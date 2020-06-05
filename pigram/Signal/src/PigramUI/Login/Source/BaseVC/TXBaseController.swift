//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXBaseController: UIViewController {

    let onboardingController: TXLoginManagerController
    init(onboardingController:TXLoginManagerController) {
        self.onboardingController = onboardingController
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage.init(color: UIColor.clear)
        self.navigationController?.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()


        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.view.becomeFirstResponder()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.view.resignFirstResponder()
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
