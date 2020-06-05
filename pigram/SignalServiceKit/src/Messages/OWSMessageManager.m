//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSMessageManager.h"
#import "AppContext.h"
#import "AppReadiness.h"
#import "ContactsManagerProtocol.h"
#import "MimeTypeUtil.h"
#import "NSNotificationCenter+OWS.h"
#import "NotificationsProtocol.h"
#import "OWSAttachmentDownloads.h"
#import "OWSBlockingManager.h"
#import "OWSCallMessageHandler.h"
#import "OWSContact.h"
#import "OWSDevice.h"
#import "OWSDevicesService.h"
#import "OWSDisappearingConfigurationUpdateInfoMessage.h"
#import "OWSDisappearingMessagesConfiguration.h"
#import "OWSDisappearingMessagesJob.h"
#import "OWSIdentityManager.h"
#import "OWSIncomingMessageFinder.h"
#import "OWSIncomingSentMessageTranscript.h"
#import "OWSMessageSender.h"
#import "OWSMessageUtils.h"
#import "OWSOutgoingReceiptManager.h"
#import "OWSReadReceiptManager.h"
#import "OWSRecordTranscriptJob.h"
#import "OWSSyncGroupsRequestMessage.h"
#import "ProfileManagerProtocol.h"
#import "SSKEnvironment.h"
#import "SSKSessionStore.h"
#import "TSAccountManager.h"
#import "TSAttachment.h"
#import "TSAttachmentPointer.h"
#import "TSAttachmentStream.h"
#import "TSContactThread.h"
#import "TSGroupModel.h"
#import "TSGroupThread.h"
#import "TSIncomingMessage.h"
#import "TSInfoMessage.h"
#import "TSNetworkManager.h"
#import "TSOutgoingMessage.h"
#import "TSQuotedMessage.h"
#import <SignalCoreKit/Cryptography.h>
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalCoreKit/NSString+OWS.h>
#import <SignalServiceKit/OWSUnknownProtocolVersionMessage.h>
#import <SignalServiceKit/SignalRecipient.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>
#import <SignalServiceKit/ContactsUpdater.h>

NS_ASSUME_NONNULL_BEGIN


NSString *const OWSMessageBlockConversationUpdateNotification = @"OWSMessageBlockConversationUpdateNotification";

@interface OWSMessageManager () <SDSDatabaseStorageObserver>

@end

#pragma mark -

@implementation OWSMessageManager

- (instancetype)init
{
    self = [super init];

    if (!self) {
        return self;
    }

    OWSSingletonAssert();

    return self;
}

#pragma mark - Dependencies

- (id<OWSCallMessageHandler>)callMessageHandler
{
    OWSAssertDebug(SSKEnvironment.shared.callMessageHandler);

    return SSKEnvironment.shared.callMessageHandler;
}

- (id<ContactsManagerProtocol>)contactsManager
{
    OWSAssertDebug(SSKEnvironment.shared.contactsManager);

    return SSKEnvironment.shared.contactsManager;
}

- (MessageSenderJobQueue *)messageSenderJobQueue
{
    return SSKEnvironment.shared.messageSenderJobQueue;
}

- (OWSBlockingManager *)blockingManager
{
    OWSAssertDebug(SSKEnvironment.shared.blockingManager);

    return SSKEnvironment.shared.blockingManager;
}

- (OWSIdentityManager *)identityManager
{
    OWSAssertDebug(SSKEnvironment.shared.identityManager);

    return SSKEnvironment.shared.identityManager;
}

- (TSNetworkManager *)networkManager
{
    OWSAssertDebug(SSKEnvironment.shared.networkManager);

    return SSKEnvironment.shared.networkManager;
}

- (OWSOutgoingReceiptManager *)outgoingReceiptManager
{
    OWSAssertDebug(SSKEnvironment.shared.outgoingReceiptManager);

    return SSKEnvironment.shared.outgoingReceiptManager;
}

- (id<OWSSyncManagerProtocol>)syncManager
{
    OWSAssertDebug(SSKEnvironment.shared.syncManager);

    return SSKEnvironment.shared.syncManager;
}

- (TSAccountManager *)tsAccountManager
{
    OWSAssertDebug(SSKEnvironment.shared.tsAccountManager);

    return SSKEnvironment.shared.tsAccountManager;
}

- (id<ProfileManagerProtocol>)profileManager
{
    return SSKEnvironment.shared.profileManager;
}

- (id<OWSTypingIndicators>)typingIndicators
{
    return SSKEnvironment.shared.typingIndicators;
}

- (OWSAttachmentDownloads *)attachmentDownloads
{
    return SSKEnvironment.shared.attachmentDownloads;
}

- (SDSDatabaseStorage *)databaseStorage
{
    return SDSDatabaseStorage.shared;
}

- (SSKSessionStore *)sessionStore
{
    return SSKEnvironment.shared.sessionStore;
}

#pragma mark -

- (void)startObserving
{
    [self.databaseStorage addDatabaseStorageObserver:self];
}

#pragma mark - SDSDatabaseStorageObserver

- (void)databaseStorageDidUpdateWithChange:(SDSDatabaseStorageChange *)change
{
    OWSAssertIsOnMainThread();
    OWSAssertDebug(AppReadiness.isAppReady);

    if (!change.didUpdateInteractions) {
        return;
    }

    [OWSMessageUtils.sharedManager updateApplicationBadgeCount];
}

- (void)databaseStorageDidUpdateExternally
{
    OWSAssertIsOnMainThread();
    OWSAssertDebug(AppReadiness.isAppReady);

    [OWSMessageUtils.sharedManager updateApplicationBadgeCount];
}

- (void)databaseStorageDidReset
{
    OWSAssertIsOnMainThread();
    OWSAssertDebug(AppReadiness.isAppReady);

    [OWSMessageUtils.sharedManager updateApplicationBadgeCount];
}

#pragma mark - Blocking

- (BOOL)isEnvelopeSenderBlocked:(SSKProtoEnvelope *)envelope
{
    OWSAssertDebug(envelope);

    return [self.blockingManager isAddressBlocked:envelope.sourceAddress];
}

- (BOOL)isDataMessageBlocked:(SSKProtoDataMessage *)dataMessage envelope:(SSKProtoEnvelope *)envelope
{
    OWSAssertDebug(dataMessage);
    OWSAssertDebug(envelope);

    if (envelope.sourceAddress.type == SignalServiceAddressTypeGroup) {
        return [self.blockingManager isGroupIdBlocked:envelope.sourceAddress.groupid];
    } else {
        BOOL senderBlocked = [self isEnvelopeSenderBlocked:envelope];

        // If the envelopeSender was blocked, we never should have gotten as far as decrypting the dataMessage.
        OWSAssertDebug(!senderBlocked);

        return senderBlocked;
    }
}

#pragma mark - message handling 开始处理收到的消息

- (void)throws_processEnvelope:(SSKProtoEnvelope *)envelope
                 plaintextData:(NSData *_Nullable)plaintextData
               wasReceivedByUD:(BOOL)wasReceivedByUD
                   transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }
    if (!self.tsAccountManager.isRegistered) {
        OWSFailDebug(@"Not registered.");
        return;
    }
    if (!CurrentAppContext().isMainApp) {
        OWSFail(@"Not main app.");
        return;
    }

    OWSLogInfo(@"handling decrypted envelope: %@", [self descriptionForEnvelope:envelope]);

    if (!envelope.hasValidSource) {
        OWSFailDebug(@"incoming envelope has invalid source");
        return;
    }
//    if (!envelope.hasSourceDevice || envelope.sourceDevice < 1) {
//        OWSFailDebug(@"incoming envelope has invalid source device");
//        return;
//    }
    if (!envelope.hasType) {
        OWSFailDebug(@"incoming envelope is missing type.");
        return;
    }

    if ([self isEnvelopeSenderBlocked:envelope]) {
        OWSLogInfo(@"incoming envelope sender is blocked.");
        return;
    }

//    [self checkForUnknownLinkedDevice:envelope transaction:transaction];

    switch (envelope.unwrappedType) {
        case SSKProtoEnvelopeTypeTyping:
        case SSKProtoEnvelopeTypeRevoke:
        case SSKProtoEnvelopeTypePigramText:
            if (!plaintextData) {
                OWSFailDebug(@"missing decrypted data for envelope: %@", [self descriptionForEnvelope:envelope]);
                return;
            }
            [self throws_handleEnvelope:envelope
                          plaintextData:plaintextData
                        wasReceivedByUD:wasReceivedByUD
                            transaction:transaction];
            break;
        case SSKProtoEnvelopeTypeReceipt:
            //            OWSAssertDebug(!plaintextData);
            
            [self handleDeliveryReceipt:envelope transaction:transaction];
            break;
        case SSKProtoEnvelopeTypeUnknown:
            OWSLogWarn(@"Received an unknown message type");
            break;
            
        default:
            OWSLogWarn(@"Received unhandled envelope type: %d", (int)envelope.unwrappedType);
            break;
    }
}

#pragma mark 处理回执
- (void)handleDeliveryReceipt:(SSKProtoEnvelope *)envelope transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }

    // Old-style delivery notices don't include a "delivery timestamp".
    [self processDeliveryReceiptsFromRecipient:envelope.sourceAddress
                                sentTimestamps:@[
                                    @(envelope.timestamp),
                                ]
                             deliveryTimestamp:nil
                                   transaction:transaction];
}

