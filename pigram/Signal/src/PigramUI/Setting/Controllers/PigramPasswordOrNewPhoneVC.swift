//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class PigramPasswordOrNewPhoneVC: TXBaseController {
    
    enum `Type` {
        case changePhone //密码修改手机号
        case changePassword //修改密码
        case resetPhonePassword //通过密码修改手机
        case resetPhoneCode //通过验证码修改手机
    }
    
    var newOboardingController: TXLoginManagerController = TXLoginManagerController.init()

    var type = Type.changePassword
    
    
    @IBOutlet weak var verifityBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    var countryCodeBtn : UIButton?
    var countryState : OnboardingCountryState?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupData()
    }
    
    
    
    
    
    
    private func setupData(){
        switch self.type {
        case .changePhone:
            self.titleLabel.text = "更换手机号"
            self.inputTextField.placeholder = kPigramLocalizeString("请输入您的登录密码", "")
            self.inputTextField.isSecureTextEntry = true
        case .changePassword:
            self.titleLabel.text = "修改密码"
            self.inputTextField.placeholder = kPigramLocalizeString("请输入旧密码", "")
            self.inputTextField.isSecureTextEntry = true

        default:
            self.newOboardingController.update(textCode: self.onboardingController.textCode ?? "")
            let countryCode = "CN"
            let callcode = PhoneNumberUtil.callingCode(fromCountryCode: countryCode)
            let countryname = PhoneNumberUtil.countryName(fromCountryCode: countryCode) ?? ""
            let state = OnboardingCountryState.init(countryName: countryname, callingCode: callcode, countryCode: countryCode)
            self.newOboardingController.update(countryState: state)
            self.titleLabel.text = "更换手机号"
            self.inputTextField.placeholder = kPigramLocalizeString("请输入新的手机号", "")
            self.inputTextField.isSecureTextEntry = false
            let countryCodeBtn = UIButton.init(type: .custom)

            self.inputTextField.leftView = countryCodeBtn
            self.inputTextField.leftViewMode = .always
            countryCodeBtn.addTarget(self, selector: #selector(selectedCountryCode))
            self.countryCodeBtn = countryCodeBtn
            self.updateCountryCode()
        }
    }
    
    
    private  func updateCountryCode(){
        let attri = NSMutableAttributedString.init(string: self.newOboardingController.countryState.callingCode , attributes: [NSAttributedString.Key.foregroundColor : TXTheme.changePhoneSelectedCountryColor()])
        let append = NSAttributedString.init(string: "  |  ", attributes: [NSAttributedString.Key.foregroundColor : TXTheme.changePhoneSegmentLineColor()])
        attri.append(append)
        countryCodeBtn?.titleLabel?.attributedText = attri
        countryCodeBtn?.setAttributedTitle(attri, for: .normal)
        countryCodeBtn?.sizeToFit()
    }

    private func setupUI(){
        self.titleLabel.font = TXTheme.changePasswordTitleFont()
        self.titleLabel.textColor = TXTheme.changePasswordTitleColor()
        self.backView.backgroundColor = TXTheme.changePhoneInputBackColor()
        self.backView.layer.cornerRadius = 25
        self.inputTextField.placeholder = kPigramLocalizeString("请输入您的登录密码", "")
        self.verifityBtn.backgroundColor = TXTheme.changePasswordVerifyBackColor()
        self.verifityBtn.setTitleColor(TXTheme.changePasswordVerifyColor(), for: .normal)
        self.verifityBtn.titleLabel?.font = TXTheme.changePasswordVerifyFont()
        self.verifityBtn.layer.cornerRadius = 17
//        self.phoneDisableBtn.setTitleColor(TXTheme.changePasswordPhoneDisableColor(), for: .normal)
//        self.phoneDisableBtn.titleLabel?.font = TXTheme.changePasswordPhoneDisableFont()
    }

    @IBAction func nextStepAction(_ sender: UIButton) {
        switch self.type {
        case .changePhone:
            self.entryPasswordChangePhone()
        case .changePassword:
            self.recordOldPassword()
        case .resetPhoneCode:
            fallthrough
        case .resetPhonePassword:
            self.parseNewPhoneNum()
        }
    }
    
    
    //MARK:-  进入密码修改手机号界面
    private func entryPasswordChangePhone(){
        guard let password = self.inputTextField.text ,password.count >= 8 else {
            OWSAlerts.showAlert(title: "请输入正确格式的密码")
            return
        }
        
        self.verifyPassword(password: password) {[weak self] in
            guard let weakself = self else{
                return
            }
            weakself.onboardingController.update(textCode: password)
            weakself.onboardingController.entryNewPhoneResetPhoneThroughOldPassword(fromVC: weakself)
        }

    }

    
    private func verifyPassword(password:String, finish :@escaping () -> Void){
        
        
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
            PigramNetworkMananger.pg_VerifyPassword(password, success: {(model) in
                modal.dismiss {
                    finish()
                }
            }) {(error) in
                modal.dismiss {
                    OWSAlerts.showErrorAlert(message: "密码校验失败")
                }
            }
        }

    }
    
    
    
    
    
    
    
    //MARK:-  通过旧手机验证码 更换手机号
    private func changePhoneWithCode(){
        self.newOboardingController.requestNewPhoneCodeChangePhoneWithCode(fromVC: self)
    }
    //MARK:-  通过密码更换手机号
    private func changePhoneWithPassword(){
        self.newOboardingController.requestNewPhoneCodeChangePhoneWithPassword(fromVC: self)
    }
    
    private func parseNewPhoneNum() {
           guard let phoneNumberText = inputTextField.text?.ows_stripped(),
               phoneNumberText.count > 0 else {
                   OWSAlerts.showAlert(title:
                       NSLocalizedString("REGISTRATION_VIEW_NO_PHONE_NUMBER_ALERT_TITLE",
                                         comment: "Title of alert indicating that users needs to enter a phone number to register."),
                       message:
                       NSLocalizedString("REGISTRATION_VIEW_NO_PHONE_NUMBER_ALERT_MESSAGE",
                                         comment: "Message of alert indicating that users needs to enter a phone number to register."))
                   return
           }
        
           let callingCode = newOboardingController.countryState.callingCode
           let phoneNumber = "\(callingCode)\(phoneNumberText)"
           guard let localNumber = PhoneNumber.tryParsePhoneNumber(fromUserSpecifiedText: phoneNumber),
               localNumber.toE164().count > 0, PhoneNumberValidator().isValidForRegistration(phoneNumber: localNumber) else {
                   OWSAlerts.showAlert(title:
                       NSLocalizedString("REGISTRATION_VIEW_INVALID_PHONE_NUMBER_ALERT_TITLE",
                                         comment: "Title of alert indicating that users needs to enter a valid phone number to register."),
                       message:
                       NSLocalizedString("REGISTRATION_VIEW_INVALID_PHONE_NUMBER_ALERT_MESSAGE",
                                         comment: "Message of alert indicating that users needs to enter a valid phone number to register."))
                   return
           }
           let e164PhoneNumber = localNumber.toE164()
           newOboardingController.update(phoneNumber: OnboardingPhoneNumber(e164: e164PhoneNumber, userInput: phoneNumberText))
            if self.type == .resetPhoneCode{
                self.changePhoneWithCode()
            }else {
                self.changePhoneWithPassword()
            }
    }
    
    private func recordOldPassword(){
        guard let password = self.inputTextField.text ,password.count >= 8 else {
            OWSAlerts.showAlert(title: "请输入正确格式的密码")
            return
        }
        self.verifyPassword(password: password) {[weak self] in
            guard let weakself = self else{
                return
            }
            weakself.onboardingController.update(textCode: password)
            weakself.onboardingController.entryResetPasswordThroughOldPassword(fromVC: weakself)
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

extension PigramPasswordOrNewPhoneVC : CountryCodeViewControllerDelegate{
     @objc func selectedCountryCode(){
             let countryCodeController = CountryCodeViewController()
             countryCodeController.countryCodeDelegate = self
             countryCodeController.interfaceOrientationMask = .portrait
             let navigationController = OWSNavigationController(rootViewController: countryCodeController)
             self.present(navigationController, animated: true, completion: nil)
    }
         
     func countryCodeViewController(_ vc: CountryCodeViewController, didSelectCountryCode countryCode: String, countryName: String, callingCode: String) {
         self.updatePhoneNumer(countryCode: countryCode, callingCode: callingCode)
     }
     
     private func updatePhoneNumer(countryCode:String,callingCode: String)
     {
         guard let countryName = PhoneNumberUtil.countryName(fromCountryCode: countryCode) else {
             return
         }

        let countryState = OnboardingCountryState(countryName: countryName, callingCode: callingCode, countryCode: countryCode)
        newOboardingController.update(countryState: countryState)
        self.updateCountryCode()
     }
}
