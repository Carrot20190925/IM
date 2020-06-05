//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
import PromiseKit
import MJExtension
import ToastSwiftFramework
@objc
public class TXLoginManagerController: NSObject {
//    @objc
//    class func defamultPinCode() -> NSString{
//        return NSString.init(string: "12345")
//    }
    private var tsAccountManager: TSAccountManager {
        
           return TSAccountManager.sharedInstance()
       }

    private var accountManager: AccountManager {
           return AppEnvironment.shared.accountManager
       }

    private var contactsManager: OWSContactsManager {
           return Environment.shared.contactsManager
       }

    private var backup: OWSBackup {
           return AppEnvironment.shared.backup
       }
  

    @objc
    public override init() {
        super.init()
    
    }
    @objc func initialViewController() -> UIViewController {
        let ViewControl = TXWelcomeController.init(onboardingController: self)
        
        
        return ViewControl
    }
    //MARK:-  更换手机号或密码时初始化数据
    private func initDataWhenChangeSomething(){
        guard let phoneNumber = tsAccountManager.localNumber else {
            return
        }
        if let dic = UserDefaults.standard.object(forKey: "pigram_last_regsiter_login_country_code_and_num") as? [String : String]{
            if let lastRegisteredCountryCode = dic["countryCode"],lastRegisteredCountryCode.length > 0  {
                let   countryCode = lastRegisteredCountryCode
                let  countryCallingCode = PhoneNumberUtil.callingCode(fromCountryCode: countryCode)
                guard let countryName = PhoneNumberUtil.countryName(fromCountryCode: countryCode) else {
                    OWSAlerts.showAlert(title: "亲，不好意思您可以退出后再修改密码！！")
                    return
                }
                let countryState = OnboardingCountryState.init(countryName: countryName, callingCode: countryCallingCode, countryCode: countryCode)
                self.update(countryState: countryState)
            }
            if let phoneNum = dic["phoneNum"],phoneNumber.length > 0  {
                self.update(phoneNumber: OnboardingPhoneNumber.init(e164: phoneNumber, userInput: phoneNum))
            }


        }else{
            OWSAlerts.showAlert(title: "亲，不好意思您可以退出后再修改密码！！")
        }
    }
    
    //MARK:-  修改密码
    func changePasswordController(viewController: UIViewController) {

        self.initDataWhenChangeSomething()
        let changeVC = PigramSetPasswordOrPhoneVC.init(onboardingController: self)
        let nav = TXBaseNaviController.init(rootViewController: changeVC)
        viewController.navigationController?.present(nav, animated: true, completion: nil)
 
    }
    
    
    //MARK:-  验证码修改密码
    func verifyCodeChangePassword(fromVC : UIViewController)  {
        self.update(userState: .changePassword)
        self.resetPasswordRequestVerification(from: fromVC, isSMS: true)
    }
    
    //MARK:-  验证码更换手机 旧手机号获取验证码
    func verifyCodeChangePhone(fromVC : UIViewController) {
        self.update(userState: .oldPhoneCode)
        self.resetPasswordRequestVerification(from: fromVC, isSMS: true)
    }
    //MARK:-  通过旧密码更换密码
    func oldPasswordChangePassword(fromVC : UIViewController) {
        let changeVC = PigramPasswordOrNewPhoneVC.init(onboardingController: self)
        changeVC.type = .changePassword
        fromVC.navigationController?.pushViewController(changeVC, animated: true)
    }
    
    //MARK:-  进入重设密码 旧密码
    func entryResetPasswordThroughOldPassword(fromVC : UIViewController) {
        let resetVC = TXResetPasswordController.init(onboardingController: self)
        resetVC.type = .oldPasswordChange
        fromVC.navigationController?.pushViewController(resetVC, animated: true)
    }
    
    
    //MARK:-  更换手机号
    func changPhoneAction(fromVC : UIViewController) {
        self.initDataWhenChangeSomething()
        let changeVC = PigramSetPasswordOrPhoneVC.init(onboardingController: self)
        changeVC.type = .changePhone
        let nav = TXBaseNaviController.init(rootViewController: changeVC)
        fromVC.navigationController?.present(nav, animated: true, completion: nil)
    }
    //MARK:-  通过验证码修改手机号
    func entryResetPhoneThroughCode(fromVC : UIViewController)  {
        let phoneVC = PigramPasswordOrNewPhoneVC.init(onboardingController: self)
        phoneVC.type = .resetPhoneCode
        fromVC.navigationController?.pushViewController(phoneVC, animated: true)
    }
    //MARK:-  通过密码修改手机号 输入旧密码界面
    func entryResetPhoneThroughOldPassword(fromVC : UIViewController)  {
        let phoneVC = PigramPasswordOrNewPhoneVC.init(onboardingController: self)
        phoneVC.type = .changePhone
        fromVC.navigationController?.pushViewController(phoneVC, animated: true)
        
    }
    //MARK:-  密码修改手机号 进入新手机号m界面
    
