//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
enum PigramTXError : Error {
    case request
    case des(code:Int,des:String)
}

typealias PigramTXNetworkSuccess = (_ reponse : Any?) -> Void
typealias PigramTXNetworkFailure = (_ error : Error) -> Void

@objc
class PigramNetworkMananger: NSObject {
//    static func pgLogoutNetwork(success: @escaping(_ response : Any?) -> Void,failure: @escaping(_ error : Error) -> Void) {
//        if let request = OWSRequestFactory.pgLogoutRequest() {
//            SSKEnvironment.shared.networkManager.makeRequest(request, success: { (task, respone) in
//                switch task.statusCode(){
//                case 200:
//                    success(respone)
//                    break
//                default:
//                    let pgError = PigramTXError.des(code: task.statusCode(), des: "貌似逻辑错误")
//                    failure(pgError)
//                    break
//                }
//            }) { (take, error) in
//                if let ensureError = error as? NSError{
//                    let pgError = PigramTXError.des(code: ensureError.code, des: ensureError.localizedDescription)
//                    failure(pgError)
//                    return
//                }
//                failure(error)
//
//            }
//        }
//    }
    
    
    static func pgRequest(_ request : TSRequest, success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        SSKEnvironment.shared.networkManager.makeRequest(request, success: { (task, respone) in
            switch task.statusCode(){
            case 200:
                fallthrough
            case 204:
                DispatchQueue.main.async {
                    success(respone)
                }
            default:
                let error = PigramTXError.request
                DispatchQueue.main.async {
                    failure(error)
                }
                break
            }
        }) { (take, error) in
            DispatchQueue.main.async {
                failure(error)
            }
        }

    }
    
    
    
    static func makeFormartFailure(task:URLSessionDataTask,error:Error,failure: @escaping PigramTXNetworkFailure){
        
    }
    
    
    //MARK:- 创建群请求
    /**
     创建群请求
     - parameter group_title: 群名称
     - parameter groupMembers: 群成员数组 里面是对象{userId:userId}  数量大于3
     - returns: <#return#>
     */
    static func pgCreateGroupsNetwork(params:Dictionary<String ,Any>?, success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
           guard let request = PigramRequestFactory.pgCreateGroupsRequest(params: params) else{
               let request = PigramTXError.request
               failure(request)
               return
            }
           self.pgRequest(request, success: success, failure: failure)
      }

