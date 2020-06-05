//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXSetDrawView: UIView {

    var centerColor : UIColor = UIColor.lightGray
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = frame.size.width * 0.5
        self.clipsToBounds = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        // Drawing code
        UIColor.white.set()
        centerColor.setFill()
        let path = UIBezierPath.init(ovalIn: rect)
        path.lineWidth = 5.0
        path.fill(with: .destinationOver, alpha: 1.0)
        path.stroke()
        
    }
    

}
