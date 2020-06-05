//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

import UIKit

let Pigram_Group_Status_Change_Notification = "Pigram_Group_Status_Change_Notification"


class PigramGroupMemberModel {
    var isSelected: Bool = false;
    let member: PigramGroupMember
    
    required init(_ member: PigramGroupMember) {
        self.member = member;
    }
}
protocol TXSetGroupMembersVCDelegate {
    
    
}


class TXSetGroupMembersVC: BaseVC {
    enum SetType {
        case normal //查看群列表
        case addManager //添加管理员
        case remove //删除群成员
        case changeOwner //转让群主
        case bannedList //禁言列表
        case addBanned //增加禁言成员
        case removeBanned //减少禁言成员
        case managerList //管理员列表
        case removeManager //移除管理员列表

    }
    enum UserType {
        case ower
        case mananger
        case member
    }

    let searchBar : UISearchBar = {
        let searchBar = OWSSearchBar.init()
        return searchBar
    }()

    
    
    var memberType = UserType.member
    var type: SetType = .normal
    var isCanDelete: Bool = false;
    var isCanSelect: Bool = false;
    var rightNavTitle = "完成"
    var navTitle: String?
    var thread : TSGroupThread?
    var compeleted: ((TXSetGroupMembersVC,[PigramGroupMember]) -> Void)?
//    var managers:[PigramGroupMemberModel] = []
    var members:[PigramGroupMemberModel] = []
    var searchResult : [PigramGroupMemberModel] = []
    var groupModel : TSGroupModel?
    public static func showVC(_ fromVC: UIViewController?,thread:TSGroupThread, navTitle: String, rightNavTitle:String,type:SetType, compeleted:@escaping (TXSetGroupMembersVC,[PigramGroupMember]) -> Void) {
        let vc = TXSetGroupMembersVC.init();
        vc.navTitle = navTitle;
        vc.rightNavTitle = rightNavTitle;
        vc.compeleted = compeleted;
        vc.type = type
        vc.thread = thread
        fromVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func finishAction(){
        let profiles = [PigramGroupMember](self.selecteds.values)
        if self.type == .changeOwner {
            if let profile = profiles.first {
                let profileName = profile.getRemarkNameInfo()
                let message = "您确定要把群主转让给\(profileName)"
                TXTheme.alertActionWithMessage(title: "转让群主", message: message, fromController: self) {[weak self] in
                    if let weakSelf = self{
                        weakSelf.compeleted?(weakSelf,profiles)
                    }
                }
            }
            
            return
        }
        self.compeleted?(self,profiles)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBtnClick()
        self.getModel()
        self.tableView.backgroundColor = UIColor.white
        self.navigationItem.title = self.navTitle;
        self.view.addSubview(self.tableView);
        self.tableView.dataSource  = self;
        self.tableView.delegate = self;
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        self.addObserverAction()
        
    }
    
    
    
    
    
    func getModel() {
        guard let groupId = self.thread?.groupModel.groupId else {
            return
        }
         ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) {[weak self] (modal) in
            if let model = PigramGroupManager.shared.getGroupModel(groupId: groupId){
                DispatchQueue.main.async {
                    self?.groupModel = model;
                    self?.setupUserType()
                    self?.setupNav()
                    self?.setupDataAction()
                    modal.dismiss {
                        
                    }
                }
                return
            }
            let params = ["groupId":groupId]
            
            PigramNetworkMananger.pgGetGroupInfoNetwork(params: params, success: {(response) in
                if let _value = response as? [String : Any] {
                    guard let model = TSGroupModel.pg_initGroupModelDetial(_value) else{
                        DispatchQueue.main.async {
                            modal.dismiss {
                                OWSAlerts.showErrorAlert(message: "服务端返回群信息错误")
                            }
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self?.groupModel = model
                        PigramGroupManager.shared.saveGroupModel(groupModel: model)
                        self?.setupUserType()
                        self?.setupNav()
                        self?.setupDataAction()
                        modal.dismiss {
                        }
                    }
                }
            }) { (error) in
                modal.dismiss {
                    OWSAlerts.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func setupUserType() {
        guard let groupModel = self.groupModel else {
            return
        }
        if groupModel.groupOwner == TSAccountManager.localUserId {
            self.memberType = .ower
        }else if (groupModel.allMembers.contains(where: { (member) -> Bool in
            if member.perm == 1,member.userId == TSAccountManager.localUserId{
                return true
            }
            return false
        })){
            self.memberType = .mananger
        }else{
            self.memberType = .member
        }
        
    }
    func setupNav() {
        let confirm = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-more")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showMore))
        confirm.tintColor = kPigramThemeColor;
//        let search = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(searchBtnClick));
        switch self.type {
        case .normal:
//            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(leftBtnClick));
            switch self.memberType {
            case .mananger:
                self.navigationItem.rightBarButtonItems = [confirm];
            case .ower:
                self.navigationItem.rightBarButtonItems = [confirm];
            case .member:
//                self.navigationItem.rightBarButtonItem = search;
                break
            }
        case .changeOwner:
            fallthrough
        case .addManager:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "完成", style: .done, target: self, action: #selector(finishAction))
        case .remove:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "删除", style: .done, target: self, action: #selector(finishAction))
        case .addBanned:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "完成", style: .done, target: self, action: #selector(finishAction))
            break
        case .bannedList:
            self.navigationItem.rightBarButtonItems = [confirm];
            break
        case .removeBanned:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "完成", style: .done, target: self, action: #selector(finishAction))

            break
        case .managerList:
            if self.memberType == .ower {
                self.navigationItem.rightBarButtonItems = [confirm];
            }
            break
        case .removeManager:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "完成", style: .done, target: self, action: #selector(finishAction))

            break
        }
    }
    func setupNormalData() {
        guard let groupModel = self.groupModel  else {
            return
        }
        self.members.removeAll();
        let memebers  = groupModel.allMembers.map({ (member) -> PigramGroupMemberModel in
           return PigramGroupMemberModel.init(member)
        })
        self.members = memebers.sorted(by: { (model1, model2) -> Bool in
            return model1.member.perm < model2.member.perm
        })
        self.tableView.reloadData()
    }
    
//    func setupManagerGroupData() {
//        guard let groupModel = self.groupModel  else {
//            return
//        }
//        var managerItems : [PigramGroupMemberModel] = []
//        self.members.removeAll();
//        for member in groupModel.allMembers {
//
//            if member.perm == 0 {
//                let model = PigramGroupMemberModel.init(member)
//                managerItems.append(model)
//            }else{
//
//                self.updateSetManangerMember(member: member)
//            }
//        }
//        self.managers = managerItems
//        self.tableView.reloadData()
//
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.setupDataAction()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.searchController.searchBar.resignFirstResponder()
//        self.searchController.dismiss(animated: true, completion: nil)
    }
    
    
    func setupDataAction() {
        switch self.type {
        case .normal:
            self.setupNormalData()
        case .addManager:
            self.setupAddManagerList()
        case .remove:
            self.setupRemoveMembers()
            break
        case .changeOwner:
            self.setupChangeOwner()
            break
        case .bannedList:
            self.setupBannedList()
            break
        case .addBanned:
            self.setupAddBannedList()
            break
        case .removeBanned:
            self.setupBannedList()
            break
        case .managerList:
            self.setupManagerList()
            break
        case .removeManager:
            self.setupManagerList()
            break

            
        }
        if self.members.count == 0,self.searchResult.count == 0 {
            self.tableView.manualUpdateNoDataView(true)

        }else{
            self.tableView.manualUpdateNoDataView(false)
        }
    }
    
    
    //MARK:-  管理员列表
    private func setupManagerList(){
        guard let groupModel = self.groupModel  else {
            return
        }

        self.members.removeAll();
        for member in groupModel.allMembers {
            if member.perm == 1 {
                self.members.append(PigramGroupMemberModel.init(member))
            }
        }
        self.tableView.reloadData()

    }
    //MARK:-  增加群管理数据
    private func setupAddManagerList(){
        guard let groupModel = self.groupModel  else {
            return
        }

        self.members.removeAll();
        for member in groupModel.allMembers {
            if member.perm == 2{
                self.updateSetBannedMember(member: member)
            }
        }
        self.tableView.reloadData()

    }
    
    //MARK:-  禁言列表
    private func setupBannedList(){
        guard let groupModel = self.groupModel  else {
            return
        }

        self.members.removeAll();
        for member in groupModel.allMembers {
            if member.perm != 0,member.memberStatus == 2 {
                self.members.append(PigramGroupMemberModel.init(member))
            }
        }
        
        self.members =  self.members.sorted { (model1, model2) -> Bool in
            return model1.member.perm < model2.member.perm;
        }
        self.tableView.reloadData()

    }
    
    //MARK:-  增加禁言列表
    private func setupAddBannedList(){
        guard let groupModel = self.groupModel  else {
            return
        }
        self.members.removeAll();
        for member in groupModel.allMembers {
            
            
            switch self.memberType {
            case .ower:
                if member.memberStatus != 2,member.perm != 0 {
                    self.members.append(PigramGroupMemberModel.init(member))
                }
            case .mananger:
                if member.memberStatus != 2,member.perm == 2 {
                    self.members.append(PigramGroupMemberModel.init(member))
                }
            default:
                break;
            }

        }
        self.members = self.members.sorted(by: { (model1, model2) -> Bool in
            return model1.member.perm < model2.member.perm
        })
        self.tableView.reloadData()
    }

    
    
    
    
    @objc
    func leftBtnClick() {
        self.navigationController?.popViewController(animated: true)
    }

    
    private func setupRemoveMembers(){
        self.setupNormalData()
    }
    private func setupChangeOwner(){
        self.setupNormalData()
    }

    
    //MARK:-  设置管理员初始化数据模型 member
    private func updateSetManangerMember(member:PigramGroupMember){
        

        let model = PigramGroupMemberModel.init(member);
        if member.perm == 1  {
            model.isSelected = true
            self.selecteds[member.userId] = member
        }
        self.members.append(model)
    }
    //MARK:-  设置禁言模型 member
    private func updateSetBannedMember(member:PigramGroupMember){

        let model = PigramGroupMemberModel.init(member);
        self.members.append(model)

    }


    private var tableView: DYTableView = {
           
           let view = DYTableView.init();
            view.banRefresh();
           view.register(ContactListCell.self, forCellReuseIdentifier: "cell");

           view.rowHeight = 68;
           view.tableFooterView = UIView.init();
           view.separatorColor = UIColor.clear;
           view.isShowNoData = true;
           
           return view;
           
       }();
    
//    private var friends: [Int: [PigramGroupMemberModel]] = [:];

    private var selecteds: [String : PigramGroupMember] = [:];

}

extension TXSetGroupMembersVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if self.isSearching() {
            return self.searchResult.count
        }
        return self.members.count
//        return (self.searchResult.count != 0) ? self.searchResult.count : self.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactListCell;
        let member: PigramGroupMemberModel?
        if self.isSearching() {
            member = self.searchResult[indexPath.row]
        }else{
            member = self.members[indexPath.row]
        }
        
        if member == nil{
            return cell;
        }
        
        switch member!.member.perm {
        case 0:
            cell.model = member;
            cell.nickLabel.text = member!.member.getRemarkNameInfo() + "-群主"
            
        case 1:
            cell.model = member;
            cell.nickLabel.text = member!.member.getRemarkNameInfo() + "-管理员"
        case 2:
            cell.model = member;
        default:
            break;
            
        }

        self.setupCell(cell: cell,indexPath,member!)
        return cell;
        
    }
  

    
    private func setupCell(cell:ContactListCell,_ indexPath:IndexPath,_ model : PigramGroupMemberModel){
        switch self.type {
        case .normal:
            cell.isShowSelectBtn = false
        case .changeOwner:
            fallthrough
        case .remove:
            switch self.memberType {
            case .ower:
                if model.member.perm != 0 {
                    cell.isShowSelectBtn = true

                }else{
                    cell.isShowSelectBtn = false
                }
            case .mananger:
                if model.member.perm != 0,model.member.perm != 1 {
                    cell.isShowSelectBtn = true
                }else{
                    cell.isShowSelectBtn = false
                }

            default:
                cell.isShowSelectBtn = false
                break
            }
            break
        case .bannedList:
            cell.isShowSelectBtn = false
            break
        case .addBanned:
            switch self.memberType {
            case .ower:
                cell.isShowSelectBtn = true
            case .mananger:
                if model.member.perm != 0,model.member.perm != 1 {
                    cell.isShowSelectBtn = true
                }else{
                    cell.isShowSelectBtn = false
                }
            default:
                cell.isShowSelectBtn = false
                break
            }
            
            break
        case .removeBanned:
            switch self.memberType {
            case .ower:
                cell.isShowSelectBtn = true
            case .mananger:
                if model.member.perm != 0,model.member.perm != 1 {
                    cell.isShowSelectBtn = true
                }else{
                    cell.isShowSelectBtn = false
                }
            default:
                cell.isShowSelectBtn = false
                break
            }

            break
        case .managerList:
            cell.isShowSelectBtn = false

            break
        case .removeManager:
            cell.isShowSelectBtn = true
            break
        case .addManager:
            cell.isShowSelectBtn = true
            break

        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true);
        
        if self.type == .normal {
            let model: PigramGroupMemberModel?
            if self.isSearching() {
                model = self.searchResult[indexPath.row]
            }else{
                model = self.members[indexPath.row]
            }
            guard let userId = model?.member.userId else {
                return
            }
            let vc = FriendSearchVC.init()
            vc.channel = .group
            vc.phoneNumber = userId
            if self.memberType == .member {
                var user: OWSUserProfile?
                kSignalDB.read { (read) in
                    user = OWSUserProfile.getFor(SignalServiceAddress.init(phoneNumber: userId), transaction: read)
                }
                if user?.relationType != .friend{
                    vc.hideConfirmBtn = true
                }
            }
            if userId == TSAccountManager.localUserId {
                vc.hideConfirmBtn = true
            }
//            self.searchController.dismiss(animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
            self.navigationController?.pushViewController(vc, animated: true)
            return
            
        }
        if self.type == .normal || self.type == .bannedList || self.type == .managerList {

            return
        }

        let model: PigramGroupMemberModel?
        if self.isSearching() {
            model = self.searchResult[indexPath.row]
        }else{
            model = self.members[indexPath.row]
        }
        
        if model == nil {
            return
        }
        
        switch self.memberType {
        case .ower:
            if model!.member.perm == 0 {
                return
            }
        case .mananger:
            if model!.member.perm == 0 || model!.member.perm == 1 {
                return
            }
        default:
            return
        }
        if self.type == .changeOwner {//转让群
            if self.selecteds.count != 0,let first = self.selecteds.first {
                let key = first.key
                if model!.member.userId == key {
                    return
                }
                for (_,model) in self.members.enumerated() {
                    if model.isSelected {
                        model.isSelected = false
                        break
                    }
                }

            }
            self.selecteds.removeAll()

        }
            
        model!.isSelected = !model!.isSelected;
        if model!.isSelected {
            self.selecteds[model!.member.userId] = model!.member;
        } else {
            self.selecteds.removeValue(forKey: model!.member.userId);
        }
        let cell = tableView.cellForRow(at: indexPath) as! ContactListCell
        if self.type == .changeOwner {
            self.tableView.reloadData()
        }else{
            cell.makesButtonSelect(model!.isSelected)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
//
//        if self.members.count ?? 0 > 0 {
//            return 30
//        }
        
        return 0;
    }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var text = "#";
        let label = UILabel.init();
        label.backgroundColor = UIColor.hex("#f0f3f9");
        label.textColor = UIColor.hex("#758493");
        label.font = UIFont.boldSystemFont(ofSize: 14);
//        if section == 0 {
//
//            if self.type == .normal {
//                text = "群主和管理员（\(self.managers.count)）"
//
//            }else
//            {
//                text = "管理员（\(self.managers.count)）"
//            }
//        }else
//        {
//            text = "成员"
//
//        }
        label.text = "    " + text;
        return label;
    }
    


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }

    
    
    
    
}

//MARK:-  更多方法处理
extension TXSetGroupMembersVC{
    @objc
    private func showMore(){
        if self.type == .normal {
            self.addOrRemoveGroupMemember()
        }else if self.type == .bannedList{
            self.addOrRemoveBannedMember()
        }else if self.type == .managerList{
            self.addOrRemoveManager()
        }
    }
    
    
    //MARK:-  增加或删除群成员
    private func addOrRemoveGroupMemember(){

       let array = ["邀请新成员", "删除群成员"];
         let imgs = ["pigram-nav-add-friend","pigram-contact-blocking"];
         var actions:[YCMenuAction] = [];
         for (index,item) in array.enumerated() {
             let action = YCMenuAction.init(title: item, image: UIImage.init(named: imgs[index]));
             actions.append(action!);
         }
         let menuView = YCMenuView.menu(with: actions, width: 150, relyonView: self.navigationItem.rightBarButtonItems?.first);
         menuView?.textFont = UIFont.systemFont(ofSize: 14);
         menuView?.textColor = UIColor.hex("#2d4257");
         menuView?.show();
         menuView?.didSelectedCellCallback = {
             (view,indexpath) in
             switch indexpath?.row {
             case 0:
                guard let groupModel = self.groupModel else {
                    return
                }
                var array:[String] = groupModel.allMembers.map { (member) -> String in
                    return member.userId;
                };
                array.append("___officer____!")
                let seleteVC = ContactListVC.init()
                seleteVC.filters = array
                seleteVC.navTitle = "邀请群成员"
                seleteVC.showVC(fromVC: self) {[weak self] (listVC, profiles) in
                    
                    if profiles.count == 0 {
                        listVC.dismiss(animated: true, completion: nil);
                        return;
                    }
                    
                    if let _ =  listVC.navigationController?.presentingViewController{
                        listVC.navigationController?.dismiss(animated: true, completion: {
                            var addNames : [String] = []
                            for profile in profiles{
                                addNames.append(profile.getContactName())

                            }
                            self?.setupAddMembers(addMembers: profiles,addNames: addNames)
                        })
                    }else
                    {
                        listVC.navigationController?.popViewController(animated: true, completion: {
                            var addNames : [String] = []
                            for profile in profiles{
                                addNames.append(profile.getContactName())
                            }
                            self?.setupAddMembers(addMembers: profiles,addNames: addNames)
                        })
                    }

                    
                }
               
                 break;
             case 1:
                guard let thread = self.thread else {
                    return
                }
                TXSetGroupMembersVC.showVC(self, thread: thread, navTitle: "删除群成员", rightNavTitle: "", type: .remove) {[weak self] (deleteVC, members) in
                    deleteVC.navigationController?.popViewController(animated: true, completion: {
                        var names : [String] = []
                        for member in members{
                            let name = member.getRemarkNameInfo()
                            names.append(name)
                        }
                        self?.setupDeleteMemebers(names: names,delelteList: members)

                    })
                }
                 break
             default:
                 break;
             }
         }
    }
    
