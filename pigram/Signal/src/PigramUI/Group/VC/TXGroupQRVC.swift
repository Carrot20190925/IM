//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXGroupQRVC: BaseVC {
    
    enum `Type` {
        case group
        case persion
    }
    var type = Type.group
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var qrBackView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var QRImageView: UIImageView!
    var thread : TSGroupThread?
    @IBOutlet var actionBtns: [DYButton]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        if self.type == .group{
            self.title = "群聊二维码"
            self.setupData()

        }else{
            self.title = "我的二维码"
            self.setupPersonData()
        }
        
        
        
        
        
    }
    
    private func setupPersonData(){

        
        let localMgr = OWSProfileManager.shared()

        let content = TSAccountManager.localUserId ?? ""
        let name = localMgr.localProfileName() ?? ""
        
        let attriText = NSMutableAttributedString.init(string: name + "\n", attributes: nil)
        
        if let dic = UserDefaults.standard.object(forKey: "pigram_last_regsiter_login_country_code_and_num") as? [String : String]{
            if let lastRegisteredCountryCode = dic["countryCode"],lastRegisteredCountryCode.length > 0  {
               let  countryCode = lastRegisteredCountryCode
               let  countryName = PhoneNumberUtil.countryName(fromCountryCode: countryCode)
                let appendText = NSAttributedString.init(string:countryName ?? "", attributes: [NSAttributedString.Key.font : TXTheme.secondTitleFont(size: 12),NSAttributedString.Key.foregroundColor : TXTheme.rgbColor(148, 148, 148)])
                attriText.append(appendText)
            }
        }
        self.groupNameLabel.attributedText = attriText
        let jsonString = "pigram://p.land?u=\(content)"
        self.QRImageView.backgroundColor = UIColor.clear
        var avatarImage = localMgr.localProfileAvatarImage() ?? OWSContactAvatarBuilder.init(forLocalUserWithDiameter: kLargeAvatarSize).buildDefaultImage()
        avatarImage = UIImage.init(clipImage:avatarImage ?? UIImage.init())
        avatarImage = UIImage.init(border: 2, color: UIColor.white, image: avatarImage ?? UIImage.init())
        self.groupImageView.image = avatarImage
        let image = TXTheme.getQRCodeImage(jsonString, fgImage: avatarImage)
        self.QRImageView.image = image
        self.descLabel.text = "扫一扫上面的二维码图案，加入我的Pigram"

    }
    
    private func setupUI(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "pg_scan_tag")?.withRenderingMode(.alwaysOriginal), style: UIBarButtonItem.Style.plain, target: self, action: #selector(txEntrySearch))
