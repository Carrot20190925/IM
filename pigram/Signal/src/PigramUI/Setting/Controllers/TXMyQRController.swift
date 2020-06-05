//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXMyQRController: BaseVC {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var QRImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
   
    private func setupUI() {
        if UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 108.0
        }
        let localMgr = OWSProfileManager.shared()

        self.title = "二维码"
        
        let content = TSAccountManager.localUserId ?? ""
        let name = localMgr.localProfileName() ?? ""
        let jsonString = "pigram://p.land?u=\(content)"
        let image = TXTheme.getQRCodeImage(jsonString, fgImage: nil)
        self.avatarImageView.layer.cornerRadius = 25
        self.avatarImageView.clipsToBounds = true
        self.saveBtn.layer.cornerRadius = 20
        self.saveBtn.clipsToBounds = true
        self.backView.backgroundColor = TXTheme.thirdColor()
        self.profileNameLabel.textColor = TXTheme.titleColor()
        self.tagLabel.textColor = TXTheme.titleColor()
        self.saveBtn.setTitleColor(UIColor.white, for: .normal)
        self.saveBtn.backgroundColor = TXTheme.secondColor()
        self.QRImageView.image = image
        self.QRImageView.backgroundColor = UIColor.clear
        let avatarImage = localMgr.localProfileAvatarImage() ?? OWSContactAvatarBuilder.init(forLocalUserWithDiameter: kLargeAvatarSize).buildDefaultImage()
        self.avatarImageView.image = avatarImage
        self.profileNameLabel.text = name
        
        
    }
    @IBAction func saveLibraryAction(_ sender: UIButton) {
        guard let _ = self.QRImageView.image else {
            OWSAlerts.showAlert(title: "没有要保存到图片")
            return
        }
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0.0)
        if let  context = UIGraphicsGetCurrentContext(){
            self.view.layer.render(in: context)

            if let viewImage = UIGraphicsGetImageFromCurrentImageContext(){
                TXTheme.saveImage(image: viewImage)
            }
        }
        UIGraphicsEndImageContext();//移除栈顶的基于当前位图的图形上下文
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
