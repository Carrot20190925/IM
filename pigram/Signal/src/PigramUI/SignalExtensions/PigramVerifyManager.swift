//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
//import MJExtension
import Mantle

fileprivate let kStoreVerifycation_Key = "kStoreVerifycation_Key";


/**
 * 好友验证和群验证消息模型
 *
 */
@objc
class PigramVerifyModel: MTLModel, MTLJSONSerializing {
   
    
    static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        
        return NSDictionary.mtl_identityPropertyMap(withModel: self.classForCoder());
    }
    
    
    @objc enum  PigramVerifyType: Int {
        case unknow = 0
        case contact = 1;
        case group = 2;
    }
    
    /**
     * 申请人id  电话号码
     */
    @objc
    public var applyId: String?
    
    /**
     * 好友：为电话号码   群组：groupid
     */
    @objc public var destinationId: String?
    
    /**
     * 用户编辑的验证内容
     */
    @objc public var content: String?
    
    /**
     * 添加渠道
     */
    @objc
    private var channel: Int;
    
    public var channelType: PigramFriendChannel? {
        
        didSet {
            self.channel = self.channelType?.rawValue ?? 0;
        }
    }
    
    public var applyAddress: SignalServiceAddress?;
    
    @objc var type: PigramVerifyType {
        
        let address = SignalServiceAddress.init(phoneNumber: self.destinationId);
        return PigramVerifyType.init(rawValue: address.type.rawValue)!;
        
    }
    
    /**
     * 唯一id
     */
    @objc var uniqueID: String? {
        
        guard let applyid = self.applyId, let destinationid = self.destinationId else {
            return nil;
        }
        return applyid + destinationid;
    }
    
    @objc
    required init(applyid: String, destinationid: String) {
        self.applyId = applyid;
        self.destinationId = destinationid;
        self.channel = 0;
        super.init();
        self.applyAddress = SignalServiceAddress.init(phoneNumber: applyid);
    }
    
    required init(dictionary dictionaryValue: [String : Any]!) throws {
        let applyId = dictionaryValue["applyId"] as? String;
        let destinationId = dictionaryValue["destinationId"] as? String;
        if applyId == nil || destinationId == nil {
            throw NSError.init(domain: "缺少必要的id", code: -1001, userInfo: nil);
        }
        self.applyId = applyId;
        self.destinationId = destinationId;
        self.content = dictionaryValue["content"] as? String;
        self.applyAddress = SignalServiceAddress.init(phoneNumber: self.applyId ?? "");
        self.channel = dictionaryValue["channel"] as? Int ?? 0;
        self.channelType = PigramFriendChannel.init(rawValue: Int(dictionaryValue["channel"] as? Int ?? 0));
        super.init();
    }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func groupId() -> String? {
        
        if self.type != .group {
            return nil;
        }
        
        return self.destinationId ?? "";
        
    }
    
}

/**
 * 验证信息管理类
 */
class PigramVerifyManager: NSObject {
    static let shared = PigramVerifyManager.init();
       
       private override init() {
           super.init();
//           self.addObserver();
       }
    

//    func addObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(removeGroupVerifyAction(_:)), name: NSNotification.Name.init("kNotification_Pigram_Group_Romove_Manager_handled"), object: nil)
//    }

    
    public func deleteVerifacation(_ model: PigramVerifyModel) {
        if model.uniqueID?.length == 0 {
                   return;
               }
        
            do {
                let fileManager = FileManager.default;
                let path = self.filePath + "/" + model.uniqueID!;
                let isExist = fileManager.fileExists(atPath: path);
                if isExist {
                    try fileManager.removeItem(atPath: path);
                }
                
                self.verifycations.removeValue(forKey: model.uniqueID!);

            } catch let error {
                
                owsFormatLogMessage(error.localizedDescription);
                
            }
       
    }

