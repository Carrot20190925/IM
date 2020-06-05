//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
extension TSRequest{
    func pgSetupAuth() {
        if TSAccountManager.sharedInstance().isRegistered {
            self.authUsername = TSAccountManager.localUserId
            self.authPassword = TSAccountManager.sharedInstance().storedServerAuthToken();
        }else{
            self.shouldHaveAuthorizationHeaders = false
        }
    }
}
class PigramRequestFactory: NSObject {
    //MARK:- 创建群请求
    /**
     创建群请求
     - parameter group_title: 群名称
     - parameter groupMembers: 群成员数组 里面是对象{userId:userId}  数量大于3
     - returns: <#return#>
     */
    static func pgCreateGroupsRequest(params:Dictionary<String, Any>?) -> TSRequest?{

        guard let _ = params?["title"] as? String else {
            return nil
        }
        guard let groupMembers = params?["groupMembers"] as? Array<Any> else {
            return nil
        }
        if  groupMembers.count < 2{
            return nil
        }
        //创建
       guard let url  = URL.init(string: "/v1/groups") else {
           return nil
       }
       let request = TSRequest.init(url: url, method: "POST", parameters:params)
       request.pgSetupAuth()
       return request
    }
    //MARK:- 获取群列表
    /**
     获取群列表
     - parameter parameters: 参数可为空
     - returns: <#return#>
     */
    static func pgGetGroupsListRequest(params:Dictionary<String, Any>?) -> TSRequest?{
       guard let url  = URL.init(string: "/v1/groups") else {
           return nil
       }
        let request = TSRequest.init(url: url, method: "GET", parameters: [:])
       request.pgSetupAuth()
       return request
    }

