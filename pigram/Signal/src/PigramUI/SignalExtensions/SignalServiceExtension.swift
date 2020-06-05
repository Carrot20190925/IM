//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation


@objc(PGUserRelationShipType)
public enum UserRelationShipType: Int {
    case unknow = 0;
    //好友
    case friend = 1;
    //黑名单
    case block  = 2;
}

extension OWSUserProfile {
    
    private struct AssociatedKeys {
          
          static var relationType = "pigram_relationType";
        ///备注名称
          static var remarkName = "pigram_remarkName";

      }
      /**
       *  关系
       */
     @objc(PGRelationType)
      public var relationType: UserRelationShipType {
          
          set {
              objc_setAssociatedObject(self, &AssociatedKeys.relationType, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
          }
          get {
              
            return (objc_getAssociatedObject(self, &AssociatedKeys.relationType) as? UserRelationShipType) ?? .unknow;
          }
          
      };
//    /**
//     * 备注
//     */
//    @objc
//    public var remarkName: String? {
//
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.remarkName, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//        get {
//
//            return objc_getAssociatedObject(self, &AssociatedKeys.remarkName) as? String;
//        }
//
//    }
        
    /// MARK: 获取好友头像
    @objc
    public func getContactAvatarImage() -> UIImage? {
        
        var builder: OWSAvatarBuilder?
        if self.address.type == .group {
             builder = OWSGroupAvatarBuilder.init(address: self.address, colorName: .pigramThemeColor, diameter: 52);
        } else {
            builder = OWSContactAvatarBuilder.init(address: self.address, colorName: .pigramThemeColor, diameter: 52);
        }
        var image = builder!.buildSavedImage();
        if image == nil{
            image = builder!.buildDefaultImage();
        }
        return image;
    }
    /**
     * 获取好友要显示的名称
     */
    @objc
    public func getContactName() -> String {
        
        var name = self.remarkName ?? "";
        
        if name.length == 0 {
            SSKEnvironment.shared.databaseStorage.read { (read) in
                name = OWSProfileManager.shared().profileName(for: self.address, transaction: read) ?? "";
            }
        }
        if name.length == 0 {
//            owsFailDebug("对方没有昵称~~~~~~~~~~~~~~");
            name = "****";
        }
        if name.length == 0 {
            name = self.address.stringForDisplay;
        }
        return name;
        
    }
    
    @objc public func getDisplayName() -> String {
        
        var name = self.remarkName ?? "";
        let profileName: String? = self.profileName;
        
        if name.length > 0 {
            if let nickname = profileName , nickname.length > 0 {
                name += "(\(nickname))";
            }
        } else {
            name = profileName ?? "";
        }
        if name.length == 0 {
            //            owsFailDebug("对方没有昵称~~~~~~~~~~~~~~");
            name = "****";
        }
        if name.length == 0 {
            name = self.address.stringForDisplay;
        }
        return name;
        
    }
    /// mark: 是否是我的好友
    public static func existMyFriendList(_ profile: OWSUserProfile) -> Bool {
        
        return (profile.relationType == .friend && profile.isNeedVerify == false) || profile.address.phoneNumber == TSAccountManager.localUserId;
        
    }
    
    /**
     * 主动从本地删除 并且删除本地会话
     */
    public func deleteFromFriendList(_ finished: @escaping (Bool) -> Void) {
        guard let destinationId = self.address.phoneNumber  else {
            DispatchQueue.main.async {
                OWSAlerts.showErrorAlert(message: "删除好友操作失败！");
                finished(false);
            }
            return
        }
        let params = ["destinationId":destinationId];
        PigramNetworkMananger.pgDeleteFriendNetwork(params: params, success: { (response) in
            DispatchQueue.main.async {
                self.deleteFromDB();
                finished(true);
            }
        }) { (error) in
            DispatchQueue.main.async {
                OWSAlerts.showErrorAlert(message: "删除好友操作失败！");
                finished(false);
            }
        }
        
    }
    
    public func deleteFromDB() {
        self.relationType = .unknow;
        var thread: TSContactThread?
        SSKEnvironment.shared.databaseStorage.read { (read) in
            thread = TSContactThread.getWithContactAddress(self.address, transaction: read);
            
        }
        SSKEnvironment.shared.databaseStorage.write { (write) in
            self.anyRemove(transaction: write);
            if thread != nil {
                thread?.anyRemove(transaction: write);
            }
        }
        if SSKEnvironment.shared.udManager.unidentifiedAccessMode(forAddress: self.address) == .enabled {
            SSKEnvironment.shared.udManager.setUnidentifiedAccessMode(.unrestricted, address: self.address);
        }
    }
}



extension ContactsUpdater {
    
        
    /**
     * 搜索好友
     */
    