// deliveryTimestamp is an optional parameter, since legacy
// delivery receipts don't have a "delivery timestamp".  Those
// messages repurpose the "timestamp" field to indicate when the
// corresponding message was originally sent.
- (void)processDeliveryReceiptsFromRecipient:(SignalServiceAddress *)address
                              sentTimestamps:(NSArray<NSNumber *> *)sentTimestamps
                           deliveryTimestamp:(NSNumber *_Nullable)deliveryTimestamp
                                 transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!address.isValid) {
        OWSFailDebug(@"invalid recipient.");
        return;
    }
    if (sentTimestamps.count < 1) {
        OWSFailDebug(@"Missing sentTimestamps.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }

    for (NSNumber *nsTimestamp in sentTimestamps) {
        uint64_t timestamp = [nsTimestamp unsignedLongLongValue];

        NSError *error;
        NSArray<TSOutgoingMessage *> *messages = (NSArray<TSOutgoingMessage *> *)[InteractionFinder
            interactionsWithTimestamp:timestamp
                               filter:^(TSInteraction *interaction) {
                                   return [interaction isKindOfClass:[TSOutgoingMessage class]];
                               }
                          transaction:transaction
                                error:&error];
        if (error != nil) {
            OWSFailDebug(@"Error loading interactions: %@", error);
        }

        if (messages.count < 1) {
            // The service sends delivery receipts for "unpersisted" messages
            // like group updates, so these errors are expected to a certain extent.
            //
            // TODO: persist "early" delivery receipts.
            OWSLogInfo(@"Missing message for delivery receipt: %llu", timestamp);
        } else {
            if (messages.count > 1) {
                OWSLogInfo(@"More than one message (%lu) for delivery receipt: %llu",
                    (unsigned long)messages.count,
                    timestamp);
            }
            for (TSOutgoingMessage *outgoingMessage in messages) {
                [outgoingMessage updateWithDeliveredRecipient:address
                                            deliveryTimestamp:deliveryTimestamp
                                                  transaction:transaction];
            }
        }
    }
}
#pragma mark 消息类型判断
- (void)throws_handleEnvelope:(SSKProtoEnvelope *)envelope
                plaintextData:(NSData *)plaintextData
              wasReceivedByUD:(BOOL)wasReceivedByUD
                  transaction:(SDSAnyWriteTransaction *)transaction
{
    
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!plaintextData) {
        OWSFailDebug(@"Missing plaintextData.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }
    if (envelope.timestamp < 1) {
        OWSFailDebug(@"Invalid timestamp.");
        return;
    }
    if (!envelope.hasValidSource) {
        OWSFailDebug(@"Invalid source.");
        return;
    }
//    if (envelope.sourceDevice < 1) {
//        OWSFailDebug(@"Invaid source device.");
//        return;
//    }
    
    BOOL duplicateEnvelope = [InteractionFinder existsIncomingMessageWithTimestamp:envelope.timestamp
                                                                           address:envelope.sourceAddress
                                                                    sourceDeviceId:envelope.sourceDevice
                                                                       transaction:transaction];

    if (duplicateEnvelope) {
        OWSLogInfo(@"Ignoring previously received envelope from %@ with timestamp: %llu",
            envelopeAddress(envelope),
            envelope.timestamp);
        return;
    }

    if (envelope.content != nil) {
        NSError *error;
        SSKProtoContent *_Nullable contentProto = [SSKProtoContent parseData:plaintextData error:&error];
        if (error || !contentProto) {
//            OWSFailDebug(@"could not parse proto: %@", error);
            return;
        }
        if (!envelope.sourceAddress.isValid) {
            OWSFailDebug(@"收到一个address 无效的消息");
            return;
        }
        OWSLogInfo(@"%@发了一个消息 handling content: <Content: %@>",envelope, [self descriptionForContent:contentProto]);
        [self updateUserProfile:envelope transcation:transaction];
        if (contentProto.syncMessage) {
            [self throws_handleIncomingEnvelope:envelope
                                withSyncMessage:contentProto.syncMessage
                                    transaction:transaction];

            [[OWSDeviceManager sharedManager] setHasReceivedSyncMessage];
        } else if (contentProto.dataMessage) {
            if (!contentProto.dataMessage.shareMessage) {
                [self handleIncomingEnvelope:envelope
                                        withDataMessage:contentProto.dataMessage
                                        wasReceivedByUD:wasReceivedByUD
                                            transaction:transaction];
            } else {
                [NSNotificationCenter.defaultCenter postNotificationName:@"kNotification_Pigram_New_Message" object:@[envelope,contentProto,transaction]];
            }
           
        } else if (contentProto.callMessage) {
            [self handleIncomingEnvelope:envelope withCallMessage:contentProto.callMessage transaction:transaction];
        } else if (contentProto.typingMessage) {
            [self handleIncomingEnvelope:envelope withTypingMessage:contentProto.typingMessage transaction:transaction];
        } else if (contentProto.nullMessage) {
            OWSLogInfo(@"Received null message.");
        } else if (contentProto.receiptMessage) {
            [self handleIncomingEnvelope:envelope
                      withReceiptMessage:contentProto.receiptMessage
                             transaction:transaction];
        } else if (contentProto.groupOperation) {
            [self handleIncomingEnvelope:envelope withGroupOperation:contentProto.groupOperation wasReceivedByUD:false transaction:transaction];
        } else if (contentProto.revokeMessage) {
            [self handleIncomingEnvelope:envelope withRevokeMessage:contentProto.revokeMessage wasReceivedByUD:false transaction:transaction];
        } else if (contentProto.revokeUserMessage) {
            
            [self handleRevokeUserMessagesWithEnvelope:envelope message:contentProto.revokeUserMessage transaction:transaction];
        } else {
            //hansen 定义的新消息 发送到外围扩展区处理
            [NSNotificationCenter.defaultCenter postNotificationName:@"kNotification_Pigram_New_Message" object:@[envelope,contentProto,transaction]];
            OWSLogWarn(@"Ignoring envelope. Content with no known payload");
        }
    }  else {
        OWSProdInfoWEnvelope([OWSAnalyticsEvents messageManagerErrorEnvelopeNoActionablePayload], envelope);
    }
}

#pragma mark  更新发送人头像和名称
- (void)updateUserProfile:(SSKProtoEnvelope *)envelop transcation:(SDSAnyWriteTransaction *)transaction {
    
    if (envelop.sourceName.length == 0 ) {
//           OWSFailDebug(@"个人名称: %@", envelop.sourceName);
    }
    if (envelop.sourceAddress.type == SignalServiceAddressTypeGroup && envelop.groupName.length == 0) {
//        OWSFailDebug(@"群名称：%@", envelop.groupName);
    }
    
    if (envelop.groupId.length > 0) {
        OWSUserProfile *profile = [OWSUserProfile getOrBuildUserProfileForAddress:[[SignalServiceAddress alloc] initWithPhoneNumber:envelop.sourceId] transaction:transaction];
        OWSUserProfile *group = [OWSUserProfile getOrBuildUserProfileForAddress:envelop.sourceAddress transaction:transaction];
        [self updateProfile:profile name:envelop.sourceName avatar:envelop.sourceAvatar transaction:transaction];
        [self updateProfile:group name:envelop.groupName avatar:envelop.groupAvatar transaction:transaction];
    } else {
        OWSUserProfile *profile = [OWSUserProfile getOrBuildUserProfileForAddress:envelop.sourceAddress transaction:transaction];
        [self updateProfile:profile name:envelop.sourceName avatar:envelop.sourceAvatar transaction:transaction];
    }
}

- (void)updateProfile:(OWSUserProfile *)profile name:(NSString *)name avatar:(NSString *)avatar transaction:(SDSAnyWriteTransaction *)transaction {
    
//    if (name.length == 0 ) {
//        OWSFailDebug(@"名称很重要呀~~~~~~");
//    }
        
    if (![profile.avatarUrlPath isEqualToString:avatar] && avatar.length > 0 && name.length != 0) {
        [profile updateWithProfileName:name avatarUrlPath:avatar avatarFileName:nil transaction:transaction completion:nil];
    } else {
        if (![name isEqualToString:profile.profileName] && name.length > 0) {
            [profile updateWithProfileName:name avatarUrlPath:avatar avatarFileName:profile.avatarFileName transaction:transaction completion:nil];
        }
    }
}
#pragma mark 处理datamessage
- (void)handleIncomingEnvelope:(SSKProtoEnvelope *)envelope
               withDataMessage:(SSKProtoDataMessage *)dataMessage
               wasReceivedByUD:(BOOL)wasReceivedByUD
                   transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!dataMessage) {
        OWSFailDebug(@"Missing dataMessage.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }

    if ([self isDataMessageBlocked:dataMessage envelope:envelope]) {
        NSString *logMessage =
            [NSString stringWithFormat:@"Ignoring blocked message from sender: %@", envelope.sourceAddress];
        if (envelope.sourceAddress.type == SignalServiceAddressTypeGroup) {
            logMessage = [logMessage stringByAppendingFormat:@" in group: %@", envelope.sourceAddress.groupid];
        }
        OWSLogError(@"%@", logMessage);
        return;
    }

    if (dataMessage.hasTimestamp) {
        if (dataMessage.timestamp <= 0) {
            OWSFailDebug(@"Ignoring message with invalid data message timestamp: %@", envelope.sourceAddress);
            // TODO: Add analytics.
            return;
        }
        // This prevents replay attacks by the service.
        if (dataMessage.timestamp != envelope.timestamp) {
//            OWSFailDebug(@"Ignoring message with non-matching data message timestamp: %@", envelope.sourceAddress);
            
            // TODO: Add analytics.
            return;
        }
    }
    

//    if ([dataMessage hasProfileKey]) {
//        NSData *profileKey = [dataMessage profileKey];
//        SignalServiceAddress *address = envelope.sourceAddress;
//        if (profileKey.length == kAES256_KeyByteLength) {
//            [self.profileManager setProfileKeyData:profileKey forAddress:address transaction:transaction];
//        } else {
//            OWSFailDebug(
//                @"Unexpected profile key length:%lu on message from:%@", (unsigned long)profileKey.length, address);
//        }
//    }

    if ((dataMessage.flags & SSKProtoDataMessageFlagsExpirationTimerUpdate) != 0) {
        [self handleExpirationTimerUpdateMessageWithEnvelope:envelope dataMessage:dataMessage transaction:transaction];
    }  else if (dataMessage.attachments.count > 0) {
        [self handleReceivedMediaWithEnvelope:envelope
                                  dataMessage:dataMessage
                              wasReceivedByUD:wasReceivedByUD
                                  transaction:transaction];
    } else {
        [self handleReceivedTextMessageWithEnvelope:envelope
                                        dataMessage:dataMessage
                                    wasReceivedByUD:wasReceivedByUD
                                        transaction:transaction];
    }

    // Send delivery receipts for "valid data" messages received via UD.
//    if (wasReceivedByUD) {
        [self.outgoingReceiptManager enqueueDeliveryReceiptForEnvelope:envelope];
//    }
}

- (void)sendGroupInfoRequest:(NSString *)groupId
                    envelope:(SSKProtoEnvelope *)envelope
                 transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }
    if (groupId.length < 1) {
        OWSFailDebug(@"Invalid groupId.");
        return;
    }

    // FIXME: https://github.com/signalapp/Signal-iOS/issues/1340
    OWSLogInfo(@"Sending group info request: %@", envelopeAddress(envelope));

    TSThread *thread = [TSContactThread getOrCreateThreadWithContactAddress:envelope.sourceAddress
                                                                transaction:transaction];

    OWSSyncGroupsRequestMessage *syncGroupsRequestMessage =
        [[OWSSyncGroupsRequestMessage alloc] initWithThread:thread groupId:groupId];

    [self.messageSenderJobQueue addMessage:syncGroupsRequestMessage.asPreparer transaction:transaction];
}

- (void)handleIncomingEnvelope:(SSKProtoEnvelope *)envelope
            withReceiptMessage:(SSKProtoReceiptMessage *)receiptMessage
                   transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!receiptMessage) {
        OWSFailDebug(@"Missing receiptMessage.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }
    if (!receiptMessage.hasType) {
        OWSFail(@"Missing type.");
        return;
    }

    NSArray<NSNumber *> *sentTimestamps = receiptMessage.timestamp;
    SignalServiceAddress *address = [[SignalServiceAddress alloc] initWithPhoneNumber:envelope.sourceAddress.phoneNumber];
    switch (receiptMessage.unwrappedType) {
        case SSKProtoReceiptMessageTypeDelivery:
            OWSLogVerbose(@"Processing receipt message with delivery receipts.");
            [self processDeliveryReceiptsFromRecipient:address
                                        sentTimestamps:sentTimestamps
                                     deliveryTimestamp:@(envelope.timestamp)
                                           transaction:transaction];
            return;
        case SSKProtoReceiptMessageTypeRead:
            OWSLogVerbose(@"Processing receipt message with read receipts.");
            [OWSReadReceiptManager.sharedManager processReadReceiptsFromRecipient:address
                                                                   sentTimestamps:sentTimestamps
                                                                    readTimestamp:envelope.timestamp];
            break;
        case SSKProtoReceiptMessageTypeFailed_not_friend:
            [self handleReceiptNotFriendWithEnvelope:envelope sentTimestamps:sentTimestamps transaction:transaction];
            break;
        case SSKProtoReceiptMessageTypeFailed_no_permission:
            [self handleReceiptNoPermissionWithEnvelope:envelope sentTimestamps:sentTimestamps transaction:transaction];
            break;
        default:
            OWSLogInfo(@"Ignoring receipt message of unknown type: %d.", (int)receiptMessage.unwrappedType);
            return;
    }
}

#pragma mark 处理不是好友的消息回执
- (void)handleReceiptNotFriendWithEnvelope:(SSKProtoEnvelope *)envelope sentTimestamps:(NSArray<NSNumber *> *)sentTimestamps transaction:(SDSAnyWriteTransaction *)transaction {
    
    if (!envelope) {
          OWSFailDebug(@"Missing envelope.");
          return;
      }

//    uint64_t timestamp = envelope.timestamp;
    TSThread *thread = nil;
    if (envelope.isGroup) {
        
        // Group messages create the group if it doesn't already exist.
        //
        // We distinguish between the old group state (if any) and the new group state.
        NSString *groupId = envelope.groupId;
        thread = [TSGroupThread threadWithGroupId:groupId transaction:transaction];
        
        
        
    } else {
        thread = [TSContactThread getOrCreateThreadWithContactAddress:envelope.sourceAddress
                                                                           transaction:transaction];
        
       
    }
    [SSKEnvironment.shared.databaseStorage readWithBlock:^(SDSAnyReadTransaction * _Nonnull read) {
        OWSUserProfile *user = [OWSUserProfile getUserProfileForAddress:envelope.sourceAddress transaction:read];
        user.isNeedVerify = true;
    }];
    NSString *text = NSLocalizedString(@"对方已不是你的好友，请从新发送好友验证。", nil);
    for (NSNumber *nsTimestamp in sentTimestamps) {
        
        uint64_t timestamp = [nsTimestamp unsignedLongLongValue];

           NSError *error;
           NSArray<TSOutgoingMessage *> *messages = (NSArray<TSOutgoingMessage *> *)[InteractionFinder
               interactionsWithTimestamp:timestamp
                                  filter:^(TSInteraction *interaction) {
                                      return [interaction isKindOfClass:[TSOutgoingMessage class]];
                                  }
                             transaction:transaction
                                   error:&error];
           if (error != nil) {
               OWSFailDebug(@"Error loading interactions: %@", error);
           }

           if (messages.count < 1) {
               // The service sends delivery receipts for "unpersisted" messages
               // like group updates, so these errors are expected to a certain extent.
               //
               // TODO: persist "early" delivery receipts.
               OWSLogInfo(@"Missing message for delivery receipt: %llu", timestamp);
           } else {
               if (messages.count > 1) {
                   OWSLogInfo(@"More than one message (%lu) for delivery receipt: %llu",
                       (unsigned long)messages.count,
                       timestamp);
               }
               for (TSOutgoingMessage *outgoingMessage in messages) {
                   [outgoingMessage updateWithSuccessedToFailureReceipent:envelope.sourceAddress readTimestamp:envelope.timestamp failureText:text transaction:transaction];
               }
           }
    }
   
    TSInfoMessage *info = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp] inThread:thread messageType:TSInfoMessageTypeGroupUpdate customMessage:text];
    [info setServerTimestamp:@(envelope.serverTimestamp)];
    [info anyInsertWithTransaction:transaction];
}

