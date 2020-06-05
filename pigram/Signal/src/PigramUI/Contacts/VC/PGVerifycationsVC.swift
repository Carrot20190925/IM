//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class PGVerifycationsVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = kPigramLocalizeString("验证消息", nil);
        self.setupSubView();
        self.extendedLayoutIncludesOpaqueBars = false;
        // Do any additional setup after loading the view.
    }
   
    
    private func setupSubView() {
        
        
        let view = UIView.init();
        view.backgroundColor = UIColor.white;
        self.view.addSubview(view);
        
        let imgView = UIImageView.init();
        imgView.image = UIImage.init(named: "pigram-group-verify");
        
        let btn = UIButton.init(type: .system);
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside);
        
        let titleLabel = UILabel.init();
        titleLabel.font = UIFont.systemFont(ofSize: 15);
        titleLabel.textColor = UIColor.darkGray;
        titleLabel.text = kPigramLocalizeString("群通知", nil);
        let subTitle = UILabel.init();
        subTitle.font = UIFont.systemFont(ofSize: 12);
        subTitle.textColor = UIColor.hex("68727e");
        subTitle.text = kPigramLocalizeString("群消息通知", nil);
        
        let accessoryView = UIImageView.init();
        accessoryView.image = UIImage.init(named: "pigram-common-right-arrow");
        view.addSubview(imgView);
        view.addSubview(titleLabel);
        view.addSubview(subTitle);
        view.addSubview(accessoryView);
        view.addSubview(btn);
        view.addSubview(self.unreadView);
        
        self.unreadView.mas_makeConstraints { (make) in
            make?.centerY.offset();
            make?.right.equalTo()(accessoryView.mas_left)?.offset()(-20);
        }
        
        view.mas_makeConstraints { (make) in
            make?.left.right()?.offset();
            make?.height.offset()(60);
            make?.top.equalTo()(self.mas_topLayoutGuide)?.offset();
        }
        
        imgView.mas_makeConstraints { (make) in
            make?.left.offset()(20);
            make?.centerY.offset();
        }
        titleLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(imgView.mas_right)?.offset()(15);
            make?.top.offset()(16);
        }
        subTitle.mas_makeConstraints { (make) in
            make?.left.equalTo()(imgView.mas_right)?.offset()(15);
            make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(5);
        }
        
        accessoryView.mas_makeConstraints { (make) in
            make?.centerY.offset();
            make?.right.offset()(-16);
        }
        
        btn.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        
        let vc = NewFriendVC.init();
        self.addChild(vc);
        self.view.addSubview(vc.view);
        vc.view.mas_makeConstraints { (make) in
            make?.left.right()?.bottom()?.offset();
            make?.top.equalTo()(view.mas_bottom);
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.unreadView.setUnreadNumber(PigramVerifyManager.shared.getAllGroupVerifications().count);
    }
    
    @objc
    func btnClick () {
        
        let vc = PGGroupVerifycationsVC.init();
        
        self.navigationController?.pushViewController(vc, animated: true);
        
    }

    private var unreadView: DYUnreadView = {
        
        let view = DYUnreadView.init();
        view.setUnreadNumber(0);
        return view;
        
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
