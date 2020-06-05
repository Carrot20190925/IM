//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

import UIKit

class TXEditGroupInfoVC: BaseVC {
    
    
    public var thread : TSGroupThread?
    var avatarViewHelper = AvatarViewHelper.init()
    
    var members : [OWSUserProfile] = []
    var tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
    var sectionItems = ["群名称","群头像"]
//    var complete:((_ name:String?,_ image:UIImage?) -> Void)?
    var name : String?
    var image : UIImage?
//    @objc
//    static func showGroupInfo(viewControllor:UIViewController,thread:TSGroupThread){
//        let info = TXEditGroupInfoVC.init()
//        info.thread = thread
//        let nav = BaseNavigationVC.init(rootViewController: info)
//            viewControllor.present(nav, animated: true) {
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "编辑资料"
//        self.setupNav()
        self.setupInit()
        self.setAvatarViewHelper()
        self.name = self.thread?.groupModel.groupName
//        self.image = self.thread?.groupModel.groupImage

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
//    func setupNav() {
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-leftBack"), style: .plain, target: self, action: #selector(goBack))
//    }
//    @objc
//    func goBack() {
//        self.navigationController?.dismiss(animated: true, completion: nil)
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
extension TXEditGroupInfoVC:AvatarViewHelperDelegate{
    func avatarActionSheetTitle() -> String? {
         return NSLocalizedString("PROFILE_VIEW_AVATAR_ACTIONSHEET_TITLE", comment: "Action Sheet title prompting the user for a profile avatar")
    }
    
    func avatarDidChange(_ image: UIImage) {
        self.setupAvatar(image: image)
        self.tableView.reloadData()
    }
    
    func fromViewController() -> UIViewController {
        return self
    }
    
    func hasClearAvatarAction() -> Bool {
        return false
    }
    
