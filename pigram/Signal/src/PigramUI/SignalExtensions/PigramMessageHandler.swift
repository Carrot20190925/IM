//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit


/**
 * 处理pigram 新定义的消息
 */
@objc(PGMessageHandler)
class PigramMessageHandler: NSObject {
    
    static let shared = PigramMessageHandler.init();
    
    private override init() {
        super.init();
        
    }
    static func pg_initialize() {
        NotificationCenter.default.addObserver(self.shared, selector: #selector(onNewMessageWithEnvelop(_ :)), name: NSNotification.Name.kNotification_Pigram_New_Message, object: nil);
        //申请者不会收到accept的消息
//        NotificationCenter.default.addObserver(self.shared, selector: #selector(onGroupApplyHandled(_:)), name: NSNotification.Name.kNotification_Pigram_Group_Apply_handled, object: nil);

    }
     
    
    @objc
    private func onNewMessageWithEnvelop(_ info: NSNotification) {
        
        let datas = info.object as? [Any];
        let envelop = datas?.first as? SSKProtoEnvelope;
        
        let content = datas?[1] as? SSKProtoContent;
        
        let anyWriteTransaction = datas?[2] as? SDSAnyWriteTransaction;
                
        if envelop == nil || content == nil || anyWriteTransaction == nil {
            return;
        }
        if let _value = content?.friendMessage {
            self.handleIncomingMessage(envelop!, message: _value, transaction: anyWriteTransaction!);
        }
        if let _value = content?.dataMessage?.shareMessage {
            self.handleShareMessage(envelop!, shareMessage: _value, transaction: anyWriteTransaction!);
        }
        
        
        
    }
    
    // MARK: 收到好友邀请消息
    private func handleIncomingMessage(_ envelop:SSKProtoEnvelope, message: SSKProtoFriendMessage, transaction: SDSAnyWriteTransaction) {
        
        if envelop.sourceAddress?.isLocalAddress == true {
            OWSLogger.verbose("Ignoring contact indicators from self or linked device.");
            return;
        }
        if SSKEnvironment.shared.blockingManager.isAddressBlocked(envelop.sourceAddress!) {
            OWSLogger.error("Ignoring blocked message from sender:\(envelop.sourceAddress)");
            return;
        }
        if message.hasAction == false {
            return;
        }
//        //对方是我好友就不处理
//        kSignalDB.read { (read) in
//            if let user = OWSUserProfile.getFor(envelop.sourceAddress!, transaction: read) {
//                if OWSUserProfile.existMyFriendList(user) {
//                    return;
//                }
//            }

//        }
        let thread = TSContactThread.init(contactAddress: envelop.sourceAddress!);
        thread.isFriendInviteThread = true;
        
        DispatchQueue.main.async {
            let model = PigramVerifyModel.init(applyid: envelop.sourceId!, destinationid: TSAccountManager.localUserId!);
            if message.unwrappedAction == .apply {

                ///获取好友头像和昵称
//                ProfileFetcherJob.init().getAndUpdateProfile(address: envelop.sourceAddress!);
                model.channelType = PigramFriendChannel.init(rawValue: Int(message.channel?.rawValue ?? 0));
                model.content = message.extraMessage;
                SSKEnvironment.shared.databaseStorage.write { (write) in
                    let user = OWSUserProfile.getOrBuild(for: envelop.sourceAddress!, transaction: write);
                    user.update(withProfileName: envelop.sourceName, avatarUrlPath: envelop.sourceAvatar, avatarFileName: user.avatarFileName, transaction: write, completion: nil)
                }
                PigramVerifyManager.shared.updateOrAddVerifycation(model);
                
                NotificationCenter.default.post(name: NSNotification.Name.kNotification_Friend_Invite_apply, object: nil);
            } else if (message.unwrappedAction == .accept) {
                ///如果同意 就生成一个profile存到本地 相当于存到了好友列表
                SSKEnvironment.shared.databaseStorage.write { (write) in
                    let user = OWSUserProfile.getOrBuild(for: envelop.sourceAddress!, transaction: write);
                    user.anyUpdate(transaction: write) { (_user) in
                        _user.relationType = .friend;
                        _user.isNeedVerify = false;
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name.kNotification_Friend_Invite_accept, object: envelop.sourceId);
                let thread = TSContactThread.getOrCreateThread(contactAddress: envelop.sourceAddress!);
                let infoMessage = TSInfoMessage.init(timestamp: NSDate.ows_millisecondTimeStamp(), in: thread, messageType: TSInfoMessageType.typeGroupUpdate, customMessage: "\(envelop.sourceName ?? "对方") 同意了您的好友验证，你们已经成为好友啦！");
                kSignalDB.asyncWrite { (write) in
                    infoMessage.anyInsert(transaction: write);
                }
                //如果本地存在这条验证就删掉
                PigramVerifyManager.shared.deleteVerifacation(model);

            }
        }
    }

    
    // MARK: 收到名片分享的消息
      private func handleShareMessage(_ envelop:SSKProtoEnvelope, shareMessage: SSKProtoShareMessage, transaction: SDSAnyWriteTransaction) {
          
          if envelop.sourceAddress?.isLocalAddress == true {
              OWSLogger.verbose("Ignoring contact indicators from self or linked device.");
              return;
          }
          if SSKEnvironment.shared.blockingManager.isAddressBlocked(envelop.sourceAddress!) {
              OWSLogger.error("Ignoring blocked message from sender:\(envelop.sourceAddress)");
              return;
          }
         
        var thread: TSThread?
        let message = PGMessageShare.init();
        message?.shareID = shareMessage.shareId;
        message?.shareName = shareMessage.shareName;
        message?.shareAvatar = shareMessage.shareAvatar;
        
        if envelop.sourceAddress!.type == .group {
            let groupThread = TSGroupThread.getOrCreateThread(withGroupId: envelop.sourceAddress!.phoneNumber!, transaction: transaction);
            ///加载名片包含的群信息
            thread = groupThread
        } else if envelop.sourceAddress!.type == .personal {
            thread = TSContactThread.getOrCreateThread(withContactAddress: envelop.sourceAddress!, transaction: transaction);

        } else {
            return;
        }
        if message?.shareType() == PGMessageShareType.group {
//            PigramNetwork.getGroupInfo((message?.shareID!)!) { (groupModel, error) in
            let address = SignalServiceAddress.init(phoneNumber: envelop.sourceId);
            let incomingMessage = TSIncomingMessage.init(incomingMessageWithTimestamp: envelop.timestamp, in: thread!, authorAddress: address, sourceDeviceId: envelop.sourceDevice, messageBody: nil, attachmentIds: [], expiresInSeconds: 0, quotedMessage: nil, contactShare: nil, linkPreview: nil, messageSticker: nil, serverTimestamp: NSNumber.init(value: envelop.serverTimestamp), wasReceivedByUD: false, isViewOnceMessage: false);
            
            incomingMessage.messageShare = message!;
            incomingMessage.anyInsert(transaction: transaction);
            kSignalDB.asyncRead { (read) in
                SSKEnvironment.shared.notificationsManager.notifyUser(for: incomingMessage, in: thread!, transaction: read);

            }

//            }

        } else if message?.shareType() == PGMessageShareType.personal {
            //加载名片包含的个人信息
            let address = SignalServiceAddress.init(phoneNumber: message?.shareID);
            let authorAddress = SignalServiceAddress.init(phoneNumber: envelop.sourceId);

            let profile = OWSUserProfile.getOrBuild(for: address, transaction: transaction);
            profile.update(withProfileName: message?.shareName, avatarUrlPath: message?.shareAvatar, avatarFileName: nil, transaction: transaction, completion: nil);
            transaction.addCompletion {
                
                let incomingMessage = TSIncomingMessage.init(incomingMessageWithTimestamp: envelop.timestamp, in: thread!, authorAddress: authorAddress, sourceDeviceId: envelop.sourceDevice, messageBody: nil, attachmentIds: [], expiresInSeconds: 0, quotedMessage: nil, contactShare: nil, linkPreview: nil, messageSticker: nil, serverTimestamp: NSNumber.init(value: envelop.serverTimestamp), wasReceivedByUD: false, isViewOnceMessage: false);
                let subMessage = PGMessageShare.init();
                subMessage?.shareID = shareMessage.shareId;
                subMessage?.shareName = shareMessage.shareName;
                subMessage?.shareAvatar = shareMessage.shareAvatar;
                incomingMessage.messageShare = subMessage!;
                kSignalDB.write { (write) in
                    incomingMessage.anyInsert(transaction: write);
                }
                kSignalDB.asyncRead { (read) in
                    SSKEnvironment.shared.notificationsManager.notifyUser(for: incomingMessage, in: thread!, transaction: read);

                }
                
            }
          

        }

       
        
      }
    
    /**
     * 有人处理了入群申请
     */
    @objc func onGroupApplyHandled(_ obj: NSNotification) {
    
        if let data = obj.object as? [Any] {
            let memberID = data.first as? String;
            let groupId = data[1] as? String;

            let address = SignalServiceAddress.init(phoneNumber: memberID);
            
            var thread: TSGroupThread?
            
            kSignalDB.write { (write) in
                thread = TSGroupThread.getOrCreateThread(withGroupId: groupId ?? "", transaction: write);
                if let model = thread?.groupModel {
                    self.onNewGroupSesseion(model, write, address: address);
                }
            }
            let model = PigramVerifyModel.init(applyid: memberID ?? "", destinationid: groupId!);
            PigramVerifyManager.shared.deleteVerifacation(model);
        }
        
    }
}



extension PigramMessageHandler{
    func inviteGroupId(data : Data) {//被邀请入群通知
        
    }
    
    
    private func onNewGroupSesseion(_ groupModel: TSGroupModel, _ transaction: SDSAnyWriteTransaction?, address: SignalServiceAddress) {
//        let thread = TSGroupThread.getOrCreateThread(with: groupModel, transaction: transaction!);
//        let newModel = groupModel;
//        thread.anyUpdateGroupThread(transaction: transaction!) { (thread) in
//            thread.groupModel = newModel;
//            thread.shouldThreadBeVisible = true;
//        }
//        OWSDisappearingMessagesJob.shared().becomeConsistent(withDisappearingDuration: 0, thread: thread, createdByRemoteRecipient: nil, createdInExistingGroup: true, transaction: transaction!);
//        if address.phoneNumber == TSAccountManager.localUserId {
//            NotificationCenter.default.post(name: NSNotification.Name.kNotification_Pigram_Group_Apply_handled_finished, object: nil);
//        }
        
    }
}
