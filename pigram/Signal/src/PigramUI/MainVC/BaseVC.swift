//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class BaseVC: UIViewController {

    /**
     * 控制器返回后的回调
     */
    public var dismissCompeleted: ((_ id : Any) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.view.backgroundColor == nil {
            self.view.backgroundColor = UIColor.white;
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }
    

    
    
    deinit {
        print("basevc ---\(self) ---- 888888888888");
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
