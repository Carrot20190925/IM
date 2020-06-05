//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXBaseNaviController: UINavigationController,UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let respond = self.responds(to: #selector(getter: interactivePopGestureRecognizer))
        if respond {
            self.interactivePopGestureRecognizer?.delegate = self
        }

    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            if self.viewControllers.count < 2||self.visibleViewController == self.viewControllers[0] {
                return false
            }
        }
        return true
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "register_goback"), style: .plain, target: self, action: #selector(goBack))
        self.hidesBottomBarWhenPushed = true

    }
 
    @objc
    func goBack() {
        self.popViewController(animated: true)
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