    //MARK:- 获取群信息
    /**
     获取群信息
     - parameter groupId: groupId
     - returns: <#return#>
     */
    static func pgGetGroupInfoRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let groupId = params?["groupId"] as? String  else {
            return nil
        }
        guard let url  = URL.init(string: "/v1/groups/find/\(groupId)") else {
           return nil
        }
        let request = TSRequest.init(url: url, method: "GET", parameters: [:])
        request.pgSetupAuth()
        return request
    }
    //MARK:- 设置管理员
    /**
     设置管理员
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgSetupManagersRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let _ = params?["groupId"] as? String else {
            return nil
        }
        guard let groupMembers = params?["groupMembers"] as? Array <Any> else {
            return nil
        }
        if  groupMembers.count <= 0{
            return nil
        }

       guard let url  = URL.init(string: "/v1/groups/update_member_perm") else {
           return nil
       }
       let request = TSRequest.init(url: url, method: "PUT", parameters: params)
       request.pgSetupAuth()
       return request
    }
    //MARK:- 转让群
    /**
     转让群
     - parameter groupId: <#param#>
     - parameter newOwnerId: <#param#>
     - returns: <#return#>
     */
    static func pgTransferGroupRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard var newParams = params else {
            return nil
        }
        guard let _ = newParams["groupId"] as? String else {
            return nil
        }
        guard let _ = newParams["newOwnerId"] as? String else {
            return nil
        }
        guard let  exOwnerId = TSAccountManager.localUserId else {
            return nil
        }
        newParams["exOwnerId"] = exOwnerId
        guard let url  = URL.init(string: "/v1/groups/trans_owner") else {
           return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters:newParams)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 创建群公告
    /**
     创建群公告
     - parameter params:
        如果noticeId为空则为创建,
        如果content为空,则为删除,,
        如果noticeId和content不为空,则为更新::
     - returns:
     */
    static func pgCreateGroupAnnouncementRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let _ = params?["groupId"] as? String else {
            return nil
        }
        guard let url  = URL.init(string: "/v1/groups/notice") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters:params)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 编辑群公告
    /**
     编辑群公告
     - parameter parameters:
     - returns:
     */
    static func pgEditGroupAnnouncementRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let url  = URL.init(string: "") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "", parameters:params)
        request.pgSetupAuth()
        return request
    }
    //MARK:-  获取群公告列表
    /**
     获取群公告列表
     - parameter parameters: 参数
     - returns: 返回值
     */
    static func pgGetAnnouncementListRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let url  = URL.init(string: "") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "", parameters:params)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 管理员或群主加好友入群
    /**
     管理员或群主加好友入群
     - parameter id: groupId
     - parameter groupMembers: [{userId:userId}]

     - returns: <#return#>
     */
    static func pgManagerAddFriendJoinGroupRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let _ = params?["groupId"] as? String else {
            return nil
        }
        guard let groupMembers = params?["groupMembers"] as? Array<Any> else {
            return nil
        }
        if groupMembers.count == 0 {
            return nil
        }
        guard let url  = URL.init(string: "/v1/groups/member") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "POST", parameters:params)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 普通成员请求入群
    /**
     普通成员请求入群
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgMemberJoinGroupRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let url  = URL.init(string: "") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "", parameters:params)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 设置群头像
    /**
     设置群头像
     - parameter groupId: 群id
     - parameter avatar: 头像路径
     - returns: <#return#>

     */
    static func pgSetupGroupAvatarRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let _ = params?["avatar"] as? String else {
            return nil
        }
        guard let _ = params?["groupId"] as? String else {
            return nil
        }
        guard let url  = URL.init(string: "/v1/groups/avatar") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters:params)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 设置群昵称
    /**
     设置群昵称
     - parameter groupId: 群id
     - parameter title: 群名

     - returns: <#return#>
     */
    static func pgSetupGroupNameRequest(params:Dictionary<String, Any>?) -> TSRequest?{
       guard let _ = params?["title"] as? String else {
           return nil
       }
       guard let _ = params?["groupId"] as? String else {
           return nil
       }
        guard let url  = URL.init(string: "/v1/groups/title") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters:params)
        request.pgSetupAuth()
        return request
    }
    
    //MARK:- 离群请求
    /**
     离群请求
     - parameter groupId: 群id
     - returns: <#return#>
     */
    static func pgQuitGroupRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard var newParams = params else {
            return nil
        }
        guard let _ = params?["groupId"] as? String else {
            return nil
        }
        guard let userId = TSAccountManager.localUserId else {
            return nil
        }
        newParams["userId"] = userId
        guard let url  = URL.init(string: "/v1/groups/quit") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "DELETE", parameters:newParams)
        request.pgSetupAuth()
        return request
    }
    
    //MARK:- 解散群请求
    /**
     解散群请求
     - parameter groupId: 群id
     - returns: <#return#>
     */
    static func pgDismissGroupRequest(params:Dictionary<String, Any>?) -> TSRequest?{

        guard let _ = params?["groupId"] as? String else {
            return nil
        }
        guard let url  = URL.init(string: "/v1/groups") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "DELETE", parameters:params)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 删除群成员
    /**
     删除群成员
     - parameter groupId: 群id
     - returns: <#return#>
     */
    static func pgdDeleteGroupMemberRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let _ = params?["groupId"] as? String else {
            return nil
        }
        guard let groupMembers = params?["groupMembers"] as? Array<Any> else {
            return nil
        }
        if groupMembers.count == 0 {
            return nil
        }
        guard let url  = URL.init(string: "/v1/groups/member") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "DELETE", parameters:params)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 申请入群
    /**
     申请入群
     - parameter groupId: 群id
     - returns: <#return#>
     */
    static func pgApplyJoinGroupRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard var newParams = params else {
            return nil
        }
        guard let _ = newParams["groupId"] as? String else {
            return nil
        }
        guard let userId = TSAccountManager.localUserId else {
            return nil
        }
        newParams["userId"] = userId

        guard let url  = URL.init(string: "/v1/groups/apply") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters:newParams)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 同意入群请求
    /**
     同意入群请求
     - parameter groupId: 群id
     - returns: <#return#>
     */
    static func pgAgreeJoinGroupRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let newParams = params else {
            return nil
        }
        guard let _ = newParams["groupId"] as? String else {
            return nil
        }
        guard let _ = newParams["userId"] as? String else {
            return nil
        }

        guard let url  = URL.init(string: "/v1/groups/accept") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters:newParams)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 查询群成员
    /**
     查询群成员
     - parameter groupId: 群id
     - parameter limit: 长度size
     - parameter offset: 偏移量
     - returns: <#return#>
     */
    static func pgFindGroupMemberRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let newParams = params else {
            return nil
        }
        guard let _ = newParams["group_id"] as? String else {
            return nil
        }
        guard let _ = newParams["limit"] as? String else {
            return nil
        }
        guard let _ = newParams["offset"] as? String else {
            return nil
        }

        guard let url  = URL.init(string: "/v1/groups/find_member") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "GET", parameters:newParams)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 设置成员在群里的昵称
    /**
     设置成员在群里的昵称
     - parameter groupId: 群id
     - parameter userId:
     - parameter remarkName:
     - returns: <#return#>
     */
    static func pgSetupGroupMemberRemarkNameRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let newParams = params else {
            return nil
        }
        guard let _ = newParams["groupId"] as? String else {
            return nil
        }
        guard let _ = newParams["userId"] as? String else {
            return nil
        }
        guard let _ = newParams["remarkName"] as? String else {
            return nil
        }

        guard let url  = URL.init(string: "/v1/groups/update_member_remark_name") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters:newParams)
        request.pgSetupAuth()
        return request
    }
    
    
    //MARK:- 拉黑群成员
    /**
     拉黑群成员
     - parameter groupId: 群id
     - parameter groupMembers:

     - returns: <#return#>
     */
    static func pgAddBlackGroupMembersRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard var newParams = params else {
            return nil
        }
        guard let _ = newParams["groupId"] as? String else {
            return nil
        }
        guard let _ = newParams["groupMembers"] as? Array <String> else {
            return nil
        }
        newParams["memberStatus"] = 2


        guard let url  = URL.init(string: "/v1/groups/update_member_status") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters:newParams)
        request.pgSetupAuth()
        return request
    }
    
    
    //MARK:- 取消拉黑群成员
    /**
     取消拉黑群成员
     - parameter groupId: 群id
     - parameter groupMembers:
     - returns: <#return#>
     */
    static func pgRemoveBlackGroupMembersRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard var newParams = params else {
            return nil
        }
        guard let _ = newParams["groupId"] as? String else {
            return nil
        }
        guard let _ = newParams["groupMembers"] as? Array <String> else {
            return nil
        }
        newParams["memberStatus"] = 1

        guard let url  = URL.init(string: "/v1/groups/update_member_status") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters:newParams)
        request.pgSetupAuth()
        return request
    }

    
    //MARK:- 群全体禁言
    static func pg_blockAllConversation(groupID: String, isBan: Bool) -> TSRequest?{
        
        let param: [String : Any]  = [
            "groupId": groupID,
            "groupPermRight" : [
                [
                    "perm": 2,
                    "groupRightBan" : isBan ? 1 : 0
                ]
            ]
        ];
        
        guard let url  = URL.init(string: "/v1/groups/ban_all_right") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters:param)
        request.pgSetupAuth()
        return request
    }
    
    
    

}

