//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

@objc
public class PigramMessageShareView: UIView {
    @objc
    public static let cellReuseIdentifier = "PigramMessageShareCell"

    @objc let viewModel:PGMessageShare
    @objc let style: ConversationStyle
    
    @objc
    public init(viewModel: PGMessageShare,conversationStyle: ConversationStyle) {
        self.viewModel = viewModel;
        self.style = conversationStyle;
        super.init(frame: .zero);
        self.setupSubView();
        self.update();
        
    }
    

    
    private func setupSubView() {
        
        self.layoutMargins = .zero;
        
        let view = UIView.init();
        view.backgroundColor = UIColor.hex("#ecf0f5");
        view.addRound(5);
        let lineView = UIView.init();
        lineView.backgroundColor = UIColor.hex("#dfe2e7");
        
        self.addSubview(view);
        view.addSubview(self.avatar);
        view.addSubview(self.nameLabel);
        view.addSubview(lineView);
        view.addSubview(self.typeLabel);
    
        view.mas_makeConstraints { (make) in
            make?.edges.offset();
        }
        self.avatar.mas_makeConstraints { (make) in
            make?.left.top()?.offset()(10);
            make?.size.offset()(36);
        }
        self.nameLabel.mas_makeConstraints { (make) in
            make?.centerY.equalTo()(self.avatar);
            make?.left.equalTo()(self.avatar.mas_right)?.offset()(10);
            make?.right.offset()(-8);
        }
        
        lineView.mas_makeConstraints { (make) in
            make?.left.right()?.offset();
            make?.height.offset()(1.0);
            make?.top.offset()(56);
            
        }
        self.typeLabel.mas_makeConstraints { (make) in
            make?.left.offset()(10);
            make?.bottom.offset()(-10);
        }
        
    }
    
    private func update() {
        guard let _id = self.viewModel.shareID else {
            
            owsFailDebug("🍃🍃🍃🍃🍃🍃------------名片缺少id");
            return;
        }
        var user: OWSUserProfile?
        let address = SignalServiceAddress.init(phoneNumber: self.viewModel.shareID);
        OWSUserProfile.databaseStorage.read { (read) in
            user = OWSUserProfile.getFor(address, transaction: read);
        }
        if user == nil {
            kSignalDB.write { (write) in
                user = OWSUserProfile.getOrBuild(for: address, transaction: write);
                user?.update(withProfileName: self.viewModel.shareName, avatarUrlPath: self.viewModel.shareAvatar, avatarFileName: nil, transaction: write, completion: nil);
            }
            self.avatar.image = user?.getContactAvatarImage();
        }
        if address.type == .group {
            self.nameLabel.text = self.viewModel.shareName;
        } else {
            self.nameLabel.text = user?.getContactName();
        }
        self.avatar.image = user?.getContactAvatarImage();
        if self.viewModel.shareType() == .group {
            self.typeLabel.text = kPigramLocalizeString("群名片", nil);
        } else if self.viewModel.shareType() == .personal {
            self.typeLabel.text = kPigramLocalizeString("个人名片", nil);
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var avatar:AvatarImageView = {
        
        let view = AvatarImageView.init();
        
        
        return view;
        
    }();
    
    private lazy var nameLabel: UILabel = {
        
        let view = UILabel.init();
        view.font = UIFont.boldSystemFont(ofSize: 15);
        view.textColor = UIColor.hex("#637383");
        view.numberOfLines = 2;
        return view;
        
    }()
    
    private lazy var typeLabel: UILabel = {
        
        let view = UILabel.init();
        view.font = UIFont.systemFont(ofSize: 12);
        view.textColor = UIColor.hex("#637383");
        return view;
        
    }()
}
