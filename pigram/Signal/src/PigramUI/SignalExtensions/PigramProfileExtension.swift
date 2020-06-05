//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation
extension OWSProfileManager {
    open func pgUpdateProfile(address:SignalServiceAddress,profileName:String?,avatarUrlPath:String?) -> Void {
        
        guard address.isValid else {
            owsFailDebug("address.isValid is no")
            return
        }
        DispatchQueue.global().async {
            var userProfile : OWSUserProfile?
            kSignalDB.write { (transaction) in
                userProfile = OWSUserProfile.getOrBuild(for: address, transaction: transaction)
                userProfile?.update(withProfileName: profileName, username: nil, avatarUrlPath: avatarUrlPath, transaction: transaction, completion: nil)
                
            }
            //carrot
            if let avatar = avatarUrlPath,avatar.length != 0,userProfile?.avatarFileName == nil{
//                self.
            }            
        }
    }
}