//MARK:-  个人请求接口

extension PigramRequestFactory{
    //MARK:-  根据手机号查找用户
    /**
     根据手机号查找用户
     - parameter phoneNumber: 查询手机号
     - returns: <#return#>
     */
    static func pgSearchUserRequest(params:Dictionary<String, Any>?) -> TSRequest?{
       guard let phoneNumber = params?["phoneNumber"] as? String else {
             return nil
       }

        guard let ensurephoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) else {
            return nil
        }

       let path = "/v1/profile/query/\(ensurephoneNumber)"
       guard let url  = URL.init(string: path) else {
           return nil
       }
       let request = TSRequest.init(url: url, method: "GET", parameters: [:])
       request.pgSetupAuth()
       return request
    }
    //MARK:-  设置用户头像
    /**
     设置用户头像
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgSetupUserAvatarRequest(params:Dictionary<String, Any>?) -> TSRequest?{
       guard let url  = URL.init(string: "") else {
           return nil
       }
       let request = TSRequest.init(url: url, method: "", parameters: params)
       request.pgSetupAuth()
       return request
    }
    //MARK:-  设置用户昵称
    /**
     设置用户昵称
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgSetupUserNickNameRequest(params:Dictionary<String, Any>?) -> TSRequest?{
       guard let url  = URL.init(string: "") else {
           return nil
       }
       let request = TSRequest.init(url: url, method: "", parameters: params)
       request.pgSetupAuth()
       return request
    }
    //MARK:-  获取用户信息
    /**
     获取用户信息
     - parameter userId: userid
     - returns: <#return#>
     */
    static func pgGetUserInfoRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let userId = params?["userId"] as? String else {
            return nil
        }
       guard let url  = URL.init(string: "/v1/accounts/find/" + userId) else {
           return nil
       }
       let request = TSRequest.init(url: url, method: "GET", parameters: [:])
        request.pgSetupAuth()
        return request
    }

}

