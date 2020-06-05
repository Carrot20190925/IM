//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
class PigramSetPasswordOrPhoneVC: TXBaseController {

    enum `Type` {
        case changePassword
        case changePhone
    }
    var type = Type.changePassword
    @IBOutlet weak var phoneDisableBtn: UIButton!
    @IBOutlet weak var verifityBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var phoneNumLabel: UILabel!
    var phoneNumber : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupData()
        
        // Do any additional setup after loading the view.
    }
    
    private func setupData(){
        self.tagLabel.text = "验证码将通过短信发送至："
        if self.type == .changePassword {
            self.titleLabel.text = kPigramLocalizeString("修改密码", "")
        }else{
            self.titleLabel.text = kPigramLocalizeString("更换手机号", "")
        }
        
        let attributes = [NSAttributedString.Key.foregroundColor:TXTheme.secondColor(),NSAttributedString.Key.font:TXTheme.secondTitleFont(size: 23),NSAttributedString.Key.baselineOffset:NSNumber.init(value: -3)]
        let attriText = NSMutableAttributedString.init(string: "• ", attributes: attributes)
        
        
        let stringText = " " + self.onboardingController.countryState.callingCode + " " + TXTheme.phoneNumFormartString(string: (self.onboardingController.phoneNumber?.userInput ?? ""))
        let phoneText = NSAttributedString.init(string: stringText)
        attriText.append(phoneText)
        self.phoneNumLabel.attributedText = attriText
    }
    
    
    
    private func setupUI(){
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "register_goback"), style: .plain, target: self, action: #selector(goBackAction))
        self.titleLabel.font = TXTheme.changePasswordTitleFont()
        self.titleLabel.textColor = TXTheme.changePasswordTitleColor()
        self.tagLabel.font = TXTheme.changePasswordDescFont()
        self.tagLabel.textColor = TXTheme.changePasswordDescColor()
        self.phoneNumLabel.font = TXTheme.changePasswordPhoneFont()
        self.phoneNumLabel.textColor = TXTheme.changePasswordPhoneColor()
        self.verifityBtn.backgroundColor = TXTheme.changePasswordVerifyBackColor()
        self.verifityBtn.setTitleColor(TXTheme.changePasswordVerifyColor(), for: .normal)
        self.verifityBtn.titleLabel?.font = TXTheme.changePasswordVerifyFont()
        self.verifityBtn.layer.cornerRadius = 17
        self.phoneDisableBtn.setTitleColor(TXTheme.changePasswordPhoneDisableColor(), for: .normal)
        self.phoneDisableBtn.titleLabel?.font = TXTheme.changePasswordPhoneDisableFont()
    }
    @objc func goBackAction(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func phoneNumDisabled(_ sender: UIButton) {
        if self.type == .changePassword {
            self.onboardingController.oldPasswordChangePassword(fromVC: self)

        }else{
            self.onboardingController.entryResetPhoneThroughOldPassword(fromVC: self)
        }
    }
    @IBAction func clickAction(_ sender: UIButton) {
        if self.type == .changePassword {
            self.onboardingController.verifyCodeChangePassword(fromVC: self)

        }else{
            self.onboardingController.verifyCodeChangePhone(fromVC: self)
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
