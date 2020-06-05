//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class SessionVC: BaseVC {

    
//    private let searchBar = OWSSearchBar.init()
    
    /// MARK: private
    private let homeVC: HomeViewController = {
        
        let view = HomeViewController.init();
        return view;
        
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.homeVC.hideSearchBarAction =  {[weak self] in
//            self?.removeSearchBarAction()
//        }
               
        self.navigationItem.title = "聊天";
//        self.navigationItem.titleView = UIView.init();
        let label = UILabel.init();
        label.font = UIFont.boldSystemFont(ofSize: 27)
        label.textColor = UIColor.black;
        label.text = self.navigationItem.title;
        label.sizeToFit();
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label, accessibilityIdentifier: "leftTitle");
        
        self.addChild(self.homeVC);
        self.view.addSubview(self.homeVC.view);
        
//        let search = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(addSearchBarAction))
        let more = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-more")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(moreBtnClick));
//        let search = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(searchBtnClick));
        self.navigationItem.rightBarButtonItems = [more];
        self.addTitleViewChangesBarHeight();
        // Do any additional setup after loading the view.
        self.addNotification();
        self.updateBadgeValue();
    }
    
//    //MARK:-  增加搜索栏
//    @objc
//    func addSearchBarAction()  {
//        self.navigationItem.rightBarButtonItems = nil;
//        self.homeVC.showSearchBarAction()
//    }
//    func removeSearchBarAction() {
//        let search = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(addSearchBarAction))
//        let more = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-more")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(moreBtnClick));
//        self.navigationItem.rightBarButtonItems = [more,search];
//        self.navigationItem.titleView = UIView.init()
//    }
//
    
    
    
    
    
    private func addNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNewGroupApply(_:)), name: NSNotification.Name.kNotification_Pigram_Group_Apply, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(onGroupApplyHandled(_:)), name: NSNotification.Name.kNotification_Pigram_Group_Apply_handled, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(onFriendVerification), name: NSNotification.Name.kNotification_Friend_Invite_apply, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(onFriendVerification), name: NSNotification.Name.kNotification_Friend_Invite_accept, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(removeGroupVerifyAction(_:)), name: NSNotification.Name.kNotification_Pigram_Group_Romove_Manager_handled, object: nil);


    }
    @objc
    func removeGroupVerifyAction(_ noti : Notification) {
        if let groupId = noti.object as? String{
            PigramVerifyManager.shared.clearGroupVerify(groupId: groupId)
        }
        self.updateBadgeValue()
    }
    ///收到入群申请
    @objc func onNewGroupApply(_ obj: NSNotification) {
        if let _value = obj.object as? [String] {
            
            let applyid = _value[0];
            let destinationid = _value[1];
            
            let model = PigramVerifyModel.init(applyid: applyid, destinationid: destinationid);
            PigramVerifyManager.shared.updateOrAddVerifycation(model);
        }
       self.updateBadgeValue();
    }
    ///收到
    @objc func onGroupApplyHandled(_ obj: NSNotification) {
        if let data = obj.object as? [Any] {
            let phone = data.first as? String;
            let groupId = data[1] as? String;
            let model = PigramVerifyModel.init(applyid: phone!, destinationid: groupId!);
            PigramVerifyManager.shared.deleteVerifacation(model);
        }
        self.updateBadgeValue();

    }
    
    ///收到好友申请或同意 只处理小红点数量的显示
    @objc func onFriendVerification() {
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



//MARK:-  暂未实现
extension SessionVC:UISearchBarDelegate{
    
    func initSearchBar() {
//        self.searchBar.delegate = self;
    }
    
    //MARK:-  UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }

    
}

class PigramTitleView: UIView {
    
    
    override var intrinsicContentSize: CGSize {
        
        return CGSize.init(width: 100, height: 60);
    }
}
