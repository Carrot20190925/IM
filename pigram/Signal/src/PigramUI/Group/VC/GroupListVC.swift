//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class GroupListModel {
    
    var isSelected: Bool = false;
    let group: TSGroupModel
    
    required init(_ userProfile: TSGroupModel) {
        self.group = userProfile;
    }
    
}

@objcMembers class GroupListVC: BaseVC {
    
    enum ListShowType {
        case list;
        case options;
    }
    
    typealias GroupResultsCallback = (GroupListVC,[TSGroupModel]?) -> Void
    
    var selectedResults:[TSGroupModel]?

    var selectedCallback: GroupResultsCallback?
    
    var filters: [TSGroupModel]?
    
    private var type: ListShowType = .list;
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            self.navigationItem.title = "群聊";
            self.view.addSubview(self.tableView);
        if self.type == .list {
            self.tableView.register(ContactsCell.self, forCellReuseIdentifier: "cell");
            let search = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(searchBtnClick));
            self.navigationItem.rightBarButtonItem = search;
        } else if self.type == .options {
            
            self.tableView.register(ContactListCell.self, forCellReuseIdentifier: "cell");
            self.tableView.mj_header = nil;
//            let search = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(searchBtnClick));
            let done = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(rightBtnClick));
            self.navigationItem.rightBarButtonItem = done;
            
        }
            
            self.tableView.mas_makeConstraints { (make) in
                make?.edges.offset();
            }
            self.tableView.loadDataCallback = {
                [weak self] (_,result) in
                
                self?.loadData({ (results) in
                    result(results);
                })
            };
        self.tableView.loadLocalDataCallback = {
            
            [weak self] (result) in
            self?.loadLocalData(result);
            
        };
            self.tableView.didSelectedTableViewCellCallback = {
                [weak self] (cell,_) in
                
                self?.handleCellDidSelect(cell: cell);
              
                
            }
       

       
        ///本地测试时使用