    //MARK:-  增加或解除禁言成员
    
    private func addOrRemoveBannedMember(){

           let array = ["增加禁言", "解除禁言"];
             let imgs = ["pigram-nav-add-friend","pigram-contact-blocking"];
             var actions:[YCMenuAction] = [];
             for (index,item) in array.enumerated() {
                 let action = YCMenuAction.init(title: item, image: UIImage.init(named: imgs[index]));
                 actions.append(action!);
             }
             let menuView = YCMenuView.menu(with: actions, width: 150, relyonView: self.navigationItem.rightBarButtonItems?.first);
             menuView?.textFont = UIFont.systemFont(ofSize: 14);
             menuView?.textColor = UIColor.hex("#2d4257");
             menuView?.show();
             menuView?.didSelectedCellCallback = {
                 (view,indexpath) in
                 switch indexpath?.row {
                 case 0:
                    guard let thread = self.thread else {
                        return
                    }
                    guard let model = self.groupModel else {
                        return
                    }
                    TXSetGroupMembersVC.showVC(self, thread: thread, navTitle: "增加禁言", rightNavTitle: "", type: .addBanned) {[weak self] (deleteVC, members) in
                                                
                        let groupMemebers = members.map { (member) -> String in
                            member.userId
                        }
                        let params = ["groupMembers":groupMemebers,"groupId":model.groupId] as [String : Any]
                        guard let weakSelf = self else{
                            return
                        }
                        ModalActivityIndicatorViewController.present(fromViewController: weakSelf, canCancel: true) {(modal) in
                            PigramNetworkMananger.pgAddBlackGroupMembersNetwork(params: params, success: { (_) in
                                DispatchQueue.main.async {
                                    modal.dismiss {
//                                        for userId in groupMemebers{
//                                            if let groupMember  = model.member(withUserId: userId)  {
//                                                groupMember.memberStatus = 2;
//                                            }
//                                        }
//                                        PigramGroupManager.shared.saveGroupModel(groupModel: model)
                                        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: Pigram_Group_Status_Change_Notification), object:model.groupId, userInfo: nil)
                                        deleteVC.navigationController?.popViewController(animated: true, completion: {
                                            OWSAlerts.showAlert(title: "添加成功")
                                        })
                                    }
                                }


                            }) { (error) in
                                DispatchQueue.main.async {
                                    modal.dismiss {
                                        OWSAlerts.showAlert(title: "添加失败")
                                    }
                                }
                            }
                        }

                    }
                   
                     break;
                 case 1:
                    guard let thread = self.thread else {
                        return
                    }
                    guard let model = self.groupModel else {
                        return
                    }
                    TXSetGroupMembersVC.showVC(self, thread: thread, navTitle: "解除禁言", rightNavTitle: "", type: .removeBanned) {[weak self] (deleteVC, members) in
                        
                        
                                                
                        let groupMemebers = members.map { (member) -> String in
                            member.userId
                        }
                        let params = ["groupMembers":groupMemebers,"groupId":thread.groupModel.groupId] as [String : Any]
                        guard let weakSelf = self else{
                            return
                        }
                        
                        ModalActivityIndicatorViewController.present(fromViewController: weakSelf, canCancel: true) { (modal) in
                            PigramNetworkMananger.pgRemoveBlackGroupMembersNetwork(params: params, success: { (_) in
                                DispatchQueue.main.async {
                                    modal.dismiss {
                                        for member in members{
                                            member.memberStatus = 1
                                        }
                                        PigramGroupManager.shared.saveGroupModel(groupModel: model)
                                        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: Pigram_Group_Status_Change_Notification), object:model.groupId, userInfo: nil)
                                        deleteVC.navigationController?.popViewController(animated: true, completion: {
                                            OWSAlerts.showAlert(title: "解除成功")
                                        })
                                    }
                                }


                            }) { (error) in
                                DispatchQueue.main.async {
                                    modal.dismiss {
                                        OWSAlerts.showAlert(title: "操作失败")
                                    }
                                }
                            }
                        }
                    }
                     break
                 default:
                     break;
                 }
             }
      }
    
    
    //MARK:-  增加或删除管理员
    private func addOrRemoveManager(){

           let array = ["增加管理员", "删除管理员"];
             let imgs = ["pigram-nav-add-friend","pigram-contact-blocking"];
             var actions:[YCMenuAction] = [];
             for (index,item) in array.enumerated() {
                 let action = YCMenuAction.init(title: item, image: UIImage.init(named: imgs[index]));
                 actions.append(action!);
             }
             let menuView = YCMenuView.menu(with: actions, width: 150, relyonView: self.navigationItem.rightBarButtonItems?.first);
             menuView?.textFont = UIFont.systemFont(ofSize: 14);
             menuView?.textColor = UIColor.hex("#2d4257");
             menuView?.show();
             menuView?.didSelectedCellCallback = {
                 (view,indexpath) in
                 switch indexpath?.row {
                 case 0:
                    guard let thread = self.thread else {
                        return
                    }
                    TXSetGroupMembersVC.showVC(self, thread: thread, navTitle: "增加管理员", rightNavTitle: "", type: .addManager) {[weak self] (deleteVC, members) in
                        self?.addOrRemoveManager(members, deleteVC,true)
                    }
                   
                     break;
                 case 1:
                    guard let thread = self.thread else {
                        return
                    }
                    TXSetGroupMembersVC.showVC(self, thread: thread, navTitle: "删除管理员", rightNavTitle: "", type: .removeManager) {[weak self] (deleteVC, members) in
                        self?.addOrRemoveManager(members, deleteVC,false)
                    }
                     break
                 default:
                     break;
                 }
             }
      }

    
    
}

