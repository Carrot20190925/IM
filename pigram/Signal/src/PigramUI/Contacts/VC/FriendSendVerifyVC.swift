//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class FriendSendVerifyVC: BaseVC {

    
    var model: OWSUserProfile?
    var channel: PigramFriendChannel = .number;
    public var fromGroupId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "申请验证";
        self.setupSubview();
        // Do any additional setup after loading the view.
    }
    
    private func setupSubview() {
        self.view.backgroundColor = UIColor.white;
        let verifyLabel = UILabel.init();
        verifyLabel.font = UIFont.systemFont(ofSize: 12);
        verifyLabel.textColor = UIColor.init(hexString: "#273d52");
        verifyLabel.text = "你需要发送验证申请，等对方通过";
        
        let remarkLabel = UILabel.init();
        remarkLabel.font = UIFont.systemFont(ofSize: 12);
        remarkLabel.textColor = UIColor.init(hexString: "#273d52");
        remarkLabel.text = "为朋友设置备注（可选）";
        
        let vField = UITextField.init();
        vField.borderStyle = .none;
        vField.font = UIFont.systemFont(ofSize: 15);
        vField.textColor = UIColor.hex("#1e3040");
        self.verifyField = vField;
        
        let rField = UITextField.init();
        rField.attributedPlaceholder = NSAttributedString.init(string: "请输入好友备注", attributes: [NSAttributedString.Key.foregroundColor : TXTheme.titleColor()])

        rField.borderStyle = .none;
        rField.font = UIFont.systemFont(ofSize: 15);
        rField.textColor = UIColor.hex("#1e3040");
        self.remarkField = rField;
        
        
        self.view.addSubview(verifyLabel);
        self.view.addSubview(remarkLabel);
        self.view.addSubview(self.verifyField!);
        self.view.addSubview(self.remarkField!);
        
        let top = UIDevice.current.hasIPhoneXNotch ? 88 + 20 : 64 + 20
        verifyLabel.mas_makeConstraints {[weak self] (make) in
            if #available(iOS 11.0, *) {
                make?.top.equalTo()(self?.view.mas_safeAreaLayoutGuideTop)?.offset()(20)
            } else {
                make?.top.mas_equalTo()(top);
                // Fallback on earlier versions
            };
            make?.left.offset()(30);
        }
        
        self.verifyField?.mas_makeConstraints({ (make) in
            make?.left.offset()(30);
            make?.top.equalTo()(verifyLabel.mas_bottom)?.offset()(12);
            make?.right.offset()(-30);
            make?.height.offset()(30);
        })
        
        remarkLabel.mas_makeConstraints { (make) in
            make?.left.offset()(30);
            make?.top.equalTo()(self.verifyField?.mas_bottom)?.offset()(12);
        }
        
        self.remarkField?.mas_makeConstraints({ (make) in
            make?.left.offset()(30);
            make?.top.mas_equalTo()(remarkLabel.mas_bottom)?.offset()(12);
            make?.right.offset()(-30);
            make?.height.offset()(30);
        })
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "发送", style: .plain, target: self, action: #selector(confirmBtnClick));
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blue;
        
        self.verifyField?.text = "你好，我是\(OWSProfileManager.shared().localProfileName() ?? "")" ;
        

        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.verifyField?.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews();
        if self.verifyField?.layer.sublayers?.count == 1{
            self.verifyField?.addBorder(side: .bottom, thickness: 1.0, color: UIColor.hex("#868686"));
            self.remarkField?.addBorder(side: .bottom, thickness: 1.0, color: UIColor.hex("#868686"));
        }

        
    }
    

    @objc
    func confirmBtnClick() {
//        - parameter destinationId: 好友的userid
//        - parameter addingWay: 添加方式
//        - parameter remarkName: 添加方式
//        - parameter applyMsg: 添加方式
//           0: by number, 1: by scanning, 3:by , 4: by ;
//        let remarkText = self.remarkField?.text;
        
        guard let destinationId = self.model?.address.phoneNumber else {
            OWSAlerts.showErrorAlert(message: "未查到好友")
            return
        }
        var addingWay : Int = 0
        switch self.channel {
        case .number:
            addingWay = 0
            break;
        case .scan:
            addingWay = 1
            break;
        case .group:
            addingWay = 2;
            break;
        case .link:
            addingWay = 5;
        default:
            addingWay = 0;
            break;
        }
        var params  = ["destinationId":destinationId,"addingWay":addingWay] as [String : Any]
        
        if  let text = self.verifyField?.text{
            params["applyMsg"] = text
        }
        
        if let groupId = self.fromGroupId {
            params["groupId"] = groupId;
        }
        
        let remarkName = self.remarkField?.text?.trimmingCharacters(in: .whitespaces)
        if let data = remarkName?.data(using: .utf8) {
            if data.count > 26 {
                OWSAlerts.showAlert(title: "备注名称太长，最多8个字")
                return
            }
            if let remarkText = remarkName {
                params["remarkName"] = remarkText
            }
        }
        
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) { (modal) in
            PigramNetworkPromise.pgAddFriendPromise(params: params).done {[weak self] (response) in
                SSKEnvironment.shared.databaseStorage.write { (write) in
                    let proflie = OWSUserProfile.getOrBuild(for: SignalServiceAddress.init(phoneNumber: destinationId), transaction: write)
                    proflie.anyUpdate(transaction: write) { (profile) in
                        proflie.remarkName = self?.remarkField?.text
                    }
                }
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showAlert(title: "申请成功")
                    }
                }
            }.catch { (error) in
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showAlert(title: error.localizedDescription)
                    }
                }

            }.retainUntilComplete()
        }


       
        
    }
    
    private var verifyField: UITextField?
    
    private var remarkField: UITextField?
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