    func setAvatarViewHelper() {
        self.avatarViewHelper.delegate = self
    }

}
//extension ConversationViewController{
//    @objc
//    func showGroupInfo() {
//
//    }
//}

extension TXEditGroupInfoVC:UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout{
    private func setupInit(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = TXTheme.thirdColor()
        tableView.frame = self.view.bounds
        tableView.backgroundColor = TXTheme.thirdColor()
        tableView.register(TXGroupInfoCell.self, forCellReuseIdentifier: "TXGroupInfoCell")
        self.view.addSubview(tableView)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : TXGroupInfoCell = tableView.dequeueReusableCell(withIdentifier: "TXGroupInfoCell", for: indexPath) as! TXGroupInfoCell

        let text = self.sectionItems[indexPath.row]
        if text == "群名称" {
            cell.showNextBtn()
            cell.setSubtitle(subtitle: self.name)
            cell.avatarImageView.isHidden = true
        }else
        {
            cell.hiddenMore()
            cell.avatarImageView.isHidden = false
            let _ =  OWSAvatarBuilder.buildImage(thread: self.thread!, diameter: UInt(40)) ?? UIImage.init()

            if let image = self.image {
                cell.avatarImageView.image = image
            }else{
                
                
                let image =  OWSAvatarBuilder.buildImage(thread: self.thread!, diameter: UInt(40)) ?? UIImage.init()
                cell.avatarImageView.image = image
//                if let avatar = self.thread?.groupModel.getAvatarUrl(), let url = URL.init(string: avatar) {
//                    cell.avatarImageView.setImageWith(url)
//                }

            }
        }
        cell.tagLabel.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let text = self.sectionItems[indexPath.row]
        if text == "群名称" {
            let edit =   TXEditController.init()
            edit.type = TXEditController.EditType.group
            edit.complete = { [weak self] (name,editVC) in
                self?.name = name
                self?.setupGroupName(name: name,editVC)
//                self?.tableView.reloadData()
            }
            self.navigationController?.pushViewController(edit, animated: true)
        }else
        {
            self.avatarViewHelper.showChangeAvatarUI()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
     
        return 0.1
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
   

}
extension TXEditGroupInfoVC{
    //MARK:-  修改群头像
    func setupAvatar(image:UIImage) {
        guard let model = self.thread?.groupModel else {
          return
        }
        
        
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) {[weak self] (modal) in
            self?.image = image
            let size = CGSize(width: CGFloat.init(kOWSProfileManager_MaxAvatarDiameter) , height: CGFloat.init(kOWSProfileManager_MaxAvatarDiameter))

            let resizeImage = image.resizedImage(toFillPixelSize: size).withRenderingMode(.alwaysOriginal)
            let data =  OWSProfileManager.shared().processedImageData(forRawAvatar: resizeImage)
            
            OWSAttachmentUploadV2.init().uploadGroupAvatar(toService: data, clearLocalAvatar: {
                
            }, progressBlock: { (progress) in
                
            }, group_id: model.groupId).done { (respone) in
                
                if let key = respone as? String{
                    model.avatar = key
                    SSKEnvironment.shared.databaseStorage.write { (transaction) in
                        let thread = TSGroupThread.getOrCreateThread(with: model, transaction: transaction)
                        thread.anyUpdateGroupThread(transaction: transaction) { (thread) in
                            thread.groupModel.avatar = key
                        }

                        let profile = OWSUserProfile.getOrBuild(for: SignalServiceAddress.init(phoneNumber: model.groupId), transaction: transaction)
                        profile.update(withProfileName: profile.profileName, avatarUrlPath: key, avatarFileName: nil, transaction: transaction, completion: nil);

                    }
                }
//                [[SSKEnvironment shared].databaseStorage writeWithBlock:^(SDSAnyWriteTransaction * _Nonnull transaction) {
//                    TSGroupThread *thread = [TSGroupThread getOrCreateThreadWithGroupId:group_id];
//                    [thread anyUpdateGroupThreadWithTransaction:transaction block:^(TSGroupThread * _Nonnull thread) {
//                        thread.groupModel.avatar = form.formKey;
//                    }];
//                    SignalServiceAddress *address = [[SignalServiceAddress alloc]initWithPhoneNumber:group_id];
//
//                    OWSUserProfile *proflie = [OWSUserProfile getOrBuildUserProfileForAddress:address transaction:transaction];
//                    [proflie updateWithProfileName:proflie.profileName avatarUrlPath:form.formKey avatarFileName:nil transaction:transaction completion:nil];
//                }];
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showAlert(title: "修改成功")
                        self?.tableView.reloadData()
                    }

                }
            }.catch { (error) in
                DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showErrorAlert(message: error.localizedDescription)
                    }
                }

            }.retainUntilComplete()

            
//            PigramNetworkMananger.uploadPhotoMananager(image: image, success: { (urlString) in
//                guard let url = urlString else{
//                    DispatchQueue.main.async {
//                        modal.dismiss {
//                            OWSAlerts.showErrorAlert(message: "空链接")
//                        }
//                    }
//                    return
//                }
//                
//                
//                let params = ["avatar":url,"groupId":model.groupId]
//                PigramNetworkMananger.pgSetupGroupAvatarNetwork(params: params, success: { (_) in
//                    SSKEnvironment.shared.databaseStorage.write { (transaction) in
//                        let thread = TSGroupThread.getOrCreateThread(with: model, transaction: transaction)
//                        thread.anyUpdateGroupThread(transaction: transaction) { (thread) in
//                            thread.groupModel.avatar = url
//                        }
//                        
//                        let profile = OWSUserProfile.getOrBuild(for: SignalServiceAddress.init(phoneNumber: model.groupId), transaction: transaction)
//                        profile.update(withProfileName: profile.profileName, avatarUrlPath: url, avatarFileName: nil, transaction: transaction, completion: nil);
//
//                    }
//                    self?.image = image
//                    DispatchQueue.main.async {
//                        modal.dismiss {
//                            OWSAlerts.showAlert(title: "修改成功")
//                            self?.tableView.reloadData()
//                        }
//
//                    }
//                }) { (error) in
//                    DispatchQueue.main.async {
//                        modal.dismiss {
//                            OWSAlerts.showErrorAlert(message: error.localizedDescription)
//                        }
//                    }
//                }
//
//            }) { (error) in
//                
//                DispatchQueue.main.async {
//                    modal.dismiss {
//                        OWSAlerts.showErrorAlert(message: error.localizedDescription)
//                    }
//                }
//            }
        }
        

      
    }
    //MARK:-  修改群名称
    func setupGroupName(name:String,_ editVC:TXEditController){
        guard let model = self.thread?.groupModel else {
            return
        }
        let params = ["groupId":model.groupId,"title":name]
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true) {[weak self] (modal) in
            PigramNetworkMananger.pgSetupGroupNameNetwork(params: params, success: { (_) in
//                let groupModel = TSGroupModel.init(title: name, members: model.allMembers, groupId: model.groupId, owner: model.groupOwner)
//                groupModel.txSetup(oldModel: model)
//                SSKEnvironment.shared.databaseStorage.write { (trasaction) in
//                    let thread = TSGroupThread.getOrCreateThread(with: model, transaction: trasaction)
//                    thread.anyUpdateGroupThread(transaction: trasaction) { (thread) in
//                        thread.groupModel = groupModel
//                    }
//
//                }
                 DispatchQueue.main.async {
                    modal.dismiss {
                        editVC.navigationController?.popViewController(animated: true, completion: {
                            OWSAlerts.showAlert(title: "群名称修改成功")
                            self?.tableView.reloadData()
                        })
                    }
                 }
             }) { (error) in
                 DispatchQueue.main.async {
                    modal.dismiss {
                        OWSAlerts.showErrorAlert(message: error.localizedDescription)
                    }
                 }
             }
        }
 

    }

}
