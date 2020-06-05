//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

@objc public class ConversationMentionButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @objc
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.setTitle("@", for: .normal);
        self.addSubview(self.unradView);
        self.unradView.mas_makeConstraints { (make) in
            make?.centerY.equalTo()(self.mas_top);
            make?.centerX.offset();
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public func updateNumber(_ number: Int) {
        
        self.unradView.setUnreadNumber(number);
        
    }

    
    private lazy var unradView: DYUnreadView = {
        
        let view = DYUnreadView.init();
        
        view.setUnreadNumber(0);
        
        return view;
    }()
}
