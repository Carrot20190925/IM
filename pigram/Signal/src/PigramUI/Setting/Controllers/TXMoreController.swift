//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXMoreController: BaseVC,UITableViewDataSource,UITableViewDelegate {
    
    
    var tableView = UITableView.init(frame: CGRect.init(), style: .grouped)
    var contents = [[kPigramLocalizeString("网络状态", "网络状态"),
                 kPigramLocalizeString("PG号", "PG号"),
                 kPigramLocalizeString("账号管理", "账号管理"),
                 kPigramLocalizeString("账号安全", "账号安全")],
                [kPigramLocalizeString("通用",  "通用"),
                 kPigramLocalizeString("隐私",  "隐私"),
                 kPigramLocalizeString("关于", "关于")]]

    var headView : TXMoreHeadView?

    
    override func loadView() {
        super.loadView()
//        let y : CGFloat = UIDevice.current.hasIPhoneXNotch ? 88.0 : 64.0
//        self.tableView.frame = CGRect.init(x: 0, y: 0, width: self.view.width(), height: self.view.height() - y)
    }
    
//    @objc class func inModalNavigationController() -> OWSNavigationController{
//        let moreView = TXMoreController.init()
//        return OWSNavigationController.init(rootViewController: moreView)
//    }
    
    @objc func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(uploadTableView), name: NSNotification.Name(rawValue: kNSNotification_OWSWebSocketStateDidChange), object: nil)
    }
    @objc func uploadTableView(){
        self.tableView.reloadData()
        
        guard let phoneNum = TSAccountManager.localNumber else {
            return
        }
        let phoneNumber = PhoneNumber.bestEffortFormatPartialUserSpecifiedText(toLookLikeAPhoneNumber: phoneNum)
        self.headView?.phoneLabel.text = phoneNumber
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavBar()
        self.setupTableView()
        self.observeNotifications()
        self.addTitleViewChangesBarHeight();
        // Do any additional setup after loading the view.
    }
    
    private func addTitleViewChangesBarHeight() {
        //为了让navigationBar高度产生变化
        let titleView = UISearchBar.init();
        titleView.isHidden = true;
        self.navigationItem.titleView = titleView;
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupImageWithColor(color : UIColor) -> UIImage? {
        let rect = CGRect.init(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
        guard let headView = self.headView else {
            return
        }
        TXMoreItem.updateHeaderUI(headView: headView)
    }
    func setupNavBar() {
        self.navigationItem.titleView = UIView.init();
//        let rgbColor = TXTheme.rgbColor(235, 235, 235)
//        self.navigationController?.navigationBar.shadowImage = self.setupImageWithColor(color: rgbColor)
        let titleLabel = UILabel.init()
        titleLabel.font = TXTheme.font(name: "PingFangSC-Medium", size: 27)
        titleLabel.textColor = TXTheme.rgbColor(39, 61, 82)
        titleLabel.text = kPigramLocalizeString("更多", "更多")
        titleLabel.sizeToFit()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "more_setup")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(entrySetupAction))
    }
    
    @objc func entrySetupAction(){
        self.navigationController?.pushViewController(TXSetController.init(), animated: true)
//        SignalApp.resetAppData()
    }
    func setupTableView() {
//        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.white
//        self.tableView.tab
        self.tableView.register(UINib.init(nibName: "TXMoreCell", bundle: Bundle.main), forCellReuseIdentifier: "TXMoreCell")
        let tableHeaderView = TXMoreItem.setupHeader(frame: CGRect.init(x: 0, y: 0, width: self.view.width(), height: 100))
        tableHeaderView.action = {[weak self] in
            let myqr = TXGroupQRVC.init()
            myqr.type = .persion
            self?.navigationController?.pushViewController(myqr, animated: true)
        }
        self.headView = tableHeaderView
        self.tableView.tableHeaderView = tableHeaderView
        self.view.addSubview(self.tableView)
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.mas_offset()
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.tableView.mas_makeConstraints { (make) in
//            make?.edges.mas_equalTo()(0)
////            make?.top.mas_equalTo()(0)
////            make?.top.mas_equalTo()(0)
////            make?.left.right()?.mas_equalTo()(0)
//        }
    }

    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.contents.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let array = self.contents[section]
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TXMoreCell = tableView.dequeueReusableCell(withIdentifier: "TXMoreCell", for: indexPath) as! TXMoreCell
        let string = self.contents[indexPath.section][indexPath.row]
        cell.titleLabel.text = string
        switch string {
        case kPigramLocalizeString("网络状态",  "网络状态"):
            do {
            cell.subTitleBtn.setImage(nil, for: .normal)
            if TSAccountManager.sharedInstance().isDeregistered() {
                cell.subTitleBtn.setTitle(kPigramLocalizeString("未登录", "未登录"), for: .normal)
            }else{
                switch TSSocketManager.shared.highestSocketState() {
                case .closed:
                    cell.subTitleBtn.setTitle(kPigramLocalizeString("离线", "离线"), for: .normal)
                    break
                case .connecting:
                    cell.subTitleBtn.setTitle(kPigramLocalizeString("正在连接...",  "正在连接..."), for: .normal)
                    break
                case .open:
                    cell.subTitleBtn.setTitle(kPigramLocalizeString("已连接",  "已连接"), for: .normal)
                    break
                default:
                    cell.subTitleBtn.setTitle(kPigramLocalizeString("其他",  "其他"), for: .normal)
                }
            }
        }
        break
  
        default:
            cell.subTitleBtn.setTitle(nil, for: .normal)
            cell.subTitleBtn.setImage(UIImage.init(named: "more_next")?.withRenderingMode(.alwaysOriginal), for: .normal)
            break
          

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        }
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let string = self.contents[indexPath.section][indexPath.row]
        switch string {
            case kPigramLocalizeString("账号管理",  "账号管理"):
                self.navigationController?.pushViewController(TXAccountSetController.init(), animated: true)
                break
            case kPigramLocalizeString("账号安全",  "账号安全"):
                do{
                    let accountSavevc = TXSetController.init()
                    accountSavevc.type = TXSetController.TXSetType.accountSave
                    self.navigationController?.pushViewController(accountSavevc, animated: true)
                 }
                break
            case kPigramLocalizeString("通用", "通用"):
                do{
                   let accountSavevc = TXSetController.init()
                   accountSavevc.type = TXSetController.TXSetType.genary
                   self.navigationController?.pushViewController(accountSavevc, animated: true)
                }
                break
            case kPigramLocalizeString("隐私","隐私"):
                do{
                   let accountSavevc = TXSetController.init()
                   accountSavevc.type = TXSetController.TXSetType.privacy
                   self.navigationController?.pushViewController(accountSavevc, animated: true)
                }
                break
            case kPigramLocalizeString("关于", "关于"):
                do{
                   let accountSavevc = TXSetController.init()
                   accountSavevc.type = TXSetController.TXSetType.about
                   self.navigationController?.pushViewController(accountSavevc, animated: true)
                }
                break
            
            case kPigramLocalizeString("PG号", "PG号"):
                do{
                    let pgVC = PigramPGVC.init()
                    self.navigationController?.pushViewController(pgVC, animated: true)
                }
                break
            default:
        
                break
        

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
