//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import SignalCoreKit

// WARNING: This code is generated. Only edit within the markers.

public enum SSKProtoError: Error {
    case invalidProtobuf(description: String)
}

// MARK: - SSKProtoEnvelope

@objc public class SSKProtoEnvelope: NSObject {

    // MARK: - SSKProtoEnvelopeType
    @objc public var isOffline = false;

    @objc public enum SSKProtoEnvelopeType: Int32 {
        case unknown = 0
        case pigramText = 1
        case receipt = 2
        case typing = 3
        case revoke = 4;
    }

    private class func SSKProtoEnvelopeTypeWrap(_ value: SignalServiceProtos_Envelope.TypeEnum) -> SSKProtoEnvelopeType {
        switch value {
        case .unknown: return .unknown
        case .pigramText: return .pigramText
        case .receipt: return .receipt
        case .typing: return .typing
        case .revoke: return .revoke

        }
    }

    private class func SSKProtoEnvelopeTypeUnwrap(_ value: SSKProtoEnvelopeType) -> SignalServiceProtos_Envelope.TypeEnum {
        switch value {
        case .unknown: return .unknown
        case .pigramText: return .pigramText
        case .receipt: return .receipt
            case .typing: return .typing
            case .revoke: return .revoke

        }
    }

    // MARK: - SSKProtoEnvelopeBuilder

    @objc public class func builder(timestamp: UInt64) -> SSKProtoEnvelopeBuilder {
        return SSKProtoEnvelopeBuilder(timestamp: timestamp)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoEnvelopeBuilder {
        let builder = SSKProtoEnvelopeBuilder(timestamp: timestamp)
        if let _value = type {
            builder.setType(_value)
        }
        if hasSourceDevice {
            builder.setSourceDevice(sourceDevice)
        }
        if let _value = self.sourceId {
            builder.setSourceId(_value)
        }
        if let _value = self.sourceName {
            builder.setSourceName(_value)
        }
        if let _value = sourceAvatar {
            builder.setSourceAvatar(_value)
        }
        
        if let _value = self.groupId {
            builder.setRealSource(_value)
        }
        if let _value = self.groupName {
            builder.setRealName(_value)
        }
        if let _value = self.groupAvatar {
            builder.setRealAvatar(_value)
        }
        
        if let _value = content {
            builder.setContent(_value)
        }
        if let _value = serverGuid {
            builder.setServerGuid(_value)
        }
        if hasServerTimestamp {
            builder.setServerTimestamp(serverTimestamp)
        }
       
        return builder
    }

    @objc public class SSKProtoEnvelopeBuilder: NSObject {

        private var proto = SignalServiceProtos_Envelope()

        @objc fileprivate override init() {}

        @objc fileprivate init(timestamp: UInt64) {
            super.init()

            setTimestamp(timestamp)
        }

        @objc
        public func setType(_ valueParam: SSKProtoEnvelopeType) {
            proto.type = SSKProtoEnvelopeTypeUnwrap(valueParam)
        }

       
        @objc
        public func setSourceId(_ valueParam: String) {
            proto.source = valueParam
        }
        
        @objc
        public func setSourceName(_ valueParam: String) {
            proto.sourceName = valueParam
        }
        
        @objc
        public func setSourceDevice(_ valueParam: UInt32) {
            proto.sourceDevice = valueParam
        }
        
        @objc
        public func setSourceAvatar(_ valueParam: String) {
            proto.sourceAvatar = valueParam
        }

        //在群里发送人的id
        @objc
        public func setRealSource(_ valueParam: String) {
            proto.groupSource = valueParam
        }
        //在群里发送人的昵称
        @objc
        public func setRealName(_ valueParam: String) {
            proto.groupSourceName = valueParam
        }
        //在群里发送人的头像
        @objc
        public func setRealAvatar(_ valueParam: String) {
            proto.groupSourceAvatar = valueParam
        }
       

        @objc
        public func setTimestamp(_ valueParam: UInt64) {
            proto.timestamp = valueParam
        }

      
        @objc
        public func setContent(_ valueParam: Data) {
            proto.content = valueParam
        }

        @objc
        public func setServerGuid(_ valueParam: String) {
            proto.serverGuid = valueParam
        }

        @objc
        public func setServerTimestamp(_ valueParam: UInt64) {
            proto.serverTimestamp = valueParam
        }

       

