//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXMoreCell: UITableViewCell {

    @IBOutlet weak var subTitleBtn: TXLeftTitleButton!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.font = TXTheme.secondTitleFont()
        self.titleLabel.textColor = TXTheme.titleColor()
        self.subTitleBtn.setTitleColor(TXTheme.titleColor(), for: .normal)
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.subTitleBtn.tapSwitch = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