    func entryNewPhoneResetPhoneThroughOldPassword(fromVC : UIViewController)  {
        let phoneVC = PigramPasswordOrNewPhoneVC.init(onboardingController: self)
        phoneVC.type = .resetPhonePassword
        fromVC.navigationController?.pushViewController(phoneVC, animated: true)
        
    }
    
    
    //MARK:-  通过验证码修改手机号 新手机号请求验证码
    func requestNewPhoneCodeChangePhoneWithCode(fromVC : UIViewController) {
        self.update(userState: .resetPhoneWithCode)
        self.resetPasswordRequestVerification(from: fromVC, isSMS: true)
    }
    
    //MARK:-  通过密码修改手机号 新手机号请求验证码
    func requestNewPhoneCodeChangePhoneWithPassword(fromVC : UIViewController) {
        self.update(userState: .resetPhoneWithPassword)
        self.resetPasswordRequestVerification(from: fromVC, isSMS: true)
    }
    
    
    
    //MARK:-  通过密码更换手机号请求
    func requestChangePhoneWithPassword(fromVC : UIViewController) {
        guard let password = self.textCode else {
            return
        }
        guard let code = self.password  else {
            return
        }
        guard let newNum = self.phoneNumber?.e164 else{
            return
        }
        
        ModalActivityIndicatorViewController.present(fromViewController: fromVC, canCancel: true) { (modal) in
            PigramNetworkMananger.pg_chagnePhoneWithPassword(password: password, newNumberCode: code, newNumber: newNum, success: { [weak self] (model) in
                self?.tsAccountManager.phoneNumberAwaitingVerification = newNum
                self?.tsAccountManager.didRegister()
                self?.saveAccountAction()
                NotificationCenter.default.post(name: NSNotification.Name.init(kNSNotification_OWSWebSocketStateDidChange), object: nil)
                modal.dismiss {
                    fromVC.dismiss(animated: true) {
                    OWSAlerts.showAlert(title: kPigramLocalizeString("修改成功", ""))
                }

                }
            }, failure: { (error) in
                modal.dismiss {
                    self.showErrorAlert(error: error as NSError)
                }
            })
        }
    }
    
    //MARK:-  通过验证码更换手机号请求
    func requestChangePhoneWithCode(fromVC : UIViewController) {
        guard let oldCode = self.textCode else {
            return
        }
        guard let code = self.password  else {
            return
        }
        guard let newNum = self.phoneNumber?.e164 else{
            return
        }
        
        ModalActivityIndicatorViewController.present(fromViewController: fromVC, canCancel: true) { (modal) in
            
            PigramNetworkMananger.pg_chagnePhoneWithCode(oldNumberCode: oldCode, newNumberCode: code, newNumber: newNum, success: {[weak self] (_) in
                self?.tsAccountManager.phoneNumberAwaitingVerification = newNum
                self?.tsAccountManager.didRegister()
                
                self?.saveAccountAction()
                
                
                NotificationCenter.default.post(name: NSNotification.Name.init(kNSNotification_OWSWebSocketStateDidChange), object: nil)

                modal.dismiss {
                    fromVC.dismiss(animated: true) {
                        OWSAlerts.showAlert(title: kPigramLocalizeString("修改成功", ""))
                    }

                }
            }) { [weak self](error) in
                modal.dismiss {
                    let errorCode = error as NSError
                    self?.showErrorAlert(error: errorCode)

                }
            }
        }
    }
    
    
    private func saveAccountAction() {
        if let phoneNumber = self.phoneNumber?.userInput {
            let countryCode = self.countryState.countryCode
            let dic = ["countryCode":countryCode,"phoneNum" : phoneNumber]
            UserDefaults.standard.setValue(dic, forKey: "pigram_last_regsiter_login_country_code_and_num")
            UserDefaults.standard.synchronize()

        }
    }
    
    
    
    //MARK:-  通过旧密码 修改密码请求
    
    func requestChangePasswordWithOldPassword(fromVC : UIViewController) {
        guard let old = self.textCode else {
            return
        }
        guard let new = self.password else {
            return
        }
        ModalActivityIndicatorViewController.present(fromViewController: fromVC, canCancel: true) { (modal) in
            PigramNetworkMananger.pg_chagnePassword(oldPassword: old, newPassword: new, success: { (model) in
                modal.dismiss {
                    fromVC.dismiss(animated: true) {
                        OWSAlerts.showAlert(title: kPigramLocalizeString("修改成功", ""))

                    }
                }
            }) { [weak self](error) in
                modal.dismiss {
                    let errorCode = error as NSError
                    self?.showErrorAlert(error: errorCode)
                }
            }
        }

    }
    