    public func pg_searchUser(_ phoneNumber: String, successed: @escaping ([OWSUserProfile]?) -> Void, failure: @escaping (Error) -> Void) {
        

        let params = ["phoneNumber":phoneNumber]
    
        PigramNetworkMananger.pgSearchUserNetword(params: params, success: { (respone) in
            
            
            guard let resObjct = respone as? Array <Any> else{
                DispatchQueue.main.async {
                    successed(nil);
                }
                return
            }

            DispatchQueue.main.async {
                var users: [OWSUserProfile] = [];
                for item in resObjct {
                    
                    if  let response = item as? [String : Any] {
                        var name : String?
                        var avatar : String?
                        guard let userId = response["userId"] as? String else{
                            DispatchQueue.main.async {
                                successed(nil);
                            }
                            return
                        }
                        if let newName = response["name"] as? String{
                            name = newName
                        }
                        
                        if let  newavatar = response["avatar"] as? String{
                            avatar = newavatar
                        }
                        var user:OWSUserProfile?
                        kSignalDB.write { (transation) in
                            let address = SignalServiceAddress.init(phoneNumber: userId)
                            
                            user = OWSUserProfile.getOrBuild(for: address, transaction: transation)
                            user?.update(withProfileName: name, avatarUrlPath: avatar, avatarFileName: nil, transaction: transation, completion:nil)
                        }
                        users.append(user!);
                    }
                    
                }
               
                successed(users)
            }
            
            

            
        }) { (error) in
            DispatchQueue.main.async {
                failure(error);
            }
        }
//        PigramNetworkMananger.pgGetUserInfoNetwork(params: params, success: { (respone) in
//
//
//        }) { (error) in
//            DispatchQueue.main.async {
//                failure(error);
//            }
//        }
//        self.lookupIdentifiers([phoneNumber], success: { (recipients) in
//
//            if recipients.count > 0 {
//                let address = recipients.first!.address;
//                var user: OWSUserProfile?
//                SSKEnvironment.shared.databaseStorage.write { (write) in
//
//                    user = OWSUserProfile.getOrBuild(for: address, transaction: write);
//                    user?.update(withProfileName: <#T##String?#>, avatarUrlPath: <#T##String?#>, avatarFileName: <#T##String?#>, transaction: <#T##SDSAnyWriteTransaction#>, completion: <#T##OWSUserProfileCompletion?##OWSUserProfileCompletion?##() -> Void#>)
//
//                }
//
//
//
//            } else {
//                DispatchQueue.main.async {
//                    successed(nil);
//                }
//            }
//
//        }) { (error) in
//            DispatchQueue.main.async {
//                failure(error);
//            }
//        }
        
    }
    
    
    
    
    
