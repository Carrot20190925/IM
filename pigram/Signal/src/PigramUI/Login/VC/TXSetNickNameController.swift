//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXSetNickNameController: TXBaseController {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldBackView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nickTagLabel: UILabel!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.addObserverAction()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.nickNameTextField.becomeFirstResponder()
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
    private func setupUI(){
        
        if !UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 111.0
        }
        
        self.titleLabel.textColor = TXTheme.titleColor()
        self.titleLabel.font = TXTheme.secondTitleFont(size: 23)
        self.nickTagLabel.textColor = TXTheme.titleColor()
        self.nickTagLabel.font = TXTheme.thirdTitleFont(size: 13)
        let attributes = [NSAttributedString.Key.foregroundColor:TXTheme.secondColor()]
        let nickPlacehode = NSMutableAttributedString.init(string: "• ", attributes: attributes)
        let appendStr = NSAttributedString.init(string:kPigramLocalizeString("取个好点的昵称吧！", "取个好点的昵称吧！") )
        nickPlacehode.append(appendStr)
        self.nickTagLabel.attributedText = nickPlacehode
        self.nickNameTextField.placeholder = kPigramLocalizeString("设置昵称（8个字以内）", "设置昵称（8个字以内）")
        let placeView = UIView.init(frame: CGRect.init(x: 20, y: 0, width: 20, height: 12))
        placeView.backgroundColor = TXTheme.titleColor()
        self.textFieldBackView.layer.cornerRadius = 25
        self.textFieldBackView.clipsToBounds = true
        self.textFieldBackView.backgroundColor = TXTheme.thirdColor()
        self.nextBtn.titleLabel?.font = TXTheme.thirdTitleFont(size: 13)
        self.nextBtn.setTitleColor(TXTheme.titleColor(), for: UIControl.State.normal)
        
    }
    @IBAction func nextStepAction(_ sender: UIButton) {
        self.nickNameTextField.acceptAutocorrectSuggestion()
        guard let nickName = self.nickNameTextField.text?.trimmingCharacters(in: .whitespaces)  else {
            OWSAlerts.showAlert(title:kPigramLocalizeString("昵称不能为空", "昵称不能为空"))
            return
        }
        if nickName.count == 0 {
            OWSAlerts.showAlert(title:kPigramLocalizeString("昵称不能为空", "昵称不能为空") )
            return
        }
        guard let data = nickName.data(using: .utf8) else {
            OWSAlerts.showAlert(title:kPigramLocalizeString("昵称不能为空", "昵称不能为空") )
            return
        }

        if data.count > 26 {
            OWSAlerts.showAlert(title:kPigramLocalizeString("昵称太长了亲", "昵称太长了亲"))
            return
        }
        if let phoneNumber = self.onboardingController.phoneNumber?.userInput {
            
            let countryCode = self.onboardingController.countryState.countryCode
            let dic = ["countryCode":countryCode,"phoneNum" : phoneNumber]
            UserDefaults.standard.setValue(dic, forKey: "pigram_last_regsiter_login_country_code_and_num")
            UserDefaults.standard.synchronize()
        }
        self.onboardingController.update(nickName: nickName)
        self.onboardingController.txRegister(fromViewController: self, success: {
        
            }) {
                let alert = UIAlertController.init(title:kPigramLocalizeString("校验失败", "校验失败") , message: nil, preferredStyle: .alert)
                let action = UIAlertAction.init(title:kPigramLocalizeString("确认", "确认") , style: .default) { (action) in
                }
                alert.addAction(action)
                self.presentAlert(alert, animated: true)
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