      //MARK:-  获取群列表
      /**
       获取群列表
       - parameter parameters: <#param#>
       - returns: <#return#>
       */
      static func pgGetGroupsListNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
         guard let request = PigramRequestFactory.pgGetGroupsListRequest(params: params) else{
             let request = PigramTXError.request
             failure(request)
             return
          }
         self.pgRequest(request, success: success, failure: failure)
      }


      //MARK:-  获取群信息
      /**
       获取群信息
       - parameter parameters: <#param#>
       - returns: <#return#>
       */
      static func pgGetGroupInfoNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
         guard let request = PigramRequestFactory.pgGetGroupInfoRequest(params: params) else{
             let request = PigramTXError.request
             failure(request)
             return
          }
         self.pgRequest(request, success: success, failure: failure)
      }
     //MARK:-  设置管理员
      /**
       设置管理员
       - parameter parameters: <#param#>
       - returns: <#return#>
       */
      static func pgSetupManagersNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
         guard let request = PigramRequestFactory.pgSetupManagersRequest(params: params) else{
             let request = PigramTXError.request
             failure(request)
             return
          }
         self.pgRequest(request, success: success, failure: failure)
      }
      //MARK:-  转让群
      /**
       转让群
       - parameter parameters: <#param#>
       - returns: <#return#>
       */
      static func pgTransferGroupNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
         guard let request = PigramRequestFactory.pgTransferGroupRequest(params: params) else{
             let request = PigramTXError.request
             failure(request)
             return
          }
         self.pgRequest(request, success: success, failure: failure)
        
    }
      //MARK:-  创建群公告
      /**
       创建群公告
       - parameter parameters:
       - returns:
       */
      static func pgCreateGroupAnnouncementNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
          guard let request = PigramRequestFactory.pgCreateGroupAnnouncementRequest(params: params) else{
              let request = PigramTXError.request
              failure(request)
              return
           }
          self.pgRequest(request, success: success, failure: failure)
        
    }
      //MARK:-  编辑群公告
      /**
       编辑群公告
       - parameter parameters:
       - returns:
       */
      static func pgEditGroupAnnouncementNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
          guard let request = PigramRequestFactory.pgEditGroupAnnouncementRequest(params: params) else{
              let request = PigramTXError.request
              failure(request)
              return
           }
          self.pgRequest(request, success: success, failure: failure)
    }
      //MARK:-  获取群公告列表
      /**
       获取群公告列表
       - parameter parameters: 参数
       - returns: 返回值
       */
      static func pgGetAnnouncementListNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
          guard let request = PigramRequestFactory.pgGetAnnouncementListRequest(params: params) else{
              let request = PigramTXError.request
              failure(request)
              return
           }
          self.pgRequest(request, success: success, failure: failure)
      }
    //MARK:- 管理员或群主加好友入群
    /**
     管理员或群主加好友入群
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgManagerAddFriendJoinGroupNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgManagerAddFriendJoinGroupRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 普通成员请求入群
    /**
     普通成员请求入群
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgMemberJoinGroupNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgMemberJoinGroupRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 设置群头像
    /**
     设置群头像
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgSetupGroupAvatarNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgSetupGroupAvatarRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 设置群名称
    /**
     设置群名称
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgSetupGroupNameNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgSetupGroupNameRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 离群请求
    /**
     离群请求
     - parameter groupId: 群id
     - returns: <#return#>
     */
    static func pgQuitGroupNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgQuitGroupRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 解散群请求
    /**
     解散群请求
     - parameter groupId: 群id
     - returns: <#return#>
     */
    static func pgDismissGroupNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgDismissGroupRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    
    //MARK:- 删除群成员
    /**
     删除群成员
     - parameter groupId: 群id
     - returns: <#return#>
     */
    @objc
    static func pgDeleteGroupMemberNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgdDeleteGroupMemberRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 申请入群
    /**
     申请入群
     - parameter groupId: 群id
     - returns: <#return#>
     */
    static func pgApplyJoinGroupNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgApplyJoinGroupRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 同意入群请求
    /**
     同意入群请求
     - parameter groupId: 群id
     - returns: <#return#>
     */
    static func pgAgreeJoinGroupNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgAgreeJoinGroupRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }

    //MARK:- 查询群成员
    /**
     查询群成员
     - parameter groupId: 群id
     - parameter limit: 长度size
     - parameter offset: 偏移量
     - returns: <#return#>
     */
    static func pgFindGroupMemberNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgFindGroupMemberRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 设置成员在群里的昵称
    /**
     设置成员在群里的昵称
     - parameter groupId: 群id
     - parameter userId:
     - parameter remarkName:
     - returns: <#return#>
     */

    static func pgSetupGroupMemberRemarkNameNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgSetupGroupMemberRemarkNameRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 拉黑群成员
    /**
     拉黑群成员
     - parameter groupId: 群id
     - parameter groupMembers:

     - returns: <#return#>
     */

    @objc
    static func pgAddBlackGroupMembersNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgAddBlackGroupMembersRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 取消拉黑群成员
    /**
     取消拉黑群成员
     - parameter groupId: 群id
     - parameter groupMembers:
     - returns: <#return#>
     */

    static func pgRemoveBlackGroupMembersNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgRemoveBlackGroupMembersRequest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }

    //MARK:- 群全体禁言
    /**
    - parameter groupId: 群id
    - parameter isBan : 是否禁言
    - returns: tsrequest
    */
    static func pg_blockAllConversation(groupID: String, isBan: Bool,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pg_blockAllConversation(groupID: groupID, isBan: isBan) else{
            let request = PigramTXError.request
            failure(request)
            return
        }
        self.pgRequest(request, success: success, failure: failure)
    }

    //MARK:- 修改群范围通知
    /**
    - parameter groupId: 群id
    - parameter id : 1:踢人通知群成员,2:退群通知群成员,3:禁言通知群成员
    - parameter action : 1:通知群成员(默认),2:不通知群成员
    - returns: tsrequest
    */
    static func pg_setGroupNotificationMutes(groupID: String, id: Int, action: Int,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        let param: [String : Any]  = [
            "groupId": groupID,
            "groupNotiMute" : [
                [
                    "id": id,
                    "action" : action
                ]
            ]
        ];
        let url  = URL.init(string: "/v1/groups/update_noti_mute")!
        let request = TSRequest.init(url: url, method: "PUT", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }

    //MARK:- 对会话进行置顶
    static func pg_setStickForSession(id: String, flag: Bool,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        let param: [String : Any]  = [ "stickList": [id], "flag": flag];
        let url  = URL.init(string: "/v1/accounts/stick")!
        let request = TSRequest.init(url: url, method: "PUT", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
       }
    
    //MARK:- 获取个人信息 包含了被置顶的会话
    @objc public
    static func pg_getMyInfo(success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        let param: [String : Any]  = [:];
        let url  = URL.init(string: "/v1/accounts/find_self")!
        let request = TSRequest.init(url: url, method: "GET", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
      
    
}

// MARK: 群分组
extension PigramNetworkMananger {
    
    //MARK:- 获取所有群分组
    static func pg_groups_getAllGroups(success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        let param: [String : Any]  = [:];
        let url  = URL.init(string: "/v1/bunches")!
        let request = TSRequest.init(url: url, method: "GET", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    
    //MARK:- 创建群分组
    static func pg_groups_createGroups(name: String, ids: [String],success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        let param: [String : Any]  = [ "title": name, "ids": ids];
        let url  = URL.init(string: "/v1/bunches")!
        let request = TSRequest.init(url: url, method: "POST", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    
    // MARK: - 添加会话到分组
    /**
     * parameter ids 群组id
     */
    static func pg_groups_addNewSession(groupsID: String,ids: [String], success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        
        let param: [String : Any]  = ["bunchId":groupsID, "ids": ids];
        let url  = URL.init(string: "/v1/bunches/add")!
        let request = TSRequest.init(url: url, method: "PUT", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    // MARK: - 删除群组
    /**
     * parameter 群组id
     */
    static func pg_groups_removeGroups(groupsID: String ,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        
        let param: [String : Any]  = ["bunchId":groupsID];
        let url  = URL.init(string: "/v1/bunches")!
        let request = TSRequest.init(url: url, method: "DELETE", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    
    // MARK: - 删除群聊
    /**
     * parameter 群组id
     */
    static func pg_groups_removeSession(groupsID: String,ids: [String], success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        
        let param: [String : Any]  = ["bunchId":groupsID, "ids": ids];
        let url  = URL.init(string: "/v1/bunches/remove")!
        let request = TSRequest.init(url: url, method: "PUT", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    
    
    // MARK: - 通过旧密码修改密码请求
    /**
     * parameter oldPassword
     * parameter newPassword
     *
     */
    static func pg_chagnePassword(oldPassword : String,newPassword: String, success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        guard let new = newPassword.md5Base64() else{
            OWSAlerts.showAlert(title: "新密码格式不对")
            return
        }
        guard let old = oldPassword.md5Base64() else {
            OWSAlerts.showAlert(title: "旧密码格式不对")
            return
        }
        let param = ["oldPassword":old,"newPassword":new]
        let url  = URL.init(string: "/v1/accounts/change_password")!
        let request = TSRequest.init(url: url, method: "PUT", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    // MARK: - 通过密码修改手机号
    /**
     * parameter oldPassword
     * parameter newPassword

     *
     */
    static func pg_chagnePhoneWithPassword(password : String,newNumberCode: String,newNumber:String, success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        guard let pass = password.md5Base64() else{
            OWSAlerts.showAlert(title: "密码格式不对")
            return
        }
        let param = ["password":pass,"newNumberCode":newNumberCode,"newNumber":newNumber]
        let url  = URL.init(string: "/v1/accounts/change_number_by_password")!
        let request = TSRequest.init(url: url, method: "PUT", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    // MARK: - 通过验证码修改手机号
    /**
     *
     */
    static func pg_chagnePhoneWithCode(oldNumberCode : String,newNumberCode: String,newNumber:String, success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        let param = ["oldNumberCode":oldNumberCode,"newNumberCode":newNumberCode,"newNumber":newNumber]
        let url  = URL.init(string: "/v1/accounts/change_number_by_code")!
        let request = TSRequest.init(url: url, method: "PUT", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    
    // MARK: - 校验密码是否正确
    /**
     - parameter parameters: password

     */
    static func pg_VerifyPassword(_ password : String, success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        guard let pass = password.md5Base64() else {
            return
        }
        let param = ["password":pass]
        let url  = URL.init(string: "/v1/accounts/validate_password")!
        let request = TSRequest.init(url: url, method: "PUT", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    // MARK: - 创建短链接接口
    /**
     创建或更新短链接, 如果groupId为空, 则为自己创建短链接, 短链接验证正则表达式为[A-Za-z0-9_-]{3,32}
     - parameter parameters: password

     */
    static func pg_createLink(_ linkValue : String,groupId : String?, success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        
        var param = ["linkValue":linkValue]
        if let group = groupId {
            param["groupId"] = group
        }
        let url  = URL.init(string: "/v1/profile/link")!
        let request = TSRequest.init(url: url, method: "PUT", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    // MARK: - 根据短链接获取群或个人信息
    /**
     根据短链接获取群或个人信息
     - parameter parameters: linkValue

     */
    @objc
    static func pg_getInfoWithLink(_ linkValue : String, success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        

        let url  = URL.init(string: "/v1/profile/link/\(linkValue)")!
        let request = TSRequest.init(url: url, method: "GET", parameters:[:])
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    // MARK: - 校验短链接
    /**
     校验短链接 如果groupid 为空则校验的是
     - parameter parameters: linkValue
     - parameter parameters: groupId

     */
    static func pg_checkLink(_ linkValue : String,groupId : String?, success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        
        var param = ["linkValue":linkValue]
        if let group = groupId {
            param["groupId"] = group
        }
        let url  = URL.init(string: "/v1/profile/link/check")!
        let request = TSRequest.init(url: url, method: "GET", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }
    // MARK: - 删除短链接
    /**
     删除短链接
     删除短链接, 如果groupId为空, 则删除自己的短链接
     - parameter parameters: groupId

     */
    static func pg_deleteLink(_ linkValue : String,groupId : String?, success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        
        var param : [String : String]? = nil
        if let group = groupId {
            param = ["groupId":group]
        }
        let url  = URL.init(string: "/v1/profile/link")!
        let request = TSRequest.init(url: url, method: "DELETE", parameters:param)
        request.pgSetupAuth()
        self.pgRequest(request, success: success, failure: failure)
    }

    
    
    
    
}

//MARK:-  个人信息接口
extension PigramNetworkMananger{
    //MARK:-  获取用户信息
    /**
     获取用户信息
     - parameter userId: userid
     - returns: <#return#>
     */
    static func pgGetUserInfoNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess ,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.pgGetUserInfoRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:-  根据手机号查找用户
    /**
     根据手机号查找用户
     - parameter phoneNumber: 查询手机号
     - returns: <#return#>
     */
    static func pgSearchUserNetword(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
       guard let request = PigramRequestFactory.pgSearchUserRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:-  设置用户头像
    /**
     设置用户头像
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgSetupUserAvatarNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
       guard let request = PigramRequestFactory.pgSetupUserAvatarRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:-  设置用户昵称
    /**
     设置用户昵称
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgSetupUserNickNameNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
       guard let request = PigramRequestFactory.pgSetupUserNickNameRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
}
//MARK:-  好友关系接口
extension PigramNetworkMananger{
    
    //MARK:-  请求加入好友
    /**
     请求加入好友
     - parameter destinationId: 好友的userid
     - parameter addingWay: 添加方式
     - parameter remarkName: 添加方式
     - parameter applyMsg: 添加方式
        1: by id, 2: by number, 3:by scanning, 4: by card;



     
     - returns: 返回值
     */
    static func pgAddFriendNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        guard let request = PigramRequestFactory.pgAddFriendReuqest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:-  同意加好友请求
    /**
     同意加好友请求
     - parameter destinationId: 对方userid
     - parameter status: 1 是加好友 2 拉黑 默认1 Int 类型
     - returns: 返回值
     */
    static func pgAgreeAddFriendNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgAgreeAddFriendReuqest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:-  拒绝加好友
    /**
     拒绝加好友请
     - parameter destinationId: 对方userid
     - returns: 返回值
     */
    static func pgRejectAddFriendNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
        guard let request = PigramRequestFactory.pgRejectAddFriendReuqest(params: params) else{
            let request = PigramTXError.request
            failure(request)
            return
         }
        self.pgRequest(request, success: success, failure: failure)
    }

    //MARK:-  获取好友列表
    /**
     获取好友列表
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgGetFriendsListNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
       guard let request = PigramRequestFactory.pgGetFriendsListRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:-  设置好友昵称
    /**
     设置好友昵称
     - parameter destinationId: id
     - parameter remarkName: 昵称
     - returns: <#return#>
     */
    static func pgUpdateFriendRemarkNameNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
       guard let request = PigramRequestFactory.pgUpdateFriendRemarkNameRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }

    //MARK:-  添加黑名单
    /**
     添加黑名单
     - parameter destinationIds: 好友的userId
     - returns: <#return#>
     */
    static func pgAddUserBlackListNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
       guard let request = PigramRequestFactory.pgAddUserBlackListRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:-  获取黑名单列表
    /**
     获取黑名单列表
     - returns: <#return#>
     */
    static func pgGetUserBlackListNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
       guard let request = PigramRequestFactory.pgGetUserBlackListRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:-  移除黑名单列表
    /**
     移除黑名单列表
     - parameter destinationIds: 好友的userId
     - returns: <#return#>
     */
    static func pgRemoveUserBlackListNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
       guard let request = PigramRequestFactory.pgRemoveUserBlackListRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:-  删除好友
    /**
     删除好友
     - parameter destinationId: 好友userid
     - returns: <#return#>
     */
    static func pgDeleteFriendNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure){
       guard let request = PigramRequestFactory.pgDeleteFriendRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    
    
}


//MARK:-  登录注册请求接口
extension PigramNetworkMananger{
    //MARK:- 注册接口
    /**
     注册接口
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgRegisterNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.pgRegisterRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
        
        let successHandle:PigramTXNetworkSuccess = { respone in
            if  let pushAuthKey = request.parameters["pushPassword"] as? String{
                TSAccountManager.sharedInstance().setStoredServerAuthToken(pushAuthKey)
            }
            success(respone)

        }
       self.pgRequest(request, success: successHandle, failure: failure)
    }
    //MARK:- 密码登录接口
    /**
     密码登录接口
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgLoginPasswordNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.pgLoginPasswordRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
        let successHandle:PigramTXNetworkSuccess = { respone in
            if  let pushAuthKey = request.parameters["pushPassword"] as? String{
                TSAccountManager.sharedInstance().setStoredServerAuthToken(pushAuthKey)
            }
            success(respone)
        }
       self.pgRequest(request, success: successHandle, failure: failure)
    }
    //MARK:- 验证码登录接口
    /**
     验证码登录接口
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgLoginVerificationCodeNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.pgLoginVerificationCodeRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
        let successHandle:PigramTXNetworkSuccess = { respone in
            if  let pushAuthKey = request.parameters["pushPassword"] as? String{
                TSAccountManager.sharedInstance().setStoredServerAuthToken(pushAuthKey)
            }
            success(respone)
        }
       self.pgRequest(request, success: successHandle, failure: failure)
    }
    
    //MARK:- 获取验证码
    /**
     获取验证码
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgGetVerificationCodeNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.pgGetVerificationCodeRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 校验验证码
    /**
     校验验证码
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgCheckVerificationCodeNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.pgCheckVerificationCodeRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 确认用户是否存在
    /**
     确认用户是否存在
     - parameter phoneNumber: 手机号码
     - returns: <#return#>
     */

    static func pgEnsureUserExistNetwork(phoneNumber:String,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
        guard let request = PigramRequestFactory.pgEnsureUserExistRequest(phoneNumber) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 修改密码
    /**
     修改密码
     - parameter phoneNumber: 手机号
     - parameter password: 密码
     - parameter code: 验证码  登录状态可不传
     - returns: <#return#>
     */

    static func pgChangePasswordNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.pgChangePasswordRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 退出登录接口
    /**
     退出登录接口
     - returns: <#return#>
     */

    static func pgLoginoOutNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.pgLoginoOutRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 扫描web登录接口
    /**
     扫描web登录接口
     - returns: <#return#>
     */
    static func pgControlLoginWebNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.pgControlLoginWebRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 获取扫描验证信息
    /**
     获取扫描验证信息
     - returns: <#return#>
     */

    static func pgGetScanDeviceAuthorNetwork(params:Dictionary<String ,Any>?,success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.pgGetScanDeviceAuthorRequest(params: params) else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }

    //MARK:- 获取oss token
    /**
     获取oss token
     - returns: <#return#>
     */

    static func getOSSTokenRequest(success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.getOSSTokenRequest() else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    //MARK:- 获取oss token
    /**
     获取oss token
     - returns: <#return#>
     */

    static func getOSSConfigRequest(success: @escaping PigramTXNetworkSuccess,failure: @escaping PigramTXNetworkFailure) {
       guard let request = PigramRequestFactory.getOSSConfigRequest() else{
           let request = PigramTXError.request
           failure(request)
           return
        }
       self.pgRequest(request, success: success, failure: failure)
    }
    
    

    
    
}
//MARK:-  上传图片
extension PigramNetworkMananger{
    //MARK:-  上传图片借口
    static func uploadPhotoMananager(image:UIImage,success: @escaping (_ urlPath : String?) -> Void,failed:@escaping (_ error : Error) -> Void){
        let size = CGSize(width: CGFloat.init(kOWSProfileManager_MaxAvatarDiameter) , height: CGFloat.init(kOWSProfileManager_MaxAvatarDiameter))

        let resizeImage = image.resizedImage(toFillPixelSize: size).withRenderingMode(.alwaysOriginal)
        let data =  OWSProfileManager.shared().processedImageData(forRawAvatar: resizeImage)
        
        
        let formRequest = OWSRequestFactory.allocAttachmentRequest()
        SSKEnvironment.shared.networkManager.makeRequest(formRequest, success: { (task, response) in
            guard let form = PigramUploadForm.parse(response: response) else{
                let error = PigramTXError.request
                failed(error)
                return
            }
            
            OWSSignalService.sharedInstance().cdnSessionManager.post("", parameters: nil, constructingBodyWith: { (formData) in
                form.appendForm(formData: formData)
                form.appendMultipartFormPath(formData, "Content-Type", OWSMimeTypeApplicationOctetStream)
                formData.appendPart(withForm: data, name: "file")

            }, progress: { (progress) in
                
            }, success: { (task, respose) in
                success(form.formKey)
            }) { (task, error) in
                failed(error)
            }

        }) { (task, error) in
            failed(error)
        }

    }
    
    
    
    
}