//MARK:-  处理删除和增加群成员
extension TXSetGroupMembersVC{
    private func addOrRemoveManager(_ members:[PigramGroupMember],_ listVC:UIViewController,_ add:Bool){
        if members.count == 0{
            OWSAlerts.showAlert(title: "请选择成员")
            return
        }
        guard let thread = self.thread else {
            return
        }
        guard let model = self.groupModel else {
            return
        }

        let groupMembers  = NSMutableSet.init()
        for member in members {
            guard let userId = member.userId else {
                continue
            }
            let user = ["userId":userId,"perm":(add ? 1 : 2)] as [String : Any]
            groupMembers.add(user)
        }
        let params = ["groupId":thread.groupModel.groupId,"groupMembers":groupMembers.allObjects] as [String : Any]
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
            PigramNetworkMananger.pgSetupManagersNetwork(params: params, success: { (_) in
                
                for member in members {
                    member.perm = (add ? 1 : 2)
                }
                PigramGroupManager.shared.saveGroupModel(groupModel: model)
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: Pigram_Group_Status_Change_Notification), object:model.groupId, userInfo: nil)
                SSKEnvironment.shared.databaseStorage.write { (transaction) in
                    let updateThread = TSGroupThread.getOrCreateThread(withGroupId: thread.groupModel.groupId, transaction: transaction)
                    let infoMessage = TSInfoMessage.init(timestamp: NSDate.ows_millisecondTimeStamp(), in: updateThread, messageType: .typeGroupUpdate, customMessage: "管理员设置成功")
                    infoMessage.anyInsert(transaction: transaction)
                }
                DispatchQueue.main.async {
                    modal.dismiss {
                        listVC.navigationController?.popViewController(animated: true)
                        OWSAlerts.showAlert(title: "设置成功")

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


extension TXSetGroupMembersVC{
    //删除群成员

    func setupDeleteMemebers(names:[String],delelteList:[PigramGroupMember]) {
        guard let model = self.groupModel else {
            return
        }
        if delelteList.count == 0 {
            return
        }
        var groupDeleteMembers : Array <Any> = []
        for member in delelteList {
            guard let userid = member.userId else {
                continue
            }
            groupDeleteMembers.append(userid)
            
        }
        
        let params = ["groupId":model.groupId,"groupMembers":groupDeleteMembers] as [String : Any]
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
            PigramNetworkMananger.pgDeleteGroupMemberNetwork(params: params, success: { (_) in

                model.allMembers.removeAll { (member) -> Bool in
                    if delelteList.contains(where: { (deleteMember) -> Bool in
                        return deleteMember.userId == member.userId;
                    }){
                        return true
                    }
                    return false
                }
                DispatchQueue.main.async {
                    PigramGroupManager.shared.saveGroupModel(groupModel: model)
                    modal.dismiss {
                        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: Pigram_Group_Status_Change_Notification), object: self.thread?.groupModel.groupId, userInfo: nil)
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

    
    
    //增加群成员

    func setupAddMembers(addMembers : [OWSUserProfile],addNames : [String]) {
        guard let model = self.groupModel else {
            return
        }
        var newMembers = model.allMembers
        var groupMembers : [Any] = []
        for member in addMembers {
            guard let userid = member.address.userid else {
                continue
            }
            let pigMember = PigramGroupMember.init(userId: userid)
            pigMember.nickname = member.profileName
            pigMember.userAvatar = member.avatarUrlPath
            newMembers.append(pigMember)
            groupMembers.append(userid)
        }
        
        let params = ["groupId":model.groupId,"groupMembers":groupMembers] as [String : Any]
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
            PigramNetworkMananger.pgManagerAddFriendJoinGroupNetwork(params: params, success: { (_) in
                model.allMembers = newMembers;
                PigramGroupManager.shared.saveGroupModel(groupModel: model)
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showAlert(title: "邀请成功")
                        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: Pigram_Group_Status_Change_Notification), object: self.thread?.groupModel.groupId, userInfo: nil)
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





extension TXSetGroupMembersVC{
//    func homeViewDatabaseSnapshotWillUpdate() {
//
//    }
//
//    func homeViewDatabaseSnapshotDidUpdate(updatedThreadIds: Set<String>) {
//        self.setupDataAction()
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
            if let groupId = noti.object as? String{
                if groupId == self.thread?.groupModel.groupId{
                    self.setupDataAction()
                }
            }
        }
    }
    @objc
    func addObserverAction() {
        NotificationCenter.default.addObserver(self, selector: #selector(uiDatabaseDidUpdate(noti:)), name: NSNotification.Name.init(rawValue: Pigram_Group_Status_Change_Notification), object: nil)
    }
    
}


extension TXSetGroupMembersVC:UISearchBarDelegate{

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.showsCancelButton = true
        return true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchResult.removeAll()
            self.tableView.reloadData()
        }

    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = nil
        self.searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        self.searchResult.removeAll()
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if var text = searchBar.text,!text.isEmpty{
            self.view.makeToastActivity(.center)
            text = text.trimmingCharacters(in: .whitespaces)
            self.searchResult = self.members.filter({ (model) -> Bool in
                return model.member.getRemarkNameInfo().contains(text)
            })
            self.tableView.reloadData()
            self.view.hideToastActivity()
        }

    }
    
    func isSearching() -> Bool {
        if let text = self.searchBar.text,!text.isEmpty {
            return true
        }
        return false
    }
    
    //MARK:-  搜索功能
    @objc
    func searchBtnClick() {
        OWSSearchBar.applyTheme(to: searchBar)
        searchBar.placeholder = kPigramLocalizeString("HOME_VIEW_CONVERSATION_SEARCHBAR_PLACEHOLDER", "Placeholder text for search bar which filters conversations.")
//        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.sizeToFit()

       self.tableView.tableHeaderView = searchBar
    }
    
    
}

