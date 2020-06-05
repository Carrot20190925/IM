//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation

extension TSThread{
    
    private struct TXAssociatedKeys {
            static var AtTop = "pigram_tx_thread_top";
            static var dateTime = "pigram_tx_thread_dateTime"
          ///备注名称
        }
    
    /**
    * 该会话是否被置顶
    */
   @objc
   public var tx_top: Bool {
       set {
           objc_setAssociatedObject(self, &TXAssociatedKeys.AtTop, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
       }
       get {
            guard let obj = objc_getAssociatedObject(self, &TXAssociatedKeys.AtTop) else {
                return false
            }
            return obj as! Bool
       }
    }
    /**
    * 该会话被置顶 的时间
    */
    @objc
    public var tx_top_date: UInt64 {
         set {
             objc_setAssociatedObject(self, &TXAssociatedKeys.dateTime, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
         }
         get {
            guard let obj = objc_getAssociatedObject(self, &TXAssociatedKeys.AtTop) else {
                           return 0
                       }
            return obj as! UInt64
         }
     }
}



extension TSGroupModel{
    func txSetup(oldModel:TSGroupModel) {
        self.notices = oldModel.notices
        self.blackList = oldModel.blackList
        self.txGroupType = oldModel.txGroupType
        self.groupStatus = oldModel.groupStatus
        self.avatar = oldModel.avatar
        self.permRightBans = oldModel.permRightBans
        self.membersCount = oldModel.membersCount
        self.notificationMutes = oldModel.notificationMutes
        self.linkString = oldModel.linkString
        
    }
}
