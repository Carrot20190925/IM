//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class BaseTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ///初始化
        let _ = PigramUploadConfig.share
        self.addObserverAction()
        self.initialSubVC();
        if #available(iOS 13.0, *){
            let standardAppearance = UITabBarAppearance.init()
            standardAppearance.shadowImage = UIImage.init(color: UIColor.white)
            standardAppearance.backgroundColor = UIColor.white
            standardAppearance.backgroundImage = UIImage.init(color: UIColor.white)
            standardAppearance.stackedItemSpacing = 0.1
            standardAppearance.stackedItemPositioning = .centered
            self.tabBar.standardAppearance = standardAppearance

        }else{
            self.tabBar.shadowImage = UIImage.init();
            self.tabBar.backgroundColor = UIColor.white;
            self.tabBar.backgroundImage = UIImage.init(color: UIColor.white);
        }

    }
    

    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func initialSubVC() {
        
        let vcMaps = [
            ["title":"消息","icon":"pigram-tab-chat", "vc":SessionVC.init()],
            ["title":"通讯录","icon":"pigram-tab-contact", "vc":ContactsVC.init()],
            ["title":"更多","icon":"pigram-tab-more", "vc":TXMoreController.init()]
        ];

        
        for item in vcMaps {
            self.tabBar.itemSpacing = 10
            self.tabBar.itemPositioning = .centered
            let vc = item["vc"] as? UIViewController;
            let navVC = BaseNavigationVC.init(rootViewController: vc!);
            vc?.tabBarItem.image = UIImage.init(named: item["icon"] as! String);
            self.addChild(navVC);
            
            
        }
        self.tabBar.itemSpacing = 0.1;
        self.tabBar.itemPositioning = .centered;
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkAppUpdate()
        
         
    }
    
    //检测到内存吃紧
    override func didReceiveMemoryWarning() {
        PigramGroupManager.shared.groupModelsCache.removeAllObjects()
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

extension BaseTabBarVC{
    
    func addObserverAction()  {
        NotificationCenter.default.addObserver(self, selector: #selector(loginOtherDevice), name: NSNotification.Name.init("kNotification_login_on_other_device"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile(noti:)), name: NSNotification.Name.init("Pigram_Notification_Update_Profile_Info"), object: nil)

    }
    
    
    
    
    @objc
    public func updateProfile(noti:Notification) ->  Void{
        guard let userId = noti.object as? String else {
            return
        }
        let params = ["phoneNumber":userId]
        PigramNetworkMananger.pgSearchUserNetword(params: params, success: { (respone) in
            guard let resObjct = respone as? Array <Any> else{
                return
            }
            for item in resObjct {
                if  let response = item as? [String : Any] {
                    var name : String?
                    var avatar : String?
                    guard let userId = response["userId"] as? String else{
                        continue
                    }
                    if let newName = response["name"] as? String{
                        name = newName
                    }
                    if let  newavatar = response["avatar"] as? String{
                        avatar = newavatar
                    }
                    var user:OWSUserProfile?
                    kSignalDB.write { (transation) in
                        let address = SignalServiceAddress.init(phoneNumber: userId)
                        user = OWSUserProfile.getOrBuild(for: address, transaction: transation)
                        user?.update(withProfileName: name, avatarUrlPath: avatar, avatarFileName: nil, transaction: transation, completion:nil)
                    }
                    
                }
            }
            
        }) { (error) in

        }
    }
    
    //MARK:--检查更新
    func checkAppUpdate() {
        let urlString = "https://pigram.org/ios/Version.txt"
        guard let url = URL.init(string: urlString)else{
            return
        }
        var request = URLRequest.init(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) {[weak self] (data, respone, error) in
            if let _ = error {
                return
            }
            if  let ensureData = data{
                guard let dic = try? JSONSerialization.jsonObject(with: ensureData, options: []) else{
                    return
                }
                if let ensureDic = dic as? Dictionary<String, String> {
                    let update = ensureDic["updateType"]
                    let version = ensureDic["Version"]?.replacingOccurrences(of: ".", with: "");
                    let infoDic = Bundle.main.infoDictionary
                    let currentVersion = (infoDic?["CFBundleShortVersionString"] as? String)?.replacingOccurrences(of: ".", with: "")
                    if Int(version ?? "0") ?? 0 <= Int(currentVersion ?? "0") ?? 0  {//线上 线下一致直接返回
                        return
                    }
                    if update == "update" {//更新
                        DispatchQueue.main.async {
                            self?.alertAction(dic: ensureDic)
                        }
                    }
                }
            }
        }
        dataTask.resume()
        
    }
    
    
    
    
    func alertAction(dic : [String:String]) {
        let title = dic["title"]
        let subtitle = dic["subtitle"]
        TXTheme.alertActionWithMessage(title: title, message: subtitle, fromController: self) {
            guard  let url = URL.init(string: "https://pigram.org") else{
                return
            }
            if UIApplication.shared.canOpenURL(url as URL){
                UIApplication.shared.open(url, options: [:]) { (isOk) in
                    
                }
            }
        }

    }
    
    
    @objc
    func loginOtherDevice() {
        TXTheme.alertActionWithMessage(title: nil, message: "老铁，您的账号在其他设备上登录啦", fromController: self) {
            
        }
        let reloginView = self.reloginView()
        self.view.addSubview(reloginView)
        
    }
    func reloginView() -> UIView {
        var y : CGFloat = 64
        if UIDevice.current.hasIPhoneXNotch {
            y = 88
        }
        let reLoginView = UIView.init(frame: CGRect.init(x: 0, y: y, width: UIScreen.main.bounds.size.width, height: 80))
        reLoginView.backgroundColor = TXTheme.secondColor()
        let label = UILabel.init()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        let attriText = NSMutableAttributedString.init(string: "未登录状态\n", attributes: [NSAttributedString.Key.font : TXTheme.mainTitleFont(size: 15)])
        let appendText = NSAttributedString.init(string: "您的号码在另一台设备上登录了Pigram.\n点击重新登录账号", attributes: [NSAttributedString.Key.font : TXTheme.secondTitleFont(size: 13)])
        attriText.append(appendText)
        label.attributedText = attriText
        reLoginView.addSubview(label)
        label.mas_makeConstraints { [weak reLoginView] (make) in
            make?.left.mas_equalTo()(20)
            make?.right.mas_equalTo()(-20)
            make?.centerY.mas_equalTo()(reLoginView?.mas_centerY)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(toLoginAction))
        reLoginView.addGestureRecognizer(tap)
        return reLoginView
    }
    @objc
    func toLoginAction() {//登录
        RegistrationUtils.showReregistrationUI(from: self)
    }
}




