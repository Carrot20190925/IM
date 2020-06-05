//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXGroupInfoCell: DYTableViewCell {

    var switchAction : ((_ switch : UISwitch) -> Void)?
    let slider = UISwitch.init()
    let tagLabel = UILabel.init()
    private let nextBtn = TXLeftTitleButton.init()
    var longPressAction : ((_ cell : TXGroupInfoCell) -> Void)?
    lazy var avatarImageView: AvatarImageView = {
       
        let imageView = AvatarImageView.init()
        self.addSubview(imageView)
        imageView.mas_makeConstraints { [weak self] (make) in
            make?.right.mas_equalTo()(-20)
            make?.centerY.mas_equalTo()(self?.mas_centerY)
            make?.size.mas_equalTo()(40)
        }
        return imageView
  
    }()
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.tagLabel.textColor =  TXTheme.titleColor()
        self.switchAction = nil
        self.slider.isUserInteractionEnabled = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setupUI();
    }
    
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var model: AnyObject? {
        
        
        didSet {
            
            if let _model = self.model as? PGGroupNotifyManagerModel {
                
                self.tagLabel.text = _model.contentStr;
                self.showSlider();
                self.slider.setOn(_model.isSwitch, animated: true);
                
            }
            
        }
        
    }
    
    
    
    private  func setupUI() {
        self.backgroundColor = UIColor.white
        tagLabel.textColor = TXTheme.titleColor()
        nextBtn.setImage(UIImage.init(named: "more_next"), for: .normal)
        nextBtn.setTitleColor(TXTheme.fourthColor(), for: .normal)
        nextBtn.isUserInteractionEnabled = false
        self.contentView.addSubview(tagLabel)
        self.contentView.addSubview(nextBtn)
        self.contentView.addSubview(slider)
        tagLabel.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(20)
            make?.centerY.mas_equalTo()(self.contentView.mas_centerY)
        }
        
        nextBtn.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(-20)
            make?.centerY.mas_equalTo()(self.contentView.mas_centerY)
            make?.left.mas_greaterThanOrEqualTo()(tagLabel.mas_right)?.offset()(20)
        }
        slider.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(-20)
            make?.centerY.mas_equalTo()(self.contentView.mas_centerY)
        }
        slider.addTarget(self, action: #selector(tapSwitchAction), for: .valueChanged)
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(longPress:)))
        self.contentView.addGestureRecognizer(longPress)
    }
    
    @objc func longPress(longPress : UILongPressGestureRecognizer){
        if longPress.state == .began {
            self.longPressAction?(self)
        }
    }
    
    
    func setImage(image:UIImage?) {
        self.nextBtn.setImage(image, for: UIControl.State.normal)
    }
    @objc
    private func tapSwitchAction(){
        self.switchAction?(self.slider)
        if let _model = self.model as? PGGroupNotifyManagerModel {
            _model.isSwitch = self.slider.isOn;
            self.otherClickFlag?(self.model as Any, 1001);
        }
    }
    
    func setSubtitle(subtitle:String?) {
        guard var sub = subtitle else {
            self.nextBtn.setTitle(subtitle, for: .normal)
            return
        }
        sub = sub + "  "
        self.nextBtn.setTitle(sub, for: .normal)
    }
    func showNextBtn() {
        self.nextBtn.isHidden = false
        self.slider.isHidden = true
    }
    
    func hiddenMore() {
        self.nextBtn.isHidden = true
        self.slider.isHidden = true
    }

    func  showSlider() {
        self.nextBtn.isHidden = true
        self.slider.isHidden = false
    }
    

 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
