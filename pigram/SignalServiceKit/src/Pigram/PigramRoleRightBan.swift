//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
//MARK:-  群角色 权限管理类
@objc
public class PigramRoleRightBan: NSObject,NSCopying,NSSecureCoding {
//PigramRoleRightBan
    
    public static var supportsSecureCoding: Bool = true
    //MARK:-  通过对象获取proto
    @objc public func getProtoBan() -> SSKProtoGroupPermission?{
        let builder =  SSKProtoGroupPermission.builder()
        builder.setRole(self.role)
        builder.setRightBan(self.groupRightBan)

        guard let roleBan = try? builder.build() else{
            return nil
        }
        return roleBan
    }
    //MARK:-  通过proto 获取对象
    @objc public static func getGroupRoleBan(protoRoleBan:SSKProtoGroupPermission) -> PigramRoleRightBan?{
        let roleBan = PigramRoleRightBan.init()
        roleBan.role = protoRoleBan.role
        roleBan.groupRightBan = protoRoleBan.rightBan
        return roleBan
    }
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let roleBan = PigramRoleRightBan.init()
        roleBan.role = self.role
        roleBan.groupRightBan = self.groupRightBan
        return roleBan;
    }
    


    // 0 群主 1 管理员 2 普通成员
    @objc public var role : UInt32 = 2
    @objc public var groupRightBan : UInt32 = 0


    @objc public var permissionType: PigramMemberPerm {
        
        get {
            return PigramMemberPerm.init(rawValue: self.groupRightBan);
        }
        
    }
    
    @objc
    public override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(role, forKey: "perm")
        aCoder.encode(groupRightBan, forKey: "memberRightBan")


    }
    
    required public init?(coder deCoder: NSCoder) {
        role = deCoder.decodeObject(forKey: "perm") as! UInt32
        groupRightBan = deCoder.decodeObject(forKey: "memberRightBan") as! UInt32

    }
    

    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherMember = object as? PigramRoleRightBan else {
            return false
        }

        return isEqualToMember(otherMember)
    }

    @objc
    public func isEqualToMember(_ otherMember: PigramRoleRightBan?) -> Bool {
        guard let otherMember = otherMember else {
            return false
        }
        return otherMember.groupRightBan == groupRightBan &&
            otherMember.role == role;
    }
    


    @objc
    public func isOwner() -> Bool{
        return self.role == 0
    }
    @objc
    public func isManager() -> Bool{
       return (self.role == 1 || self.role == 0)
    }
    @objc
    public func isMember() -> Bool{
        return self.role == 2
    }

}
