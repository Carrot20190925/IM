//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
import PromiseKit
extension TSRequest{
    
}
extension OWSRequestFactory {
    static func txEnsurePhoneNumberResister(phoneNumber:String) -> TSRequest? {
        let url = URL.init(string: "/v1/accounts/find/" + phoneNumber)
        guard let ensureUrl = url else {
            return nil
        }
        
        let request = TSRequest.init(url: ensureUrl, method: "GET", parameters: [:])
        request.shouldHaveAuthorizationHeaders = false;
        return request
    }
    
//    static func pgLogoutRequest() -> TSRequest?{
//        guard let url  = URL.init(string: "/v1/accounts/logout/") else {
//            return nil
//        }
//        let request = TSRequest.init(url: url, method: "PUT", parameters: [:])
//        request.authUsername = TSAccountManager.localUserId
//        request.authPassword = TSAccountManager.sharedInstance().storedServerAuthToken();
//        return request
//    }
    
}



extension TSGroupModel{
    @objc
    func getAvatarUrl() -> String? {
        guard let avatar = self.avatar else {
            return nil
        }
        if avatar.hasPrefix("http") {
            return avatar
        }
        let cdnsServer = PigramUploadConfig.share.bucket
        return "\(cdnsServer)/\(avatar)"
    }
}
