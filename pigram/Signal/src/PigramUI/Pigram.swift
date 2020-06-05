//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import Foundation
import PromiseKit


func MyLog<T>(_ message : T,file:String = #file,function:String = #function,line:Int = #line) {
    
    #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        debugPrint("\(message)    File: \(fileName); Line : \(line); Function: \(function)")
    #endif
}

let kSignalDB = SSKEnvironment.shared.databaseStorage;
let kPigramThemeColor = UIColor.hex("#3ca6ff");

/**
 * 国际化
 */
public func kPigramLocalizeString(_ key:String, _ desc: String?) -> String {
    return NSLocalizedString(key, comment: desc ?? "");
    
}

/**
 * push 会话VC
 */
public func pg_showConversationVC(fromNavgationVC:UINavigationController, thread: TSThread) {
    
    let vc = ConversationViewController.init();
    
    vc.configure(for: thread, action: .none, focusMessageId: nil);
    vc.hidesBottomBarWhenPushed = true;
    fromNavgationVC.setSecondSubVC(vc);
    
}

extension NSNotification.Name {
    
        ///好友申请
    static let kNotification_Friend_Invite_apply = NSNotification.Name("kNotification_Friend_Invite_apply");
        ///同意好友申请
    static let kNotification_Friend_Invite_accept = NSNotification.Name("kNotification_Friend_Invite_accept");
   ///收到新消息
    static let kNotification_Pigram_New_Message = NSNotification.Name("kNotification_Pigram_New_Message");
    
    ///收到入群申请
    static let kNotification_Pigram_Group_Apply = NSNotification.Name("kNotification_Pigram_Group_Apply");

    ///有人处理入群申请
    static let kNotification_Pigram_Group_Apply_handled = NSNotification.Name("kNotification_Pigram_Group_Apply_handled");
    
    ///有人处理了入群申请 并且更新群组信息完成
    static let kNotification_Pigram_Group_Apply_handled_finished = NSNotification.Name("kNotification_Pigram_Group_Apply_handled_finished");
    
    ///同步获取群组信息
    static let kNotification_Pigram_Get_GroupInfo_Sync = NSNotification.Name("kNotification_Pigram_Get_GroupInfo_Sync");
    //管理权限被取消
    static let kNotification_Pigram_Group_Romove_Manager_handled = NSNotification.Name("kNotification_Pigram_Group_Romove_Manager_handled");
    //处理离线消息完成
    static let kNotificaation_Pigram_Offline_Message_Finished = NSNotification.Name("kNotificaation_Pigram_Offline_Message_Finished");


}

@objcMembers public class PigramInitialObjc: NSObject {
    
    public static func pg_Initialize() {
        
        PigramMessageHandler.pg_initialize();
        PigramInitialObjc.shared.pg_instanceInitialize();
        PigramVerifyManager.pg_initialize();
        PigramGroupManager.pg_initialize();
    }
    
    static let shared = PigramInitialObjc.init();
    
    
    private override init() {
        super.init();
       
    }
    
    private func pg_instanceInitialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccessful), name: Notification.Name.init("kNotification_login_successsful"), object: nil);
        if TSAccountManager.sharedInstance().isRegistered {
            PigramNetwork.getMyFriendList(finished: nil);

        }
        
        
//               if TSAccountManager.sharedInstance().storedServerAuthToken()?.length ?? 0 > 0 {
//               }
    }

    @objc
    private func loginSuccessful() {
        if TSAccountManager.sharedInstance().isRegistered {
            PigramNetwork.getMyFriendList(finished: nil);
            PigramNetwork.getMyGroupList(finished: nil);
        }
        
    }
    
    
    
}

