//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class ContactsVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setuoSubview();
        
        self.updatetableViewContents();
        
        self.addTitleViewChangesBarHeight();
        
        // Do any additional setup after loading the view.
        self.addNotification();
        
        let verify = SignalServiceAddress.init(phoneNumber: "pigram_verification_contact_cell");
        let groupList = SignalServiceAddress.init(phoneNumber: "pigram_group_list_contact_cell");
        let groups = SignalServiceAddress.init(phoneNumber: "pigram_groups_contact_cell");

        kSignalDB.write { (write) in
            let verifyProfile = OWSUserProfile.getOrBuild(for: verify, transaction: write);
            let groupProfile = OWSUserProfile.getOrBuild(for: groupList, transaction: write);
            let groupsProfile = OWSUserProfile.getOrBuild(for: groups, transaction: write);

            if groupProfile.profileName == nil {
                
                groupProfile.update(withProfileName: "群聊", avatarUrlPath: nil, avatarFileName: nil, transaction: write, completion: nil);
                
            }
            if verifyProfile.profileName == nil{
                verifyProfile.update(withProfileName: "验证消息", avatarUrlPath: nil, avatarFileName: nil, transaction: write, completion: nil);

            }
            if groupsProfile.profileName == nil{
                groupsProfile.update(withProfileName: "群组", avatarUrlPath: nil, avatarFileName: nil, transaction: write, completion: nil);

            }
        
            self.verifies.append(verifyProfile);
            self.verifies.append(groupProfile);
            self.verifies.append(groupsProfile);
        }
    }
    
    private func addNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupVerifications), name: NSNotification.Name.kNotification_Pigram_Group_Apply, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupVerifications), name: NSNotification.Name.kNotification_Pigram_Group_Apply_handled, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFriendApply), name: NSNotification.Name.kNotification_Friend_Invite_apply, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFriendAccept), name: NSNotification.Name.kNotification_Friend_Invite_accept, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(removeGroupVerifyAction(_:)), name: NSNotification.Name.kNotification_Pigram_Group_Romove_Manager_handled, object: nil);
        
    }
    @objc
    func removeGroupVerifyAction(_ noti : Notification) {
        if let groupId = noti.object as? String{
            PigramVerifyManager.shared.clearGroupVerify(groupId: groupId)
        }
        self.updateGroupVerifications()
        self.updateBadgeValue()
    }
    ///收到好友申请或同意 只处理小红点数量的显示
    @objc func updateGroupVerifications() {
        self.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic);
    }
    @objc func updateFriendApply() {
        self.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic);
    }
    @objc func updateFriendAccept() {
        self.tableView.loadLocalData();
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.tableView.loadLocalData();
        self.updateBadgeValue();
    }
    
    private func updateBadgeValue() {
        let contactItem = self.tabBarController?.tabBar.items?[1];
        let unreadCount = PigramVerifyManager.shared.getAllVerifications()?.count ?? 0;
        contactItem?.badgeValue = unreadCount > 0 ? "\(unreadCount)" : nil;
    }
    
   
    private func addTitleViewChangesBarHeight() {
        //为了让navigationBar高度产生变化
        let titleView = UISearchBar.init();
        titleView.isHidden = true;
        self.navigationItem.titleView = titleView;
    }
    private func setuoSubview() {
        self.navigationItem.title = "好友";
        self.navigationItem.titleView = UIView.init();
        let label = UILabel.init();
        label.font = UIFont.boldSystemFont(ofSize: 27)
        label.textColor = UIColor.black;
        label.text = self.navigationItem.title;
        label.sizeToFit()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label, accessibilityIdentifier: "leftTitle");
        // Do any additional setup after loading the view.
        let more = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-more")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(moreBtnClick));
        self.tableView.backgroundColor = UIColor.white
        let search = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(searchBtnClick));
        self.navigationItem.rightBarButtonItems = [more,search];
        
        self.view.addSubview(self.tableView);
        self.tableView.dataSource  = self;
        self.tableView.delegate = self;
        
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
       
        
    }
    
    
    
    private func updatetableViewContents() {
        
        self.tableView.loadDataCallback = {
            [weak self] (_, result) in
            self?.loadData(result);
           
        };
        self.tableView.loadLocalDataCallback = {
            [weak self] (result) in
            self?.loadLocalData(result);
        };
        
        self.tableView.loadLocalData();
        
        
    }
    
    private func loadData(_ result: @escaping DYTableView_Result) {
        
        PigramNetwork.getMyFriendList(1) { (results, error) in
            
            if let _results = results {
                
                self.friends.removeAll();
                let array:[OWSUserProfile] = _results;
                for item in array {
                    if item.relationType != .friend {
                        continue;
                    }
                    let initialLetter = item.getContactName().transformToPinyinHead();
                    let asciiNumber = Character.init((initialLetter)).toInt();
                    var key = 27;
                    if asciiNumber >= 65 && asciiNumber <= 91 {
                        key = asciiNumber - 64;
                        //                        key = asciiNumber - 64 + Int(arc4random() % 10);
                    }
                    var values = self.friends[key];
                    if values == nil {
                        values = [];
                    }
                    values?.append(item);
                    self.friends[key] = values;
                }
                self.tableView.reloadData();
                
            }
            
            result([]);

        }
       
        
    }
    
    private func loadLocalData(_ result: @escaping DYTableView_Result) {
           
           self.friends.removeAll();
           var array:[OWSUserProfile] = [];
           SSKEnvironment.shared.databaseStorage.read { (transaction) in
               array = OWSUserProfile.anyFetchAll(transaction: transaction);
           }
            var data:[OWSUserProfile] = [];
            data.append(contentsOf: array);
           for item in data {
               if item.relationType != .friend {
                   continue;
               }
               let initialLetter = item.getContactName().transformToPinyinHead();
               
               let asciiNumber = Character.init((initialLetter)).toInt();
               var key = 27;
               if asciiNumber >= 65 && asciiNumber <= 91 {
                   key = asciiNumber - 64;
               }
               var values = self.friends[key];
               if values == nil {
                   values = [];
               }
               values?.append(item);
               self.friends[key] = values;
           }
           result([]);
           self.tableView.reloadData();
           
       }
    
    private var tableView: DYTableView = {
        
        let view = DYTableView.init();
        
        view.register(ContactsCell.self, forCellReuseIdentifier: "cell");
        view.register(ContactsCell.self, forCellReuseIdentifier: "sectionCell");

        view.rowHeight = 68;
        view.tableFooterView = UIView.init();
        view.separatorColor = UIColor.clear;
        view.isShowNoData = false;
        
        
        
        return view;
        
    }();
    
    @objc
    private func moreBtnClick() {
        let array = ["添加好友", "扫一扫", "创建群聊"];
        let imgs = ["pigram-nav-add-friend","pigram-nav-qr","pigram-nav-group-create"];
        var actions:[YCMenuAction] = [];
        for (index,item) in array.enumerated() {
            
            let action = YCMenuAction.init(title: item, image: UIImage.init(named: imgs[index]));
            actions.append(action!);
        }
        
        let menuView = YCMenuView.menu(with: actions, width: 120, relyonView: self.navigationItem.rightBarButtonItems?.first);
        menuView?.textFont = UIFont.systemFont(ofSize: 14);
        menuView?.textColor = UIColor.hex("#2d4257");
        menuView?.show();
        menuView?.didSelectedCellCallback = {
            (view,indexpath) in
            switch indexpath?.row {
            case 0:
                let vc = FriendAdditionVC.init();
                vc.hidesBottomBarWhenPushed = true;
                self.navigationController?.pushViewController(vc, animated: true);
                break;
            case 1:
                self.txEntrySearch()
                break;
            case 2:
                
                
                
                let contactVC = ContactListVC.init()
                contactVC.navTitle = "创建群聊"
                contactVC.rightNavTitle = "完成"
                contactVC.filters = ["___officer____!"]
                
                contactVC.showVC(fromVC: self) {[weak self] (listVc, results) in
                    
                    if results.count == 0 || results.count < 2{
                        OWSAlerts.showAlert(title: "请至少选择两人创建群聊");
                        return;
                    }
                    if let weakSelf = self{
                        PigramGroupManager.createGroups(fromVC: weakSelf, results) { (result) in
                            if result{
                                listVc.dismiss(animated: true, completion: nil);
                            }
                        }
                    }
                }

                break;
            default:
                break;
            }
        }
        
    }

    @objc
    private func searchBtnClick() {
        let vc = DYSearchVC.searchVC();
        vc.placeholder = "输入好友昵称...";

        vc.selectedSearchBtnCallback = {
            (tableView, text) in
            tableView?.loadDataCallback = {
                (_, result) in
                var arrayM: [OWSUserProfile] = [];
                
                for item in self.friends.values {
                    
                    let newFriends = item.filter { (member) -> Bool in
                        
                        if member.getContactName().contains(text) {
                            return true;
                        }
                        return false
                    }
                    arrayM.append(contentsOf: newFriends);
                }
                result(arrayM);
            };
            tableView?.begainRefreshData();
            
        }
        vc.tableView?.didSelectedTableViewCellCallback = {
            [weak self] (cell, index) in
            
            if let model = cell.model as? OWSUserProfile {
                self?.dismiss(animated: false, completion: {
                    let vc = FriendSearchVC.init();
                    vc.user = model;
                    if model.address.userid == TSAccountManager.localUserId {
                        vc.hideConfirmBtn = true
                    }
                    vc.hidesBottomBarWhenPushed = true;
                    self?.navigationController?.pushViewController(vc, animated: true);
                });
            }
        };
        vc.tableView?.register(ContactsCell.self, forCellReuseIdentifier: "cell");
        vc.tableView?.rowHeight = 68;
        vc.tableView?.tableFooterView = UIView.init();
        vc.tableView?.separatorColor = UIColor.lightGray;
        vc.tableView?.noDataText = "没有搜索到相关的好友！";
        
       
        self.present(vc, animated: true, completion: nil);
    }
    private var unreadView: DYUnreadView = {
        
        let view = DYUnreadView.init();
        view.setUnreadNumber(0);
        return view;
        
    }()
        
    private var friends: [Int: [OWSUserProfile]] = [:];
    
    private var verifies: [OWSUserProfile] = [];

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want t do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    */

    deinit {
        NotificationCenter.default.removeObserver(self);
    }


}


