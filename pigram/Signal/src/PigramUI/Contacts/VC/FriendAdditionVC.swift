//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class FriendAdditionVC: BaseVC{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "添加好友";
        
        self.view.addSubview(self.tableView);
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        // Do any additional setup after loading the view.
    }
    
  
    
    private var tableView: UITableView = {
        
        let view = UITableView.init()
        view.backgroundColor = UIColor.white
        view.tableFooterView = UIView.init();
        view.rowHeight = 64;
        
        return view;
        
    }();
    
    private var data:[[String:String]] = [
        ["icon": "pigram-contact-search", "title" : "手机号添加", "subText": "搜索手机号"],
        ["icon": "pigram-contact-QR", "title" : "扫一扫添加好友", "subText": "扫描二维码"],
//        ["icon": "pigram-contact-phone", "title" : "手机联系人", "subText": "添加手机通讯录的好友"],
    ];

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension FriendAdditionVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell");
        cell.backgroundColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15);
        cell.textLabel?.textColor = UIColor.hex("#273d52");
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12);
        cell.detailTextLabel?.textColor = UIColor.hex("#68727e");
        let dict = self.data[indexPath.row];
        cell.imageView?.image = UIImage.init(named: dict["icon"]!);
        cell.textLabel?.text = dict["title"];
        cell.detailTextLabel?.text = dict["subText"];
        cell.accessoryType = .disclosureIndicator;
        return cell;
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        
        switch indexPath.row {
        case 0:
            let vc = PigramSearchVC.init();
            vc.placeholderText = "请输入国家区号 + 手机号";
            vc.hidesBottomBarWhenPushed = true;
            vc.tableView.register(ContactsCell.self, forCellReuseIdentifier: "cell");
            vc.tableView.rowHeight = 68;
            vc.tableView.backgroundColor = UIColor.white
            vc.tableView.noDataText = "没有找到你要的联系人";
            vc.searchBar.text = "";
            vc.searchBar.showsSearchResultsButton = true;
            vc.searchBar.keyboardType = .alphabet;
            vc.selectedSearchBtnCallback = {
                (tableview, text) in
                var _text = text;
                if text[0] != "+" {
                    _text = "+" + text;
                }
                
                tableview?.loadDataCallback = {
                    (_, result) in
                    
                    ContactsUpdater.shared().pg_searchUser(_text, successed: { (users) in
                        
                        DispatchQueue.main.async {
                            if users == nil {
                                result([]);
                            } else {
                                result(users ?? []);
                            }
                        }
                        
                        
                    }) { (error) in
                        DispatchQueue.main.async {
                            result([]);
                            if  let sureError = error as? NSError,sureError.code == 404{
                                OWSAlerts.showErrorAlert(message: "没有找到相关用户");
                                return;
                            }
                            OWSAlerts.showErrorAlert(message: error.localizedDescription);
                        }
                       
                    }
                    
                };
                tableview?.isShowNoData = true;
                tableview?.begainRefreshData();
            };
            vc.tableView.didSelectedTableViewCellCallback = {
                [weak self] (cell,_) in
                
                if cell.model is OWSUserProfile {
                    let vc = FriendSearchVC.init();
                    vc.user = cell.model as? OWSUserProfile;
                    if vc.user?.address.userid == TSAccountManager.localUserId {
                        vc.hideConfirmBtn = true
                    }
                    self?.navigationController?.pushViewController(vc, animated: true);
                }
            }
            self.navigationController?.pushViewController(vc, animated: true);
            break
        case 1:
            
            self.txEntrySearch()
            break
            
        default:
            break;
        }
    }
    
    
    
}


