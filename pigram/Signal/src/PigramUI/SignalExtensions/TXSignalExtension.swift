//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation

extension TXGroupInfoVC {
    
    func txDissolutionGroup(thread : TSGroupThread) {
        let model = thread.groupModel
        let params = ["groupId":thread.groupModel.groupId]
//        model.allMembers = []
        model.txGroupType = TXGroupTypeExit
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) {[weak self] (modal) in
            PigramNetworkMananger.pgDismissGroupNetwork(params: params, success: { (_) in
                SSKEnvironment.shared.databaseStorage.write { (trasaction) in
                    let thread = TSGroupThread.getOrCreateThread(withGroupId: model.groupId, transaction: trasaction)
                    
                    thread.anyUpdateGroupThread(transaction: trasaction) { (thread) in
                        thread.groupModel = model
                        thread.shouldThreadBeVisible = false
                    }
                    thread.leaveGroup(with: trasaction)
                }
                PigramGroupManager.shared.removeGroupModel(groupId: model.groupId)
                DispatchQueue.main.async {
                    modal.dismiss {
                        self?.navigationController?.popToRootViewController(animated: true)
                        OWSAlerts.showAlert(title: "解散成功")

                    }
                }
                
                
            }) { (error) in
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showAlert(title: "解散失败,请检查网络")
                    }
                }
            }
        }

    }
    func txLeaveGroupAction(thread:TSGroupThread) {
        let model = thread.groupModel
        let params = ["groupId":thread.groupModel.groupId]
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) {[weak self] (modal) in
            PigramNetworkMananger.pgQuitGroupNetwork(params: params, success: {(_) in
                PigramGroupManager.shared.removeGroupModel(groupId: model.groupId)
                SSKEnvironment.shared.databaseStorage.write { (trasaction) in
                    model.txGroupType = TXGroupTypeExit
                    let thread = TSGroupThread.getOrCreateThread(withGroupId: model.groupId, transaction: trasaction)
                    thread.anyUpdateGroupThread(transaction: trasaction) { (thread) in
                        thread.groupModel = model
                    }
                    thread.leaveGroup(with: trasaction)
                }
                DispatchQueue.main.async {
                    modal.dismiss {
                        self?.navigationController?.popToRootViewController(animated: true)
                        OWSAlerts.showAlert(title: "离群成功")
                    }
                }
                
            }) { (error) in
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showAlert(title: "离群失败,请检查网络")
                    }
                }
            }

        }
    }
}
extension ConversationViewController{
    //MARK:-  进入群设置或个人设置
    @objc
    func txToSetupView() {
        if self.thread.isGroupThread() {
            let infoVC = TXGroupInfoVC.showGroupInfo(viewControllor: self, thread: self.thread as! TSGroupThread)
//            infoVC.dissolutionOrLeaveGroup = {[weak self] type in
//                self?.navigationController?.popToRootViewController(animated: true)
//            }

            infoVC.placeTopAction = {[weak self] (top) in
                if let id = self?.thread.recipientAddresses.first?.phoneNumber {
                    PigramNetworkMananger.pg_setStickForSession(id: id, flag: top, success: { (_) in
                        
                    }) { (_) in
                        
                    }
                }
               
                self?.databaseStorage.write(block: { (transtion) in
                    self?.thread.anyUpdate(transaction: transtion, block: { (thread) in
                        thread.tx_top = top
                        if top{
                            thread.tx_top_date = NSDate.ows_millisecondsSince1970(for: Date.init(timeIntervalSinceNow: 0))
                        }else{
                            thread.tx_top_date = 0
                        }
                    })
                })
            }
            
        }else
        {
            let infoVC = TXChatInfoVC.showGroupInfo(viewControllor: self, thread: self.thread as! TSContactThread)
            /**
            **置顶
             */
            infoVC.placeTopAction = {[weak self] (top) in
                if let id = self?.thread.recipientAddresses.first?.phoneNumber {
                    PigramNetworkMananger.pg_setStickForSession(id: id, flag: top, success: { (_) in
                        
                    }) { (_) in
                        
                    }
                }
                self?.databaseStorage.write(block: { (transtion) in
                    self?.thread.anyUpdate(transaction: transtion, block: { (thread) in
                        thread.tx_top = top
                        if top{
                            thread.tx_top_date = NSDate.ows_millisecondsSince1970(for: Date.init(timeIntervalSinceNow: 0))
                        }else{
                            thread.tx_top_date = 0
                        }
                    })
                })
            }
         }
    }
    
