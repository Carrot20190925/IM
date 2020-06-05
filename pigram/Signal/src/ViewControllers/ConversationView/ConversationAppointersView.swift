//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

@objc public
class ConversationAppointersView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private var members: NSMutableArray
    
    @objc public var selectedCell: ((_ result:PigramGroupMember) -> Void)?
  
    
    
    private var memberCountInGroup: Int;
    private let groupId: String
    
    private var isNeedSearch: Bool = true;
    
    @objc
    required init(members: [PigramGroupMember]?, memberCount: Int, groupId: String) {
        self.members = NSMutableArray.init(array: members ?? []);
        self.memberCountInGroup = memberCount;
        self.groupId = groupId;
        super.init(frame: CGRect.zero);
        self.addSubview(self.tableView);
        
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        self.tableView.loadDataCallback = {
            [weak self] (_, result) in
            
            if self?.memberCountInGroup != self?.members.count {
                
                PigramNetworkMananger.pgFindGroupMemberNetwork(params: ["group_id": self?.groupId ?? "","limit": "50", "offset" : "0"], success: { (response) in
                    
                    if let array = response as? [Any] {
                        
                        var members = TSGroupModel.pg_initGroupMembers(array);
                        if members?.count ?? 0 < 50 {
                            SSKEnvironment.shared.databaseStorage.write { (transaction) in
                                if members?.count ?? 0 > 0 {
                                    let thread = TSGroupThread.getOrCreateThread(withGroupId: self?.groupId ?? "", transaction: transaction);
                                    thread.anyUpdateGroupThread(transaction: transaction) { (thread) in
                                        thread.groupModel.allMembers = members ?? [];
                                    }
                                }
                            }
                            self?.memberCountInGroup = members?.count ?? self?.memberCountInGroup ?? 0;
                            self?.isNeedSearch = false;
                        }
                        members = members?.filter({ (member) -> Bool in
                            return member.userId != TSAccountManager.localUserId;
                        })
                        self?.members = NSMutableArray.init(array: members ?? []);
                        result(members ?? []);
                    } else {
                        result([]);
                    }
                    
                }) { (error) in
                    result([]);
                }

                
            } else {
                self?.isNeedSearch = false;
                let members = members?.filter({ (member) -> Bool in
                    return member.userId != TSAccountManager.localUserId;
                })
                self?.members = NSMutableArray.init(array: members ?? []);
                result(members ?? []);
            }
                    
        }
        self.tableView.didSelectedTableViewCellCallback = {
            [weak self] (view, index) in
            if let model = view.model as? PigramGroupMember {
                self?.selectedCell?(model);
            }
            self?.removeFromSuperview();
        }
        if self.memberCountInGroup == self.members.count {
            self.tableView.banRefresh();
        }
        
        self.tableView.begainRefreshData();
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc
    public func updateContent(for text:String) {
        if text.length == 0 {
            self.tableView.dy_dataSource = self.members;
            self.tableView.reloadData();
            return;
        }
        if self.isNeedSearch {
            PigramNetworkMananger.pgFindGroupMemberNetwork(params: ["group_id": self.groupId,"limit": "20", "offset" : "0", "name": text], success: { (response) in
                if let array = response as? [Any] {
                    var members = TSGroupModel.pg_initGroupMembers(array);
                    members = members?.filter({ (member) -> Bool in
                        return member.userId != TSAccountManager.localUserId;
                    })
                    self.tableView.dy_dataSource = NSMutableArray.init(array: members ?? []);
                    self.tableView.reloadData();
                }
                
            }) { (error) in
                
                
            }
            
        } else {
            if let members = self.members as? [PigramGroupMember] {
                let newMembers = members.filter { (member) -> Bool in
                    if member.getRemarkNameInfo().contains(text) && member.userId != TSAccountManager.localUserId {
                        return true;
                    }
                    return false
                }
                self.tableView.dy_dataSource = NSMutableArray.init(array: newMembers);
                self.tableView.reloadData();
            }
        }
        
    }
    
    
    private lazy var tableView: DYTableView =  {
        
        let view = DYTableView.init();
        view.register(ContactListCell.self, forCellReuseIdentifier: "cell");
        view.rowHeight = 44;
        view.separatorColor = .clear;
        view.noDataText = "没有可选的用户";
        return view;
        
    }()

}
