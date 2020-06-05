//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class NewFriendCell: DYTableViewCell {

    
    override var model: AnyObject? {
        
        didSet {
            
            if let model = self.model as? PigramVerifyModel {
                
                var profile:OWSUserProfile?
                let address = SignalServiceAddress.init(phoneNumber: model.applyId);
                SSKEnvironment.shared.databaseStorage.write { (write) in
                    
                    profile = OWSUserProfile.getOrBuild(for: address, transaction: write);
                }
                if model.type == .group {
                    var group:OWSUserProfile?
                    let gAddress = SignalServiceAddress.init(phoneNumber: model.destinationId);
                    SSKEnvironment.shared.databaseStorage.write { (write) in
                        group = OWSUserProfile.getOrBuild(for: gAddress, transaction: write);
                    }
                    self.updateVerifycationCell(profile!, groupProfile: group!);
                    var image = profile?.getContactAvatarImage();
                    image = image?.resizedImage(to: CGSize.init(width: 52, height: 52));
                    self.avatarView.image = image;
                    self.subTitle.text = "";
                    if subTitle.text?.length == 0 {
                        self.nickLabel.mas_updateConstraints({ (make) in
                            make?.centerY.offset();
                            make?.left.equalTo()(self.avatarView.mas_right)?.offset()(8);
                            make?.right.offset()(-80);
                        })
                    }
                    
                } else if model.type == .contact {
                    self.nickLabel.text = profile?.getDisplayName();
                    if profile?.profileName == nil || profile?.profileName?.count == 0 {
                        ProfileFetcherJob.init().getAndUpdateProfile(address: SignalServiceAddress.init(phoneNumber: model.applyId)) { (_, _) in
                            
                            DispatchQueue.main.async {
                                self.nickLabel.text = profile?.getContactName();
                            }
                            
                        };
                    }
                    var image = profile?.getContactAvatarImage();
                    image = image?.resizedImage(to: CGSize.init(width: 52, height: 52));
                    self.avatarView.image = image;
                    let array = ["手机号搜索","扫一扫", "群来源", "名片分享","名片分享","PG号",];
                    self.subTitle.text = array[model.channelType?.rawValue ?? 0];
                }
                
                
                
            }
            
        }
        
    }
    
    private func updateVerifycationCell(_ profile: OWSUserProfile, groupProfile: OWSUserProfile) {
        let applyAttr = NSMutableAttributedString.init(string: profile.getContactName(), attributes: [NSAttributedString.Key.foregroundColor : kPigramThemeColor as Any, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]);
        let attribute = NSAttributedString.init(string: kPigramLocalizeString("申请加入群", nil), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black as Any, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)])
        let destinationAttr = NSAttributedString.init(string: groupProfile.profileName ?? "***", attributes: [NSAttributedString.Key.foregroundColor : kPigramThemeColor as Any, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]);
        applyAttr.append(attribute);
        applyAttr.append(destinationAttr);
        self.nickLabel.attributedText = applyAttr;
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        
        self.contentView.addSubview(self.avatarView);
        self.contentView.addSubview(self.nickLabel);
        self.contentView.addSubview(self.subTitle);
        self.avatarView.mas_makeConstraints { (make) in
            make?.centerY.offset();
            make?.size.offset()(52);
            make?.left.offset()(20);
        }
        self.nickLabel.mas_makeConstraints { (make) in
            make?.top.offset()(12);
            make?.left.equalTo()(self.avatarView.mas_right)?.offset()(8);
            make?.right.offset()(-80);
        }
        self.subTitle.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.nickLabel.mas_bottom)?.offset()(10);
            make?.left.equalTo()(self.nickLabel.mas_left);
            make?.right.offset()(-80);

        }
        self.avatarView.addRound(26);
        self.contentView.addSubview(self.addBtn);
        self.addBtn.mas_makeConstraints { (make) in
            make?.centerY.offset();
            make?.right.offset()(-15);
            make?.width.offset()(54);
            make?.height.offset()(29);
        }
        self.addBtn.addTarget(self, action: #selector(addBtnClick), for: .touchUpInside);
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func addBtnClick() {
        
        self.otherClickFlag?(self.model as Any, 1001);
    }
    
    private var addBtn: UIButton = {
        
        let btn = UIButton.init(type: UIButton.ButtonType.custom);
        
        btn.setTitle(kPigramLocalizeString("同意", nil), for: .normal);
        btn.backgroundColor = UIColor.hex("#3ca6ff");
        btn.addRound(5);
        btn.isEnabled = false;
        
        return btn;
    }()
    
    var avatarView: AvatarImageView = {
          
          let view = AvatarImageView.init();
          
          return view;
          
      }();
      
      var nickLabel: UILabel = {
          
          let view = UILabel.init();
          view.font = UIFont.boldSystemFont(ofSize: 14);
          view.textColor = UIColor.hex("#273d52");
        view.numberOfLines = 2;
          return view;
          
      }()
    
    var subTitle: UILabel = {
        
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 12);
        label.textColor = UIColor.hex("#68727e");
        
        return label;
        
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