    func showErrorAlert(error : NSError) {
            switch error.code{
            case 412:
                OWSAlerts.showErrorAlert(message: "密码错误")
            case 403:
                OWSAlerts.showErrorAlert(message: "验证码错误")
            case 406:
                OWSAlerts.showErrorAlert(message: "新手机号和老手机号相同")
            case 421:
                OWSAlerts.showErrorAlert(message: "新手机号已经注册")
            default:
            OWSAlerts.showErrorAlert(message: "修改失败")

        }
    }
    func registerController(viewController: UIViewController) {
        
       let View = TXRegisterController.init(onboardingController: self)
       let nav =  TXBaseNaviController.init(rootViewController: View)
       nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
       viewController.present(nav, animated: true, completion: nil)
    }
    
    func loginController(viewController: UIViewController) {
        
       let View = TXRegisterController.init(onboardingController: self)
       View.state = .accountLogin
       View.isShowChangeBtn = false
       let nav =  TXBaseNaviController.init(rootViewController: View)
       nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
       viewController.present(nav, animated: true, completion: nil)
    }
    func requestingVerificationDidSucceed(viewController: UIViewController) {
        let View = TXVerificationCodeController.init(onboardingController: self)
        viewController.navigationController?.pushViewController(View, animated: true)
    }
    
    func onboardingForgotPassword(viewController: UIViewController) {
        
        let View = TXVerificationCodeController.init(onboardingController: self)
        View.type = TXVerificationCodeController.VerityType.resetPassword
        let nav = TXBaseNaviController.init(rootViewController: View)
        viewController.navigationController?.present(nav, animated: true, completion: nil)
    }
    

    //MARK:-  重置密码
    func onboardingResetPassword(viewController: UIViewController) {
        let View = TXResetPasswordController.init(onboardingController: self)
        viewController.navigationController?.pushViewController(View, animated: true)
    }
    func onboardingLoginPassword(viewController: UIViewController) {
        let View = TXResetPasswordController.init(onboardingController: self)
        View.type = .loginPassword
        viewController.navigationController?.pushViewController(View, animated: true)
    }
    
    func requestEnsurePhoneNumberRegister(viewController: UIViewController) {
        guard let phoneNumber = phoneNumber else {
            owsFailDebug("Missing phoneNumber.")
            return
        }
        let phone = phoneNumber.e164
        if let phoneNum = self.phoneNumber?.userInput {
            let countryCode = self.countryState.countryCode
            let dic = ["countryCode":countryCode,"phoneNum" : phoneNum]
            UserDefaults.standard.setValue(dic, forKey: "pigram_last_regsiter_login_country_code_and_num")
            UserDefaults.standard.synchronize()
        }
        ModalActivityIndicatorViewController.present(fromViewController: viewController, canCancel: true) { (controller) in
            firstly {
                PigramLoginOrRegisterManager.pgEnsurePhoneNumberRegister(phoneNumber: phone)
//                self.accountManager.txEnsurePhoneNumberRegister(phoneNumber: phone)
            }.done { (response) in
                DispatchQueue.main.async {
                    controller.dismiss {
                        guard let res = response else{
                            self.requestVerification(fromViewController: viewController, isSMS: true)
                            return
                        }
                        let success : TXLoginSuccessItem = TXLoginSuccessItem.mj_object(withKeyValues: res)
                        guard let password = success.loginPassword else{
                            self.update(userState: .codeLogin)
                            self.requestVerification(fromViewController: viewController, isSMS: true)
                            return
                        }
                        if password.length != 0{
                            self.update(userState: .accountLogin)
                            self.onboardingLoginPassword(viewController: viewController)
                            return
                        }
                        self.update(userState: .codeLogin)
                        self.requestVerification(fromViewController: viewController, isSMS: true)
                    }
            
               }
            }.catch { (error) in
                
                DispatchQueue.main.async {
                    controller.dismiss {
                        if let pigramError = error as? PigramTXError{
                            switch pigramError {
                            case .request:
                                OWSAlerts.showErrorAlert(message: "请求链接有问题")
                            case .des(_,let des):
                                OWSAlerts.showErrorAlert(message: des)
                                break
                                
                                
                                
                            }
                            return
                        }
                        let ensureError = error as NSError
                        if ensureError.code == 404{
                            OWSAlerts.showAlert(title: "您好像还没有注册")
                        }else if ensureError.code == 413 {
                            OWSAlerts.showAlert(title: "操作太频繁了亲，稍后重试")
                        }else{
                            OWSAlerts.showAlert(title: error.localizedDescription)
                        }

                    }
                }
            }.retainUntilComplete()
        }
    }
    
