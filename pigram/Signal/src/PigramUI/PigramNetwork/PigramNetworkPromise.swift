//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
import PromiseKit
class PigramNetworkPromise {
     //MARK:- 搜索好友
     /**
      搜索好友
      - parameter parameters: <#param#>
      - returns: <#return#>
      */
    static func pgAddFriendPromise(params: Dictionary <String,Any>) -> Promise<Any?> {
          let promise = Promise<Any?> { resolver in
            PigramNetworkMananger.pgAddFriendNetwork(params:params,success: { responseObject in
                     resolver.fulfill((responseObject))
             }, failure: resolver.reject)
           }
         return promise
     }
    
    static func getOSSTokenPromise() -> Promise<Any?>{
        let promise = Promise<Any?> { resolver in
           PigramNetworkMananger.getOSSTokenRequest(success: { responseObject in
                    resolver.fulfill((responseObject))
            }, failure: resolver.reject)
          }
        return promise
    }
    
    
}