#pragma mark 处理撤回这个人的所有的消息
- (void)handleRevokeUserMessagesWithEnvelope:(SSKProtoEnvelope *)envelope message:(SSKProtoRevokeUserMessage *)message transaction:(SDSAnyWriteTransaction *)transaction {
    
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return ;
    }
    if (message.targetUserId.length == 0 || message.targetGroupId.length == 0) {
        OWSFailDebug(@"Missing target user id or target group id");
        return;
    }
    
    if (!envelope.isGroup) {
        OWSFailDebug(@"撤回个人所有消息，只能在群组中！！！！！！");
        return;
    }
    
    NSString *groupId = envelope.groupId;
    TSGroupThread *_Nullable oldGroupThread = [TSGroupThread threadWithGroupId:groupId transaction:transaction];
    
    if (oldGroupThread) {
        [transaction addCompletionWithBlock:^{
            
            [self revokeUserMessagesInGroupThreadId:oldGroupThread.uniqueId targetUserId:message.targetUserId];
            
        }];
    }
}


- (void)revokeUserMessagesInGroupThreadId:(NSString *)threadId targetUserId:(NSString *)userId {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *targetUserId = userId;
        BOOL isMe = [targetUserId isEqualToString:TSAccountManager.localUserId];
        InteractionFinder *finder = [[InteractionFinder alloc] initWithThreadUniqueId:threadId];
        
        [SSKEnvironment.shared.databaseStorage readWithBlock:^(SDSAnyReadTransaction * _Nonnull read) {
            [finder enumerateInteractionsWithTransaction:read error:NULL block:^(TSInteraction * _Nonnull interaction, BOOL * _Nonnull stop) {
                
                [SSKEnvironment.shared.databaseStorage asyncWriteWithBlock:^(SDSAnyWriteTransaction * _Nonnull write) {
                    if (isMe) {
                        if (interaction.interactionType == OWSInteractionType_OutgoingMessage) {
                            [interaction anyRemoveWithTransaction:write];
                        }
                    } else {
                        if (interaction.interactionType == OWSInteractionType_IncomingMessage) {
                            TSIncomingMessage *message = (TSIncomingMessage *)interaction;
                            if ([message.authorAddress.userid isEqualToString:targetUserId]) {
                                [interaction anyRemoveWithTransaction:write];
                            }
                        }
                    }
                }];
            }];
        }];
    });
}

#pragma mark 处理没有发送权限的回执
- (void)handleReceiptNoPermissionWithEnvelope:(SSKProtoEnvelope *)envelope sentTimestamps:(NSArray<NSNumber *> *)sentTimestamps transaction:(SDSAnyWriteTransaction *)transaction {
    
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return ;
    }
//    uint64_t timestamp = envelope.timestamp;
    TSThread *thread = nil;
    if (envelope.isGroup) {
        // Group messages create the group if it doesn't already exist.
        //
        // We distinguish between the old group state (if any) and the new group state.
        NSString *groupId = envelope.groupId;
        thread = [TSGroupThread threadWithGroupId:groupId transaction:transaction];
                
    } else {
        thread = [TSContactThread getOrCreateThreadWithContactAddress:envelope.sourceAddress
                                                                           transaction:transaction];
    }
    NSString *text = NSLocalizedString(@"你没有该权限", nil);
    for (NSNumber *nsTimestamp in sentTimestamps) {
        
        uint64_t timestamp = [nsTimestamp unsignedLongLongValue];
        
        NSError *error;
        NSArray<TSOutgoingMessage *> *messages = (NSArray<TSOutgoingMessage *> *)[InteractionFinder
                                                                                  interactionsWithTimestamp:timestamp
                                                                                  filter:^(TSInteraction *interaction) {
            return [interaction isKindOfClass:[TSOutgoingMessage class]];
        }
                                                                                  transaction:transaction
                                                                                  error:&error];
        if (error != nil) {
            OWSFailDebug(@"Error loading interactions: %@", error);
        }
        
        if (messages.count < 1) {
            // The service sends delivery receipts for "unpersisted" messages
            // like group updates, so these errors are expected to a certain extent.
            //
            // TODO: persist "early" delivery receipts.
            OWSLogInfo(@"Missing message for delivery receipt: %llu", timestamp);
        } else {
            if (messages.count > 1) {
                OWSLogInfo(@"More than one message (%lu) for delivery receipt: %llu",
                           (unsigned long)messages.count,
                           timestamp);
            }
            for (TSOutgoingMessage *outgoingMessage in messages) {
                [outgoingMessage updateWithSuccessedToFailureReceipent:envelope.sourceAddress readTimestamp:envelope.timestamp failureText:text transaction:transaction];
            }
        }
    }
    TSInfoMessage *info = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp] inThread:thread messageType:TSInfoMessageTypeGroupUpdate customMessage:NSLocalizedString(@"你没有该权限", nil)];
    [info setServerTimestamp:@(envelope.serverTimestamp)];
    [info anyInsertWithTransaction:transaction];

}
- (void)handleIncomingEnvelope:(SSKProtoEnvelope *)envelope
               withCallMessage:(SSKProtoCallMessage *)callMessage
                   transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!callMessage) {
        OWSFailDebug(@"Missing callMessage.");
        return;
    }

    if ([self isEnvelopeSenderBlocked:envelope]) {
        OWSFailDebug(@"envelope sender is blocked. Shouldn't have gotten this far.");
        return;
    }

    if ([callMessage hasProfileKey]) {
        NSData *profileKey = [callMessage profileKey];
        SignalServiceAddress *address = envelope.sourceAddress;
        [self.profileManager setProfileKeyData:profileKey forAddress:address transaction:transaction];
    }

    // By dispatching async, we introduce the possibility that these messages might be lost
    // if the app exits before this block is executed.  This is fine, since the call by
    // definition will end if the app exits.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (callMessage.offer) {
            [self.callMessageHandler receivedOffer:callMessage.offer fromCaller:envelope.sourceAddress];
        } else if (callMessage.answer) {
            [self.callMessageHandler receivedAnswer:callMessage.answer fromCaller:envelope.sourceAddress];
        } else if (callMessage.iceUpdate.count > 0) {
            for (SSKProtoCallMessageIceUpdate *iceUpdate in callMessage.iceUpdate) {
                [self.callMessageHandler receivedIceUpdate:iceUpdate fromCaller:envelope.sourceAddress];
            }
        } else if (callMessage.hangup) {
            OWSLogVerbose(@"Received CallMessage with Hangup.");
            [self.callMessageHandler receivedHangup:callMessage.hangup fromCaller:envelope.sourceAddress];
        } else if (callMessage.busy) {
            [self.callMessageHandler receivedBusy:callMessage.busy fromCaller:envelope.sourceAddress];
        } else {
            OWSProdInfoWEnvelope([OWSAnalyticsEvents messageManagerErrorCallMessageNoActionablePayload], envelope);
        }
    });
}

