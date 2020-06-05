//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
@objc
enum GroupType : Int{
    case normal
    case optional
}
@objcMembers
class PGGroupsVC: BaseVC {


    var type = GroupType.normal
    var finishAction : (([TSGroupModel], PGGroupsVC) -> Void)?
    static func showSeletedGroupsVC(fromVC : UINavigationController ,finishAction : @escaping ([TSGroupModel],PGGroupsVC) -> Void){
        let pgVC = PGGroupsVC.init()
        pgVC.type = .optional
        pgVC.finishAction = finishAction
        fromVC.pushViewController(pgVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "群组";
        self.view.addSubview(self.tableView);
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset()(0);
        }
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        if self.type == .normal {
            let more = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-more")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(moreBtnClick));
            self.navigationItem.rightBarButtonItem = more;
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "完成", style: .plain, target: self, action: #selector(selectedFinish))
        }

        self.loadDataAction()
        self.tableView.begainRefreshData();
        // Do any additional setup after loading the view.
    }
    

    
    
    func loadDataAction()  {
        
        
        
        

        
        
        self.tableView.loadDataCallback = {
            [weak self] (_, result) in
            
            PigramNetworkMananger.pg_groups_getAllGroups(success: { (response) in
                
                if let value = response as? [[String : Any]] {
                    self?.groups.removeAll();
                    for item in value {
                        let model = PGGroupsSectionModel.init(dict: item)
                        self?.groups.append(model);
                    }
                    result(self?.groups ?? []);
                    
                } else {
                    result(self?.groups ?? []);
                }
                
            }) { (error) in
                result(self?.groups ?? []);
            }
        }
    }
    

    
    private lazy var tableView: DYTableView = {
       
        let view = DYTableView.init();
        view.isShowNoData = true;
        view.noDataText = "您现在群组空空如也哦";
        view.register(ContactsCell.self, forCellReuseIdentifier: "cell");
        view.rowHeight = 68;
        view.tableFooterView = UIView.init();
        view.separatorColor = UIColor.lightGray;
        view.register(PGGroupsHeaderView.self, forHeaderFooterViewReuseIdentifier: "header");
        return view;
        
    }();
    
    
    @objc
    func selectedFinish(){
        var models : [TSGroupModel] = []
        for item in self.groups {
            if item.isUnfold {
                for model in item.groupModels {
                    models.append(model)
                }
            }
        }
        self.finishAction?(models,self)
    }
    //MARK:-  更多
    @objc
    private func moreBtnClick() {
        
        
        
        let array = ["添加群分组"];
        let imgs = ["pg-groups-add"];
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
                OWSAlerts.showEditAlert(fromVC: self.navigationController ?? self, title: "添加群分组名称", message: "", placeholder: "请输入群分组名称") { (text) in
                    self.addNewGroups(name: text);
                }
                break;
            default:
                break;
            }
        }
    }
    
    private func addNewGroups(name: String) {
        var filters : [TSGroupModel] = []
        for group in self.groups {
            for item in group.groupModels {
                filters.append(item)
            }
        }
        GroupListVC.showGroupSelectVC(fromVC: self.navigationController ?? self, filters: filters) { (listVC, models) in
            if models?.count ?? 0 > 0 {
                self.createNewGroups(listVC:listVC,name: name,models: models!);
            }
        }
        
    }
    
    private func createNewGroups(listVC: GroupListVC,name: String,models: [TSGroupModel]) {
        
        let ids = models.map { (model) -> String in
            return model.groupId;
        }
        ModalActivityIndicatorViewController.present(fromViewController: listVC, canCancel: false) { (modal) in
            PigramNetworkMananger.pg_groups_createGroups(name: name, ids: ids, success: { (response) in
                
                modal.dismiss {
                    if let _value = response as? [String : Any] {
                        let model = PGGroupsSectionModel.init(dict: _value);
                        self.groups.append(model);
                        self.tableView.reloadData();
                        listVC.dismiss(animated: true, completion: nil);
                    } else {
                        OWSAlerts.showAlert(title: "服务端数据错误！");
                    }
                }
                
            }) { (error) in
                
                modal.dismiss {
                    OWSAlerts.showAlert(title: error.localizedDescription);
                }
            }
            
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
    private var groups: [PGGroupsSectionModel] = [];

}

extension PGGroupsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groups.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.type == .normal {
            let model: PGGroupsSectionModel = self.groups[section];
            return model.isUnfold ? model.groupModels.count : 0;
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ContactsCell;
        
        let model = self.groups[indexPath.section].groupModels[indexPath.row];
        
        cell?.model = model as AnyObject?;
        cell?.longTapAction = {[weak self] cell in
            guard let index = self?.tableView.indexPath(for: cell) else{
                return
            }
            guard let model = cell.model as? TSGroupModel else {
                return
            }
            self?.removeGroup(groupModel: model, indexPath: index)
        }
        return cell!;
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {


        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? PGGroupsHeaderView;
        
        header?.model = self.groups[section];

        header?.tapClickBlock = {
            [weak self] in
            
            self?.tableView.reloadSections(IndexSet.init(integer: section), with: .automatic);
        };
        
        if self.type == .normal {
            header?.setArrowImage(nomal: true)
            header?.longTapClickBlock = {
                [weak self] (view) in
                self?.editGroups(view);
            }
        }else{
            header?.setArrowImage(nomal: false)

        }

        
        return header;

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55;
    }
    

    //MARK:-  移除群聊
    private func removeGroup(groupModel : TSGroupModel,indexPath: IndexPath){
        guard let model = self.groups[indexPath.section] as PGGroupsSectionModel? else {
            return
        }
        guard let groupsId = model.groupsId else{
            return
        }
        let ids = [groupModel.groupId]
        TXTheme.alertActionWithMessage(title: "提示", message: "确定将\(groupModel.groupName ?? "")从群组中移除", fromController: self) {
            ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { [weak self] (modal) in
                guard let weakSelf = self else{
                    return
                }
                PigramNetworkMananger.pg_groups_removeSession(groupsID: groupsId, ids: ids, success: { (response) in
                    modal.dismiss {
                        model.removeModel(groupModel: groupModel)
                        weakSelf.tableView.reloadData()
                    }
                }) { (error) in
                    modal.dismiss {
                        weakSelf.view.makeToast("添加失败")
                    }
                }
            }
            
        }
    }
    
    
    ///编辑群组
    private func editGroups(_ headView: PGGroupsHeaderView) {
        
        guard let groupsModel = headView.model else {
            return
        }
        
        let array = ["添加群聊", "删除群组"];
        let imgs = ["pigram-groups-add","pigram-groups-delete"];
        var actions:[YCMenuAction] = [];
        for (index,item) in array.enumerated() {
            let action = YCMenuAction.init(title: item, image: UIImage.init(named: imgs[index]));
            actions.append(action!);
        }
        
        let menuView = YCMenuView.menu(with: actions, width: 150, relyonView: headView);
        menuView?.textFont = UIFont.systemFont(ofSize: 14);
        menuView?.textColor = UIColor.hex("#2d4257");
        menuView?.show();
        menuView?.didSelectedCellCallback = {[weak self]
            (menu,indexpath) in
            guard let weakSelf = self else {
                return
            }
            
            guard let groupsId = groupsModel.groupsId else{
                return
            }
            switch indexpath?.row {
            case 0:
                
                var filters : [TSGroupModel] = []
                for group in weakSelf.groups {
                    for item in group.groupModels {
                        filters.append(item)
                    }
                }
                GroupListVC.showGroupSelectVC(fromVC: weakSelf.navigationController ?? weakSelf, filters: filters) { (listVC, models) in
                    if models?.count ?? 0 > 0 {

                        var ids : [String] = []
                        for item in models! {
                            if let groupId = item.groupId as String?  {
                                ids.append(groupId)
                            }
                        }
                        ModalActivityIndicatorViewController.present(fromViewController: listVC, canCancel: true) { (modal) in
                            PigramNetworkMananger.pg_groups_addNewSession(groupsID: groupsId, ids: ids, success: { (response) in
                                modal.dismiss {
                                    weakSelf.tableView.begainRefreshData()
                                    listVC.dismiss(animated: true, completion: nil)
                                }
                            }) { (error) in
                                modal.dismiss {
                                    weakSelf.view.makeToast("添加失败")
                                }
                            }
                        }
                    }
                }
                break;
            default:
                TXTheme.alertActionWithMessage(title: "提示", message: "确定删除群组\(groupsModel.groupsName ?? "")", fromController: weakSelf) {
                    ModalActivityIndicatorViewController.present(fromViewController: weakSelf, canCancel: true) { (modal) in
                        PigramNetworkMananger.pg_groups_removeGroups(groupsID: groupsId, success: { (_) in
                            modal.dismiss {
                                weakSelf.tableView.begainRefreshData()
                            }
                        }) { (_) in
                            modal.dismiss {
                                weakSelf.view.makeToast("删除失败")
                            }
                        }
                    }

                }
                break;
            }
        }
        
    }
}
