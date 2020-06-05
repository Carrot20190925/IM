//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
import PromiseKit
class PigramLoginOrRegisterManager: NSObject {
    //MARK:- 校验用户是否存在
    /**
     校验用户是否存在
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
   static func pgEnsurePhoneNumberRegister(phoneNumber: String) -> Promise<Any?> {
         guard phoneNumber.count > 0 else {
                let error = OWSErrorWithCodeDescription(.userError,
                                                        NSLocalizedString("请输入手机号码！",
                                                                          comment: ""))
                return Promise(error: error)
            }
         let promise = Promise<Any?> { resolver in
            PigramNetworkMananger.pgEnsureUserExistNetwork(phoneNumber: phoneNumber, success: { (responseObject) in
                    resolver.fulfill((responseObject))
            }, failure: resolver.reject)
          }
        return promise
    }
    
    
    
    
     //MARK:- 注册接口
     /**
      注册接口
      - parameter parameters: <#param#>
      - returns: <#return#>
      */
    static func pgRegister(params: Dictionary <String,Any>) -> Promise<Any?> {
          let promise = Promise<Any?> { resolver in
            PigramNetworkMananger.pgRegisterNetwork(params:params,success: { responseObject in
                    
                     resolver.fulfill((responseObject))
             }, failure: resolver.reject)
           }
         return promise
     }
        //MARK:- 校验验证码
        /**
         校验验证码
         - parameter parameters: <#param#>
         - returns: <#return#>
         */
       static func pgVerifyCode(params: Dictionary <String,Any>) -> Promise<Any?> {
             let promise = Promise<Any?> { resolver in
               PigramNetworkMananger.pgCheckVerificationCodeNetwork(params:params,success: { responseObject in
                        resolver.fulfill((responseObject))
                }, failure: resolver.reject)
              }
            return promise
        }
     //MARK:- 登录接口
     /**
      登录接口
      - parameter parameters: <#param#>
      - returns: <#return#>
      */
    static func pgLogin(params: Dictionary <String,Any>,isPassword:Bool) -> Promise<Any?> {
          let promise = Promise<Any?> { resolver in
            if isPassword{
                PigramNetworkMananger.pgLoginPasswordNetwork(params:params,success: { responseObject in
                         resolver.fulfill((responseObject))
                 }, failure: resolver.reject)
            }else
            {
                PigramNetworkMananger.pgLoginVerificationCodeNetwork(params:params,success: { responseObject in
                         resolver.fulfill((responseObject))
                 }, failure: resolver.reject)
            }

           }
         return promise
     }
     //MARK:- 修改密码
     /**
     修改密码
     - parameter parameters: <#param#>
     - returns: <#return#>
      */
    static func pgChangePassword(params: Dictionary <String,Any>) -> Promise<Any?> {
          let promise = Promise<Any?> { resolver in
            PigramNetworkMananger.pgChangePasswordNetwork(params:params,success: { responseObject in
                     resolver.fulfill((responseObject))
             }, failure: resolver.reject)
           }
         return promise
     }
    
    
     //MARK:-  web扫码登录
     /**
     web扫码登录
     - parameter parameters: <#param#>
     - returns: <#return#>
      */
    static func pgScanWebQRLogin(params: Dictionary <String,Any>) -> Promise<Any?> {
          let promise = Promise<Any?> { resolver in
            
            PigramNetworkMananger.pgControlLoginWebNetwork(params:params,success: { responseObject in
                     resolver.fulfill((responseObject))
             }, failure: resolver.reject)
           }
        return promise
     }
    
     //MARK:-  web扫码登录
     /**
     web扫码登录
     - parameter parameters: <#param#>
     - returns: <#return#>
      */
    static func pgSetAuthorPromise(params: Dictionary <String,Any>) -> Promise<Any?> {
          let promise = Promise<Any?> { resolver in
            
            PigramNetworkMananger.pgGetScanDeviceAuthorNetwork(params:params,success: { responseObject in
                     resolver.fulfill((responseObject))
             }, failure: resolver.reject)
           }
        return promise
     }
    
    
    
    
}