- (void)handleIncomingEnvelope:(SSKProtoEnvelope *)envelope
             withTypingMessage:(SSKProtoTypingMessage *)typingMessage
                   transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(transaction);

    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!typingMessage) {
        OWSFailDebug(@"Missing typingMessage.");
        return;
    }
    if (typingMessage.timestamp != envelope.timestamp) {
        OWSFailDebug(@"typingMessage has invalid timestamp.");
        return;
    }
    if (envelope.sourceAddress.isLocalAddress) {
        OWSLogVerbose(@"Ignoring typing indicators from self or linked device.");
        return;
    } else if ([self.blockingManager isAddressBlocked:envelope.sourceAddress]
        || (typingMessage.hasGroupID && [self.blockingManager isGroupIdBlocked:typingMessage.groupID])) {
        NSString *logMessage =
            [NSString stringWithFormat:@"Ignoring blocked message from sender: %@", envelope.sourceAddress];
        if (typingMessage.hasGroupID) {
            logMessage = [logMessage stringByAppendingFormat:@" in group: %@", typingMessage.groupID];
        }
        OWSLogError(@"%@", logMessage);
        return;
    }
    

    TSThread *_Nullable thread;
    if (typingMessage.hasGroupID) {
        TSGroupThread *groupThread = [TSGroupThread threadWithGroupId:typingMessage.groupID transaction:transaction];

        if (!groupThread.isLocalUserInGroup) {
            OWSLogInfo(@"Ignoring messages for left group.");
            return;
        }

        thread = groupThread;
    } else {
        thread = [TSContactThread getThreadWithContactAddress:envelope.sourceAddress transaction:transaction];
    }

    if (!thread) {
        // This isn't neccesarily an error.  We might not yet know about the thread,
        // in which case we don't need to display the typing indicators.
        OWSLogWarn(@"Could not locate thread for typingMessage.");
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (!typingMessage.hasAction) {
            OWSFailDebug(@"Type message is missing action.");
            return;
        }
        SignalServiceAddress *address = [[SignalServiceAddress alloc] initWithPhoneNumber:envelope.sourceId];
        switch (typingMessage.unwrappedAction) {
            case SSKProtoTypingMessageActionStarted:
                [self.typingIndicators didReceiveTypingStartedMessageInThread:thread
                                                                      address:address
                                                                     deviceId:envelope.sourceDevice];
                break;
            case SSKProtoTypingMessageActionStopped:
                [self.typingIndicators didReceiveTypingStoppedMessageInThread:thread
                                                                      address:address
                                                                     deviceId:envelope.sourceDevice];
                break;
            default:
                OWSFailDebug(@"Typing message has unexpected action.");
                break;
        }
    });
}
#pragma mark 收到撤回消息的消息
- (void)handleIncomingEnvelope:(SSKProtoEnvelope *)envelope
withRevokeMessage:(NSArray<SSKProtoRevokeMessage *> *)messages
                 wasReceivedByUD:(BOOL)wasReceivedByUD transaction:(SDSAnyWriteTransaction *)transaction {
    
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    
    [messages enumerateObjectsUsingBlock:^(SSKProtoRevokeMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SSKProtoRevokeMessage *message = messages.firstObject;

        if (!message.targetUserId) {
            OWSFailDebug(@"Missing targetUserId.");
            return;
        }
        if (!message.targetTimestamp) {
//            OWSFailDebug(@"Missing targetTimestamp.");
            return;
        }
        
        TSThread *thread = nil;
        if (envelope.isGroup) {
            
            // Group messages create the group if it doesn't already exist.
            //
            // We distinguish between the old group state (if any) and the new group state.
            NSString *groupId = envelope.groupId;
            thread = [TSGroupThread threadWithGroupId:groupId transaction:transaction];
            
        } else {
            thread = [TSContactThread getOrCreateThreadWithContactAddress:envelope.sourceAddress
                                                              transaction:transaction];
        }
        NSNumber *timestamp = @(message.targetTimestamp);
        NSArray<TSMessage *> *resultMessages = nil;
        NSError *error;
        if ([message.targetUserId isEqualToString:TSAccountManager.localUserId]) {
            resultMessages = (NSArray<TSOutgoingMessage *> *)[InteractionFinder
                                                                                      interactionsWithTimestamp:message.targetTimestamp
                                                                                      filter:^(TSInteraction *interaction) {
                return [interaction isKindOfClass:[TSOutgoingMessage class]];
            }
                                                                                      transaction:transaction
                                                                                      error:&error];
            
        } else {
            resultMessages = (NSArray<TSIncomingMessage *> *)[InteractionFinder
                                                                                             interactionsWithTimestamp:message.targetTimestamp
                                                                                             filter:^(TSInteraction *interaction) {
                       return [interaction isKindOfClass:[TSIncomingMessage class]];
                   }
                                                                                             transaction:transaction
                                                                                             error:&error];
        }
        if (error != nil) {
            OWSFailDebug(@"Error loading interactions: %@", error);
        }
        
        if (resultMessages.count < 1) {
            // The service sends delivery receipts for "unpersisted" messages
            // like group updates, so these errors are expected to a certain extent.
            //
            // TODO: persist "early" delivery receipts.
            OWSLogInfo(@"Missing message for revoke message: %llu", timestamp);
        } else {
            if (resultMessages.count > 1) {
                OWSLogInfo(@"More than one message (%lu) for delivery receipt: %@",
                           (unsigned long)messages.count,
                           timestamp);
            }
            for (TSMessage *resultMessage in resultMessages) {
                if (envelope.isGroup) {
                    if (resultMessage.interactionType == OWSInteractionType_IncomingMessage) {
                        TSIncomingMessage *incoming = (TSIncomingMessage *)resultMessage;
                        if (![incoming.authorAddress.userid isEqualToString:message.targetUserId]) {
                            OWSLogInfo(@"查找到的这条撤回消息对应不上 target id：",message.targetUserId);
                            continue;
                        }
                    }
                   
                }
                [resultMessage anyRemoveWithTransaction:transaction];
            }
        }
    }];
    

}


#pragma mark 收到处理群组的操作
- (void)handleIncomingEnvelope:(SSKProtoEnvelope *)envelope
            withGroupOperation:(SSKProtoGroupContext *)message
               wasReceivedByUD:(BOOL)wasReceivedByUD transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!message) {
        OWSFailDebug(@"Missing dataMessage.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }
    if (!message.id) {
        OWSFailDebug(@"收到的不是群相关的操作");
        return;
    }
    if (!message.hasType) {
        OWSFailDebug(@"Group message is missing type.");
        return;
    }
    OWSLogInfo(@"%@",message);
    NSString *groupId = envelope.groupId ?: message.id;

    
    TSGroupThread *_Nullable oldGroupThread =
    [TSGroupThread threadWithGroupId:groupId transaction:transaction];
    NSMutableString *updateInfo = [[NSMutableString alloc] init];
    [message.members enumerateObjectsUsingBlock:^(SSKProtoGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.id isEqualToString:TSAccountManager.localUserId]) {
            [updateInfo appendString:@"你"];
        } else {
            [updateInfo appendString:obj.name ?: @"***"];
        }
        if (idx != message.members.count - 1) {
            [updateInfo appendString:@"、"];
        }
    }];
    PigramGroupNotice *newNotice = [PigramGroupNotice initFromProtoNotice:message.notices];
    if (!oldGroupThread) {
        PigramGroupMember *member = [[PigramGroupMember alloc] initWithUserId:TSAccountManager.localUserId];
        TSGroupModel *model = [[TSGroupModel alloc] initWithTitle:message.name ?: envelope.groupName members:@[member] groupId:message.id owner:envelope.sourceId];
        oldGroupThread = [[TSGroupThread alloc] initWithGroupModel:model];
        model.membersCount = message.memberCount;
        model.txGroupType = TXGroupTypeJoined;
        model.notices = @[newNotice];
        oldGroupThread.shouldThreadBeVisible = YES;
        [oldGroupThread anyInsertWithTransaction:transaction];
    }
