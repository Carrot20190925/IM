//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

@objcMembers public
class PigramNetwork: NSObject {
    /**
     * 获取好友列表
     * status 0 拉取全部  1 == 好友  2 = 黑名单
     */
    static public func getMyFriendList(_ status: Int = 0, finished: (([OWSUserProfile]?, Error?) -> Void)?) {
        let request = OWSRequestFactory.pg_getMyFriendList(status);
        TSNetworkManager.shared().makePromise(request: request!).done({ (task, response) in
            if let array = response as? [[String : Any]] {
                
                var users:[OWSUserProfile] = [];
                for item in array {
                    let address = SignalServiceAddress.init(uuidString: nil, phoneNumber: item["destinationId"] as? String);
                    
                    var user: OWSUserProfile?
//                    kSignalDB.read { (read) in
//                        user = OWSUserProfile.getFor(address, transaction: read);
//                    }
                    let destinationAvatar = item["destinationAvatar"] as? String
                    let remarkName = item["remarkName"] as? String
                    let profileName = item["name"] as? String
                    
                    let relationType = UserRelationShipType.init(rawValue: item["status"] as! Int);
                    SSKEnvironment.shared.profileManager.fetchProfile(for: address);
//                    if user == nil {
                        kSignalDB.write { (write) in
                            user = OWSUserProfile.getOrBuild(for: address, transaction: write);
                            user?.relationType = relationType!;
                            user?.remarkName = remarkName
                            user?.anyUpdate(transaction: write, block: { (proflie) in
                                proflie.relationType = relationType!
                                proflie.remarkName = remarkName
                            })
                            user?.update(withProfileName: profileName, avatarUrlPath: destinationAvatar, avatarFileName: user?.avatarFileName, transaction: write, completion: nil);
                        }
//                    }
                    if user != nil {
                        users.append(user!);
                    }
                }
                finished?(users, nil);
            }
        }).catch({ (error) in
            finished?(nil, error);

            });
    }
    
    
    /**
     * 获取我的群列表
     *
     *
     */
    static public func getMyGroupList(_ status: Int = 0, finished: (([TSGroupModel]?, Error?) -> Void)?) {
    
    
        let request = OWSRequestFactory.pg_getMyGroupList();
        TSNetworkManager.shared().makePromise(request: request!).done({ (task, response) in
            if let array = response as? [[String : Any]] {
                
                var groups:[TSGroupModel] = [];
                for item in array {
                    let model = TSGroupModel.pg_initGroupModelDetial(item);
                    if model != nil {
                        groups.append(model!);
                    }
                }
                finished?(groups, nil);
            }
        }).catch({ (error) in
            finished?(nil, error);

        });
        
    }
    
    /**
     * 获取群信息
     * isNeedMember  1 == 获取全部群成员， 0： 一个群成员也不会返回
     *
     */
    static public func getGroupInfo(_ groupId: String, isNeedMembers: Bool = true, finished:((TSGroupModel?, Error?) -> Void)?) {
        
        
        let request = OWSRequestFactory.pg_getGroupInfo(groupId, isNeedMembers: isNeedMembers);
    
        TSNetworkManager.shared().makePromise(request: request!).done({ (task, response) in
            if let _response = response as? [String : Any] {
                
                let model = TSGroupModel.pg_initGroupModelDetial(_response);
                
                finished?(model,nil)
            } else {
                
                let error = NSError.init(domain: "data is nil", code: -9999, userInfo: nil);
                finished?(nil, error);
            }
        }).catch({ (error) in
            finished?(nil, error);
            
        }).retainUntilComplete();
    }
    /**
     * 获取群信息 会带上自己和群主
     *
     */
    static public func getGroupInfoIncludeMySelf(_ groupId: String, finished:((TSGroupModel?, Error?) -> Void)?) {
        
        
        let request = OWSRequestFactory.pg_getGroupInfoIncludeMyself(groupId);
    
        TSNetworkManager.shared().makePromise(request: request!).done({ (task, response) in
            if let _response = response as? [String : Any] {
                
                let model = TSGroupModel.pg_initGroupModelDetial(_response);
                
                finished?(model,nil)
            } else {
                
                let error = NSError.init(domain: "data is nil", code: -9999, userInfo: nil);
                finished?(nil, error);
            }
        }).catch({ (error) in
            finished?(nil, error);
            
        }).retainUntilComplete();
        
    }
    
}
