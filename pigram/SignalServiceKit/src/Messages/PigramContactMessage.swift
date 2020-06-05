//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation

@objc(OWSPigramContactAction)
public enum PigramFriendAction: Int {
    case apply = 0
    case accept = 1
    case decline = 2
}
@objc(OWSPigramContactChannel)
public enum PigramFriendChannel: Int {

    case number = 0
    case scan = 1
    case group = 2
    case userID // = 3
    case card // = 4
    case link // = 5
}
/**
 * 好友邀请
 */
@objc(OWCPigramContactMessage)
public  class PigramContactMessage: TSOutgoingMessage {

//    @objc(OWCPigramContactAction)
    public let action: PigramFriendAction
    public let channel: PigramFriendChannel

    // MARK: Initializers
    ///是否为我发送的消息
    @objc
    public var isSentByMe = true;
    
    ///跟action一样 表示状态 重新加一个是为了能够存在数据库
    @objc
    public var status: Int;
    
    @objc
    public var channel_OC: Int;
    
    @objc /// 发送好友邀请时的验证消息
    public var content: String?
    
    @objc /// 对好友的备注
    public var note: String?
    
    
    @objc
    public init(thread: TSThread,
                action: PigramFriendAction, channel: PigramFriendChannel) {
        self.action = action
        self.status = action.rawValue;
        self.channel = channel;
        self.channel_OC = channel.rawValue;
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
                   isViewOnceMessage: false)
    }
    
    @objc
    public required init!(coder: NSCoder) {
        self.action = .apply
        self.status = 0;
        self.channel = .number;
        self.channel_OC = 0;
        super.init(coder: coder)
    }
    
    @objc
    public required init(dictionary dictionaryValue: [String: Any]!) throws {
        self.action = .apply
        self.status = 0;
        self.channel = .number;
        self.channel_OC = 0;
        try super.init(dictionary: dictionaryValue)
    }
        
    private func protoAction(forAction action: PigramFriendAction) -> SSKProtoFriendMessage.SSKProtoFriendMessageAction {
        switch action {
        case .apply:
            return .apply
        case .accept:
            return .accept
        case .decline:
            return .decline
        }
    }
    private func protoChannel(forChannel channel: PigramFriendChannel) -> SSKProtoFriendMessage.SSKProtoFriendMessageChannel {
           switch channel {
           case .number: return .number
           case .scan: return .scan
           case .group: return .group
           case .card: return .card
           case .userID: return .userID
           case .link: return .link

           }
       }
    
    @objc
    public override func buildPlainTextData(_ recipient: SignalRecipient) -> Data? {
        
        let friendBuilder = SSKProtoFriendMessage.builder(timestamp: self.timestamp)
        friendBuilder.setAction(protoAction(forAction: action))
        friendBuilder.setChannel(protoChannel(forChannel: channel));
        let contentBuilder = SSKProtoContent.builder()
        
        do {
            contentBuilder.setFriendMessage(try friendBuilder.build())
            
            let data = try contentBuilder.buildSerializedData()
            return data
        } catch let error {
            owsFailDebug("failed to build content: \(error)")
            return nil
        }
    }
    
    // MARK: TSYapDatabaseObject overrides
    
    @objc
    public override var shouldBeSaved: Bool {
        if self.isSentByMe == false {
            return true;
        }
        return false;
    }
    
    @objc
    public override var debugDescription: String {
        return "contactMessage"
    }
    @objc
    public override func interactionType() -> OWSInteractionType {

        return OWSInteractionType.pigramContact;
    }
    
    // MARK:
    
    @objc(stringForPigramContactAction:)
    public class func string(forContactAction action: PigramFriendAction) -> String {
        switch action {
        case .apply:
            return "apply"
        case .accept:
            return "accept"
        case .decline:
            return "decline";
        }
    }
    
    public override class func collection() -> String {
        return "PigramContactMessage";
    }
    
    public override var messageState: TSOutgoingMessageState {

        if self.isSentByMe {
            return super.messageState;
        }
        return .sent;
    }
    
}

@objc(OWSContactIncomingMessage)
public class PigramContactIncomingMessage: TSIncomingMessage {
    
    public let action: PigramFriendAction
       public let channel: PigramFriendChannel

    // MARK: Initializers
    ///是否为我发送的消息
    @objc
    public var isSentByMe = true;
    
    ///跟action一样 表示状态 重新加一个是为了能够存在数据库
    @objc
    public var status: Int;
    
    @objc
    public var channel_OC: Int;
    
    @objc
    public var userId: String;
    
    @objc
    public var userName: String;
    
    @objc var userAvatar: String;
    
    @objc
    public var extraMessage: String;
    
    @objc /// 发送好友邀请时的验证消息
    public var content: String?
    
    @objc /// 对好友的备注
    public var note: String?
    
    @objc
       public init(thread: TSThread,
                   envelop: SSKProtoEnvelope, message: SSKProtoFriendMessage) {
        self.action = PigramFriendAction.init(rawValue: Int(message.unwrappedAction.rawValue))!;
           self.status = action.rawValue;
        self.channel = PigramFriendChannel.init(rawValue: Int(message.unwrappedChannel.rawValue))!;
           self.channel_OC = channel.rawValue;
        self.userId = message.user?.id ?? "";
        self.userName = message.user?.name ?? "";
        self.userAvatar = message.user?.avatar ?? "";
        self.extraMessage = message.extraMessage;
        
        super.init(incomingMessageWithTimestamp: NSDate.ows_millisecondTimeStamp(), in: thread, authorAddress: envelop.sourceAddress!, sourceDeviceId: envelop.sourceDevice, messageBody: "", attachmentIds: [], expiresInSeconds: 0, quotedMessage: nil, contactShare: nil, linkPreview: nil, messageSticker: nil, serverTimestamp: nil, wasReceivedByUD: true, isViewOnceMessage: false);
        
    }
    
    
    
    
    required init(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        self.action = .apply;
        self.status = 0;
        self.channel = .number;
        self.channel_OC = 0;
        self.userId = "";
        self.userName = "";
        self.userAvatar = "";
        self.extraMessage = "";
        super.init(coder: coder);
    }
    
    required init(dictionary dictionaryValue: [String : Any]!) throws {
        self.action = .apply;
        self.status = 0;
        self.channel = .number;
        self.channel_OC = 0;
        self.userId = "";
        self.userName = "";
        self.userAvatar = "";
        self.extraMessage = "";
        try super.init(dictionary: dictionaryValue);
//        fatalError("init(dictionary:) has not been implemented")
    }
}