//    if (message.unwrappedType != SSKProtoGroupContextTypeUpdate) {
//        if (!oldGroupThread.isLocalUserInGroup && (message.unwrappedType != SSKProtoGroupContextTypeApplyAccept || message.unwrappedType == SSKProtoGroupContextTypeApplyDecline) ) {
//            OWSLogInfo(@"Ignoring messages for left group.");
//            return;
//        }
//    }
  
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_Pigram_Group_Message_Handle_C" object:@[envelope,message]];
    TSGroupModel *groupModel = oldGroupThread.groupModel;
    NSMutableArray<PigramGroupMember *> *newMembers = [groupModel.allMembers mutableCopy];
    groupModel.membersCount = message.memberCount;
    switch (message.unwrappedType) {
        //被添加入群 或者创建群
        case SSKProtoGroupContextTypeDrag: {
            __block NSMutableArray<PigramRoleRightBan *> *perms = [[NSMutableArray alloc] initWithCapacity:message.permissions.count];
            [message.permissions enumerateObjectsUsingBlock:^(SSKProtoGroupPermission * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PigramRoleRightBan *right = [PigramRoleRightBan new];
                right.role = obj.role;
                right.groupRightBan = obj.rightBan;
                [perms addObject:right];
            }];
            if (perms.count > 0) {
                groupModel.permRightBans = perms;
            }
            PigramGroupMember *member = [groupModel memberWithUserId:TSAccountManager.localUserId];
            if (!member) {
                member = [PigramGroupMember getGroupMemberWithProtoMember:message.members.firstObject];
                NSMutableArray *array = [[NSMutableArray alloc] initWithArray:groupModel.allMembers];
                [array addObject:member];
                groupModel.allMembers = array.copy;;
            }
            groupModel.membersCount = message.memberCount;
            groupModel.txGroupType = TXGroupTypeJoined;
            [oldGroupThread anyUpdateGroupThreadWithTransaction:transaction block:^(TSGroupThread * thread) {
                thread.groupModel = groupModel;
            }];
            [updateInfo appendString:NSLocalizedString(@" 加入了群组！", nil)];
            TSInfoMessage *infoMessage = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp] inThread:oldGroupThread messageType: TSInfoMessageTypeGroupUpdate customMessage:updateInfo];
            [infoMessage setServerTimestamp:@(envelope.serverTimestamp)];
            [infoMessage anyInsertWithTransaction:transaction];
                    
            ///更新在拉入群前的一些操作
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:OWSMessageBlockConversationUpdateNotification object:nil];
            });

        }
            break;
        //添加操作  取决于target
        case SSKProtoGroupContextTypeAdd: {
            
            if (message.target == SSKProtoGroupContextTargetManager) {
            
                [message.members enumerateObjectsUsingBlock:^(SSKProtoGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    PigramGroupMember *member = [groupModel memberWithUserId:obj.id];
                    if (member) {
                        member.perm = obj.roleInGroup;
                    }
                    if ([obj.id isEqualToString:TSAccountManager.localUserId]) {
                        TSInfoMessage *infoMessage = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                                                                                    inThread:oldGroupThread
                                                                                                 messageType:TSInfoMessageTypeGroupUpdate
                                                                                               customMessage:@"你被群主设置成管理员了！"];
                        [infoMessage setServerTimestamp:@(envelope.serverTimestamp)];
                                       [infoMessage anyInsertWithTransaction:transaction];
                    }
                    
                }];
                groupModel.allMembers = newMembers.copy;
                [oldGroupThread anyUpdateGroupThreadWithTransaction:transaction block:^(TSGroupThread * thread) {
                    thread.groupModel = groupModel;
                }];
            }
            
        }
            break;
        //删除操作  取决于target
        case SSKProtoGroupContextTypeRemove: {
            
            if (message.target == SSKProtoGroupContextTargetManager) {
                [message.members enumerateObjectsUsingBlock:^(SSKProtoGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    PigramGroupMember *member = [groupModel memberWithUserId:obj.id];
                    if (member) {
                        member.perm = obj.roleInGroup;
                    }
                    if ([obj.id isEqualToString:TSAccountManager.localUserId]) {
                        
                        TSInfoMessage *infoMessage = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                                                                     inThread:oldGroupThread
                                                                                  messageType:TSInfoMessageTypeGroupUpdate
                                                                                customMessage:@"你的管理员头衔被群主解除了！"];
                        [infoMessage setServerTimestamp:@(envelope.serverTimestamp)];
                        [infoMessage anyInsertWithTransaction:transaction];
                        //去除在此群的验证信息
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_Pigram_Group_Romove_Manager_handled" object:oldGroupThread.groupModel.groupId];
                        });
                    }
                }];
                groupModel.allMembers = newMembers.copy;
                [oldGroupThread anyUpdateGroupThreadWithTransaction:transaction block:^(TSGroupThread * thread) {
                    thread.groupModel = groupModel;
                }];
                
            }  else if (message.target == SSKProtoGroupContextTargetMember) {
                
                [message.members enumerateObjectsUsingBlock:^(SSKProtoGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   
                    if ([obj.id isEqualToString:TSAccountManager.localUserId]) {
                        //去除在此群的验证信息
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_Pigram_Group_Romove_Manager_handled" object:oldGroupThread.groupModel.groupId];
                        });
                        groupModel.txGroupType = TXGroupTypeExit;
                        [oldGroupThread leaveGroupWithTransaction:transaction];
                    }
                    PigramGroupMember *member = [groupModel memberWithUserId:obj.id];
                    [newMembers removeObject:member];
                    
                }];
                [updateInfo appendFormat:@" %@", NSLocalizedString(@"被移除群聊", nil)];
                groupModel.allMembers = newMembers.copy;
                [oldGroupThread anyUpdateGroupThreadWithTransaction:transaction block:^(TSGroupThread * thread) {
                   thread.groupModel = groupModel;
                }];
                TSInfoMessage *infoMessage = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                                                             inThread:oldGroupThread
                                                                          messageType:TSInfoMessageTypeGroupUpdate
                                                                        customMessage:updateInfo];
                [infoMessage setServerTimestamp:@(envelope.serverTimestamp)];
                [infoMessage anyInsertWithTransaction:transaction];
            }
            
        }
            break;
        /// 群中的某个人被拉黑 或取消拉黑
        case SSKProtoGroupContextTypeBlock: {
            __block NSString *customerMessage = nil;
            [message.members enumerateObjectsUsingBlock:^(SSKProtoGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PigramGroupMember  *member = [groupModel memberWithUserId:obj.id];
                if (member != nil) {
                    member.memberStatus = obj.memberStatus;
                }
                if ([obj.id isEqualToString:TSAccountManager.localUserId]) {
                    //0.5秒的时间够 数据库更新了。。。。
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:OWSMessageBlockConversationUpdateNotification object:nil];
                    });
                }
                if (obj.memberStatus == 1) {
                    customerMessage = @" 被解除禁言～";
                } else if (obj.memberStatus == 2) {
                    customerMessage = @" 被禁言了～";
                }
            }];
           
            [oldGroupThread anyUpdateGroupThreadWithTransaction:transaction block:^(TSGroupThread * _Nonnull thread) {
                thread.groupModel = groupModel;
            }];
            if (updateInfo.length > 0) {
                [updateInfo appendString:customerMessage];
                TSInfoMessage *info = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                                                      inThread:oldGroupThread
                                                                   messageType:TSInfoMessageTypeGroupUpdate
                                                                 customMessage:updateInfo];
                [info setServerTimestamp:@(envelope.serverTimestamp)];
                [info anyInsertWithTransaction:transaction];
                                          }
        }
            break;
        ///更新操作
        case SSKProtoGroupContextTypeUpdate: {
            // Ensures that the thread exists but doesn't update it.
            NSString *newOwner = groupModel.groupOwner;
            NSString *newGroupName = groupModel.groupName;
            NSString *newAvatar = groupModel.avatar;
            NSString *link = groupModel.linkString;
            NSArray<PigramRoleRightBan *> *groupPerms = groupModel.permRightBans;
            switch (message.target) {
                case SSKProtoGroupContextTargetNone:
                    
                    break;
                case SSKProtoGroupContextTargetLink:
                    link = message.link;
                    
                    break;
                case SSKProtoGroupContextTargetName:
                    //如果已经离群并且 角色不是member直接返回 应该告诉消息发送者我已经离群 让他将我删除
                    if (oldGroupThread.groupModel.txGroupType == TXGroupTypeExit) {
                        return;
                    }
                    newGroupName = envelope.groupName ?: message.name;
                    [updateInfo appendFormat:@"群名称被修改为 %@", newGroupName];
                    break;
                case SSKProtoGroupContextTargetAvatar:
                    newAvatar = message.avatar;
                    
                    break;
                case SSKProtoGroupContextTargetOwner:
                {

                    //如果已经离群并且被转让的群主不是我 角色不是member直接返回 应该告诉消息发送者我已经离群 让他将我删除
                    if (oldGroupThread.groupModel.txGroupType == TXGroupTypeExit && (![TSAccountManager.localUserId isEqualToString:message.members.firstObject.id])) {
                        return;
                    }
                    __block PigramGroupMember *oldOwnerObj = nil;
                    __block PigramGroupMember *newOwnerObj = nil;
                    [message.members enumerateObjectsUsingBlock:^(SSKProtoGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        PigramGroupMember *member = [PigramGroupMember getGroupMemberWithProtoMember:obj];
                        if (obj.roleInGroup == 0) {
                            newOwnerObj = member;
                        } else {
                            oldOwnerObj = member;
                        }
                        
                    }];
                    newOwner = newOwnerObj.userId;
                    PigramGroupMember *oldOwner =  [groupModel memberWithUserId:groupModel.groupOwner];
                    if (oldOwner) {
                        oldOwner.perm = 2;
                    }
                    PigramGroupMember *newOwnerMember =  [groupModel memberWithUserId:newOwner];
                    if (newOwnerMember) {
                        newOwnerMember.perm = 0;
                        newOwnerMember.memberStatus = 1;
                    }
                    [updateInfo deleteCharactersInRange:NSMakeRange(0, updateInfo.length)];
                    [updateInfo appendFormat:@"%@ 将群主转让给 %@", oldOwnerObj.getRemarkNameInfo, [newOwnerObj.userId isEqualToString:TSAccountManager.localUserId] ? @"你" : newOwnerObj.getRemarkNameInfo];

                }
                    break;
                case SSKProtoGroupContextTargetNotice:
                    
                {
                    [oldGroupThread anyUpdateGroupThreadWithTransaction:transaction block:^(TSGroupThread * _Nonnull thread) {
                        thread.groupModel.notices = @[newNotice];
                    }];
                    if (newNotice.content.length > 0) {
                        [updateInfo appendFormat:@"群公告更新了~~\n%@",message.notices.content];
                    }
                }
                    
                    break;
                    //对群组权限操作 对应 message.perm
                case SSKProtoGroupContextTargetPermGroup:
                {
                    SSKProtoGroupPermission *newRight = message.permissions.firstObject;
                    __block PigramRoleRightBan *oldRoleRight = nil;
                   
                    [groupPerms enumerateObjectsUsingBlock:^(PigramRoleRightBan * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if (newRight.role == obj.role) {
                            oldRoleRight = obj;
                            oldRoleRight.groupRightBan = newRight.rightBan;
                            *stop = YES;
                        }
                    }];
                    if (oldRoleRight == nil) {
                        oldRoleRight = [[PigramRoleRightBan alloc] init];
                        oldRoleRight.role = newRight.role;
                        oldRoleRight.groupRightBan = newRight.rightBan;
                        groupPerms = @[oldRoleRight];
                    }
                    if (newRight.role == 2) {
                        //全体禁言
                        if (newRight.rightBan == 1) {
                            [updateInfo appendFormat:@" %@ 开启了全体禁言，只有群主和管理员才能发言。",envelope.sourceName];
                        } else {
                            [updateInfo appendFormat:@" %@ 关闭了全体禁言，全体可发言。",envelope.sourceName];
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:OWSMessageBlockConversationUpdateNotification object:nil];
                        });
                    } else {
                        [updateInfo appendFormat:@" 未知的群权限变更操作！"];
                    }
                }
                    break;
                //这个操作只有自己能收到  更新自己的权限 对应 message.rightBan
                case SSKProtoGroupContextTargetPermPersonal:
                {
                    [message.members enumerateObjectsUsingBlock:^(SSKProtoGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        PigramGroupMember *member = [groupModel memberWithUserId:obj.id];
                        member.memberRightBan = obj.rightInGroup;
                    }];
                }
                    break;
                default:
                    break;

            }
          
            groupModel.avatar = newAvatar;
            groupModel.groupName = newGroupName;
            groupModel.allMembers = [newMembers copy];
            groupModel.groupOwner = newOwner;
            groupModel.permRightBans = groupPerms;
            groupModel.linkString =  link;
            [oldGroupThread anyUpdateGroupThreadWithTransaction:transaction
                                                          block:^(TSGroupThread *thread) {
                thread.groupModel = groupModel;
                thread.shouldThreadBeVisible = YES;
            }];
            [[OWSDisappearingMessagesJob sharedJob] becomeConsistentWithDisappearingDuration:0
                                                                                      thread:oldGroupThread
                                                                    createdByRemoteRecipient:nil
                                                                      createdInExistingGroup:YES
                                                                                 transaction:transaction];
            // MJK TODO - should be safe to remove senderTimestamp
            if (updateInfo.length > 0) {
                TSInfoMessage *infoMessage = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                                                                        inThread:oldGroupThread
                                                                                     messageType:TSInfoMessageTypeGroupUpdate
                                                                                   customMessage:updateInfo];
                [infoMessage setServerTimestamp:@(envelope.serverTimestamp)];
                           [infoMessage anyInsertWithTransaction:transaction];
            }
           

        }
            break;
        case SSKProtoGroupContextTypeDismiss://解散通知
        {
            if (!oldGroupThread) {
                return;

            }
            [oldGroupThread anyUpdateGroupThreadWithTransaction:transaction block:^(TSGroupThread * thread) {
                thread.groupModel.txGroupType = TXGroupTypeExit;
            }];
            [oldGroupThread leaveGroupWithTransaction:transaction];
            
            NSString *updateGroupInfo = NSLocalizedString(@"群组被解散了", @"群主解散了群组");
            // MJK TODO - should be safe to remove senderTimestamp
            TSInfoMessage *infoMessage = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                             inThread:oldGroupThread
                                          messageType:TSInfoMessageTypeGroupUpdate
                                                                    customMessage:updateGroupInfo];
            [infoMessage setServerTimestamp:@(envelope.serverTimestamp)];
            [infoMessage anyInsertWithTransaction:transaction];
            return;
        }
        case SSKProtoGroupContextTypeQuit: {
            if (!oldGroupThread) {
                OWSLogWarn(@"ignoring quit group message from unknown group.");
                return;
            }
            
            if (message.members.count == 0) {
                return;
            }
            NSMutableSet *updateMembers = [NSMutableSet setWithArray:oldGroupThread.groupModel.allMembers];
            PigramGroupMember *member = [PigramGroupMember getGroupMemberWithProtoMember:message.members.firstObject];
            [updateMembers removeObject:member];
            [oldGroupThread anyUpdateGroupThreadWithTransaction:transaction
                                                          block:^(TSGroupThread *thread) {
                thread.groupModel.allMembers =
                [updateMembers.allObjects copy];
                thread.groupModel.membersCount = message.memberCount;
                
            }];
            NSString *updateGroupInfo =
            [NSString stringWithFormat:NSLocalizedString(@"GROUP_MEMBER_LEFT", @""), updateInfo];
            // MJK TODO - should be safe to remove senderTimestamp
            TSInfoMessage *info = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                             inThread:oldGroupThread
                                          messageType:TSInfoMessageTypeGroupUpdate
                                                             customMessage:updateGroupInfo];
            [info setServerTimestamp:@(envelope.serverTimestamp)];
            [info anyInsertWithTransaction:transaction];
        }
            break;
        case SSKProtoGroupContextTypeApply: {
            //收到申请入群申请
            //群主和管理员会在验证消息列表中显示这个申请
            if (oldGroupThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_Pigram_Group_Apply" object:@[message.members.firstObject.id, message.id]];
                });
            }

        }
            break;
        case SSKProtoGroupContextTypeApplyDecline:
        case SSKProtoGroupContextTypeApplyAccept: {
            //某某人 处理了加群申请 收到这个消息就代表 同意了申请
            // 删除本地对应的群验证消息 更新其他管理员或者群主对应的本地消息
            if (message.members.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_Pigram_Group_Apply_handled" object:@[message.members.firstObject.id,groupId, transaction]];
                });
            }
        }
            break;

        default: {
            OWSLogWarn(@"Ignoring unknown group message type: %d", (int)message.unwrappedType);
        }
            break;
    }
      
    
}
#pragma mark 处理群头像更新
- (void)handleReceivedGroupAvatarUpdateWithEnvelope:(SSKProtoEnvelope *)envelope
                                        groupOperation:(SSKProtoGroupContext *)message
                                        transaction:(SDSAnyWriteTransaction *)transaction
{
//    if (!envelope) {
//        OWSFailDebug(@"Missing envelope.");
//        return;
//    }
//    if (!message) {
//        OWSFailDebug(@"Missing dataMessage.");
//        return;
//    }
//    if (!transaction) {
//        OWSFail(@"Missing transaction.");
//        return;
//    }
//
//    TSGroupThread *_Nullable groupThread =
//        [TSGroupThread threadWithGroupId:envelope.groupId transaction:transaction];
//    if (!groupThread) {
//        OWSFailDebug(@"Missing group for group avatar update");
//        return;
//    }
//
//    TSAttachmentPointer *_Nullable avatarPointer =
//        [TSAttachmentPointer attachmentPointerFromProto:message.avatar albumMessage:nil];
//
//    if (!avatarPointer) {
//        OWSLogWarn(@"received unsupported group avatar envelope");
//        return;
//    }
//
//    [avatarPointer anyInsertWithTransaction:transaction];
//
//    [self.attachmentDownloads downloadAttachmentPointer:avatarPointer
//        message:nil
//        success:^(NSArray<TSAttachmentStream *> *attachmentStreams) {
//            OWSAssertDebug(attachmentStreams.count == 1);
//            TSAttachmentStream *attachmentStream = attachmentStreams.firstObject;
//
//            [self.databaseStorage writeWithBlock:^(SDSAnyWriteTransaction *transaction) {
//                [groupThread updateAvatarWithAttachmentStream:attachmentStream transaction:transaction];
//
//                // Eagerly clean up the attachment.
//                [attachmentStream anyRemoveWithTransaction:transaction];
//            }];
//        }
//        failure:^(NSError *error) {
//            OWSLogError(@"failed to fetch attachments for group avatar sent at: %llu. with error: %@",
//                envelope.timestamp,
//                error);
//
//            [self.databaseStorage writeWithBlock:^(SDSAnyWriteTransaction *transaction) {
//                // Eagerly clean up the attachment.
//                TSAttachment *_Nullable attachment =
//                    [TSAttachment anyFetchWithUniqueId:avatarPointer.uniqueId transaction:transaction];
//                if (attachment == nil) {
//                    // In the test case, database storage may be reset by the
//                    // time the pointer download fails.
//                    OWSFailDebugUnlessRunningTests(@"Could not load attachment.");
//                    return;
//                }
//                [attachment anyRemoveWithTransaction:transaction];
//            }];
//        }];
}