extension ContactsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 28;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.verifies.count;
        }
        return self.friends[section]?.count ?? 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactsCell;
        
        if indexPath.section == 0 {
//            cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell", for: indexPath) as! ContactsCell;
            if indexPath.row == 0 {
                cell.showNewFriendView();
            } else {
                cell.accessoryView = nil;
            }
            let profile = self.verifies[indexPath.row];
            MyLog(profile.profileName)
            cell.nickLabel.text = profile.profileName;
            cell.avatarView.image = profile.getContactAvatarImage();
        } else {
            let user = self.friends[indexPath.section]![indexPath.row];
            cell.model = user;
            cell.accessoryView = nil;
        }
        
        return cell;
        
    }
  

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true);
        if indexPath.section == 0 {
            var vc: UIViewController?;
            if indexPath.row == 0 {
                vc = PGVerifycationsVC.init();
            } else if indexPath.row == 1 {
                vc = GroupListVC.init();
            } else {
                vc = PGGroupsVC.init();
            }
            vc?.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(vc!, animated: true);

            
        } else {
            let model = self.friends[indexPath.section]![indexPath.row];
            let vc = FriendSearchVC.init();
            vc.user = model;
            if model.address.userid == TSAccountManager.localUserId {
                vc.hideConfirmBtn = true
            }
            vc.hidesBottomBarWhenPushed = true;
            self.navigationController?.pushViewController(vc, animated: true);
        }
        
        
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let users = self.friends[section];
        
        if users?.count ?? 0 > 0 {
            return 21
        }
        
        return 0;
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var text = "#";
        if section != 27 {
            text = String.init(Character(Unicode.Scalar.init(section + 64)!));
        }
        let label = UILabel.init();
        label.backgroundColor = UIColor.hex("#f0f3f9");
        label.textColor = UIColor.hex("#758493");
        label.font = UIFont.boldSystemFont(ofSize: 14);
        label.text = "    " + text;
        return label;
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
      
        
//        var array:[String] = [];
//        let titles = self.friends.keys.sorted();
//        for item in titles {
//            let index = item + 64;
//            if index > 90 {
//                array.append("#");
//            } else {
//                array.append(String.init(Character.init(Unicode.Scalar.init(index)!)));
//            }
//        }
        var array:[String] = [];
        
        for item in 65..<91 {
            array.append(String.init(Character.init(Unicode.Scalar.init(item)!)));
        }
        array.append("#");
        return array;
    }
    
    
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
       
        
        return index + 1;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
//        if indexPath.section != 0 {
//           let model = self.friends[indexPath.section]![indexPath.row];
//            if model.address.phoneNumber == TSAccountManager.localNumber {
//                return false;
//            }
//            return true;
//        }
        return false;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
//            OWSAlerts.showConfirmationAlert(title: "删除好友", message: "是否确定删除好友", proceedTitle: "d删除") { (_) in
//                let model = self.friends[indexPath.section]![indexPath.row];
//                model.deleteFromFriendList();
//                self.friends[indexPath.section]!.remove(at: indexPath.row);
//                tableView.deleteRows(at: [indexPath], with: .automatic);
//            }
//
            
        }
        
    }
    
    
    
    
    
}
