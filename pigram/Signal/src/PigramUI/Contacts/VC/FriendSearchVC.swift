//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
import Kingfisher

/**
 * 个人信息
 */

@objcMembers class FriendSearchVC: BaseVC {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nickLabel: UILabel!
//    @IBOutlet weak var phoneNumber: UILabel!
    var hideConfirmBtn = false
    
    @objc public var fromGroupId: String?
    
    var phoneNumber : String? {
        
        didSet {
            kSignalDB.read { (read) in
                self.user = OWSUserProfile.getFor(SignalServiceAddress.init(phoneNumber: self.phoneNumber), transaction: read);
            }
            
            self.job = ProfileFetcherJob.init();
        }
        
    }

    public var channel: PigramFriendChannel = .number;
    
    var job: ProfileFetcherJob?
    @IBOutlet weak var confirmBtn: UIButton!
    var user: OWSUserProfile?
    private var isMyFriend: Bool = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 88;
        }
        self.confirmBtn.isHidden = hideConfirmBtn
        if self.user == nil && self.phoneNumber == nil {
            self.confirmBtn.isEnabled = false;
            return;
        }
        
        let more = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-more")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(rightBtnClick));
        if self.user?.relationType == .friend && self.user?.address.userid != TSAccountManager.localUserId {
            self.navigationItem.rightBarButtonItem = more;
        }

        if let model = self.user {
            self.isMyFriend = OWSUserProfile.existMyFriendList(model);        }
        self.confirmBtn.setTitle(self.isMyFriend ? "发送消息" : "添加好友", for: .normal);
        
        if let _phone = self.phoneNumber {
            
            let address = SignalServiceAddress.init(phoneNumber: _phone);
            kSignalDB.write { (write) in
                self.user = OWSUserProfile.getOrBuild(for: address, transaction: write);
            }
            
            if self.user?.profileName == nil {
                ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { (modal) in
                    
                    self.job?.getAndUpdateProfile(address: address) { (result, error) in
                        
                        if result {
                            
                            DispatchQueue.main.async {
                                
                                modal.dismiss {
                                    kSignalDB.read { (read) in
                                        self.user = OWSUserProfile.getFor(address, transaction: read);
                                    }
                                    self.update();
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                
                                modal.dismiss {
                                    OWSAlerts.showErrorAlert(message: error!.localizedDescription);
                                }
                            }
                        }
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateFriendAccept(_ :)), name: NSNotification.Name.kNotification_Friend_Invite_accept, object: nil);
        self.update();
        // Do any additional setup after loading the view.
    }
    
    @objc func updateFriendAccept(_ info: Notification) {
        
        if let _id = info.object as? String {
            
            if _id == self.user?.address.userid {
                self.confirmBtn.setTitle("发送消息", for: .normal);
                self.isMyFriend = true;
            }
            
        }
        
        
    }
    
    private func update() {
        if self.user == nil {
            return;
        }
        self.avatarView.addRounded(radius: self.avatarView.width * 0.5);
        self.nickLabel.text = self.user?.getContactName();
        self.avatarView?.image = self.user?.getContactAvatarImage();
//        self.avatarView.setKingFisherImage(urlStr: self.user?.avatarUrlPath ?? "", placeholder: self.user!.getContactAvatarImage()!);
//        self.phoneNumber.text = "手机号：\(self.user?.address.phoneNumber ?? "")";
    }
  
    
    @objc
    private func rightBtnClick() {
        
        var array = ["设置备注", "加入黑名单"];
        var imgs = ["pigram-contact-remark", "pigram-contact-blocking"]

        if self.user?.relationType == .friend {
            array = ["设置备注", "加入黑名单","删除好友"];
            imgs = ["pigram-contact-remark", "pigram-contact-blocking","pigram-contact-delete"];
        }
        
        var actions:[YCMenuAction] = [];
        for (index,item) in array.enumerated() {
            
            let action = YCMenuAction.init(title: item, image: UIImage.init(named: imgs[index]));
            actions.append(action!);
        }
        let menuView = YCMenuView.menu(with: actions, width: 140, relyonView: self.navigationItem.rightBarButtonItems?.first);
        menuView?.textFont = UIFont.systemFont(ofSize: 13);
        menuView?.textColor = UIColor.hex("#2d4257");
        menuView?.show();
        menuView?.didSelectedCellCallback = {
            [weak self] (view,indexpath) in
            if indexpath?.row == 0 {
                let vc = PigramEditorVC();
                vc.navigationItem.title = "设置备注";
                vc.defaultText = self?.user?.getContactName();
                vc.saveBtnClickCallback = {
                    [weak self] (text) in
                    guard let destinationId = self?.user?.address.phoneNumber else {
                        return
                    }
                    if text.trimmingCharacters(in: .whitespaces).length == 0 {
                        OWSAlerts.showAlert(title: "设置备注不能为空")
                        return
                    }
                    if text.length == 0 {
                        OWSAlerts.showAlert(title: "设置备注不能为空")
                        return
                    }
                    let data = text.data(using: .utf8)
                     guard let  ensureData = data else{
                         OWSAlerts.showAlert(title: "设置备注不能为空")
                         return
                     }
                     if ensureData.count > 26 {
                       OWSAlerts.showAlert(title: "字数不能超过8个汉字！")
                       return
                     }
                    
                    let params = ["destinationId":destinationId,"remarkName":text]
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
                                OWSContactAvatarBuilder.init(address: profile.address, name: profile.remarkName!, colorName: .pigramThemeColor, diameter: 52).updateDefaultImage();
                               
                           }
                            DispatchQueue.main.async {
                                modal.dismiss {
                                    self?.user?.remarkName = text;
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
                
                OWSAlerts.showConfirmationAlert(title: "加入黑名单", message: "加入黑名单，你将不能和对方互发消息。", proceedTitle: "加入") {[weak self](_) in
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
                            if self?.channel == .group {
                                self?.navigationController?.popViewController(animated: true)
                            }else
                            {
                                self?.navigationController?.popToRootViewController(animated: true);

                            }
                        }
                    })
                }
                
            }
            
        };
    }


    @IBAction func confirmBtnClick(_ sender: Any) {
        
        if self.isMyFriend {
            let vc = ConversationViewController.init();
            let thread = TSContactThread.getOrCreateThread(contactAddress: self.user!.address);
            vc.configure(for: thread, action: .none, focusMessageId: nil);
            self.navigationController?.setSecondSubVC(vc);
        } else {
            let vc = FriendSendVerifyVC.init();
            vc.model = self.user;
            vc.fromGroupId = self.fromGroupId;
            vc.channel = self.channel;
            self.navigationController?.pushViewController(vc, animated: true);
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