- (void)handleReceivedMediaWithEnvelope:(SSKProtoEnvelope *)envelope
                            dataMessage:(SSKProtoDataMessage *)dataMessage
                        wasReceivedByUD:(BOOL)wasReceivedByUD
                            transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!dataMessage) {
        OWSFailDebug(@"Missing dataMessage.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }

    TSThread *_Nullable thread = [self threadForEnvelope:envelope dataMessage:dataMessage transaction:transaction];
    if (!thread) {
        OWSFailDebug(@"ignoring media message for unknown group.");
        return;
    }

    TSIncomingMessage *_Nullable message = [self handleReceivedEnvelope:envelope
                                                        withDataMessage:dataMessage
                                                        wasReceivedByUD:wasReceivedByUD
                                                            transaction:transaction];

    if (!message) {
        return;
    }

    OWSAssertDebug([TSMessage anyFetchWithUniqueId:message.uniqueId transaction:transaction] != nil);

    OWSLogDebug(@"incoming attachment message: %@", message.debugDescription);

    [self.attachmentDownloads downloadBodyAttachmentsForMessage:message
        transaction:transaction
        success:^(NSArray<TSAttachmentStream *> *attachmentStreams) {
            OWSLogDebug(@"successfully fetched attachments: %lu for message: %@",
                (unsigned long)attachmentStreams.count,
                message);
        }
        failure:^(NSError *error) {
            OWSLogError(@"failed to fetch attachments for message: %@ with error: %@", message, error);
        }];
}
#pragma mark 收到同步消息
- (void)throws_handleIncomingEnvelope:(SSKProtoEnvelope *)envelope
                      withSyncMessage:(SSKProtoSyncMessage *)syncMessage
                          transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!syncMessage) {
        OWSFailDebug(@"Missing syncMessage.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }

//    if (![envelope.sourceId isEqualToString:TSAccountManager.localUserId]) {
//        // Sync messages should only come from linked devices.
//        OWSProdErrorWEnvelope([OWSAnalyticsEvents messageManagerErrorSyncMessageFromUnknownSource], envelope);
//        return;
//    }

    if (syncMessage.sent) {
      
        
        if (syncMessage.sent.revokeMessage) {
            
            [self handleIncomingEnvelope:envelope withRevokeMessage:syncMessage.sent.revokeMessage wasReceivedByUD:false transaction:transaction];
            return;
        }
        
        if (syncMessage.sent.revokeUserMessage) {
            
            [self handleRevokeUserMessagesWithEnvelope:envelope message:syncMessage.sent.revokeUserMessage transaction:transaction];
            return;
        }
        if (syncMessage.configuration.stick) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_pigram_update_stick" object:nil];
            return;
        }
//        if (syncMessage.configuration.bunches) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_pigram_update_bunches" object:nil];
//            return;
//        }
        
        OWSIncomingSentMessageTranscript *transcript =
            [[OWSIncomingSentMessageTranscript alloc] initWithProto:syncMessage.sent transaction:transaction];

        SSKProtoDataMessage *_Nullable dataMessage = syncMessage.sent.message;
        if (!dataMessage) {
            OWSFailDebug(@"Missing dataMessage.");
            return;
        }
        SignalServiceAddress *destination = syncMessage.sent.destinationAddress;
        if (destination.type == SignalServiceAddressTypeGroup) {
            NSString *groupId = envelope.groupId;
            TSGroupThread *_Nullable oldGroupThread = [TSGroupThread threadWithGroupId:groupId transaction:transaction];
            if (dataMessage.hasRequiredProtocolVersion
                && dataMessage.requiredProtocolVersion > SSKProtos.currentProtocolVersion) {
                [self insertUnknownProtocolVersionErrorInThread:oldGroupThread
                                                protocolVersion:dataMessage.requiredProtocolVersion
                                                         sender:envelope.sourceAddress
                                                    transaction:transaction];
                return;
            }

            if (!oldGroupThread) {
                PigramGroupMember *member = [[PigramGroupMember alloc] initWithUserId:TSAccountManager.localUserId];
                TSGroupModel *model = [[TSGroupModel alloc] initWithTitle: envelope.groupName members:@[member] groupId:groupId owner:envelope.sourceId];
                oldGroupThread = [[TSGroupThread alloc] initWithGroupModel:model];
                model.txGroupType = TXGroupTypeJoined;
                oldGroupThread.shouldThreadBeVisible = YES;
                [oldGroupThread anyInsertWithTransaction:transaction];
            }
        }
//        if (dataMessage && destination.isValid && dataMessage.hasProfileKey) {
//            // If we observe a linked device sending our profile key to another
//            // user, we can infer that that user belongs in our profile whitelist.
//            if (envelope.isGroup) {
//                [self.profileManager addGroupIdToProfileWhitelist:envelope.groupId];
//            } else {
//                [self.profileManager addUserToProfileWhitelist:destination];
//            }
//        }

        if ([self isDataMessageGroupAvatarUpdate:syncMessage.sent.message] && !syncMessage.sent.isRecipientUpdate) {
            [OWSRecordTranscriptJob
                processIncomingSentMessageTranscript:transcript
                                   attachmentHandler:^(NSArray<TSAttachmentStream *> *attachmentStreams) {
                                       OWSAssertDebug(attachmentStreams.count == 1);
                                       TSAttachmentStream *attachmentStream = attachmentStreams.firstObject;
                                       [self.databaseStorage writeWithBlock:^(SDSAnyWriteTransaction *transaction) {
                                           TSGroupThread *_Nullable groupThread =
                                               [TSGroupThread threadWithGroupId:envelope.groupId
                                                                    transaction:transaction];
                                           if (!groupThread) {
                                               OWSFailDebug(@"ignoring sync group avatar update for unknown group.");
                                               return;
                                           }

                                           [groupThread updateAvatarWithAttachmentStream:attachmentStream
                                                                             transaction:transaction];
                                       }];
                                   }
                                         transaction:transaction];
        } else {
            [OWSRecordTranscriptJob
                processIncomingSentMessageTranscript:transcript
                                   attachmentHandler:^(NSArray<TSAttachmentStream *> *attachmentStreams) {
                                       OWSLogDebug(@"successfully fetched transcript attachments: %lu",
                                           (unsigned long)attachmentStreams.count);
                                   }
                                         transaction:transaction];
        }
    } else if (syncMessage.request) {
        if (!syncMessage.request.hasType) {
            OWSFailDebug(@"Ignoring sync request without type.");
            return;
        }
        if (syncMessage.request.unwrappedType == SSKProtoSyncMessageRequestTypeContacts) {
            // We respond asynchronously because populating the sync message will
            // create transactions and it's not practical (due to locking in the OWSIdentityManager)
            // to plumb our transaction through.
            //
            // In rare cases this means we won't respond to the sync request, but that's
            // acceptable.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[self.syncManager syncAllContacts] retainUntilComplete];
            });
        } else if (syncMessage.request.unwrappedType == SSKProtoSyncMessageRequestTypeGroups) {
            [self.syncManager syncGroupsWithTransaction:transaction];
        } else if (syncMessage.request.unwrappedType == SSKProtoSyncMessageRequestTypeBlocked) {
            OWSLogInfo(@"Received request for block list");
            [self.blockingManager syncBlockList];
        } else if (syncMessage.request.unwrappedType == SSKProtoSyncMessageRequestTypeConfiguration) {
            [SSKEnvironment.shared.syncManager sendConfigurationSyncMessage];

            // We send _two_ responses to the "configuration request".
            [StickerManager syncAllInstalledPacksWithTransaction:transaction];
        } else {
            OWSLogWarn(@"ignoring unsupported sync request message");
        }
    } else if (syncMessage.blocked) {
        NSArray<NSString *> *blockedPhoneNumbers = [syncMessage.blocked.numbers copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.blockingManager setBlockedPhoneNumbers:blockedPhoneNumbers sendSyncMessage:NO];
        });
    } else if (syncMessage.read.count > 0) {
        OWSLogInfo(@"Received %lu read receipt(s)", (unsigned long)syncMessage.read.count);
        [OWSReadReceiptManager.sharedManager processReadReceiptsFromLinkedDevice:syncMessage.read
                                                                   readTimestamp:envelope.timestamp
                                                                     transaction:transaction];
    } else if (syncMessage.stickerPackOperation.count > 0) {
        OWSLogInfo(@"Received sticker pack operation(s): %d", (int)syncMessage.stickerPackOperation.count);
        for (SSKProtoSyncMessageStickerPackOperation *packOperationProto in syncMessage.stickerPackOperation) {
            [StickerManager processIncomingStickerPackOperation:packOperationProto transaction:transaction];
        }
    } else if (syncMessage.viewOnceOpen != nil) {
        OWSLogInfo(@"Received view-once read receipt sync message");
        [ViewOnceMessages processIncomingSyncMessage:syncMessage.viewOnceOpen
                                            envelope:envelope
                                         transaction:transaction];
    } else {
        OWSLogWarn(@"Ignoring unsupported sync message.");
    }
}