//        self.navigationController.naite
        if UIDevice.current.hasIPhoneXNotch {
            self.topConstraint.constant = 168
        }
        var color = TXTheme.rgbColor(240, 243, 249)
        self.view.backgroundColor = color
        self.qrBackView.backgroundColor = color
        self.groupImageView.layer.cornerRadius = 25
        self.groupImageView.clipsToBounds = true
        self.backView.backgroundColor = UIColor.white
        self.groupNameLabel.font = TXTheme.thirdTitleFont(size: 15)
        self.descLabel.font = TXTheme.thirdTitleFont(size: 12)
        color = TXTheme.titleColor()
        self.descLabel.textColor = color
        self.groupNameLabel.textColor = color
        self.backView.layer.cornerRadius = 10
        self.backView.clipsToBounds = true
        self.qrBackView.layer.cornerRadius = 5
        self.qrBackView.clipsToBounds = true
        let images = ["pg_photo_save","pg_share_qr"]
        for (index,button) in self.actionBtns.enumerated() {
            button.setTitleColor(color, for: .normal)
            button.layer.cornerRadius = 20
            button.clipsToBounds = true
            button.margin = 10
            button.direction = 1
            button.setImage(UIImage.init(named: images[index])?.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
    }
    
    private func setupData(){
        
        guard let model = self.thread?.groupModel else {
            OWSAlerts.showErrorAlert(message: "群信息错误")
            return
        }
        let name = model.groupName ?? "新群组"
        let attriText = NSMutableAttributedString.init(string: name + "\n", attributes: nil)

        
        self.groupNameLabel.attributedText = attriText

        
        var image = OWSAvatarBuilder.buildImage(thread: self.thread!, diameter: UInt(self.groupImageView.size.width));

        
        self.groupImageView.image = image
//        let image =
        self.descLabel.text = "扫一扫上面的二维码图案，加入此群聊"
        image = UIImage.init(clipImage:image ?? UIImage.init())
        image = UIImage.init(border: 2, color: UIColor.white, image: image ?? UIImage.init())
        let  jsonString = "pigram://p.land?g=\(model.groupId)"
        let qrImage = TXTheme.getQRCodeImage(jsonString, fgImage: image)
        self.QRImageView.image = qrImage
    }

    //保存群
    @IBAction func saveImage(_ sender: UIButton) {
        guard let _ = self.QRImageView.image else {
            return
        }
        UIGraphicsBeginImageContextWithOptions(self.backView.bounds.size, false, 0.0)
        if let  context = UIGraphicsGetCurrentContext(){
            self.backView.layer.render(in: context)
            if let viewImage = UIGraphicsGetImageFromCurrentImageContext(){
                TXTheme.saveImage(image: viewImage)
            }
        }
        UIGraphicsEndImageContext();//移除栈顶的基于当前位图的图形上下文
    }
    //分享群
    @IBAction func shareAction(_ sender: UIButton) {
        
        OWSAlerts.showActionSheet(fromVC: self, title: "分享二维码名片", message: "请选择分组", options: ["我的群组","我的群聊","我的好友"]) { [weak self] (index) in
            
            if index == 1 {
                if let thread = self?.thread{
                    GroupListVC.showGroupSelectVC(fromVC: self!, filters: [thread.groupModel]) { [weak self] (vc, results) in
                           if results != nil {
                               self?.handleOpationResults(vc:vc, results: results!);
                           }
                     }
                }else{
                    GroupListVC.showGroupSelectVC(fromVC: self!, filters: nil) { [weak self] (vc, results) in
                           if results != nil {
                               self?.handleOpationResults(vc:vc, results: results!);
                           }
                     }
                }

                
            } else if index == 2 {
                
                let contactVC = ContactListVC.init()
                contactVC.navTitle = "选择好友"
                contactVC.rightNavTitle = "完成"
                contactVC.filters = ["___officer____!"]
                contactVC.showVC(fromVC: self) {[weak self] (vc, results) in
                    self?.handleOpationResults(vc:vc,results: results);

                }
               
            }else{
                guard let nav = self?.navigationController else {
                    return
                }
                PGGroupsVC.showSeletedGroupsVC(fromVC: nav) {[weak self] (results, vc) in
                    self?.handleOpationResults(vc:vc,results: results);

                }
                
            }
            
        }
    }
    private func handleOpationResults<T>(vc: UIViewController, results: [T]) {
        if results.count == 0 {
            OWSAlerts.showAlert(title: "请至少选择一项！");
            return;
        }
        if self.QRImageView.image == nil {
            OWSAlerts.showAlert(title: "没有生成二维码！");
            return;
        }
        
//        var qrImg = UIImage.init(ciImage: (self.QRImageView.image?.ciImage)!);
//        qrImg = qrImg.resize(width: qrImg.size.width, height: qrImg.size.height)!;
        
        
        guard let _ = self.QRImageView.image else {
            return
        }
        
        var image : UIImage?
        UIGraphicsBeginImageContextWithOptions(self.backView.bounds.size, false, 0.0)
        if let  context = UIGraphicsGetCurrentContext(){
            self.backView.layer.render(in: context)
            if let viewImage = UIGraphicsGetImageFromCurrentImageContext(){
                image = viewImage
            }else{
                return
            }
            
        }
        UIGraphicsEndImageContext();
        let imgData = image!.jpegData(compressionQuality: 0.3);
        
        let datasource = DataSourceValue.dataSource(with: imgData!, fileExtension: "jpeg");
                
        if let _results = results as? [OWSUserProfile] {
            
                for item in _results {
                    
                    let thread = TSContactThread.getOrCreateThread(contactAddress: item.address);
                    self.tryToSendQRAttactchment(dataSource: datasource!, thread: thread);
            }
            
            
        } else if let _results = results as? [TSGroupModel] {
            
                for item in _results {
                    
                    let thread = TSGroupThread.getOrCreateThread(with: item);
                    if thread.shouldThreadBeVisible == false {
                        kSignalDB.write { (write) in
                            thread.anyUpdateGroupThread(transaction: write) { (thread) in
                                thread.shouldThreadBeVisible = true;
                            }
                        }
                    }
                    self.tryToSendQRAttactchment(dataSource: datasource!, thread: thread);
                    
                }
        }
        if vc.isKind(of: PGGroupsVC.self) {
            vc.navigationController?.popViewController(animated: true)

        }else{
            vc.dismiss(animated: true, completion: nil);

        }
        
    }
    
    // MARK: 发送二维码到群组或好友
    private func tryToSendQRAttactchment(dataSource: DataSource,thread: TSThread) {
       
        
        let attachment = SignalAttachment.attachment(dataSource: dataSource, dataUTI: "public.jpeg", imageQuality: .original);
        
        kSignalDB.uiRead { (read) in
            ThreadUtil.enqueueMessage(withText: nil, mediaAttachments: [attachment], in: thread, quotedReplyModel: nil, linkPreviewDraft: nil,mentions: nil, transaction: read);
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
