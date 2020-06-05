//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
import PromiseKit

extension UIViewController {
    public func popGestureClose(){
        guard let nav = self.navigationController else {
            return
        }
        let respond = nav.responds(to: #selector(getter: nav.interactivePopGestureRecognizer))
        guard let supView = nav.interactivePopGestureRecognizer?.view else {
            return
        }
        guard let gestures = supView.gestureRecognizers else {
            return
        }
        if respond {
            for popGesture in gestures {
                popGesture.isEnabled = false
            }
        }
       
    }
    
    public func popGestureOpen(){
          guard let nav = self.navigationController else {
              return
          }
          let respond = nav.responds(to: #selector(getter: nav.interactivePopGestureRecognizer))
          guard let supView = nav.interactivePopGestureRecognizer?.view else {
              return
          }
          guard let gestures = supView.gestureRecognizers else {
              return
          }
          if respond {
              for popGesture in gestures {
                  popGesture.isEnabled = true
              }
          }
         
      }
}


extension OWSProfileManager{
    //    public func updateNickName(nickName:NSString?,avatarUrlPath:NSString?,avtarFileName:NSString?,image:UIImage?){
    //
    //    }
}

extension ECKeyPair{
//    public func getKeyPair(privateKey:String,publickKey:String){
//        let privateData = NSData.init(fromBase64String: privateKey as String)
//        let publickData = NSData.init(fromBase64String: publickKey as String)
//        let keyPair = ECKeyPair.init(coder: <#T##NSCoder#>)
//    }
}

extension AccountManager{
    func txEnsurePhoneNumberRegister(phoneNumber: String) -> Promise<Any?> {
         guard phoneNumber.count > 0 else {
                let error = OWSErrorWithCodeDescription(.userError,
                                                        NSLocalizedString("REGISTRATION_ERROR_BLANK_VERIFICATION_CODE",
                                                                          comment: "alert body during registration"))
                return Promise(error: error)
            }
         let promise = Promise<Any?> { resolver in
            PigramNetworkMananger.pgEnsureUserExistNetwork(phoneNumber: phoneNumber, success: { (responseObject) in
                        resolver.fulfill((responseObject))

            }, failure: resolver.reject(_:))           
          }
        return promise
    }
}
extension TSAccountManager{
    enum TXNetError: Error {
        case custom(code:Int)
        case system(error:Error)
    }

    
//    func pgLogoutNetwork(success: @escaping(_ response : Any?) -> Void,failure: @escaping(_ error : Error) -> Void) {
//        if let request = OWSRequestFactory.pgLogoutRequest() {
//            SSKEnvironment.shared.networkManager.makeRequest(request, success: { (task, respone) in
//                success(respone)
//            }) { (take, error) in
//                failure(error)
//            }
//        }
//    }
    func txEnsurePhoneNumberRegister(phoneNumber:String,success: @escaping(_ response : Any?) -> Void,failure: @escaping(_ error : Error) -> Void) {
        if let request = OWSRequestFactory.txEnsurePhoneNumberResister(phoneNumber: phoneNumber)
        {
            SSKEnvironment.shared.networkManager.makeRequest(request, success: { (task, response) in
                switch task.statusCode() {
                    case 200:
                        success(response)
                    break
                default:
                    do {
                        let error = TXNetError.custom(code:task.statusCode())
                        failure(error)
                     }
                    break
                }
            }) { (task, error) in
                failure(error)
            }
        }
       
    }
    
}
extension ProfileManagerProtocol{
    
}