//        self.tableView.canDeleteCell = true;
//        self.tableView.deleteCellCallback = {
//            (view, indexPath) in
//            if let _model = view.dy_dataSource[indexPath.row] as? TSGroupModel {
//                let thread = TSGroupThread.getOrCreateThread(with: _model);
//                TSGroupThread.databaseStorage.write { (write) in
//                    thread.anyRemove(transaction: write);
//                }
//                view.dy_dataSource.removeObject(at: indexPath.row);
//                view.deleteRows(at: [indexPath], with: .automatic);
//            }
//        };
        
        
        self.tableView.loadLocalData();
        
        
    }
    
    @objc
    private func searchBtnClick() {
        let vc = DYSearchVC.searchVC();
        vc.placeholder = "输入群组名称...";
        
        vc.selectedSearchBtnCallback = {
            (tableView, text) in
            tableView?.loadDataCallback = {
                [weak self] (_, result) in
                
                if let groups = self?.tableView.dy_dataSource as? [TSGroupModel] {
                    
                    let newGroups = groups.filter { (group) -> Bool in
                        
                        if group.groupName?.contains(text) ?? false {
                            return true;
                        }
                        return false
                    }
                    result(newGroups);
                } else {
                    result([]);
                }
                
            };
            tableView?.begainRefreshData();
            
        }
        vc.tableView?.didSelectedTableViewCellCallback = {
            [weak self] (cell, index) in
            
            if let model = cell.model as? TSGroupModel {
                self?.dismiss(animated: false, completion: {
                   self?.pushConversation(model: model);
                });
            }
        };
        vc.tableView?.register(ContactsCell.self, forCellReuseIdentifier: "cell");
        vc.tableView?.rowHeight = 68;
        vc.tableView?.tableFooterView = UIView.init();
        vc.tableView?.separatorColor = UIColor.lightGray;
        vc.tableView?.noDataText = "没有搜索到相关的群组！";
        
        vc.hidesBottomBarWhenPushed = true;
        self.present(vc, animated: true, completion: nil);
    }
    
    public class func showGroupSelectVC(fromVC: UIViewController, filters:[TSGroupModel]?, callback:@escaping GroupResultsCallback) {
        
        let vc = GroupListVC.init();
        vc.navigationItem.title = "选择群聊";
        vc.selectedCallback = callback;
        vc.filters = filters;
        vc.type = .options;
        vc.selectedResults = [];
        let nav = BaseNavigationVC.init(rootViewController: vc);
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "完成", style: .plain, target: vc, action: #selector(rightBtnClick));
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "取消", style: .plain, target: vc, action: #selector(cancleBtnClick));
        
        fromVC.present(nav, animated: true, completion: nil);
        
    }
    @objc
    private func rightBtnClick() {
        
        self.selectedCallback?(self,self.selectedResults);
        
    }
    @objc
    private func cancleBtnClick() {
        
        self.dismiss(animated: true, completion: nil);
        
    }
    private func loadLocalData (_ result: DYTableView_Result) {
    
       
        if self.type == .list {
            
            let models:[TSGroupModel] = self.getAllGroups();
            result(models);
            
        } else if self.type == .options {
            let models:[TSGroupModel] = self.getAllGroups();

            let listModels:[GroupListModel] = models.map({ (_value) -> GroupListModel in
               
                 return GroupListModel.init(_value);
            });
          
            result(listModels);
        }
    
    }
    
    private func loadData (_ result:  @escaping DYTableView_Result) {
        
        PigramNetwork.getMyGroupList { (results, error) in
            var models:[TSGroupModel] = [];
            if let _value = results {
                kSignalDB.write { (write) in
                    for item in _value {
                        let thread = TSGroupThread.getOrCreateThread(with: item, transaction: write);
                        thread.anyUpdateGroupThread(transaction: write) { (thread) in
                            thread.groupModel = item;
                        }
                        if item.txGroupType == TXGroupTypeJoined {
                            models.append(item);
                        }
                    }
                }
            }
           
           models = models.sorted(by: { (last, next) -> Bool in
                
                return last.groupName ?? "0" > next.groupName ?? "0";
            })
            result(models);

        }
        
    }
    
    private func getAllGroups() -> [TSGroupModel] {
        
        var models:[TSGroupModel] = [];
        var threads: [TSThread]?
        kSignalDB.read { (read) in
            threads = TSGroupThread.anyFetchAll(transaction: read);
        }
        
        
        
        
        threads = threads?.filter({ (_value) -> Bool in
                        
            if let groupThread = _value as? TSGroupThread, groupThread.groupModel.txGroupType == TXGroupTypeJoined {
                let isFilter = self.filters?.contains(where: { (model) -> Bool in
                   return model.groupId == groupThread.groupModel.groupId
                }) ?? false
                
                if !isFilter {
                    models.append(groupThread.groupModel);
                }
                return true;
            }
            return false;
        })
     
        models = models.sorted(by: { (last, next) -> Bool in
            
            return last.groupName ?? "0" > next.groupName ?? "0";
        })
        
        return models;
        
    }
    
    private func handleCellDidSelect(cell: DYTableViewCell) {
        
        if let _model = cell.model as? TSGroupModel {
            
            self.pushConversation(model: _model);
            
        } else if let _model = cell.model as? GroupListModel {
            
            _model.isSelected = !_model.isSelected;
            if _model.isSelected {
                self.selectedResults?.append(_model.group);
            } else {
                self.selectedResults = self.selectedResults?.filter({ (model) -> Bool in
                    return model.groupId != _model.group.groupId;
                });
            }
            if let _cell = cell as? ContactListCell {
                _cell.makesButtonSelect(_model.isSelected);
            }
        }
        
        
    }
    
    private func pushConversation(model: TSGroupModel) {
        var thread: TSGroupThread?
         
         TSGroupThread.databaseStorage.write { (write) in
             thread = TSGroupThread.getOrCreateThread(with: model, transaction: write);
         }
         //在群组会话被删除时，是进行的软删除 将该值设置成了false
         if thread?.shouldThreadBeVisible == false {
             TSGroupThread.databaseStorage.write { (write) in
                 thread?.anyUpdateGroupThread(transaction: write, block: { (thread) in
                     thread.shouldThreadBeVisible = true;
                 });
             }
         }
        
         let vc = ConversationViewController.init();
         vc.configure(for: thread!, action: .none, focusMessageId: nil);
        vc.hidesBottomBarWhenPushed = true;
         self.navigationController?.setSecondSubVC(vc);
        
    }
        

        
        private var tableView: DYTableView = {
            
            let view = DYTableView.init();
            view.rowHeight = 68;
            
            view.noDataText = "你还没有进行任何群组";
            return view;
            
        }();

}