    public func requestVerificationCode(fromViewController: UIViewController, isSMS: Bool,success:@escaping (UIViewController) -> Void){
         AssertIsOnMainThread()

        guard let phoneNumber = phoneNumber else {
            owsFailDebug("Missing phoneNumber.")
            return
        }
        let captchaToken = self.captchaToken
        self.verificationRequestCount += 1
        ModalActivityIndicatorViewController.present(fromViewController: fromViewController, canCancel: true) { (modal) in
            firstly {
                self.accountManager.requestAccountVerification(recipientId: phoneNumber.e164,
                                                               captchaToken: captchaToken,
                                                               isSMS: isSMS)
            }.done {
                DispatchQueue.main.async {
                    modal.dismiss {
                        success(fromViewController)
                    }
                }
            }.catch { error in
                Logger.error("Error: \(error)")
                DispatchQueue.main.async {
                    modal.dismiss {
                        self.requestingVerificationDidFail(viewController: fromViewController, error: error)
                    }
                }
            }.retainUntilComplete()
        }


    }
    
    
    
    
    public func resetPasswordRequestVerification(from:UIViewController,isSMS:Bool){
            AssertIsOnMainThread()

            guard let phoneNumber = phoneNumber else {
                owsFailDebug("Missing phoneNumber.")
                return
            }

            // We eagerly update this state, regardless of whether or not the
            // registration request succeeds.
    //        OnboardingController.setLastRegisteredCountryCode(value: countryState.countryCode)
    //        OnboardingController.setLastRegisteredPhoneNumber(value: phoneNumber.userInput)
            
            let captchaToken = self.captchaToken
            self.verificationRequestCount += 1
            ModalActivityIndicatorViewController.present(fromViewController: from,
                                                         canCancel: true) { modal in
                firstly {
                    self.accountManager.requestAccountVerification(recipientId: phoneNumber.e164,
                                                                   captchaToken: captchaToken,
                                                                   isSMS: isSMS)
                }.done {
                    DispatchQueue.main.async {
                        modal.dismiss {
                             let changePassword = TXVerificationCodeController.init(onboardingController: self)
                             from.navigationController?.pushViewController(changePassword, animated: true)
//                             from.navigationController?.present(nav, animated: true, completion: nil)
                        }
                    }
                    

                }.catch { error in
                    Logger.error("Error: \(error)")
                    modal.dismiss {
                    }
                }.retainUntilComplete()
            }
    }
    public func requestVerification(fromViewController: UIViewController, isSMS: Bool) {
        AssertIsOnMainThread()

        guard let phoneNumber = phoneNumber else {
            owsFailDebug("Missing phoneNumber.")
            return
        }

        // We eagerly update this state, regardless of whether or not the
        // registration request succeeds.
//        OnboardingController.setLastRegisteredCountryCode(value: countryState.countryCode)
//        OnboardingController.setLastRegisteredPhoneNumber(value: phoneNumber.userInput)
        
        let captchaToken = self.captchaToken
        self.verificationRequestCount += 1
        
        ModalActivityIndicatorViewController.present(fromViewController: fromViewController, canCancel: true) { (modal) in
            firstly {
                self.accountManager.requestAccountVerification(recipientId: phoneNumber.e164,
                                                               captchaToken: captchaToken,
                                                               isSMS: isSMS)
            }.done {
                DispatchQueue.main.async {
                    modal.dismiss {
                        self.requestingVerificationDidSucceed(viewController: fromViewController)
                    }
                }

            }.catch { error in
                Logger.error("Error: \(error)")
                DispatchQueue.main.async {
                    modal.dismiss {
                        if  let ensureError = error as? NSError{
                            if ensureError.code == 400{
                                OWSAlerts.showAlert(title:
                                    NSLocalizedString("REGISTRATION_VIEW_INVALID_PHONE_NUMBER_ALERT_TITLE",
                                                      comment: "Title of alert indicating that users needs to enter a valid phone number to register."),
                                    message:
                                    NSLocalizedString("REGISTRATION_VIEW_INVALID_PHONE_NUMBER_ALERT_MESSAGE",
                                                      comment: "Message of alert indicating that users needs to enter a valid phone number to register."))
                            }else{
                                OWSAlerts.showAlert(title: error.localizedDescription)
                            }

                        }else{
                            OWSAlerts.showAlert(title: error.localizedDescription)

                        }
                    }

                }

            }.retainUntilComplete()

        }

    }
    
    
    private func requestingVerificationDidFail(viewController: UIViewController, error: Error) {
        switch error {
        case AccountServiceClientError.captchaRequired:
            onboardingDidRequireCaptcha(viewController: viewController)
            return

        case let networkManagerError as NetworkManagerError:
            switch networkManagerError.statusCode {
            case 400:
                OWSAlerts.showAlert(title: NSLocalizedString("REGISTRATION_ERROR", comment: ""),
                                    message: NSLocalizedString("REGISTRATION_NON_VALID_NUMBER", comment: ""))
                return
            default:
                break
            }
        default:
            break
        }
        let nsError = error as NSError
        owsFailDebug("unexpected error: \(nsError)")
        OWSAlerts.showAlert(title: nsError.localizedDescription,
                            message: nsError.localizedRecoverySuggestion)
    }
    public func onboardingDidRequireCaptcha(viewController: UIViewController) {
          AssertIsOnMainThread()

          Logger.info("")

          guard let navigationController = viewController.navigationController else {
              owsFailDebug("Missing navigationController.")
              return
          }

          // The service could demand CAPTCHA from the "phone number" view or later
          // from the "code verification" view.  The "Captcha" view should always appear
          // immediately after the "phone number" view.
          while navigationController.viewControllers.count > 1 &&
              !(navigationController.topViewController is OnboardingPhoneNumberViewController) {
                  navigationController.popViewController(animated: false)
          }

          let view = TXOnboardingCaptchaController(onboardingController: self)
          navigationController.pushViewController(view, animated: true)
      }
    public func onboardingDidNickName(viewController: UIViewController){
           AssertIsOnMainThread()
           Logger.info("")
           let view = TXSetNickNameController.init(onboardingController: self)
           viewController.navigationController?.pushViewController(view, animated: true)
       }
    public func onboardingDidAvatar(viewController: UIViewController){
        AssertIsOnMainThread()
        Logger.info("")
        let view = TXSetAvatarController.init(onboardingController: self)
        viewController.navigationController?.pushViewController(view, animated: true)
    }
    public func onboardingDidPassword(viewController: UIViewController){
        AssertIsOnMainThread()
        Logger.info("")
        let view = TXSetPasswordController.init(onboardingController: self)
        viewController.navigationController?.pushViewController(view, animated: true)
    }
    // MARK: - State

