//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class ContactListCell: DYTableViewCell {

    
    var isShowSelectBtn: Bool = true {
        
        didSet {
            
            self.selectBtn.mas_updateConstraints { (make) in
                make?.centerY.offset();
                if self.isShowSelectBtn {
                    make?.left.offset()(14)
                } else {
                    make?.left.offset()(-28);
                }
                make?.size.offset()(14);
            }
            
        }
        
    }
    
    override var model: AnyObject? {
        
        didSet {
            
            if let model = self.model as? ContactListModel {
                
                self.nickLabel.text = model.user.getDisplayName();
                var image = model.user.getContactAvatarImage();
                image = image?.resizedImage(to: CGSize.init(width: 52, height: 52));
                self.avatarView.image = image;
                self.selectBtn.isSelected = model.isSelected;
//                self.accessoryType = model.isSelected ? .checkmark : .none;
                //                self.avatarView.setCornerImage(52);
            } else if let model = self.model as? GroupListModel {
                
                self.selectBtn.isSelected = model.isSelected;
                self.nickLabel.text = "\(model.group.groupName ?? "") (\(model.group.membersCount))";
                self.updateGroupAvatar(model: model.group);
                //                self.accessoryType = model.isSelected ? .checkmark : .none;
                //                self.avatarView.setCornerImage(52);
            } else if let model = self.model as? PigramGroupMemberModel{
                self.selectBtn.isSelected = model.isSelected
                self.nickLabel.text = model.member.getRemarkNameInfo()
                model.member.getContactAvatarImage(self.avatarView);
//                image = image?.resizedImage(to: CGSize.init(width: 52, height: 52));
//                self.avatarView.image = image;
            } else if let model = self.model as? PigramGroupMember {
                self.isShowSelectBtn = false;
                self.avatarView.mas_remakeConstraints { (make) in
                    make?.centerY.offset();
                    make?.size.offset()(30);
                    make?.left.equalTo()(self.selectBtn.mas_right)?.offset()(20);
                }
                self.nickLabel.text = model.getRemarkNameInfo();
                model.getContactAvatarImage(self.avatarView);
                
//                let imageBuilder = OWSContactAvatarBuilder.init(address: SignalServiceAddress.init(phoneNumber: model.userId), colorName: .pigramThemeColor, diameter: 30);
//                let image = imageBuilder.build()?.resizedImage(to: CGSize.init(width: 30, height: 30));
//                self.avatarView.image = image;
                
            }
            
        }
        
    }
    
    public func makesButtonSelect(_ isSelect:Bool) {
        self.selectBtn.isSelected = isSelect;
    }
    private func updateGroupAvatar(model: TSGroupModel) {
        
        let thread = TSGroupThread.init(groupModel: model);
        self.avatarView.image = OWSAvatarBuilder.buildImage(thread: thread, diameter: 52);
        
        
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.selectBtn);
        self.contentView.addSubview(self.avatarView);
        self.contentView.addSubview(self.nickLabel);
        self.selectBtn.mas_makeConstraints { (make) in
            make?.centerY.offset();
            make?.left.offset()(14);
            make?.size.offset()(14);
        }
        self.avatarView.mas_makeConstraints { (make) in
            make?.centerY.offset();
            make?.size.offset()(52);
            make?.left.equalTo()(self.selectBtn.mas_right)?.offset()(20);
        }
        self.nickLabel.mas_makeConstraints { (make) in
            make?.centerY.offset();
            make?.left.equalTo()(self.avatarView.mas_right)?.offset()(8);
            make?.right.offset()(-8);

        }
        self.avatarView.addRound(26);
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var avatarView: AvatarImageView = {
        
        let view = AvatarImageView.init();
        
        return view;
        
    }();
    
    var nickLabel: UILabel = {
        
        let view = UILabel.init();
        view.font = UIFont.boldSystemFont(ofSize: 18);
        view.textColor = UIColor.hex("#273d52");
        view.numberOfLines = 2;

        return view;
        
    }()
    
    
    private var selectBtn: UIButton = {
        
        let btn = UIButton.init(type: .custom);
        
        btn.isUserInteractionEnabled = false;
        btn.setImage(UIImage.init(named: "pigram-group-unselect"), for: .normal);
        btn.setImage(UIImage.init(named: "pigram-group-selected"), for: .selected);

        return btn;
    }()
        
}


