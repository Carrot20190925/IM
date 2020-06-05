//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXNewGroupController: OWSViewController,UITableViewDataSource,UITableViewDelegate {
    var friendList:NSMutableArray = NSMutableArray.init()
    var selectedFriendList:NSMutableArray = NSMutableArray.init()
    var friendMapList:NSMutableDictionary = NSMutableDictionary.init()
    var friendKeyList = NSArray.init()
    var tableView: UITableView?
    var groupId: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        self.setupTabelView()
        self.setupNav()
        // Do any additional setup after loading the view.
    }
    func setupTabelView() {
        self.tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
        self.view.addSubview(self.tableView!)
        self.tableView?.register(UINib.init(nibName: "TXFriendGroupCell", bundle: Bundle.main), forCellReuseIdentifier: "TXFriendGroupCell")
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    func getGroupModel() -> TSGroupModel {
        let nameGroup = "".ows_stripped
        var addressList:[SignalServiceAddress] = []
        for profile in self.selectedFriendList {
            let prosure = profile as! OWSUserProfile
            addressList.append(prosure.address)
        }
        addressList.append(TSAccountManager.localAddress!)
        let groupId = Randomness.generateRandomBytes(kGroupIdLength)
        return TSGroupModel.init(title: nameGroup(), members: addressList, image: nil, groupId: groupId)
    }
    
    func getDatabaseStorage() -> SDSDatabaseStorage {
        return SSKEnvironment.shared.databaseStorage
    }
    func setupData() {
        self.getDatabaseStorage().uiRead { (transaction) in
            self.friendList = NSMutableArray.init(array: OWSUserProfile.anyFetchAll(transaction: transaction))
        }
        
        var localArray:[OWSUserProfile] = []
    
        for profile in self.friendList {
            let localAdrress = OWSUserProfile.localProfileAddress()
            if localAdrress == (profile as! OWSUserProfile).address {
                localArray.append(profile as! OWSUserProfile)
                    print("phoneNumber" + (localAdrress.phoneNumber ?? ""))
            }
            let localPhoneNumAddress = TSAccountManager.localAddress
            if localPhoneNumAddress == (profile as! OWSUserProfile).address {
                localArray.append(profile as! OWSUserProfile)
                print("phoneNumber" + (localAdrress.phoneNumber ?? ""))
            }
        }
        
        self.friendList.removeObjects(in: localArray)
        self.setupDataAction()
        self.tableView?.reloadData()
    }
    func setupDataAction() {
        let friendDic = NSMutableDictionary.init()
        for profile in self.friendList {
            let profileSure =  profile as! OWSUserProfile
            let profileFirst: String!
            var profileList: NSMutableArray?
            if let profileName = profileSure.profileName{
                profileFirst = String.init(profileName.first ?? "1")
                profileList = friendDic.object(forKey: profileFirst ?? "1") as? NSMutableArray
                               
            }else
            {
                profileFirst = String.init("2")
                profileList = friendDic.object(forKey: profileFirst ?? "2") as? NSMutableArray
            }
            
            let item = TXAddFriendModel.init(item: profile as! OWSUserProfile)
            if profileList != nil {
                let proListSure = profileList!
                   proListSure.add(item)
            }else{
                profileList = NSMutableArray.init(object: item)
                friendDic.setValue(profileList, forKey: profileFirst)
           }
        }
        self.friendMapList = friendDic.mutableCopy() as! NSMutableDictionary
        let allKeys = NSArray.init(array: friendDic.allKeys)
        self.friendKeyList = NSArray.init(array: allKeys.sorted(by: { (one, two) -> Bool in
            return true
        }))
        
    }
    
    
    
    func setupNav() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "完成", style: .plain, target: self, action: #selector(TXNewGroupController.finishAction))
        self.navigationItem.title = "创建群组"
          
      }
    
    @objc func finishAction() {
        let groupModel = self.getGroupModel()
        var thread: TSGroupThread? = nil
        self.getDatabaseStorage().write { (transaction) in
            thread = TSGroupThread.getOrCreateThread(with: groupModel, transaction: transaction)
        }
        OWSProfileManager.shared().addThread(toProfileWhitelist: thread!)
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { (modalActivityIndicator) in
            let message = TSOutgoingMessage.init(in: thread!, groupMetaMessage: TSGroupMetaMessage.new, expiresInSeconds: 0)
//            let dataMessageBuilder = message.dataMessageBuilder()
//            dataMessageBuilder.
            
                   message.update(withCustomMessage: NSLocalizedString("GROUP_CREATED", comment: "Group created."))
                   let globalQueue = DispatchQueue.global()
                   globalQueue.async {
                       SSKEnvironment.shared.messageSender.sendMessage(message.asPreparer, success: {
                           let mainqueue = DispatchQueue.main
                           mainqueue.async {
                               SignalApp.shared().presentConversation(for: thread!, action: ConversationViewAction.compose, animated: false)
                               self.presentingViewController?.dismiss(animated: true, completion: nil)
                           }
                       }) { (error) in
                           let mainqueue = DispatchQueue.main
                           let errorMessage = TSErrorMessage.init(timestamp: NSDate.ows_millisecondTimeStamp(), in: thread!, failedMessageType: TSErrorMessageType.groupCreationFailed)
                           
                           self.getDatabaseStorage().write { (transaction) in
                               errorMessage .anyInsert(transaction: transaction)
                           }
                           mainqueue.async {
                               SignalApp.shared().presentConversation(for: thread!, action: ConversationViewAction.compose, animated: false)
                               self.presentingViewController?.dismiss(animated: true, completion: nil)
                           }

                       }
                   }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.friendKeyList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keyString = self.friendKeyList.object(at: section)
        let array = self.friendMapList.object(forKey: keyString) as! NSMutableArray
        return array.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : TXFriendGroupCell = tableView.dequeueReusableCell(withIdentifier: "TXFriendGroupCell", for: indexPath) as! TXFriendGroupCell
        let keyString = self.friendKeyList.object(at: indexPath.section)
        let array = self.friendMapList.object(forKey: keyString) as! NSMutableArray
        let item : TXAddFriendModel = (array.object(at: indexPath.row) as! TXAddFriendModel)
        if item.selected {
            cell.selectedBtn.setImage(UIImage.init(named: "image_editor_checkmark_full"), for: .normal)
        }else
        {
            cell.selectedBtn.setImage(UIImage.init(named: "image_editor_checkmark_empty"), for: .normal)
        }
        let itemProfile = item.item
        cell.nameLabel?.text =  itemProfile?.profileName ?? itemProfile?.address.phoneNumber
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let label = UILabel.init()
//        let keyString = self.friendKeyList.object(at: section) as! String
//        label.text = keyString
//        return label
//
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keyString = self.friendKeyList.object(at: indexPath.section)
        let array = self.friendMapList.object(forKey: keyString) as! NSMutableArray
        let item : TXAddFriendModel = array.object(at: indexPath.row) as! TXAddFriendModel
        if item.selected {
            self.selectedFriendList.remove(item.item!)

        }else{
            self.selectedFriendList.add(item.item!)
        }
        item.selected = !item.selected
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keyString = self.friendKeyList.object(at: section) as! String
        return  keyString
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