    /**
     * 发送好友邀请
     * channel:  添加渠道
     * content：验证信息
     * note： 对好友进行备注
     */
    public func sendFriendInviteWithRecipient(_ address:SignalServiceAddress, action: PigramFriendAction, channel: PigramFriendChannel, content: String?, note: String?, success: @escaping () -> Void, failured: @escaping (_ error: Error) -> Void) {
        guard let  destinationId = address.phoneNumber else {
            let error = PigramTXError.request
            failured(error)
            return
        }

        let params = ["destinationId":destinationId]
        PigramNetworkMananger.pgAgreeAddFriendNetwork(params: params, success: { (response) in
            DispatchQueue.main.async {
                let thread = TSContactThread.getOrCreateFriendInviteThread(address: address);
                let message = PigramContactMessage.init(thread: thread, action: action, channel: channel);
                message.content = content;
                message.note = note;
                message.isSentByMe = true;
                if message.action == .accept {
                    //删除本地的对应的邀请消息
                    let model = PigramVerifyModel.init(applyid: address.userid!, destinationid: TSAccountManager.localUserId!);
                    PigramVerifyManager.shared.deleteVerifacation(model);
                    //生成一个好友对象  存到本地
                    SSKEnvironment.shared.databaseStorage.write { (write) in
                        let profile = OWSUserProfile.getOrBuild(for: address, transaction: write);
                        profile.relationType = .friend;
                        profile.anyInsert(transaction: write);
                    }
                }
                SSKEnvironment.shared.databaseStorage.asyncWrite { (write) in
                    thread.anyRemove(transaction: write);
                }
                
                success()
            }
        }) { (error) in
            DispatchQueue.main.async {
                failured(error)
            }
        }

    }
    
    
}


extension TSContactThread {
    
    private struct AssociatedKeys {
        
        static var isFriendInviteThread = "inviteFriendKey";
        
    }
    
    /**
     *  这个thread是否用于发送好友邀请
     */
    @objc
    public var isFriendInviteThread: Bool {
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isFriendInviteThread, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        get {
            
            return objc_getAssociatedObject(self, &AssociatedKeys.isFriendInviteThread) as? Bool ?? false;
        }
        
    };
    
    /**
     * 创建发送好友邀请的thread
     */
    @objc
    static public func getOrCreateFriendInviteThread(address: SignalServiceAddress) -> TSContactThread {
        
        let thread = TSContactThread.getOrCreateThread(contactAddress: address);

        thread.isFriendInviteThread = true;
        return thread;
        
    }
   
    
    
    
}

extension PigramContactIncomingMessage {
    
        /**
         * 获取所有的好友邀请  并过滤掉重复消息
         */
        static public func allNewFriendsMessage() -> [PigramContactIncomingMessage]? {
            
            var messages:[Any] = [];
            SSKEnvironment.shared.databaseStorage.read { (read) in
                  messages = PigramContactIncomingMessage.anyFetchAll(transaction: read);

                messages = messages.filter { (message) -> Bool in
                    if let newMessage = message as? PigramContactIncomingMessage {
                        return newMessage.action == .apply && newMessage.authorAddress.isValid;
                    }
                    return false;
                }
            }
            
            return messages as? [PigramContactIncomingMessage];
        }
        
    
    public func getUserProfile() -> OWSUserProfile {
          
          var user: OWSUserProfile?
          
          SSKEnvironment.shared.databaseStorage.write { (write) in
              user = OWSUserProfile.getOrBuild(for: self.authorAddress, transaction: write);
          }
          return user!
          
      }
}


extension TSGroupModel {
    

    /**
     * 根据profil数组 生成默认的群组图像
     */
    static func generateGroupDefaultImage(_ users:[OWSUserProfile]) -> UIImage {
        
        let bwh: CGFloat = 52;
        let swh: CGFloat = bwh / 4;
         var images:[UIImage] = [];
        
        for item in users {
            let image = item.getContactAvatarImage()!.resizedImage(to: CGSize.init(width: 15, height: 15));
            images.append(image!);
            if images.count == 4 {
                break;
            }
        }
        UIGraphicsBeginImageContext(CGSize.init(width: bwh, height: bwh));
        let rect = CGRect.init(x: 0, y: 0, width: bwh, height: bwh);
        let context = UIGraphicsGetCurrentContext();
        if images.count == 3 {
            
            images.first?.draw(at: CGPoint.init(x: bwh * 0.5 - swh, y: (bwh - swh * 2) * 0.5));
            images[1].draw(at: CGPoint.init(x: (bwh - swh * 2) * 0.5, y: (bwh - swh * 2) * 0.5 + swh));
            images[2].draw(at: CGPoint.init(x: (bwh - swh * 2) * 0.5 + swh, y: (bwh - swh * 2) * 0.5 + swh));
        } else if images.count == 4 {
            
            for (index,img) in images.enumerated() {
                img.draw(at: CGPoint.init(x: CGFloat(index) * CGFloat((index % 2)), y: CGFloat(index) * CGFloat((index / 2))))
            }
        }
        context?.setFillColor(kPigramThemeColor!.cgColor);
        context?.fill(rect);
        context?.addEllipse(in: rect);
        context?.clip();
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!;
    }
    
    
}


extension TSGroupModel {
    