    public static func pg_initialize() {
        
        PigramVerifyManager.shared.getAllVerifications();
        
    }
    
    
    public func updateOrAddVerifycation(_ model: PigramVerifyModel) {
        if model.uniqueID?.length == 0 {
            return;
        }
        do {
            let json = try MTLJSONAdapter.jsonDictionary(fromModel: model);
            let key  = model.uniqueID;
            let data = try JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed);
            let fileUrl = self.filePath + "/" + key!;
            let fileManager = FileManager.default;
            let url = URL.init(fileURLWithPath: fileUrl);
            if fileManager.fileExists(atPath: fileUrl) {
                try fileManager.removeItem(at: url);
            }
            try fileManager.createDirectory(atPath: self.filePath, withIntermediateDirectories: true, attributes: nil)

            try data.write(to: url);
            self.verifycations[model.uniqueID!] = model;
            
        } catch let error {
            
            owsFormatLogMessage(error.localizedDescription);
            
        }
        
    }
   
    
    
    public func getAllGroupVerifications() -> [PigramVerifyModel] {
        
        var groups: [PigramVerifyModel] = [];
        
        for item in self.verifycations.values {
            
            if item.type == .group {
                groups.append(item);
            }
        }

        return groups;
    }
    
    public func getAllFriendVerifications() -> [PigramVerifyModel] {
        
        var friends: [PigramVerifyModel] = [];
        for item in self.verifycations.values {
            
            if item.type == .contact {
                friends.append(item);
            }
        }

        return friends;
    }
    
    
    public func getAllVerifications() -> [PigramVerifyModel]?  {
        var verifications: [PigramVerifyModel] = [];
//        self.verifycations.removeAll()
        do {
            let fileManager = FileManager.default;
            let urls = try fileManager.subpathsOfDirectory(atPath: self.filePath);
            for item in urls {
                let path = self.filePath + "/" + item;
                let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path));
                let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String : Any];
                let applyId = json?["applyId"] as? String;
                let destinationId = json?["destinationId"] as? String;
                if applyId == nil || destinationId == nil {
                    try fileManager.removeItem(at: URL.init(fileURLWithPath: path));
                    
                }
                let model = try? PigramVerifyModel.init(dictionary: json);
                if let _value = model {
                    self.verifycations[_value.uniqueID!] = _value;
                }
            }
            
            for item in self.verifycations.values {
                verifications.append(item);
            }
        } catch let error {
            owsFormatLogMessage(error.localizedDescription);
            return nil;
        }
        return verifications;
    }
    
    private lazy var filePath: String = {

        let directory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first;

        let path = directory?.appending("/PigramVerify");
        return path!;
    }()
    //MARK:-  清除所有验证消息
    func clearAllVerify() {
        if FileManager.default.fileExists(atPath: self.filePath) {
            do {
                try FileManager.default.removeItem(atPath: self.filePath)
            }catch{
                OWSLogger.debug("删除失败")
            }
        }
    }
    //MARK:-  清除好友验证消息
    func clearFriendVerify()  {
        
    }
    
    //MARK:-  清除对应groupId验证
    func clearGroupVerify(groupId:String) {
    
        
//        do {
//            let fileManager = FileManager.default;
//            let urls = try fileManager.subpathsOfDirectory(atPath: self.filePath);
//            for item in urls {
//                let path = self.filePath + "/" + item;
//                let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path));
//                let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String : Any];
//                let applyId = json?["applyId"] as? String;
//                let destinationId = json?["destinationId"] as? String;
//                if applyId == nil || destinationId == nil {
//                    try fileManager.removeItem(at: URL.init(fileURLWithPath: path));
//                }
//                if destinationId == groupId {
//                    try fileManager.removeItem(at: URL.init(fileURLWithPath: path));
//                }
//
//            }
//        }catch let error{
//            
//        }
        let models = self.verifycations.map { (model) -> PigramVerifyModel in
            return model.value
        }
        for model in models {
            if model.destinationId == groupId {
                self.deleteVerifacation(model)
            }
        }
        
//        self.g.etAllVerifications()
//        self.verifycations = self.getAllVerifications()
    }
    /**
     * key = applyid + destinationid
     */
    private var verifycations: [String : PigramVerifyModel] = [:];
    
}
