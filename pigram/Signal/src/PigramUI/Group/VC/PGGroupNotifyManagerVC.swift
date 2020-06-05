//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

public class PGGroupNotifyManagerModel: DYTableViewModel {
    
    var contentStr: String {
        
        get {
            
            return ["1" : "踢人","2" : "退群","3" : "禁言","0" : "未知"][self.id ?? "0"]!;
        }
        
        
    }
    
    var id: String?;
    var isSwitch: Bool = false;
    
}

class PGGroupNotifyManagerVC: BaseVC {

    var groupModel: TSGroupModel?
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "通知范围管理";
        self.view.addSubview(self.tableView);
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        self.tableView.loadDataCallback = {
            [weak self] (_, result) in
            var models:[PGGroupNotifyManagerModel] = [];
            if let _model = self?.groupModel {
                for item in _model.notificationMutes {
                    let model = PGGroupNotifyManagerModel.init();
                    model.id = item.key as? String;
                    let result = item.value as? Int ?? 1;
                    model.isSwitch = result == 2 ? false : true;
                    models.append(model);
                }
            }
            result(models);
            PigramNetwork.getGroupInfo(self?.groupModel?.groupId ?? "", isNeedMembers: false) { (model, error) in
                
                if let _model = model, _model.notificationMutes.count > 0 {
                    for item in _model.notificationMutes {
                        for notify in models {
                            let result = item.value as? Int ?? 1;
                            if let idstr = item.key as? String {
                                if notify.id ?? "" == idstr {
                                    notify.isSwitch = result == 2 ? false : true;
                                }
                            }
                        }
                    }
                    models = models.sorted(by: { (curr, next) -> Bool in
                        return curr.id ?? "0" < next.id ?? "0";
                    })
                    result(models);
                    
                }
            }
            
        }
        
        self.tableView.didSelectedCellSubViewCallback = {
            [weak self] (model, flag) in
            
            if flag == 1001 {
                if let _model = model as? PGGroupNotifyManagerModel {
                    
                    let id = Int(_model.id ?? "0")!;
                    PigramNetworkMananger.pg_setGroupNotificationMutes(groupID: self?.groupModel!.groupId ?? "", id: id, action: _model.isSwitch ? 1 : 2, success: { (response) in
                        
                        OWSAlerts.showAlert(title: "操作成功！");
                        self?.groupModel?.notificationMutes["\(id)"] = _model.isSwitch ? 1 : 2;
                        PigramGroupManager.shared.saveGroupModel(groupModel: self?.groupModel);
                        
                    }) { (error) in
                        
                        let oc_error = error as NSError;
                            
                        if oc_error.code == 406 {
                            OWSAlerts.showErrorAlert(message: "您权限不足！");
                        } else {
                            OWSAlerts.showErrorAlert(message: error.localizedDescription);
                        }
                        
                        
                    }
                }
            }
        }
        
        self.tableView.begainRefreshData();
        // Do any additional setup after loading the view.
    }
    

    private lazy var tableView: DYTableView = {
        
        let view = DYTableView.init();
        view.register(TXGroupInfoCell.self, forCellReuseIdentifier: "cell");
        view.backgroundColor = UIColor.groupTableViewBackground;
        view.isShowNoData = false;
        view.rowHeight = 44;
        return view;
        
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
