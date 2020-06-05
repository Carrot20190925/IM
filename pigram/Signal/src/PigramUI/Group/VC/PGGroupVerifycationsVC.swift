//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class PGGroupVerifycationsVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = kPigramLocalizeString("群消息验证", nil);
        
        self.view.addSubview(self.tableView);
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        self.tableView.loadDataCallback = {
            [weak self] (_, result) in
            
            self?.loadData(result);
            
        };
        self.tableView.loadLocalDataCallback = {
            (result) in
            
            result(PigramVerifyManager.shared.getAllGroupVerifications());
        };
        
        self.tableView.loadLocalData();
        self.tableView.didSelectedTableViewCellCallback = {
                       [weak self] (cell,indexPath) in
            
            if  let model = cell.model as? PigramVerifyModel {
                var nickname: String?;
                kSignalDB.read { (read) in
                    let profile = OWSUserProfile.getFor(model.applyAddress!, transaction: read);
                    nickname = profile?.profileName;
                }
                
                OWSAlerts.showConfirmationAlert(title: "是否确定同意\(nickname ?? "此人")进入群聊？") { (_) in
                    self?.agreeGroupApply(model: model, index: indexPath);
                }
                
            }
        }
        self.tableView.deleteCellCallback = {
            [weak self] (view, indexPath) in
            
            if  let model = view.dy_dataSource[indexPath.row] as? PigramVerifyModel {
                self?.deleteModel(model, indexPath: indexPath);
            }
            
        };
        
        // Do any additional setup after loading the view.
        self.addNotification();
    }
    
    private func addNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onVerifyChanged), name: NSNotification.Name.kNotification_Pigram_Group_Apply, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(onVerifyChanged), name: NSNotification.Name.kNotification_Pigram_Group_Apply_handled, object: nil);
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
        self.tableView.loadLocalData();
    }
    
    private func deleteModel(_ model: PigramVerifyModel, indexPath: IndexPath) {
        
        PigramVerifyManager.shared.deleteVerifacation(model);
        if self.tableView.dy_dataSource.count > indexPath.row {
            self.tableView.dy_dataSource.removeObject(at: indexPath.row);
            self.tableView.deleteRows(at: [indexPath], with: .automatic);
        }
    }
    
    //MARK:-  同意申请入群请求
    
    private func agreeGroupApply(model: PigramVerifyModel, index: IndexPath) {
        guard let applyId = model.applyId else {
            return ;
        }
        guard let groupId = model.groupId() else {
            return;
        }
        let params = ["groupId":groupId,"userId":applyId]
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
            PigramNetworkMananger.pgAgreeJoinGroupNetwork(params: params, success: { (_) in
                self.deleteModel(model, indexPath: index);
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showAlert(title: "操作成功")
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
    
    private func loadData (_ result: DYTableView_Result) {
        PigramVerifyManager.shared.getAllVerifications();
        result(PigramVerifyManager.shared.getAllGroupVerifications());
                
    }
    
    private var tableView: DYTableView = {
           
        let view = DYTableView.init();
        view.backgroundColor = UIColor.white
        view.rowHeight = 68;
        view.register(NewFriendCell.self, forCellReuseIdentifier: "cell");
        view.noDataText = "没有任何群验证消息";
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