    //MARK:-  初始化群成员
    public static func pg_initGroupMembers(_ response : Any?) -> [PigramGroupMember]?{
        guard let memebers = response as? Array <Dictionary <String,Any>> else {
            return nil
        }
        var groupMembers : [PigramGroupMember] = []
        for item in memebers{
            guard let groupMember = self.pg_initMember(item) else {
                continue
            }
            groupMembers.append(groupMember);
        }
        return groupMembers
    }
    
    
    private static func pg_initMember(_ dict: [String : Any]?) -> PigramGroupMember?{
        guard let item = dict  else {
            return nil
        }
        guard let userid = item["userId"] as? String  else {
            return nil;
        }
        let groupMember = PigramGroupMember.init(userId: userid);
        //
        if let nickname = item["name"] as? String {
            groupMember.nickname = nickname
        }
        if let perm = item["perm"] as? UInt32 {
            groupMember.perm = perm
        }
        if let memberRightBan = item["memberRightBan"] as? UInt32 {
            groupMember.memberRightBan = memberRightBan
        }
        if let userAvatar = item["userAvatar"] as? String {
            groupMember.userAvatar = userAvatar
        }
        if let remarkName = item["remarkName"] as? String {
            groupMember.remarkName = remarkName
        }
        if let memberStatus = item["memberStatus"] as? UInt32 {
            groupMember.memberStatus = memberStatus
        }
        return groupMember;
    }
    
