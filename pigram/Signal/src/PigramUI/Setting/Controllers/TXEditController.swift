//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXEditController: BaseVC,UITextFieldDelegate {

    @IBOutlet weak var segmentView: UIView!
    enum EditType {
        case profileName // 个人昵称
        case group //群名称
        case groupNickName //个人在群的昵称
    }
    var type = EditType.profileName
    var complete:((_ name : String,_ editVC:TXEditController) -> Void)?
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        switch self.type {
        case .profileName:
            self.title = "我的昵称"
            let placeholder = NSAttributedString.init(string: "请输入您的昵称，控制在8个字以内", attributes: [NSAttributedString.Key.foregroundColor : TXTheme.titleColor()])
            self.textField.attributedPlaceholder = placeholder
        case .group:
            self.title = "群聊名称"
//            self.textField.pl
            let placeholder = NSAttributedString.init(string: "请输入群名称，控制在12个字以内", attributes: [NSAttributedString.Key.foregroundColor : TXTheme.titleColor()])
            self.textField.attributedPlaceholder = placeholder
        case .groupNickName:
            self.title = "我的群昵称"
            let placeholder = NSAttributedString.init(string: "请输入您群昵称，控制在8个字以内", attributes: [NSAttributedString.Key.foregroundColor : TXTheme.titleColor()])
            self.textField.attributedPlaceholder = placeholder

        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "完成", style: .plain, target: self, action: #selector(didFinishProfileName))
        self.segmentView.backgroundColor = TXTheme.thirdColor()
    }
    @objc
    func didFinishProfileName() {
        self.textField.acceptAutocorrectSuggestion()
        guard let text = self.textField.text?.trimmingCharacters(in: .whitespaces)  else {
            OWSAlerts.showAlert(title: "设置昵称不能为空")
            return
        }
        if text.length == 0 {
           OWSAlerts.showAlert(title: "设置昵称不能为空")
           return
        }
        let data = text.data(using: .utf8)
        guard let  ensureData = data else{
            OWSAlerts.showAlert(title: "设置昵称不能为空")
            return
        }
        if self.type == .group {
            if ensureData.count > 36 {
              OWSAlerts.showAlert(title: "字数不能超过12个汉字！")
              return
            }
        }else{
            if ensureData.count > 26 {
              OWSAlerts.showAlert(title: "字数不能超过8个汉字！")
              return
            }
        }

        if self.type != .profileName {
            self.complete?(text,self)
            return
        }
        
        
        let localMgr = OWSProfileManager.shared()
        let avatarImage = localMgr.localProfileAvatarImage() ?? nil
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { (controller) in
                   OWSProfileManager.shared().updateLocalProfileName(text, avatarImage: avatarImage, success: {[weak self] in
                                let mainQueue = DispatchQueue.main
                                mainQueue.async {
                                    controller.dismiss {
                                       let manager = SSKEnvironment.shared.contactsManager as! OWSContactsManager
                                       let builder =   OWSContactAvatarBuilder.init(forLocalUserWithDiameter: kLargeAvatarSize)
                                        guard let key = builder.cacheKey() as AnyObject? else{
                                            return
                                        }
                                        manager.avatarCache.removeAllImages(forKey: key)
                                        self?.navigationController?.popViewController(animated: true)
                                    }
                                }
                            },failure:{
                                let mainQueue = DispatchQueue.main
                                mainQueue.async {
                                    controller.dismiss {
                                        OWSAlerts.showErrorAlert(message: NSLocalizedString("PROFILE_VIEW_ERROR_UPDATE_FAILED", comment: "Error message shown when a"))
                                    }
                                }
                            })
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
