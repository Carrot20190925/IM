//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXLeftTitleButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let switchView = UISwitch.init()
    var tapSwitch :((_ on: Bool) -> Void)?
    
    override func awakeFromNib() {
        switchView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        switchView.addTarget(self, action: #selector(tapSwitchAction), for: .valueChanged)
    }
    
    @objc
    private func tapSwitchAction(){
        self.tapSwitch?(switchView.isOn)
    }
    
    func addSwitchAction() {
        self.isUserInteractionEnabled = true
        self.addSubview(switchView)
    }
    func removeSwitchAction() {
        self.isUserInteractionEnabled = false
        self.switchView.removeFromSuperview()
        self.tapSwitch = nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /** 修改 title 的 frame */
        // 1.获取 titleLabel 的 frame
        var titleLabelFrame = self.titleLabel?.frame;
        // 2.修改 titleLabel 的 frame
        titleLabelFrame?.origin.x = 0;
        // 3.重新赋值
        self.titleLabel?.frame = titleLabelFrame ?? CGRect.zero;
        
        /** 修改 imageView 的 frame */
        // 1.获取 imageView 的 frame
        var imageViewFrame = self.imageView?.frame;
        // 2.修改 imageView 的 frame
        imageViewFrame?.origin.x = titleLabelFrame?.size.width ?? 0.0;
        // 3.重新赋值
        self.imageView?.frame = imageViewFrame ?? CGRect.zero;
    }
}
