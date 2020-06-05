//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

@objcMembers class PGGroupInfoVC: BaseVC {

    
    var groupId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onGroupApplyHandledFinished(_:)), name: NSNotification.Name.kNotification_Pigram_Group_Apply_handled_finished, object: nil);

        if self.groupId != nil {
            self.setupSubView();
            self.update();
        }
        self.edgesForExtendedLayout = UIRectEdge.bottom;
        // Do any additional setup after loading the view.
    
    }
    
    @objc
    func onGroupApplyHandledFinished(_ info: NSNotification) {
       
        DispatchQueue.main.async {
            self.update();
        }
               
    }
    
    private func update () {
        guard let group_id = self.groupId else {
            return;
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            
            let groupModel = PigramGroupManager.shared.getGroupModel(groupID: group_id, true);
            
            if groupModel != nil {
                self.updateSubview(groupModel!);
            } else {
                //获取群详情`
                ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
                    PigramNetwork.getGroupInfo(group_id, isNeedMembers: false) { (model, error) in
                        DispatchQueue.main.async {
                            if (error != nil) {
                                modal.dismiss {
                                    OWSAlerts.showAlert(title: error?.localizedDescription);
                                }
                            } else {
                                SVProgressHUD.dismiss();
                                modal.dismiss {
                                    self.updateSubview(model!);
                                }
                            }
                        }
                    }
                }

                
            }
        }
        
    }
    private func updateSubview(_ groupModel: TSGroupModel) {
        self.nameLabel.text = groupModel.groupName;
        if self.nameLabel.text == nil {
            kSignalDB.read { (read) in
                let user = OWSUserProfile.getFor(SignalServiceAddress.init(phoneNumber: groupModel.groupId), transaction: read);
                self.nameLabel.text = user?.getContactName();
            }
        }
        let imageBuilder = OWSGroupAvatarBuilder.init(address: SignalServiceAddress.init(phoneNumber: groupModel.groupId), colorName: .pigramThemeColor, diameter: 52);
        self.avatarView.image = imageBuilder.buildSavedImage();
        if self.avatarView.image == nil {
            self.avatarView.image = imageBuilder.buildDefaultImage();
        }
        if groupModel.txGroupType == TXGroupTypeJoined {
            self.confirmBtn.setTitle("发送消息", for: .normal);
            self.confirmBtn.addTarget(self, action: #selector(onConversation), for: .touchUpInside);
        } else {
            //如果不在 就发送入群申请
            self.confirmBtn.setTitle("加入群聊", for: .normal);
            self.confirmBtn.addTarget(self, action: #selector(onJoinGroup), for: .touchUpInside);
        }
    }
    @objc
    private func onConversation() {
        var thread: TSGroupThread?
        kSignalDB.write { (read) in
            let uniqueID = TSGroupThread.threadId(fromGroupId: self.groupId!);
            thread = TSGroupThread.anyFetch(uniqueId: uniqueID, transaction: read) as? TSGroupThread;
        }
        pg_showConversationVC(fromNavgationVC: self.navigationController!, thread: thread!);
    }
//MARK:-  加入群组
    @objc
    private func onJoinGroup() {
        if self.groupId == nil {
            return;
        }
        
       let params = ["groupId":self.groupId!]
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
            PigramNetworkMananger.pgApplyJoinGroupNetwork(params: params, success: { (_) in
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showAlert(title:  kPigramLocalizeString("已发送入群申请！", nil))
                    }
                }
            }) { (error ) in
                DispatchQueue.main.async {
                    let _error = error as NSError;
                    modal.dismiss {
                        if _error.code == 425 {
                            OWSAlerts.showAlert(title: "您已经加入群组！")
                        } else {
                            OWSAlerts.showErrorAlert(message: error.localizedDescription)
                        }
                    }
                   
                }
            }
        }

    }
      
    
    private func setupSubView() {
        
        self.view.backgroundColor = UIColor.hex("#F0F3F9");
        
        let view = UIView.init();
        view.backgroundColor = UIColor.white;
        view.addSubview(self.avatarView);
        view.addSubview(self.nameLabel);
        
        self.avatarView.mas_makeConstraints { (make) in
            make?.size.offset()(62);
            make?.centerY.offset();
            make?.left.offset()(15);
        }
        self.avatarView.addRound(31);
        self.nameLabel.mas_makeConstraints { (make) in
            make?.centerY.equalTo()(self.avatarView);
            make?.left.equalTo()(self.avatarView.mas_right)?.offset()(10);
            make?.width.offset()(180);
        }
        
        self.view.addSubview(view);
        self.view.addSubview(self.confirmBtn);
        
        view.mas_makeConstraints { (make) in
            make?.left.right()?.top()?.offset();
            make?.height.offset()(118);
        }
        self.confirmBtn.mas_makeConstraints { (make) in
            make?.left.right()?.offset();
            make?.top.equalTo()(view.mas_bottom)?.offset()(15);
            make?.height.offset()(46);
        }
        
    }
    
    
    private lazy var avatarView: AvatarImageView = {
        
        let view = AvatarImageView.init();
                
        return view;
    }()
    
    private lazy var nameLabel: UILabel  = {
        
        let label = UILabel.init()
        label.textColor = UIColor.hex("#273D52");
        label.font = UIFont.systemFont(ofSize: 17);
        return label;
    }()
    
    
    private lazy var confirmBtn: UIButton = {
    
        let btn = UIButton.init();
        btn.backgroundColor = UIColor.white;
        btn.setTitleColor(kPigramThemeColor, for: .normal);
        
        return btn;
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
        
        NotificationCenter.default.removeObserver(self);
        
    }

}
