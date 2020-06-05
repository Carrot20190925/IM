//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
//import
class TXRegisterController: TXBaseController,CountryCodeViewControllerDelegate {
//    var userState: TXUserState =
    var isShowChangeBtn = true
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerTagLabel: UILabel!
    @IBOutlet weak var registerTitleLabel: UILabel!
    @IBOutlet weak var nextBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var contryCodeLabel: UILabel!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    var state : TXLoginManagerController.TXUserState = .isRegister
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
    }
    
    private func setupInit(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowAction(noti:)), name: UIResponder.keyboardWillShowNotification, object:  nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "register_goback"), style: .plain, target: self, action: #selector(goback))
        self.setupUI()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapCountryCodeViewAction))
        var countryCode = "CN"
        var countryCallingCode = PhoneNumberUtil.callingCode(fromCountryCode: countryCode)

        self.backView.addGestureRecognizer(tap)
        
        if let dic = UserDefaults.standard.object(forKey: "pigram_last_regsiter_login_country_code_and_num") as? [String : String]{
            if let lastRegisteredCountryCode = dic["countryCode"],lastRegisteredCountryCode.length > 0  {
                countryCode = lastRegisteredCountryCode
                countryCallingCode = PhoneNumberUtil.callingCode(fromCountryCode: countryCode)

            }
            if let phoneNumber = dic["phoneNum"],phoneNumber.length > 0  {
                self.phoneNumberTF.text = phoneNumber
                self.onboardingController.update(phoneNumber: OnboardingPhoneNumber.init(e164: countryCallingCode + phoneNumber, userInput: phoneNumber))
            }
        }

        self.updatePhoneNumer(countryCode: countryCode, callingCode: countryCallingCode)
    }
    @objc
    private func keyboardShowAction(noti: Notification){
        print(noti.userInfo ?? "")
        let userInfo = noti.userInfo! as Dictionary
        let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyBoardRect = value.cgRectValue
              // 得到键盘高度
        let keyBoardHeight = keyBoardRect.size.height
              // 得到键盘弹出所需时间
       self.nextBottomContraint.constant = keyBoardHeight
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.phoneNumberTF.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.phoneNumberTF.resignFirstResponder()
    }
    @objc
    private func goback(){
        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }
    private func setupUI(){
        if !UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 111.0
        }
        self.registerTitleLabel.font = TXTheme.secondTitleFont(size: 23)
        self.registerTitleLabel.textColor = TXTheme.titleColor()
        self.registerTagLabel.font = TXTheme.thirdTitleFont(size: 12)
        self.registerTagLabel.textColor = TXTheme.fourthColor()
        self.backView.backgroundColor = TXTheme.thirdColor()
        self.contryCodeLabel.font = TXTheme.thirdTitleFont(size: 12)
        self.contryCodeLabel.textColor = TXTheme.titleColor()
        self.loginBtn.setTitleColor(TXTheme.secondColor(), for: .normal)
        self.loginBtn.titleLabel?.font = TXTheme.thirdTitleFont(size: 13)
        self.nextBtn.titleLabel?.font = TXTheme.thirdTitleFont(size: 13)
        self.nextBtn.setTitleColor(TXTheme.titleColor(), for: UIControl.State.normal)
        self.backView.layer.cornerRadius = 25;
        self.backView.clipsToBounds = true
        self.updateUIAction()
        
    }
    private func updateUIAction(){
        switch state {
           case .isRegister:
           break
           case .accountLogin:
           do {
               self.registerTitleLabel.text = kPigramLocalizeString("账号登录", "账号登录")
                if self.isShowChangeBtn {
                    self.loginBtn.setTitle(kPigramLocalizeString("验证码登录", "验证码登录"), for: .normal)
                }else{
                    self.loginBtn.isHidden = true
                }
           }
           case .codeLogin:
           do{
               self.registerTitleLabel.text = kPigramLocalizeString("验证码登录", "验证码登录")
               self.loginBtn.setTitle(kPigramLocalizeString("账号登录", "账号登录"), for: .normal)
           }
        default:break
       }
    }
    private var tsAccountManager: TSAccountManager {
        return TSAccountManager.sharedInstance()
    }
    @objc func tapCountryCodeViewAction(){
        self.showCountryPicker()
    }
    
    private func updatePhoneNumer(countryCode:String,callingCode: String)
    {
        self.contryCodeLabel.text = callingCode
        self.phoneNumberTF.placeholder =  ViewControllerUtils.examplePhoneNumber(forCountryCode: countryCode, callingCode: callingCode)
        guard let countryName = PhoneNumberUtil.countryName(fromCountryCode: countryCode) else {
            return
        }

        let countryState = OnboardingCountryState(countryName: countryName, callingCode: callingCode, countryCode: countryCode)
        onboardingController.update(countryState: countryState)
    }
    
    private func showCountryPicker() {
//        guard !tsAccountManager.isReregistering() else {
//            return
//        }
        let countryCodeController = CountryCodeViewController()
        countryCodeController.countryCodeDelegate = self
        countryCodeController.interfaceOrientationMask = .portrait
        let navigationController = OWSNavigationController(rootViewController: countryCodeController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func countryCodeViewController(_ vc: CountryCodeViewController, didSelectCountryCode countryCode: String, countryName: String, callingCode: String) {
        self.updatePhoneNumer(countryCode: countryCode, callingCode: callingCode)
    }

    @IBAction func loginAction(_ sender: UIButton) {
        let view = TXRegisterController.init(onboardingController: self.onboardingController)
        switch self.state {
        case .isRegister:
            view.state = .accountLogin
            view.isShowChangeBtn = false
        case .accountLogin:
            view.state = .codeLogin
        case .codeLogin:
            view.state = .accountLogin
        default: break
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    @IBAction func nextStepAction(_ sender: UIButton) {
        self.phoneNumberTF.resignFirstResponder()
        self.parseAndTryToRegister()
    }
    
    
    
    
    private func accountLoginAction(){
        
        self.onboardingController.requestEnsurePhoneNumberRegister(viewController: self)
    }
    private func codeLoginAction(){
        self.sendRequestVerifityCode()
    }
    private func sendRequestVerifityCode(){
          onboardingController.requestVerification(fromViewController: self, isSMS: true)
    }
    private func parseAndTryToRegister() {
           guard let phoneNumberText = phoneNumberTF.text?.ows_stripped(),
               phoneNumberText.count > 0 else {
                   OWSAlerts.showAlert(title:
                       NSLocalizedString("REGISTRATION_VIEW_NO_PHONE_NUMBER_ALERT_TITLE",
                                         comment: "Title of alert indicating that users needs to enter a phone number to register."),
                       message:
                       NSLocalizedString("REGISTRATION_VIEW_NO_PHONE_NUMBER_ALERT_MESSAGE",
                                         comment: "Message of alert indicating that users needs to enter a phone number to register."))
                   return
           }
        
           let callingCode = onboardingController.countryState.callingCode
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
           onboardingController.update(phoneNumber: OnboardingPhoneNumber(e164: e164PhoneNumber, userInput: phoneNumberText))
           onboardingController.update(userState: self.state)
            switch self.state {
                case .isRegister:
                    self.sendRequestVerifityCode()
                case .accountLogin:
                    self.accountLoginAction()
                break
                case .codeLogin:
                    self.codeLoginAction()
                break
            default:break
            }
       }
    
    
    
    
    
    
    
    
    deinit {
        self.removerObserverAction()
    }
    private func removerObserverAction(){
          NotificationCenter.default.removeObserver(self)
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