//MARK:-  好友请求接口
extension PigramRequestFactory{
    //MARK:-  请求加入好友
    /**
     请求加入好友
     - parameter destinationId: 好友的userid
     - returns: 返回值
     */
    static func pgAddFriendReuqest(params:Dictionary<String, Any>?) -> TSRequest?{
        var newParam = params;
        guard let _ = params?["destinationId"] as?String   else {
            return nil
        }
        guard let _ = TSAccountManager.localUserId else {
            return nil
        }
        guard var url  = URL.init(string: "/v1/relations/apply") else {
            return nil
        }
        if let groupId = params?["groupId"] as? String {
            url = URL.init(string: "/v1/relations/apply?group_id=\(groupId)")!;
            newParam?.removeValue(forKey: "groupId");
        }
        
        let request = TSRequest.init(url: url, method: "PUT", parameters:newParam)
        request.pgSetupAuth()
        return request
    }
    //MARK:-  同意加好友请求
    /**
     同意加好友请求
     - parameter destinationId: 对方userid
     - parameter status: 1 是加好友 2 拉黑 默认1 Int 类型
     - parameter status: 1 是加好友 2 拉黑 默认1
     - returns: 返回值
     */
    static func pgAgreeAddFriendReuqest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let destinationId = params?["destinationId"] as? String  else {
            return nil
        }
        guard let sourceId = TSAccountManager.localUserId else {
            return nil
        }
        var newStatus = 1
        if let status = params?["status"] as? Int {
            newStatus = status
        }

