//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
@objc
public class PigramGroupNotice: NSObject,NSCopying,NSSecureCoding{
    
    public static var supportsSecureCoding: Bool = true
    //MARK:-  通过对象获取proto
    @objc public func getNoticeProto() -> SSKProtoGroupNotice?{
        let builder =  SSKProtoGroupNotice.builder()
        builder.setId(self.id)
        builder.setContent(self.content)
        guard let noticeProto = try? builder.build() else{
            return nil
        }
        return noticeProto
    }
    //MARK:-  通过proto 获取对象
    @objc public static func initFrom(protoNotice:SSKProtoGroupNotice) -> PigramGroupNotice?{
        let notice = PigramGroupNotice.init(id:protoNotice.id)
        notice.content = protoNotice.content
        notice.updatebyUserId = protoNotice.sender?.id;
        notice.updatebyUserName = protoNotice.sender?.name;
        notice.updatebyUserAvatar = protoNotice.sender?.avatar;
        notice.lastUpdate = protoNotice.updateTimestamp;

        return notice
    }
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let notice = PigramGroupNotice.init(id: self.id)
        notice.id = self.id
        notice.content = self.content
        notice.updatebyUserId = self.updatebyUserId;
        notice.updatebyUserName = self.updatebyUserName;
        notice.updatebyUserAvatar = self.updatebyUserAvatar;
        notice.lastUpdate = self.lastUpdate;
        notice.status = self.status;
        return notice;
    }
    


    // 0 展示 1 隐藏
    @objc public var status : UInt8 = 0
    @objc public var id : String!
    @objc public var lastUpdate : UInt64 = 0
    @objc public var content : String?
    @objc public var updatebyUserName : String?
    @objc public var updatebyUserAvatar : String?
    @objc public var updatebyUserId : String?
    @objc public init(id : String) {
        self.id = id
        super.init()
    }
//    @objc
//    public override init() {
//        super.init()
//    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(lastUpdate, forKey: "serverTime")
        aCoder.encode(content, forKey: "content")
        aCoder.encode(updatebyUserName, forKey: "updatebyUserName")
        aCoder.encode(updatebyUserAvatar, forKey: "updatebyUserAvatar")
        aCoder.encode(updatebyUserId, forKey: "updatebyUserId")
        aCoder.encode(status, forKey: "status")


    }
    
    required public init?(coder deCoder: NSCoder) {
        status = (deCoder.decodeObject(forKey: "status") as? UInt8) ?? 0
        id = deCoder.decodeObject(forKey: "id") as? String
        lastUpdate = (deCoder.decodeObject(forKey: "lastUpdate") as? UInt64) ?? 0
        content = deCoder.decodeObject(forKey: "content") as? String
        updatebyUserName = deCoder.decodeObject(forKey: "updatebyUserName") as? String
        updatebyUserAvatar = deCoder.decodeObject(forKey: "updatebyUserAvatar") as? String
        updatebyUserId = deCoder.decodeObject(forKey: "updatebyUserId") as? String

    }
    

    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherMember = object as? PigramGroupNotice else {
            return false
        }

        return isEqualToMember(otherMember)
    }

    @objc
    public func isEqualToMember(_ otherMember: PigramGroupNotice?) -> Bool {
        guard let otherMember = otherMember else {
            return false
        }
        return otherMember.id == id &&
            otherMember.content == content &&
            otherMember.status == status;
    }
    


}