- (void)handleEndSessionMessageWithEnvelope:(SSKProtoEnvelope *)envelope
                                dataMessage:(SSKProtoDataMessage *)dataMessage
                                transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!dataMessage) {
        OWSFailDebug(@"Missing dataMessage.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }

    TSContactThread *thread = [TSContactThread getOrCreateThreadWithContactAddress:envelope.sourceAddress
                                                                       transaction:transaction];

    // MJK TODO - safe to remove senderTimestamp
    TSInfoMessage *info = [[TSInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
inThread:thread
messageType:TSInfoMessageTypeSessionDidEnd];
    [info setServerTimestamp:@(envelope.serverTimestamp)];

    [info anyInsertWithTransaction:transaction];

    [self.sessionStore deleteAllSessionsForAddress:envelope.sourceAddress transaction:transaction];
}

- (void)handleExpirationTimerUpdateMessageWithEnvelope:(SSKProtoEnvelope *)envelope
                                           dataMessage:(SSKProtoDataMessage *)dataMessage
                                           transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!dataMessage) {
        OWSFailDebug(@"Missing dataMessage.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }

    TSThread *_Nullable thread = [self threadForEnvelope:envelope dataMessage:dataMessage transaction:transaction];
    if (!thread) {
        OWSFailDebug(@"ignoring expiring messages update for unknown group.");
        return;
    }

    OWSDisappearingMessagesConfiguration *disappearingMessagesConfiguration =
        [OWSDisappearingMessagesConfiguration fetchOrBuildDefaultWithThread:thread transaction:transaction];
    if (dataMessage.hasExpireTimer && dataMessage.expireTimer > 0) {
        OWSLogInfo(
            @"Expiring messages duration turned to %u for thread %@", (unsigned int)dataMessage.expireTimer, thread);
        disappearingMessagesConfiguration =
            [disappearingMessagesConfiguration copyAsEnabledWithDurationSeconds:dataMessage.expireTimer];
    } else {
        OWSLogInfo(@"Expiring messages have been turned off for thread %@", thread);
        disappearingMessagesConfiguration = [disappearingMessagesConfiguration copyWithIsEnabled:NO];
    }
    OWSAssertDebug(disappearingMessagesConfiguration);

    // NOTE: We always update the configuration here, even if it hasn't changed
    //       to leave an audit trail.

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [disappearingMessagesConfiguration anyUpsertWithTransaction:transaction];
#pragma clang diagnostic pop

    NSString *name = [self.contactsManager displayNameForAddress:envelope.sourceAddress transaction:transaction];

    // MJK TODO - safe to remove senderTimestamp
    OWSDisappearingConfigurationUpdateInfoMessage *message =
        [[OWSDisappearingConfigurationUpdateInfoMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                                                          thread:thread
                                                                   configuration:disappearingMessagesConfiguration
                                                             createdByRemoteName:name
                                                          createdInExistingGroup:NO];
    [message setServerTimestamp:@(envelope.serverTimestamp)];

    [message anyInsertWithTransaction:transaction];
}

- (void)handleProfileKeyMessageWithEnvelope:(SSKProtoEnvelope *)envelope
                                dataMessage:(SSKProtoDataMessage *)dataMessage
                                transaction:(SDSAnyWriteTransaction *)transaction
{
//    if (!envelope) {
//        OWSFailDebug(@"Missing envelope.");
//        return;
//    }
//    if (!dataMessage) {
//        OWSFailDebug(@"Missing dataMessage.");
//        return;
//    }
//
//    SignalServiceAddress *address = envelope.sourceAddress;
//    if (!dataMessage.hasProfileKey) {
//        OWSFailDebug(@"received profile key message without profile key from: %@", envelopeAddress(envelope));
//        return;
//    }
//    NSData *profileKey = dataMessage.profileKey;
//    if (profileKey.length != kAES256_KeyByteLength) {
//        OWSFailDebug(@"received profile key of unexpected length: %lu, from: %@",
//            (unsigned long)profileKey.length,
//            envelopeAddress(envelope));
//        return;
//    }
//
//    id<ProfileManagerProtocol> profileManager = SSKEnvironment.shared.profileManager;
//    [profileManager setProfileKeyData:profileKey forAddress:address transaction:transaction];
}

- (void)handleReceivedTextMessageWithEnvelope:(SSKProtoEnvelope *)envelope
                                  dataMessage:(SSKProtoDataMessage *)dataMessage
                              wasReceivedByUD:(BOOL)wasReceivedByUD
                                  transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return;
    }
    if (!dataMessage) {
        OWSFailDebug(@"Missing dataMessage.");
        return;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return;
    }

    [self handleReceivedEnvelope:envelope
                 withDataMessage:dataMessage
                 wasReceivedByUD:wasReceivedByUD
                     transaction:transaction];
    
    
}
#pragma mark 处理群信息请求的消息
- (void)handleGroupInfoRequest:(SSKProtoEnvelope *)envelope
                   dataMessage:(SSKProtoDataMessage *)dataMessage
                   transaction:(SDSAnyWriteTransaction *)transaction
{
//    if (!envelope) {
//        OWSFailDebug(@"Missing envelope.");
//        return;
//    }
//    if (!dataMessage) {
//        OWSFailDebug(@"Missing dataMessage.");
//        return;
//    }
//    if (!transaction) {
//        OWSFail(@"Missing transaction.");
//        return;
//    }
//    if (!dataMessage.group.hasType) {
//        OWSFailDebug(@"Missing group message type.");
//        return;
//    }
//    if (dataMessage.group.unwrappedType != SSKProtoGroupContextTypeRequestInfo) {
//        OWSFailDebug(@"Unexpected group message type.");
//        return;
//    }
//
//    NSString *groupId = dataMessage.group ? dataMessage.group.id : nil;
//    if (!groupId) {
//        OWSFailDebug(@"Group info request is missing group id.");
//        return;
//    }
//
//    OWSLogInfo(@"Received 'Request Group Info' message for group: %@ from: %@", groupId, envelope.sourceAddress);
//
//    TSGroupThread *_Nullable gThread = [TSGroupThread threadWithGroupId:dataMessage.group.id transaction:transaction];
//    if (!gThread) {
//        OWSLogWarn(@"Unknown group: %@", groupId);
//        return;
//    }
//
//    // Ensure sender is in the group.
//    if (![gThread.groupModel.groupMembers containsObject:envelope.sourceAddress]) {
//        OWSLogWarn(@"Ignoring 'Request Group Info' message for non-member of group. %@ not in %@",
//            envelope.sourceAddress,
//            gThread.groupModel.groupMembers);
//        return;
//    }
//
//    // Ensure we are in the group.
//    if (!gThread.isLocalUserInGroup) {
//        OWSLogWarn(@"Ignoring 'Request Group Info' message for group we no longer belong to.");
//        return;
//    }
//
//    NSString *updateGroupInfo =
//        [gThread.groupModel getInfoStringAboutUpdateTo:gThread.groupModel contactsManager:self.contactsManager];
//
//    uint32_t expiresInSeconds = [gThread disappearingMessagesDurationWithTransaction:transaction];
//    TSOutgoingMessage *message = [TSOutgoingMessage outgoingMessageInThread:gThread
//                                                           groupMetaMessage:TSGroupMetaMessageUpdate
//                                                           expiresInSeconds:expiresInSeconds];
//
//    [message updateWithCustomMessage:updateGroupInfo transaction:transaction];
//    // Only send this group update to the requester.
//    [message updateWithSendingToSingleGroupRecipient:envelope.sourceAddress transaction:transaction];
//
//    if (gThread.groupModel.groupImage) {
//        NSData *_Nullable data = UIImagePNGRepresentation(gThread.groupModel.groupImage);
//        OWSAssertDebug(data);
//        if (data) {
//            _Nullable id<DataSource> dataSource = [DataSourceValue dataSourceWithData:data fileExtension:@"png"];
//            [self.messageSenderJobQueue addMediaMessage:message
//                                             dataSource:dataSource
//                                            contentType:OWSMimeTypeImagePng
//                                         sourceFilename:nil
//                                                caption:nil
//                                         albumMessageId:nil
//                                  isTemporaryAttachment:YES];
//        }
//    } else {
//        [self.messageSenderJobQueue addMessage:message.asPreparer transaction:transaction];
//    }
}

#pragma mark 处理收到的datamessage
- (TSIncomingMessage *_Nullable)handleReceivedEnvelope:(SSKProtoEnvelope *)envelope
                                       withDataMessage:(SSKProtoDataMessage *)dataMessage
                                       wasReceivedByUD:(BOOL)wasReceivedByUD
                                           transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return nil;
    }
    if (!dataMessage) {
        OWSFailDebug(@"Missing dataMessage.");
        return nil;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return nil;
    }

    uint64_t timestamp = envelope.timestamp;

    if (envelope.isGroup) {

        // Group messages create the group if it doesn't already exist.
        //
        // We distinguish between the old group state (if any) and the new group state.
        NSString *groupId = envelope.groupId;
        TSGroupThread *_Nullable oldGroupThread = [TSGroupThread threadWithGroupId:groupId transaction:transaction];

        if (dataMessage.hasRequiredProtocolVersion
            && dataMessage.requiredProtocolVersion > SSKProtos.currentProtocolVersion) {
            [self insertUnknownProtocolVersionErrorInThread:oldGroupThread
                                            protocolVersion:dataMessage.requiredProtocolVersion
                                                     sender:envelope.sourceAddress
                                                transaction:transaction];
            return nil;
        }
        if (!oldGroupThread) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_Pigram_Get_GroupInfo_Sync" object:@[groupId, transaction]];
//            oldGroupThread = [TSGroupThread threadWithGroupId:groupId transaction:transaction];
        }
        if (!oldGroupThread) {
            PigramGroupMember *member = [[PigramGroupMember alloc] initWithUserId:TSAccountManager.localUserId];
            TSGroupModel *model = [[TSGroupModel alloc] initWithTitle: envelope.groupName members:@[member] groupId:groupId owner:envelope.sourceId];
            oldGroupThread = [[TSGroupThread alloc] initWithGroupModel:model];
//            model.membersCount = message.memberCount;
            model.txGroupType = TXGroupTypeJoined;
            oldGroupThread.shouldThreadBeVisible = YES;
            [oldGroupThread anyInsertWithTransaction:transaction];
        }

        NSString *messageDescription =
            [NSString stringWithFormat:@"Incoming message from: %@ for group: %@ with timestamp: %llu",
                      envelopeAddress(envelope),
                      groupId,
                      timestamp];
        return [self createIncomingMessageInThread:oldGroupThread
                                messageDescription:messageDescription
                                          envelope:envelope
                                       dataMessage:dataMessage
                                   wasReceivedByUD:wasReceivedByUD
                                       transaction:transaction];
    } else {
        TSContactThread *thread = [TSContactThread getOrCreateThreadWithContactAddress:envelope.sourceAddress
                                                                           transaction:transaction];

        if (dataMessage.hasRequiredProtocolVersion
            && dataMessage.requiredProtocolVersion > SSKProtos.currentProtocolVersion) {
            [self insertUnknownProtocolVersionErrorInThread:thread
                                            protocolVersion:dataMessage.requiredProtocolVersion
                                                     sender:envelope.sourceAddress
                                                transaction:transaction];
            return nil;
        }

        NSString *messageDescription = [NSString stringWithFormat:@"Incoming 1:1 message from: %@ with timestamp: %llu",
                                                 envelopeAddress(envelope),
                                                 timestamp];
        return [self createIncomingMessageInThread:thread
                                messageDescription:messageDescription
                                          envelope:envelope
                                       dataMessage:dataMessage
                                   wasReceivedByUD:wasReceivedByUD
                                       transaction:transaction];
    }
}

- (void)insertUnknownProtocolVersionErrorInThread:(TSThread *)thread
                                  protocolVersion:(NSUInteger)protocolVersion
                                           sender:(SignalServiceAddress *)sender
                                      transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(thread);
    OWSAssertDebug(transaction);

    OWSFailDebug(@"Unknown protocol version: %lu", (unsigned long)protocolVersion);

    if (!sender.isValid) {
        OWSFailDebug(@"Missing sender.");
        return;
    }

    // We convert protocolVersion to a numeric value here.
    TSInteraction *message =
        [[OWSUnknownProtocolVersionMessage alloc] initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                                                             thread:thread
                                                             sender:sender
                                                    protocolVersion:protocolVersion];
    [message anyInsertWithTransaction:transaction];
}

