//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
//
class TXVerificationCodeController: TXBaseController,UITextFieldDelegate {
    
    enum VerityType {
        case normal
        case resetPassword
        case changePassword

    }
//    var resetPassword = false
    var type:VerityType = .normal
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var inputCodeLabels: [UILabel]!
    @IBOutlet weak var phoneNumbelLabel: UILabel!
    @IBOutlet var descLabels: [UILabel]!
    @IBOutlet weak var titleLabel: UILabel!
    @objc
    @IBOutlet dynamic weak var codeTextField: UITextField!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    var secondTime = 60
    
    var timer : Timer?
    private func isComplete() -> Bool{
        
        guard let text = self.codeTextField.text else {
            return false
        }
        return text.length == 6
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.onboardingController.userState == .changePassword {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "register_goback"), style: .plain, target: self, action: #selector(goBackAction))
        }else if(self.type == .resetPassword){
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "register_goback"), style: .plain, target: self, action: #selector(goBackAction))
        }
        self.setupUI()
        self.addObserverAction()
        self.timeBtn.isUserInteractionEnabled = false
        self.codeTextField.delegate = self;
        let attributes = [NSAttributedString.Key.foregroundColor:TXTheme.secondColor(),NSAttributedString.Key.font:TXTheme.secondTitleFont(size: 23),NSAttributedString.Key.baselineOffset:NSNumber.init(value: -3)]
        let attriText = NSMutableAttributedString.init(string: "•", attributes: attributes)
        let stringText = " " + self.onboardingController.countryState.callingCode + " " + TXTheme.phoneNumFormartString(string: (self.onboardingController.phoneNumber?.userInput ?? ""))
        let phoneText = NSAttributedString.init(string: stringText)
        attriText.append(phoneText)
        self.phoneNumbelLabel.attributedText = attriText
        if self.type != .resetPassword {
            self.beginTimer()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self.view);
        let filedpoint = self.view.convert(point!, to: self.codeTextField);
        if self.codeTextField.bounds.contains(filedpoint) {
            self.codeTextField.becomeFirstResponder();
        } else {
            self.codeTextField.endEditing(true);
        }
    }
    @objc
    private func goBackAction(){
        if self.onboardingController.userState == .changePassword   {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.type != .resetPassword {
            self.codeTextField.becomeFirstResponder()
        }

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.type != .resetPassword {
            self.codeTextField.resignFirstResponder()
        }
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

    private func beginTimer(){
        self.timeBtn.isUserInteractionEnabled = false
        self.endTimerAction()
        self.secondTime = 60
        self.timer = Timer.init(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: .common)
    }
    @objc func timerAction(){
        if self.secondTime > 0 {
            let timeString = NSMutableAttributedString.init(string: "重新发送")
            let secondText = String(self.secondTime) + "S"
            let secondString = NSAttributedString.init(string: secondText, attributes: [NSAttributedString.Key.foregroundColor:TXTheme.secondColor()])
            timeString.append(secondString)
            self.timeBtn.titleLabel?.attributedText = timeString

            self.timeBtn.setAttributedTitle(timeString, for: .normal)
            self.secondTime -= 1
        }else{
            let timeString = NSMutableAttributedString.init(string: "重新发送")
            self.timeBtn.titleLabel?.attributedText = timeString
            self.timeBtn.setAttributedTitle(timeString, for: .normal)
            self.timeBtn.isUserInteractionEnabled = true
            self.endTimerAction()
        }
        
    }
    private func formartString(string : String) -> String{
        let num = string.length / 3
        var remainder = string.length % 3
        var firstString : String
        var secondString : String
        let thirdString : String
        var parserText = string
        
        if num > 0,remainder > 0 {
            thirdString = string.substring(from: string.length - (num + 1))
            parserText = string.substring(to: string.length - thirdString.length)
            remainder = parserText.length % num
            if remainder > 0 {
                secondString = parserText.substring(from: parserText.length - (num + 1))
            }else{
                secondString = parserText.substring(from: parserText.length - num)
            }
            firstString = parserText.substring(to: parserText.length - secondString.length)
            
            return firstString + " " + secondString + " " + thirdString
            
        }else if num > 0, remainder == 0{
            thirdString = string.substring(from: string.length - (num))
            parserText = string.substring(to: string.length - thirdString.length)
            secondString = parserText.substring(from: parserText.length - num)
            firstString = parserText.substring(to: parserText.length - secondString.length)
            return firstString + " " + secondString + " " + thirdString

        }else{
            return parserText
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let newText = (text as NSString).replacingCharacters(in: range, with: string)

        
        if newText.length > 6 {
            self.nextBtn.isUserInteractionEnabled = true
            return false
        }
        
        if newText.length == 6 {
            self.nextBtn.isUserInteractionEnabled = true
        }else
        {
            self.nextBtn.isUserInteractionEnabled = false
        }
        for (index , label) in self.inputCodeLabels.enumerated() {
            if index < newText.length {
                let text = newText.substring(from: index)
                label.text = text.substring(toIndex: 1)
            }else{
                label.text = ""
            }
    
        }
        return true
    }
    
    
    private func setupUI(){
        if !UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 111.0
        }
        self.titleLabel.textColor = TXTheme.titleColor()
        self.titleLabel.font = TXTheme.secondTitleFont(size: 23)
        self.phoneNumbelLabel.textColor = TXTheme.titleColor()
        self.timeBtn.setTitleColor(TXTheme.fourthColor(), for: .normal)
        self.timeBtn.titleLabel?.font = TXTheme.thirdTitleFont(size: 12)
        self.nextBtn.titleLabel?.font = TXTheme.thirdTitleFont(size: 13)
        self.nextBtn.setTitleColor(TXTheme.titleColor(), for: UIControl.State.normal)
        for label in self.descLabels {
            label.textColor = TXTheme.fourthColor()
            label.font = TXTheme.thirdTitleFont(size: 12)
        }
        for label in self.inputCodeLabels {
            label.backgroundColor = TXTheme.thirdColor()
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            if self.type == .resetPassword {
                label.isHidden = true
            }
        }
        self.updateUIAction()
    }
    private func updateUIAction(){
        
        
        switch type {
        case .normal:
            self.updateNormalUI()
        case .resetPassword:
            do{
                self.titleLabel.text = "设置密码"
                self.nextBtn.setTitle("发送验证码", for: .normal)
                let label = self.descLabels[0]
                label.text = "验证码发送至："
                let secondLabel = self.descLabels[1]
                secondLabel.isHidden = true
                self.timeBtn.isHidden = true
            }

        default:
            do{
                self.titleLabel.text = "设置密码"
                self.nextBtn.setTitle("发送验证码", for: .normal)
                let label = self.descLabels[0]
                label.text = "验证码发送至："
                let secondLabel = self.descLabels[1]
                secondLabel.isHidden = true
                self.timeBtn.isHidden = true
            }
        }
      
    }
    
    private func updateNormalUI(){
        switch self.onboardingController.userState {
                   case .isRegister:
                       self.titleLabel.text = "验证码"
                       self.nextBtn.setTitle("下一步", for: .normal)
                   case .accountLogin:
                       self.titleLabel.text = "设置密码"
                       self.nextBtn.setTitle("下一步", for: .normal)
                   case .codeLogin:
                       self.titleLabel.text = "验证码"
                       self.nextBtn.setTitle("登录Pigram", for: .normal)
                   case .changePassword:
                       self.titleLabel.text = "设置密码"
                       self.nextBtn.setTitle("下一步", for: .normal)
                    case .oldPhoneCode :
                        self.titleLabel.text = "验证码"
                        self.nextBtn.setTitle("下一步", for: .normal)
                    case .resetPhoneWithCode:
                        fallthrough
                    case .resetPhoneWithPassword:
                        self.titleLabel.text = "新手机号验证码"
                        self.nextBtn.setTitle("下一步", for: .normal)
                   }
    }

    @IBAction func nextStepAction(_ sender: UIButton) {
//        self.codeTextField.resignFirstResponder()
        switch type {
        case .normal:
            self.noramlAction()
        case .resetPassword://
            do{
                 self.onboardingController.requestVerification(fromViewController: self, isSMS: true)
             }
 
        default:
            do{
                 self.onboardingController.requestVerification(fromViewController: self, isSMS: true)
            }
        }
    }
    
    
    
    
    
    private func noramlAction(){
        switch onboardingController.userState {
        case .codeLogin:
            self.codeLoginAction()
        case .resetPhoneWithCode:
            self.getNewPhoneCodeAction()
            break
        case .resetPhoneWithPassword:
            self.getNewPhoneCodeAction()
            break
        default:
            self.tryToVerify()

        }

    }
    
    

    
    //MARK:-  提交修改密码
    private func getNewPhoneCodeAction(){
        guard let text = self.codeTextField.text else {
              //请输入
              return
          }
          if text.length != 6 {
              //输入码长度不对
              return
          }
        self.onboardingController.update(password: text)
        
        if self.onboardingController.userState == .resetPhoneWithCode {
            self.onboardingController.requestChangePhoneWithCode(fromVC: self)

        }else{
            self.onboardingController.requestChangePhoneWithPassword(fromVC: self)

        }
        
    }
    
    private func codeLoginAction(){
        guard let text = self.codeTextField.text else {
              //请输入
              return
          }
          if text.length != 6 {
              //输入码长度不对
              return
          }
        //调用验证码登录接口
        self.onboardingController.update(textCode: text)
        self.onboardingController.update(isPassword: false)
        self.onboardingController.txRequestLoginAction(fromViewController: self)
         
    }
    private func toResetPasswordAction(){
        self.onboardingController.onboardingResetPassword(viewController: self)
    }
    
    @IBAction func sendCodeAction(_ sender: UIButton) {
        
        if self.type != .resetPassword {
        
          self.onboardingController.requestVerificationCode(fromViewController: self, isSMS: true) { (controller) in
            if self.type != .resetPassword{
                 self.beginTimer()
             }
          }
        }
      
    }
    private func tryToVerify() {
        Logger.info("")
        guard let codeText = self.codeTextField.text else {
            return
        }
        if codeText.length != 6 {
            return
        }
        onboardingController.update(textCode: codeText)
        onboardingController.txVerificationCode(fromViewController: self, success: {[weak self] in
                self?.entryNextAction()
        }) {
            OWSAlerts.showAlert(title: "验证失败")
        }

    }
    private func entryNextAction(){
        switch self.onboardingController.userState {
            case .isRegister://去注册界面
                self.onboardingController.onboardingDidNickName(viewController: self)
            break
            case .oldPhoneCode:
                self.onboardingController.entryResetPhoneThroughCode(fromVC: self)
            case .accountLogin://进入重设密码
            fallthrough
            case .changePassword:
                self.toResetPasswordAction()
                break
        default :
            break
       }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.endTimerAction()
    }
    deinit {
        self.endTimerAction()
        self.removerObserverAction()
    }

    private func endTimerAction(){
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
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