       public enum TXUserState {
            case isRegister //注册
            case accountLogin //账号登录
            case codeLogin //验证吗登录
            case changePassword //修改密码
            case oldPhoneCode // 旧手机号获取验证码
            case resetPhoneWithCode //验证码修改手机号
            case resetPhoneWithPassword //密码修改手机号
        
        }
       public private(set) var countryState: OnboardingCountryState = .defaultValue
       public private(set) var userState: TXUserState = .isRegister
       public private(set) var phoneNumber: OnboardingPhoneNumber?
       public private(set) var captchaToken: String?

       public private(set) var password: String?//密码
       public private(set) var textCode: String?//验证码
       public private(set) var isPassword: Bool = true//密码或验证码

       public private(set) var twoFAPin: String?
       public private(set) var nickName: String?

       private var kbsAuth: RemoteAttestationAuth?

       public private(set) var verificationRequestCount: UInt = 0
       public func update(userState: TXUserState) {
           AssertIsOnMainThread()
           self.userState = userState
       }
        @objc
        public func update(password: String) {
            AssertIsOnMainThread()
            self.password = password
        }

       @objc
       public func update(countryState: OnboardingCountryState) {
           AssertIsOnMainThread()

           self.countryState = countryState
       }
        @objc
        public func update(nickName: String) {
            AssertIsOnMainThread()
            self.nickName = nickName
        }


       @objc
       public func update(phoneNumber: OnboardingPhoneNumber) {
           AssertIsOnMainThread()

           self.phoneNumber = phoneNumber
       }

       @objc
       public func update(captchaToken: String) {
           AssertIsOnMainThread()

           self.captchaToken = captchaToken
       }

       @objc
       public func update(textCode: String) {
           AssertIsOnMainThread()
           self.textCode = textCode
       }
        @objc
        public func update(isPassword: Bool) {
            AssertIsOnMainThread()
            self.isPassword = isPassword
        }
            