#pragma mark 创建一个incomming message
    - (nullable TSIncomingMessage *)createIncomingMessageInThread:(TSThread *)thread
                                               messageDescription:(NSString *)messageDescription
                                                         envelope:(SSKProtoEnvelope *)envelope
                                                      dataMessage:(SSKProtoDataMessage *)dataMessage
                                                  wasReceivedByUD:(BOOL)wasReceivedByUD
                                                      transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return nil;
    }
    if (!thread) {
//        OWSFailDebug(@"Missing thread.");
        return nil;
    }

    SignalServiceAddress *authorAddress = [[SignalServiceAddress alloc] initWithPhoneNumber:envelope.sourceId];
    if (!authorAddress.isValid) {
        OWSFailDebug(@"invalid authorAddress");
        return nil;
    }

    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return nil;
    }

    OWSLogDebug(@"%@", messageDescription);

    uint64_t timestamp = envelope.timestamp;
    NSString *body = dataMessage.body;
    NSNumber *_Nullable serverTimestamp = (envelope.hasServerTimestamp ? @(envelope.serverTimestamp) : nil);

    TSQuotedMessage *_Nullable quotedMessage =
        [TSQuotedMessage quotedMessageForDataMessage:dataMessage thread:thread transaction:transaction];

    OWSContact *_Nullable contact;
    OWSLinkPreview *_Nullable linkPreview;
    [[OWSDisappearingMessagesJob sharedJob] becomeConsistentWithDisappearingDuration:dataMessage.expireTimer
                                                                              thread:thread
                                                            createdByRemoteRecipient:authorAddress
                                                              createdInExistingGroup:NO
                                                                         transaction:transaction];

    contact = [OWSContacts contactForDataMessage:dataMessage transaction:transaction];

    NSError *linkPreviewError;
    linkPreview = [OWSLinkPreview buildValidatedLinkPreviewWithDataMessage:dataMessage
                                                                      body:body
                                                               transaction:transaction
                                                                     error:&linkPreviewError];
    if (linkPreviewError && ![OWSLinkPreview isNoPreviewError:linkPreviewError]) {
        OWSLogError(@"linkPreviewError: %@", linkPreviewError);
    }

    NSError *stickerError;
    MessageSticker *_Nullable messageSticker =
        [MessageSticker buildValidatedMessageStickerWithDataMessage:dataMessage
                                                        transaction:transaction
                                                              error:&stickerError];
    if (stickerError && ![MessageSticker isNoStickerError:stickerError]) {
        OWSFailDebug(@"stickerError: %@", stickerError);
    }

    BOOL isViewOnceMessage = dataMessage.hasIsViewOnce && dataMessage.isViewOnce;

    // Legit usage of senderTimestamp when creating an incoming group message record
    //生成收到的消息  hansen
    TSIncomingMessage *incomingMessage =
        [[TSIncomingMessage alloc] initIncomingMessageWithTimestamp:timestamp
                                                           inThread:thread
                                                      authorAddress:authorAddress
                                                     sourceDeviceId:envelope.sourceDevice
                                                        messageBody:body
                                                      attachmentIds:@[]
                                                   expiresInSeconds:dataMessage.expireTimer
                                                      quotedMessage:quotedMessage
                                                       contactShare:contact
                                                        linkPreview:linkPreview
                                                     messageSticker:messageSticker
                                                    serverTimestamp:serverTimestamp
                                                    wasReceivedByUD:wasReceivedByUD
                                                  isViewOnceMessage:isViewOnceMessage];
    incomingMessage.isOffline = envelope.isOffline;
    NSMutableArray *mentions = [[NSMutableArray alloc] initWithCapacity:dataMessage.mentions.count];
    [dataMessage.mentions enumerateObjectsUsingBlock:^(SSKProtoUserEntiy * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PigramGroupMember *member = [[PigramGroupMember alloc] initWithUserId:obj.id];
        member.nickname = obj.name;
        member.userAvatar = obj.avatar;
        [mentions addObject:member];
        if ([obj.id isEqualToString:TSAccountManager.localUserId]) {
            incomingMessage.isMentionedMe = true;
        } else if ([obj.id isEqualToString:@"___user____!manager"]) {
            incomingMessage.isMentionedAll = true;
        }
    }];
    incomingMessage.mentions = mentions;
    if (!incomingMessage) {
        OWSFailDebug(@"Missing incomingMessage.");
        return nil;
    }
    incomingMessage.groupId = envelope.groupId;
    NSArray<TSAttachmentPointer *> *attachmentPointers =
        [TSAttachmentPointer attachmentPointersFromProtos:dataMessage.attachments albumMessage:incomingMessage];

    NSMutableArray<NSString *> *attachmentIds = [incomingMessage.attachmentIds mutableCopy];
    for (TSAttachmentPointer *pointer in attachmentPointers) {
        [pointer anyInsertWithTransaction:transaction];
        [attachmentIds addObject:pointer.uniqueId];
    }
    incomingMessage.attachmentIds = [attachmentIds copy];

    if (!incomingMessage.hasRenderableContent) {
        OWSLogWarn(@"Ignoring empty: %@", messageDescription);
        return nil;
    }
//    NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
    [incomingMessage anyInsertWithTransaction:transaction];
//    NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
//    OWSLogInfo(@"用时 -- %lf",end - start);
    // Any messages sent from the current user - from this device or another - should be automatically marked as read.
    if (envelope.sourceAddress.isLocalAddress) {
        // Don't send a read receipt for messages sent by ourselves.
        [incomingMessage markAsReadAtTimestamp:envelope.timestamp sendReadReceipt:NO transaction:transaction];
    }

    // Download the "non-message body" attachments.
    NSMutableArray<NSString *> *otherAttachmentIds = [incomingMessage.allAttachmentIds mutableCopy];
    if (incomingMessage.attachmentIds) {
        [otherAttachmentIds removeObjectsInArray:incomingMessage.attachmentIds];
    }
    for (NSString *attachmentId in otherAttachmentIds) {
        TSAttachment *_Nullable attachment = [TSAttachment anyFetchWithUniqueId:attachmentId transaction:transaction];
        if (![attachment isKindOfClass:[TSAttachmentPointer class]]) {
            OWSLogInfo(@"Skipping attachment stream.");
            continue;
        }
        TSAttachmentPointer *_Nullable attachmentPointer = (TSAttachmentPointer *)attachment;

        OWSLogDebug(@"Downloading attachment for message: %lu", (unsigned long)incomingMessage.timestamp);

        // Use a separate download for each attachment so that:
        //
        // * We update the message as each comes in.
        // * Failures don't interfere with successes.
        [self.attachmentDownloads downloadAttachmentPointer:attachmentPointer
            message:incomingMessage
            success:^(NSArray<TSAttachmentStream *> *attachmentStreams) {
                [self.databaseStorage writeWithBlock:^(SDSAnyWriteTransaction *transaction) {
                    TSAttachmentStream *_Nullable attachmentStream = attachmentStreams.firstObject;
                    OWSAssertDebug(attachmentStream);
                    if (attachmentStream && incomingMessage.quotedMessage.thumbnailAttachmentPointerId.length > 0 &&
                        [attachmentStream.uniqueId
                            isEqualToString:incomingMessage.quotedMessage.thumbnailAttachmentPointerId]) {
                        [incomingMessage
                            anyUpdateMessageWithTransaction:transaction
                                                      block:^(TSMessage *message) {
                                                          [message setQuotedMessageThumbnailAttachmentStream:
                                                                       attachmentStream];
                                                      }];
                    } else {
                        // We touch the message to trigger redraw of any views displaying it,
                        // since the attachment might be a contact avatar, etc.
                        [self.databaseStorage touchInteraction:incomingMessage transaction:transaction];
                    }
                }];
            }
            failure:^(NSError *error) {
                OWSLogWarn(@"failed to download attachment for message: %lu with error: %@",
                    (unsigned long)incomingMessage.timestamp,
                    error);
            }];
    }

    // In case we already have a read receipt for this new message (this happens sometimes).
    [OWSReadReceiptManager.sharedManager applyEarlyReadReceiptsForIncomingMessage:incomingMessage
                                                                      transaction:transaction];

    [self.databaseStorage touchThread:thread transaction:transaction];

    [ViewOnceMessages applyEarlyReadReceiptsForIncomingMessage:incomingMessage transaction:transaction];
    if (!envelope.isOffline) {
        [SSKEnvironment.shared.notificationsManager notifyUserForIncomingMessage:incomingMessage
                                                                        inThread:thread
                                                                     transaction:transaction];
    }

    if (incomingMessage.messageSticker != nil) {
        [StickerManager.shared setHasUsedStickersWithTransaction:transaction];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.typingIndicators didReceiveIncomingMessageInThread:thread
                                                         address:envelope.sourceAddress
                                                        deviceId:envelope.sourceDevice];
    });

    return incomingMessage;
}

#pragma mark - helpers

- (BOOL)isDataMessageGroupAvatarUpdate:(SSKProtoDataMessage *)dataMessage
{
    if (!dataMessage) {
        OWSFailDebug(@"Missing dataMessage.");
        return NO;
    }
    return false;

//    return (dataMessage.group != nil && dataMessage.group.hasType
//        && dataMessage.group.unwrappedType == SSKProtoGroupContextTypeUpdate && dataMessage.group.avatar != nil);
}

/**
 * @returns
 *   Group or Contact thread for message, creating a new contact thread if necessary,
 *   but never creating a new group thread.
 */
- (nullable TSThread *)threadForEnvelope:(SSKProtoEnvelope *)envelope
                             dataMessage:(SSKProtoDataMessage *)dataMessage
                             transaction:(SDSAnyWriteTransaction *)transaction
{
    if (!envelope) {
        OWSFailDebug(@"Missing envelope.");
        return nil;
    }
    if (!dataMessage) {
        OWSFailDebug(@"Missing dataMessage.");
        return nil;
    }
    if (!transaction) {
        OWSFail(@"Missing transaction.");
        return nil;
    }

    if (envelope.isGroup) {
        NSString *groupId = envelope.sourceAddress.groupid;
        OWSAssertDebug(groupId.length > 0);
        TSGroupThread *_Nullable groupThread = [TSGroupThread threadWithGroupId:groupId transaction:transaction];
        // This method should only be called from a code path that has already verified
        // that this is a "known" group.
         if (!groupThread) {
             TSGroupModel *model = [[TSGroupModel alloc] initWithTitle: envelope.groupName members:@[] groupId:groupId owner:envelope.sourceId];
             groupThread = [[TSGroupThread alloc] initWithGroupModel:model];
             //            model.membersCount = message.memberCount;
             model.txGroupType = TXGroupTypeJoined;
             groupThread.shouldThreadBeVisible = YES;
             [groupThread anyInsertWithTransaction:transaction];
         }
        OWSAssertDebug(groupThread);
        return groupThread;
    } else {
        return [TSContactThread getOrCreateThreadWithContactAddress:envelope.sourceAddress transaction:transaction];
    }
}

#pragma mark -

- (void)checkForUnknownLinkedDevice:(SSKProtoEnvelope *)envelope transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(envelope);
    OWSAssertDebug(transaction);

    if (!envelope.sourceAddress.isLocalAddress) {
        return;
    }

    // Consult the device list cache we use for message sending
    // whether or not we know about this linked device.
    SignalRecipient *_Nullable recipient = [SignalRecipient registeredRecipientForAddress:envelope.sourceAddress
                                                                          mustHaveDevices:NO
                                                                              transaction:transaction];
    if (!recipient) {
        OWSFailDebug(@"No local SignalRecipient.");
    } else {
        BOOL isRecipientDevice = [recipient.devices containsObject:@(envelope.sourceDevice)];
        if (!isRecipientDevice) {
            OWSLogInfo(@"Message received from unknown linked device; adding to local SignalRecipient: %lu.",
                       (unsigned long) envelope.sourceDevice);

            [recipient updateRegisteredRecipientWithDevicesToAdd:@[ @(envelope.sourceDevice) ]
                                                 devicesToRemove:nil
                                                     transaction:transaction];
        }
    }

    // Consult the device list cache we use for the "linked device" UI
    // whether or not we know about this linked device.
    NSMutableSet<NSNumber *> *deviceIdSet = [NSMutableSet new];
    for (OWSDevice *device in [OWSDevice anyFetchAllWithTransaction:transaction]) {
        [deviceIdSet addObject:@(device.deviceId)];
    }
    BOOL isInDeviceList = [deviceIdSet containsObject:@(envelope.sourceDevice)];
    if (!isInDeviceList) {
        OWSLogInfo(@"Message received from unknown linked device; refreshing device list: %lu.",
                   (unsigned long) envelope.sourceDevice);

        [OWSDevicesService refreshDevices];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.profileManager fetchLocalUsersProfile];
        });
    }
}

@end

NS_ASSUME_NONNULL_END
