//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class PigramEditorVC: BaseVC {
    
    
    
    var saveBtnClickCallback: ((_ text: String) -> Void)?
    
    var defaultText: String?
    
    var placeholder: String = "请输入...";

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.bottom;
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", style: .plain, target: self, action: #selector(rightBtnClick));
        
        self.view.addSubview(self.editField);
        self.editField.mas_makeConstraints { (make) in
            make?.top.offset()(20);
            make?.left.offset()(20);
            make?.right.offset()(-20);
        }
        self.editField.backgroundColor = UIColor.white
        self.editField.placeholder = self.placeholder
        self.editField.text = self.defaultText;
        // Do any additional setup after loading the view.
    }
    
    
    @objc
    func rightBtnClick() {
        
        self.saveBtnClickCallback?(self.editField.text!);
    }

    
    private var editField: UITextField = {
        
        let view = UITextField.init();
        view.borderStyle = .roundedRect;
        view.clearButtonMode = .always;
        return view;
        
    }();
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