       @objc
       public func update(twoFAPin: String) {
           AssertIsOnMainThread()

           self.twoFAPin = twoFAPin
       }

//      public enum
    
    
    
    
    public func txResetPasswordAction(fromViewController: UIViewController){
        ModalActivityIndicatorViewController.present(fromViewController: fromViewController, canCancel: true) { (controller) in
                   
                   guard let phoneNumber = self.phoneNumber?.e164 else{
                       return
                   }
                   guard let passwordText = self.password else{
                       return
                   }
                   let password = self.isPassword
                   self.accountManager.txLoginWithCode(phoneNumber: phoneNumber,textCode: passwordText, pin: nil,isPassword: password).done { (_) in
                       DispatchQueue.main.async {
                        UIApplication.shared.keyWindow?.rootViewController = BaseTabBarVC.init()
//                            OWSNavigationController.init(rootViewController: HomeViewController.init())
                       }
                   }.catch { (error) in
                                       Logger.error("Error: \(error)")

                   }.retainUntilComplete()
                 
               }
    }
    //验证吗登录 和密码登录
    public func txRequestLoginAction(fromViewController: UIViewController){
        
        if let phoneNumber = self.phoneNumber?.userInput {
            let countryCode = self.countryState.countryCode
            let dic = ["countryCode":countryCode,"phoneNum" : phoneNumber]
            UserDefaults.standard.setValue(dic, forKey: "pigram_last_regsiter_login_country_code_and_num")
            UserDefaults.standard.synchronize()

        }
        ModalActivityIndicatorViewController.present(fromViewController: fromViewController, canCancel: true) { (controller) in
            
            guard let phoneNumber = self.phoneNumber?.e164 else{
                return
            }
            let password = self.isPassword
            var text : String?
            if password {
                text = self.password
            }else{
                text = self.textCode
            }
            guard let textCode = text else{
                return
            }
            self.accountManager.txLoginWithCode(phoneNumber: phoneNumber,textCode: textCode, pin: nil,isPassword: password).done { (_) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kNotification_login_successsful"), object: nil)
                DispatchQueue.main.async {
                    controller.dismiss {
                        fromViewController.view.endEditing(true)
                        UIApplication.shared.keyWindow?.rootViewController = BaseTabBarVC.init()

                    }
                }
            }.catch { (error) in
                Logger.error("Error: \(error)")
                DispatchQueue.main.async {
                           controller.dismiss {
                                if  let ensureError = error as? NSError{
                                    switch ensureError.code {
                                    case 404:
                                        OWSAlerts.showAlert(title: "密码错误")
                                    default:
                                        OWSAlerts.showErrorAlert(message: error.localizedDescription)
                                    }
                                    return
                                }
                                OWSAlerts.showErrorAlert(message: error.localizedDescription)
                           }
                       }

            }.retainUntilComplete()
          
        }

    }
    
//    /设置密码 与重设密码
    public func txRequestForSetPassword(fromViewController: UIViewController){
        ModalActivityIndicatorViewController.present(fromViewController: fromViewController, canCancel: true) { (controller) in
            guard let password = self.password else{
                return
            }
            guard let phoneNumber = self.phoneNumber?.e164 else{
                return
            }
//            if let
            var params = ["phoneNumber":phoneNumber,"password":password]
            if  let textCode = self.textCode{
                params["code"] = textCode
            }
            PigramLoginOrRegisterManager.pgChangePassword(params: params).done { (response) in
                DispatchQueue.main.async {
                    controller.dismiss {
                        if self.userState == .changePassword{
                            fromViewController.navigationController?.dismiss(animated: true, completion: nil)
                        }else if (self.userState == .accountLogin){
                            fromViewController.navigationController?.dismiss(animated: true, completion: nil)
                        }else{
                            UIApplication.shared.keyWindow?.rootViewController = BaseTabBarVC.init()
                        }

                    }
                }
            }.catch { [weak self] (error) in
                Logger.error("Error: \(error)")
                DispatchQueue.main.async {
                    controller.dismiss {
                        self?.showErrorAlert(error: error as NSError)
                    }
                }
            }.retainUntilComplete()
     
        }

    }
    private func alertActionWithMessage(message:String,fromController:UIViewController){
           let alert = UIAlertController.init(title: message, message: nil, preferredStyle: .alert)
           let action = UIAlertAction.init(title: "确认", style: .default) { (action) in
                   
           }
           alert.addAction(action)
           fromController.presentAlert(alert, animated: true)
    }
    public func txRegister(fromViewController: UIViewController,
                           success :@escaping () -> Void,failed:@escaping () -> Void){
        AssertIsOnMainThread()
        guard let phoneNumber = phoneNumber else {
                      owsFailDebug("Missing phoneNumber.")
                     return
                 }
        guard let nickName = self.nickName else {
            owsFailDebug("Missing nickName.")
            failed()
            return
        }
        guard let code = self.textCode else {
            return
        }
        tsAccountManager.phoneNumberAwaitingVerification = phoneNumber.e164
        let twoFAPin = self.twoFAPin
        ModalActivityIndicatorViewController.present(fromViewController: fromViewController, canCancel: true) { (model) in
            self.accountManager.txRegisterNew(nickName: nickName, pin: twoFAPin,textCode: code).done { (_) in
                  DispatchQueue.main.async {
                    model.dismiss {
                        self.registerSuccessAction()

                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kNotification_login_successsful"), object: nil)
                        self.onboardingDidAvatar(viewController: fromViewController)
                    }
                }
            }.catch { (error) in
                  DispatchQueue.main.async {
                    model.dismiss {
                        if let ensureError = error as? NSError,ensureError.code == 406{
                           OWSAlerts.showErrorAlert(message: "你好像已经注册了")
                        }else{
                            OWSAlerts.showAlert(title: error.localizedDescription)
                        }
                    }
                }
            }.retainUntilComplete()
        }
        
    }
    
