//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXMoreHeadView: UIView {
//    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var phoneLabel: UILabel = UILabel.init()
    var userNameLabel: UILabel = UILabel.init()
    var QRImageView: UIImageView = UIImageView.init()
    var iconImageView: UIImageView = UIImageView.init()
    
    var action : (() -> Void)!
    
    func initUI() {
        self.addSubview(phoneLabel)
        self.addSubview(userNameLabel)
        self.addSubview(QRImageView)
        self.addSubview(iconImageView)
        iconImageView.mas_makeConstraints {[weak self] (make) in
            make?.left.mas_equalTo()(20)
            make?.centerY.mas_equalTo()(self?.mas_centerY)
            make?.width.height()?.mas_equalTo()(50)
        }
        userNameLabel.mas_makeConstraints { (make) in
            make?.top.mas_equalTo()(iconImageView.mas_top)
            make?.left.mas_equalTo()(iconImageView.mas_right)?.offset()(10)
        }
        phoneLabel.mas_makeConstraints { (make) in
            make?.bottom.mas_equalTo()(iconImageView.mas_bottom)
            make?.left.mas_equalTo()(userNameLabel.mas_left)
        }
        QRImageView.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(-20)
            make?.width.height()?.mas_equalTo()(50)
            make?.centerY.mas_equalTo()(iconImageView.mas_centerY)
        }
        QRImageView.image = UIImage.init(named: "more_qr")?.withRenderingMode(.alwaysOriginal)
        self.iconImageView.layer.cornerRadius = 25
        self.iconImageView.clipsToBounds = true
        self.userNameLabel.textColor = TXTheme.titleColor()
        self.userNameLabel.font = TXTheme.mainTitleFont()
        self.phoneLabel.textColor = TXTheme.titleColor()
        self.phoneLabel.font = TXTheme.mainTitleFont()
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapHeaderAction))
        self.addGestureRecognizer(tap)
        
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //    var iconImageView = UIImageView.init()
//    var userNameLabel = UILabel.init()
//    var phoneLabel = UILabel.init()
//    var QRImageView = UIImageView.init()
    override func awakeFromNib() {
        super.awakeFromNib()
//        if !UIDevice.current.hasIPhoneXNotch {
//            self.topConstraint.constant = 84
//        }

        
    }
    @objc
    func tapHeaderAction() {
        self.action()
    }
  

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