    /**
     * 从服务获取群组信息 初始化群组需要的model 初始化群列表模型
     */
//    public static func pg_initGroupModel(_ dict: [String : Any]?) -> TSGroupModel? {
//
//        if let _response = dict {
//
//            guard let id = _response["id"] as? String else {
//                return nil;
//            }
//            guard  let ownerMember = self.pg_initMember(_response["owner"] as? [String : Any]) else {
//                return nil
//            }
//
            
            
            /*
//             "permRights": [                 --角色组权限
//             {
//             "perm": 0,                           --角色， 0：群主， 1：管理， 2：群员
//             "groupRight": "0"                    --权限，0：发送所有消息， 1：发送文本， 2:能发送图片
//             },
//
//             */
//            let members: [PigramGroupMember] = [ownerMember];
//            let groupName: String = _response["title"] as? String ?? "";
//            let model = TSGroupModel.init(title: groupName, members: members, groupId: id, owner: ownerMember.userId);
//
//            //二进制的图片
//            if let avatar = _response["avatar"] as? String {
//                model.avatar = avatar
//                SSKEnvironment.shared.databaseStorage.write { (transaction) in
//                    let profile = OWSUserProfile.getOrBuild(for: SignalServiceAddress.init(phoneNumber: model.groupId), transaction: transaction)
//                    let hasNewAvatar = profile.avatarUrlPath != avatar;
//                    profile.update(withProfileName: profile.profileName, avatarUrlPath: avatar, avatarFileName: hasNewAvatar ? nil : profile.avatarFileName, transaction: transaction, completion: nil);
//                }
//            }
//            model.txGroupType = TXGroupType(rawValue: TXGroupType.RawValue(_response["groupStatus"] as? Int ?? 0));
//            if let memberCount = _response["memberCount"] as? Int  {
//                model.membersCount = memberCount
//            }
//            if let  groupStatus = _response["groupStatus"] as? Int  {
//                model.groupStatus = groupStatus
//            }
//            if let permRightBans = _response["permRightBans"] as? Array <Dictionary <String,Any>>{
//                let rightBans = NSMutableSet.init()
//                for rightBan in permRightBans {
//                    let rightBanItem = PigramRoleRightBan.init()
//                    if let perm = rightBan["perm"] as? UInt32 {
//                        rightBanItem.perm = perm
//                    }
//                    if let groupRightBan = rightBan["groupRightBan"] as? UInt32 {
//                        rightBanItem.groupRightBan = groupRightBan
//                    }
//                    rightBans.add(rightBanItem)
//                }
//                model.permRightBans = rightBans.allObjects as! [PigramRoleRightBan]
//            }
//            if let notices = _response["notices"] as? Array <Dictionary <String,Any>> {
//                let noticeItems = NSMutableSet.init()
//                for notice in notices {
//                    guard let id = notice["id"] as? UInt32 else {
//                        continue
//                    }
//                    let idString = String(id)
//                    let noticeItem = PigramGroupNotice.init(id: idString)
//                    if let content = notice["content"] as? String {
//                        noticeItem.content = content
//                    }
//                    if let lastUpdate = notice["lastUpdate"] as? UInt64 {
//                        noticeItem.lastUpdate = lastUpdate
//                    }
//                    if let updatebyUserName = notice["updatebyUserName"] as? String {
//                        noticeItem.updatebyUserName = updatebyUserName
//                    }
//                    if let updatebyUserAvatar = notice["updatebyUserAvatar"] as? String {
//                        noticeItem.updatebyUserAvatar = updatebyUserAvatar
//                    }
//                    if let updatebyUserId = notice["updatebyUserId"] as? String {
//                        noticeItem.updatebyUserId = updatebyUserId
//                    }
//                    noticeItems.add(noticeItem)
//                }
//                model.notices = noticeItems.allObjects as! [PigramGroupNotice]
//            }
//
//            PigramGroupManager.shared.updateOrAddGroupModel(model);
//            return model;
//        }
//        return nil;
//
//    }
    
