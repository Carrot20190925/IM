//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

@objc
public class PigramGroupMember: NSObject,NSCopying,NSSecureCoding {

    public static var supportsSecureCoding: Bool = true
    //MARK:-  通过对象获取proto
    @objc public func getProtoMember() -> SSKProtoGroupMember?{
       let builder =  SSKProtoGroupMember.builder()
        builder.setId(self.userId)
        builder.setRoleInGroup(UInt32(self.perm))
        builder.setRightInGroup(UInt32(self.memberRightBan))
        builder.setName(self.nickname)
        builder.setAvatar(self.userAvatar)
        guard let member = try? builder.build() else{
            return nil
        }
        return member
    }
    //MARK:-  通过proto 获取对象
    @objc public static func getGroupMember(protoMember:SSKProtoGroupMember?) -> PigramGroupMember?{
        guard let protoMember = protoMember else { return nil }
        guard let userId = protoMember.id else {
            return nil
        }
        let member = PigramGroupMember.init(userId: userId)
        member.userAvatar = protoMember.avatar
        member.perm = protoMember.roleInGroup
        member.memberRightBan = protoMember.rightInGroup
        member.nickname = protoMember.name
        member.memberStatus = protoMember.memberStatus
        return member
    }
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let member = PigramGroupMember.init(userId: self.userId)
        //        address.userid = self.userid;
        member.perm = self.perm
        member.memberRightBan = self.memberRightBan
        member.nickname = self.nickname
        member.userAvatar = self.userAvatar
        return member;
    }
    
    
    @objc
    public func buildServiceAddress() -> SignalServiceAddress? {
        if self.userId.count == 0 {
            return nil;
        }
        
        return SignalServiceAddress.init(phoneNumber: self.userId);
    }

    // 0 群主 1 管理员 2 普通成员
    @objc public var perm : UInt32 = 2
    //禁言 15 1: txt, 2:sticker,4:autio,8:vedio
    @objc public var memberRightBan : UInt32 = 0
    // 1. 正常 2.拉黑 / 在2.1.0版本之前用来表示禁言
    @objc public var memberStatus : UInt32 = 1
    @objc public var userId : String!
    @objc public var nickname : String?
    @objc public var userAvatar : String?
    /**
     * 我的群昵称
     */
    @objc public var remarkName : String?
    
    /**
     * 好友备注昵称
     */
    @objc public var friendRemarkName: String? {
        
        get {
            var remarkName: String?;
                
            SSKEnvironment.shared.databaseStorage.read { (transaction) in
                let profile = OWSUserProfile.getFor(SignalServiceAddress.init(phoneNumber: self.userId), transaction: transaction)
                remarkName = profile?.remarkName
            }
            return remarkName;
        }
        
    }
    /**
     * 好友昵称
     */
    @objc public var friendNickName: String? {
        
        get {
            var nickName: String?;
                
            SSKEnvironment.shared.databaseStorage.read { (transaction) in
                let profile = OWSUserProfile.getFor(SignalServiceAddress.init(phoneNumber: self.userId), transaction: transaction)
                nickName = profile?.profileName
            }
            
            return nickName;
        }
    }
    @objc
    public init(userId:String){
        self.userId = userId
        super.init()
    }

    
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(perm, forKey: "perm")
        aCoder.encode(memberRightBan, forKey: "memberRightBan")
        aCoder.encode(memberStatus, forKey: "memberStatus")

        aCoder.encode(nickname, forKey: "nickname")
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(userAvatar, forKey: "userAvatar")
        aCoder.encode(remarkName, forKey: "remarkName")


    }
    
    required public init?(coder deCoder: NSCoder) {
        perm = deCoder.decodeObject(forKey: "perm") as! UInt32
        memberRightBan = deCoder.decodeObject(forKey: "memberRightBan") as! UInt32
        memberStatus = (deCoder.decodeObject(forKey: "memberStatus") as? UInt32) ?? 1
        nickname = deCoder.decodeObject(forKey: "nickname") as? String
        userId = (deCoder.decodeObject(forKey: "userId") as? String)
        userAvatar = deCoder.decodeObject(forKey: "userAvatar") as? String
        remarkName = deCoder.decodeObject(forKey: "remarkName") as? String
    }
    
    @objc func getRole() -> PigramGroupRole{
        return PigramGroupRole.init(rawValue: self.perm) ?? .member
    }
    @objc func getRightBan() -> PigramMemberPerm{
        return PigramMemberPerm.init(rawValue: self.memberRightBan)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherMember = object as? PigramGroupMember else {
            return false
        }

        return isEqualToMember(otherMember)
    }

    @objc
    public func isEqualToMember(_ otherMember: PigramGroupMember?) -> Bool {
        guard let otherMember = otherMember else {
            return false
        }
        return otherMember.userId == userId &&
            otherMember.perm == perm &&
            otherMember.userAvatar == userAvatar &&
            otherMember.nickname == nickname &&
            otherMember.memberRightBan == memberRightBan &&
            otherMember.memberStatus == memberStatus &&
            otherMember.remarkName == remarkName;
    }
    

    
    /**
     * 优先显示好友的昵称 依次群昵称 、 个人昵称
     */
    @objc
    public func getRemarkNameInfo() -> String{
        
        if let displayName = self.friendRemarkName, displayName.count > 0 {
            if let _nickName = self.nickname, _nickName.count > 0 {
                return displayName + "(\(_nickName))";
            }
            return displayName
        }
        
        if let displayName = self.remarkName, displayName.count > 0 {
            if let _nickName = self.nickname, _nickName.count > 0 {
                return displayName + "(\(_nickName))";
            }
            return displayName
        }
        
        if let displayName = self.nickname, displayName.count > 0 {
            return displayName;
        }
        return "***"
    }

    @objc
    public func isOwner() -> Bool{
        
        return self.perm == 0
    }
    @objc
    public func isManager() -> Bool{
       return (self.perm == 1 || self.perm == 0)
    }
    @objc
    public func isMember() -> Bool{
        return self.perm == 2
    }

    
}
