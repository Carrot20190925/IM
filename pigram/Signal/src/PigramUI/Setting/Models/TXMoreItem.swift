//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXMoreItem: NSObject {

     class func setupHeader(frame:CGRect) -> TXMoreHeadView {
     
        let tableHeadView:TXMoreHeadView = TXMoreHeadView.init(frame: frame)
//            Bundle.main.loadNibNamed("TXMoreHeadView", owner: nil, options: nil)?.first as! TXMoreHeadView
        tableHeadView.frame = frame
        guard let phoneNum = TSAccountManager.localNumber else {
            return tableHeadView
        }
        let phoneNumber = PhoneNumber.bestEffortFormatPartialUserSpecifiedText(toLookLikeAPhoneNumber: phoneNum)      
        tableHeadView.phoneLabel.text = phoneNumber
      
        return tableHeadView
        
    }
    
    
    
    class func updateHeaderUI(headView : TXMoreHeadView){
        let localMgr = OWSProfileManager.shared()
        let profile : OWSUserProfile = localMgr.localUserProfile()
        let avatarImage = profile.getContactAvatarImage()
        headView.iconImageView.image = avatarImage
        headView.userNameLabel.text = localMgr.localProfileName()
    }
    
   
    
}
