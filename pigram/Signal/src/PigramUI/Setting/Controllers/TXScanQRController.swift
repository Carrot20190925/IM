//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

import PromiseKit
class TXScanQRController: LBXScanViewController {
    static let PIGRAMPROTOCOL = "pigram://p.land?"
    static let PIGRAMUSER = "___user____!"
    static let PIGRAMGROUP = "___group___!"
//    var complete : ((_ result: String?,_ scanVC:TXScanQRController) -> Void)?
    let photoBtn = UIButton.init()
    let backBtn = UIButton.init()
    let titleLabel = UILabel.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    deinit {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photoBtn.setTitle("相册", for: UIControl.State.normal)
        photoBtn.sizeToFit()
        photoBtn.addTarget(self, action: #selector(openPhotoAlbum), for: .touchUpInside)
        backBtn.setImage(UIImage.init(named: "register_goback")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        titleLabel.text = "扫一扫"
        titleLabel.textColor = TXTheme.whiteColor()
        self.view.addSubview(photoBtn)
        self.view.addSubview(backBtn)
        self.view.addSubview(titleLabel)
        let top : CGFloat
        if UIDevice.current.hasIPhoneXNotch {
            top = 44
        }else{
            top = 20
        }
        backBtn.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(20)
            make?.top.mas_equalTo()(top)
            make?.height.mas_equalTo()(44)
            make?.width.mas_equalTo()(44);
        }
        titleLabel.mas_makeConstraints {[weak self] (make) in
            make?.top.mas_equalTo()(top)
            make?.centerX.mas_equalTo()(self?.view.mas_centerX)
            make?.height.mas_equalTo()(44)
        }
        photoBtn.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(-20)
            make?.top.mas_equalTo()(top)
            make?.height.mas_equalTo()(44)
        }
    }
    @objc
    private func goBack(){
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
//    override func handleCodeResult(arrayResult: [LBXScanResult]) {
//        guard let result = arrayResult.first else {
//            self.complete?(nil,self)
//            return
//        }
//        guard let text = result.strScanned else {
//            self.complete?(nil,self)
//            return
//        }
//        self.complete?(text,self)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension BaseVC:LBXScanViewControllerDelegate{
    func scanFinished(scanResult: LBXScanResult, error: String?) {

     guard let text = scanResult.strScanned else {
        OWSAlerts.showErrorAlert(message: "不能识别亲")
        return
     }
      let paramString = text.substring(from: TXScanQRController.PIGRAMPROTOCOL.count)
      let array = paramString.components(separatedBy: "=")
    
      if  let key = array.first,key.count > 0 {
          switch key {
          case "g":
              if let value = array[1] as String?,value.count > 0{
                  let groupVC = PGGroupInfoVC.init()
                  groupVC.groupId = value
                  self.navigationController?.pushViewController(groupVC, animated: true)
              }else{
                  OWSAlerts.showAlert(title: "不能识别亲")
              }
          case "u":
              if let value = array[1] as String?,value.count > 0{
                  let vc = FriendSearchVC.init();
                  vc.channel = .scan
                  vc.phoneNumber = value
                  if value == TSAccountManager.localUserId {
                    vc.hideConfirmBtn = true
                  }
                  self.navigationController?.pushViewController(vc, animated: true)
              }else{
                  OWSAlerts.showAlert(title: "不能识别亲")
              }
          case "d":
              if let value = array[1] as String?,value.count > 0{
                  OWSAlerts.showAlert(title: nil, message: "允许设备登陆账号", buttonTitle: "登录") {[weak self] (action) in
                      guard let weakSelf = self else{
                          return
                      }
                      

                      guard let userId = TSAccountManager.localUserId else{
                          OWSAlerts.showErrorAlert(message: "本地账号出错")
                          return
                      }

                      ModalActivityIndicatorViewController.present(fromViewController: weakSelf, canCancel: true) { (modal) in
                          PigramNetworkMananger.pgControlLoginWebNetwork(params: [:], success: { (respose) in
                              guard let dicResponse = respose as? Dictionary<String,Any> else{
                                 DispatchQueue.main.async {
                                    modal.dismiss {
                                        OWSAlerts.showErrorAlert(message: "验证错误")
                                    }
                                 }
                                 return
                              }
                              guard let verificationCode = dicResponse["verificationCode"] as? String else{
                                 DispatchQueue.main.async {
                                    modal.dismiss {
                                        OWSAlerts.showErrorAlert(message: "验证错误")
                                    }
                                 }
                                 return
                              }
                               let builder =   ProvisioningProtoProvisionMessage.builder(userId: userId, provisioningCode: verificationCode, userAgent: "OWI")
                               guard let data  = try? builder.buildSerializedData() else{
                                  DispatchQueue.main.async {
                                     modal.dismiss {
                                         OWSAlerts.showErrorAlert(message: "数据序列化出错")
                                     }
                                  }
                                   return
                               }
                              let params = ["deviceId":value,"data":data] as [String : Any]
                              PigramNetworkMananger.pgGetScanDeviceAuthorNetwork(params: params, success: { (_) in
                                  DispatchQueue.main.async {
                                     modal.dismiss {
                                         OWSAlerts.showAlert(title: "操作成功")
                                     }
                                  }
                              }) { (error) in
                                  DispatchQueue.main.async {
                                     modal.dismiss {
                                         OWSAlerts.showErrorAlert(message: error.localizedDescription)
                                     }
                                  }
                              }
                          }) { (error) in
                              if let ensureError = error as? NSError,ensureError.code == 411 {
                                  DispatchQueue.main.async {
                                     modal.dismiss {
                                         OWSAlerts.showErrorAlert(message: "亲，绑定设备太多了")
                                     }
                                  }
                                  return
                              }
                              DispatchQueue.main.async {
                                 modal.dismiss {
                                     OWSAlerts.showErrorAlert(message: error.localizedDescription)
                                 }
                              }
                          }
                      }
                  }
              }
              else{
                  OWSAlerts.showAlert(title: "不能识别亲")
              }
              break
          default:
                OWSAlerts.showErrorAlert(message: "不能识别亲")
              break
              
          }
      }else
      {
        OWSAlerts.showErrorAlert(message: "不能识别亲")
      }
        
        
    }
    //MARK:-  扫描界面
    @objc
    func txEntrySearch() {
        self.InnerStyle()

    }
    // MARK: - ---无边框，内嵌4个角 -----
    private func InnerStyle() {
        let type = AVCaptureDevice.authorizationStatus(for: .video)
        if (type == .restricted)  {
            OWSAlerts.showAlert(title: "请在设置-Pigram-设置允许访问相机功能")
            return
        }
        if type == .denied {
            OWSAlerts.showAlert(title: "请在设置-Pigram-设置允许访问相机功能")
            return
        }
        //设置扫码区域参数
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        style.photoframeLineW = 3
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        //qq里面的线条图片
        style.animationImage = UIImage(named: "qrcode_scan_light_green")
//        style.color_NotRecoginitonArea = UIColor.col
//        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        let vc = TXScanQRController()
//        let vc = LBXScanViewController.init()
        vc.scanStyle = style
        vc.isOpenInterestRect = true
        
        vc.scanResultDelegate = self;
//        self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true, completion: nil)
    }
}