    /**
     * 从服务获取群组信息 初始化群组需要的model 初始化群详情模型
     */
    public static func pg_initGroupModelDetial(_ dict: [String : Any]?,_ isNeedMembers: Bool = true) -> TSGroupModel? {
        if let _response = dict {
            
            guard let id = _response["id"] as? String else {
                return nil;
            }

            /*
             "permRights": [                 --角色组权限
             {
             "perm": 0,                           --角色， 0：群主， 1：管理， 2：群员
             "groupRight": "0"                    --权限，0：发送所有消息， 1：发送文本， 2:能发送图片
             },
             
             */
            var inGroup = false
            var owner : String = "";
            var members: [PigramGroupMember] = [];
            let groupName: String = _response["title"] as? String ?? "";
            let linkString: String? = _response["link"] as? String;

            let groupMembers = _response["groupMembers"] as? Array<Dictionary<String,Any>>
            var me: PigramGroupMember?
            for item in groupMembers ?? []{
                guard let userid = item["userId"] as? String  else {
                    continue;
                }
               
                let groupMember = PigramGroupMember.init(userId: userid);
                //
                if let nickname = item["name"] as? String {
                    groupMember.nickname = nickname
                }
                if let perm = item["perm"] as? UInt32 {
                    groupMember.perm = perm
                    if perm == 0 {
                        owner = userid
                    }
                }
                if let memberRightBan = item["memberRightBan"] as? UInt32 {
                    groupMember.memberRightBan = memberRightBan
                }
                if let userAvatar = item["userAvatar"] as? String {
                    groupMember.userAvatar = userAvatar
                }
                if let remarkName = item["remarkName"] as? String {
                    groupMember.remarkName = remarkName
                }
                if let memberStatus = item["memberStatus"] as? UInt32 {
                    groupMember.memberStatus = memberStatus
                }
                if userid == TSAccountManager.localUserId ?? "" {
                    inGroup = true
                    me = groupMember;
                }
                members.append(groupMember);

            }
                    
//            guard let newOwner = owner else {
//                return nil
//            }
            
             var model = TSGroupModel.init(title: groupName, members: members, groupId: id, owner: owner);
            model.linkString  = linkString
            var newGroupMembers:[PigramGroupMember] = [];
            if !isNeedMembers ,let myself = me  {
                newGroupMembers.append(myself);
                model = TSGroupModel.init(title: groupName, members: newGroupMembers, groupId: id, owner: owner);
            }
           
            
            //二进制的图片
            if let avatar = _response["avatar"] as? String {
                model.avatar = avatar
            }

            SSKEnvironment.shared.databaseStorage.write { (transaction) in
                let profile = OWSUserProfile.getOrBuild(for: SignalServiceAddress.init(phoneNumber: model.groupId), transaction: transaction);
                if profile.profileName != model.groupName {
                    profile.update(withProfileName: groupName, avatarUrlPath: model.avatar, avatarFileName: profile.avatarFileName, transaction: transaction, completion: nil);
                }
               
            }
            model.txGroupType = TXGroupType(rawValue: TXGroupType.RawValue(_response["groupStatus"] as? Int ?? 0));
            if !inGroup&&model.txGroupType == TXGroupTypeJoined {
                model.txGroupType = TXGroupTypeUnknow
            }
          
            if let memberCount = _response["memberCount"] as? Int  {
                model.membersCount = memberCount
            }else{
                model.membersCount = members.count
            }
            if let  groupStatus = _response["groupStatus"] as? Int  {
                model.groupStatus = groupStatus
            }
            if let permRightBans = _response["permRightBans"] as? Array <Dictionary <String,Any>>{
                let rightBans = NSMutableSet.init()
                for rightBan in permRightBans {
                    let rightBanItem = PigramRoleRightBan.init()
                    if let perm = rightBan["perm"] as? UInt32 {
                        rightBanItem.role = perm
                    }
                    if let groupRightBan = rightBan["groupRightBan"] as? UInt32 {
                        rightBanItem.groupRightBan = groupRightBan
                    }
                    rightBans.add(rightBanItem)
                }
                model.permRightBans = rightBans.allObjects as! [PigramRoleRightBan]
            }
            if let notices = _response["notices"] as? Array <Dictionary <String,Any>> {
                let noticeItems = NSMutableSet.init()
                for notice in notices {
                    guard let id = notice["id"] as? UInt32 else {
                        continue
                    }
                    let idString = String(id)
                    let noticeItem = PigramGroupNotice.init(id: idString)
                    if let content = notice["content"] as? String {
                        noticeItem.content = content
                    }
                    if let lastUpdate = notice["lastUpdate"] as? UInt64 {
                        noticeItem.lastUpdate = lastUpdate
                    }
                    if let updatebyUserName = notice["updatebyUserName"] as? String {
                        noticeItem.updatebyUserName = updatebyUserName
                    }
                    if let updatebyUserAvatar = notice["updatebyUserAvatar"] as? String {
                        noticeItem.updatebyUserAvatar = updatebyUserAvatar
                    }
                    if let updatebyUserId = notice["updatebyUserId"] as? String {
                        noticeItem.updatebyUserId = updatebyUserId
                    }
                    noticeItems.add(noticeItem)
                }
                model.notices = noticeItems.allObjects as! [PigramGroupNotice]
            }
            
            if let notificationMutes = _response["notificationMutes"] as? [[String : Any]] {
                
                var dict:[AnyHashable : Any] = [:];
                for item in notificationMutes {
                    let id = "\(item["id"] ?? "-1")";
                    let action = item["action"] as Any;
                    dict[id] = action;
                }
                model.notificationMutes = dict;
            }
            
            return model;
        }
        return nil;
        
    }
    
}



























extension OWSRequestFactory{

    
    /**
     * 拉取好友列表
     */
    static func pg_getMyFriendList(_ status: Int = 0) -> TSRequest? {
        let path = "/v1/relations"
        let url = URL.init(string: path)
        guard let urlRequest = url else {
            return nil
        }
        let request = TSRequest.init(url: urlRequest, method: "GET",parameters: status > 0 ? ["status": status] : [:]);
        request.authUsername = TSAccountManager.localUserId;
        request.authPassword = TSAccountManager.sharedInstance().storedServerAuthToken();
        return request;
    }
    
