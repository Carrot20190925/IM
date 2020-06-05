//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXBlackListController: BaseVC {
    enum BlackType {
        case add
        case remove
        case removeAction
    }
    var type: BlackType = .add
    var isCanDelete: Bool = false;
    var isCanSelect: Bool = false;
    var blackList : [OWSUserProfile]?
    
    var rightNavTitle = "完成"
    var navTitle: String?
    
    var compeleted: ((TXBlackListController,[OWSUserProfile]) -> Void)?
    
    public static func showVC(_ fromVC: UIViewController, navTitle: String, rightNavTitle:String,type:BlackType, compeleted:@escaping (TXBlackListController,[OWSUserProfile]) -> Void) {
        
        let vc = TXBlackListController.init();
        vc.navTitle = navTitle;
        vc.rightNavTitle = rightNavTitle;
        vc.compeleted = compeleted;
        vc.type = type
        let nav = BaseNavigationVC.init(rootViewController: vc);
        
        fromVC.present(nav, animated: true, completion: nil);
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.navTitle;
        self.view.addSubview(self.tableView);
        self.tableView.dataSource  = self;
        self.tableView.delegate = self;
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-leftBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(leftBtnClick))
        let confirm  = UIBarButtonItem.init(title: self.rightNavTitle, style: .plain, target: self, action: #selector(confirmBtnClick));
      
        confirm.tintColor = kPigramThemeColor;
//        let search = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(searchBtnClick));
        if self.type == .removeAction {
            self.navigationItem.rightBarButtonItems = [confirm];

        }else{
            self.navigationItem.rightBarButtonItems = [confirm];

        }
        self.updatetableViewContents();

//         Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.loadLocalDataAction()
    }
    
    @objc
    func leftBtnClick() {
        self.dismiss(animated: true, completion: nil);
    }
    @objc
    func confirmBtnClick() {
        switch self.type {
        case .add:
            self.addBlackTableAction()
        case .remove:
            self.removeBlackTableAction()
        default:
            self.compeleted?(self, [OWSUserProfile](self.selecteds.values));
        }
     
       
    }
    private func removeBlackTableAction(){
        TXBlackListController.showVC(self, navTitle: "移除黑名单", rightNavTitle: "完成", type: TXBlackListController.BlackType.removeAction) {[weak self] (listVC, profiles) in

            
            if profiles.count == 0{
                return
            }
            var destinationIds:[String] = []
            
            for profile in profiles{
                if let userId = profile.address.userid{
                    destinationIds.append(userId)
                }
            }
            let params = ["destinationIds":destinationIds]
            ModalActivityIndicatorViewController.present(fromViewController: listVC, canCancel: true) { (modal) in
                PigramNetworkMananger.pgRemoveUserBlackListNetwork(params: params, success: { (_) in
                    DispatchQueue.main.async {
                        for profile in profiles{
                           SSKEnvironment.shared.databaseStorage.write { (transaction) in
                                    profile.anyUpdate(transaction: transaction) { (profile) in
                                        if profile.relationType == .block{
                                            profile.relationType = .friend
                                        }
                                }
                            }
                            SSKEnvironment.shared.blockingManager.removeBlockedAddress(profile.address);
                        }
                        modal.dismiss {
                            listVC.navigationController?.dismiss(animated: true, completion: {
                                self?.loadLocalDataAction()
                            })
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
    private func addBlackTableAction(){
        let contactVC = ContactListVC.init()
        var filterMemebers : [String] = []
        if let filters = self.blackList {
            filterMemebers = filters.map({ (profile) -> String in
                return profile.address.userid ?? "";
            })
            
            
        }
        filterMemebers.append("___officer____!")
        contactVC.filters  = filterMemebers
        contactVC.navTitle = "添加黑名单"
        contactVC.showVC(fromVC: self) {[weak self] (listVC, profiles) in
            if profiles.count == 0{
                return
            }
            var destinationIds:[String] = []
            for profile in profiles{
                if let userId = profile.address.userid{
                    destinationIds.append(userId)
                }
            }
            let params = ["destinationIds":destinationIds]
            ModalActivityIndicatorViewController.present(fromViewController: listVC, canCancel: true) { (modal) in
                PigramNetworkMananger.pgAddUserBlackListNetwork(params: params, success: { (_) in
                    DispatchQueue.main.async {
                        for profile in profiles{
                           SSKEnvironment.shared.databaseStorage.write { (transaction) in
                                profile.anyUpdate(transaction: transaction) { (profile) in
                                    if profile.relationType == .friend{
                                        profile.relationType =  .block
                                    }
                                }
                            }
                        }
                        modal.dismiss {
                            listVC.navigationController?.dismiss(animated: true, completion: {
                                self?.loadLocalDataAction()
                            })
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

    
    @objc
    func searchBtnClick() {
        
    }
    
    private func updatetableViewContents() {
        var array : [OWSUserProfile] = []
         SSKEnvironment.shared.databaseStorage.read { (transaction) in
             let profiles = OWSUserProfile.anyFetchAll(transaction: transaction)
             array = profiles.filter({ (profile) -> Bool in
                 return profile.relationType == .block
             })
         }

        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
            PigramNetworkMananger.pgGetUserBlackListNetwork(params: [:], success: { (response) in
                guard let objects = response as? Array<Dictionary <String,Any>> else{
                    DispatchQueue.main.async {
                        modal.dismiss {
                            self.loadLocalDataAction()
                        }
                    }
                    return
                }
                if objects.count == array.count{
                    DispatchQueue.main.async {
                        modal.dismiss {
                            self.loadLocalDataAction()
                        }
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        modal.dismiss {
                            self.loadNetData(responseData: objects)
                        }
                    }
                }
                
            }) { (error) in
                DispatchQueue.main.async {
                    modal.dismiss {
                        self.loadLocalDataAction()
                    }
                }
            }
        }


          
      }
    
    private func loadNetData(responseData:Array<Dictionary<String,Any>> ){
        SSKEnvironment.shared.databaseStorage.write { (write) in
            for item in responseData {
                if let destinationId = item["destinationId"] as? String{
                    let profile = OWSUserProfile.getOrBuild(for: SignalServiceAddress.init(phoneNumber: destinationId), transaction: write)
                    profile.relationType = .block
                    profile.anyInsert(transaction: write)
                }
            }
        }

        self.loadLocalDataAction()
    }
    private func loadLocalDataAction(){
        self.tableView.loadLocalDataCallback = {[weak self] result in
            
            self?.friends.removeAll();
            var array:[OWSUserProfile] = [];
//            let addressSet = SSKEnvironment.shared.blockingManager.blockedAddresses
            SSKEnvironment.shared.databaseStorage.read { (transaction) in
                let profiles = OWSUserProfile.anyFetchAll(transaction: transaction)
                array = profiles.filter({ (profile) -> Bool in
                    return profile.relationType == .block
                })
            }
            self?.blackList = array
            for item in array {
                var initialLetter = item.getContactName().transformToPinyinHead();
                if initialLetter.length == 0 {
                    initialLetter = "#";
                }
                let asciiNumber = Character.init(initialLetter).toInt();
                var key = 26;
                if asciiNumber >= 65 && asciiNumber <= 91 {
                    key = asciiNumber - 65;
                }
                var values = self?.friends[key];
                if values == nil {
                    values = [];
                }
                let model = ContactListModel.init(item);
                values?.append(model);
                self?.friends[key] = values;
            }
            result(self?.friends.keys.count ?? 0 > 0 ? [""] : []);
            
        }
        self.tableView.loadLocalData()
    }

    private var tableView: DYTableView = {
           
       let view = DYTableView.init();
       view.backgroundColor = UIColor.white;
       view.register(ContactListCell.self, forCellReuseIdentifier: "cell");

       view.rowHeight = 68;
       view.tableFooterView = UIView.init();
       view.separatorColor = UIColor.clear;
       view.isShowNoData = true;
       view.noDataText = "你还没有任何黑名单好友";
       
       
       
       return view;
           
       }();
    
    private var friends: [Int: [ContactListModel]] = [:];

    private var selecteds: [String : OWSUserProfile] = [:];

}

extension TXBlackListController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 27;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.friends[section]?.count ?? 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactListCell;
        if self.type != .removeAction {
            cell.isShowSelectBtn = false
        }
        let user = self.friends[indexPath.section]![indexPath.row];
        cell.model = user;
        
        return cell;
        
    }
  

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true);
        if self.type != .removeAction {
            return
        }
        let model = self.friends[indexPath.section]![indexPath.row];
        let user = model.user;
        model.isSelected = !model.isSelected;
        if model.isSelected {
            self.selecteds[user.uniqueId] = user;
        } else {
            self.selecteds.removeValue(forKey: user.uniqueId);
        }
        let cell = tableView.cellForRow(at: indexPath) as! ContactListCell
        cell.makesButtonSelect(model.isSelected)
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
        if section != 26 {
            text = String.init(Character(Unicode.Scalar.init(section + 65)!));
        }
        let label = UILabel.init();
        label.backgroundColor = UIColor.hex("#f0f3f9");
        label.textColor = UIColor.hex("#758493");
        label.font = UIFont.boldSystemFont(ofSize: 14);
        label.text = "    " + text;
        return label;
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        var array:[String] = [];
        
        for item in 65..<91 {
            array.append(String.init(Character.init(Unicode.Scalar.init(item)!)));
        }
        array.append("#");
        return array;
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return 27;
    }
    
   
    
    
    
    
    
}
