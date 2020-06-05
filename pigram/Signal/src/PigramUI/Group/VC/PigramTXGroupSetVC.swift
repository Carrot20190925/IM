//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

/**
 * 群管理界面
 */
class PigramTXGroupSetVC: BaseVC {
    enum SetType {
        case groupMananger //群管理
        case groupBanned //禁言
    }
    var memberType = TXGroupInfoVC.UserType.member
    var setType = SetType.groupMananger
    
    var tableView = UITableView.init(frame: CGRect.init(), style: .plain)
    var viewItems : [[String]] = []
    var thread : TSGroupThread?
    var groupModel : TSGroupModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.white
       
        self.setupNav()
        self.setupTableView()
        self.updateContent();
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateContent), name: .init(Pigram_Group_Status_Change_Notification), object: nil);
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    @objc
    private func updateContent() {
        let blockStrs = self.isBlockAll ?  ["全体禁言"] : ["全体禁言", "群成员禁言"];
        
        switch self.setType {
        case .groupMananger:
            self.title = "群管理"
            if self.memberType == .owner {
                self.viewItems = [["管理员设置"],["转让群"],blockStrs]
            }else{
                self.viewItems = [blockStrs]
            }
            self.viewItems.append(["通知范围管理"]);
        case .groupBanned:
            self.title = "群内禁言"
            self.viewItems = [blockStrs]
        }
        self.tableView.reloadData();
    }
    
    func setupNav() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-leftBack"), style: .plain, target: self, action: #selector(goBack))
    }
    @objc
    func goBack() {
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    /**
     * 是否全部禁言
     */
    private var isBlockAll: Bool {
        get {
            if let _groupModel = self.groupModel {
                for item in _groupModel.permRightBans {
                    if item.permissionType == PigramMemberPerm.text && item.role == 2 {
                        return true;
                    }
                }
            }
            return false;
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /**
     * 处理全体禁言
     */
    private func handleBlockAllConversation(_ btn: UISwitch) {
        
        PigramNetworkMananger.pg_blockAllConversation(groupID: self.groupModel?.groupId ?? "", isBan: btn.isOn, success: { (response) in
            OWSAlerts.showAlert(title: "操作成功！");
        }) { (error) in
            btn.isOn = !btn.isOn;
            let oc_error = error as NSError;
                
            if oc_error.code == 406 {
                OWSAlerts.showErrorAlert(message: "您权限不足！");
            } else {
                OWSAlerts.showErrorAlert(message: error.localizedDescription);
            }
            
        }
    }

}
extension PigramTXGroupSetVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewItems.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = self.viewItems[section]
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TXGroupInfoCell", for: indexPath) as! TXGroupInfoCell
        let items = self.viewItems[indexPath.section]
        let text = items[indexPath.row]
        switch text {
        case "全体禁言":
            cell.showSlider()
            cell.switchAction = {[weak self] on in //全体禁言
                self?.handleBlockAllConversation(on);
            }
            cell.slider.setOn(self.isBlockAll, animated: true);
        default:
            cell.showNextBtn()

        }
        cell.tagLabel.text = text
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let items = self.viewItems[indexPath.section]
        let text = items[indexPath.row]
        switch text {
        case "管理员设置":
            
            TXSetGroupMembersVC.showVC(self, thread: self.thread!, navTitle: "设置管理员", rightNavTitle: "", type: TXSetGroupMembersVC.SetType.managerList) {  (membersVC, members) in
              }
        case "转让群":
            TXSetGroupMembersVC.showVC(self, thread: self.thread!, navTitle: "转让群", rightNavTitle: "", type: TXSetGroupMembersVC.SetType.changeOwner) { [weak self] (membersVC, memembers) in
                if memembers.count != 0,let first = memembers.first{
                    self?.setupChangeOwner(first)
                }
              }
            break
        case "群内禁言":
            TXSetGroupMembersVC.showVC(self, thread: self.thread!, navTitle: "群成员禁言列表", rightNavTitle: "", type: TXSetGroupMembersVC.SetType.bannedList) { (membersVC, memembers) in

              }
            break;
        case "全体禁言":
            
            
            
            break;
        case "群成员禁言":
            TXSetGroupMembersVC.showVC(self, thread: self.thread!, navTitle: "群成员禁言列表", rightNavTitle: "", type: TXSetGroupMembersVC.SetType.bannedList) { (membersVC, memembers) in

              }
            
            break;
        case "通知范围管理":
            
            let vc = PGGroupNotifyManagerVC.init();
            vc.groupModel = self.groupModel;
            self.navigationController?.pushViewController(vc, animated: true);
            
            break;
        default:
            break
        }
    }
    func setupTableView() {
        self.tableView.frame = self.view.bounds
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 50
        self.view.addSubview(self.tableView)
        self.tableView.register(TXGroupInfoCell.self, forCellReuseIdentifier: "TXGroupInfoCell")
        self.tableView.separatorColor = TXTheme.thirdColor()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
//设置群管理
extension PigramTXGroupSetVC{
    
    func setupChangeOwner(_ member:PigramGroupMember) {
        
        guard let model = self.groupModel else {
            return
        }
        
        guard let owner = member.userId else {
            return
        }
        if model.groupOwner != TSAccountManager.localUserId {//不是群主没有权限
            OWSAlerts.showAlert(title: "您没有转让群的权限")
            return
        }

        let params = ["groupId":model.groupId,"newOwnerId":owner]
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
            PigramNetworkMananger.pgTransferGroupNetwork(params: params
                , success: {[weak self] (_) in

                    DispatchQueue.main.async {
                        if let oldOwner = model.member(withUserId: model.groupOwner){
                            oldOwner.perm = 2
                        }
                        if let newOwner = model.member(withUserId: owner){
                            newOwner.perm = 0
                        }
                        model.groupOwner = owner
                        PigramGroupManager.shared.saveGroupModel(groupModel: model)
                        modal.dismiss {
                            NotificationCenter.default.post(name: .init(rawValue: Pigram_Group_Status_Change_Notification), object: model.groupId, userInfo: nil)
                            self?.navigationController?.dismiss(animated: true, completion: nil)
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
