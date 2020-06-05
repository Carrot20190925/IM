//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

import UIKit

class TXChatInfoVC: BaseVC,TXGroupInfoHeadViewDelegate { 
//     TSContactThread
    public var thread : TSContactThread?
    var profile : OWSUserProfile?
    var members : [OWSUserProfile] = []
    var tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
    var headView = TXGroupInfoHeadView.init()
    var sectionItems = [["消息免打扰", "置顶会话"],["清空聊天记录"]]
    @objc
    var placeTopAction : ((_ on : Bool) -> Void)?
    @objc
    static func showGroupInfo(viewControllor:UIViewController,thread:TSContactThread) -> TXChatInfoVC{
        let info = TXChatInfoVC.init()
        info.thread = thread
        viewControllor.navigationController?.pushViewController(info, animated: true)
        return info
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "聊天信息"
//        self.setupNav()
        self.setupInit()
        self.setupData()
    }
    
//    func setupNav() {
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-leftBack"), style: .plain, target: self, action: #selector(goBack))
//    }
//    @objc
//    func goBack() {
//        self.navigationController?.dismiss(animated: true, completion: nil)
//    }
    func setupData() {
        if hasExistingContact() {
            
        }
        guard let contactAddress = self.thread?.contactAddress else {
            return
        }
        SSKEnvironment.shared.databaseStorage.read { (transaction) in
            let profile = OWSUserProfile.getFor(contactAddress, transaction: transaction)
            if let  profileExist = profile {
                self.members.append(profileExist)
                self.profile = profileExist
            }
        }
        self.setupHeadView()
    }
    
//    - (BOOL)hasExistingContact
//    {
//        OWSAssertDebug([self.thread isKindOfClass:[TSContactThread class]]);
//        TSContactThread *contactThread = (TSContactThread *)self.thread;
//        SignalServiceAddress *recipientAddress = contactThread.contactAddress;
//        return [self.contactsManager hasSignalAccountForAddress:recipientAddress];
//    }
//    return Environment.shared.contactsManager;

