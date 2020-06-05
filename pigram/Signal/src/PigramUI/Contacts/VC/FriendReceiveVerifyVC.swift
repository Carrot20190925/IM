//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class FriendReceiveVerifyVC: BaseVC {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var friend: PigramVerifyModel?{
        didSet {
            kSignalDB.read { (read) in
                let address = SignalServiceAddress.init(phoneNumber: self.friend?.applyId);
                self.user = OWSUserProfile.getFor(address, transaction: read);
            }
        }
    }
    private var user: OWSUserProfile?;
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nickLabel: UILabel!
    private var verifyInfoTextView: UITextView?
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 88
        }
//        self.verifyInfoTextView.isEditable = false
        self.avatarView.addRounded(radius: self.avatarView.width * 0.5);
        let more = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-more")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(rightBtnClick));
        if self.user?.relationType == .friend {
            self.navigationItem.rightBarButtonItem = more;
        }
        self.verifyInfoTextView = UITextView.init();
        self.verifyInfoTextView?.isEditable = false;
        self.verifyInfoTextView?.backgroundColor = UIColor.groupTableViewBackground;
        self.contentView.addSubview(self.verifyInfoTextView!);
        self.verifyInfoTextView?.mas_makeConstraints({ (make) in
            
            make?.right.offset()(-10);
            make?.left.equalTo()(self.avatarView.mas_right)?.offset()(10);
            make?.height.offset()(80);
            make?.bottom.offset()(-20);
            
        })
        self.update()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.verifyInfoTextView?.setContentOffset(CGPoint.zero, animated: false)

    }
    
    private func update() {
        if let user = self.user {
            self.avatarView.image = user.getContactAvatarImage();
            self.nickLabel.text = user.getContactName();
            self.verifyInfoTextView?.text = self.friend?.content;
//            self.verifyInfoTextView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    @objc
    func rightBtnClick() {
        let array = ["设置备注", "加入黑名单"];
        let imgs = ["pigram-contact-remark", "pigram-contact-blocking"]
        
        
        var actions:[YCMenuAction] = [];
        for (index,item) in array.enumerated() {
            
            let action = YCMenuAction.init(title: item, image: UIImage.init(named: imgs[index]));
            actions.append(action!);
        }
        
        let menuView = YCMenuView.menu(with: actions, width: 120, relyonView: self.navigationItem.rightBarButtonItems?.first);
        menuView?.textFont = UIFont.systemFont(ofSize: 14);
        menuView?.textColor = UIColor.hex("#2d4257");
        menuView?.show();
        menuView?.didSelectedCellCallback = {
            [weak self] (view,indexpath) in
            
            if indexpath?.row == 0 {
                
                let user = self?.user;
                let vc = PigramEditorVC();
                vc.navigationItem.title = "设置备注";
                vc.defaultText = user?.getContactName();
                
                vc.saveBtnClickCallback = {
                    [weak self] (text) in
                    guard let destinationId = self?.user?.address.phoneNumber else {
                        return
                    }
                    let remarkName = text.trimmingCharacters(in: .whitespaces)
                    guard let data = remarkName.data(using: .utf8) else {
                        OWSAlerts.showAlert(title: "请设置正确备注")
                        return
                    }
                    if data.count > 26 {
                        OWSAlerts.showAlert(title: "备注名称太长，最多8个字")
                        return
                    }
                    
                    let params = ["destinationId":destinationId,"remarkName":remarkName]
                    guard let weakSelf = self else {
                        return
                    }
                    ModalActivityIndicatorViewController.present(fromViewController: weakSelf, canCancel: true) { (modal) in
                        PigramNetworkMananger.pgUpdateFriendRemarkNameNetwork(params: params, success: { (_) in
                           kSignalDB.write { (write) in
                               let profile = OWSUserProfile.getOrBuild(for: SignalServiceAddress.init(phoneNumber: destinationId), transaction: write)
                               profile.anyUpdate(transaction: write) { (profile) in
                                   profile.remarkName = text
                               }
                           }
                            DispatchQueue.main.async {
                                modal.dismiss {
                                    self?.update()
                                    self?.navigationController?.popViewController(animated: true)
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
                self?.navigationController?.pushViewController(vc, animated: true);
                
            } else if indexpath?.row == 1 {
                
                OWSAlerts.showConfirmationAlert(title: "加入黑名单", message: "加入黑名单，你将不能和对方互发消息。", proceedTitle: "加入") {[weak self] (_) in
                    guard let userId = self?.user?.address.userid else{
                        return
                    }
                    let destinationIds = [userId]
                    let params = ["destinationIds":destinationIds]
                    guard let weakSelf = self else{
                        return
                    }
                    ModalActivityIndicatorViewController.present(fromViewController: weakSelf, canCancel: true) { (modal) in
                        PigramNetworkMananger.pgAddUserBlackListNetwork(params: params, success: { (_) in
                            let address = SignalServiceAddress.init(phoneNumber: userId)
                            SSKEnvironment.shared.blockingManager.addBlockedAddress(address);
                            SSKEnvironment.shared.databaseStorage.write { (write) in
                                let profile = OWSUserProfile.getOrBuild(for: address, transaction: write)
                                profile.anyUpdate(transaction: write) { (profile) in
                                    profile.relationType = .block
                                }
                            }
                            DispatchQueue.main.async {
                                modal.dismiss {
                                    self?.navigationController?.popToRootViewController(animated: true)
                                    OWSAlerts.showAlert(title: "设置成功")
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
                
            } else if indexpath?.row == 2 {
                
                OWSAlerts.showConfirmationAlert(title: "删除好友", message: "是否确定删除好友", proceedTitle: "删除") { (_) in
                    self?.user?.deleteFromFriendList({ (result) in
                        if result {
                            self?.navigationController?.popToRootViewController(animated: true);
                        }
                    })
                }
                
            }
            
        };
    }

    @IBAction func confirmBtnCLick(_ sender: Any) {
        if let address = self.friend?.applyAddress {
            
            ModalActivityIndicatorViewController.present(fromViewController: self.navigationController ?? self, canCancel: true) { [weak self] modal in
                SSKEnvironment.shared.contactsUpdater.sendFriendInviteWithRecipient(address, action: .accept, channel: self?.friend?.channelType ?? .number, content: nil, note: nil, success: {

                    DispatchQueue.main.async {
                        modal.dismiss {
                            let thread = TSContactThread.getOrCreateThread(contactAddress: address);
                            let infoMessage = TSInfoMessage.init(timestamp: NSDate.ows_millisecondTimeStamp(), in: thread, messageType: TSInfoMessageType.typeGroupUpdate, customMessage: "你同意了对方的好友验证，你们已经成为好友啦！");
                            kSignalDB.asyncWrite { (write) in
                                infoMessage.anyInsert(transaction: write);
                            }
                            let vc = ConversationViewController.init();
                            vc.configure(for: thread, action: .none, focusMessageId: nil);
                            vc.hidesBottomBarWhenPushed = true
                            self?.navigationController?.setSecondSubVC(vc);
                        }
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        modal.dismiss {
                            OWSAlerts.showErrorAlert(message: error.localizedDescription);
                        }
                    }
                }
                
             
            };
         
           
           
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

}


extension FriendReceiveVerifyVC:UITextViewDelegate{
//    func addDelegate() {
//        self.verifyInfoTextView.delegate = self;
//    }

    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y != 0 {
//            scrollView.setContentOffset(CGPoint.zero, animated: false)
//        }
//    }
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//
//    }
    
    
}