        guard let url  = URL.init(string: "/v1/relations") else {
            return nil
        }
        let newParams = ["sourceId":sourceId,"status":newStatus,"destinationId":destinationId] as [String : Any]
        let request = TSRequest.init(url: url, method: "POST", parameters:newParams)
        request.pgSetupAuth()
        return request
    }
    //MARK:-  拒绝加好友
    /**
     拒绝加好友请
     - parameter destinationId: 对方userid
     - returns: 返回值
     */
    static func pgRejectAddFriendReuqest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let destinationId = params?["destinationId"] as? String else {
            return nil
        }
        guard let sourceId = TSAccountManager.localUserId else {
            return nil
        }
        guard let url  = URL.init(string: "/v1/relations/reject") else {
            return nil
        }
        let newParams = ["destinationId":destinationId,"sourceId":sourceId]
        let request = TSRequest.init(url: url, method: "PUT", parameters:newParams)
        request.pgSetupAuth()
        return request
    }
    //MARK:-  获取好友列表
    /**
     获取好友列表
     - parameter status: 1 好友 2 黑名单 默认黑名单 Int 类型
     - returns: <#return#>
     */
    static func pgGetFriendsListRequest(params:Dictionary<String, Any>?) -> TSRequest?{

       var status = 1
       if let newStatus = params?["status"] as? Int {
            status = newStatus
       }
       guard let url  = URL.init(string: "/v1/relations") else {
           return nil
       }
       let newParams = ["status":status]
       let request = TSRequest.init(url: url, method: "GET", parameters: newParams)
       request.pgSetupAuth()
       return request
    }

    //MARK:-  添加黑名单
    /**
     添加黑名单
     - parameter destinationIds: 好友的userIds
     - returns: <#return#>
     */
    static func pgAddUserBlackListRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard var newParams = params else {
            return nil
        }
        guard let _ = newParams["destinationIds"] as? Array<String> else {
            return nil
        }
        guard let sourceId = TSAccountManager.localUserId else {
            return nil
        }
        newParams["sourceId"] = sourceId
        newParams["status"] = 2
       guard let url  = URL.init(string: "/v1/relations/update_status") else {
           return nil
       }
       let request = TSRequest.init(url: url, method: "PUT", parameters: newParams)
       request.pgSetupAuth()
       return request
    }
    //MARK:-  获取黑名单列表
    /**
     获取黑名单列表
     - returns: <#return#>
     */
    static func pgGetUserBlackListRequest(params:Dictionary<String, Any>?) -> TSRequest?{
       guard let url  = URL.init(string: "/v1/relations") else {
           return nil
       }
       let request = TSRequest.init(url: url, method: "GET", parameters:["status":2])
       request.pgSetupAuth()
       return request
    }
    //MARK:-  移除黑名单列表
    /**
     移除黑名单列表
     - parameter destinationIds: 好友的userId
     - returns: <#return#>
     */
    static func pgRemoveUserBlackListRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard var newParams = params else {
            return nil
        }
        guard let _ = newParams["destinationIds"] as? Array<String> else {
            return nil
        }
        guard let sourceId = TSAccountManager.localUserId else {
            return nil
        }
        newParams["sourceId"] = sourceId
        newParams["status"] = 1
        guard let url  = URL.init(string: "/v1/relations/update_status") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters: newParams)
        request.pgSetupAuth()
        return request
    }
    //MARK:-  删除好友
    /**
     删除好友
     - parameter destinationId: 好友userid
     - returns: <#return#>
     */
    static func pgDeleteFriendRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard var newParams = params else {
            return nil
        }
        guard let _ = newParams["destinationId"] else {
            return nil
        }
        guard let sourceId = TSAccountManager.localUserId else {
            return nil
        }
        newParams["sourceId"] = sourceId
        guard let url  = URL.init(string: "/v1/relations") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "DELETE", parameters: newParams)
        request.pgSetupAuth()
        return request
    }
    //MARK:-  设置好友昵称
    /**
     设置好友昵称
     - parameter destinationId: id
     - parameter remarkName: 昵称
     - returns: <#return#>
     */
    static func pgUpdateFriendRemarkNameRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard var newParams = params else {
            return nil
        }
        guard let _ = newParams["destinationId"] as? String else {
            return nil
        }
        guard let _ = newParams["remarkName"] as? String else {
            return nil
        }
        guard let sourceId = TSAccountManager.localUserId else {
            return nil
        }
        newParams["sourceId"] = sourceId
        guard let url  = URL.init(string: "/v1/relations/update_remark_name") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters: newParams)
        request.pgSetupAuth()
        return request
    }

    
    
}
//MARK:-  登录注册请求接口
extension PigramRequestFactory{
    //MARK:- 注册接口
    /**
     注册接口
     - parameter fetchesMessages: 获取信息
     - parameter registrationId: 登记身份证
     - parameter name:
     - parameter number: 手机号
     - parameter pushPassword: 登记身份证
     - parameter loginPassword: 登记身份证
     - returns: <#return#>
     */
    static func pgRegisterRequest(params:Dictionary<String, Any>?) -> TSRequest?{

       guard let code = params?["code"] as? String else {
          return nil
       }
       guard let name = params?["name"] as? String else {
           return nil
       }
       guard let url  = URL.init(string: "/v1/accounts/code/\(code)") else {
           return nil
       }
       var accountAttributes = PigramRequestFactory.accountAttributes()
       accountAttributes["name"] = name
       let  request = TSRequest.init(url: url, method: "PUT", parameters: accountAttributes)
       request.shouldHaveAuthorizationHeaders = false
       return request
    }
    //MARK:- 密码登录接口
    /**
     密码登录接口
     - parameter password: 密码
     - parameter phoneNumber: 手机号

     - returns: <#return#>
     */
    static func pgLoginPasswordRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let password = params?["password"] as? String else {
            return nil
        }
        guard let phoneNumber = params?["phoneNumber"] as? String else {
            return nil
        }
        guard let url  = URL.init(string: "/v1/accounts/logon_with_password") else {
           return nil
        }
        guard let md5Base64 = password.md5Base64() else {
            return nil
        }
        var accountAttributes = PigramRequestFactory.accountAttributes()
        accountAttributes["number"] = phoneNumber
        accountAttributes["loginPassword"] = md5Base64
        let request = TSRequest.init(url: url, method: "PUT", parameters: accountAttributes)
        request.shouldHaveAuthorizationHeaders = false
        return request
    }
    //MARK:- 验证码登录接口
    /**
     验证码登录接口
     - parameter phonenumeber: 电话
     
     - returns: <#return#>
     */
    static func pgLoginVerificationCodeRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let code = params?["code"] as? String else {
            return nil
        }
        guard let phoneNumber = params?["phoneNumber"] as? String else {
            return nil
        }
        guard let url  = URL.init(string: "/v1/accounts/logon_with_code/\(code)") else {
           return nil
        }
        var accountAttributes = PigramRequestFactory.accountAttributes()
        accountAttributes["number"] = phoneNumber

        let request = TSRequest.init(url: url, method: "PUT", parameters: accountAttributes)
        request.shouldHaveAuthorizationHeaders = false
        return request
    }
    
    //MARK:- 获取验证码
    /**
     获取验证码
     - parameter parameters: <#param#>
     - returns: <#return#>
     */
    static func pgGetVerificationCodeRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let phoneNumber = params?["phoneNumber"] as? String else{
          return nil
       }
       guard let url  = URL.init(string: ("/v2/accounts/code/" + phoneNumber)) else {
           return nil
       }
       let request = TSRequest.init(url: url, method: "", parameters: params)
       request.pgSetupAuth()
       return request
    }
    //MARK:- 校验验证码
    /**
     校验验证码
     - parameter phoneNumber: 手机号
     - parameter code: 验证码
     - returns: <#return#>
     */
    static func pgCheckVerificationCodeRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        guard let phoneNumber = params?["phoneNumber"] as? String else {
            return nil
       }
        guard let code = params?["code"] as? String else {
           return nil
       }
       guard let url  = URL.init(string: "v1/accounts/verify/\(phoneNumber)/\(code)" ) else {
           return nil
       }
       let request = TSRequest.init(url: url, method: "PUT", parameters: [:])
       request.shouldHaveAuthorizationHeaders = false
