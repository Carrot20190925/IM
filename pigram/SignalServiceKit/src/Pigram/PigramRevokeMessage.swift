//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

@objc public class PigramRevokeMessage: TSOutgoingMessage {

    @objc public let targetUserId: String;
    
    @objc public let targetTimeStamp: UInt64;
    
    private var groupId: String?
    @objc
    init(thread: TSThread, id: String, timestamp: UInt64) {
        if timestamp == 0 {
            owsFailDebug("单条消息时间戳必须有值");
        }
        self.targetUserId = id;
        self.targetTimeStamp = timestamp;
        super.init(outgoingMessageWithTimestamp: NSDate.ows_millisecondTimeStamp(),
        in: thread,
        messageBody: nil,
        attachmentIds: NSMutableArray(),
        expiresInSeconds: 0,
        expireStartedAt: 0,
        isVoiceMessage: false,
        groupMetaMessage: .unspecified,
        quotedMessage: nil,
        contactShare: nil,
        linkPreview: nil,
        messageSticker: nil,
        isViewOnceMessage: false);
    }
    
    /**
     * 撤回用户在群组的所有消息
     */
    @objc
    init(thread: TSGroupThread, targetUserId: String) {
        
        self.targetUserId = targetUserId;
        self.targetTimeStamp = 0;
        self.groupId = thread.groupModel.groupId;
        super.init(outgoingMessageWithTimestamp: NSDate.ows_millisecondTimeStamp(),
        in: thread,
        messageBody: nil,
        attachmentIds: NSMutableArray(),
        expiresInSeconds: 0,
        expireStartedAt: 0,
        isVoiceMessage: false,
        groupMetaMessage: .unspecified,
        quotedMessage: nil,
        contactShare: nil,
        linkPreview: nil,
        messageSticker: nil,
        isViewOnceMessage: false);
    }
    @objc
    public override func buildPlainTextData(_ recipient: SignalRecipient) -> Data? {
        
        
        let content = SSKProtoContent.builder();
        
        do {
            if self.targetTimeStamp == 0 {
                
                let message = SSKProtoRevokeUserMessage.builder();
                message.setTargetUserID(self.targetUserId);
                message.setTagrgetGroupId(self.groupId);
                content.setRevokeUserMessage(try message.build());
            } else {
                let message = SSKProtoRevokeMessage.builder();
                message.setTargetUserID(self.targetUserId);
                message.setTagrgetTimeStamp(self.targetTimeStamp);
                content.setRevokeMessage([try message.build()]);
            }
            let data = try content.buildSerializedData();

            return data;
        } catch let error {
            owsFailDebug("failed to build content: \(error)")
            return nil;
        }
        
    }
    
    public override var shouldBeSaved: Bool {
        
        return false;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(dictionary dictionaryValue: [String : Any]!) throws {
        fatalError("init(dictionary:) has not been implemented")
    }
    
    
    
}
