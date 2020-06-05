//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit


class TXSetController: BaseVC,UITableViewDelegate,UITableViewDataSource {
    
  
    enum TXSetType {
        case normal
        case lauguage
        case advanced
        case accountSave
        case bindDevice
        case privacy
        case blackList
        case about
        case genary
        case voice
        case theme

    }
    let tableView = UITableView.init(frame: CGRect.init(), style: .grouped)
    var items : [String] = []
    var genaryItems : [[String]] = []
    var type:TXSetType = .normal
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.frame = self.view.bounds
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.mas_offset()
        }
        self.tableView.register(TXGroupInfoCell.self, forCellReuseIdentifier: "TXGroupInfoCell")
//        self.tableView.register(UINib.init(nibName: "TXMoreCell", bundle: Bundle.main), forCellReuseIdentifier: "TXMoreCell")
        if self.type == .normal {
            self.tableView.backgroundColor = TXTheme.thirdColor()
        }else
        {
            self.tableView.backgroundColor = UIColor.white
        }
        self.tableView.separatorColor = TXTheme.thirdColor()
        self.setupData()
        // Do any additional setup after loading the view.
    }
    
   
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.type == .genary {
            return self.genaryItems.count
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.type == .genary {
            let array = self.genaryItems[section]
            return array.count
        }
        return self.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : TXGroupInfoCell = tableView.dequeueReusableCell(withIdentifier: "TXGroupInfoCell", for: indexPath) as! TXGroupInfoCell
        var text : String
        if self.type == .genary {
            let array:[String] = self.genaryItems[indexPath.section]
            text = array[indexPath.row]
//            cell.titleLabel?.text = array[indexPath.row]
        }else{
            text = self.items[indexPath.row]
//            cell.titleLabel?.text = self.items[indexPath.row]
        }
        self.setupCell(cell: cell, text: text)
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let string:String
        
        if self.type == .genary {
            let array : [String] = self.genaryItems[indexPath.section]
            string = array[indexPath.row]
        }else{
            string = self.items[indexPath.row]
        }
        
        switch string {
        case kPigramLocalizeString("推送通知", "推送通知"):
            let cell = tableView.cellForRow(at: indexPath) as! TXGroupInfoCell
            if !cell.slider.isOn {
                OWSAlerts.showAlert(title: kPigramLocalizeString("前往系统设置里开启推送", "前往系统设置里开启推送"))
            }
            break
        case kPigramLocalizeString("语言", "语言"):
            do{
                let setLauguageVC = TXSetController.init()
                setLauguageVC.type = TXSetController.TXSetType.lauguage
                self.navigationController?.pushViewController(setLauguageVC, animated: true)
            }
            break
        case kPigramLocalizeString("高级", "高级"):
            do{
                let setLauguageVC = TXSetController.init()
                setLauguageVC.type = TXSetController.TXSetType.advanced
                self.navigationController?.pushViewController(setLauguageVC, animated: true)
            }
            break
        case kPigramLocalizeString("跟随系统", "跟随系统"):
            break
        case kPigramLocalizeString("简体中文", "简体中文"):
            break
        case kPigramLocalizeString("繁体中文", "繁体中文"):
            break
        case "英语":
            break
        case "日语":
            break
        case "韩语":
            break
        case "俄语":
            break
        case kPigramLocalizeString("启用调试日志", "启用调试日志"):
            break
        case kPigramLocalizeString("提交调试日志", "提交调试日志"):
            DDLog.flushLog()
            Pastelog.submitLogs()
            break
        case kPigramLocalizeString("允许手机、电脑同时在线", "允许手机、电脑同时在线"):
            break
        case kPigramLocalizeString("绑定设备", "绑定设备"):
            let linkVC = OWSLinkedDevicesTableViewController.init()
            self.navigationController?.pushViewController(linkVC, animated: true)
            break
        case kPigramLocalizeString("修改密码", "修改密码"):
            do{
                let mgr = TXLoginManagerController.init()
                mgr.changePasswordController(viewController: self)
            }
            break
            
        case kPigramLocalizeString("更换手机号", "更换手机号"):
            let mgr = TXLoginManagerController.init()
            mgr.changPhoneAction(fromVC: self)
            break
        case kPigramLocalizeString("黑名单", "黑名单"):
            do{
                let setLauguageVC = TXSetController.init()
                setLauguageVC.type = TXSetController.TXSetType.blackList
                self.navigationController?.pushViewController(setLauguageVC, animated: true)
            }
            break
        case kPigramLocalizeString("声音", "声音"):
            do{
                if indexPath.section == 0 {
                    let setSoundVC = OWSSoundSettingsViewController.init()
                    self.navigationController?.pushViewController(setSoundVC, animated: true)
                }
                
            }
            break
        case kPigramLocalizeString("主题", "主题"):
            do{
                let setLauguageVC = TXSetController.init()
                setLauguageVC.type = TXSetController.TXSetType.theme
                self.navigationController?.pushViewController(setLauguageVC, animated: true)
            }
            break
        case kPigramLocalizeString("添加黑名单", "添加黑名单"):
            do{
                TXBlackListController.showVC(self, navTitle: kPigramLocalizeString("黑名单列表", "黑名单列表"), rightNavTitle:kPigramLocalizeString("添加", "添加") , type: TXBlackListController.BlackType.add) { (listVC, profiles) in

                }
            }
            break
            
        case kPigramLocalizeString("黑名单列表", "黑名单列表"):
            do{
                TXBlackListController.showVC(self, navTitle:kPigramLocalizeString("黑名单列表", "黑名单列表") , rightNavTitle:kPigramLocalizeString("移除", "移除") , type: TXBlackListController.BlackType.remove) { (listVC, profiles) in
                    
                }
            }
            break
        case kPigramLocalizeString("清除聊天记录", "清除聊天记录"):
            TXTheme.alertActionWithMessage(title:kPigramLocalizeString("清除聊天记录", "清除聊天记录") , message:kPigramLocalizeString("您确定要清除所有历史记录吗（包括信息，附件等）", "您确定要清除所有历史记录吗（包括信息，附件等）") , fromController: self) {
                ThreadUtil.deleteAllContent()
                OWSAlerts.showAlert(title:kPigramLocalizeString("清除成功", "清除成功") )
            }
        case kPigramLocalizeString("版本", "版本"):
            self.checkAppUpdate();
            break;
        case kPigramLocalizeString("条款和隐私政策", "条款和隐私政策"):
            let webVC = PigramTxWebVC.init()
            webVC.urlString = "https://pigram.org/privacy.html"
            self.navigationController?.pushViewController(webVC, animated: true)
            break;
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch type {
        case .normal:
            do{
                let button = UIButton.init()
                button.setTitle(kPigramLocalizeString("退出账号", "退出账号"), for: .normal)
                button.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
                button.setTitleColor(TXTheme.secondColor(), for: .normal)
                return button
            }

        default:
            return UIView.init()
        }
       
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch self.type {
        case .normal:
            do{
                return 40.0
            }
        case .genary:
            do{
                if section == 1 {
                    return 0.1
                }
                return 0.1
            }
        default:
            return 0.1
        }

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch self.type {
        case .advanced:
            do{
                 let label = UILabel.init()
                 label.textColor = TXTheme.titleColor()
                 label.text = kPigramLocalizeString("     信息记录日志", "信息记录日志")
                 return label
             }
        default:
            return UIView.init()
        }
       
     }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch type {
        case .advanced:
            return 40.0
        default:
            return 0.1
        }
    }
    @objc
    private func logoutAction(){
        
        
        
        TXTheme.alertActionWithMessage(title: kPigramLocalizeString("温馨提示", "温馨提示"), message:kPigramLocalizeString("亲，退出账号可能导致本地数据清空，你需要重启应用登录", "亲，退出账号可能导致本地数据清空，你需要重启应用登录") , fromController: self) {[weak self] in
            guard let weakSelf = self else{
                return
            }
            ModalActivityIndicatorViewController.present(fromViewController: weakSelf, canCancel: true) { (model) in
                PigramNetworkMananger.pgLoginoOutNetwork(params: [:], success: { (_) in
                    DispatchQueue.main.async {
                        model.dismiss {
                            PigramVerifyManager.shared.clearAllVerify()
                            SignalApp.resetAppData()
                            
                        }
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        model.dismiss {
                            OWSAlerts.showErrorAlert(message: kPigramLocalizeString("退出失败", "退出失败"))
                        }
                    }
                }
//                PigramNetworkMananger.pgLoginoOutNetwork(success: { (_) in
//                    DispatchQueue.main.async {
//                        model.dismiss {
//                            SignalApp.resetAppData()
//                        }
//                    }
//                }) { (error) in
//                    DispatchQueue.main.async {
//                        model.dismiss {
//                            OWSAlerts.showErrorAlert(message: "退出失败")
//                        }
//                    }
//                }
            }
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



extension TXSetController{
    
    
    
    private func setupCell(cell:TXGroupInfoCell,text:String){
        cell.tagLabel.text = text
        switch self.type {
        case .lauguage,.voice,.theme:
            cell.showNextBtn()
            cell.setImage(image: UIImage.init(named: "pigram-group-unselect")?.withRenderingMode(.alwaysOriginal))
        case .bindDevice:
            cell.hiddenMore()
        default:
            switch text {
            case kPigramLocalizeString("语言", "语言"),
                kPigramLocalizeString("高级", "高级"),
                kPigramLocalizeString("绑定设备", "绑定设备"),
                kPigramLocalizeString("修改密码", "修改密码"),
                kPigramLocalizeString("更换手机号", "更换手机号"),
                kPigramLocalizeString("黑名单", "黑名单"),
                kPigramLocalizeString("清除聊天记录", "清除聊天记录"),
                kPigramLocalizeString("条款和隐私政策", "条款和隐私政策"),
                kPigramLocalizeString("添加黑名单", "添加黑名单"),
                kPigramLocalizeString("黑名单列表", "黑名单列表"),
                kPigramLocalizeString("提交调试日志", "提交调试日志"):do {
                    cell.showNextBtn()
                    cell.setImage(image: UIImage.init(named: "more_next")?.withRenderingMode(.alwaysOriginal))
                }
            case kPigramLocalizeString("版本", "版本"):
                cell.showNextBtn()
                cell.setImage(image: UIImage.init(named: "more_next")?.withRenderingMode(.alwaysOriginal))
                let infoDic = Bundle.main.infoDictionary
                if let version = infoDic?["CFBundleShortVersionString"] as? String{
                    let buildVersion = infoDic?["CFBundleVersion"] as? String;
                    cell.setSubtitle(subtitle: version + " (" + (buildVersion ?? "1.0") + ")");
                }

                
                
            case kPigramLocalizeString("静音", "静音"):
                cell.showSlider()
                let on = Environment.shared.preferences.soundInForeground()
                cell.slider.setOn(!on, animated: false)
                cell.switchAction = { on in
                    Environment.shared.preferences.setSoundInForeground(!on.isOn)
                    
                }


            case kPigramLocalizeString("主题", "主题"),
                kPigramLocalizeString("声音", "声音"):
                cell.showNextBtn()
                cell.setImage(image: UIImage.init(named: "more_next")?.withRenderingMode(.alwaysOriginal))
                cell.setSubtitle(subtitle: nil)
            case kPigramLocalizeString("推送通知", "推送通知"):
                cell.showSlider()
                cell.slider.isUserInteractionEnabled = false
                if #available(iOS 13.0, *) {
                    //系统版本高于13.0
                    UNUserNotificationCenter.current().getNotificationSettings { (set) in
                        DispatchQueue.main.async {
                            if set.authorizationStatus == UNAuthorizationStatus.notDetermined{
                                cell.slider.setOn(false, animated: false)
                            }else if set.authorizationStatus == .denied{
                                cell.slider.setOn(false, animated: false)

                            }else{
                                cell.slider.setOn(true, animated: false)
                            }
                        }
                    }
                } else if #available(iOS 10.0, *) {
                    //系统版本高于10.0
                    UNUserNotificationCenter.current().getNotificationSettings { (set) in
                        DispatchQueue.main.async {
                            if set.authorizationStatus == UNAuthorizationStatus.notDetermined{
                                cell.slider.setOn(false, animated: false)

                            }else if set.authorizationStatus == .denied{
                                cell.slider.setOn(false, animated: false)

                            }else{
                                cell.slider.setOn(true, animated: false)
                            }
                        }
                    }
                }else{
                    let types = UIApplication.shared.currentUserNotificationSettings?.types
                    if Int(types!.rawValue) == 0 {
                        cell.slider.setOn(false, animated: false)

                    }else{
                        cell.slider.setOn(true, animated: false)
                    }
                }
            case kPigramLocalizeString("已读回执", "已读回执"):
                cell.showSlider()
                let on = OWSReadReceiptManager.shared().areReadReceiptsEnabled()
                cell.slider.setOn(on, animated: false)
                cell.switchAction = { on in
                    OWSReadReceiptManager.shared().setAreReadReceiptsEnabled(on.isOn)
                }

                break
                
            case kPigramLocalizeString("正在输入提示", "正在输入提示"):
                cell.showSlider()
                let on = SSKEnvironment.shared.typingIndicators.areTypingIndicatorsEnabled()
                cell.slider.setOn(on, animated: false)
                cell.switchAction = { on in
                    SSKEnvironment.shared.typingIndicators.setTypingIndicatorsEnabled(value: on.isOn)
                }
                break
            case kPigramLocalizeString("启用调试日志", "启用调试日志"):
                cell.showSlider()
                let on = OWSPreferences.isLoggingEnabled()
                cell.slider.setOn(on, animated: false)
                cell.switchAction = { on in
                    OWSPreferences.setIsLoggingEnabled(on.isOn)
                }
                break
            case kPigramLocalizeString("屏幕锁", "屏幕锁"):
                cell.showSlider()
                let on = OWSScreenLock.shared.isScreenLockEnabled()
                cell.slider.setOn(on, animated: false)
                cell.switchAction = { on in
                    OWSScreenLock.shared.setIsScreenLockEnabled(on.isOn)
                }
                break
        
            default:
                cell.showSlider()
            }
            break
            
        }
        
        
    }
    
    
    
    
    private func setupData(){
           switch type {
                  case .normal:
                      self.items = [kPigramLocalizeString("推送通知", "推送通知"),
                                 kPigramLocalizeString("高级", "高级")]
                      self.title = kPigramLocalizeString("设置","设置")
                      break
                  case .lauguage:
                      self.items = [kPigramLocalizeString("跟随系统", "跟随系统"),
                                 kPigramLocalizeString("简体中文", "简体中文"),
                                 kPigramLocalizeString("繁体中文", "繁体中文"),
                                 kPigramLocalizeString("英语", "英语"),
                                 kPigramLocalizeString("日语", "日语"),
                                 kPigramLocalizeString("韩语", "韩语"),
                                 kPigramLocalizeString("俄语", "俄语"),]
                      self.title = kPigramLocalizeString("语言", "语言")
                      break
                  case .advanced:
                      self.items = [kPigramLocalizeString("启用调试日志", "启用调试日志"),
                                 kPigramLocalizeString("提交调试日志", "提交调试日志")]
                      self.title = kPigramLocalizeString("高级", "高级")
                      break
                  case .accountSave:
                      self.items = [kPigramLocalizeString("绑定设备", "绑定设备"),
                                 kPigramLocalizeString("修改密码", "修改密码"),
                                 kPigramLocalizeString("更换手机号", "更换手机号")]
                      self.title = kPigramLocalizeString("账号安全", "账号安全")
                      break
                  case .bindDevice:
                      self.title = kPigramLocalizeString("绑定设备", "绑定设备")
                      break
                  case .privacy:
                      self.title = kPigramLocalizeString("隐私", "隐私")
                      self.items = [kPigramLocalizeString("黑名单", "黑名单"),
                                 kPigramLocalizeString("已读回执", "已读回执"),
                                 kPigramLocalizeString("正在输入提示", "正在输入提示"),
                                 kPigramLocalizeString("清除聊天记录", "清除聊天记录")]
                      break
                  case .blackList:
                      self.title = kPigramLocalizeString("黑名单", "黑名单")
                      self.items = [kPigramLocalizeString("添加黑名单", "添加黑名单"),
                                 kPigramLocalizeString("黑名单列表", "黑名单列表")]

                      break
                  case .about:
                      self.title = kPigramLocalizeString("关于","关于")
                      self.items = [kPigramLocalizeString("版本", "版本"),
                                kPigramLocalizeString("条款和隐私政策", "条款和隐私政策")]
                      break
                  case .genary:
                      self.title = kPigramLocalizeString("通用", "通用")
                      self.genaryItems = [[kPigramLocalizeString("声音", "声音")],[kPigramLocalizeString("静音", "静音")]]
                      break
                  case .voice:
                      self.title = kPigramLocalizeString("声音", "声音")
                      self.items = [kPigramLocalizeString("声音1", "声音1"),
                                kPigramLocalizeString("声音2", "声音2"),
                                kPigramLocalizeString("声音3", "声音3")]
                      break
                  case .theme:
                      self.title = kPigramLocalizeString("主题", "主题")
                      self.items = [kPigramLocalizeString("默认主题", "默认主题"),
                                kPigramLocalizeString("主题2", "主题2"),
                                kPigramLocalizeString("主题3", "主题3")]
                      break

                  }
       }
}




extension TXSetController{
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
                    let infoDic = Bundle.main.infoDictionary
//                    let versionStr = ensureDic["Version"] as? String;
//                    let currentVersionStr = infoDic?["CFBundleShortVersionString"] as? String;
                    let version = ensureDic["Version"]?.replacingOccurrences(of: ".", with: "");
                    let currentVersion = (infoDic?["CFBundleShortVersionString"] as? String)?.replacingOccurrences(of: ".", with: "")
                    if Int(version ?? "0") ?? 0 <= Int(currentVersion ?? "0") ?? 0   {//线上 线下一致直接返回
                        return
                    }

                    DispatchQueue.main.async {
                        self?.alertAction(dic: ensureDic)
                    }
                }
            }
        }
        dataTask.resume()
        
    }
    
    
    
    
    func alertAction(dic : [String:String]) {
        let title = dic["title"]
        let subtitle = dic["subtitle"]
        let version = dic["Version"]
        let messageTitle = "\(title ?? "")\(version ?? "")"
        TXTheme.alertActionWithMessage(title: messageTitle, message: subtitle, fromController: self) {
            guard  let url = URL.init(string: "https://pigram.org") else{
                return
            }
            if UIApplication.shared.canOpenURL(url as URL){
                UIApplication.shared.open(url, options: [:]) { (isOk) in
                    
                }
            }
        }

    }
}
