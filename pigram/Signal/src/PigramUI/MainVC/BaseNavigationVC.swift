//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class BaseNavigationVC: UINavigationController ,UIGestureRecognizerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        let respond = self.responds(to: #selector(getter: interactivePopGestureRecognizer))
        if respond {
          self.interactivePopGestureRecognizer?.delegate = self
        }
//        self.navigationBar.shadowImage = UIImage.init();
//        let image = UIImage.init(color: UIColor.white)
//        self.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage.init()
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor :  TXTheme.titleColor()]
        // Do any additional setup after loading the view.
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
        
        if self.children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "pigram-nav-leftBack"), style: .plain, target: self, action: #selector(backBtnClick))

        }
        super.pushViewController(viewController, animated: animated);

    }
    @objc
    private func backBtnClick() {
        self.popViewController(animated: true);
    }


}