//       request.pgSetupAuth()
       return request
    }
    //MARK:- 确认用户是否存在
    /**
     确认用户是否存在
     - parameter phoneNumber: 手机号
     - returns: <#return#>
     */
    static func pgEnsureUserExistRequest(_ phoneNumber:String) -> TSRequest?{
        guard let url  = URL.init(string: "/v1/accounts/find/" + phoneNumber) else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "GET", parameters: [:])
        request.shouldHaveAuthorizationHeaders = false;
        return request
    }
    //MARK:- 修改密码
    /**
     修改密码
     - parameter phoneNumber: 手机号
     - parameter password: 密码
     - parameter code: 验证码  登录状态可不传

     - returns: <#return#>
     */
    static func pgChangePasswordRequest(params:Dictionary<String, Any>?) -> TSRequest?{
        
        guard let phoneNumber = params?["phoneNumber"] as? String else {
            return nil
        }
        guard let password = params?["password"] as? String else {
            return nil
        }
        var path = "/v1/accounts/password"
        var showAuth = true
        if !TSAccountManager.sharedInstance().isRegistered ,let code = params?["code"] as? String{
            path = "/v1/accounts/password?code=\(code)"
            showAuth = false
        }
        guard let md5Base64  = password.md5Base64() else {
            return nil
        }
        let newparams = ["loginPassword":md5Base64,"number":phoneNumber]
        guard let url  = URL.init(string: path) else {
            return nil
        }
        
        let request = TSRequest.init(url: url, method: "PUT", parameters: newparams)
        request.pgSetupAuth()
        request.shouldHaveAuthorizationHeaders = showAuth;
        return request
    }
    
    //MARK:- 退出登录接口
    /**
     退出登录接口
     - returns: <#return#>
     */
    static func pgLoginoOutRequest(params:Dictionary<String, Any>?) -> TSRequest?{

        guard let url  = URL.init(string: "/v1/accounts/logout/") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "PUT", parameters: params)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 扫描web登录接口
    /**
     扫描web登录接口
     - returns: <#return#>
     */
    static func pgControlLoginWebRequest(params:Dictionary<String, Any>?) -> TSRequest?{

        guard let url  = URL.init(string: "/v1/devices/provisioning/code") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "GET", parameters: params)
        request.pgSetupAuth()
        return request
    }
    //MARK:- 获取扫描验证信息
    /**
     获取扫描验证信息
     - returns: <#return#>
     */
    static func pgGetScanDeviceAuthorRequest(params:Dictionary<String, Any>?) -> TSRequest?{

        guard let data = params?["data"] as? Data else {
            return nil
        }
        guard let deviceId = params?["deviceId"] as? String else {
            return nil
        }
        guard let url  = URL.init(string: "/v1/provisioning/\(deviceId)") else {
            return nil
        }
        let body = data.base64EncodedString()
        let request = TSRequest.init(url: url, method: "PUT", parameters: ["body":body])
        request.pgSetupAuth()
        return request
    }
    
    //MARK:-  获取oss token

    static func getOSSTokenRequest() -> TSRequest?{
        guard let url  = URL.init(string: "/sts") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "GET", parameters: [:])
        request.pgSetupAuth()
        return request
    }
    //MARK:-  获取oss 配置信息

    static func getOSSConfigRequest() -> TSRequest?{
        guard let url  = URL.init(string: "/v1/profile/form/aliyun") else {
            return nil
        }
        let request = TSRequest.init(url: url, method: "GET", parameters: [:])
        request.pgSetupAuth()
        return request
    }
    
    
    
}




