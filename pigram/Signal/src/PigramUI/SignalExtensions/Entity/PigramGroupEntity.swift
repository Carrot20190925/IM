//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit


/**
 * 群组实体对象
 */
@objcMembers public class PigramGroupEntity: NSObject {

    public let groupId: String;
    public let groupName: String;
    public var avatar: String?;
    public let groupStatus: TXGroupType;
    
    required init(id: String, name: String, status: TXGroupType) {
        self.groupId = id;
        self.groupName = name;
        self.groupStatus = status;
        super.init();
    }
    
    static func initWithGroupModel(_ model: TSGroupModel) -> PigramGroupEntity {
        
        let entity = PigramGroupEntity.init(id: model.groupId, name: model.groupName ?? "", status: model.txGroupType);
        entity.avatar = model.avatar;
        return entity;
    }
}

