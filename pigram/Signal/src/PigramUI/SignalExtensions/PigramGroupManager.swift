//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

import UIKit

class PigramGroupManager: NSObject {


    let groupModelsCache : NSCache = NSCache<NSString,TSGroupModel>()
    static let shared = PigramGroupManager.init();
    var groupPath : String?
    
    private override init() {
        super.init();
        self.groupModelsCache.countLimit = 10
        self.addObserver()
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_Pigram_Group_Message_Handle_C" object:@[envelope,message]];
//        self.groupModelsCache.set
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    public func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleGroupMessage(noti:)), name: NSNotification.Name.init("kNotification_Pigram_Group_Message_Handle_C"), object: nil)
    }
    @objc func handleGroupMessage(noti:Notification){
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.2) {
            if let objct = noti.object as? Array<Any>{
                guard let enevlop = objct.first as? SSKProtoEnvelope else{
                    return
                }
                guard let message = objct[1] as? SSKProtoGroupContext  else {
                    return
                }
                self.dealIncoming(envelope: enevlop, message: message)
            }
        }
        
    }
    
    public static func pg_initialize() {
        AppReadiness.runNowOrWhenAppDidBecomeReady {
            kSignalDB.read { (read) in
                let threads = TSThread.anyFetchAll(transaction: read)
                for item in threads {
                    if let _group = item as? TSGroupThread {
                        PigramGroupManager.shared.modelDict[_group.groupModel.groupId] = _group.groupModel;
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(self.shared, selector: #selector(getMtGroupList), name: NSNotification.Name.init("kNotification_login_successsful"), object: nil)
        if SSKEnvironment.shared.tsAccountManager.isRegistered {
            PigramGroupManager.shared.getMtGroupList();
        }
       
    }
    
    
    @objc
    private func getMtGroupList() {
        PigramNetwork.getMyGroupList { (results, error) in
            if let _value = results {
                kSignalDB.asyncWrite { (write) in
                    for item in _value {
                        PigramGroupManager.shared.modelDict[item.groupId] = item;
                        let thread = TSGroupThread.getOrCreateThread(with: item, transaction: write);
                        thread.anyUpdateGroupThread(transaction: write) { (thread) in
                            thread.groupModel = item;
                        }
                    }
                }
            }
        }
    }
    
    
    public func getGroupModel(groupID: String, _ ignoreFetch:Bool = false) -> TSGroupModel? {
        if groupID.count == 0 {
            return nil;
        }
        
        var model: TSGroupModel?;
//        model = self.modelDict[groupID]
        if model  == nil {
            let thread_id  = TSGroupThread.threadId(fromGroupId: groupID);
            kSignalDB.read { (read) in
                let thread = TSGroupThread.anyFetch(uniqueId: thread_id, transaction: read) as? TSGroupThread;
                model = thread?.groupModel;
            }
        }
        if model == nil {
                PigramNetwork.getGroupInfo(groupID) { (model, error) in
                    if model != nil && ignoreFetch == false {
                        if let  _ = model!.member(withUserId: TSAccountManager.localUserId) {
                            kSignalDB.write { (write) in
                                let thread = TSGroupThread.getOrCreateThread(withGroupId: model!.groupId, transaction: write)
                                thread.anyUpdateGroupThread(transaction: write) { (thread) in
                                    thread.groupModel = model!
                                }
                            }
                        }
                        PigramGroupManager.shared.updateOrAddGroupModel(model!);
                    }
                };
        }
        return model;
    }
    
    
    public func updateOrAddGroupModel(_ model: TSGroupModel) {
        self.modelDict[model.groupId] = model;
    }
    
    public func deleteGroupModel(_ model: TSGroupModel) {
        self.modelDict.removeValue(forKey: model.groupId);
    }
    
    public func allGroupModel() -> [TSGroupModel] {
        
        var all: [TSGroupModel] = [];
        
        for item in self.modelDict.values {
            all.append(item);
        }
        return all;
        
    }
    
    /**
     * 判断群组是否有效
     */
    static public func groupIsvalid(thread: TSGroupThread) -> Bool {
        
        var result = false;
        
        //1、判读自己在不在群内
        let inGroup = thread.isLocalUserInGroup();
        
        if inGroup && thread.groupModel.txGroupType == TXGroupTypeJoined {
            result = true;
        }
        
        return result;
    }
    
    // MARK: private
    private var modelDict:[String: TSGroupModel] = [:];
}


extension PigramGroupManager {

    
    
    //MARK:-  创建群
    static func createGroups(fromVC:UIViewController,_ users:[OWSUserProfile], finished:@escaping (Bool) -> Void){
//        var allUsers = Array.init(users);
        var groupName = "";
        let groupMembers : NSMutableSet  = NSMutableSet.init()//构建群成员

        for (_,item) in users.enumerated()  {
            groupName.append("\(item.profileName ?? "")、" );
            if let userId = item.address.phoneNumber{
                groupMembers.add(userId)
            }
        }

        if groupName.length > 10 {
            groupName = groupName.substring(to: 10) + "...";
        }
        if groupName.length == 0 {
            groupName = "新建群组\(arc4random() % 100)";
        }

        
        let successful:(ModalActivityIndicatorViewController,Any?) -> Void = {(modal,response) in
            DispatchQueue.main.async {
                modal.dismiss {
                    guard let owner = TSAccountManager.localUserId else{
                        finished(false);
                        return
                    }
                    guard let responseObject = response as? Dictionary<String,Any> else
                    {
                        finished(false);
                        return
                    }
                    guard let id = responseObject["id"] as? String else{
                        finished(false);
                        return
                    }

                    guard let groupMembers = responseObject["groupMembers"] as? Array<Any> else{
                        return
                    }
                    var allMembers:[PigramGroupMember] = []
                    for member in groupMembers{
                        if let memberDic = member as? Dictionary<String,Any>{
                            guard let userId = memberDic["userId"] as? String else{
                                continue
                            }
                            let groupMember =  PigramGroupMember.init(userId: userId)
//
                            if let nickname = memberDic["name"] as? String {
                                groupMember.nickname = nickname
                            }
                            if let perm = memberDic["perm"] as? UInt32 {
                                groupMember.perm = perm
                            }
                            if let memberRightBan = memberDic["memberRightBan"] as? UInt32 {
                                groupMember.memberRightBan = memberRightBan
                            }
                            if let userAvatar = memberDic["userAvatar"] as? String {
                                groupMember.userAvatar = userAvatar
                            }
                            if let remarkName = memberDic["remarkName"] as? String {
                                groupMember.remarkName = remarkName
                            }
                            if let memberStatus = memberDic["memberStatus"] as? UInt32 {
                                groupMember.memberStatus = memberStatus
                            }
                            allMembers.append(groupMember)
                        }
                    }
                
                    let model = TSGroupModel.init(title: groupName, members: allMembers, groupId: id, owner: owner)
                    if let groupStatus = responseObject["status"] as? Int{
                        model.groupStatus = groupStatus;
                    }
                    finished(true);
                    //指定自己为群主
                    model.txGroupType = TXGroupTypeJoined;
                    model.membersCount = allMembers.count;
                    var thread : TSGroupThread!
                    SSKEnvironment.shared.databaseStorage.write { (transacation) in
                        thread = TSGroupThread.getOrCreateThread(with: model, transaction: transacation)
                        thread.anyUpdateGroupThread(transaction: transacation) { (thread) in
                            thread.shouldThreadBeVisible = true
                            thread.groupModel = model
                        }
                    }
                    OWSProfileManager.shared().addThread(toProfileWhitelist: thread);
                    let vc = ConversationViewController.init();
                    vc.configure(for: thread, action: .none, focusMessageId: nil);
                    fromVC.navigationController?.setSecondSubVC(vc);
                    vc.hidesBottomBarWhenPushed = true
                    PigramGroupManager.shared.updateOrAddGroupModel(model);
                   
                    
                }
            }
            
        };
        
        let failured:(ModalActivityIndicatorViewController, Error) -> Void = {
            (modal,error) in
            DispatchQueue.main.async {
                modal.dismiss {
                    finished(false);
                    OWSAlerts.showErrorAlert(message: error.localizedDescription);
                }
            }
        };
        
        ModalActivityIndicatorViewController.present(fromViewController: fromVC.presentedViewController!, canCancel: false) { (modal) in
            let params = ["title":groupName,"groupMembers":groupMembers.allObjects] as [String : Any]
            PigramNetworkMananger.pgCreateGroupsNetwork(params: params, success: { (response) in
                successful(modal,response)
            }) { (error) in
                failured(modal,error)
            }
            
        };
    }
    
    
    
    
    
    
    

    private func lastVersionHandleJoinGroup(_ groupId: String) {
//        PigramNetwork.getGroupInfo(groupId) { (model, error) in
//                       if let ensureModel =  model{
//                           if ensureModel.groupOwner.length == 0 {//如果没有群主则返回
//                               return
//                           }
//                           var newMembersDic : [String : SignalServiceAddress] = [:]
//                           //MARK:过滤重复数据
//                           for address in ensureModel.allMembers {
//                               if let phoneNumber = address.phoneNumber{
//                                   newMembersDic[phoneNumber] = address
//                               }
//                           }
//                           let values = Array(newMembersDic.values)
//                           if let   newManagers = NSSet.init(array: ensureModel.groupManagers).allObjects as? [String]{
//                               //MARK:过滤重复
//                               ensureModel.groupManagers = newManagers
//                           }
//                           let newModel = TSGroupModel.init(title: ensureModel.groupName, members: values, image: ensureModel.groupImage, groupId: ensureModel.groupId)
//                           newModel.txSetup(oldModel: ensureModel)
//                           if !ensureModel.groupMembers.contains(where: { (address) -> Bool in
//                               if address.phoneNumber == TSAccountManager.localNumber{
//                                   return true
//                               }
//                               return false
//                           }) {
//
//                               SSKEnvironment.shared.databaseStorage.write { (write) in
//                                   let thread = TSGroupThread.getOrCreateThread(with: newModel, transaction: write)
//                                   newModel.txGroupType = TXGroupTypeExit
//                                   thread.anyUpdateGroupThread(transaction: write) { (thread) in
//                                       thread.shouldThreadBeVisible = false
//                                       thread.groupModel = newModel
//                                   }
//                               }
//                               //MARK:不包含自己就直接返回
//                               return
//                           }
//                           SSKEnvironment.shared.databaseStorage.write { (transaction) in
//                               let thread = TSGroupThread.getOrCreateThread(with: ensureModel, transaction: transaction)
//                               thread.anyUpdateGroupThread(transaction: transaction) { (thread) in
//                                   thread.groupModel = newModel
//                                   thread.shouldThreadBeVisible = true
//                               }
//                               let updateInfo = "你已加入群组"
//                               let message = TSInfoMessage.init(timestamp: NSDate.ows_millisecondTimeStamp(), in: thread, messageType: TSInfoMessageType.typeGroupUpdate, customMessage: updateInfo)
//                               message.anyInsert(transaction: transaction)
//                               // MJK TODO - should be safe to remove senderTimestam
//                           }
//                       }
//                   }
    }
}





extension PigramGroupManager{
    
    
    @objc func getFileDirectory() -> String?{
        if let path = self.groupPath {
            return path
        }
        guard var  path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else{
            return nil
        }
        
        path =  "\(path)/Pigram_Group_Model_File";
        if FileManager.default.fileExists(atPath: path) {
        }else{
            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        self.groupPath = path;
        return path;
    }
    
    
    //保存群组模型
    @objc func saveGroupModel(groupModel:TSGroupModel?){
        guard let model = groupModel else {
            return
        }
        self.groupModelsCache.setObject(model, forKey: NSString.init(string: model.groupId))
        guard var path = self.getFileDirectory()  else {
            return
        }
        path = "\(path)/\(model.groupId)"
        DispatchQueue.global().async {
//            let start = NSDate.ows_millisecondTimeStamp()
            let success =  NSKeyedArchiver.archiveRootObject(model, toFile: path)
//            let end = NSDate.ows_millisecondTimeStamp()
//            OWSLogger.info("归档加写入时间 == \(end - start)")
            if !success {
                owsFailDebug("保存失败")
            }
        }
    }
    @objc func synchronizationGroupModel(groupId:String){
        if let model = self.groupModelsCache.object(forKey: NSString.init(string: groupId)) {
            DispatchQueue.main.async {
                guard var path = self.getFileDirectory()  else {
                    return
                }
                path = "\(path)/\(groupId)"
                let success =  NSKeyedArchiver.archiveRootObject(model, toFile: path)
                if !success {
                    owsFailDebug("保存失败")
                }
            }
        }
    }
    //获取群组模型
    @objc func getGroupModel(groupId:String) -> TSGroupModel?{
        if let model = self.groupModelsCache.object(forKey: NSString.init(string: groupId)) {
            return model
        }
        guard var path = self.getFileDirectory()  else {
            return nil
        }
        path = "\(path)/\(groupId)"
        if FileManager.default.fileExists(atPath: path) {
//            let start = NSDate.ows_millisecondTimeStamp()
            guard let model = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? TSGroupModel else{
    //            owsFailDebug("没有获取到失败")
                return nil
            }
            
//            let end = NSDate.ows_millisecondTimeStamp()
//            OWSLogger.info("读取归档时间 == \(end - start)")
            self.groupModelsCache.setObject(model, forKey: NSString.init(string: groupId))
            return model
        }
        return nil

    }
    
    @objc func removeGroupModel(groupId:String){
        self.groupModelsCache.removeObject(forKey: NSString.init(string: groupId))
        guard var path = self.getFileDirectory()  else {
            return
        }
        path = "\(path)/\(groupId)"
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            }catch let error {
                owsFailDebug("删除失败")
            }
        }

            
    }
}



extension PigramGroupManager{
    

    @objc func dealIncoming(envelope:SSKProtoEnvelope,message:SSKProtoGroupContext){
        let queue = DispatchQueue.init(label: "pigram.concurrent.group.message.handlde.queue.com", qos: .default, attributes: .concurrent, autoreleaseFrequency: .never, target: nil)
        let item = DispatchWorkItem.init(qos: .default, flags: .barrier) {
            
            let groupId = envelope.groupId ?? message.id
            guard let model = PigramGroupManager.shared.getGroupModel(groupId: groupId) else {
                return;
            }
            switch message.unwrappedType {
            //被添加入群 或者创建群
            case .drag:
                for member in message.members ?? [] {
                    if let groupMember = PigramGroupMember.getGroupMember(protoMember: member){
                        if model.member(withUserId: groupMember.userId) == nil {
                            model.allMembers.append(groupMember)
                        }
                    }
                }
                model.membersCount = model.allMembers.count
                PigramGroupManager.shared.saveGroupModel(groupModel: model)
                break;
            //增加操作 取决于target
            case .add:
                switch message.target {
                //增加管理员
                case .manager:
                    for member in message.members ?? [] {
                        if let groupMember = PigramGroupMember.getGroupMember(protoMember: member){
                            if let modelMember = model.member(withUserId: groupMember.userId) {
                                modelMember.perm = groupMember.perm
                            }else
                            {
                                model.allMembers.append(groupMember)
                            }
                        }
                    }
                    PigramGroupManager.shared.saveGroupModel(groupModel: model)
                    break
                default:
                    break
                }
                break
            //拉黑或禁言操作
            case .block:
                for member in message.members ?? [] {
                    if let groupMember = PigramGroupMember.getGroupMember(protoMember: member){
                        if let modelMember = model.member(withUserId: groupMember.userId) {
                            modelMember.memberStatus = groupMember.memberStatus
                        }else
                        {
                            model.allMembers.append(groupMember)
                        }
                    }
                }
                PigramGroupManager.shared.saveGroupModel(groupModel: model)
                
                break;
            //删除操作 取决于target
            case .remove:
                switch message.target {
                case .manager:
                    for member in message.members ?? [] {
                        if let groupMember = PigramGroupMember.getGroupMember(protoMember: member){
                            if let modelMember = model.member(withUserId: groupMember.userId) {
                                modelMember.perm = groupMember.perm
                            }else
                            {
                                model.allMembers.append(groupMember)
                            }
                        }
                    }
                    PigramGroupManager.shared.saveGroupModel(groupModel: model)
                    break
                case .member:
                    for member in message.members ?? [] {
                        model.allMembers = model.allMembers.filter({ (groupMember) -> Bool in
                            return groupMember.userId != member.id
                        })
                    }
                    model.membersCount = model.allMembers.count
                    PigramGroupManager.shared.saveGroupModel(groupModel: model)
                    break
                default:
                    break
                }
                break
            //更新某群
            case .update:
                if message.target == .owner {
                    var newOwner : String = model.groupOwner
                    for member in message.members ?? [] {
                        if let groupMember = PigramGroupMember.getGroupMember(protoMember: member){
                            if groupMember.perm == 0 {
                                if let oldOwnerMember = model.member(withUserId: model.groupOwner){
                                    oldOwnerMember.perm = 2;
                                }
                                newOwner = groupMember.userId
                                groupMember.memberStatus = 1;
                                if let newOwnerMember = model.member(withUserId: newOwner) {
                                    newOwnerMember.perm = 0
                                    newOwnerMember.memberStatus = 1;
                                }else{
                                    model.allMembers.append(groupMember)
                                }
                                model.groupOwner = newOwner
                            }
                        }
                    }
                } else if message.target == .permGroup {
                    if let threadGroupModel = PigramGroupManager.shared.getGroupModel(groupID: groupId, true) {
                        
                        model.permRightBans = threadGroupModel.permRightBans;
                        
                    }
                }
                PigramGroupManager.shared.saveGroupModel(groupModel: model)
                break
            //某群解散
            case .dismiss:
                model.txGroupType = TXGroupTypeExit;
                PigramGroupManager.shared.removeGroupModel(groupId: groupId)
                break
            //某人离群
            case .quit:
                for member in message.members ?? [] {
                    if member.id == TSAccountManager.localUserId {
                        PigramGroupManager.shared.removeGroupModel(groupId: groupId)
                        return
                    }
                    model.allMembers = model.allMembers.filter { (groupMember) -> Bool in
                        return groupMember.userId != member.id
                    }
                }
                PigramGroupManager.shared.saveGroupModel(groupModel: model)
                break
            //同意某人进群 只有管理员以上身份会收到消息
            case .applyAccept:
                //                if let model = PigramGroupManager.shared.getGroupModel(groupId: groupId) {
                //                    for member in message.members ?? [] {
                //                        if let groupMember = PigramGroupMember.getGroupMember(protoMember: member) {
                //                            if model.member(withUserId: groupMember.userId) == nil{
                //                                model.allMembers.append(groupMember)
                //                            }
                //                        }
                //                    }
                //                    PigramGroupManager.shared.saveGroupModel(groupModel: model)
                //                }
                break
            default:
                break
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .init(rawValue: Pigram_Group_Status_Change_Notification), object:groupId, userInfo: nil)
            }
        }
        
        queue.async(execute: item)
    }
}
