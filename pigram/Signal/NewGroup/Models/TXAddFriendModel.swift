//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXAddFriendModel: NSObject {
    var item: OWSUserProfile!
    var selected = false
    init(item : OWSUserProfile) {
        self.item = item
    }
    
    
}
