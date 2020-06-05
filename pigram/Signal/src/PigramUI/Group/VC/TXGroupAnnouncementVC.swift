//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXGroupAnnouncementVC: BaseVC {

    enum AnnounceMentType {
        case normal
        case creat
    }
    var notice : String?
    var isOwer : Bool = true
    
    var type = AnnounceMentType.creat
    var textView : UITextView?
    var complete : ((_ text:String,_ announcementVC:TXGroupAnnouncementVC) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNav()
        if self.type == .creat {
            self.setupCreatUI()
        }else{
            self.setupNormalUI()
        }
        
    }
    func setupNav() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-leftBack"), style: .plain, target: self, action: #selector(goBack))
    }
    @objc
    func goBack() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    private func setupCreatUI() {
        self.title = "群公告"
        let label = UILabel.init()
        label.textColor = TXTheme.titleColor()
        label.font = TXTheme.mainTitleFont()
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineSpacing = 15
        paragraphStyle.alignment = NSTextAlignment.center
        let attriText = NSMutableAttributedString.init(string: "暂无群公告\n", attributes: [NSAttributedString.Key.font : TXTheme.mainTitleFont(size: 22),NSAttributedString.Key.paragraphStyle : paragraphStyle])
        let appendText = NSAttributedString.init(string: "群公告适用于发布群规，群活动等信息", attributes: nil)
  
        attriText.append(appendText)
        label.attributedText = attriText
        let creatBtn = UIButton.init()
        creatBtn.setTitleColor(UIColor.white, for: .normal)
        creatBtn.setTitle("立即创建", for: .normal)
        creatBtn.backgroundColor = TXTheme.secondColor()
        creatBtn.layer.cornerRadius = 20
        creatBtn.clipsToBounds = true
        creatBtn.addTarget(self, action: #selector(entryEdit), for: .touchUpInside)
        
        self.view.addSubview(label)
        self.view.addSubview(creatBtn)
        let top : CGFloat
        if UIDevice.current.hasIPhoneXNotch {
            top = 88 + 100
        }else{
            top = 64 + 100
        }
        label.mas_makeConstraints {(make) in
            make?.left.mas_equalTo()(20)
            make?.right.mas_equalTo()(-20)
            make?.top.mas_equalTo()(top)
        }
        creatBtn.mas_makeConstraints { [weak self] (make) in
            make?.centerX.mas_equalTo()(self?.view.mas_centerX)
            make?.top.mas_equalTo()(label.mas_bottom)?.offset()(60)
            make?.height.mas_equalTo()(40)
            make?.width.mas_equalTo()(120)
        }
        
    }
    @objc
    private func entryEdit(){
        let editVC = TXGroupAnnouncementVC.init()
        editVC.type = TXGroupAnnouncementVC.AnnounceMentType.normal
        editVC.complete = complete
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    deinit {
        
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
extension TXGroupAnnouncementVC:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.length < 1 {
            textView.text = "填写公告，1-200字"
        }
    }
    func textViewDidChange(_ textView: UITextView) {
//        if textView.text.length < 1 {
//            textView.text = "填写公告，1-600字"
//        }

    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "填写公告，1-200字" {
            textView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        var string = textView.text
//        if string == "填写公告，1-600字" {
//            textView.text = ""
//            string = ""
//        }
//        guard let r = string?.toRange(range) else { return true }
//        string =  string?.replacingCharacters(in: r, with: text)
//        if string?.length == 0 {
//            textView.text = "填写公告，1-600字"
//        }
        return true
    }
    private func setupNormalUI(){
          if self.isOwer {
            self.title = "编辑群公告"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "发布", style: .plain,  target: self, action: #selector(updateAnnounceMent))
          }else{
            self.title = "群公告"
          }
          let backView = UIView.init()
          backView.layer.cornerRadius = 5
          backView.clipsToBounds = true
          backView.backgroundColor = TXTheme.thirdColor()
          let textView = UITextView.init()
          textView.isUserInteractionEnabled = self.isOwer
          if let  notice = self.notice,notice.length != 0 {
            textView.text = notice
          }else{
            textView.text = "填写公告，1-200字"
          }
          textView.textColor = TXTheme.titleColor()
          textView.backgroundColor = UIColor.clear
          textView.delegate = self
          self.textView = textView
          backView.addSubview(textView)
          self.view.addSubview(backView)
          let top : CGFloat
          if UIDevice.current.hasIPhoneXNotch {
              top = 88 + 20
          }else{
              top = 64 + 20
          }
          backView.mas_makeConstraints { (make) in
              make?.top.mas_equalTo()(top)
              make?.left.mas_equalTo()(20)
              make?.right.mas_equalTo()(-20)
              make?.height.mas_equalTo()(backView.mas_width)
          }
          textView.mas_makeConstraints { (make) in
              make?.left.top()?.mas_equalTo()(20)
              make?.bottom.right()?.mas_equalTo()(-20)
          }
      }
    @objc
    func updateAnnounceMent() {//发布新的更新公告
        guard let text = self.textView?.text else {
            return
        }
        if let data = text.data(using: .utf8), data.count > 600 {
            OWSAlerts.showAlert(title: "填写公告，最多200字")
            return
        }
        self.complete?(text,self)

//        self.navigationController?.dismiss(animated: true, completion: {[weak self] in
//        })

    }
}


extension String {
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
}
