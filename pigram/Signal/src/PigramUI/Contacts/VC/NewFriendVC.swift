//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class NewFriendVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "新朋友";
        self.view.addSubview(self.tableView);
        
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        self.tableView.loadDataCallback = {
            (_,result) in
            
            result(PigramVerifyManager.shared.getAllFriendVerifications());
            
        };
        self.tableView.loadData();
         self.tableView.didSelectedTableViewCellCallback = {
                       [weak self] (cell,_) in
            
            if let model = cell.model as? PigramVerifyModel {
                let vc = FriendReceiveVerifyVC.init();
                vc.friend = model;
                self?.navigationController?.pushViewController(vc, animated: true);
            }
            
        }
        self.tableView.deleteCellCallback = {
            (view, indexPath) in
           
            if  let model = view.dy_dataSource[indexPath.row] as? PigramVerifyModel {
                PigramVerifyManager.shared.deleteVerifacation(model);
                view.dy_dataSource.removeObject(at: indexPath.row);
                view.deleteRows(at: [indexPath], with: .automatic);
            }
            
        };
        self.addNotification();
    }
    
    private func addNotification() {
           
           NotificationCenter.default.addObserver(self, selector: #selector(onVerifyChanged), name: NSNotification.Name.kNotification_Pigram_Group_Apply, object: nil);

           NotificationCenter.default.addObserver(self, selector: #selector(onVerifyChanged), name: NSNotification.Name.kNotification_Pigram_Group_Apply_handled, object: nil);
           
           NotificationCenter.default.addObserver(self, selector: #selector(onVerifyChanged), name: NSNotification.Name.kNotification_Friend_Invite_apply, object: nil);

           NotificationCenter.default.addObserver(self, selector: #selector(onVerifyChanged), name: NSNotification.Name.kNotification_Friend_Invite_accept, object: nil);
        
          NotificationCenter.default.addObserver(self, selector: #selector(removeGroupVerifyAction(_:)), name: NSNotification.Name.kNotification_Pigram_Group_Romove_Manager_handled, object: nil);



       }
    
    @objc
    func removeGroupVerifyAction(_ noti : Notification) {
        if let groupId = noti.object as? String{
            PigramVerifyManager.shared.clearGroupVerify(groupId: groupId)
        }
        self.onVerifyChanged()
    }
    
    @objc func onVerifyChanged() {
        self.tableView.loadData();
    }

    
    private var tableView: DYTableView = {
        
        let view = DYTableView.init();
        view.backgroundColor = UIColor.white
        view.rowHeight = 68;
        view.register(NewFriendCell.self, forCellReuseIdentifier: "cell");
        view.noDataText = "你还没有收到任何好友邀请";
        view.canDeleteCell = true;
        return view;
        
    }();
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
