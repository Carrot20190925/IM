//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSMessageHandler.h"

NS_ASSUME_NONNULL_BEGIN

@class SDSAnyWriteTransaction;
@class SSKProtoEnvelope;

/**
 * 禁言权限发生变化
 */
extern NSString *const OWSMessageBlockConversationUpdateNotification;

@interface OWSMessageManager : OWSMessageHandler

// processEnvelope: can be called from any thread.
- (void)throws_processEnvelope:(SSKProtoEnvelope *)envelope
                 plaintextData:(NSData *_Nullable)plaintextData
               wasReceivedByUD:(BOOL)wasReceivedByUD
                   transaction:(SDSAnyWriteTransaction *)transaction;

// This should be invoked by the main app when the app is ready.
- (void)startObserving;


/**
 * 撤回个人在群组中的所有消息
 */
- (void)revokeUserMessagesInGroupThreadId:(NSString *)threadId targetUserId:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END
