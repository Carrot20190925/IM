//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXGroupInfoVC: BaseVC,TXGroupInfoHeadViewDelegate {
    public enum UserType {
        case owner
        case mananger
        case member
    }

    @objc
    enum ActionType:NSInteger {
        case leave
        case dissolution
    }
    public var thread : TSGroupThread?
    weak var delegate : OWSConversationSettingsViewDelegate?
    var groupModel : TSGroupModel?
    var members : [PigramGroupMember] = []
    var tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
    var headView = TXGroupInfoHeadView.init()
    var sectionItems:[[String]] = []
    var memberType : UserType = .member
    @objc
    var placeTopAction : ((_ on: Bool) -> Void)?
    
    @objc
    static func showGroupInfo(viewControllor:UIViewController,thread:TSGroupThread) -> TXGroupInfoVC{
        let info = TXGroupInfoVC.init()
        info.delegate = viewControllor as? OWSConversationSettingsViewDelegate
        info.thread = thread
        viewControllor.navigationController?.pushViewController(info, animated: true)
        return info
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "群聊资料"
//        self.setupNav()
        self.setupInit()
        self.setupHeadView()
        self.addObserverAction()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.groupModel == nil {
            self.checkGroupModelInfo()
        }
    }
    //MARK:-  判断群信息是否完整
    func checkGroupModelInfo() {
        guard let groupId = self.thread?.groupModel.groupId else {
            return
        }
        if let model = PigramGroupManager.shared.getGroupModel(groupId: groupId){
            if self.thread?.groupModel.membersCount == model.membersCount {
                
                self.groupModel = model;
                self.setupData()
                return
            }
        }
        
        ModalActivityIndicatorViewController.present(fromViewController: self.navigationController ?? self, canCancel: true) { [weak self](modal) in

            PigramNetwork.getGroupInfo(groupId, finished: { (model, error) in
                if let _model = model {
                    DispatchQueue.main.async {
                        self?.groupModel = _model
                        PigramGroupManager.shared.saveGroupModel(groupModel: _model)
                        kSignalDB.write { (write) in
                            self?.thread?.anyUpdateGroupThread(transaction: write, block: { (thread) in
                                thread.groupModel.membersCount = _model.allMembers.count;
                            })
                        }
                        modal.dismiss {
                            self?.setupData()
                        }
                    }
                } else {
                    modal.dismiss {
                        OWSAlerts.showErrorAlert(message: error?.localizedDescription ?? "请求失败!")
                    }
                }
            })
        }

    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
//    func setupNav() {
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-leftBack"), style: .plain, target: self, action: #selector(goBack))
//    }
//    @objc
//    func goBack() {
//        self.navigationController?.dismiss(animated: true, completion: nil)
//    }
    
    func setupData() {
        guard let model = self.groupModel else {
            return
        }
        guard (self.groupModel?.groupOwner) != nil else {
            return
        }
        
        if model.groupOwner == TSAccountManager.localUserId {//判断本人是不是群主
            self.memberType = .owner
            sectionItems = [["编辑资料","二维码","群公告","群链接","置顶会话"],["消息免打扰"],["群管理"],["清空聊天记录"]]
        }else{
            if let member = model.member(withUserId: TSAccountManager.localUserId), member.perm == 1 {
                self.memberType = .mananger
                sectionItems = [["编辑资料","二维码","群公告", "置顶会话"],["消息免打扰"],["群管理"],["清空聊天记录"]]
            }else{
                self.memberType = .member
                sectionItems = [["二维码","群公告", "置顶会话"],["消息免打扰"],["清空聊天记录"]]
            }
        }
        self.updateHeadView()
        self.tableView.reloadData()
    }
    
    
    func updateHeadView() {
        guard let model = self.groupModel else {
            return
        }
        self.members = model.allMembers.sorted(by: { (member1, member2) -> Bool in
            return member1.perm < member2.perm
        })
        headView.reloadData()
    }
    func setupHeadView() {
        headView.frame = CGRect.init(x: 0, y: 0, width: self.view.width(), height: 0)
        headView.setupUI()
        self.tableView.tableHeaderView = headView
        headView.delegate = self
        headView.reloadData()
        //MARK:-  //邀请好友 查看好友信息
        headView.inviteFriend = {[weak self] (index) in
            if self?.members.count ?? 0 > index && index <= 4 {
                if let member = self?.members[index]{
                    let vc = FriendSearchVC.init()
                    if self?.memberType == .member {
                        var user: OWSUserProfile?
                        kSignalDB.read { (read) in
                            user = OWSUserProfile.getFor(SignalServiceAddress.init(phoneNumber: member.userId), transaction: read)
                        }
                        if user?.relationType != .friend {
                            vc.hideConfirmBtn = true
                        }
                        if member.userId == TSAccountManager.localUserId {
                            vc.hideConfirmBtn = true
                        }
                        vc.phoneNumber = member.userId
                        vc.channel = .group
                        self?.navigationController?.pushViewController(vc, animated: true)
                        return
                    }else
                    {
                        if index != 4 {
                            if member.userId == TSAccountManager.localUserId {
                                vc.hideConfirmBtn = true
                            }
                            vc.phoneNumber = member.userId
                            vc.channel = .group
                            self?.navigationController?.pushViewController(vc, animated: true)
                            return
                        }
                    }
                }
            }
            
            let vc = ContactListVC.init();
            vc.navTitle = "邀请新成员";
            vc.rightNavTitle = "完成";
            var filterMembers:[String] = self?.groupModel?.allMembers.map({ (member) -> String in
                return member.userId;
            }) ?? [];
            filterMembers.append("___officer____!")
            vc.filters = filterMembers;
           
            vc.showVC(fromVC: self) { [weak self] (vc, results) in
                self?.handleGroupMembersInvite(vc: vc, results: results);
            }
            
        }
         //查看群成员列表
        headView.showMemers = {[weak self] in
            guard let thread = self?.thread else {
                return
            }
            TXSetGroupMembersVC.showVC(self, thread: thread, navTitle: "群成员列表", rightNavTitle: "", type: TXSetGroupMembersVC.SetType.normal) { (vc, profiles) in
                
            }
        }
    }
    /// MARK: 邀请好友进群
    private func handleGroupMembersInvite(vc: ContactListVC, results:[OWSUserProfile]) {
        
        if results.count == 0 {
            vc.dismiss(animated: true, completion: nil);
            return;
        }

        //如果我是群组或者是管理员 将人直接拉入群 然后更新群组信息
        let model = self.groupModel;
        if let  member = model?.member(withUserId: TSAccountManager.localUserId),member.perm != 2 {
            var addNames : [String] = []
            for profile in results{
                let profileName = profile.getContactName()
                addNames.append(profileName)
            }
            vc.dismiss(animated: true) {[weak self] in
                self?.setupAddMembers(addMembers: results, addNames: addNames)
            }

        }else{
            //如果是普通群成员  发送一个分享群名片消息
            OWSAlerts.showAlert(title: "发送群名片", message: "因为你不是群主或管理员，所以此次操作只会给对方发送一个群名片", buttonTitle: "发送") { (_) in
                
                
            };
        }

        
    }
    
    
    func numberItems() -> Int {
        return self.members.count
    }
    func memberItem(index: Int) -> PigramGroupMember? {
        return self.members[index]
    }
    func inviteItemHide() -> Bool {//普通成员就隐藏
        return self.memberType == .member
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension ConversationViewController{
//    @objc
//    func showGroupInfo() {
//
//    }
//}

extension TXGroupInfoVC:UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout{
    private func setupInit(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = TXTheme.thirdColor()
        tableView.frame = self.view.bounds
        tableView.backgroundColor = TXTheme.thirdColor()
        tableView.register(TXGroupInfoCell.self, forCellReuseIdentifier: "TXGroupInfoCell")
        self.view.addSubview(tableView)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionItems.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = self.sectionItems[section]
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : TXGroupInfoCell = tableView.dequeueReusableCell(withIdentifier: "TXGroupInfoCell", for: indexPath) as! TXGroupInfoCell
        cell.longPressAction = nil
        let items:[String] = self.sectionItems[indexPath.section]

        let text = items[indexPath.row]
        switch text {
        case "编辑资料":
            cell.showNextBtn()
            break
        case "二维码":
            cell.showNextBtn()
            break
        case "群链接":
            cell.longPressAction = {[weak self] _ in
                guard let link = self?.thread?.groupModel.linkString ,link.count > 0 else {
                    return
                }
                let paste = UIPasteboard.general
                paste.string = "https://p.land/\(link)"
            }
            cell.showNextBtn()
            if let link = self.thread?.groupModel.linkString,link.count > 0{
                cell.setSubtitle(subtitle: "https://p.land/\(link)")

            }else{
                cell.setSubtitle(subtitle: "未设置")

            }
        case "群公告":
            cell.showNextBtn()
            if let notices = self.thread?.groupModel.notices,let notice = notices.first,notice.content?.count != 0{
                if self.memberType == .owner {
                    cell.setSubtitle(subtitle: "编辑公告")
                }else{
                    cell.setSubtitle(subtitle: "查看公告")
                }
            }else
            {
                if self.memberType == .owner {
                    cell.setSubtitle(subtitle: "未设置")
                }else{
                    cell.setSubtitle(subtitle: "暂无公告")
                }
            }

        case "群管理":
            cell.showNextBtn()
            cell.setSubtitle(subtitle: "设置群权限")
        case "我的群昵称":
            cell.showNextBtn()

            if let remark = self.groupModel?.member(withUserId: TSAccountManager.localUserId)?.remarkName{
                cell.setSubtitle(subtitle: remark)
            }else{
                cell.setSubtitle(subtitle: "未设置")
            }
        case "置顶会话":
            cell.showSlider()
            cell.slider.setOn(self.thread?.tx_top ?? false, animated: true)
            cell.switchAction = {[weak self] on in
                self?.placeTopAction?(on.isOn)
            }
        case "消息免打扰":
            cell.showSlider()
            cell.slider.setOn(self.thread?.isMuted ?? false, animated: true)
            cell.switchAction = { [weak self] on in
                let timezone = TimeZone.init(identifier: "UTC")
                guard let time = timezone else {
                    return
                }
                var calendar = Calendar.current
                calendar.timeZone = time
                var dateComponents = DateComponents.init()
                if on.isOn {
                    dateComponents.year = 2

                }else
                {
                    dateComponents.second = 0
                }
                let date = calendar.date(byAdding: dateComponents, to: Date.init(timeIntervalSinceNow: 0))
                guard let ensureDate = date else {
                    return
                }
                SSKEnvironment.shared.databaseStorage.write { (transtion) in
                    self?.thread?.updateWithMuted(until: ensureDate, transaction: transtion)
                }
            }
        case "清空聊天记录":
            cell.hiddenMore()
            cell.tagLabel.textColor = TXTheme.secondColor()
    
        default:
            cell.showNextBtn()
        }
        cell.tagLabel.text = text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let items:[String] = self.sectionItems[indexPath.section]
        let text = items[indexPath.row]
        switch text {
        case "编辑资料":
           let editVC = TXEditGroupInfoVC.init()
           editVC.thread = self.thread
           self.navigationController?.pushViewController(editVC, animated: true)
        break
        case "二维码":
            let qrVC =  TXGroupQRVC.init()
            qrVC.thread = self.thread
            self.navigationController?.pushViewController(qrVC, animated: true)
        case "群公告":
            let announceVC = TXGroupAnnouncementVC.init()
            announceVC.complete = { [weak self] (text,vc) in
                self?.setupNotices(notices: [text],vc: vc)
            }
            if let notices = self.thread?.groupModel.notices,let  notice = notices.first{
                announceVC.notice = notice.content;
            }
            if let text = announceVC.notice,text.length != 0  {
                announceVC.type = TXGroupAnnouncementVC.AnnounceMentType.normal
            }else{
                if self.memberType != .owner {
                    return
                }
            }
            announceVC.isOwer = (self.memberType == .owner)
            let nav = BaseNavigationVC.init(rootViewController: announceVC)
            self.navigationController?.present(nav, animated: true, completion: nil)
        case "群链接":
            let pgVC = PigramPGVC.init()
            pgVC.type = .group
            pgVC.groupModel = self.thread?.groupModel
            pgVC.setupSuccess = {[weak self] link in
//                self?.thread?.groupModel.link = link
//                guard let groupModel = self?.thread?.groupModel else {
//                    return
//                }
//
//                let model = TSGroupModel.init(title: groupModel.groupName, members: groupModel.allMembers, groupId: groupModel.groupId, owner: groupModel.groupOwner)
//                model.txSetup(oldModel: groupModel)
//                model.link = link
//                SSKEnvironment.shared.databaseStorage.write { (write) in
//                    let thread = TSGroupThread.getOrCreateThread(withGroupId: groupModel.groupId, transaction: write)
//                    thread.anyUpdateGroupThread(transaction: write) { (thread) in
//                        thread.groupModel = model
//                    }
//                }

            }
            self.navigationController?.pushViewController(pgVC, animated: true)
            return
        case "清空聊天记录":
            let name = self.groupModel?.groupName ?? "该"
            let message = "确定删除\(name)群组的聊天记录吗？"
                TXTheme.alertActionWithMessage(title: nil, message: message, fromController: self) {[weak self] in
                    kSignalDB.write { (write) in
                        self?.thread?.removeAllThreadInteractions(with: write)
                    }
                    OWSAlerts.showAlert(title: "删除成功")
                }
        case "群管理":
            guard let thread = self.thread else {
                return
            }
            let groupManagerVC = PigramTXGroupSetVC.init()
            groupManagerVC.groupModel = self.groupModel
            groupManagerVC.thread = thread
            groupManagerVC.memberType = self.memberType
            let nav = BaseNavigationVC.init(rootViewController: groupManagerVC)
            self.navigationController?.present(nav, animated: true, completion: nil)
            break
        case "我的群昵称":
            guard let model = self.groupModel else {
                return
            }
            let editVC =  TXEditController.init()
            editVC.type = .groupNickName
            editVC.complete = { (name,editVC) in
                if name.count == 0 {
                    return
                }
                var params = ["groupId":model.groupId,"remarkName":name]
                guard let userId = TSAccountManager.localUserId else {
                    return
                }
                params["userId"] = userId
                ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
                    PigramNetworkMananger.pgSetupGroupMemberRemarkNameNetwork(params: params, success: { (_) in
                        if  let member = model.member(withUserId: userId){
                               member.remarkName = name
                        }
                        SSKEnvironment.shared.databaseStorage.write { (transaction) in
                            let thread = TSGroupThread.getOrCreateThread(withGroupId: model.groupId, transaction: transaction)
                            thread.anyUpdateGroupThread(transaction: transaction) { (thread) in
                                thread.groupModel.allMembers = model.allMembers
                            }
                            let infoMessage = TSInfoMessage.init(timestamp: NSDate.ows_millisecondTimeStamp(), in: thread, messageType: .typeGroupUpdate, customMessage: "您的昵称修改为:\(name)")
                            infoMessage.anyInsert(transaction: transaction)
                        }
                        DispatchQueue.main.async {
                            modal.dismiss {
                                OWSAlerts.showAlert(title: "修改成功")
                            
                            }
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            modal.dismiss {
                                OWSAlerts.showErrorAlert(message: error.localizedDescription)
                            }
                        }
                    }

                }

            }
            self.navigationController?.pushViewController(editVC, animated: true)

            break
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = TXTheme.thirdColor()
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (self.sectionItems.count - 1)  {
            return 80
        }
        return 0.1
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        if section == (self.sectionItems.count - 1)  {
            view.backgroundColor = TXTheme.thirdColor()
            let button = UIButton.init(frame: CGRect.init(x: 0, y: 10, width: self.view.width(), height: 50))
            button.addTarget(self, action: #selector(dissolutionGroup), for: .touchUpInside)
            button.backgroundColor = UIColor.white
            if self.memberType == .owner {
                button.setTitle("解散群聊", for: .normal)

            }else{
                button.setTitle("退出群聊", for: .normal)
            }
            button.setTitleColor(UIColor.red, for: .normal)
            view.addSubview(button)
            
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    @objc
    func dissolutionGroup() {

        
        let message : String
        if self.memberType == .owner {
            message = "解散群后群内所有信息将会被删除"
        }else{
            message = "离开本群后相关信息将会删除"
        }
        TXTheme.alertActionWithMessage(title: nil, message: message, fromController: self) {[weak self] in
            if let type = self?.memberType,type == .owner {//解散
                if let thread = self?.thread {
                    self?.txDissolutionGroup(thread:thread)
                }

              }else
              {
                 if let thread = self?.thread {
                      self?.txLeaveGroupAction(thread:thread)
                  }
              }
        }
    }
    

    
    //设置发送公告
    func setupNotices(notices:[String],vc:TXGroupAnnouncementVC) {

        guard let model = self.thread?.groupModel else {
            return
        }
        var params : Dictionary<String,String> = ["groupId":model.groupId]
        if let notice = notices.first {
            params["content"] = notice
            if model.notices.count != 0 ,let first = model.notices.first {
                params["noticeId"] = first.id
            }
        }
        ModalActivityIndicatorViewController.present(fromViewController: vc, canCancel: true) { (modal) in
            PigramNetworkMananger.pgCreateGroupAnnouncementNetwork(params: params, success: { (respose) in
                if let notice = respose as? Dictionary<String,Any>{
                    guard let id = notice["id"] as? UInt32 else {
                        DispatchQueue.main.async {
                            modal.dismiss {
                                OWSAlerts.showErrorAlert(message: "没有公告id")
                            }
                        }
                        return
                    }
                    let  idString = String(id)
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
                    model.notices =  [noticeItem]
                }
                SSKEnvironment.shared.databaseStorage.write { (transaction) in
                    let thread = TSGroupThread.getOrCreateThread(withGroupId: model.groupId, transaction: transaction)
                    thread.anyUpdateGroupThread(transaction: transaction) { (thread) in
                        thread.groupModel =  model
                    }

                }
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showAlert(title: "发布成功")
                        NotificationCenter.default.post(name: .init(rawValue: Pigram_Group_Status_Change_Notification), object: self.thread?.groupModel.groupId, userInfo: nil)
                    }

                }
                
            }) { (error) in
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        }


    }

}


extension TXGroupInfoVC{
//    func homeViewDatabaseSnapshotWillUpdate() {
//
//    }
    
//    func homeViewDatabaseSnapshotDidUpdate(updatedThreadIds: Set<String>) {
//        self.setupData()
//        self.updateHeadView()
//        self.tableView.reloadData()
//    }
//
//    func homeViewDatabaseSnapshotDidUpdateExternally() {
//
//    }
//
//    func homeViewDatabaseSnapshotDidReset() {
//
//    }
    
    
    
    
    
//    @objc
//    func uiDatabaseDidUpdateExternally(noti:NSNotification) {
//
//    }
//    @objc
//    func uiDatabaseWillUpdate(noti:NSNotification) {
//
//    }
    @objc
    func uiDatabaseDidUpdate(noti:Notification) {
        DispatchQueue.main.async {
            if let groupId = noti.object as? String,groupId == self.thread?.groupModel.groupId {
                if self.groupModel?.txGroupType == TXGroupTypeExit {
                    self.navigationController?.popToRootViewController(animated: true)
                    return;
                }
                self.setupData()
                self.updateHeadView()
                self.tableView.reloadData()
            }
        }


    }
    func addObserverAction() {
        NotificationCenter.default.addObserver(self, selector: #selector(uiDatabaseDidUpdate(noti:)), name: .init(rawValue: Pigram_Group_Status_Change_Notification), object: nil)

    }
}
extension TXGroupInfoVC{
    //增加群成员

       
    //增加群成员
    func setupAddMembers(addMembers : [OWSUserProfile],addNames : [String]) {
        guard let model = self.groupModel else {
            return
        }
//        var newMembers = model.allMembers
        var groupMembers : [Any] = []
        for member in addMembers {
            guard let userid = member.address.userid else {
                continue
            }
//            let pigMember = PigramGroupMember.init(userId: userid)
//            pigMember.nickname = member.profileName
//            pigMember.userAvatar = member.avatarUrlPath
//            newMembers.append(pigMember)
            groupMembers.append(userid)
        }

        let params = ["groupId":model.groupId,"groupMembers":groupMembers] as [String : Any]

        PigramNetworkMananger.pgManagerAddFriendJoinGroupNetwork(params: params, success: { (_) in
//            model.allMembers = newMembers;
//            PigramGroupManager.shared.saveGroupModel(groupModel: model)
            DispatchQueue.main.async {
                OWSAlerts.showAlert(title: "邀请成功")
                NotificationCenter.default.post(name: .init(rawValue: Pigram_Group_Status_Change_Notification), object: self.thread?.groupModel.groupId, userInfo: nil)
                
            }

        }) { (error) in
            DispatchQueue.main.async {
                OWSAlerts.showErrorAlert(message: error.localizedDescription)
            }
        }

    }
}