    //MARK:-  注册成功
    public func registerSuccessAction(){
        OpenInstallSDK.reportRegister()
        
        OpenInstallSDK.defaultManager()?.getInstallParms(withTimeoutInterval: 15, completed: { (appData) in
            //在主线程中回调
            
            if appData?.data != nil,let link = appData?.data["short_id"] as? String ,link.count > 0{
                TXTheme.tapLinkAction(link: link)
                //e.g.如免填邀请码建立邀请关系、自动加好友、自动进入某个群组或房间等
            }
            if appData?.channelCode != nil{
                //e.g.可自己统计渠道相关数据等
            }
            MyLog("安装参数 data = \(String(describing: appData?.data)),channelCode = \(String(describing: appData?.channelCode))")
        })

    }
    
    
    public func txVerificationCode(fromViewController: UIViewController,
                                   success :@escaping () -> Void,failed:@escaping () -> Void){
        AssertIsOnMainThread()
        guard let phoneNumber = phoneNumber else {
                      owsFailDebug("Missing phoneNumber.")
                      return
                  }
        guard let verificationCode = self.textCode else {
            owsFailDebug("Missing verificationCode.")
            failed()
            return
         }
        tsAccountManager.phoneNumberAwaitingVerification = phoneNumber.e164
//        let twoFAPin = self.twoFAPin
        ModalActivityIndicatorViewController.present(fromViewController: fromViewController, canCancel: true) { (model) in
            let params = ["phoneNumber":phoneNumber.e164,"code":verificationCode]
            PigramLoginOrRegisterManager.pgVerifyCode(params: params).done { (response) in
                DispatchQueue.main.async {
                    model.dismiss {
                        success()
                    }
                }
            }.catch { (error) in
                DispatchQueue.main.async {
                    model.dismiss {
                        if let ensureError = error as? NSError, ensureError.code == 403{
                                OWSAlerts.showErrorAlert(message: "验证码错误！！")
                                return;
                            }
                        }
                        OWSAlerts.showAlert(title: error.localizedDescription)
                    }
                }
            }

    }
      public func submitVerification(fromViewController: UIViewController,
                                     success :@escaping () -> Void,failed:@escaping () -> Void) {
            AssertIsOnMainThread()

            // If we have credentials for KBS auth, we need to restore our keys.
      

            guard let phoneNumber = phoneNumber else {
                owsFailDebug("Missing phoneNumber.")
                return
            }
            guard let verificationCode = self.textCode else {
                owsFailDebug("Missing verificationCode.")
                failed()
                return
            }

            // Ensure the account manager state is up-to-date.
            // TODO: We could skip this in production.
            
            tsAccountManager.phoneNumberAwaitingVerification = phoneNumber.e164
            let twoFAPin = self.twoFAPin
//            ModalActivityIndicatorViewController.present(fromViewController: fromViewController,
//                                                         canCancel: true) { (modal) in
//
//                                                            self.accountManager.register(verificationCode: verificationCode, pin: twoFAPin)
//                                                                .done { (_) in
//                                                                    DispatchQueue.main.async {
//                                                                        modal.dismiss(completion: {
//                                                                            self.onboardingDidNickName(viewController: fromViewController)
//                                                                        })
//                                                                    }
//                                                                }.catch({ (error) in
//                                                                    Logger.error("Error: \(error)")
//
//                                                                    DispatchQueue.main.async {
//                                                                        modal.dismiss(completion: {
//                                                                            self.verificationFailed(fromViewController: fromViewController, error: error as NSError, success: success, failed: failed)
//                                                                        })
//                                                                    }
//                                                                }).retainUntilComplete()
//            }
        }

