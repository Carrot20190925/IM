//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation

@objc public class OWSAlerts: NSObject, UITextFieldDelegate{

    /// Cleanup and present alert for no permissions
    @objc
    public class func showNoMicrophonePermissionAlert() {
        let alertTitle = NSLocalizedString("CALL_AUDIO_PERMISSION_TITLE", comment: "Alert title when calling and permissions for microphone are missing")
        let alertMessage = NSLocalizedString("CALL_AUDIO_PERMISSION_MESSAGE", comment: "Alert message when calling and permissions for microphone are missing")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        let dismissAction = UIAlertAction(title: CommonStrings.dismissButton, style: .cancel)
        dismissAction.accessibilityIdentifier = "OWSAlerts.\("dismiss")"
        alert.addAction(dismissAction)

        if let settingsAction = CurrentAppContext().openSystemSettingsAction(completion: nil) {
            settingsAction.accessibilityIdentifier = "OWSAlerts.\("settings")"
            alert.addAction(settingsAction)
        }
        CurrentAppContext().frontmostViewController()?.presentAlert(alert)
    }

    @objc
    public class func showAlert(_ alert: UIAlertController) {
        guard let frontmostViewController = CurrentAppContext().frontmostViewController() else {
            owsFailDebug("frontmostViewController was unexpectedly nil")
            return
        }
        frontmostViewController.presentAlert(alert)
    }

    @objc
    public class func showAlert(title: String) {
        self.showAlert(title: title, message: nil, buttonTitle: nil)
    }

    @objc
    public class func showAlert(title: String?, message: String) {
        self.showAlert(title: title, message: message, buttonTitle: nil)
    }

    @objc
    public class func showAlert(title: String?, message: String? = nil, buttonTitle: String? = nil, buttonAction: ((UIAlertAction) -> Void)? = nil) {
        guard let fromViewController = CurrentAppContext().frontmostViewController() else {
            return
        }
        showAlert(title: title, message: message, buttonTitle: buttonTitle, buttonAction: buttonAction,
                  fromViewController: fromViewController)
    }

