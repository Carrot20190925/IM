//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit


class ContactListModel {
    
    var isSelected: Bool = false;
    let user: OWSUserProfile
    
    required init(_ userProfile: OWSUserProfile) {
        user = userProfile;
    }
    
    
    
}

@objcMembers class ContactListVC: BaseVC {

    var isCanDelete: Bool = false;
    var isCanSelect: Bool = false;
    var rightNavTitle = "完成"
    var navTitle: String?
    //过滤掉一些成员
    var filters:[String]?
    
    var compeleted: ((ContactListVC,[OWSUserProfile]) -> Void)?

    /**
     * 显示我的好友列表 并选择
     */
    public static func showVC(_ fromVC: UIViewController, navTitle: String, rightNavTitle:String, compeleted:@escaping (ContactListVC,[OWSUserProfile]) -> Void) {
        
        let vc = ContactListVC.init();
        vc.navTitle = navTitle;
        vc.rightNavTitle = rightNavTitle;
        vc.compeleted = compeleted;
        let nav = BaseNavigationVC.init(rootViewController: vc);
        
        fromVC.present(nav, animated: true, completion: nil);
    }
    /**
     * 显示我的好友列表 并选择 过滤
     */
    public func showVC(fromVC: UIViewController?, compeleted:@escaping (ContactListVC,[OWSUserProfile]) -> Void) {
        
        self.compeleted = compeleted;
        let nav = BaseNavigationVC.init(rootViewController: self);
        
        fromVC?.present(nav, animated: true, completion: nil);
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.navTitle;
        self.view.addSubview(self.tableView);
        self.tableView.backgroundColor = UIColor.white
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        self.loadData();
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(leftBtnClick));
        let confirm = UIBarButtonItem.init(title: self.rightNavTitle, style: .plain, target: self, action: #selector(confirmBtnClick));
        confirm.tintColor = kPigramThemeColor;
        let search = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(searchBtnClick));
        self.navigationItem.rightBarButtonItems = [confirm,search];
        self.tableView.didSelectedTableViewCellCallback = {
            [weak self] (cell, index) in
            
            if let model = cell.model as? ContactListModel {
                model.isSelected = !model.isSelected;
                self?.updateCellSelectState(model: model, index: index);
            }
        }
    }
    
    @objc
    func leftBtnClick() {
        self.dismiss(animated: true, completion: nil);
    }
    @objc
    func confirmBtnClick() {
        self.compeleted?(self, [OWSUserProfile](self.selecteds.values));
    }
    @objc
    private func searchBtnClick() {
        let vc = DYSearchVC.searchVC();
        vc.placeholder = "输入好友昵称...";
        
        vc.selectedSearchBtnCallback = {
           [weak self] (tableView, text) in
            tableView?.loadDataCallback = {
               [weak self] (_, result) in
                var arrayM: [ContactListModel] = [];
            
                for item in self?.tableView.dy_dataSource ?? [] {
                    
                    if let member = item as? ContactListModel {
                        if member.user.getContactName().contains(text) {
                            arrayM.append(member);
                        }
                    }
                }
                result(arrayM);
            };
            tableView?.begainRefreshData();
            
        }
        vc.tableView?.didSelectedTableViewCellCallback = {
            [weak self] (cell, index) in
            
            if let model = cell.model as? ContactListModel {
                if let _cell = cell as? ContactListCell {
                    model.isSelected = !model.isSelected;
                    _cell.makesButtonSelect(model.isSelected);
                }
                let index: IndexPath = IndexPath.init(row: self?.tableView.dy_dataSource.index(of: model) ?? 0, section: 0);
                self?.updateCellSelectState(model: model, index: index);
            }
        };
        vc.tableView?.register(ContactListCell.self, forCellReuseIdentifier: "cell");
        vc.tableView?.rowHeight = 68;
        vc.tableView?.tableFooterView = UIView.init();
        vc.tableView?.separatorColor = UIColor.lightGray;
        vc.tableView?.noDataText = "没有搜索到相关的好友！";
        
        
        self.present(vc, animated: true, completion: nil);
    }
    
    
    
    
    private func updateCellSelectState (model : ContactListModel, index: IndexPath) {
        
        let user = model.user;
        if model.isSelected {
            self.selecteds[user.uniqueId] = user;
        } else {
            self.selecteds.removeValue(forKey: user.uniqueId);
        }
        if let cell = self.tableView.cellForRow(at: index) as? ContactListCell {
            cell.makesButtonSelect(model.isSelected);
        }
        
    }
    private func loadData () {
        self.tableView.loadDataCallback = {
            [weak self] (_, result) in
            
            self?.friends.removeAll();
            var array:[OWSUserProfile] = [];
            SSKEnvironment.shared.databaseStorage.read { (transaction) in
                array = OWSUserProfile.anyFetchAll(transaction: transaction);
            }
            var models:[ContactListModel] = [];
            
            for item in array {
                if item.relationType != .friend {
                    continue;
                }
                if self?.filters?.contains(where: { (userid) -> Bool in
                    return item.address.phoneNumber == userid || item.address.phoneNumber?.contains(userid) ?? true;
                }) ?? false {
                    continue;
                }
                let model = ContactListModel.init(item);
                models.append(model);
            }
            
            result(models);
        };
        self.tableView.loadData();
    }
    /**
     * 按字母分组
     */
    @available(*,deprecated,message: "因为添加了好友搜索，所以不再使用首字母排序！")
    private  func updatetableViewContents() {
          
        self.tableView.loadDataCallback = {
            [weak self] (_, result) in
            
            self?.friends.removeAll();
            var array:[OWSUserProfile] = [];
            SSKEnvironment.shared.databaseStorage.read { (transaction) in
                array = OWSUserProfile.anyFetchAll(transaction: transaction);
            }
            for item in array {
                if item.relationType != .friend {
                    continue;
                }
               if self?.filters?.contains(where: { (userid) -> Bool in
                   return item.address.phoneNumber == userid;
                }) ?? false {
                    continue;
                }
                
                var initialLetter = item.getContactName().transformToPinyinHead();
                if initialLetter.length == 0 {
                    initialLetter = "#";
                }
                
                let asciiNumber = Character.init(initialLetter).toInt();
                var key = 26;
                if asciiNumber >= 65 && asciiNumber <= 91 {
                    key = asciiNumber - 65;
                    //                        key = asciiNumber - 64 + Int(arc4random() % 10);
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
        };
        self.tableView.loadData();
          
      }

    private var tableView: DYTableView = {
           
           let view = DYTableView.init();
           
           view.register(ContactListCell.self, forCellReuseIdentifier: "cell");

           view.rowHeight = 68;
           view.tableFooterView = UIView.init();
           view.separatorColor = UIColor.clear;
           view.isShowNoData = false;
            view.banRefresh();
           
           return view;
           
       }();
    
    private var friends: [Int: [ContactListModel]] = [:];

    private var selecteds: [String : OWSUserProfile] = [:];
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


//extension ContactListVC : UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 27;
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return self.friends[section]?.count ?? 0;
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactListCell;
//
//        let user = self.friends[indexPath.section]![indexPath.row];
//        cell.model = user;
//
//        return cell;
//
//    }
//
//
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        tableView.deselectRow(at: indexPath, animated: true);
//        let model = self.friends[indexPath.section]![indexPath.row];
//        self.updateCellSelectState(model: model, index: indexPath);
//
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//
//        let users = self.friends[section];
//
//        if users?.count ?? 0 > 0 {
//            return 21
//        }
//
//        return 0;
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        var text = "#";
//        if section != 26 {
//            text = String.init(Character(Unicode.Scalar.init(section + 65)!));
//        }
//        let label = UILabel.init();
//        label.backgroundColor = UIColor.hex("#f0f3f9");
//        label.textColor = UIColor.hex("#758493");
//        label.font = UIFont.boldSystemFont(ofSize: 14);
//        label.text = "    " + text;
//        return label;
//    }
//
//
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//
//        var array:[String] = [];
//
//        for item in 65..<91 {
//            array.append(String.init(Character.init(Unicode.Scalar.init(item)!)));
//        }
//        array.append("#");
//        return array;
//    }
//
//    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//
//        return index;
//    }
//
//
//
//
//
//
//
//}