        @objc public func build() throws -> SSKProtoEnvelope {
            return try SSKProtoEnvelope.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoEnvelope.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_Envelope

    @objc public let timestamp: UInt64
    /**
     * 判断是否需要发送通知 有的消息不需要更新UI
     */
    @objc public var isNeedNotify: Bool = true;

    public var type: SSKProtoEnvelopeType? {
        guard proto.hasType else {
            return nil
        }
        return SSKProtoEnvelope.SSKProtoEnvelopeTypeWrap(proto.type)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    @objc public var unwrappedType: SSKProtoEnvelopeType {
        if !hasType {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: Envelope.type.")
        }
        return SSKProtoEnvelope.SSKProtoEnvelopeTypeWrap(proto.type)
    }
    @objc public var hasType: Bool {
        return proto.hasType
    }
    @objc public var sourceDevice: UInt32 {
        return proto.sourceDevice
    }
    @objc public var hasSourceDevice: Bool {
        return proto.hasSourceDevice
    }
    /**
     * 群id 或者个人id
     */
    @objc public var sourceId: String? {
        guard proto.hasSource else {
            return nil
        }
        return proto.source
    }
    @objc public var hasSourceId: Bool {
        return proto.hasSource
    }

   

    @objc public var sourceName: String? {
        guard proto.hasSourceName else {
            return nil
        }
        return proto.sourceName
    }
    @objc public var hasSourceName: Bool {
        return proto.hasSourceName
    }

    @objc public var sourceAvatar: String? {
        guard proto.hasSourceAvatar else {
            return nil
        }
        return proto.sourceAvatar
    }
    @objc public var hasSourceAvatar: Bool {
        return proto.hasSourceAvatar
    }
    
    @objc public var groupId: String? {
         guard proto.hasGroupSource else {
             return nil
         }
         return proto.groupSource
     }
     @objc public var hasGroupId: Bool {
        
        return proto.groupSource.count > 0;
     }
    

     @objc public var groupName: String? {
         guard proto.hasGroupSourceName else {
             return nil
         }
         return proto.groupSourceName
     }
     @objc public var hasGroupName: Bool {
         return proto.hasGroupSourceName
     }

     @objc public var groupAvatar: String? {
         guard proto.hasGroupSourceAvatar else {
             return nil
         }
         return proto.groupSourceAvatar
     }
     @objc public var hasGroupAvatar: Bool {
         return proto.hasGroupSourceAvatar
     }

    @objc public var content: Data? {
        guard proto.hasContent else {
            return nil
        }
        return proto.content
    }
    @objc public var hasContent: Bool {
        return proto.hasContent
    }

    @objc public var serverGuid: String? {
        guard proto.hasServerGuid else {
            return nil
        }
        return proto.serverGuid
    }
    @objc public var hasServerGuid: Bool {
        return proto.hasServerGuid
    }

    @objc public var serverTimestamp: UInt64 {
        return proto.serverTimestamp
    }
    @objc public var hasServerTimestamp: Bool {
        return proto.hasServerTimestamp
    }

   

    @objc public var hasValidSource: Bool {
        return sourceAddress != nil
    }
    @objc public var sourceAddress: SignalServiceAddress? {
        guard hasSourceId || hasGroupId else { return nil }
        //用address 的uuid 表示个人和群组的id
        var address = SignalServiceAddress(phoneNumber: self.sourceId!);
        if hasGroupId {
            address = SignalServiceAddress.init(phoneNumber: self.groupId);
        }
        guard address.isValid else {
            owsFailDebug("address was unexpectedly invalid")
            return nil
        }

        return address
    }
    
    @objc public var isGroup: Bool {
        
        return self.sourceAddress?.type == .group;
    }

    private init(proto: SignalServiceProtos_Envelope,
                 timestamp: UInt64) {
        self.proto = proto
        self.timestamp = timestamp
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoEnvelope {
        let proto = try SignalServiceProtos_Envelope(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_Envelope) throws -> SSKProtoEnvelope {
        guard proto.hasTimestamp else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: timestamp")
        }
        
        guard proto.hasSource else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required source id")
        }
        let timestamp = proto.timestamp

        // MARK: - Begin Validation Logic for SSKProtoEnvelope -

        // MARK: - End Validation Logic for SSKProtoEnvelope -

        let result = SSKProtoEnvelope(proto: proto,
                                      timestamp: timestamp)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoEnvelope {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoEnvelope.SSKProtoEnvelopeBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoEnvelope? {
        return try! self.build()
    }
}

#endif

// MARK: User  entity
@objc
public class SSKProtoUserEntiy: NSObject {
    
    
    
    fileprivate let proto: SignalServiceProtos_UserEntity;
    
    @objc public class func builder() -> SSKProtoUserEntiyBuidler {
        return SSKProtoUserEntiyBuidler()
    }
    
    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoUserEntiyBuidler {
        let builder = SSKProtoUserEntiyBuidler()
        
        builder.setId(self.id);
        builder.setName(self.name);
        builder.setAvatar(self.avatar);
        return builder
    }
    @objc
    public class SSKProtoUserEntiyBuidler: NSObject {
        
        fileprivate var proto = SignalServiceProtos_UserEntity();
        @objc fileprivate override init() {}
        
        @objc
        public func setId(_ valueParam: String?) {
            guard valueParam != nil else {
                return;
            }
            proto.userID = valueParam!;
        }
        
        @objc
        public func setName(_ valueParam: String?) {
            guard valueParam != nil else {
                return;
            }
            proto.userName = valueParam!;
        }
        @objc
        public func setAvatar(_ valueParam: String?) {
            guard valueParam != nil else {
                return;
            }
            proto.userAvatar = valueParam!;
        }
        
        
        
        @objc public func build() throws -> SSKProtoUserEntiy {
            return try SSKProtoUserEntiy.parseProto(proto)
        }
        
        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoUserEntiy.parseProto(proto).serializedData()
        }
        
        
    }
    @objc public var hasId: Bool {
        return proto.hasUserID
    }
    
    @objc
    public var id: String? {
        if !self.hasId {
            return nil;
        }
        return proto.userID;
    }
    
    @objc public var hasName: Bool {
        return proto.hasUserName
    }
    
    @objc
    public var name: String? {
        if !self.hasName {
            return nil;
        }
        return proto.userName;
    }
    
    @objc public var hasAvatar: Bool {
        return proto.hasUserAvatar
    }
    
    @objc
    public var avatar: String? {
        if !self.hasAvatar {
            return nil;
        }
        return proto.userAvatar;
    }
    
    private  init(proto: SignalServiceProtos_UserEntity) {
        self.proto = proto;
    }
    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoUserEntiy {
        let proto = try SignalServiceProtos_UserEntity(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_UserEntity) throws -> SSKProtoUserEntiy {
        
        // MARK: - Begin Validation Logic for SSKProtoTypingMessage -

        // MARK: - End Validation Logic for SSKProtoTypingMessage -

        let result = SSKProtoUserEntiy(proto: proto)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
    
    
    
    
}
// MARK: 撤回某个人的所有消息
@objc
public class SSKProtoRevokeUserMessage: NSObject {
    
    
    fileprivate let proto: SignalServiceProtos_RevokeUserMessage;
    
    @objc public class func builder() -> SSKProtoRevokeUserMessagesBuilder {
        return SSKProtoRevokeUserMessagesBuilder()
    }
    
    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoRevokeUserMessagesBuilder {
        let builder = SSKProtoRevokeUserMessagesBuilder()
        
        builder.setTargetUserID(self.targetUserId);
        builder.setTagrgetGroupId(self.targetGroupId);
        return builder
    }
    @objc
    public class SSKProtoRevokeUserMessagesBuilder: NSObject {
        
        fileprivate var proto = SignalServiceProtos_RevokeUserMessage();
        @objc fileprivate override init() {}
        
        @objc
        public func setTargetUserID(_ valueParam: String?) {
            guard valueParam != nil else {
                return;
            }
            proto.targetUserID = valueParam!;
        }
        
        @objc
        public func setTagrgetGroupId(_ valueParam: String?) {
            guard valueParam != nil else {
                return;
            }
            proto.targetGroupID = valueParam!;
        }
        
        @objc public func build() throws -> SSKProtoRevokeUserMessage {
            return try SSKProtoRevokeUserMessage.parseProto(proto)
        }
        
        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoRevokeUserMessage.parseProto(proto).serializedData()
        }
        
        
    }
    @objc public var hasUserId: Bool {
        return proto.hasTargetUserID
    }
    
    @objc
    public var targetUserId: String? {
        if !self.hasUserId {
            return nil;
        }
        return proto.targetUserID;
    }
    
    @objc public var hasTargetGroupId: Bool {
           return proto.hasTargetGroupID
       }
       
       @objc
       public var targetGroupId: String? {
           if !self.hasTargetGroupId {
               return nil;
           }
           return proto.targetGroupID;
       }

    
    private  init(proto: SignalServiceProtos_RevokeUserMessage) {
        self.proto = proto;
    }
    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoRevokeUserMessage {
        let proto = try SignalServiceProtos_RevokeUserMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_RevokeUserMessage) throws -> SSKProtoRevokeUserMessage {
        if !proto.hasTargetUserID {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: targetuserid")
            
        }
        // MARK: - Begin Validation Logic for SSKProtoTypingMessage -

        // MARK: - End Validation Logic for SSKProtoTypingMessage -

        let result = SSKProtoRevokeUserMessage(proto: proto)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
    
    
    
    
}


// MARK: revoke message
@objc
public class SSKProtoRevokeMessage: NSObject {
    
    
    fileprivate let proto: SignalServiceProtos_RevokeMessage;
    
    @objc public class func builder() -> SSKProtoRevokeMessageBuilder {
        return SSKProtoRevokeMessageBuilder()
    }
    
    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoRevokeMessageBuilder {
        let builder = SSKProtoRevokeMessageBuilder()
        
        builder.setTargetUserID(self.targetUserId);
        builder.setTagrgetTimeStamp(self.targetTimestamp);
        return builder
    }
    @objc
    public class SSKProtoRevokeMessageBuilder: NSObject {
        
        fileprivate var proto = SignalServiceProtos_RevokeMessage();
        @objc fileprivate override init() {}
        
        @objc
        public func setTargetUserID(_ valueParam: String?) {
            guard valueParam != nil else {
                return;
            }
            proto.targetUserID = valueParam!;
        }
        
        @objc
        public func setTagrgetTimeStamp(_ valueParam: UInt64) {
            guard valueParam != 0 else {
                return;
            }
            proto.targetTimestamp = valueParam;
        }
        
        @objc public func build() throws -> SSKProtoRevokeMessage {
            return try SSKProtoRevokeMessage.parseProto(proto)
        }
        
        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoRevokeMessage.parseProto(proto).serializedData()
        }
        
        
    }
    @objc public var hasId: Bool {
        return proto.hasTargetUserID
    }
    
    @objc
    public var targetUserId: String? {
        if !self.hasId {
            return nil;
        }
        return proto.targetUserID;
    }
    
    @objc public var hasTimeStamp: Bool {
        return proto.hasTargetTimestamp
    }
    
    @objc
    public var targetTimestamp: UInt64 {
        if !self.hasTimeStamp {
            return 0;
        }
        return proto.targetTimestamp;
    }

    
    private  init(proto: SignalServiceProtos_RevokeMessage) {
        self.proto = proto;
    }
    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoRevokeMessage {
        let proto = try SignalServiceProtos_RevokeMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_RevokeMessage) throws -> SSKProtoRevokeMessage {
        if !proto.hasTargetUserID {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: targetuserid")
            
        }
        // MARK: - Begin Validation Logic for SSKProtoTypingMessage -

        // MARK: - End Validation Logic for SSKProtoTypingMessage -

        let result = SSKProtoRevokeMessage(proto: proto)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
    
    
    
    
}

// MARK: - SSKProtoTypingMessage

@objc public class SSKProtoTypingMessage: NSObject {

    // MARK: - SSKProtoTypingMessageAction

    @objc public enum SSKProtoTypingMessageAction: Int32 {
        case started = 0
        case stopped = 1
        
    }

    private class func SSKProtoTypingMessageActionWrap(_ value: SignalServiceProtos_TypingMessage.Action) -> SSKProtoTypingMessageAction {
        switch value {
        case .started: return .started
        case .stopped: return .stopped
       
        
        }
    }

    private class func SSKProtoTypingMessageActionUnwrap(_ value: SSKProtoTypingMessageAction) -> SignalServiceProtos_TypingMessage.Action {
        switch value {
        case .started: return .started
        case .stopped: return .stopped
        }
    }

    // MARK: - SSKProtoTypingMessageBuilder

    @objc public class func builder(timestamp: UInt64) -> SSKProtoTypingMessageBuilder {
        return SSKProtoTypingMessageBuilder(timestamp: timestamp)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoTypingMessageBuilder {
        let builder = SSKProtoTypingMessageBuilder(timestamp: timestamp)
        if let _value = action {
            builder.setAction(_value)
        }
        if let _value = groupID {
            builder.setGroupID(_value)
        }
        return builder
    }

    @objc public class SSKProtoTypingMessageBuilder: NSObject {

        private var proto = SignalServiceProtos_TypingMessage()

        @objc fileprivate override init() {}

        @objc fileprivate init(timestamp: UInt64) {
            super.init()

            setTimestamp(timestamp)
        }

        @objc
        public func setTimestamp(_ valueParam: UInt64) {
            proto.timestamp = valueParam
        }

        @objc
        public func setAction(_ valueParam: SSKProtoTypingMessageAction) {
            proto.action = SSKProtoTypingMessageActionUnwrap(valueParam)
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setGroupID(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.groupID = valueParam
        }

        public func setGroupID(_ valueParam: String) {
            proto.groupID = valueParam
        }

        @objc public func build() throws -> SSKProtoTypingMessage {
            return try SSKProtoTypingMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoTypingMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_TypingMessage

    @objc public let timestamp: UInt64

    public var action: SSKProtoTypingMessageAction? {
        guard proto.hasAction else {
            return nil
        }
        return SSKProtoTypingMessage.SSKProtoTypingMessageActionWrap(proto.action)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    @objc public var unwrappedAction: SSKProtoTypingMessageAction {
        if !hasAction {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: TypingMessage.action.")
        }
        return SSKProtoTypingMessage.SSKProtoTypingMessageActionWrap(proto.action)
    }
    @objc public var hasAction: Bool {
        return proto.hasAction
    }

    @objc public var groupID: String? {
        guard proto.hasGroupID else {
            return nil
        }
        return proto.groupID
    }
    @objc public var hasGroupID: Bool {
        return proto.hasGroupID
    }

    private init(proto: SignalServiceProtos_TypingMessage,
                 timestamp: UInt64) {
        self.proto = proto
        self.timestamp = timestamp
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoTypingMessage {
        let proto = try SignalServiceProtos_TypingMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_TypingMessage) throws -> SSKProtoTypingMessage {
        guard proto.hasTimestamp else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: timestamp")
        }
        let timestamp = proto.timestamp

        // MARK: - Begin Validation Logic for SSKProtoTypingMessage -

        // MARK: - End Validation Logic for SSKProtoTypingMessage -

        let result = SSKProtoTypingMessage(proto: proto,
                                           timestamp: timestamp)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoTypingMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoTypingMessage.SSKProtoTypingMessageBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoTypingMessage? {
        return try! self.build()
    }
}

#endif

// MARK: - 邀请好友
@objc public class SSKProtoFriendMessage: NSObject {
    
    // MARK: - SSKProtoTypingMessageAction
    
    @objc public enum SSKProtoFriendMessageAction: Int32 {
        case apply = 0
        case accept = 1
        case decline = 2
    }
    
    @objc public enum SSKProtoFriendMessageChannel: Int32 {
           case number = 0
           case scan = 1
           case group = 2
           case userID // = 3
           case card // = 4
           case link // = 5
       }
    
    private class func SSKProtoFriendMessageActionWrap(_ value: SignalServiceProtos_FriendOperation.Action) -> SSKProtoFriendMessageAction {
        switch value {
        case .apply: return .apply
        case .accept: return .accept
        case .decline: return .decline
       
        }
    }
    
    private class func SSKProtoFriendMessageActionUnwrap(_ value: SSKProtoFriendMessageAction) -> SignalServiceProtos_FriendOperation.Action {
        switch value {
        case .apply: return .apply
        case .accept: return .accept
        case .decline: return .decline
    
        }
    }
    
    private class func SSKProtoFriendMessageChannelWrap(_ value: SignalServiceProtos_FriendOperation.Channel) -> SSKProtoFriendMessageChannel {
          switch value {
          case .number: return .number
          case .scan: return .scan
          case .group: return .group
          case .card: return .card
          case .userID: return .userID
          case .link : return .link

          }
    }
    
    private class func SSKProtoFriendMessageChannelUnwrap(_ value: SSKProtoFriendMessageChannel) -> SignalServiceProtos_FriendOperation.Channel {
           switch value {
           case .number: return .number
           case .scan: return .scan
           case .group: return .group
           case .card: return .card
           case .userID: return .userID
           case .link : return .link

           }
    }
    
    // MARK: - SSKProtoFriendMessageBuilder
    
    @objc public class func builder(timestamp: UInt64) -> SSKProtoFriendMessageBuilder {
        return SSKProtoFriendMessageBuilder()
    }
    
    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoFriendMessageBuilder {
        let builder = SSKProtoFriendMessageBuilder()
        if let _value = action {
            builder.setAction(_value)
        }
        if let _value = channel {
            builder.setChannel(_value)
        }
        builder.setUser(self.user);

        builder.setExtraMessage(self.extraMessage)
        return builder
    }
    
    @objc public class SSKProtoFriendMessageBuilder: NSObject {
        
        private var proto = SignalServiceProtos_FriendOperation()
        
        @objc fileprivate override init() {}
                    
        
        @objc
        public func setAction(_ valueParam: SSKProtoFriendMessageAction) {
            
            proto.action = SSKProtoFriendMessageActionUnwrap(valueParam)
        }
        @objc
        public func setChannel(_ valueParam: SSKProtoFriendMessageChannel) {
            
            proto.channel = SSKProtoFriendMessageChannelUnwrap(valueParam);
        }
        
        @objc
        public func setUser(_ valueParam: SSKProtoUserEntiy?) {
            guard valueParam != nil else {
                return;
            }
            proto.user = valueParam!.proto;
        }
        
        @objc
        public func setExtraMessage(_ valueParam: String?) {
            guard valueParam != nil else {
                return;
            }
            proto.extraMessage = valueParam!;
        }
        
        @objc public func build() throws -> SSKProtoFriendMessage {
            return try SSKProtoFriendMessage.parseProto(proto)
        }
        
        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoFriendMessage.parseProto(proto).serializedData()
        }
    }
    
    fileprivate let proto: SignalServiceProtos_FriendOperation
        
    public var action: SSKProtoFriendMessageAction? {
        guard proto.hasAction else {
            return nil
        }
        return SSKProtoFriendMessage.SSKProtoFriendMessageActionWrap(proto.action)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    @objc public var unwrappedAction: SSKProtoFriendMessageAction {
        if !hasAction {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: FriendMessage.action.")
        }
        return SSKProtoFriendMessage.SSKProtoFriendMessageActionWrap(proto.action)
    }
    @objc public var hasAction: Bool {
        return proto.hasAction
    }
    
    @objc
    public var hasChannel: Bool {
        return proto.hasChannel;
    }
    @objc public var hasUser: Bool {
           return proto.hasUser
       }
    @objc
    public var user: SSKProtoUserEntiy? {
        guard self.hasUser else {
            return nil
        }
        return try? SSKProtoUserEntiy.parseProto(self.proto.user);
    }
    
    
    @objc
    public var hasExtraMessage: Bool {
        return proto.hasExtraMessage;
    }
    @objc
    public var extraMessage: String {
        return proto.extraMessage;
    }
    
    public var channel: SSKProtoFriendMessageChannel? {
        guard proto.hasAction else {
            return nil
        }
        return SSKProtoFriendMessage.SSKProtoFriendMessageChannelWrap(proto.channel)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    @objc public var unwrappedChannel: SSKProtoFriendMessageChannel {
        if !hasAction {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: FriendMessage.action.")
        }
        return SSKProtoFriendMessage.SSKProtoFriendMessageChannelWrap(proto.channel)
    }
    
    
    private init(proto: SignalServiceProtos_FriendOperation) {
        self.proto = proto
       
    }
    
    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }
    
    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoFriendMessage {
        let proto = try SignalServiceProtos_FriendOperation(serializedData: serializedData)
        return try parseProto(proto)
    }
    
    fileprivate class func parseProto(_ proto: SignalServiceProtos_FriendOperation) throws -> SSKProtoFriendMessage {
        
        
        // MARK: - Begin Validation Logic for SSKProtoTypingMessage -
        
        // MARK: - End Validation Logic for SSKProtoTypingMessage -
        
        let result = SSKProtoFriendMessage(proto: proto);
    
        return result
    }
    
    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoFriendMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoFriendMessage.SSKProtoFriendMessageBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoFriendMessage? {
        return try! self.build()
    }
}

#endif
// MARK: 群名片和好友名片的分享
@objc public class SSKProtoShareMessage: NSObject {
    
    @objc public enum SSKProtoShareType: Int {

        case contact = 0;
        case group = 1;
    }
   
    
    @objc public var shareId: String? {
        
        return self.proto.sharedID;
    }
    
    @objc public var shareName: String? {
        
        return self.proto.sharedName;
    }
    @objc
    public var shareAvatar: String? {
        
        return self.proto.sharedAvatar;
    }
    
    fileprivate let proto: SignalServiceProtos_DataMessage.ShareMessage
    
    private init(proto: SignalServiceProtos_DataMessage.ShareMessage) {
        self.proto = proto;
    }
    
    @objc public class func builder(timestamp: UInt64) -> SSKProtoShareMessageBuidler {
        return SSKProtoShareMessageBuidler();
      }
      
    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoShareMessageBuidler {
        let builder = SSKProtoShareMessageBuidler()
       
        if let _value = self.shareId {
            builder.setShareId(_value);
        }
        if let _value = self.shareName {
            builder.setShareName(_value);
        }
        if let _value = self.shareAvatar {
            builder.setShareAvatar(_value);
        }
        return builder
    }
    
    @objc public class SSKProtoShareMessageBuidler: NSObject {
        
        private var proto = SignalServiceProtos_DataMessage.ShareMessage();
        
        @objc fileprivate override init() {}
        
        
        @objc
        public func setShareId(_ value: String?) {
            if value == nil {
                return;
            }
            self.proto.sharedID = value!;
        }
        
        @objc
        public func setShareName(_ value: String?) {
            if value == nil {
                return;
            }
            self.proto.sharedName = value!;
        }
        
        @objc
        public func setShareAvatar(_ value: String?) {
            if  value == nil {
                return;
            }
            self.proto.sharedAvatar = value!;
        }
        @objc public func build() throws -> SSKProtoShareMessage {
            return try SSKProtoShareMessage.parseProto(proto)
        }
        
        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoShareMessage.parseProto(proto).serializedData()
        }
    }
    
    @objc
       public func serializedData() throws -> Data {
           return try self.proto.serializedData()
       }
       
       @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoShareMessage {
           let proto = try SignalServiceProtos_DataMessage.ShareMessage(serializedData: serializedData)
           return try parseProto(proto)
       }
       
       fileprivate class func parseProto(_ proto: SignalServiceProtos_DataMessage.ShareMessage) throws -> SSKProtoShareMessage {
           
           
           // MARK: - Begin Validation Logic for SSKProtoTypingMessage -
           
           // MARK: - End Validation Logic for SSKProtoTypingMessage -
           
           let result = SSKProtoShareMessage(proto: proto);
       
           return result
       }
       
       @objc public override var debugDescription: String {
           return "\(proto)"
       }
    
}

// MARK: - SSKProtoContent

@objc public class SSKProtoContent: NSObject {

    // MARK: - SSKProtoContentBuilder

    @objc public class func builder() -> SSKProtoContentBuilder {
        return SSKProtoContentBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoContentBuilder {
        let builder = SSKProtoContentBuilder()
        if let _value = dataMessage {
            builder.setDataMessage(_value)
        }
        if let _value = syncMessage {
            builder.setSyncMessage(_value)
        }
        if let _value = callMessage {
            builder.setCallMessage(_value)
        }
        if let _value = nullMessage {
            builder.setNullMessage(_value)
        }
        if let _value = receiptMessage {
            builder.setReceiptMessage(_value)
        }
        if let _value = typingMessage {
            builder.setTypingMessage(_value)
        }
        if let _value = friendMessage {
            builder.setFriendMessage(_value);
        }
        if let _value = groupOperation {
           builder.setGroupOperation(_value);
       }
        if let _value = self.revokeMessage {
            builder.setRevokeMessage(_value); 
        }
        if let _value = self.revokeUserMessage {
            builder.setRevokeUserMessage(_value);
        }
        
        return builder
    }

    @objc public class SSKProtoContentBuilder: NSObject {

        private var proto = SignalServiceProtos_Content()

        @objc fileprivate override init() {}

        @objc
        @available(swift, obsoleted: 1.0)
        public func setDataMessage(_ valueParam: SSKProtoDataMessage?) {
            guard let valueParam = valueParam else { return }
            proto.dataMessage = valueParam.proto
        }

        public func setDataMessage(_ valueParam: SSKProtoDataMessage) {
            proto.dataMessage = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setSyncMessage(_ valueParam: SSKProtoSyncMessage?) {
            guard let valueParam = valueParam else { return }
            proto.syncMessage = valueParam.proto
        }

        public func setSyncMessage(_ valueParam: SSKProtoSyncMessage) {
            proto.syncMessage = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setCallMessage(_ valueParam: SSKProtoCallMessage?) {
            guard let valueParam = valueParam else { return }
            proto.callMessage = valueParam.proto
        }

        public func setCallMessage(_ valueParam: SSKProtoCallMessage) {
            proto.callMessage = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setNullMessage(_ valueParam: SSKProtoNullMessage?) {
            guard let valueParam = valueParam else { return }
            proto.nullMessage = valueParam.proto
        }

        public func setNullMessage(_ valueParam: SSKProtoNullMessage) {
            proto.nullMessage = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setReceiptMessage(_ valueParam: SSKProtoReceiptMessage?) {
            guard let valueParam = valueParam else { return }
            proto.receiptMessage = valueParam.proto
        }

        public func setReceiptMessage(_ valueParam: SSKProtoReceiptMessage) {
            proto.receiptMessage = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setTypingMessage(_ valueParam: SSKProtoTypingMessage?) {
            guard let valueParam = valueParam else { return }
            proto.typingMessage = valueParam.proto
        }

        public func setTypingMessage(_ valueParam: SSKProtoTypingMessage) {
            proto.typingMessage = valueParam.proto
        }
        
        @objc
        @available(swift, obsoleted: 1.0)
        public func setContactMessage(_ valueParam: SSKProtoFriendMessage?) {
            guard let valueParam = valueParam else { return }
            proto.friendOperation = valueParam.proto
        }
        
        @objc
        public func setFriendMessage(_ valueParam: SSKProtoFriendMessage) {
            proto.friendOperation = valueParam.proto
        }
        
        @objc
        public func setGroupOperation(_ valueParam: SSKProtoGroupContext) {
            proto.groupOperation = valueParam.proto
        }
        
        @objc
        public func setRevokeMessage(_ valueParam: [SSKProtoRevokeMessage]?) {
            if let _value = valueParam {
                
                proto.revokeMessage = _value.map({ (message) -> SignalServiceProtos_RevokeMessage in
                    return message.proto;
                });
            }
        }
        @objc
        public func setRevokeUserMessage(_ valueParam: SSKProtoRevokeUserMessage?) {
            if let _value = valueParam {
                proto.revokeUserMessage = _value.proto;
            }
        }
        @objc public func build() throws -> SSKProtoContent {
            return try SSKProtoContent.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoContent.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_Content

    @objc public let dataMessage: SSKProtoDataMessage?

    @objc public let syncMessage: SSKProtoSyncMessage?

    @objc public let callMessage: SSKProtoCallMessage?

    @objc public let nullMessage: SSKProtoNullMessage?

    @objc public let receiptMessage: SSKProtoReceiptMessage?

    @objc public let typingMessage: SSKProtoTypingMessage?

    @objc public let friendMessage: SSKProtoFriendMessage?
        
    @objc public let groupOperation: SSKProtoGroupContext?
    
    @objc public let revokeMessage: [SSKProtoRevokeMessage]?

    @objc public let revokeUserMessage: SSKProtoRevokeUserMessage?

    
    private init(proto: SignalServiceProtos_Content,
                 dataMessage: SSKProtoDataMessage?,
                 syncMessage: SSKProtoSyncMessage?,
                 callMessage: SSKProtoCallMessage?,
                 nullMessage: SSKProtoNullMessage?,
                 receiptMessage: SSKProtoReceiptMessage?,
                 typingMessage: SSKProtoTypingMessage?,
                 friendMessage: SSKProtoFriendMessage?) {
        self.proto = proto
        self.dataMessage = dataMessage
        self.syncMessage = syncMessage
        self.callMessage = callMessage
        self.nullMessage = nullMessage
        self.receiptMessage = receiptMessage
        self.typingMessage = typingMessage
        self.friendMessage = friendMessage
        if proto.hasGroupOperation {
            self.groupOperation = try? SSKProtoGroupContext.parseProto(proto.groupOperation);
        } else {
            self.groupOperation = nil;
        }
        if proto.revokeMessage.count > 0 {
            self.revokeMessage = try? proto.revokeMessage.map({ (message) -> SSKProtoRevokeMessage in
                return try SSKProtoRevokeMessage.parseProto(message);
            });
        } else {
            self.revokeMessage = nil;
        }
        if proto.hasRevokeUserMessage {
            self.revokeUserMessage = try? SSKProtoRevokeUserMessage.parseProto(proto.revokeUserMessage);
        } else {
            self.revokeUserMessage = nil;
        }
        
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoContent {
        let proto = try SignalServiceProtos_Content(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_Content) throws -> SSKProtoContent {
        var dataMessage: SSKProtoDataMessage? = nil
        if proto.hasDataMessage {
            dataMessage = try SSKProtoDataMessage.parseProto(proto.dataMessage)
        }

        var syncMessage: SSKProtoSyncMessage? = nil
        if proto.hasSyncMessage {
            syncMessage = try SSKProtoSyncMessage.parseProto(proto.syncMessage)
        }

        var callMessage: SSKProtoCallMessage? = nil
        if proto.hasCallMessage {
            callMessage = try SSKProtoCallMessage.parseProto(proto.callMessage)
        }

        var nullMessage: SSKProtoNullMessage? = nil
        if proto.hasNullMessage {
            nullMessage = try SSKProtoNullMessage.parseProto(proto.nullMessage)
        }

        var receiptMessage: SSKProtoReceiptMessage? = nil
        if proto.hasReceiptMessage {
            receiptMessage = try SSKProtoReceiptMessage.parseProto(proto.receiptMessage)
        }

        var typingMessage: SSKProtoTypingMessage? = nil
        if proto.hasTypingMessage {
            typingMessage = try SSKProtoTypingMessage.parseProto(proto.typingMessage)
        }
        var friendMessage: SSKProtoFriendMessage? = nil
        if proto.hasFriendOperation {
            friendMessage = try SSKProtoFriendMessage.parseProto(proto.friendOperation);
        }
       
        
        // MARK: - Begin Validation Logic for SSKProtoContent -
        
        // MARK: - End Validation Logic for SSKProtoContent -
        
        let result = SSKProtoContent(proto: proto,
                                     dataMessage: dataMessage,
                                     syncMessage: syncMessage,
                                     callMessage: callMessage,
                                     nullMessage: nullMessage,
                                     receiptMessage: receiptMessage,
                                     typingMessage: typingMessage,friendMessage: friendMessage);
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoContent {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoContent.SSKProtoContentBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoContent? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoCallMessageOffer

@objc public class SSKProtoCallMessageOffer: NSObject {

    // MARK: - SSKProtoCallMessageOfferBuilder

    @objc public class func builder(id: UInt64, sessionDescription: String) -> SSKProtoCallMessageOfferBuilder {
        return SSKProtoCallMessageOfferBuilder(id: id, sessionDescription: sessionDescription)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoCallMessageOfferBuilder {
        let builder = SSKProtoCallMessageOfferBuilder(id: id, sessionDescription: sessionDescription)
        return builder
    }

    @objc public class SSKProtoCallMessageOfferBuilder: NSObject {

        private var proto = SignalServiceProtos_CallMessage.Offer()

        @objc fileprivate override init() {}

        @objc fileprivate init(id: UInt64, sessionDescription: String) {
            super.init()

            setId(id)
            setSessionDescription(sessionDescription)
        }

        @objc
        public func setId(_ valueParam: UInt64) {
            proto.id = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setSessionDescription(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.sessionDescription = valueParam
        }

        public func setSessionDescription(_ valueParam: String) {
            proto.sessionDescription = valueParam
        }

        @objc public func build() throws -> SSKProtoCallMessageOffer {
            return try SSKProtoCallMessageOffer.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoCallMessageOffer.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_CallMessage.Offer

    @objc public let id: UInt64

    @objc public let sessionDescription: String

    private init(proto: SignalServiceProtos_CallMessage.Offer,
                 id: UInt64,
                 sessionDescription: String) {
        self.proto = proto
        self.id = id
        self.sessionDescription = sessionDescription
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoCallMessageOffer {
        let proto = try SignalServiceProtos_CallMessage.Offer(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_CallMessage.Offer) throws -> SSKProtoCallMessageOffer {
        guard proto.hasID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: id")
        }
        let id = proto.id

        guard proto.hasSessionDescription else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: sessionDescription")
        }
        let sessionDescription = proto.sessionDescription

        // MARK: - Begin Validation Logic for SSKProtoCallMessageOffer -

        // MARK: - End Validation Logic for SSKProtoCallMessageOffer -

        let result = SSKProtoCallMessageOffer(proto: proto,
                                              id: id,
                                              sessionDescription: sessionDescription)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoCallMessageOffer {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoCallMessageOffer.SSKProtoCallMessageOfferBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoCallMessageOffer? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoCallMessageAnswer

@objc public class SSKProtoCallMessageAnswer: NSObject {

    // MARK: - SSKProtoCallMessageAnswerBuilder

    @objc public class func builder(id: UInt64, sessionDescription: String) -> SSKProtoCallMessageAnswerBuilder {
        return SSKProtoCallMessageAnswerBuilder(id: id, sessionDescription: sessionDescription)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoCallMessageAnswerBuilder {
        let builder = SSKProtoCallMessageAnswerBuilder(id: id, sessionDescription: sessionDescription)
        return builder
    }

    @objc public class SSKProtoCallMessageAnswerBuilder: NSObject {

        private var proto = SignalServiceProtos_CallMessage.Answer()

        @objc fileprivate override init() {}

        @objc fileprivate init(id: UInt64, sessionDescription: String) {
            super.init()

            setId(id)
            setSessionDescription(sessionDescription)
        }

        @objc
        public func setId(_ valueParam: UInt64) {
            proto.id = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setSessionDescription(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.sessionDescription = valueParam
        }

        public func setSessionDescription(_ valueParam: String) {
            proto.sessionDescription = valueParam
        }

        @objc public func build() throws -> SSKProtoCallMessageAnswer {
            return try SSKProtoCallMessageAnswer.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoCallMessageAnswer.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_CallMessage.Answer

    @objc public let id: UInt64

    @objc public let sessionDescription: String

    private init(proto: SignalServiceProtos_CallMessage.Answer,
                 id: UInt64,
                 sessionDescription: String) {
        self.proto = proto
        self.id = id
        self.sessionDescription = sessionDescription
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoCallMessageAnswer {
        let proto = try SignalServiceProtos_CallMessage.Answer(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_CallMessage.Answer) throws -> SSKProtoCallMessageAnswer {
        guard proto.hasID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: id")
        }
        let id = proto.id

        guard proto.hasSessionDescription else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: sessionDescription")
        }
        let sessionDescription = proto.sessionDescription

        // MARK: - Begin Validation Logic for SSKProtoCallMessageAnswer -

        // MARK: - End Validation Logic for SSKProtoCallMessageAnswer -

        let result = SSKProtoCallMessageAnswer(proto: proto,
                                               id: id,
                                               sessionDescription: sessionDescription)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoCallMessageAnswer {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoCallMessageAnswer.SSKProtoCallMessageAnswerBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoCallMessageAnswer? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoCallMessageIceUpdate

@objc public class SSKProtoCallMessageIceUpdate: NSObject {

    // MARK: - SSKProtoCallMessageIceUpdateBuilder

    @objc public class func builder(id: UInt64, sdpMid: String, sdpMlineIndex: UInt32, sdp: String) -> SSKProtoCallMessageIceUpdateBuilder {
        return SSKProtoCallMessageIceUpdateBuilder(id: id, sdpMid: sdpMid, sdpMlineIndex: sdpMlineIndex, sdp: sdp)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoCallMessageIceUpdateBuilder {
        let builder = SSKProtoCallMessageIceUpdateBuilder(id: id, sdpMid: sdpMid, sdpMlineIndex: sdpMlineIndex, sdp: sdp)
        return builder
    }

    @objc public class SSKProtoCallMessageIceUpdateBuilder: NSObject {

        private var proto = SignalServiceProtos_CallMessage.IceUpdate()

        @objc fileprivate override init() {}

        @objc fileprivate init(id: UInt64, sdpMid: String, sdpMlineIndex: UInt32, sdp: String) {
            super.init()

            setId(id)
            setSdpMid(sdpMid)
            setSdpMlineIndex(sdpMlineIndex)
            setSdp(sdp)
        }

        @objc
        public func setId(_ valueParam: UInt64) {
            proto.id = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setSdpMid(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.sdpMid = valueParam
        }

        public func setSdpMid(_ valueParam: String) {
            proto.sdpMid = valueParam
        }

        @objc
        public func setSdpMlineIndex(_ valueParam: UInt32) {
            proto.sdpMlineIndex = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setSdp(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.sdp = valueParam
        }

        public func setSdp(_ valueParam: String) {
            proto.sdp = valueParam
        }

        @objc public func build() throws -> SSKProtoCallMessageIceUpdate {
            return try SSKProtoCallMessageIceUpdate.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoCallMessageIceUpdate.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_CallMessage.IceUpdate

    @objc public let id: UInt64

    @objc public let sdpMid: String

    @objc public let sdpMlineIndex: UInt32

    @objc public let sdp: String

    private init(proto: SignalServiceProtos_CallMessage.IceUpdate,
                 id: UInt64,
                 sdpMid: String,
                 sdpMlineIndex: UInt32,
                 sdp: String) {
        self.proto = proto
        self.id = id
        self.sdpMid = sdpMid
        self.sdpMlineIndex = sdpMlineIndex
        self.sdp = sdp
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoCallMessageIceUpdate {
        let proto = try SignalServiceProtos_CallMessage.IceUpdate(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_CallMessage.IceUpdate) throws -> SSKProtoCallMessageIceUpdate {
        guard proto.hasID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: id")
        }
        let id = proto.id

        guard proto.hasSdpMid else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: sdpMid")
        }
        let sdpMid = proto.sdpMid

        guard proto.hasSdpMlineIndex else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: sdpMlineIndex")
        }
        let sdpMlineIndex = proto.sdpMlineIndex

        guard proto.hasSdp else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: sdp")
        }
        let sdp = proto.sdp

        // MARK: - Begin Validation Logic for SSKProtoCallMessageIceUpdate -

        // MARK: - End Validation Logic for SSKProtoCallMessageIceUpdate -

        let result = SSKProtoCallMessageIceUpdate(proto: proto,
                                                  id: id,
                                                  sdpMid: sdpMid,
                                                  sdpMlineIndex: sdpMlineIndex,
                                                  sdp: sdp)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoCallMessageIceUpdate {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoCallMessageIceUpdate.SSKProtoCallMessageIceUpdateBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoCallMessageIceUpdate? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoCallMessageBusy

@objc public class SSKProtoCallMessageBusy: NSObject {

    // MARK: - SSKProtoCallMessageBusyBuilder

    @objc public class func builder(id: UInt64) -> SSKProtoCallMessageBusyBuilder {
        return SSKProtoCallMessageBusyBuilder(id: id)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoCallMessageBusyBuilder {
        let builder = SSKProtoCallMessageBusyBuilder(id: id)
        return builder
    }

    @objc public class SSKProtoCallMessageBusyBuilder: NSObject {

        private var proto = SignalServiceProtos_CallMessage.Busy()

        @objc fileprivate override init() {}

        @objc fileprivate init(id: UInt64) {
            super.init()

            setId(id)
        }

        @objc
        public func setId(_ valueParam: UInt64) {
            proto.id = valueParam
        }

        @objc public func build() throws -> SSKProtoCallMessageBusy {
            return try SSKProtoCallMessageBusy.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoCallMessageBusy.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_CallMessage.Busy

    @objc public let id: UInt64

    private init(proto: SignalServiceProtos_CallMessage.Busy,
                 id: UInt64) {
        self.proto = proto
        self.id = id
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoCallMessageBusy {
        let proto = try SignalServiceProtos_CallMessage.Busy(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_CallMessage.Busy) throws -> SSKProtoCallMessageBusy {
        guard proto.hasID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: id")
        }
        let id = proto.id

        // MARK: - Begin Validation Logic for SSKProtoCallMessageBusy -

        // MARK: - End Validation Logic for SSKProtoCallMessageBusy -

        let result = SSKProtoCallMessageBusy(proto: proto,
                                             id: id)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoCallMessageBusy {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoCallMessageBusy.SSKProtoCallMessageBusyBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoCallMessageBusy? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoCallMessageHangup

@objc public class SSKProtoCallMessageHangup: NSObject {

    // MARK: - SSKProtoCallMessageHangupBuilder

    @objc public class func builder(id: UInt64) -> SSKProtoCallMessageHangupBuilder {
        return SSKProtoCallMessageHangupBuilder(id: id)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoCallMessageHangupBuilder {
        let builder = SSKProtoCallMessageHangupBuilder(id: id)
        return builder
    }

    @objc public class SSKProtoCallMessageHangupBuilder: NSObject {

        private var proto = SignalServiceProtos_CallMessage.Hangup()

        @objc fileprivate override init() {}

        @objc fileprivate init(id: UInt64) {
            super.init()

            setId(id)
        }

        @objc
        public func setId(_ valueParam: UInt64) {
            proto.id = valueParam
        }

        @objc public func build() throws -> SSKProtoCallMessageHangup {
            return try SSKProtoCallMessageHangup.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoCallMessageHangup.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_CallMessage.Hangup

    @objc public let id: UInt64

    private init(proto: SignalServiceProtos_CallMessage.Hangup,
                 id: UInt64) {
        self.proto = proto
        self.id = id
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoCallMessageHangup {
        let proto = try SignalServiceProtos_CallMessage.Hangup(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_CallMessage.Hangup) throws -> SSKProtoCallMessageHangup {
        guard proto.hasID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: id")
        }
        let id = proto.id

        // MARK: - Begin Validation Logic for SSKProtoCallMessageHangup -

        // MARK: - End Validation Logic for SSKProtoCallMessageHangup -

        let result = SSKProtoCallMessageHangup(proto: proto,
                                               id: id)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoCallMessageHangup {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoCallMessageHangup.SSKProtoCallMessageHangupBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoCallMessageHangup? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoCallMessage

@objc public class SSKProtoCallMessage: NSObject {

    // MARK: - SSKProtoCallMessageBuilder

    @objc public class func builder() -> SSKProtoCallMessageBuilder {
        return SSKProtoCallMessageBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoCallMessageBuilder {
        let builder = SSKProtoCallMessageBuilder()
        if let _value = offer {
            builder.setOffer(_value)
        }
        if let _value = answer {
            builder.setAnswer(_value)
        }
        builder.setIceUpdate(iceUpdate)
        if let _value = hangup {
            builder.setHangup(_value)
        }
        if let _value = busy {
            builder.setBusy(_value)
        }
        if let _value = profileKey {
            builder.setProfileKey(_value)
        }
        return builder
    }

    @objc public class SSKProtoCallMessageBuilder: NSObject {

        private var proto = SignalServiceProtos_CallMessage()

        @objc fileprivate override init() {}

        @objc
        @available(swift, obsoleted: 1.0)
        public func setOffer(_ valueParam: SSKProtoCallMessageOffer?) {
            guard let valueParam = valueParam else { return }
            proto.offer = valueParam.proto
        }

        public func setOffer(_ valueParam: SSKProtoCallMessageOffer) {
            proto.offer = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setAnswer(_ valueParam: SSKProtoCallMessageAnswer?) {
            guard let valueParam = valueParam else { return }
            proto.answer = valueParam.proto
        }

        public func setAnswer(_ valueParam: SSKProtoCallMessageAnswer) {
            proto.answer = valueParam.proto
        }

        @objc public func addIceUpdate(_ valueParam: SSKProtoCallMessageIceUpdate) {
            var items = proto.iceUpdate
            items.append(valueParam.proto)
            proto.iceUpdate = items
        }

        @objc public func setIceUpdate(_ wrappedItems: [SSKProtoCallMessageIceUpdate]) {
            proto.iceUpdate = wrappedItems.map { $0.proto }
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setHangup(_ valueParam: SSKProtoCallMessageHangup?) {
            guard let valueParam = valueParam else { return }
            proto.hangup = valueParam.proto
        }

        public func setHangup(_ valueParam: SSKProtoCallMessageHangup) {
            proto.hangup = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setBusy(_ valueParam: SSKProtoCallMessageBusy?) {
            guard let valueParam = valueParam else { return }
            proto.busy = valueParam.proto
        }

        public func setBusy(_ valueParam: SSKProtoCallMessageBusy) {
            proto.busy = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setProfileKey(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.profileKey = valueParam
        }

        public func setProfileKey(_ valueParam: Data) {
            proto.profileKey = valueParam
        }

        @objc public func build() throws -> SSKProtoCallMessage {
            return try SSKProtoCallMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoCallMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_CallMessage

    @objc public let offer: SSKProtoCallMessageOffer?

    @objc public let answer: SSKProtoCallMessageAnswer?

    @objc public let iceUpdate: [SSKProtoCallMessageIceUpdate]

    @objc public let hangup: SSKProtoCallMessageHangup?

    @objc public let busy: SSKProtoCallMessageBusy?

    @objc public var profileKey: Data? {
        guard proto.hasProfileKey else {
            return nil
        }
        return proto.profileKey
    }
    @objc public var hasProfileKey: Bool {
        return proto.hasProfileKey
    }

    private init(proto: SignalServiceProtos_CallMessage,
                 offer: SSKProtoCallMessageOffer?,
                 answer: SSKProtoCallMessageAnswer?,
                 iceUpdate: [SSKProtoCallMessageIceUpdate],
                 hangup: SSKProtoCallMessageHangup?,
                 busy: SSKProtoCallMessageBusy?) {
        self.proto = proto
        self.offer = offer
        self.answer = answer
        self.iceUpdate = iceUpdate
        self.hangup = hangup
        self.busy = busy
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoCallMessage {
        let proto = try SignalServiceProtos_CallMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_CallMessage) throws -> SSKProtoCallMessage {
        var offer: SSKProtoCallMessageOffer? = nil
        if proto.hasOffer {
            offer = try SSKProtoCallMessageOffer.parseProto(proto.offer)
        }

        var answer: SSKProtoCallMessageAnswer? = nil
        if proto.hasAnswer {
            answer = try SSKProtoCallMessageAnswer.parseProto(proto.answer)
        }

        var iceUpdate: [SSKProtoCallMessageIceUpdate] = []
        iceUpdate = try proto.iceUpdate.map { try SSKProtoCallMessageIceUpdate.parseProto($0) }

        var hangup: SSKProtoCallMessageHangup? = nil
        if proto.hasHangup {
            hangup = try SSKProtoCallMessageHangup.parseProto(proto.hangup)
        }

        var busy: SSKProtoCallMessageBusy? = nil
        if proto.hasBusy {
            busy = try SSKProtoCallMessageBusy.parseProto(proto.busy)
        }

        // MARK: - Begin Validation Logic for SSKProtoCallMessage -

        // MARK: - End Validation Logic for SSKProtoCallMessage -

        let result = SSKProtoCallMessage(proto: proto,
                                         offer: offer,
                                         answer: answer,
                                         iceUpdate: iceUpdate,
                                         hangup: hangup,
                                         busy: busy)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoCallMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoCallMessage.SSKProtoCallMessageBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoCallMessage? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoDataMessageQuoteQuotedAttachment

@objc public class SSKProtoDataMessageQuoteQuotedAttachment: NSObject {

    // MARK: - SSKProtoDataMessageQuoteQuotedAttachmentBuilder

    @objc public class func builder() -> SSKProtoDataMessageQuoteQuotedAttachmentBuilder {
        return SSKProtoDataMessageQuoteQuotedAttachmentBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoDataMessageQuoteQuotedAttachmentBuilder {
        let builder = SSKProtoDataMessageQuoteQuotedAttachmentBuilder()
        if let _value = contentType {
            builder.setContentType(_value)
        }
        if let _value = fileName {
            builder.setFileName(_value)
        }
        if let _value = thumbnail {
            builder.setThumbnail(_value)
        }
        return builder
    }

    @objc public class SSKProtoDataMessageQuoteQuotedAttachmentBuilder: NSObject {

        private var proto = SignalServiceProtos_DataMessage.Quote.QuotedAttachment()

        @objc fileprivate override init() {}

        @objc
        @available(swift, obsoleted: 1.0)
        public func setContentType(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.contentType = valueParam
        }

        public func setContentType(_ valueParam: String) {
            proto.contentType = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setFileName(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.fileName = valueParam
        }

        public func setFileName(_ valueParam: String) {
            proto.fileName = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setThumbnail(_ valueParam: SSKProtoAttachmentPointer?) {
            guard let valueParam = valueParam else { return }
            proto.thumbnail = valueParam.proto
        }

        public func setThumbnail(_ valueParam: SSKProtoAttachmentPointer) {
            proto.thumbnail = valueParam.proto
        }


        @objc public func build() throws -> SSKProtoDataMessageQuoteQuotedAttachment {
            return try SSKProtoDataMessageQuoteQuotedAttachment.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoDataMessageQuoteQuotedAttachment.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_DataMessage.Quote.QuotedAttachment

    @objc public let thumbnail: SSKProtoAttachmentPointer?

    @objc public var contentType: String? {
        guard proto.hasContentType else {
            return nil
        }
        return proto.contentType
    }
    @objc public var hasContentType: Bool {
        return proto.hasContentType
    }

    @objc public var fileName: String? {
        guard proto.hasFileName else {
            return nil
        }
        return proto.fileName
    }
    @objc public var hasFileName: Bool {
        return proto.hasFileName
    }

  

    private init(proto: SignalServiceProtos_DataMessage.Quote.QuotedAttachment,
                 thumbnail: SSKProtoAttachmentPointer?) {
        self.proto = proto
        self.thumbnail = thumbnail
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoDataMessageQuoteQuotedAttachment {
        let proto = try SignalServiceProtos_DataMessage.Quote.QuotedAttachment(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_DataMessage.Quote.QuotedAttachment) throws -> SSKProtoDataMessageQuoteQuotedAttachment {
        var thumbnail: SSKProtoAttachmentPointer? = nil
        if proto.hasThumbnail {
            thumbnail = try SSKProtoAttachmentPointer.parseProto(proto.thumbnail)
        }

        // MARK: - Begin Validation Logic for SSKProtoDataMessageQuoteQuotedAttachment -

        // MARK: - End Validation Logic for SSKProtoDataMessageQuoteQuotedAttachment -

        let result = SSKProtoDataMessageQuoteQuotedAttachment(proto: proto,
                                                              thumbnail: thumbnail)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoDataMessageQuoteQuotedAttachment {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoDataMessageQuoteQuotedAttachment.SSKProtoDataMessageQuoteQuotedAttachmentBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoDataMessageQuoteQuotedAttachment? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoDataMessageQuote

@objc public class SSKProtoDataMessageQuote: NSObject {

    // MARK: - SSKProtoDataMessageQuoteBuilder

    @objc public class func builder(id: UInt64) -> SSKProtoDataMessageQuoteBuilder {
        return SSKProtoDataMessageQuoteBuilder(id: id)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoDataMessageQuoteBuilder {
        let builder = SSKProtoDataMessageQuoteBuilder(id: id)
        if let _value = author {
            builder.setAuthor(_value)
        }
        
        if let _value = text {
            builder.setText(_value)
        }
        builder.setAttachments(attachments)
        return builder
    }

    @objc public class SSKProtoDataMessageQuoteBuilder: NSObject {

        private var proto = SignalServiceProtos_DataMessage.Quote()

        @objc fileprivate override init() {}

        @objc fileprivate init(id: UInt64) {
            super.init()

            setId(id)
        }

        @objc
        public func setId(_ valueParam: UInt64) {
            proto.id = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setAuthor(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.author = valueParam
        }

        public func setAuthor(_ valueParam: String) {
            proto.author = valueParam
        }


        @objc
        @available(swift, obsoleted: 1.0)
        public func setText(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.text = valueParam
        }

        public func setText(_ valueParam: String) {
            proto.text = valueParam
        }

        @objc public func addAttachments(_ valueParam: SSKProtoDataMessageQuoteQuotedAttachment) {
            var items = proto.attachments
            items.append(valueParam.proto)
            proto.attachments = items
        }

        @objc public func setAttachments(_ wrappedItems: [SSKProtoDataMessageQuoteQuotedAttachment]) {
            proto.attachments = wrappedItems.map { $0.proto }
        }

        @objc public func build() throws -> SSKProtoDataMessageQuote {
            return try SSKProtoDataMessageQuote.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoDataMessageQuote.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_DataMessage.Quote

    @objc public let id: UInt64

    @objc public let attachments: [SSKProtoDataMessageQuoteQuotedAttachment]

    @objc public var author: String? {
        guard proto.hasAuthor else {
            return nil
        }
        return proto.author
    }
    @objc public var hasAuthor: Bool {
        return proto.hasAuthor
    }

    @objc public var text: String? {
        guard proto.hasText else {
            return nil
        }
        return proto.text
    }
    @objc public var hasText: Bool {
        return proto.hasText
    }

    @objc public var hasValidAuthor: Bool {
        return authorAddress != nil
    }
    @objc public var authorAddress: SignalServiceAddress? {
        guard hasAuthor else { return nil }


        let uuid: String? = {
//            guard hasAuthor else {
//                // Shouldn’t happen in prod yet
//                assert(FeatureFlags.allowUUIDOnlyContacts)
//                return nil
//            }

            guard let author = author else {
                owsFailDebug("authorE164 was unexpectedly nil")
                return nil
            }

            guard !author.isEmpty else {
                owsFailDebug("authorE164 was unexpectedly empty")
                return nil
            }

            return author
        }()

        let address = SignalServiceAddress(phoneNumber: uuid!);
        guard address.isValid else {
            owsFailDebug("address was unexpectedly invalid")
            return nil
        }

        return address
    }

    private init(proto: SignalServiceProtos_DataMessage.Quote,
                 id: UInt64,
                 attachments: [SSKProtoDataMessageQuoteQuotedAttachment]) {
        self.proto = proto
        self.id = id
        self.attachments = attachments
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoDataMessageQuote {
        let proto = try SignalServiceProtos_DataMessage.Quote(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_DataMessage.Quote) throws -> SSKProtoDataMessageQuote {
        guard proto.hasID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: id")
        }
        let id = proto.id

        var attachments: [SSKProtoDataMessageQuoteQuotedAttachment] = []
        attachments = try proto.attachments.map { try SSKProtoDataMessageQuoteQuotedAttachment.parseProto($0) }

        // MARK: - Begin Validation Logic for SSKProtoDataMessageQuote -

        // MARK: - End Validation Logic for SSKProtoDataMessageQuote -

        let result = SSKProtoDataMessageQuote(proto: proto,
                                              id: id,
                                              attachments: attachments)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoDataMessageQuote {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoDataMessageQuote.SSKProtoDataMessageQuoteBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoDataMessageQuote? {
        return try! self.build()
    }
}

#endif



// MARK: - SSKProtoDataMessagePreview

@objc public class SSKProtoDataMessagePreview: NSObject {

    // MARK: - SSKProtoDataMessagePreviewBuilder

    @objc public class func builder(url: String) -> SSKProtoDataMessagePreviewBuilder {
        return SSKProtoDataMessagePreviewBuilder(url: url)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoDataMessagePreviewBuilder {
        let builder = SSKProtoDataMessagePreviewBuilder(url: url)
        if let _value = title {
            builder.setTitle(_value)
        }
        if let _value = image {
            builder.setImage(_value)
        }
        return builder
    }

    @objc public class SSKProtoDataMessagePreviewBuilder: NSObject {

        private var proto = SignalServiceProtos_DataMessage.Preview()

        @objc fileprivate override init() {}

        @objc fileprivate init(url: String) {
            super.init()

            setUrl(url)
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setUrl(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.url = valueParam
        }

        public func setUrl(_ valueParam: String) {
            proto.url = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setTitle(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.title = valueParam
        }

        public func setTitle(_ valueParam: String) {
            proto.title = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setImage(_ valueParam: SSKProtoAttachmentPointer?) {
            guard let valueParam = valueParam else { return }
            proto.image = valueParam.proto
        }

        public func setImage(_ valueParam: SSKProtoAttachmentPointer) {
            proto.image = valueParam.proto
        }

        @objc public func build() throws -> SSKProtoDataMessagePreview {
            return try SSKProtoDataMessagePreview.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoDataMessagePreview.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_DataMessage.Preview

    @objc public let url: String

    @objc public let image: SSKProtoAttachmentPointer?

    @objc public var title: String? {
        guard proto.hasTitle else {
            return nil
        }
        return proto.title
    }
    @objc public var hasTitle: Bool {
        return proto.hasTitle
    }

    private init(proto: SignalServiceProtos_DataMessage.Preview,
                 url: String,
                 image: SSKProtoAttachmentPointer?) {
        self.proto = proto
        self.url = url
        self.image = image
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoDataMessagePreview {
        let proto = try SignalServiceProtos_DataMessage.Preview(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_DataMessage.Preview) throws -> SSKProtoDataMessagePreview {
        guard proto.hasURL else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: url")
        }
        let url = proto.url

        var image: SSKProtoAttachmentPointer? = nil
        if proto.hasImage {
            image = try SSKProtoAttachmentPointer.parseProto(proto.image)
        }

        // MARK: - Begin Validation Logic for SSKProtoDataMessagePreview -

        // MARK: - End Validation Logic for SSKProtoDataMessagePreview -

        let result = SSKProtoDataMessagePreview(proto: proto,
                                                url: url,
                                                image: image)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoDataMessagePreview {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoDataMessagePreview.SSKProtoDataMessagePreviewBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoDataMessagePreview? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoDataMessageSticker

@objc public class SSKProtoDataMessageSticker: NSObject {

    // MARK: - SSKProtoDataMessageStickerBuilder

    @objc public class func builder(packID: Data, packKey: Data, stickerID: UInt32, data: SSKProtoAttachmentPointer) -> SSKProtoDataMessageStickerBuilder {
        return SSKProtoDataMessageStickerBuilder(packID: packID, packKey: packKey, stickerID: stickerID, data: data)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoDataMessageStickerBuilder {
        let builder = SSKProtoDataMessageStickerBuilder(packID: packID, packKey: packKey, stickerID: stickerID, data: data)
        return builder
    }

    @objc public class SSKProtoDataMessageStickerBuilder: NSObject {

        private var proto = SignalServiceProtos_DataMessage.Sticker()

        @objc fileprivate override init() {}

        @objc fileprivate init(packID: Data, packKey: Data, stickerID: UInt32, data: SSKProtoAttachmentPointer) {
            super.init()

            setPackID(packID)
            setPackKey(packKey)
            setStickerID(stickerID)
            setData(data)
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setPackID(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.packID = valueParam
        }

        public func setPackID(_ valueParam: Data) {
            proto.packID = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setPackKey(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.packKey = valueParam
        }

        public func setPackKey(_ valueParam: Data) {
            proto.packKey = valueParam
        }

        @objc
        public func setStickerID(_ valueParam: UInt32) {
            proto.stickerID = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setData(_ valueParam: SSKProtoAttachmentPointer?) {
            guard let valueParam = valueParam else { return }
            proto.data = valueParam.proto
        }

        public func setData(_ valueParam: SSKProtoAttachmentPointer) {
            proto.data = valueParam.proto
        }

        @objc public func build() throws -> SSKProtoDataMessageSticker {
            return try SSKProtoDataMessageSticker.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoDataMessageSticker.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_DataMessage.Sticker

    @objc public let packID: Data

    @objc public let packKey: Data

    @objc public let stickerID: UInt32

    @objc public let data: SSKProtoAttachmentPointer

    private init(proto: SignalServiceProtos_DataMessage.Sticker,
                 packID: Data,
                 packKey: Data,
                 stickerID: UInt32,
                 data: SSKProtoAttachmentPointer) {
        self.proto = proto
        self.packID = packID
        self.packKey = packKey
        self.stickerID = stickerID
        self.data = data
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoDataMessageSticker {
        let proto = try SignalServiceProtos_DataMessage.Sticker(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_DataMessage.Sticker) throws -> SSKProtoDataMessageSticker {
        guard proto.hasPackID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: packID")
        }
        let packID = proto.packID

        guard proto.hasPackKey else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: packKey")
        }
        let packKey = proto.packKey

        guard proto.hasStickerID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: stickerID")
        }
        let stickerID = proto.stickerID

        guard proto.hasData else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: data")
        }
        let data = try SSKProtoAttachmentPointer.parseProto(proto.data)

        // MARK: - Begin Validation Logic for SSKProtoDataMessageSticker -

        // MARK: - End Validation Logic for SSKProtoDataMessageSticker -

        let result = SSKProtoDataMessageSticker(proto: proto,
                                                packID: packID,
                                                packKey: packKey,
                                                stickerID: stickerID,
                                                data: data)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoDataMessageSticker {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoDataMessageSticker.SSKProtoDataMessageStickerBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoDataMessageSticker? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoDataMessage

@objc public class SSKProtoDataMessage: NSObject {

    // MARK: - SSKProtoDataMessageFlags

    @objc public enum SSKProtoDataMessageFlags: Int32 {
        case expirationTimerUpdate = 1
    }
    
    @objc public enum SSKProtoDataMessageMessageType: Int32 {
        case unknown = 0;
        case text = 1;
        case picture = 2;
        case card = 3;
        case voice = 4;
        case video = 5;
        case file = 6;
    }

    private class func SSKProtoDataMessageFlagsWrap(_ value: SignalServiceProtos_DataMessage.Flags) -> SSKProtoDataMessageFlags {
       
        switch value {
        case .expirationTimerUpdate: return .expirationTimerUpdate
        default:
            return .expirationTimerUpdate
            break

        }
    }

    private class func SSKProtoDataMessageFlagsUnwrap(_ value: SSKProtoDataMessageFlags) -> SignalServiceProtos_DataMessage.Flags {
        
        switch value {
               case .expirationTimerUpdate: return .expirationTimerUpdate
               }
       
    }
    
//    private class func SSKProtoDataMessageMessageTypeWrap(_ value: SignalServiceProtos_DataMessage.MessageType) -> SSKProtoDataMessageMessageType {
//        return SSKProtoDataMessageMessageType.init(rawValue: Int32(value.rawValue)) ?? .unknown;
//
//    }

//    private class func SSKProtoDataMessageMessageTypeUnwrap(_ value: SSKProtoDataMessageMessageType) -> SignalServiceProtos_DataMessage.MessageType {
//        return SignalServiceProtos_DataMessage.MessageType.init(rawValue: Int(value.rawValue)) ?? .unknown;
//    }

    // MARK: - SSKProtoDataMessageProtocolVersion

    @objc public enum SSKProtoDataMessageProtocolVersion: Int32 {
        case initial = 0
    }

    private class func SSKProtoDataMessageProtocolVersionWrap(_ value: SignalServiceProtos_DataMessage.ProtocolVersion) -> SSKProtoDataMessageProtocolVersion {
        switch value {
        case .initial: return .initial
        default : return .initial
        }
    }

    private class func SSKProtoDataMessageProtocolVersionUnwrap(_ value: SSKProtoDataMessageProtocolVersion) -> SignalServiceProtos_DataMessage.ProtocolVersion {
        switch value {
        case .initial: return .initial
        default : return .initial
        }
    }

    // MARK: - SSKProtoDataMessageBuilder

    @objc public class func builder() -> SSKProtoDataMessageBuilder {
        return SSKProtoDataMessageBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoDataMessageBuilder {
        let builder = SSKProtoDataMessageBuilder()
        if let _value = body {
            builder.setBody(_value)
        }
        builder.setAttachments(attachments)
        
        if hasFlags {
            builder.setFlags(flags)
        }
        if hasExpireTimer {
            builder.setExpireTimer(expireTimer)
        }
        
        if hasTimestamp {
            builder.setTimestamp(timestamp)
        }
        if let _value = quote {
            builder.setQuote(_value)
        }
        builder.setPreview(preview)
        if let _value = sticker {
            builder.setSticker(_value)
        }
        if hasRequiredProtocolVersion {
            builder.setRequiredProtocolVersion(requiredProtocolVersion)
        }
        if hasIsViewOnce {
            builder.setIsViewOnce(isViewOnce)
        }
        
        if let _value = shareMessage {
            builder.setShareMessage(_value);
        }
        
        if let _value = self.mentions {
            builder.setMentions(_value);
        }
        
        
        return builder
    }

    @objc public class SSKProtoDataMessageBuilder: NSObject {

        private var proto = SignalServiceProtos_DataMessage()

        @objc fileprivate override init() {}

        @objc
        @available(swift, obsoleted: 1.0)
        public func setBody(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.body = valueParam
        }

        public func setBody(_ valueParam: String) {
           
            proto.body = valueParam
        }

        @objc public func addAttachments(_ valueParam: SSKProtoAttachmentPointer) {
            var items = proto.attachments
            items.append(valueParam.proto)
            
            proto.attachments = items
        }

        @objc public func setAttachments(_ wrappedItems: [SSKProtoAttachmentPointer]) {
          
            proto.attachments = wrappedItems.map({ (attchment) -> SignalServiceProtos_AttachmentPointer in
                
                return attchment.proto
            });
        }

        @objc
        public func setFlags(_ valueParam: UInt32) {
            proto.flags = valueParam
        }

        @objc
        public func setExpireTimer(_ valueParam: UInt32) {
            proto.expireTimer = valueParam
        }

        @objc
        public func setTimestamp(_ valueParam: UInt64) {
            proto.timestamp = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setQuote(_ valueParam: SSKProtoDataMessageQuote?) {
            guard let valueParam = valueParam else { return }
            proto.quote = valueParam.proto
        }

        public func setQuote(_ valueParam: SSKProtoDataMessageQuote) {
            proto.quote = valueParam.proto
        }

        @objc public func addPreview(_ valueParam: SSKProtoDataMessagePreview) {
            var items = proto.preview
            items.append(valueParam.proto)
            proto.preview = items
        }

        @objc public func setPreview(_ wrappedItems: [SSKProtoDataMessagePreview]) {
            proto.preview = wrappedItems.map { $0.proto }
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setSticker(_ valueParam: SSKProtoDataMessageSticker?) {
            guard let valueParam = valueParam else { return }
            proto.sticker = valueParam.proto
        }

        public func setSticker(_ valueParam: SSKProtoDataMessageSticker) {
            proto.sticker = valueParam.proto
        }

        @objc
        public func setRequiredProtocolVersion(_ valueParam: UInt32) {
            proto.requiredProtocolVersion = valueParam
        }

        @objc
        public func setIsViewOnce(_ valueParam: Bool) {
            proto.isViewOnce = valueParam
        }

        @objc
        public func setShareMessage(_ valueParam: SSKProtoShareMessage?) {
            guard let valueParam = valueParam else { return }
            
            proto.shareMessage = valueParam.proto;
        }
        
        @objc
        public func setMentions(_ valueParam: [SSKProtoUserEntiy]?) {
            
            guard let valueParam = valueParam else {
                return
            }
            proto.mentioned = valueParam.map({ (entity) -> SignalServiceProtos_UserEntity in
                return entity.proto;
            });
        }
        
        @objc public func build() throws -> SSKProtoDataMessage {
            return try SSKProtoDataMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoDataMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_DataMessage

    @objc public let attachments: [SSKProtoAttachmentPointer]

    @objc public let quote: SSKProtoDataMessageQuote?

    @objc public let preview: [SSKProtoDataMessagePreview]

    @objc public let sticker: SSKProtoDataMessageSticker?
    
    @objc public let shareMessage: SSKProtoShareMessage?
    
    @objc public let mentions: [SSKProtoUserEntiy]?
    
    @objc public var body: String? {
        guard proto.hasBody else {
            return nil
        }
        return proto.body
    }
    @objc public var hasBody: Bool {
        return proto.hasBody
    }

    @objc public var flags: UInt32 {
        return proto.flags
    }
    @objc public var hasFlags: Bool {
        return proto.hasFlags
    }

    @objc public var expireTimer: UInt32 {
        return proto.expireTimer
    }
    @objc public var hasExpireTimer: Bool {
        return proto.hasExpireTimer
    }


    @objc public var timestamp: UInt64 {
        return proto.timestamp
    }
    @objc public var hasTimestamp: Bool {
        return proto.hasTimestamp
    }

    @objc public var requiredProtocolVersion: UInt32 {
        return proto.requiredProtocolVersion
    }
    @objc public var hasRequiredProtocolVersion: Bool {
        return proto.hasRequiredProtocolVersion
    }

    @objc public var isViewOnce: Bool {
        return proto.isViewOnce
    }
    @objc public var hasIsViewOnce: Bool {
        return proto.hasIsViewOnce
    }

    private init(proto: SignalServiceProtos_DataMessage,
                 attachments: [SSKProtoAttachmentPointer],
                 quote: SSKProtoDataMessageQuote?,
                 preview: [SSKProtoDataMessagePreview],
                 sticker: SSKProtoDataMessageSticker?,shareMessage: SSKProtoShareMessage?, mentions:[SSKProtoUserEntiy]?) {
        self.proto = proto
        self.attachments = attachments
        self.quote = quote
        self.preview = preview
        self.sticker = sticker
        self.shareMessage = shareMessage;
        self.mentions = mentions;
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoDataMessage {
        let proto = try SignalServiceProtos_DataMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_DataMessage) throws -> SSKProtoDataMessage {
        var attachments: [SSKProtoAttachmentPointer] = []
        attachments = try proto.attachments.map { try SSKProtoAttachmentPointer.parseProto($0) }

      

        var quote: SSKProtoDataMessageQuote? = nil
        if proto.hasQuote {
            quote = try SSKProtoDataMessageQuote.parseProto(proto.quote)
        }

       

        var preview: [SSKProtoDataMessagePreview] = []
        preview = try proto.preview.map { try SSKProtoDataMessagePreview.parseProto($0) }

        var sticker: SSKProtoDataMessageSticker? = nil
        if proto.hasSticker {
            sticker = try SSKProtoDataMessageSticker.parseProto(proto.sticker)
        }
        
        
        var share: SSKProtoShareMessage? = nil
        if proto.hasShareMessage {
            share = try SSKProtoShareMessage.parseProto(proto.shareMessage);
        }
        
        var mentions: [SSKProtoUserEntiy]? = nil
        if proto.mentioned.count > 0 {
            mentions = try proto.mentioned.map({ (_mention) -> SSKProtoUserEntiy in
               return try SSKProtoUserEntiy.parseProto(_mention);
            })
        }
        // MARK: - Begin Validation Logic for SSKProtoDataMessage -

        // MARK: - End Validation Logic for SSKProtoDataMessage -

        let result = SSKProtoDataMessage(proto: proto,
                                         attachments: attachments,
                                         quote: quote,
                                         preview: preview,
                                         sticker: sticker, shareMessage: share,mentions:mentions );
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoDataMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoDataMessage.SSKProtoDataMessageBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoDataMessage? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoNullMessage

@objc public class SSKProtoNullMessage: NSObject {

    // MARK: - SSKProtoNullMessageBuilder

    @objc public class func builder() -> SSKProtoNullMessageBuilder {
        return SSKProtoNullMessageBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoNullMessageBuilder {
        let builder = SSKProtoNullMessageBuilder()
        if let _value = padding {
            builder.setPadding(_value)
        }
        return builder
    }

    @objc public class SSKProtoNullMessageBuilder: NSObject {

        private var proto = SignalServiceProtos_NullMessage()

        @objc fileprivate override init() {}

        @objc
        @available(swift, obsoleted: 1.0)
        public func setPadding(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.padding = valueParam
        }

        public func setPadding(_ valueParam: Data) {
            proto.padding = valueParam
        }

        @objc public func build() throws -> SSKProtoNullMessage {
            return try SSKProtoNullMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoNullMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_NullMessage

    @objc public var padding: Data? {
        guard proto.hasPadding else {
            return nil
        }
        return proto.padding
    }
    @objc public var hasPadding: Bool {
        return proto.hasPadding
    }

    private init(proto: SignalServiceProtos_NullMessage) {
        self.proto = proto
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoNullMessage {
        let proto = try SignalServiceProtos_NullMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_NullMessage) throws -> SSKProtoNullMessage {
        // MARK: - Begin Validation Logic for SSKProtoNullMessage -

        // MARK: - End Validation Logic for SSKProtoNullMessage -

        let result = SSKProtoNullMessage(proto: proto)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoNullMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoNullMessage.SSKProtoNullMessageBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoNullMessage? {
        return try! self.build()
    }
}

#endif


// MARK: - SSKProtoReceiptMessage

@objc public class SSKProtoReceiptMessage: NSObject {

    // MARK: - SSKProtoReceiptMessageType

    @objc public enum SSKProtoReceiptMessageType: Int32 {
        case delivery = 0
        case read = 1
        case failed_not_friend = 2;
        case failed_no_permission = 3;
    }

    private class func SSKProtoReceiptMessageTypeWrap(_ value: SignalServiceProtos_ReceiptMessage.TypeEnum) -> SSKProtoReceiptMessageType {
        switch value {
        case .delivery: return .delivery
        case .read: return .read
        case .failedByNotFriends: return .failed_not_friend;
        case .failedByNoPermission: return .failed_no_permission;
        }
    }

    private class func SSKProtoReceiptMessageTypeUnwrap(_ value: SSKProtoReceiptMessageType) -> SignalServiceProtos_ReceiptMessage.TypeEnum {
        switch value {
        case .delivery: return .delivery
        case .read: return .read
        case .failed_not_friend: return .failedByNotFriends;
        case .failed_no_permission: return .failedByNoPermission;
        }
    }


    // MARK: - SSKProtoReceiptMessageBuilder

    @objc public class func builder() -> SSKProtoReceiptMessageBuilder {
        return SSKProtoReceiptMessageBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoReceiptMessageBuilder {
        let builder = SSKProtoReceiptMessageBuilder()
        if let _value = type {
            builder.setType(_value)
        }
        builder.setTimestamp(timestamp)
        return builder
    }

    @objc public class SSKProtoReceiptMessageBuilder: NSObject {

        private var proto = SignalServiceProtos_ReceiptMessage()

        @objc fileprivate override init() {}

        @objc
        public func setType(_ valueParam: SSKProtoReceiptMessageType) {
            proto.type = SSKProtoReceiptMessageTypeUnwrap(valueParam)
        }

        @objc public func addTimestamp(_ valueParam: UInt64) {
            var items = proto.timestamp
            items.append(valueParam)
            proto.timestamp = items
        }

        @objc public func setTimestamp(_ wrappedItems: [UInt64]) {
            proto.timestamp = wrappedItems
        }

        @objc public func build() throws -> SSKProtoReceiptMessage {
            return try SSKProtoReceiptMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoReceiptMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_ReceiptMessage

    public var type: SSKProtoReceiptMessageType? {
        guard proto.hasType else {
            return nil
        }
        return SSKProtoReceiptMessage.SSKProtoReceiptMessageTypeWrap(proto.type)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    @objc public var unwrappedType: SSKProtoReceiptMessageType {
        if !hasType {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: ReceiptMessage.type.")
        }
        return SSKProtoReceiptMessage.SSKProtoReceiptMessageTypeWrap(proto.type)
    }
    @objc public var hasType: Bool {
        return proto.hasType
    }

    @objc public var timestamp: [UInt64] {
        return proto.timestamp
    }

    private init(proto: SignalServiceProtos_ReceiptMessage) {
        self.proto = proto
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoReceiptMessage {
        let proto = try SignalServiceProtos_ReceiptMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_ReceiptMessage) throws -> SSKProtoReceiptMessage {
        // MARK: - Begin Validation Logic for SSKProtoReceiptMessage -

        // MARK: - End Validation Logic for SSKProtoReceiptMessage -

        let result = SSKProtoReceiptMessage(proto: proto)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoReceiptMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoReceiptMessage.SSKProtoReceiptMessageBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoReceiptMessage? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoVerified

@objc public class SSKProtoVerified: NSObject {

    // MARK: - SSKProtoVerifiedState

    @objc public enum SSKProtoVerifiedState: Int32 {
        case `default` = 0
        case verified = 1
        case unverified = 2
    }

    private class func SSKProtoVerifiedStateWrap(_ value: SignalServiceProtos_Verified.State) -> SSKProtoVerifiedState {
        switch value {
        case .default: return .default
        case .verified: return .verified
        case .unverified: return .unverified
        }
    }

    private class func SSKProtoVerifiedStateUnwrap(_ value: SSKProtoVerifiedState) -> SignalServiceProtos_Verified.State {
        switch value {
        case .default: return .default
        case .verified: return .verified
        case .unverified: return .unverified
        }
    }

    // MARK: - SSKProtoVerifiedBuilder

    @objc public class func builder() -> SSKProtoVerifiedBuilder {
        return SSKProtoVerifiedBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoVerifiedBuilder {
        let builder = SSKProtoVerifiedBuilder()
        if let _value = destination {
            builder.setDestination(_value)
        }
        
        if let _value = identityKey {
            builder.setIdentityKey(_value)
        }
        if let _value = state {
            builder.setState(_value)
        }
        if let _value = nullMessage {
            builder.setNullMessage(_value)
        }
        return builder
    }

    @objc public class SSKProtoVerifiedBuilder: NSObject {

        private var proto = SignalServiceProtos_Verified()

        @objc fileprivate override init() {}

        @objc
        @available(swift, obsoleted: 1.0)
        public func setDestination(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.destination = valueParam
        }

        public func setDestination(_ valueParam: String) {
            proto.destination = valueParam
        }


        @objc
        @available(swift, obsoleted: 1.0)
        public func setIdentityKey(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.identityKey = valueParam
        }

        public func setIdentityKey(_ valueParam: Data) {
            proto.identityKey = valueParam
        }

        @objc
        public func setState(_ valueParam: SSKProtoVerifiedState) {
            proto.state = SSKProtoVerifiedStateUnwrap(valueParam)
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setNullMessage(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.nullMessage = valueParam
        }

        public func setNullMessage(_ valueParam: Data) {
            proto.nullMessage = valueParam
        }

        @objc public func build() throws -> SSKProtoVerified {
            return try SSKProtoVerified.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoVerified.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_Verified

    @objc public var destination: String? {
        guard proto.hasDestination else {
            return nil
        }
        return proto.destination
    }
    @objc public var hasDestination: Bool {
        return proto.hasDestination
    }

    @objc public var identityKey: Data? {
        guard proto.hasIdentityKey else {
            return nil
        }
        return proto.identityKey
    }
    @objc public var hasIdentityKey: Bool {
        return proto.hasIdentityKey
    }

    public var state: SSKProtoVerifiedState? {
        guard proto.hasState else {
            return nil
        }
        return SSKProtoVerified.SSKProtoVerifiedStateWrap(proto.state)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    @objc public var unwrappedState: SSKProtoVerifiedState {
        if !hasState {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: Verified.state.")
        }
        return SSKProtoVerified.SSKProtoVerifiedStateWrap(proto.state)
    }
    @objc public var hasState: Bool {
        return proto.hasState
    }

    @objc public var nullMessage: Data? {
        guard proto.hasNullMessage else {
            return nil
        }
        return proto.nullMessage
    }
    @objc public var hasNullMessage: Bool {
        return proto.hasNullMessage
    }

    @objc public var hasValidDestination: Bool {
        return destinationAddress != nil
    }
    @objc public var destinationAddress: SignalServiceAddress? {
        guard hasDestination else { return nil }

        let uuidString: String? = {
            guard hasDestination else { return nil }

            guard let destinationUuid = destination else {
                owsFailDebug("destinationUuid was unexpectedly nil")
                return nil
            }

            return destinationUuid
        }()

        let address = SignalServiceAddress(phoneNumber: uuidString);
        guard address.isValid else {
            owsFailDebug("address was unexpectedly invalid")
            return nil
        }

        return address
    }

    private init(proto: SignalServiceProtos_Verified) {
        self.proto = proto
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoVerified {
        let proto = try SignalServiceProtos_Verified(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_Verified) throws -> SSKProtoVerified {
        // MARK: - Begin Validation Logic for SSKProtoVerified -

        // MARK: - End Validation Logic for SSKProtoVerified -

        let result = SSKProtoVerified(proto: proto)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoVerified {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoVerified.SSKProtoVerifiedBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoVerified? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoSyncMessageSent

@objc public class SSKProtoSyncMessageSent: NSObject {

    // MARK: - SSKProtoSyncMessageSentBuilder

    @objc public class func builder() -> SSKProtoSyncMessageSentBuilder {
        return SSKProtoSyncMessageSentBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoSyncMessageSentBuilder {
        let builder = SSKProtoSyncMessageSentBuilder()
        if let _value = destination {
            builder.setDestination(_value)
        }
        
        if hasTimestamp {
            builder.setTimestamp(timestamp)
        }
        if let _value = message {
            builder.setMessage(_value)
        }
        if hasExpirationStartTimestamp {
            builder.setExpirationStartTimestamp(expirationStartTimestamp)
        }
        if hasIsRecipientUpdate {
            builder.setIsRecipientUpdate(isRecipientUpdate)
        }
        if let _value = self.revokeMessage {
                   builder.setRevokeMessage(_value);
               }
        return builder
    }

    @objc public class SSKProtoSyncMessageSentBuilder: NSObject {

        private var proto = SignalServiceProtos_SyncMessage.Sent()

        @objc fileprivate override init() {}

        @objc
        @available(swift, obsoleted: 1.0)
        public func setDestination(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.destination = valueParam
        }

        public func setDestination(_ valueParam: String) {
            proto.destination = valueParam
        }

        @objc
        public func setTimestamp(_ valueParam: UInt64) {
            proto.timestamp = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setMessage(_ valueParam: SSKProtoDataMessage?) {
            guard let valueParam = valueParam else { return }
            proto.message = valueParam.proto
        }

        public func setMessage(_ valueParam: SSKProtoDataMessage) {
            proto.message = valueParam.proto
        }

        @objc
        public func setExpirationStartTimestamp(_ valueParam: UInt64) {
            proto.expirationStartTimestamp = valueParam
        }


        @objc
        public func setIsRecipientUpdate(_ valueParam: Bool) {
            proto.isRecipientUpdate = valueParam
        }
        
        @objc
        public func setRevokeMessage(_ valueParam: [SSKProtoRevokeMessage]?) {
            if let _value = valueParam {
                
                proto.revokeMessage = _value.map({ (message) -> SignalServiceProtos_RevokeMessage in
                    return message.proto;
                });
            }
        }

        @objc public func build() throws -> SSKProtoSyncMessageSent {
            return try SSKProtoSyncMessageSent.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoSyncMessageSent.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_SyncMessage.Sent

    @objc public let message: SSKProtoDataMessage?
    
    @objc public let revokeMessage: [SSKProtoRevokeMessage]?

    @objc public let revokeUserMessage: SSKProtoRevokeUserMessage?

    @objc public var destination: String? {
        guard proto.hasDestination else {
            return nil
        }
        return proto.destination
    }
    @objc public var hasDestination: Bool {
        return proto.hasDestination
    }

    @objc public var timestamp: UInt64 {
        return proto.timestamp
    }
    @objc public var hasTimestamp: Bool {
        return proto.hasTimestamp
    }

    @objc public var expirationStartTimestamp: UInt64 {
        return proto.expirationStartTimestamp
    }
    @objc public var hasExpirationStartTimestamp: Bool {
        return proto.hasExpirationStartTimestamp
    }

    @objc public var isRecipientUpdate: Bool {
        return proto.isRecipientUpdate
    }
    @objc public var hasIsRecipientUpdate: Bool {
        return proto.hasIsRecipientUpdate
    }

    @objc public var hasValidDestination: Bool {
        return destinationAddress != nil
    }
    @objc public var destinationAddress: SignalServiceAddress? {
        guard hasDestination else { return nil }

     

        let uuidString: String? = {
            guard hasDestination else {
                // Shouldn’t happen in prod yet
                assert(FeatureFlags.allowUUIDOnlyContacts)
                return nil
            }

            guard let destinationE164 = destination else {
                owsFailDebug("destinationE164 was unexpectedly nil")
                return nil
            }

            guard !destinationE164.isEmpty else {
                owsFailDebug("destinationE164 was unexpectedly empty")
                return nil
            }

            return destination
        }()

        let address = SignalServiceAddress.init(phoneNumber: uuidString);
        guard address.isValid else {
            owsFailDebug("address was unexpectedly invalid")
            return nil
        }

        return address
    }

    private init(proto: SignalServiceProtos_SyncMessage.Sent,
                 message: SSKProtoDataMessage?) {
        self.proto = proto
        self.message = message
        if proto.revokeMessage.count > 0 {
            self.revokeMessage = try? proto.revokeMessage.map({ (message) -> SSKProtoRevokeMessage in
                return try SSKProtoRevokeMessage.parseProto(message);
            });
        } else {
            self.revokeMessage = nil;
        }
        if proto.hasRevokeUserMessage {
            self.revokeUserMessage = try? SSKProtoRevokeUserMessage.parseProto(proto.revokeUserMessage);
        } else {
            self.revokeUserMessage = nil;
        }
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoSyncMessageSent {
        let proto = try SignalServiceProtos_SyncMessage.Sent(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_SyncMessage.Sent) throws -> SSKProtoSyncMessageSent {
        var message: SSKProtoDataMessage? = nil
        if proto.hasMessage {
            message = try SSKProtoDataMessage.parseProto(proto.message)
        }
        

        // MARK: - Begin Validation Logic for SSKProtoSyncMessageSent -

        // MARK: - End Validation Logic for SSKProtoSyncMessageSent -

        let result = SSKProtoSyncMessageSent(proto: proto,
                                             message: message)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoSyncMessageSent {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoSyncMessageSent.SSKProtoSyncMessageSentBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoSyncMessageSent? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoSyncMessageContacts

@objc public class SSKProtoSyncMessageContacts: NSObject {

    // MARK: - SSKProtoSyncMessageContactsBuilder

    @objc public class func builder(blob: SSKProtoAttachmentPointer) -> SSKProtoSyncMessageContactsBuilder {
        return SSKProtoSyncMessageContactsBuilder(blob: blob)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoSyncMessageContactsBuilder {
        let builder = SSKProtoSyncMessageContactsBuilder(blob: blob)
        if hasIsComplete {
            builder.setIsComplete(isComplete)
        }
        return builder
    }

    @objc public class SSKProtoSyncMessageContactsBuilder: NSObject {

        private var proto = SignalServiceProtos_SyncMessage.Contacts()

        @objc fileprivate override init() {}

        @objc fileprivate init(blob: SSKProtoAttachmentPointer) {
            super.init()

            setBlob(blob)
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setBlob(_ valueParam: SSKProtoAttachmentPointer?) {
            guard let valueParam = valueParam else { return }
            proto.blob = valueParam.proto
        }

        public func setBlob(_ valueParam: SSKProtoAttachmentPointer) {
            proto.blob = valueParam.proto
        }

        @objc
        public func setIsComplete(_ valueParam: Bool) {
            proto.isComplete = valueParam
        }

        @objc public func build() throws -> SSKProtoSyncMessageContacts {
            return try SSKProtoSyncMessageContacts.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoSyncMessageContacts.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_SyncMessage.Contacts

    @objc public let blob: SSKProtoAttachmentPointer

    @objc public var isComplete: Bool {
        return proto.isComplete
    }
    @objc public var hasIsComplete: Bool {
        return proto.hasIsComplete
    }

    private init(proto: SignalServiceProtos_SyncMessage.Contacts,
                 blob: SSKProtoAttachmentPointer) {
        self.proto = proto
        self.blob = blob
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoSyncMessageContacts {
        let proto = try SignalServiceProtos_SyncMessage.Contacts(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_SyncMessage.Contacts) throws -> SSKProtoSyncMessageContacts {
        guard proto.hasBlob else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: blob")
        }
        let blob = try SSKProtoAttachmentPointer.parseProto(proto.blob)

        // MARK: - Begin Validation Logic for SSKProtoSyncMessageContacts -

        // MARK: - End Validation Logic for SSKProtoSyncMessageContacts -

        let result = SSKProtoSyncMessageContacts(proto: proto,
                                                 blob: blob)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoSyncMessageContacts {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoSyncMessageContacts.SSKProtoSyncMessageContactsBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoSyncMessageContacts? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoSyncMessageGroups

@objc public class SSKProtoSyncMessageGroups: NSObject {

    // MARK: - SSKProtoSyncMessageGroupsBuilder

    @objc public class func builder() -> SSKProtoSyncMessageGroupsBuilder {
        return SSKProtoSyncMessageGroupsBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoSyncMessageGroupsBuilder {
        let builder = SSKProtoSyncMessageGroupsBuilder()
        if let _value = blob {
            builder.setBlob(_value)
        }
        return builder
    }

    @objc public class SSKProtoSyncMessageGroupsBuilder: NSObject {

        private var proto = SignalServiceProtos_SyncMessage.Groups()

        @objc fileprivate override init() {}

        @objc
        @available(swift, obsoleted: 1.0)
        public func setBlob(_ valueParam: SSKProtoAttachmentPointer?) {
            guard let valueParam = valueParam else { return }
            proto.blob = valueParam.proto
        }

        public func setBlob(_ valueParam: SSKProtoAttachmentPointer) {
            proto.blob = valueParam.proto
        }

        @objc public func build() throws -> SSKProtoSyncMessageGroups {
            return try SSKProtoSyncMessageGroups.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoSyncMessageGroups.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_SyncMessage.Groups

    @objc public let blob: SSKProtoAttachmentPointer?

    private init(proto: SignalServiceProtos_SyncMessage.Groups,
                 blob: SSKProtoAttachmentPointer?) {
        self.proto = proto
        self.blob = blob
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoSyncMessageGroups {
        let proto = try SignalServiceProtos_SyncMessage.Groups(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_SyncMessage.Groups) throws -> SSKProtoSyncMessageGroups {
        var blob: SSKProtoAttachmentPointer? = nil
        if proto.hasBlob {
            blob = try SSKProtoAttachmentPointer.parseProto(proto.blob)
        }

        // MARK: - Begin Validation Logic for SSKProtoSyncMessageGroups -

        // MARK: - End Validation Logic for SSKProtoSyncMessageGroups -

        let result = SSKProtoSyncMessageGroups(proto: proto,
                                               blob: blob)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoSyncMessageGroups {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoSyncMessageGroups.SSKProtoSyncMessageGroupsBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoSyncMessageGroups? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoSyncMessageBlocked

@objc public class SSKProtoSyncMessageBlocked: NSObject {

    // MARK: - SSKProtoSyncMessageBlockedBuilder

    @objc public class func builder() -> SSKProtoSyncMessageBlockedBuilder {
        return SSKProtoSyncMessageBlockedBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoSyncMessageBlockedBuilder {
        let builder = SSKProtoSyncMessageBlockedBuilder()
        builder.setNumbers(numbers)
        builder.setGroupIds(groupIds)
        return builder
    }

    @objc public class SSKProtoSyncMessageBlockedBuilder: NSObject {

        private var proto = SignalServiceProtos_SyncMessage.Blocked()

        @objc fileprivate override init() {}

        @objc public func addNumbers(_ valueParam: String) {
            var items = proto.numbers
            items.append(valueParam)
            proto.numbers = items
        }

        @objc public func setNumbers(_ wrappedItems: [String]) {
            proto.numbers = wrappedItems
        }

        @objc public func addGroupIds(_ valueParam: String) {
            var items = proto.groupIds
            items.append(valueParam)
            proto.groupIds = items
        }

        @objc public func setGroupIds(_ wrappedItems: [String]) {
            proto.groupIds = wrappedItems
        }


        @objc public func build() throws -> SSKProtoSyncMessageBlocked {
            return try SSKProtoSyncMessageBlocked.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoSyncMessageBlocked.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_SyncMessage.Blocked

    @objc public var numbers: [String] {
        return proto.numbers
    }

    @objc public var groupIds: [String] {
        return proto.groupIds
    }


    private init(proto: SignalServiceProtos_SyncMessage.Blocked) {
        self.proto = proto
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoSyncMessageBlocked {
        let proto = try SignalServiceProtos_SyncMessage.Blocked(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_SyncMessage.Blocked) throws -> SSKProtoSyncMessageBlocked {
        // MARK: - Begin Validation Logic for SSKProtoSyncMessageBlocked -

        // MARK: - End Validation Logic for SSKProtoSyncMessageBlocked -

        let result = SSKProtoSyncMessageBlocked(proto: proto)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoSyncMessageBlocked {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoSyncMessageBlocked.SSKProtoSyncMessageBlockedBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoSyncMessageBlocked? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoSyncMessageRequest

@objc public class SSKProtoSyncMessageRequest: NSObject {

    // MARK: - SSKProtoSyncMessageRequestType

    @objc public enum SSKProtoSyncMessageRequestType: Int32 {
        case unknown = 0
        case contacts = 1
        case groups = 2
        case blocked = 3
        case configuration = 4
    }

    private class func SSKProtoSyncMessageRequestTypeWrap(_ value: SignalServiceProtos_SyncMessage.Request.TypeEnum) -> SSKProtoSyncMessageRequestType {
        switch value {
        case .unknown: return .unknown
        case .contacts: return .contacts
        case .groups: return .groups
        case .blocked: return .blocked
        case .configuration: return .configuration
        }
    }

    private class func SSKProtoSyncMessageRequestTypeUnwrap(_ value: SSKProtoSyncMessageRequestType) -> SignalServiceProtos_SyncMessage.Request.TypeEnum {
        switch value {
        case .unknown: return .unknown
        case .contacts: return .contacts
        case .groups: return .groups
        case .blocked: return .blocked
        case .configuration: return .configuration
        }
    }

    // MARK: - SSKProtoSyncMessageRequestBuilder

    @objc public class func builder() -> SSKProtoSyncMessageRequestBuilder {
        return SSKProtoSyncMessageRequestBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoSyncMessageRequestBuilder {
        let builder = SSKProtoSyncMessageRequestBuilder()
        if let _value = type {
            builder.setType(_value)
        }
        return builder
    }

    @objc public class SSKProtoSyncMessageRequestBuilder: NSObject {

        private var proto = SignalServiceProtos_SyncMessage.Request()

        @objc fileprivate override init() {}

        @objc
        public func setType(_ valueParam: SSKProtoSyncMessageRequestType) {
            proto.type = SSKProtoSyncMessageRequestTypeUnwrap(valueParam)
        }

        @objc public func build() throws -> SSKProtoSyncMessageRequest {
            return try SSKProtoSyncMessageRequest.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoSyncMessageRequest.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_SyncMessage.Request

    public var type: SSKProtoSyncMessageRequestType? {
        guard proto.hasType else {
            return nil
        }
        return SSKProtoSyncMessageRequest.SSKProtoSyncMessageRequestTypeWrap(proto.type)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    @objc public var unwrappedType: SSKProtoSyncMessageRequestType {
        if !hasType {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: Request.type.")
        }
        return SSKProtoSyncMessageRequest.SSKProtoSyncMessageRequestTypeWrap(proto.type)
    }
    @objc public var hasType: Bool {
        return proto.hasType
    }

    private init(proto: SignalServiceProtos_SyncMessage.Request) {
        self.proto = proto
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoSyncMessageRequest {
        let proto = try SignalServiceProtos_SyncMessage.Request(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_SyncMessage.Request) throws -> SSKProtoSyncMessageRequest {
        // MARK: - Begin Validation Logic for SSKProtoSyncMessageRequest -

        // MARK: - End Validation Logic for SSKProtoSyncMessageRequest -

        let result = SSKProtoSyncMessageRequest(proto: proto)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoSyncMessageRequest {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoSyncMessageRequest.SSKProtoSyncMessageRequestBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoSyncMessageRequest? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoSyncMessageRead

@objc public class SSKProtoSyncMessageRead: NSObject {

    // MARK: - SSKProtoSyncMessageReadBuilder

    @objc public class func builder(timestamp: UInt64) -> SSKProtoSyncMessageReadBuilder {
        return SSKProtoSyncMessageReadBuilder(timestamp: timestamp)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoSyncMessageReadBuilder {
        let builder = SSKProtoSyncMessageReadBuilder(timestamp: timestamp)
        if let _value = sender {
            builder.setSender(_value)
        }
       
        return builder
    }

    @objc public class SSKProtoSyncMessageReadBuilder: NSObject {

        private var proto = SignalServiceProtos_SyncMessage.Read()

        @objc fileprivate override init() {}

        @objc fileprivate init(timestamp: UInt64) {
            super.init()

            setTimestamp(timestamp)
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setSender(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.sender = valueParam
        }

        public func setSender(_ valueParam: String) {
            proto.sender = valueParam
        }


        @objc
        public func setTimestamp(_ valueParam: UInt64) {
            proto.timestamp = valueParam
        }

        @objc public func build() throws -> SSKProtoSyncMessageRead {
            return try SSKProtoSyncMessageRead.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoSyncMessageRead.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_SyncMessage.Read

    @objc public let timestamp: UInt64

    @objc public var sender: String? {
        guard proto.hasSender else {
            return nil
        }
        return proto.sender
    }
    @objc public var hasSender: Bool {
        return proto.hasSender
    }


    @objc public var hasValidSender: Bool {
        return senderAddress != nil
    }
    @objc public var senderAddress: SignalServiceAddress? {
        guard hasSender else { return nil }

       

        let uuidString: String? = {
            guard hasSender else {
                // Shouldn’t happen in prod yet
                assert(FeatureFlags.allowUUIDOnlyContacts)
                return nil
            }

            guard let senderE164 = sender else {
                owsFailDebug("senderE164 was unexpectedly nil")
                return nil
            }

            guard !senderE164.isEmpty else {
                owsFailDebug("senderE164 was unexpectedly empty")
                return nil
            }

            return senderE164
        }()

        let address = SignalServiceAddress.init(phoneNumber: uuidString)
        guard address.isValid else {
            owsFailDebug("address was unexpectedly invalid")
            return nil
        }

        return address
    }

    private init(proto: SignalServiceProtos_SyncMessage.Read,
                 timestamp: UInt64) {
        self.proto = proto
        self.timestamp = timestamp
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoSyncMessageRead {
        let proto = try SignalServiceProtos_SyncMessage.Read(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_SyncMessage.Read) throws -> SSKProtoSyncMessageRead {
        guard proto.hasTimestamp else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: timestamp")
        }
        let timestamp = proto.timestamp

        // MARK: - Begin Validation Logic for SSKProtoSyncMessageRead -

        // MARK: - End Validation Logic for SSKProtoSyncMessageRead -

        let result = SSKProtoSyncMessageRead(proto: proto,
                                             timestamp: timestamp)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoSyncMessageRead {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoSyncMessageRead.SSKProtoSyncMessageReadBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoSyncMessageRead? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoSyncMessageConfiguration

@objc public class SSKProtoSyncMessageConfiguration: NSObject {

    // MARK: - SSKProtoSyncMessageConfigurationBuilder

    @objc public class func builder() -> SSKProtoSyncMessageConfigurationBuilder {
        return SSKProtoSyncMessageConfigurationBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoSyncMessageConfigurationBuilder {
        let builder = SSKProtoSyncMessageConfigurationBuilder()
        if hasReadReceipts {
            builder.setReadReceipts(readReceipts)
        }
      
        if hasTypingIndicators {
            builder.setTypingIndicators(typingIndicators)
        }
        if hasLinkPreviews {
            builder.setLinkPreviews(linkPreviews)
        }
        return builder
    }

    @objc public class SSKProtoSyncMessageConfigurationBuilder: NSObject {

        private var proto = SignalServiceProtos_SyncMessage.Configuration()

        @objc fileprivate override init() {}

        @objc
        public func setReadReceipts(_ valueParam: Bool) {
            proto.readReceipts = valueParam
        }

       
        @objc
        public func setTypingIndicators(_ valueParam: Bool) {
            proto.typingIndicators = valueParam
        }

        @objc
        public func setLinkPreviews(_ valueParam: Bool) {
            proto.linkPreviews = valueParam
        }

        @objc public func build() throws -> SSKProtoSyncMessageConfiguration {
            return try SSKProtoSyncMessageConfiguration.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoSyncMessageConfiguration.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_SyncMessage.Configuration

    @objc public var readReceipts: Bool {
        return proto.readReceipts
    }
    @objc public var hasReadReceipts: Bool {
        return proto.hasReadReceipts
    }


    @objc public var typingIndicators: Bool {
        return proto.typingIndicators
    }
    @objc public var hasTypingIndicators: Bool {
        return proto.hasTypingIndicators
    }

    @objc public var linkPreviews: Bool {
        return proto.linkPreviews
    }
    @objc public var hasLinkPreviews: Bool {
        return proto.hasLinkPreviews
    }
    
    @objc public var stick: Bool {
           return proto.stick
       }
       @objc public var hasStick: Bool {
           return proto.hasStick
       }

//    @objc public var bunches: Bool {
//        return proto.
//    }
//    @objc public var hasBunches: Bool {
//        return proto.hasBunches
//    }
    private init(proto: SignalServiceProtos_SyncMessage.Configuration) {
        self.proto = proto
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoSyncMessageConfiguration {
        let proto = try SignalServiceProtos_SyncMessage.Configuration(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_SyncMessage.Configuration) throws -> SSKProtoSyncMessageConfiguration {
        // MARK: - Begin Validation Logic for SSKProtoSyncMessageConfiguration -

        // MARK: - End Validation Logic for SSKProtoSyncMessageConfiguration -

        let result = SSKProtoSyncMessageConfiguration(proto: proto)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoSyncMessageConfiguration {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoSyncMessageConfiguration.SSKProtoSyncMessageConfigurationBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoSyncMessageConfiguration? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoSyncMessageStickerPackOperation

@objc public class SSKProtoSyncMessageStickerPackOperation: NSObject {

    // MARK: - SSKProtoSyncMessageStickerPackOperationType

    @objc public enum SSKProtoSyncMessageStickerPackOperationType: Int32 {
        case install = 0
        case remove = 1
    }

    private class func SSKProtoSyncMessageStickerPackOperationTypeWrap(_ value: SignalServiceProtos_SyncMessage.StickerPackOperation.TypeEnum) -> SSKProtoSyncMessageStickerPackOperationType {
        switch value {
        case .install: return .install
        case .remove: return .remove
        }
    }

    private class func SSKProtoSyncMessageStickerPackOperationTypeUnwrap(_ value: SSKProtoSyncMessageStickerPackOperationType) -> SignalServiceProtos_SyncMessage.StickerPackOperation.TypeEnum {
        switch value {
        case .install: return .install
        case .remove: return .remove
        }
    }

    // MARK: - SSKProtoSyncMessageStickerPackOperationBuilder

    @objc public class func builder(packID: Data, packKey: Data) -> SSKProtoSyncMessageStickerPackOperationBuilder {
        return SSKProtoSyncMessageStickerPackOperationBuilder(packID: packID, packKey: packKey)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoSyncMessageStickerPackOperationBuilder {
        let builder = SSKProtoSyncMessageStickerPackOperationBuilder(packID: packID, packKey: packKey)
        if let _value = type {
            builder.setType(_value)
        }
        return builder
    }

    @objc public class SSKProtoSyncMessageStickerPackOperationBuilder: NSObject {

        private var proto = SignalServiceProtos_SyncMessage.StickerPackOperation()

        @objc fileprivate override init() {}

        @objc fileprivate init(packID: Data, packKey: Data) {
            super.init()

            setPackID(packID)
            setPackKey(packKey)
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setPackID(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.packID = valueParam
        }

        public func setPackID(_ valueParam: Data) {
            proto.packID = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setPackKey(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.packKey = valueParam
        }

        public func setPackKey(_ valueParam: Data) {
            proto.packKey = valueParam
        }

        @objc
        public func setType(_ valueParam: SSKProtoSyncMessageStickerPackOperationType) {
            proto.type = SSKProtoSyncMessageStickerPackOperationTypeUnwrap(valueParam)
        }

        @objc public func build() throws -> SSKProtoSyncMessageStickerPackOperation {
            return try SSKProtoSyncMessageStickerPackOperation.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoSyncMessageStickerPackOperation.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_SyncMessage.StickerPackOperation

    @objc public let packID: Data

    @objc public let packKey: Data

    public var type: SSKProtoSyncMessageStickerPackOperationType? {
        guard proto.hasType else {
            return nil
        }
        return SSKProtoSyncMessageStickerPackOperation.SSKProtoSyncMessageStickerPackOperationTypeWrap(proto.type)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    @objc public var unwrappedType: SSKProtoSyncMessageStickerPackOperationType {
        if !hasType {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: StickerPackOperation.type.")
        }
        return SSKProtoSyncMessageStickerPackOperation.SSKProtoSyncMessageStickerPackOperationTypeWrap(proto.type)
    }
    @objc public var hasType: Bool {
        return proto.hasType
    }

    private init(proto: SignalServiceProtos_SyncMessage.StickerPackOperation,
                 packID: Data,
                 packKey: Data) {
        self.proto = proto
        self.packID = packID
        self.packKey = packKey
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoSyncMessageStickerPackOperation {
        let proto = try SignalServiceProtos_SyncMessage.StickerPackOperation(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_SyncMessage.StickerPackOperation) throws -> SSKProtoSyncMessageStickerPackOperation {
        guard proto.hasPackID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: packID")
        }
        let packID = proto.packID

        guard proto.hasPackKey else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: packKey")
        }
        let packKey = proto.packKey

        // MARK: - Begin Validation Logic for SSKProtoSyncMessageStickerPackOperation -

        // MARK: - End Validation Logic for SSKProtoSyncMessageStickerPackOperation -

        let result = SSKProtoSyncMessageStickerPackOperation(proto: proto,
                                                             packID: packID,
                                                             packKey: packKey)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoSyncMessageStickerPackOperation {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoSyncMessageStickerPackOperation.SSKProtoSyncMessageStickerPackOperationBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoSyncMessageStickerPackOperation? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoSyncMessageViewOnceOpen

@objc public class SSKProtoSyncMessageViewOnceOpen: NSObject {

    // MARK: - SSKProtoSyncMessageViewOnceOpenBuilder

    @objc public class func builder(timestamp: UInt64) -> SSKProtoSyncMessageViewOnceOpenBuilder {
        return SSKProtoSyncMessageViewOnceOpenBuilder(timestamp: timestamp)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoSyncMessageViewOnceOpenBuilder {
        let builder = SSKProtoSyncMessageViewOnceOpenBuilder(timestamp: timestamp)
        if let _value = sender {
            builder.setSender(_value)
        }
       
        return builder
    }

    @objc public class SSKProtoSyncMessageViewOnceOpenBuilder: NSObject {

        private var proto = SignalServiceProtos_SyncMessage.ViewOnceOpen()

        @objc fileprivate override init() {}

        @objc fileprivate init(timestamp: UInt64) {
            super.init()

            setTimestamp(timestamp)
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setSender(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.sender = valueParam
        }

        public func setSender(_ valueParam: String) {
            proto.sender = valueParam
        }

       

        @objc
        public func setTimestamp(_ valueParam: UInt64) {
            proto.timestamp = valueParam
        }

        @objc public func build() throws -> SSKProtoSyncMessageViewOnceOpen {
            return try SSKProtoSyncMessageViewOnceOpen.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoSyncMessageViewOnceOpen.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_SyncMessage.ViewOnceOpen

    @objc public let timestamp: UInt64

    @objc public var sender: String? {
        guard proto.hasSender else {
            return nil
        }
        return proto.sender
    }
    @objc public var hasSender: Bool {
        return proto.hasSender
    }
    
    @objc public var hasValidSender: Bool {
        return senderAddress != nil
    }
    @objc public var senderAddress: SignalServiceAddress? {
        guard hasSender else { return nil }

        
        let uuidString: String? = {
            guard self.hasSender else {
                // Shouldn’t happen in prod yet
                assert(FeatureFlags.allowUUIDOnlyContacts)
                return nil
            }

            guard let senderE164 = sender else {
                owsFailDebug("senderE164 was unexpectedly nil")
                return nil
            }

            guard !senderE164.isEmpty else {
                owsFailDebug("senderE164 was unexpectedly empty")
                return nil
            }

            return senderE164
        }()

        let address = SignalServiceAddress.init(phoneNumber: uuidString)
        guard address.isValid else {
            owsFailDebug("address was unexpectedly invalid")
            return nil
        }

        return address
    }

    private init(proto: SignalServiceProtos_SyncMessage.ViewOnceOpen,
                 timestamp: UInt64) {
        self.proto = proto
        self.timestamp = timestamp
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoSyncMessageViewOnceOpen {
        let proto = try SignalServiceProtos_SyncMessage.ViewOnceOpen(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_SyncMessage.ViewOnceOpen) throws -> SSKProtoSyncMessageViewOnceOpen {
        guard proto.hasTimestamp else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: timestamp")
        }
        let timestamp = proto.timestamp

        // MARK: - Begin Validation Logic for SSKProtoSyncMessageViewOnceOpen -

        // MARK: - End Validation Logic for SSKProtoSyncMessageViewOnceOpen -

        let result = SSKProtoSyncMessageViewOnceOpen(proto: proto,
                                                     timestamp: timestamp)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoSyncMessageViewOnceOpen {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoSyncMessageViewOnceOpen.SSKProtoSyncMessageViewOnceOpenBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoSyncMessageViewOnceOpen? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoSyncMessage

@objc public class SSKProtoSyncMessage: NSObject {

    // MARK: - SSKProtoSyncMessageBuilder

    @objc public class func builder() -> SSKProtoSyncMessageBuilder {
        return SSKProtoSyncMessageBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoSyncMessageBuilder {
        let builder = SSKProtoSyncMessageBuilder()
        if let _value = sent {
            builder.setSent(_value)
        }
        if let _value = contacts {
            builder.setContacts(_value)
        }
        if let _value = groups {
            builder.setGroups(_value)
        }
        if let _value = request {
            builder.setRequest(_value)
        }
        builder.setRead(read)
        if let _value = blocked {
            builder.setBlocked(_value)
        }
       
        if let _value = configuration {
            builder.setConfiguration(_value)
        }
        if let _value = padding {
            builder.setPadding(_value)
        }
        builder.setStickerPackOperation(stickerPackOperation)
        if let _value = viewOnceOpen {
            builder.setViewOnceOpen(_value)
        }
        return builder
    }

    @objc public class SSKProtoSyncMessageBuilder: NSObject {

        private var proto = SignalServiceProtos_SyncMessage()

        @objc fileprivate override init() {}

        @objc
        @available(swift, obsoleted: 1.0)
        public func setSent(_ valueParam: SSKProtoSyncMessageSent?) {
            guard let valueParam = valueParam else { return }
            proto.sent = valueParam.proto
        }

        public func setSent(_ valueParam: SSKProtoSyncMessageSent) {
            proto.sent = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setContacts(_ valueParam: SSKProtoSyncMessageContacts?) {
            guard let valueParam = valueParam else { return }
            proto.contacts = valueParam.proto
        }

        public func setContacts(_ valueParam: SSKProtoSyncMessageContacts) {
            proto.contacts = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setGroups(_ valueParam: SSKProtoSyncMessageGroups?) {
            guard let valueParam = valueParam else { return }
            proto.groups = valueParam.proto
        }

        public func setGroups(_ valueParam: SSKProtoSyncMessageGroups) {
            proto.groups = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setRequest(_ valueParam: SSKProtoSyncMessageRequest?) {
            guard let valueParam = valueParam else { return }
            proto.request = valueParam.proto
        }

        public func setRequest(_ valueParam: SSKProtoSyncMessageRequest) {
            proto.request = valueParam.proto
        }

        @objc public func addRead(_ valueParam: SSKProtoSyncMessageRead) {
            var items = proto.read
            items.append(valueParam.proto)
            proto.read = items
        }

        @objc public func setRead(_ wrappedItems: [SSKProtoSyncMessageRead]) {
            proto.read = wrappedItems.map { $0.proto }
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setBlocked(_ valueParam: SSKProtoSyncMessageBlocked?) {
            guard let valueParam = valueParam else { return }
            proto.blocked = valueParam.proto
        }

        public func setBlocked(_ valueParam: SSKProtoSyncMessageBlocked) {
            proto.blocked = valueParam.proto
        }


        @objc
        @available(swift, obsoleted: 1.0)
        public func setConfiguration(_ valueParam: SSKProtoSyncMessageConfiguration?) {
            guard let valueParam = valueParam else { return }
            proto.configuration = valueParam.proto
        }

        public func setConfiguration(_ valueParam: SSKProtoSyncMessageConfiguration) {
            proto.configuration = valueParam.proto
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setPadding(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.padding = valueParam
        }

        public func setPadding(_ valueParam: Data) {
            proto.padding = valueParam
        }

        @objc public func addStickerPackOperation(_ valueParam: SSKProtoSyncMessageStickerPackOperation) {
            var items = proto.stickerPackOperation
            items.append(valueParam.proto)
            proto.stickerPackOperation = items
        }

        @objc public func setStickerPackOperation(_ wrappedItems: [SSKProtoSyncMessageStickerPackOperation]) {
            proto.stickerPackOperation = wrappedItems.map { $0.proto }
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setViewOnceOpen(_ valueParam: SSKProtoSyncMessageViewOnceOpen?) {
            guard let valueParam = valueParam else { return }
            proto.viewOnceOpen = valueParam.proto
        }

        public func setViewOnceOpen(_ valueParam: SSKProtoSyncMessageViewOnceOpen) {
            proto.viewOnceOpen = valueParam.proto
        }
      

        @objc public func build() throws -> SSKProtoSyncMessage {
            return try SSKProtoSyncMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoSyncMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_SyncMessage

    @objc public let sent: SSKProtoSyncMessageSent?

    @objc public let contacts: SSKProtoSyncMessageContacts?

    @objc public let groups: SSKProtoSyncMessageGroups?

    @objc public let request: SSKProtoSyncMessageRequest?

    @objc public let read: [SSKProtoSyncMessageRead]

    @objc public let blocked: SSKProtoSyncMessageBlocked?

//    @objc public let verified: SSKProtoVerified?

    @objc public let configuration: SSKProtoSyncMessageConfiguration?

    @objc public let stickerPackOperation: [SSKProtoSyncMessageStickerPackOperation]

    @objc public let viewOnceOpen: SSKProtoSyncMessageViewOnceOpen?

    @objc public var padding: Data? {
        guard proto.hasPadding else {
            return nil
        }
        return proto.padding
    }
    @objc public var hasPadding: Bool {
        return proto.hasPadding
    }

    private init(proto: SignalServiceProtos_SyncMessage,
                 sent: SSKProtoSyncMessageSent?,
                 contacts: SSKProtoSyncMessageContacts?,
                 groups: SSKProtoSyncMessageGroups?,
                 request: SSKProtoSyncMessageRequest?,
                 read: [SSKProtoSyncMessageRead],
                 blocked: SSKProtoSyncMessageBlocked?,
//                 verified: SSKProtoVerified?,
                 configuration: SSKProtoSyncMessageConfiguration?,
                 stickerPackOperation: [SSKProtoSyncMessageStickerPackOperation],
                 viewOnceOpen: SSKProtoSyncMessageViewOnceOpen?) {
        self.proto = proto
        self.sent = sent
        self.contacts = contacts
        self.groups = groups
        self.request = request
        self.read = read
        self.blocked = blocked
//        self.verified = verified
        self.configuration = configuration
        self.stickerPackOperation = stickerPackOperation
        self.viewOnceOpen = viewOnceOpen
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoSyncMessage {
        let proto = try SignalServiceProtos_SyncMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_SyncMessage) throws -> SSKProtoSyncMessage {
        var sent: SSKProtoSyncMessageSent? = nil
        if proto.hasSent {
            sent = try SSKProtoSyncMessageSent.parseProto(proto.sent)
        }

        var contacts: SSKProtoSyncMessageContacts? = nil
        if proto.hasContacts {
            contacts = try SSKProtoSyncMessageContacts.parseProto(proto.contacts)
        }

        var groups: SSKProtoSyncMessageGroups? = nil
        if proto.hasGroups {
            groups = try SSKProtoSyncMessageGroups.parseProto(proto.groups)
        }

        var request: SSKProtoSyncMessageRequest? = nil
        if proto.hasRequest {
            request = try SSKProtoSyncMessageRequest.parseProto(proto.request)
        }

        var read: [SSKProtoSyncMessageRead] = []
        read = try proto.read.map { try SSKProtoSyncMessageRead.parseProto($0) }

        var blocked: SSKProtoSyncMessageBlocked? = nil
        if proto.hasBlocked {
            blocked = try SSKProtoSyncMessageBlocked.parseProto(proto.blocked)
        }

//        var verified: SSKProtoVerified? = nil
//        if proto.hasVerified {
//            verified = try SSKProtoVerified.parseProto(proto.verified)
//        }

        var configuration: SSKProtoSyncMessageConfiguration? = nil
        if proto.hasConfiguration {
            configuration = try SSKProtoSyncMessageConfiguration.parseProto(proto.configuration)
        }

        var stickerPackOperation: [SSKProtoSyncMessageStickerPackOperation] = []
        stickerPackOperation = try proto.stickerPackOperation.map { try SSKProtoSyncMessageStickerPackOperation.parseProto($0) }

        var viewOnceOpen: SSKProtoSyncMessageViewOnceOpen? = nil
        if proto.hasViewOnceOpen {
            viewOnceOpen = try SSKProtoSyncMessageViewOnceOpen.parseProto(proto.viewOnceOpen)
        }

        // MARK: - Begin Validation Logic for SSKProtoSyncMessage -

        // MARK: - End Validation Logic for SSKProtoSyncMessage -

        let result = SSKProtoSyncMessage(proto: proto,
                                         sent: sent,
                                         contacts: contacts,
                                         groups: groups,
                                         request: request,
                                         read: read,
                                         blocked: blocked,
//                                         verified: verified,
                                         configuration: configuration,
                                         stickerPackOperation: stickerPackOperation,
                                         viewOnceOpen: viewOnceOpen)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoSyncMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoSyncMessage.SSKProtoSyncMessageBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoSyncMessage? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoAttachmentPointer

@objc public class SSKProtoAttachmentPointer: NSObject {

    // MARK: - SSKProtoAttachmentPointerFlags

    @objc public enum SSKProtoAttachmentPointerFlags: Int32 {
        case voiceMessage = 1
    }

    private class func SSKProtoAttachmentPointerFlagsWrap(_ value: SignalServiceProtos_AttachmentPointer.Flags) -> SSKProtoAttachmentPointerFlags {
        switch value {
        case .voiceMessage: return .voiceMessage
        }
    }

    private class func SSKProtoAttachmentPointerFlagsUnwrap(_ value: SSKProtoAttachmentPointerFlags) -> SignalServiceProtos_AttachmentPointer.Flags {
        switch value {
        case .voiceMessage: return .voiceMessage
        }
    }

    // MARK: - SSKProtoAttachmentPointerBuilder

    @objc public class func builder(id: UInt64) -> SSKProtoAttachmentPointerBuilder {
        return SSKProtoAttachmentPointerBuilder(id: id)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoAttachmentPointerBuilder {
        let builder = SSKProtoAttachmentPointerBuilder(id: id)
        if let _value = contentType {
            builder.setContentType(_value)
        }
      
        if hasSize {
            builder.setSize(size)
        }
        if let _value = thumbnail {
            builder.setThumbnail(_value)
        }
       
        if let _value = fileName {
            builder.setFileName(_value)
        }
        if hasFlags {
            builder.setFlags(flags)
        }
        if hasWidth {
            builder.setWidth(width)
        }
        if hasHeight {
            builder.setHeight(height)
        }
        if let _value = caption {
            builder.setCaption(_value)
        }
        return builder
    }

    @objc public class SSKProtoAttachmentPointerBuilder: NSObject {

        private var proto = SignalServiceProtos_AttachmentPointer()

        @objc fileprivate override init() {}

        @objc fileprivate init(id: UInt64) {
            super.init()

            setId(id)
        }

        @objc
        public func setId(_ valueParam: UInt64) {
            
            proto.id = "\(valueParam)";
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setContentType(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.contentType = valueParam
        }

        public func setContentType(_ valueParam: String) {
            proto.contentType = valueParam
        }


        @objc
        public func setSize(_ valueParam: UInt32) {
            proto.size = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setThumbnail(_ valueParam: Data?) {
            guard let valueParam = valueParam else { return }
            proto.thumbnail = valueParam
        }

        public func setThumbnail(_ valueParam: Data) {
            proto.thumbnail = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setFileName(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.fileName = valueParam
        }

        public func setFileName(_ valueParam: String) {
            proto.fileName = valueParam
        }

        @objc
        public func setFlags(_ valueParam: UInt32) {
            proto.flags = valueParam
        }

        @objc
        public func setWidth(_ valueParam: UInt32) {
            proto.width = valueParam
        }

        @objc
        public func setHeight(_ valueParam: UInt32) {
            proto.height = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setCaption(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.caption = valueParam
        }

        public func setCaption(_ valueParam: String) {
            proto.caption = valueParam
        }

        @objc public func build() throws -> SSKProtoAttachmentPointer {
            return try SSKProtoAttachmentPointer.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoAttachmentPointer.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_AttachmentPointer

    @objc public let id: UInt64

    @objc public var contentType: String? {
        guard proto.hasContentType else {
            return nil
        }
        return proto.contentType
    }
    @objc public var hasContentType: Bool {
        return proto.hasContentType
    }

   

    @objc public var size: UInt32 {
        return proto.size
    }
    @objc public var hasSize: Bool {
        return proto.hasSize
    }

    @objc public var thumbnail: Data? {
        guard proto.hasThumbnail else {
            return nil
        }
        return proto.thumbnail
    }
    @objc public var hasThumbnail: Bool {
        return proto.hasThumbnail
    }

   

    @objc public var fileName: String? {
        guard proto.hasFileName else {
            return nil
        }
        return proto.fileName
    }
    @objc public var hasFileName: Bool {
        return proto.hasFileName
    }

    @objc public var flags: UInt32 {
        return proto.flags
    }
    @objc public var hasFlags: Bool {
        return proto.hasFlags
    }

    @objc public var width: UInt32 {
        return proto.width
    }
    @objc public var hasWidth: Bool {
        return proto.hasWidth
    }

    @objc public var height: UInt32 {
        return proto.height
    }
    @objc public var hasHeight: Bool {
        return proto.hasHeight
    }

    @objc public var caption: String? {
        guard proto.hasCaption else {
            return nil
        }
        return proto.caption
    }
    @objc public var hasCaption: Bool {
        return proto.hasCaption
    }

    private init(proto: SignalServiceProtos_AttachmentPointer,
                 id: UInt64) {
        self.proto = proto
        self.id = id
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoAttachmentPointer {
        let proto = try SignalServiceProtos_AttachmentPointer(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_AttachmentPointer) throws -> SSKProtoAttachmentPointer {
        guard proto.hasID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: id")
        }
        guard let id = UInt64(proto.id) else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) can not convert aattchment string id to uint64");
        }
        

        // MARK: - Begin Validation Logic for SSKProtoAttachmentPointer -

        // MARK: - End Validation Logic for SSKProtoAttachmentPointer -
        
        let result = SSKProtoAttachmentPointer(proto: proto,
                                               id: id)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoAttachmentPointer {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoAttachmentPointer.SSKProtoAttachmentPointerBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoAttachmentPointer? {
        return try! self.build()
    }
}

#endif


// MARK: 群组公告
@objc public class SSKProtoGroupNotice: NSObject {

    @objc
    public let id: String;
    @objc
    public let sender: SSKProtoUserEntiy?;
    @objc
    public let content: String
    @objc
    public let updateTimestamp: UInt64;
    
    fileprivate let proto: SignalServiceProtos_GroupOperation.Notice;
    private init(_ proto:SignalServiceProtos_GroupOperation.Notice, id: String, content: String?) {
        
        self.proto = proto;
        self.id = id;
        self.content = content ?? "";
        self.sender = try? SSKProtoUserEntiy.parseProto(proto.sender);
        self.updateTimestamp = proto.serverTimestamp;
        
    }
    
    @objc public class func builder() -> SSKProtoGroupNoticeBuilder {
        return SSKProtoGroupNoticeBuilder();
       }

       // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoGroupNoticeBuilder {
        let builder = SSKProtoGroupNoticeBuilder()
        builder.setId(self.id)
        builder.setContent(self.content);
        return builder
    }
    
    @objc
    public class SSKProtoGroupNoticeBuilder: NSObject {
        
         private var proto = SignalServiceProtos_GroupOperation.Notice()

         @objc fileprivate override init() {}
        
        @objc
        public func setId(_ value: String) {
            
            self.proto.id = value;
            
        }
        
        @objc
        public func setContent(_ value: String?) {
            guard let _value = value else {
                return;
            }
            self.proto.content = _value;
            
        }

        @objc public func build() throws -> SSKProtoGroupNotice {
            return try SSKProtoGroupNotice.parseProto(proto);
        }
        
        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoGroupNotice.parseProto(proto).serializedData()
        }
        
    }
    
    
    
    @objc
       public func serializedData() throws -> Data {
           return try self.proto.serializedData()
       }

       @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoGroupNotice {
           let proto = try SignalServiceProtos_GroupOperation.Notice(serializedData: serializedData)
           return try parseProto(proto)
       }

       fileprivate class func parseProto(_ proto: SignalServiceProtos_GroupOperation.Notice) throws -> SSKProtoGroupNotice {
           // MARK: - Begin Validation Logic for SSKProtoGroupContextMember -

           // MARK: - End Validation Logic for SSKProtoGroupContextMember -

        let result = SSKProtoGroupNotice.init(proto, id: proto.id, content: proto.content);
           return result
       }

       @objc public override var debugDescription: String {
           return "\(proto)"
       }
    
}

// MARK: 群权限

@objc public class SSKProtoGroupPermission: NSObject {
    
    
    @objc public let role: UInt32;
    @objc public let rightBan: UInt32;
        
    private init(proto: SignalServiceProtos_GroupOperation.Perm) {
        
        self.role = proto.role;
        self.rightBan = proto.rightBan;
        self.proto = proto;
        
    }
    fileprivate let proto: SignalServiceProtos_GroupOperation.Perm
    
    
    @objc public class func builder() -> SSKProtoGroupPermissionBuilder {
        return SSKProtoGroupPermissionBuilder()
    }
    
    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoGroupPermissionBuilder {
        let builder = SSKProtoGroupPermissionBuilder()
        builder.setRole(self.role);
        builder.setRightBan(self.rightBan);
        return builder
    }
    
    @objc public class SSKProtoGroupPermissionBuilder: NSObject {
        
        private var proto = SignalServiceProtos_GroupOperation.Perm();
        
        @objc fileprivate override init() {}
        
        public func setRole(_ value: UInt32?) {
            if let _value = value {
                proto.role = _value;
            }
        }
        public func setRightBan(_ value: UInt32?) {
            
            if let _value = value {
                proto.rightBan = _value;
            }
           
        }
       
        @objc public func build() throws -> SSKProtoGroupPermission {
            return try SSKProtoGroupPermission.parseProto(proto);
        }
        
        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoGroupPermission.parseProto(proto).serializedData()
        }
    }
    
    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoGroupPermission {
        let proto = try SignalServiceProtos_GroupOperation.Perm(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_GroupOperation.Perm) throws -> SSKProtoGroupPermission {
        // MARK: - Begin Validation Logic for SSKProtoGroupContextMember -

        // MARK: - End Validation Logic for SSKProtoGroupContextMember -

        let result = SSKProtoGroupPermission.init(proto: proto);
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}
// MARK: group member
@objc
public class SSKProtoGroupMember: NSObject {
    
    
    
    fileprivate let proto: SignalServiceProtos_GroupOperation.GroupMember;
    
    @objc public class func builder() -> SSKProtoGroupMemberBuilder {
        return SSKProtoGroupMemberBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoGroupMemberBuilder {
        let builder = SSKProtoGroupMemberBuilder()

        builder.setId(self.id);
        builder.setName(self.name);
        builder.setAvatar(self.avatar);
        builder.setRoleInGroup(self.roleInGroup);
        builder.setRightInGroup(self.rightInGroup);
        builder.setMemberStatus(self.memberStatus);
        return builder
    }
    @objc
    public class SSKProtoGroupMemberBuilder: NSObject {

        fileprivate var proto = SignalServiceProtos_GroupOperation.GroupMember();
        @objc fileprivate override init() {}

        @objc
        public func setId(_ valueParam: String?) {
            guard valueParam != nil else {
                return;
            }
            proto.userID = valueParam!;
        }

        @objc
        public func setName(_ valueParam: String?) {
            guard valueParam != nil else {
                return;
            }
            proto.userName = valueParam!;
        }
        @objc
        public func setAvatar(_ valueParam: String?) {
            guard valueParam != nil else {
                return;
            }
            proto.userAvatar = valueParam!;
        }
        
        @objc
        public func setRoleInGroup(_ valueParam: UInt32) {
            
            proto.roleInGroup = valueParam;
        }
        
        @objc
        public func setRightInGroup(_ valueParam: UInt32) {
            
            proto.rightInGroup = valueParam;
        }
        @objc
        public func setMemberStatus(_ valueParam: UInt32) {
           
            proto.memberStatus = valueParam;
        }

        @objc public func build() throws -> SSKProtoGroupMember {
            return try SSKProtoGroupMember.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoGroupMember.parseProto(proto).serializedData()
        }


    }
    @objc public var hasId: Bool {
        return proto.hasUserID
    }
    
    @objc
    public var id: String? {
        if !self.hasId {
            return nil;
        }
        return proto.userID;
    }
    
    @objc public var hasName: Bool {
        return proto.hasUserName
    }
    
    @objc
    public var name: String? {
        if !self.hasName {
            return nil;
        }
        return proto.userName;
    }
    
    @objc public var hasAvatar: Bool {
        return proto.hasUserAvatar
    }
    
    @objc
    public var avatar: String? {
        if !self.hasAvatar {
            return nil;
        }
        return proto.userAvatar;
    }
    @objc public var hasRoleInGroup: Bool {
        return proto.hasRoleInGroup
    }
    
    @objc
    public var roleInGroup: UInt32 {
        if !self.hasRoleInGroup {
            return 0;
        }
        return proto.roleInGroup;
    }
    
    @objc public var hasRightInGroup: Bool {
           return proto.hasRightInGroup
       }
    
    @objc
    public var rightInGroup: UInt32 {
        if !self.hasRightInGroup {
            return 0;
        }
        return proto.rightInGroup;
    }
       
    @objc public var hasMemberStatus: Bool {
        return proto.hasMemberStatus
    }
    
    @objc
    public var memberStatus: UInt32 {
        if !self.hasMemberStatus {
            return 0;
        }
        return proto.memberStatus;
    }
    
    
    private  init(proto: SignalServiceProtos_GroupOperation.GroupMember) {
        self.proto = proto;
    }
    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoGroupMember {
        let proto = try SignalServiceProtos_GroupOperation.GroupMember(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_GroupOperation.GroupMember) throws -> SSKProtoGroupMember {
        
        // MARK: - Begin Validation Logic for SSKProtoTypingMessage -

        // MARK: - End Validation Logic for SSKProtoTypingMessage -

        let result = SSKProtoGroupMember(proto: proto)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
    
    
    
    
}
// MARK: - SSKProtoGroupContext

@objc public class SSKProtoGroupContext: NSObject {

    //针对什么角色做的操作
    @objc
    public enum SSKProtoGroupContextTarget: Int {
        case none = 0;
        case name = 1;
        case avatar = 2;
        case owner = 3;
        
        case manager = 4;
        case member = 5;
        case notice = 6;
        case permGroup = 7;
        case permPersonal = 8;
        case link = 9
        
    }
    
    // MARK: - SSKProtoGroupContextType

    @objc public enum SSKProtoGroupContextType: Int32 {
        case unknown = 0
        case drag = 1
        case invite = 2
        case apply = 3
        case decline = 4
        case block = 5
        case update = 6
        case add = 7;
        case remove = 8;
        case applyAccept = 9;
        case applyDecline = 10;
        case quit = 11;
        case dismiss = 12;
    }

    private class func SSKProtoGroupContextTypeWrap(_ value: SignalServiceProtos_GroupOperation.TypeEnum) -> SSKProtoGroupContextType {
       
        return SSKProtoGroupContextType.init(rawValue: Int32(value.rawValue)) ?? SSKProtoGroupContextType.unknown;
    }

    private class func SSKProtoGroupContextTypeUnwrap(_ value: SSKProtoGroupContextType) -> SignalServiceProtos_GroupOperation.TypeEnum {
        
        return SignalServiceProtos_GroupOperation.TypeEnum.init(rawValue: Int(value.rawValue)) ?? SignalServiceProtos_GroupOperation.TypeEnum.unknown;
    }
    
    private class func SSKProtoGroupContextTargetWrap(_ value: SignalServiceProtos_GroupOperation.Target) -> SSKProtoGroupContextTarget {
          
        return SSKProtoGroupContextTarget.init(rawValue: value.rawValue) ?? SSKProtoGroupContextTarget.none;
       }

       private class func SSKProtoGroupContextTargetUnwrap(_ value: SSKProtoGroupContextTarget) -> SignalServiceProtos_GroupOperation.Target {
           
           return SignalServiceProtos_GroupOperation.Target.init(rawValue: Int(value.rawValue)) ?? SignalServiceProtos_GroupOperation.Target.none;
       }
    
    /**
     * 因为只收不发 所以不需要 builder
     */
    // MARK: - SSKProtoGroupContextBuilder

    @objc public class func builder(id: String) -> SSKProtoGroupContextBuilder {
        return SSKProtoGroupContextBuilder(id: id)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoGroupContextBuilder {
        let builder = SSKProtoGroupContextBuilder(id: id)
        if let _value = type {
            builder.setType(_value)
        }
        if let _value = name {
            builder.setName(_value)
        }
        if let _value = avatar {
            builder.setAvatar(_value)
        }

        builder.setNotices(self.notices);
        builder.setPermissions(self.permissions);
        builder.setTarget(self.target);
        builder.setGroupMember(self.members);


        return builder
    }

    @objc public class SSKProtoGroupContextBuilder: NSObject {

        private var proto = SignalServiceProtos_GroupOperation()

        @objc fileprivate override init() {}

        @objc fileprivate init(id: String) {
            super.init()

            setId(id)
            //默认对所有
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setId(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.id = valueParam
        }

        public func setId(_ valueParam: String) {
            proto.id = valueParam
        }

        @objc
        public func setType(_ valueParam: SSKProtoGroupContextType) {
            proto.type = SSKProtoGroupContextTypeUnwrap(valueParam)
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setName(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.name = valueParam
        }

        public func setName(_ valueParam: String) {
            proto.name = valueParam
        }



        @objc
        @available(swift, obsoleted: 1.0)
        public func setAvatar(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.avatar = valueParam
        }

        public func setAvatar(_ valueParam: String) {
            proto.avatar = valueParam
        }



        @objc
        public func setNotices(_ value:SSKProtoGroupNotice?) {
            guard let _value = value else {
                return;
            }
            self.proto.notices = _value.proto
        }

        @objc
        public func setPermissions(_ value: [SSKProtoGroupPermission]?) {
            guard let _value = value else {
                return;
            }
            self.proto.perm = _value.map({ (permission) -> SignalServiceProtos_GroupOperation.Perm in
                return permission.proto;
            });
        }

        @objc
        public func setGroupMember(_ value: [SSKProtoGroupMember]?) {
            guard let _value = value else {
                return;
            }
            self.proto.groupMember = _value.map({ (member) -> SignalServiceProtos_GroupOperation.GroupMember in
                return member.proto;
            });
        }

        @objc
        public func setTarget(_ value:SSKProtoGroupContextTarget) {

            self.proto.target = SSKProtoGroupContext.SSKProtoGroupContextTargetUnwrap(value);
        }

        @objc public func build() throws -> SSKProtoGroupContext {
            return try SSKProtoGroupContext.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoGroupContext.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_GroupOperation

    @objc public let id: String

    @objc public let avatar: String?
    
    @objc public let notices: SSKProtoGroupNotice?
    
    @objc public let permissions: [SSKProtoGroupPermission]?

    @objc public let target: SSKProtoGroupContextTarget

    @objc public let members: [SSKProtoGroupMember]?
    
    @objc public let link: String?

    
    @objc
    public var hasRightBen: Bool {
        return self.proto.hasRightBan;
    }
    @objc var rightBen: UInt32 {
        
        return self.proto.rightBan;
    }
    public var type: SSKProtoGroupContextType? {
        guard proto.hasType else {
            return nil
        }
        return SSKProtoGroupContext.SSKProtoGroupContextTypeWrap(proto.type)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    @objc public var unwrappedType: SSKProtoGroupContextType {
        if !hasType {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: GroupContext.type.")
        }
        return SSKProtoGroupContext.SSKProtoGroupContextTypeWrap(proto.type)
    }
    @objc public var hasType: Bool {
        return proto.hasType
    }

    @objc public var name: String? {
        guard proto.hasName else {
            return nil
        }
        return proto.name
    }
    @objc public var hasName: Bool {
        return proto.hasName
    }
    @objc public var memberCount: UInt32 {
           guard self.hasMemberCount else {
               return 0;
           }
           return self.proto.memberCount;
       }
       @objc public var hasMemberCount: Bool {
           
           return self.proto.hasMemberCount;
           
       }

    private init(proto: SignalServiceProtos_GroupOperation,
                 id: String,
                 avatar: String?,
                 notices:SSKProtoGroupNotice?,permissions: [SSKProtoGroupPermission]?,target: SSKProtoGroupContextTarget, members: [SSKProtoGroupMember]?) {
        self.proto = proto
        self.id = id
        self.avatar = avatar
        self.notices = notices;
        self.permissions = permissions;
        self.target = target;
        self.link = proto.linkValue
        self.members = members;
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoGroupContext {
        let proto = try SignalServiceProtos_GroupOperation(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_GroupOperation) throws -> SSKProtoGroupContext {
        guard proto.hasID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: id")
        }
        let id = proto.id

//        var avatar: SSKProtoAttachmentPointer? = nil
//        if proto.hasAvatar {
//            avatar = try SSKProtoAttachmentPointer.parseProto(proto.avatar)
//        }

        var members: [SSKProtoGroupMember]?
        members = try proto.groupMember.map{
            try SSKProtoGroupMember.parseProto($0);
        };
        // MARK: - Begin Validation Logic for SSKProtoGroupContext -

        // MARK: - End Validation Logic for SSKProtoGroupContext -
        let permissions: [SSKProtoGroupPermission]?
        permissions = try proto.perm.map { try SSKProtoGroupPermission.parseProto($0) }
        
        let notices: SSKProtoGroupNotice?
        notices = try SSKProtoGroupNotice.parseProto(proto.notices)

        let result = SSKProtoGroupContext(proto: proto,
                                          id: id,
                                          avatar: proto.avatar,
                                          notices: notices, permissions: permissions,target: SSKProtoGroupContext.SSKProtoGroupContextTargetWrap(proto.target), members: members);
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoGroupContext {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoGroupContext.SSKProtoGroupContextBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoGroupContext? {
        return try! self.build()
    }
}

#endif


// MARK: - SSKProtoPackSticker

@objc public class SSKProtoPackSticker: NSObject {

    // MARK: - SSKProtoPackStickerBuilder

    @objc public class func builder(id: UInt32) -> SSKProtoPackStickerBuilder {
        return SSKProtoPackStickerBuilder(id: id)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoPackStickerBuilder {
        let builder = SSKProtoPackStickerBuilder(id: id)
        if let _value = emoji {
            builder.setEmoji(_value)
        }
        return builder
    }

    @objc public class SSKProtoPackStickerBuilder: NSObject {

        private var proto = SignalServiceProtos_Pack.Sticker()

        @objc fileprivate override init() {}

        @objc fileprivate init(id: UInt32) {
            super.init()

            setId(id)
        }

        @objc
        public func setId(_ valueParam: UInt32) {
            proto.id = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setEmoji(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.emoji = valueParam
        }

        public func setEmoji(_ valueParam: String) {
            proto.emoji = valueParam
        }

        @objc public func build() throws -> SSKProtoPackSticker {
            return try SSKProtoPackSticker.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoPackSticker.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_Pack.Sticker

    @objc public let id: UInt32

    @objc public var emoji: String? {
        guard proto.hasEmoji else {
            return nil
        }
        return proto.emoji
    }
    @objc public var hasEmoji: Bool {
        return proto.hasEmoji
    }

    private init(proto: SignalServiceProtos_Pack.Sticker,
                 id: UInt32) {
        self.proto = proto
        self.id = id
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoPackSticker {
        let proto = try SignalServiceProtos_Pack.Sticker(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_Pack.Sticker) throws -> SSKProtoPackSticker {
        guard proto.hasID else {
            throw SSKProtoError.invalidProtobuf(description: "\(logTag) missing required field: id")
        }
        let id = proto.id

        // MARK: - Begin Validation Logic for SSKProtoPackSticker -

        // MARK: - End Validation Logic for SSKProtoPackSticker -

        let result = SSKProtoPackSticker(proto: proto,
                                         id: id)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoPackSticker {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoPackSticker.SSKProtoPackStickerBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoPackSticker? {
        return try! self.build()
    }
}

#endif

// MARK: - SSKProtoPack

@objc public class SSKProtoPack: NSObject {

    // MARK: - SSKProtoPackBuilder

    @objc public class func builder() -> SSKProtoPackBuilder {
        return SSKProtoPackBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    @objc public func asBuilder() -> SSKProtoPackBuilder {
        let builder = SSKProtoPackBuilder()
        if let _value = title {
            builder.setTitle(_value)
        }
        if let _value = author {
            builder.setAuthor(_value)
        }
        if let _value = cover {
            builder.setCover(_value)
        }
        builder.setStickers(stickers)
        return builder
    }

    @objc public class SSKProtoPackBuilder: NSObject {

        private var proto = SignalServiceProtos_Pack()

        @objc fileprivate override init() {}

        @objc
        @available(swift, obsoleted: 1.0)
        public func setTitle(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.title = valueParam
        }

        public func setTitle(_ valueParam: String) {
            proto.title = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setAuthor(_ valueParam: String?) {
            guard let valueParam = valueParam else { return }
            proto.author = valueParam
        }

        public func setAuthor(_ valueParam: String) {
            proto.author = valueParam
        }

        @objc
        @available(swift, obsoleted: 1.0)
        public func setCover(_ valueParam: SSKProtoPackSticker?) {
            guard let valueParam = valueParam else { return }
            proto.cover = valueParam.proto
        }

        public func setCover(_ valueParam: SSKProtoPackSticker) {
            proto.cover = valueParam.proto
        }

        @objc public func addStickers(_ valueParam: SSKProtoPackSticker) {
            var items = proto.stickers
            items.append(valueParam.proto)
            proto.stickers = items
        }

        @objc public func setStickers(_ wrappedItems: [SSKProtoPackSticker]) {
            proto.stickers = wrappedItems.map { $0.proto }
        }

        @objc public func build() throws -> SSKProtoPack {
            return try SSKProtoPack.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SSKProtoPack.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SignalServiceProtos_Pack

    @objc public let cover: SSKProtoPackSticker?

    @objc public let stickers: [SSKProtoPackSticker]

    @objc public var title: String? {
        guard proto.hasTitle else {
            return nil
        }
        return proto.title
    }
    @objc public var hasTitle: Bool {
        return proto.hasTitle
    }

    @objc public var author: String? {
        guard proto.hasAuthor else {
            return nil
        }
        return proto.author
    }
    @objc public var hasAuthor: Bool {
        return proto.hasAuthor
    }

    private init(proto: SignalServiceProtos_Pack,
                 cover: SSKProtoPackSticker?,
                 stickers: [SSKProtoPackSticker]) {
        self.proto = proto
        self.cover = cover
        self.stickers = stickers
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SSKProtoPack {
        let proto = try SignalServiceProtos_Pack(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SignalServiceProtos_Pack) throws -> SSKProtoPack {
        var cover: SSKProtoPackSticker? = nil
        if proto.hasCover {
            cover = try SSKProtoPackSticker.parseProto(proto.cover)
        }

        var stickers: [SSKProtoPackSticker] = []
        stickers = try proto.stickers.map { try SSKProtoPackSticker.parseProto($0) }

        // MARK: - Begin Validation Logic for SSKProtoPack -

        // MARK: - End Validation Logic for SSKProtoPack -

        let result = SSKProtoPack(proto: proto,
                                  cover: cover,
                                  stickers: stickers)
        return result
    }

    @objc public override var debugDescription: String {
        return "\(proto)"
    }
}

#if DEBUG

extension SSKProtoPack {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SSKProtoPack.SSKProtoPackBuilder {
    @objc public func buildIgnoringErrors() -> SSKProtoPack? {
        return try! self.build()
    }
}

#endif