    /**
     * 拉去群列表
     */
    static func pg_getMyGroupList() -> TSRequest? {
           let path = "/v1/groups"
           let url = URL.init(string: path)
           guard let urlRequest = url else {
               return nil
           }
           let request = TSRequest.init(url: urlRequest, method: "GET",parameters:["groupStatus":1]);
           request.authUsername = TSAccountManager.localUserId;
           request.authPassword = TSAccountManager.sharedInstance().storedServerAuthToken();
           
           return request;

       }
    
    /**
     * 根据群ID 获取群信息
     */
    static func pg_getGroupInfo(_ groupId: String, isNeedMembers: Bool) -> TSRequest? {

        
        let idStr = groupId;
//        idStr = idStr.replaceCharacters(characterSet: CharacterSet.init(charactersIn: "/"), replacement: "_");

        let path = "/v1/groups/find/\(idStr)?inc_member=\(isNeedMembers)"
        
           let url = URL.init(string: path)
           guard let urlRequest = url else {
               return nil
           }
        let request = TSRequest.init(url: urlRequest, method: "GET",parameters:[:]);
           request.authUsername = TSAccountManager.localNumber;
           request.authPassword = TSAccountManager.sharedInstance().storedServerAuthToken();
           
           return request;

       }
    
    /**
     * 根据群ID 获取群信息
     */
    static func pg_getGroupInfoIncludeMyself(_ groupId: String) -> TSRequest? {
        
        
        let idStr = groupId;
        //        idStr = idStr.replaceCharacters(characterSet: CharacterSet.init(charactersIn: "/"), replacement: "_");
        
        let path = "/v1/groups/find_with_owner_self/\(idStr)"
        
        let url = URL.init(string: path)
        guard let urlRequest = url else {
            return nil
        }
        let request = TSRequest.init(url: urlRequest, method: "GET",parameters:[:]);
        request.pgSetupAuth()

        
        return request;
        
    }
    
}

extension TSAccountManager{

}


    
extension PigramGroupMember
{
    /// MARK: 获取好友头像
    @objc
    public func getContactAvatarImage(_ imageView:UIImageView?) {
        let name = self.getRemarkNameInfo()
        let buidler = OWSContactAvatarBuilder.init(address: SignalServiceAddress.init(phoneNumber: self.userId), name: name, colorName: ConversationColorName.pigramThemeColor, diameter: 52)
        var image = buidler.buildSavedImage();
        if image == nil{
            image = buidler.buildDefaultImage();
            if let avatar = self.avatarUrlPath(),let avatarUrl = URL.init(string: avatar),let iconImageView = imageView {
                iconImageView.setImageWith(avatarUrl, placeholderImage: image)
                return
            }
        }
        imageView?.image = image
    }
}


extension OWSProfileManager
{
    
    


}

extension PigramGroupMember{
    @objc
    public func avatarUrlPath() -> String?{
        guard let avatar = self.userAvatar else{
            return nil
        }
        if !avatar.hasPrefix("http") {
            let cdnsServer = PigramUploadConfig.share.bucket
            return "\(cdnsServer)/\(avatar)"
        }
        return avatar
    }
}

extension OWSSignalService:OWSSignalServiceProtocol{
    public func getCDNServer() -> String {
        return PigramUploadConfig.share.bucket
    }
}
