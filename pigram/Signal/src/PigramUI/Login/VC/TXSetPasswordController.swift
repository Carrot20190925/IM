//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXSetPasswordController: TXBaseController {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet var inputTextFields: [UITextField]!
    @IBOutlet var inputBackViews: [UIView]!
    @IBOutlet var tagLabels: [UILabel]!
    @IBOutlet weak var nextBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.addObserverAction()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let firstTF = self.inputTextFields[0]
        firstTF.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    private func setupUI(){
        if !UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 111.0
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title:kPigramLocalizeString("取消", "取消") , style: .plain, target: self, action: #selector(jumpAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title:kPigramLocalizeString("跳过", "跳过") , style: .plain, target: self, action: #selector(jumpAction))
        self.titleLabel.textColor = TXTheme.titleColor()
        self.titleLabel.font = TXTheme.secondTitleFont(size: 23)
        var color = TXTheme.titleColor()
        let font = TXTheme.thirdTitleFont(size: 13)
        let attributes = [NSAttributedString.Key.foregroundColor:TXTheme.secondColor()]

        for (index,label) in self.tagLabels.enumerated() {
            label.textColor = color
            label.font = font
            let stringPlacehode = NSMutableAttributedString.init(string: "• ", attributes: attributes)
            let appendStr:NSAttributedString
            if index == 0 {
                appendStr = NSAttributedString.init(string:kPigramLocalizeString("设置一个好记的密码！", "设置一个好记的密码！") )
            }else
            {
                appendStr = NSAttributedString.init(string:kPigramLocalizeString("请确认密码！", "请确认密码！"))
            }
            stringPlacehode.append(appendStr)
            label.attributedText = stringPlacehode
        }
        color = TXTheme.thirdColor()
        for backView in self.inputBackViews {
            backView.layer.cornerRadius = 25
            backView.clipsToBounds = true
            backView.backgroundColor = color
        }
        self.nextBtn.titleLabel?.font = TXTheme.thirdTitleFont(size: 13)
        self.nextBtn.setTitleColor(TXTheme.titleColor(), for: UIControl.State.normal)
    }
    @objc
    private func jumpAction(){
        self.toMainControllerAction()
    }
    
    private func toMainControllerAction(){
        self.view.endEditing(true)
        UserDefaults.standard.set(1, forKey: "tx_login_or_regsiter_success")
        UserDefaults.standard.synchronize()
        UIApplication.shared.keyWindow?.rootViewController = BaseTabBarVC.init()
    }
        
    private func alertActionWithMessage(message:String){
        let alert = UIAlertController.init(title: message, message: nil, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "好", style: .default) { (action) in
                
        }
        alert.addAction(action)
        self.presentAlert(alert, animated: true)
    }
    @IBAction func nextStepAction(_ sender: UIButton) {
        for textField in self.inputTextFields{
            textField.resignFirstResponder()
        }
        guard let firstText = self.inputTextFields[0].text else {
            //密码为空
            OWSAlerts.showAlert(title: "密码不能为空！")
            return
        }
        if !firstText.isPassword() {
            OWSAlerts.showAlert(title: "8-20位字母和数字组成，区分大小写！")
            //密码不符合字母数字组合
            return
        }
        //  调用重设密码接口
       guard  let secondText = self.inputTextFields[1].text  else {
           OWSAlerts.showAlert(title: "请确认密码！")
           //  再次输入
           return
       }
       if !(firstText == secondText) {
            OWSAlerts.showAlert(title: "密码不一致！")
           //两次密码不一致
       }
        self.view.endEditing(true)
        self.onboardingController.update(password: firstText)
        self.onboardingController.txRequestForSetPassword(fromViewController: self)
            
        
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
        self.bottomContraint.constant = keyBoardHeight
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