        private func verificationFailed(fromViewController: UIViewController, error: NSError,
                                        success : () -> Void,failed: () -> Void) {
            AssertIsOnMainThread()

            if error.domain == OWSSignalServiceKitErrorDomain &&
                error.code == OWSErrorCode.registrationMissing2FAPIN.rawValue {

                Logger.info("Missing 2FA PIN.")

                // If we were provided KBS auth, we'll need to re-register using reg lock v2,
                // store this for that path.
                kbsAuth = error.userInfo[TSRemoteAttestationAuthErrorKey] as? RemoteAttestationAuth
                
                // Since we were told we need 2fa, clear out any stored KBS keys so we can
                // do a fresh verification.
                KeyBackupService.clearKeychain()
                success()
            } else {
                if error.domain == OWSSignalServiceKitErrorDomain &&
                    error.code == OWSErrorCode.userError.rawValue {
                    failed()
                }
                Logger.verbose("error: \(error.domain) \(error.code)")
                OWSAlerts.showAlert(title: NSLocalizedString("REGISTRATION_VERIFICATION_FAILED_TITLE", comment: "Alert view title"),
                                    message: error.localizedDescription,
                                    fromViewController: fromViewController)
            }
        }
    

    
    
    public func verificationDidComplete(fromView view: UIViewController) {
        AssertIsOnMainThread()

     Logger.info("")

     // At this point, the user has been prompted for contact access
     // and has valid service credentials.
     // We start the contact fetch/intersection now so that by the time
     // they get to HomeView we can show meaningful contact in the suggested
     // contact bubble.
//        contactsManager.fetchSystemContactsOnceIfAlreadyAuthorized()

        if tsAccountManager.isReregistering() {
            showProfileView(fromView: view)
        } else {
            checkCanImportBackup(fromView: view)
        }
    }
    private func showProfileView(fromView view: UIViewController) {
           AssertIsOnMainThread()

           Logger.info("")

           guard let navigationController = view.navigationController else {
               owsFailDebug("Missing navigationController")
               return
           }

           ProfileViewController.present(forRegistration: navigationController)
       }
     private func checkCanImportBackup(fromView view: UIViewController) {
           AssertIsOnMainThread()

           Logger.info("")

           backup.checkCanImport({ (canImport) in
               Logger.info("canImport: \(canImport)")

               if (canImport) {
                   self.backup.setHasPendingRestoreDecision(true)

                   self.showBackupRestoreView(fromView: view)
               } else {
                   self.showProfileView(fromView: view)
               }
           }, failure: { (_) in
               self.showBackupCheckFailedAlert(fromView: view)
           })
       }
    
    private func showBackupCheckFailedAlert(fromView view: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        let alert = UIAlertController(title: NSLocalizedString("CHECK_FOR_BACKUP_FAILED_TITLE",
                                                               comment: "Title for alert shown when the app failed to check for an existing backup."),
                                      message: NSLocalizedString("CHECK_FOR_BACKUP_FAILED_MESSAGE",
                                                                 comment: "Message for alert shown when the app failed to check for an existing backup."),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("REGISTER_FAILED_TRY_AGAIN", comment: ""),
                                      style: .default) { (_) in
                                        self.checkCanImportBackup(fromView: view)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("CHECK_FOR_BACKUP_DO_NOT_RESTORE", comment: "The label for the 'do not restore backup' button."),
                                      style: .destructive) { (_) in
                                        self.showProfileView(fromView: view)
        })
        view.presentAlert(alert)
    }
    private func showBackupRestoreView(fromView view: UIViewController) {
        AssertIsOnMainThread()

        Logger.info("")

        guard let navigationController = view.navigationController else {
            owsFailDebug("Missing navigationController")
            return
        }

        let restoreView = BackupRestoreViewController()
        navigationController.setViewControllers([restoreView], animated: true)
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


extension TXTheme{
    static
    func tapLinkAction(link : String) {
         
         PigramNetworkMananger.pg_getInfoWithLink(link, success: { (response) in
             
             if let data = response as? [String:Any] ,let ID = data["id"] as? String{
                 if ID.hasPrefix("___group___!") {
                    
                    PigramNetworkMananger.pgApplyJoinGroupNetwork(params: ["groupId":ID], success: { (_) in
                        
                    }) { (error) in
                        
                    }
                     
                 }else if ID.hasPrefix("___user____!"){
                    
                    
                     if ID == TSAccountManager.localUserId {
                         return
                     }
                    let  params  = ["destinationId":ID,"addingWay":5] as [String : Any]

                    PigramNetworkMananger.pgAddFriendNetwork(params: params, success: { (_) in
                        
                    }) { (error) in
                    }
                     
                 }
             }

         }) { (error) in
             
         }
     }

}