    @objc
    public class func showAlert(title: String?, message: String? = nil, buttonTitle: String? = nil, buttonAction: ((UIAlertAction) -> Void)? = nil, fromViewController: UIViewController?) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let actionTitle = buttonTitle ?? NSLocalizedString("OK", comment: "")
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: buttonAction)
        okAction.accessibilityIdentifier = "OWSAlerts.\("ok")"
        alert.addAction(okAction)
        fromViewController?.presentAlert(alert)
    }

    @objc
    public class func showConfirmationAlert(title: String, message: String? = nil, proceedTitle: String? = nil, proceedAction: @escaping (UIAlertAction) -> Void) {
        assert(title.count > 0)

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(self.cancelAction)

        let actionTitle = proceedTitle ?? NSLocalizedString("OK", comment: "")
        let okAction = UIAlertAction(title: actionTitle, style: .default, handler: proceedAction)
        okAction.accessibilityIdentifier = "OWSAlerts.\("ok")"
        alert.addAction(okAction)

        CurrentAppContext().frontmostViewController()?.presentAlert(alert)
    }

    @objc
    public class func showErrorAlert(message: String) {
        self.showAlert(title: CommonStrings.errorAlertTitle, message: message, buttonTitle: nil)
    }

    @objc
    public class var cancelAction: UIAlertAction {
        let action = UIAlertAction(title: CommonStrings.cancelButton, style: .cancel) { _ in
            Logger.debug("Cancel item")
            // Do nothing.
        }
        action.accessibilityIdentifier = "OWSAlerts.cancel"
        return action
    }

    @objc
    public class var dismissAction: UIAlertAction {
        let action = UIAlertAction(title: CommonStrings.dismissButton, style: .cancel) { _ in
            Logger.debug("Dismiss item")
            // Do nothing.
        }
        action.accessibilityIdentifier = "OWSAlerts.dismiss"
        return action
    }

    @objc
    public class func showPendingChangesAlert(discardAction: @escaping () -> Void) {
        let alert = UIAlertController(
            title: NSLocalizedString("NEW_GROUP_VIEW_UNSAVED_CHANGES_TITLE",
                                     comment: "The alert title if user tries to exit the new group view without saving changes."),
            message: NSLocalizedString("NEW_GROUP_VIEW_UNSAVED_CHANGES_MESSAGE",
                                       comment: "The alert message if user tries to exit the new group view without saving changes."),
            preferredStyle: .alert
        )

        let discardAction = UIAlertAction(
            title: NSLocalizedString("ALERT_DISCARD_BUTTON",
                                     comment: "The label for the 'discard' button in alerts and action sheets."),
            style: .destructive
        ) { _ in discardAction() }
        alert.addAction(discardAction)
        alert.addAction(OWSAlerts.cancelAction)

        OWSAlerts.showAlert(alert)
    }

    @objc
    public class func showIOSUpgradeNagIfNecessary() {
        // Our min SDK is iOS9, so this will only show for iOS9 users
        // TODO: Start nagging iOS 10 users now that we're bumping up
        // our min SDK to iOS 10.
        if #available(iOS 10.0, *) { return }

        // Don't nag legacy users if this is an end of life build
        // (the last build their OS version supports)
        guard !AppExpiry.isEndOfLifeOSVersion else { return }

        // Don't show the nag to users who have just launched
        // the app for the first time.
        guard AppVersion.sharedInstance().lastAppVersion != nil else {
            return
        }

        if let iOSUpgradeNagDate = Environment.shared.preferences.iOSUpgradeNagDate() {
            let kNagFrequencySeconds = 3 * kDayInterval
            guard fabs(iOSUpgradeNagDate.timeIntervalSinceNow) > kNagFrequencySeconds else {
                return
            }
        }

        Environment.shared.preferences.setIOSUpgradeNagDate(Date())

        OWSAlerts.showAlert(title: NSLocalizedString("UPGRADE_IOS_ALERT_TITLE",
                                                        comment: "Title for the alert indicating that user should upgrade iOS."),
                            message: NSLocalizedString("UPGRADE_IOS_ALERT_MESSAGE",
                                                      comment: "Message for the alert indicating that user should upgrade iOS."))
    }
    
    @objc
    public class func showActionSheet(fromVC: UIViewController,title: String, message: String, options:[String], selectedCallback: @escaping (Int) -> Void) {
        
        let vc = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet);
        for (index,item) in options.enumerated() {
           
            let action = UIAlertAction.init(title: item, style: .default) { (action) in
                               
                selectedCallback(index);
            }
            
            vc.addAction(action);
        }
        let cancleAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil);
        vc.addAction(cancleAction);
        fromVC.presentAlert(vc);
        
    }
    @objc
    public class func showEditAlert(fromVC: UIViewController, title: String, message: String, placeholder: String, completeCallback: @escaping (String) -> Void) {
        
        let vc = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        
        vc.addTextField { (textfield) in
            textfield.placeholder = placeholder;
            textfield.delegate = vc;
            textfield.accessibilityIdentifier = "pigram_showEditAlert";
        }
        
        let cancleAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil);
        vc.addAction(cancleAction);
        let confirmAction = UIAlertAction.init(title: "确定", style: .default) { (_) in
            
            if vc.textFields?.first?.text?.count ?? 0 > 0 {
                
                completeCallback(vc.textFields?.first?.text ?? "");
            }
        }
        confirmAction.isEnabled = false;
        vc.addAction(confirmAction);
        fromVC.presentAlert(vc);
        
        
        
        
    }
}

extension UIAlertController: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.accessibilityIdentifier == "pigram_showEditAlert"{
            let name = textField.text as NSString? ?? "";
            let newString = name.replacingCharacters(in: range, with: string)
            let confirmAction = self.actions.last;
            confirmAction?.isEnabled = newString.count > 0 ? true : false;
        }
        
        
        
        return true;
    }
    
    
}