    func hasExistingContact() -> Bool {
        guard let contactAddress = self.thread?.contactAddress else {
            return false
        }
       return Environment.shared.contactsManager.hasSignalAccount(for: contactAddress)
    }
    func setupHeadView() {
        headView.frame = CGRect.init(x: 0, y: 0, width: self.view.width(), height: 0)
        headView.setupPersonInfo()
        self.tableView.tableHeaderView = headView
        headView.delegate = self
        headView.reloadData()
        //邀请好友 组建群组
        headView.inviteFriend = { [weak self] (index) in
            if index == 0 { //查看好友信息
                let vc = FriendSearchVC.init()
                vc.channel = .number
                vc.phoneNumber = self?.thread?.contactAddress.userid
                if vc.phoneNumber == TSAccountManager.localUserId {
                    vc.hideConfirmBtn = true
                }
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let listVC = ContactListVC.init()
            if let profile = self?.profile{
                listVC.filters = [profile.address.userid!];
                listVC.filters?.append("___officer____!")

            }else{
                listVC.filters?.append("___officer____!")
            }
            listVC.navTitle = "创建群聊"
            listVC.showVC(fromVC: self) {[weak self] (listVc, results) in
                var resultsEnsure = results
                if let profile = self?.profile{
                    resultsEnsure.append(profile)
                }
                if resultsEnsure.count == 0 || resultsEnsure.count < 2{
                    OWSAlerts.showAlert(title: "请至少选择两人创建群聊");
                    return;
                }
                if let weakSelf = self{
                    PigramGroupManager.createGroups(fromVC: weakSelf, resultsEnsure) { (result) in
                        if result{
                            listVc.dismiss(animated: true, completion: nil);

                        }
                    }
                }

            }
        }
    }
    func numberItems() -> Int {
        return self.members.count
    }
    func profileItem(index: Int) -> OWSUserProfile? {
         return self.members[index]
    }


//    func imageItem(index: Int) -> UIImage? {
//        let member = self.members[index]
//        return member.getContactAvatarImage()
//    }

//    func titleItem(index: Int) -> String? {
//        let member = self.members[index]
//        return member.getContactName()
//    }
    func inviteItemHide() -> Bool {
        return false
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

extension TXChatInfoVC:UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout{
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
        let items:[String] = self.sectionItems[indexPath.section]

        let text = items[indexPath.row]
        switch text {
        case "二维码":
            cell.showNextBtn()
            break
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
        case "清空聊天记录":
            let profile = self.members.first
            var nameSure : String?
            if let name = profile?.profileName {
                nameSure = name
            }else{
                nameSure = profile?.address.phoneNumber
            }
            guard let name = nameSure else {
                return
            }
            let message = "确定删除和\(name)的聊天记录吗？"
            TXTheme.alertActionWithMessage(title: nil, message: message, fromController: self) {[weak self] in
                kSignalDB.write { (write) in
                    self?.thread?.removeAllThreadInteractions(with: write)
                }
                OWSAlerts.showAlert(title: "删除成功")
            }
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
       
        return 0.1
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
     
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
   

}



extension TXChatInfoVC{
    private func createNewGroup(_ users:[OWSUserProfile], finished:@escaping (Bool) -> Void) {
        
//        var allUsers = Array.init(users);
//
//        kSignalDB.write { (write) in
//
//            let user = OWSUserProfile.getOrBuild(for: TSAccountManager.localAddress!, transaction: write);
//            allUsers.append(user);
//        }
//
//        var groupName = "";
//        for index in 0..<3 {
//            let item = allUsers[index];
//            groupName.append(item.profileName ?? "");
//
//        }
//        if groupName.length > 10 {
//            groupName = groupName.substring(to: 10) + "...";
//        }
//        if groupName.length == 0 {
//            groupName = "新建群组\(arc4random() % 100)";
//        }
//        let members = allUsers.map { (user) -> SignalServiceAddress in
//            return user.address;
//        }
//        //        let groupImage = TSGroupModel.generateGroupDefaultImage(allUsers);
//        let groupId = Randomness.generateRandomBytes(16);
//        let model = TSGroupModel.init(title: groupName, members: members, image: nil, groupId: groupId);
//        //指定自己为群主
//        model.groupOwner = TSAccountManager.localNumber!;
//        model.groupManagers = [model.groupOwner];
//        model.txGroupType = TXGroupTypeJoined;
//        let thread = TSGroupThread.getOrCreateThread(with: model);
//
//        OWSProfileManager.shared().addThread(toProfileWhitelist: thread);
//
//        let successful:(ModalActivityIndicatorViewController) -> Void = {
//            [weak self] (modal) in
//            DispatchQueue.main.async {
//                modal.dismiss {
//                    finished(true);
//                    let vc = ConversationViewController.init();
//                    vc.configure(for: thread, action: .none, focusMessageId: nil);
//                    self?.navigationController?.setSecondSubVC(vc);
//
//                }
//            }
//
//        };
//
//        let failured:(ModalActivityIndicatorViewController, Error) -> Void = {
//            (modal,error) in
//            DispatchQueue.main.async {
//                modal.dismiss {
//                    finished(false);
//                    OWSAlerts.showErrorAlert(message: error.localizedDescription);
//                }
//            }
//        };
//
//        ModalActivityIndicatorViewController.present(fromViewController: self.presentedViewController!, canCancel: false) { (modal) in
//
//            let outgoing = TSOutgoingMessage.init(in: thread, groupMetaMessage: .new, expiresInSeconds: 0);
//            outgoing.update(withCustomMessage: NSLocalizedString("GROUP_CREATED",comment: "创建群组"));
//
//            var source: DataSource?
//            if model.groupImage != nil {
//                let imageData = model.groupImage?.pngData()
//                source = DataSourceValue.dataSource(with: imageData!, fileExtension: "png");
//            }
//            if source != nil {
//                SSKEnvironment.shared.messageSender.sendTemporaryAttachment(source!, contentType: OWSMimeTypeImagePng, in: outgoing, success: {
//                    successful(modal);
//                }) { (error) in
//                    failured(modal,error);
//                };
//            } else {
//
//                SSKEnvironment.shared.messageSender.sendMessage(outgoing.asPreparer, success: {
//                    successful(modal);
//                }) { (error) in
//                    failured(modal,error);
//                };
//
//            }
//
//
//        };
        
    }
}
