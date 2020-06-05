//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class ContactsCell: DYTableViewCell {
    
    var longTapAction : ((_ cell :ContactsCell) -> Void)?
    
    override var model: AnyObject? {
            
        didSet {
            
            if let model = self.model as? OWSUserProfile {
                
                self.nickLabel.text = model.getDisplayName();
                let image = model.getContactAvatarImage();
                self.avatarView.image = image;
//                self.avatarView.setCornerImage(52);
            } else if let model = self.model as? TSGroupModel {
                
                self.nickLabel.text = "\(model.groupName ?? "") (\(model.membersCount))";
                self.updateGroupAvatar(model: model);
            }
            
            
        }
        
    }
    
    private func updateGroupAvatar(model: TSGroupModel) {
        
        let thread = TSGroupThread.init(groupModel: model);
        self.avatarView.image = OWSAvatarBuilder.buildImage(thread: thread, diameter: 52);
        
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.white
        self.contentView.addSubview(self.avatarView);
        self.contentView.addSubview(self.nickLabel);
    
        self.avatarView.mas_makeConstraints { (make) in
            make?.centerY.offset();
            make?.size.offset()(52);
            make?.left.offset()(20);
        }
        self.nickLabel.mas_makeConstraints { (make) in
            make?.centerY.offset();
            make?.left.equalTo()(self.avatarView.mas_right)?.offset()(8);
            make?.right.offset()(-8);

        }
        self.avatarView.addRound(26);
        let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longTapClick(_ :)));

        self.contentView.addGestureRecognizer(longTap)
    }
    
    @objc func longTapClick(_ sender : UILongPressGestureRecognizer){
        if sender.state == .began {
            self.longTapAction?(self)
        }
    }
    
    public func showNewFriendView() {
        self.accessoryView = self.unreadView;
        
        let unreadCount = PigramVerifyManager.shared.getAllVerifications()?.count ?? 0;
        
        self.unreadView.setUnreadNumber(unreadCount);
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
    
    private var unreadView: DYUnreadView = {
        
        let view = DYUnreadView.init();
        view.setUnreadNumber(0);
        return view;
        
    }()
    

}

