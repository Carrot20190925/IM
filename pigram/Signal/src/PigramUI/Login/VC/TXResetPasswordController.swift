//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
//设置密码页面 密码登录界面公用
class TXResetPasswordController: TXBaseController {

    
    enum `Type` {
        //密码登录
        case loginPassword
        //验证码修改密码
        case codeChange
        //旧密码修密码
        case oldPasswordChange
    }
//    var resetPassword = true
    var type = Type.codeChange
    @IBOutlet weak var changeLoginBtn: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var forgetBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet var inputTextFields: [UITextField]!
    @IBOutlet var inputBackViews: [UIView]!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObserverAction()
        self.setupNav()
        self.setupUI()
        

        // Do any additional setup after loading the view.
    }
    //切换验证吗登陆
    @IBAction func changeLoginAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.onboardingController.update(userState: TXLoginManagerController.TXUserState.codeLogin)
        self.onboardingController.requestVerification(fromViewController: self, isSMS: true)
//        self.navigationController?.pushViewController(View, animated: true)        
    }
    @IBAction func forgotPasswordAction(_ sender: UIButton) {
        self.forgotAction()
    }
    private func setupNav(){
        
        if self.type == .loginPassword {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "register_big_forgot")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(forgotAction))
        }
        
    }
    @objc
    private func forgotAction(){
        self.onboardingController.onboardingForgotPassword(viewController: self)
    }
    private func setupUI(){
        if !UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 111.0
        }
        self.titleLabel.font = TXTheme.secondTitleFont(size: 23)
        self.titleLabel.textColor = TXTheme.titleColor()
        self.tagLabel.font = TXTheme.thirdTitleFont(size: 12)
        self.tagLabel.textColor = TXTheme.fourthColor()
        self.phoneLabel.textColor = TXTheme.titleColor()
        for backView in self.inputBackViews {
            backView.layer.cornerRadius = 25
            backView.clipsToBounds = true
            backView.backgroundColor = TXTheme.thirdColor()
        }
        self.nextBtn.titleLabel?.font = TXTheme.thirdTitleFont(size: 13)
        self.nextBtn.setTitleColor(TXTheme.titleColor(), for: UIControl.State.normal)
        self.updateUIAction()
      
        
        
    }
    
    private func addObserverAction(){
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowAction(noti:)), name: UIResponder.keyboardWillShowNotification, object:  nil)

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
   //        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
       self.bottomConstraint.constant = keyBoardHeight
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let firstTF = self.inputTextFields[0]
        firstTF.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.resignFirstResponder()
    }
    private func updateUIAction(){
          let titleString : String
          let tagString : String
        
        switch self.type {
        case .loginPassword:
            self.changeLoginBtn.isHidden = false
              titleString = kPigramLocalizeString("输入密码", "输入密码")
              tagString = kPigramLocalizeString("输入密码后请点击“登录Pigram”即刻进入Pigram世界！粗心的你如忘记密码，请点击右上角“忘”重新设计", "输入密码后请点击“登录Pigram”即刻进入Pigram世界！粗心的你如忘记密码，请点击右上角“忘”重新设计")
              let secondBackView = self.inputBackViews[1]
              secondBackView.isHidden = true
        default:
            if self.onboardingController.userState == .changePassword {
                titleString = kPigramLocalizeString("设置密码", "设置密码")
            }else
            {
                titleString = kPigramLocalizeString("忘记密码", "忘记密码")
            }
            tagString = kPigramLocalizeString("请重新设置新密码，长按大脑记忆存储键，\n牢记新密码哦！", "请重新设置新密码，长按大脑记忆存储键，\n牢记新密码哦！")
            self.forgetBtn.isHidden = true
            self.changeLoginBtn.isHidden = true
        }

          self.titleLabel.text = titleString
          self.tagLabel.text = tagString
          let attributes = [NSAttributedString.Key.foregroundColor:TXTheme.secondColor()]
          let attriText = NSMutableAttributedString.init(string: "•", attributes: attributes)
          let stringText = " " + self.onboardingController.countryState.callingCode + " " + TXTheme.formartString(string: (self.onboardingController.phoneNumber?.userInput ?? ""))
          let phoneText = NSAttributedString.init(string: stringText)
          attriText.append(phoneText)
          self.phoneLabel.attributedText = attriText
    }
    private func alertActionWithMessage(message:String){
        let alert = UIAlertController.init(title: message, message: nil, preferredStyle: .alert)
        let action = UIAlertAction.init(title:kPigramLocalizeString("确认", "确认") , style: .default) { (action) in
        }
        alert.addAction(action)
        self.presentAlert(alert, animated: true)
    }

    @IBAction func nextStepAction(_ sender: UIButton) {
        for textField in self.inputTextFields {
            textField.resignFirstResponder()
        }
        guard let firstText = self.inputTextFields[0].text else {
                   //密码为空
            OWSAlerts.showAlert(title:kPigramLocalizeString("密码不能为空！", "密码不能为空！") )
            return
        }
        switch self.type {
        case .loginPassword:
            self.loginAction(firstText: firstText)

        case .oldPasswordChange: //
            self.resetPasswordWithOldPassword(firstText: firstText)
            break
        default:
            self.resetPasswordWithCode(firstText: firstText)
        }
    }
    
    
    ///登录账号
 
    private func loginAction(firstText :  String){
        if firstText.length == 0 {
            OWSAlerts.showAlert(title:kPigramLocalizeString("请输入密码！", "请输入密码！") )
            return
        }
        //调用密码登录接口
        self.onboardingController.update(password: firstText)
        self.onboardingController.update(isPassword: true)
        self.onboardingController.txRequestLoginAction(fromViewController: self)
    }
    ///通过旧密码修改密码

    private func resetPasswordWithOldPassword(firstText : String){
        self.onboardingController.update(password: firstText)
        self.onboardingController.requestChangePasswordWithOldPassword(fromVC: self)
    }
    
    ///通过验证码修改密码
    private func resetPasswordWithCode(firstText : String){
            if !firstText.isPassword() {
                OWSAlerts.showAlert(title:kPigramLocalizeString("8-20位字母和数字组成，区分大小写", "8-20位字母和数字组成，区分大小写") )
                //密码不符合字母数字组合
                return
            }
             //  调用重设密码接口
              guard  let secondText = self.inputTextFields[1].text  else {
                  OWSAlerts.showAlert(title:kPigramLocalizeString("请确认密码！", "请确认密码！") )
                  //  再次输入
                  return
              }
              if !(firstText == secondText) {
                   OWSAlerts.showAlert(title:kPigramLocalizeString("密码不一致！", "密码不一致！") )
                  //两次密码不一致
              }
               //重新设置密码
               self.onboardingController.update(password: firstText)
               self.onboardingController.txRequestForSetPassword(fromViewController: self)
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