    //MARK:-  识别二维码
    @objc
    func pgIndentifyQRCode(_ image:UIImage) {
//        SVProgressHUD.show()
        let arrayResult = LBXScanWrapper.recognizeQRImage(image: image)
        if !arrayResult.isEmpty {
            guard let result = arrayResult.first else {
                OWSAlerts.showErrorAlert(message: "不能识别亲")
                return
            }
            guard let ensureResult = result.strScanned else {
                OWSAlerts.showErrorAlert(message: "不能识别亲")
                return
            }
            
              let paramString = ensureResult.substring(from: TXScanQRController.PIGRAMPROTOCOL.count)
              let array = paramString.components(separatedBy: "=")
            
              if  let key = array.first,key.count > 0 {
                  switch key {
                  case "g":
                      if let value = array[1] as String?,value.count > 0{
                          let groupVC = PGGroupInfoVC.init()
                          groupVC.groupId = value

                          self.navigationController?.pushViewController(groupVC, animated: true)
                      }else{
                        OWSAlerts.showErrorAlert(message: "不能识别亲")
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
                        OWSAlerts.showErrorAlert(message: "不能识别亲")
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
                      break
                  default:
                    OWSAlerts.showErrorAlert(message: "不能识别亲")
                      break
                  }
              }
        }else{
            OWSAlerts.showErrorAlert(message: "不能识别亲")
        }
    }
    
    

    //MARK:-  点击聊天头像进入好友页面
    @objc
    func entryFriendSearch(_ incomeUserId : String?) {
        if self.thread.isGroupThread(),let userId  = incomeUserId  {
            let thread = self.thread as! TSGroupThread
            let vc = FriendSearchVC.init()
            vc.channel = .group
            vc.phoneNumber = userId
            vc.fromGroupId = thread.groupModel.groupId;
            if userId == TSAccountManager.localUserId {
                vc.hideConfirmBtn = true
            }
            if let member = thread.groupModel.member(withUserId: TSAccountManager.localUserId) {
                if member.perm == 2 {
                    var user: OWSUserProfile?
                    kSignalDB.read { (read) in
                        user = OWSUserProfile.getFor(SignalServiceAddress.init(phoneNumber: userId), transaction: read)
                    }
                    if user?.relationType != .friend {
                        vc.hideConfirmBtn = true
                    }
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
    
    //MARK:-  隐藏群公告
    @objc
    func hideAnnounceAction() {
        if self.thread.isGroupThread() {
            let thread = self.thread as! TSGroupThread
            if let notice = thread.groupModel.notices.first{
                notice.status = 1
                let newNotice = notice.copy() as! PigramGroupNotice
                self.databaseStorage.asyncWrite { (write) in
                    let newThread  = TSGroupThread.getOrCreateThread(withGroupId: thread.groupModel.groupId, transaction: write)
                    newThread.anyUpdateGroupThread(transaction: write) { (newThread) in
                        newThread.groupModel.notices = [newNotice];
                    }
                }
            }
            self.lastNoticeView.removeFromSuperview();
//            self.updateAnnouncementView()
            
        }
    }

    
    @objc func updateAnnouncementView()  {
        if self.thread.isGroupThread()  {
            let thread = self.thread as! TSGroupThread
            if let notice = thread.groupModel.notices.first,notice.status == 0 ,let content = notice.content,content.count != 0{
                self.lastNoticeView.y = UIDevice.current.hasIPhoneXNotch ? 88 : 64
                self.view.addSubview(self.lastNoticeView)
                self.noticeContentTextView?.text = "最新公告：\(content)"
            }else{
                if lastNoticeView.superview != nil{
                    lastNoticeView.removeFromSuperview()
                }
            }
        }
    }
    
//    #pragma mark -- 增加公告栏
//    - (void)updateAnnouncementView{
//        if (self.thread.isGroupThread) {
//            TSGroupThread *thread = (TSGroupThread *)self.thread;
//            PigramGroupNotice *notice = thread.groupModel.notices.firstObject;
//            NSString *content = notice.content;
//
//            if (notice != nil && notice.status == 0 && content.length != 0) {
//                [self.view addSubview:self.lastNoticeView];
//                self.noticeContentTextView.text = [@"最新公告：" stringByAppendingString: content];
//            }else{
//                if (_lastNoticeView) {
//                    [_lastNoticeView removeFromSuperview];
//                }
//            }
//
//        }
//    }
    
    
    
    
    
}


extension HomeViewController{
    @objc
    func txAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(txRemoveThread(noti:)), name: NSNotification.Name.init("tx_remove_thread_action"), object: nil)
    }
    @objc
    func txRemoveThread(noti:Notification) {
        var obj = noti.object as? TSGroupThread
        SSKEnvironment.shared.databaseStorage.write { (transation) in
            obj?.anyRemove(transaction: transation)
        }
    }
   
}

extension UIResponder{
    @objc
    func tapLinkAction(link : String) {
        
        PigramNetworkMananger.pg_getInfoWithLink(link, success: { (response) in
            
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            var nav : UINavigationController?
            if rootVC?.isKind(of: UITabBarController.self) ?? false {
                let tabVC = rootVC as? UITabBarController
                let childVC = tabVC?.selectedViewController
                if childVC?.isKind(of: UINavigationController.self) ?? false {
                    nav = childVC as? UINavigationController
                    
                }
            }
            if let data = response as? [String:Any] ,let ID = data["id"] as? String{
                if ID.hasPrefix("___group___!") {

                    var thread : TSGroupThread?
                    let thread_id  = TSGroupThread.threadId(fromGroupId: ID);

                    SSKEnvironment.shared.databaseStorage.read { (read) in
                        thread = TSGroupThread.anyFetch(uniqueId: thread_id, transaction: read) as? TSGroupThread
                    }

                    if (thread?.groupModel.txGroupType == TXGroupTypeJoined) {
                        let vc = ConversationViewController.init()
                        vc.configure(for: thread!, action: .none, focusMessageId: nil)
                        vc.hidesBottomBarWhenPushed = true
                        nav?.setSecondSubVC(vc)


                    }else{
                        
                        let infoVC = PGGroupInfoVC.init()
                        infoVC.groupId = ID;
                        nav?.pushViewController(infoVC, animated: true)

                    }
                    
                    
                    
                    
                }else if ID.hasPrefix("___user____!"){
                    if ID == TSAccountManager.localUserId {
                        return
                    }
   
                    var thread : TSContactThread?
                    var profile : OWSUserProfile?
                    SSKEnvironment.shared.databaseStorage.read { (read) in
                        let address = SignalServiceAddress.init(phoneNumber: ID)
                        profile = OWSUserProfile.getFor(address, transaction: read)
                        if profile?.relationType == UserRelationShipType.friend{
                            thread = TSContactThread.getWithContactAddress(address, transaction: read)
                        }
                    }
                    
                    if thread != nil {
                        let vc = ConversationViewController.init()
                        vc.configure(for: thread!, action: .none, focusMessageId: nil)
                        vc.hidesBottomBarWhenPushed = true
                        nav?.setSecondSubVC(vc)
                    }else{
                        let vc = FriendSearchVC.init();
                        vc.channel = .link
                        vc.phoneNumber = ID
                        nav?.pushViewController(vc, animated: true)
                    }
                    
                }
            }

        }) { (error) in
            
        }
    }
}

extension ConversationViewController{
    
    @objc
    func tapLinkAction(item : ConversationViewItem ,link : String) {
        


        PigramNetworkMananger.pg_getInfoWithLink(link, success: { (response) in
            if let data = response as? [String:Any] ,let ID = data["id"] as? String{
                if ID.hasPrefix("___group___!") {
                    if item.thread.isGroupThread() {
                        let thread : TSGroupThread = item.thread as! TSGroupThread;
                        if thread.groupModel.groupId == ID {
                            return
                        }
                    }
                    var thread : TSGroupThread?
                    let thread_id  = TSGroupThread.threadId(fromGroupId: ID);

                    self.databaseStorage.read { (read) in
                        thread = TSGroupThread.anyFetch(uniqueId: thread_id, transaction: read) as? TSGroupThread
                    }

                    if (thread?.groupModel.txGroupType == TXGroupTypeJoined) {
                        let vc = ConversationViewController.init()
                        vc.configure(for: thread!, action: .none, focusMessageId: nil)
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.setSecondSubVC(vc)

                    }else{
                        
                        let infoVC = PGGroupInfoVC.init()
                        infoVC.groupId = ID;
                        self.navigationController?.pushViewController(infoVC, animated: true)

                    }
                    
                    
                    
                    
                }else if ID.hasPrefix("___user____!"){
                    if ID == TSAccountManager.localUserId {
                        return
                    }
                    if item.thread.isKind(of: TSContactThread.self){
                        let thread = item.thread as! TSContactThread
                        if thread.contactAddress.userid == ID {
                            return
                        }
                    }
                    var thread : TSContactThread?
                    var profile : OWSUserProfile?
                    self.databaseStorage.read { (read) in
                        let address = SignalServiceAddress.init(phoneNumber: ID)
                        profile = OWSUserProfile.getFor(address, transaction: read)
                        if profile?.relationType == UserRelationShipType.friend{
                            thread = TSContactThread.getWithContactAddress(address, transaction: read)
                        }
                    }
                    
                    if thread != nil {
                        let vc = ConversationViewController.init()
                        vc.configure(for: thread!, action: .none, focusMessageId: nil)
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.setSecondSubVC(vc)
                    }else{
                        let vc = FriendSearchVC.init();
                        vc.channel = .link
                        vc.phoneNumber = ID
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                }
            }

        }) { (error) in
            
        }
    }
    
}