extension PigramRequestFactory{
    
    static func accountAttributes() -> Dictionary<String,Any>{
        let accountMgr = TSAccountManager.sharedInstance()
        let registrationId = accountMgr.getOrGenerateRegistrationId()
        //如果为false的话 服务器不会主动推消息
        let isManualMessageFetchEnabled = accountMgr.isManualMessageFetchEnabled()
        var accountAttributes = ["voice":true,
                                 "video":true,
                                 "fetchesMessages":isManualMessageFetchEnabled,
                                 "registrationId":"\(registrationId)",
                                 ] as [String : Any]
        if let localNumber = accountMgr.localNumber,localNumber.length != 0 {
            accountAttributes["number"] = localNumber
        }
        if let authKey = accountMgr.storedServerAuthToken(),authKey.length != 0{
            accountAttributes["pushPassword"] = authKey

        }else{
            let authKey = TSAccountManager.generateNewAccountAuthenticationToken()
            accountAttributes["pushPassword"] = authKey
        }
        return accountAttributes
        
    }
    
    

}




import CommonCrypto

// 直接给String扩展方法
extension String {
//    func md5() -> String {
//        let str = self.cString(using: String.Encoding.utf8)
//        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
//        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
//        CC_MD5(str!, strLen, result)
//        let hash = NSMutableString()
//        for i in 0 ..< digestLen {
//            hash.appendFormat("%02x", result[i])
//        }
//        free(result)
//        return String(format: hash as String)
//    }
    
