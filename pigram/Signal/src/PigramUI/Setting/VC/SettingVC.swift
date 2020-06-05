//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class SettingVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "更多";
        self.navigationItem.titleView = UIView.init();
        let label = UILabel.init();
        label.font = UIFont.boldSystemFont(ofSize: 27)
        label.textColor = UIColor.black;
        label.text = self.navigationItem.title;
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label, accessibilityIdentifier: "leftTitle");
        // Do any additional setup after loading the view.
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
