//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXAccountSetController: BaseVC,AvatarViewHelperDelegate {
    
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet var tagLabels: [UILabel]!
    
    @IBOutlet var backViews: [UIView]!
    
    @IBOutlet var contentBtns: [UIButton]!
    var image : UIImage?
    let avatarViewHelper = AvatarViewHelper.init()

    
    
      func avatarActionSheetTitle() -> String? {
          return NSLocalizedString("PROFILE_VIEW_AVATAR_ACTIONSHEET_TITLE", comment: "Action Sheet title prompting the user for a profile avatar")
      }
      func clearAvatarActionLabel() -> String {
          return NSLocalizedString("PROFILE_VIEW_CLEAR_AVATAR",comment: "Label for action that clear's the user's profile avatar");
      }
      func avatarDidChange(_ image: UIImage) {
          let size = CGSize(width: CGFloat.init(kOWSProfileManager_MaxAvatarDiameter) , height: CGFloat.init(kOWSProfileManager_MaxAvatarDiameter))
          let resizeImage = image.resizedImage(toFillPixelSize: size).withRenderingMode(.alwaysOriginal)
          let avatarBtn = self.contentBtns[0]
          ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { (controller) in
            OWSProfileManager.shared().updateLocalProfileName(OWSProfileManager.shared().localProfileName(), avatarImage: resizeImage, success: {
                         let mainQueue = DispatchQueue.main
                         mainQueue.async {
                             controller.dismiss {
                                avatarBtn.setImage(resizeImage, for: .normal)
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
      
      func fromViewController() -> UIViewController {
             return self
         }
         
     func hasClearAvatarAction() -> Bool {
         return true
     }
     
    
     func clearAvatar() {
         self.image = nil
     }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupManager()
        self.setupUI()        
        // Do any additional setup after loading the view.
    }
    
    private func setupUI(){
        self.title = "账号管理"
//        self.back
        for label in self.tagLabels {
            label.textColor = TXTheme.titleColor()
        }
        if !UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 64
        }
        let avatarBtn = self.contentBtns[0]
        avatarBtn.layer.cornerRadius = 20
        avatarBtn.clipsToBounds = true
        let profileNameBtn = self.contentBtns[1]
        profileNameBtn.setTitleColor(TXTheme.titleColor(), for: .normal)
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUIAcion()
    }
    private func updateUIAcion(){
        let localMgr = OWSProfileManager.shared()
        let avatarImage = localMgr.localProfileAvatarImage() ?? OWSContactAvatarBuilder.init(forLocalUserWithDiameter: kLargeAvatarSize).buildDefaultImage()
        let avatarBtn = self.contentBtns[0]
        let profileNameBtn = self.contentBtns[1]
        avatarBtn.setImage(avatarImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        profileNameBtn.setTitle(localMgr.localProfileName(), for: .normal)
    }
    
    private func setupManager(){
        avatarViewHelper.delegate = self
        for (index,object) in self.backViews.enumerated() {
            object.tag = index
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(tap:)))
            object.addGestureRecognizer(tap)
        }
    }
    @objc
    private func tapAction(tap:UITapGestureRecognizer){
        let tag = tap.view?.tag
        switch tag {
        case 0:
            avatarViewHelper.showChangeAvatarUI()
            break
        case 1:
            self.navigationController?.pushViewController(TXEditController.init(), animated: true)
            break
        default:
            break
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
