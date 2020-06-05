//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class PigramPGVC: BaseVC,UITextFieldDelegate {
    
    enum PGType {
        case person
        case group
    }
    var groupModel : TSGroupModel?
    @IBOutlet weak var toastLabel: UILabel!
    @IBOutlet weak var inputTF: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet var descLabels: [UILabel]!
    @IBOutlet weak var titleTagLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    var type = PGType.person
    
    var setupSuccess : ((_ link : String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        
    }
    
    private func initUI(){
        self.titleTagLabel.font = TXTheme.PG_titleTagFont()
        self.toastLabel.font = TXTheme.PG_toastFont()
        let font = TXTheme.PG_descFont()
        let color = TXTheme.PG_descColor()
        for label in self.descLabels {
            label.font = font
            label.textColor = color
        }
        self.linkLabel.font = TXTheme.PG_linkFont()
        self.saveBtn.titleLabel?.font = TXTheme.PG_saveFont()
        self.titleTagLabel.textColor = TXTheme.PG_titleTagColor()
        self.toastLabel.textColor = TXTheme.PG_toastColor()
        self.toastLabel.isHidden = true
        self.linkLabel.textColor = TXTheme.PG_linkColor()
        self.saveBtn.setTitleColor(TXTheme.PG_saveTitleColor(), for: .normal)
        self.linkLabel.isHidden = true
        let descLabel = self.descLabels[2]
        descLabel.isHidden = true
        self.saveBtn.backgroundColor = TXTheme.PG_saveBackColor()
        self.inputTF.delegate = self
        let longpress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressLink(press:)))
        self.linkLabel.addGestureRecognizer(longpress)
        self.loadData()

        
        if self.type == .person {
            self.title = "PG号"

        }else{
            self.title = "群链接"
            self.titleTagLabel.text = "输入您群链接"
            let descOne = self.descLabels[0]
            descOne.text = "您可以在Pigram上设置一个群链接，设置后，别人将能够在不知您的群信息的情况下，通过此链接找到此群"
            let descThird = self.descLabels[2]
            descThird.text = "此链接会打开一个群聊窗口："
            
        }
    }
    
    @objc
    private func longPressLink(press : UILongPressGestureRecognizer){
        if press.state == .began {
            let paste = UIPasteboard.general
            paste.string = self.linkLabel.text
            OWSAlerts.showAlert(title: "复制成功")
        }
    }
    
    
    
    private func loadData(){
        if self.type == .person {
            PigramNetworkMananger.pg_getMyInfo(success: {[weak self] (response) in
                if let data = response as? [String : Any] ,let link = data["link"] as? String,link.count > 0{
                    self?.inputTF.text = link
                    self?.setLinkSuccess(link: link)
                }
                MyLog(response)
                
            }) { (error) in
                
            }
        }else{
            if let link = self.groupModel?.linkString,link.count > 0 {
                self.inputTF.text = link
                self.setLinkSuccess(link: link)
            }
        }

    }

    @IBAction func saveAction(_ sender: UIButton) {
        guard let text = self.inputTF.text,text.count >= 5 else{
            OWSAlerts.showAlert(title: "长度不对")
            return
        }
        if !text.isPGAccount() {
            OWSAlerts.showAlert(title: "格式不对请检查是不是有其他特殊符号")
            return
        }
        
        
        PigramNetworkMananger.pg_createLink(text, groupId: self.groupModel?.groupId, success: {[weak self] (response) in
            MyLog(response)
            OWSAlerts.showAlert(title: "设置成功")
            self?.setupSuccess?(text)

            self?.setLinkSuccess(link: text)

        }) {[weak self] (error) in
            self?.setupError(error: error as NSError)
            MyLog(error)
        }
        
    }
    
    
    
    func setLinkSuccess(link : String)  {
                    
        self.linkLabel.isHidden = false
        self.toastLabel.isHidden = false
        self.linkLabel.text = "https://p.land/\(link)"
        let descLabel = self.descLabels[2]
        descLabel.isHidden = false
    }
    
    
    func setupError(error : NSError)  {
        switch error.code {
        case 406:
            OWSAlerts.showAlert(title: "权限不足")
        case 412:
            OWSAlerts.showAlert(title: "链接已经被占用")
        case 417:
            OWSAlerts.showAlert(title: "链接名字包含非法字符串或者长度不在3-32之间")
        default:
            break
        }
    }

}