    func md5Base64() -> String? {
        
        guard let message = self.data(using: .utf8) else {
            return nil
        }
        var digesetData = Data.init(count: Int(CC_MD5_DIGEST_LENGTH))
        _ =  digesetData.withUnsafeMutableBytes { (digBytes) -> UInt8  in
            message.withUnsafeBytes { (messageBytes) -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(message.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
            
        }
      return  digesetData.base64EncodedString()
    }

}











//MARK:-  上传图片类
class PigramUploadForm {
    var formAcl : String!
    var formKey : String!
    var formPolicy : String!
    var formAlgorithm : String!
    var formCredential : String!
    var formDate : String!
    var formSignature : String!
    var attachmentId : NSNumber?
    var attachmentIdString : String?
    
    static func parse(response : Any?) -> PigramUploadForm? {

        guard let responseMap = response as? Dictionary<String,Any> else {
            return nil
        }
        
        guard let formAcl = responseMap["acl"] as? String else {
            return nil
        }
        guard let formKey = responseMap["key"] as? String  else {
            return nil
        }
        guard let formPolicy = responseMap["policy"] as? String  else {
            return nil
        }
        guard let formAlgorithm = responseMap["algorithm"] as? String  else {
            return nil
        }
        guard let formCredential = responseMap["credential"] as? String  else {
            return nil
        }
        guard let formDate = responseMap["date"] as? String  else {
            return nil
        }
        guard let formSignature = responseMap["signature"] as? String  else {
            return nil
        }
        var attachmentId : NSNumber?
        if let attachment = responseMap["attachmentId"] {
            guard let attach = attachment as? NSNumber  else {
                return nil
            }
            attachmentId = attach
        }
        var attachmentIdString : String?
        if let attachmentString = responseMap["attachmentIdString"] {
            guard let attachStr = attachmentString as? String  else {
                return nil
            }
            attachmentIdString = attachStr
        }
        
        let form = PigramUploadForm.init()
                
        // Required properties.
        form.formAcl = formAcl;
        form.formKey = formKey;
        form.formPolicy = formPolicy;
        form.formAlgorithm = formAlgorithm;
        form.formCredential = formCredential;
        form.formDate = formDate;
        form.formSignature = formSignature;

        // Optional properties.
        form.attachmentId = attachmentId;
        form.attachmentIdString = attachmentIdString;
        return form

    }
    
    func appendMultipartFormPath(_ formData:AFMultipartFormData,_ name:String,_ value:String){
        if  let data = value.data(using: .utf8){
            formData.appendPart(withForm: data, name: name)
        }
        
    }
    func appendForm(formData:AFMultipartFormData) {
        self.appendMultipartFormPath(formData, "key", self.formKey);
        self.appendMultipartFormPath(formData, "acl", self.formAcl);
        self.appendMultipartFormPath(formData, "x-amz-algorithm", self.formAlgorithm);
        self.appendMultipartFormPath(formData, "x-amz-credential", self.formCredential);
        self.appendMultipartFormPath(formData, "x-amz-date", self.formDate);
        self.appendMultipartFormPath(formData, "policy", self.formPolicy);
        self.appendMultipartFormPath(formData, "x-amz-signature", self.formSignature);
    }
    
}
