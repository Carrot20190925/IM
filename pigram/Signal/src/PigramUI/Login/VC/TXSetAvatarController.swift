//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXSetAvatarController: TXBaseController,AvatarViewHelperDelegate {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
//    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    let avatarViewHelper = AvatarViewHelper.init()
    @IBOutlet weak var nextBtn: UIButton!
     //    @property (nonatomic, readonly) AvatarViewHelper *avatarViewHelper;

    @IBOutlet var backViews: [UIView]!
    @IBOutlet var subtitleLabels: [UILabel]!
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet weak var tagLabel: UILabel!
    var image : UIImage?
    
    func avatarActionSheetTitle() -> String? {
        return NSLocalizedString("PROFILE_VIEW_AVATAR_ACTIONSHEET_TITLE", comment: "Action Sheet title prompting the user for a profile avatar")
    }
    func clearAvatarActionLabel() -> String {
        return NSLocalizedString("PROFILE_VIEW_CLEAR_AVATAR",comment: "Label for action that clear's the user's profile avatar");
    }
    func avatarDidChange(_ image: UIImage) {
        let imageView = self.imageViews[0]
        imageView.image = image
        let size = CGSize(width: CGFloat.init(kOWSProfileManager_MaxAvatarDiameter) , height: CGFloat.init(kOWSProfileManager_MaxAvatarDiameter))
        self.image = image.resizedImage(toFillPixelSize: size).withRenderingMode(.alwaysOriginal)
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
        self.setupUI()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(showPhotoAction))
        let backView = self.backViews[0]
        backView.addGestureRecognizer(tap)
        avatarViewHelper.delegate = self as AvatarViewHelperDelegate;
        
    }
    private func setupUI(){
        if !UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 111.0
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: kPigramLocalizeString("跳过", "跳过"), style: .plain, target: self, action: #selector(jumpAction))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title:kPigramLocalizeString("取消", "取消") , style: .plain, target: self, action: #selector(jumpAction))

        self.titleLabel.textColor = TXTheme.titleColor()
               self.titleLabel.font = TXTheme.secondTitleFont(size: 23)
        for label in self.subtitleLabels {
            label.textColor = TXTheme.fourthColor()
            label.font = TXTheme.thirdTitleFont(size: 11)
        }
        for imageView in self.imageViews {
            imageView.layer.cornerRadius = 31
            imageView.clipsToBounds = true
            imageView.backgroundColor = TXTheme.fourthColor()
        }
        self.tagLabel.textColor = TXTheme.fourthColor()
        self.tagLabel.font = TXTheme.thirdTitleFont(size: 12)
        self.nextBtn.titleLabel?.font = TXTheme.thirdTitleFont(size: 13)
        self.nextBtn.setTitleColor(TXTheme.titleColor(), for: UIControl.State.normal)
    }
    
    @objc
    private func jumpAction(){
        self.uploadActionFinish()
    }
    @objc
    private func showPhotoAction(){
        avatarViewHelper.showChangeAvatarUI()
    }


//    private func
    @IBAction func nextAction(_ sender: UIButton) {

      
        guard let nickName = self.onboardingController.nickName else {
            return
        }
        if nickName.length > 15 , nickName.length <= 0 {
            return
        }
        guard let image = self.image else {
            OWSAlerts.showAlert(title:kPigramLocalizeString("请选择头像", "请选择头像") ,
                                message: "")

            return
        }
        
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { (controller) in
            OWSProfileManager.shared().updateLocalProfileName(nickName, avatarImage: image, success: {[weak self] in
                let mainQueue = DispatchQueue.main
                mainQueue.async {
                    controller.dismiss {
                        self?.uploadActionFinish()
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
    private func uploadActionFinish(){
        self.onboardingController.onboardingDidPassword(viewController: self)
//        self.onboardingController.on
        
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
