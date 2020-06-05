//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
@objc
protocol TXGroupInfoHeadViewDelegate{
    func numberItems() -> Int
    func inviteItemHide() -> Bool
    @objc optional func  memberItem(index : Int) -> PigramGroupMember?
    @objc optional func  profileItem(index : Int) -> OWSUserProfile?
    
}
//extension TXGroupInfoHeadViewDelegate {
//
//    func  memberItem(index : Int) -> PigramGroupMember? {
//
//        return nil;
//    }
//    func  profileItem(index : Int) -> OWSUserProfile? {
//        return nil;
//    }
//
//}
@objc
class TXGroupInfoHeadView: UIView {
    enum InfoType {
        case group
        case person
    }
    weak var delegate : TXGroupInfoHeadViewDelegate?
    var imageViews:[UIImageView] = []
    var nameLabels:[UILabel] = []
    var numButton : TXLeftTitleButton!
    var inviteFriend : ((_:Int)->Void)?
    var showMemers : (()->Void)?
    var type : InfoType = .group

    func setupUI() {
        self.backgroundColor = UIColor.white
        let segView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.width(), height: 10))
        segView.backgroundColor = TXTheme.thirdColor()
        self.addSubview(segView)
        var x:CGFloat = 20
        var y:CGFloat = 25
        let tagLabel = UILabel.init()
        tagLabel.text = "群聊成员"
        tagLabel.sizeToFit()
        var width = tagLabel.width()
        var height = tagLabel.height()
        tagLabel.frame = CGRect.init(x: x, y: y, width: width, height: height)
        self.addSubview(tagLabel)
        let numButton = TXLeftTitleButton.init()
        numButton.setImage(UIImage.init(named: "more_next"), for: .normal)
        numButton.setTitleColor(TXTheme.titleColor(), for: .normal)
        numButton.setTitle("查看群资料  ", for: .normal)
        numButton.addTarget(self, action: #selector(showMembersAction), for: .touchUpInside)
        self.numButton = numButton
        self.addSubview(numButton)
        numButton.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(-20)
            make?.bottom.mas_equalTo()(tagLabel.mas_bottom)
        }
        
        y += (height + 10)
        width = 40
        height = width
        let spaceW = (self.width() - (5 * width) - (2 * x))/4.0
        for index in 0...5 {
            let imageView = UIImageView.init(frame: CGRect.init(x: x, y: y, width: width, height:height ))
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapInviteFriend(tap:)))
            imageView.addGestureRecognizer(tap)
            imageView.backgroundColor = UIColor.lightGray
            imageView.layer.cornerRadius = width * 0.5
            imageView.clipsToBounds = true
            imageView.tag = index
            let label = UILabel.init(frame: CGRect.init(x: x - 10, y: y + height + 10, width: width + 20, height: 20))
            label.text = "邀请"
            label.textColor = TXTheme.titleColor()
            label.textAlignment = NSTextAlignment.center
            label.font = TXTheme.thirdTitleFont(size: 10)
            self.addSubview(imageView)
            self.addSubview(label)
            imageViews.append(imageView)
            nameLabels.append(label)
            x += (width + spaceW)
        }
        
        var frame = self.frame
        frame.size.height = y + height + 40
        self.frame = frame
    }
    
    
    func setupPersonInfo() {
            self.type = .person
           self.backgroundColor = UIColor.white
           let segView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.width(), height: 10))
           segView.backgroundColor = TXTheme.thirdColor()
           self.addSubview(segView)
           var x:CGFloat = 20
           let y:CGFloat = 25
          
           
           let width : CGFloat = 40
           let height: CGFloat = width
           let spaceW = (self.width() - (5 * width) - (2 * x))/4.0
           for index in 0...5 {
               let imageView = UIImageView.init(frame: CGRect.init(x: x, y: y, width: width, height:height ))
               let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapInviteFriend))
               imageView.addGestureRecognizer(tap)
               imageView.backgroundColor = UIColor.lightGray
               imageView.layer.cornerRadius = width * 0.5
               imageView.clipsToBounds = true
            
               imageView.tag = index
               let label = UILabel.init(frame: CGRect.init(x: x, y: y + height + 10, width: width, height: 20))
               label.text = "邀请"
               label.textAlignment = NSTextAlignment.center
               label.textColor = TXTheme.titleColor()
               label.font = TXTheme.thirdTitleFont(size: 10)
               self.addSubview(imageView)
               self.addSubview(label)
               imageViews.append(imageView)
               nameLabels.append(label)
               x += (width + spaceW)
           }
           
           var frame = self.frame
           frame.size.height = y + height + 40
           self.frame = frame
    }
    
    
    
    
    @objc
    func showMembersAction() {
        self.showMemers?()
    }
    @objc
    func tapInviteFriend(tap:UITapGestureRecognizer) {
        guard let view = tap.view else {
            return
        }
        self.inviteFriend?(view.tag)
        
    }
    
    func reloadData() {
        
        guard var count = delegate?.numberItems()  else {
            return
        }
        if self.type == .group {
            self.numButton.setTitle("查看\(count)名群资料  ", for: .normal)
        }
        if count >= 4 {
            count = 4
        }
        for index in 0...5 {
            let imageview = self.imageViews[index]
            let label = self.nameLabels[index]
            imageview.isUserInteractionEnabled = true
            label.isHidden = false
            imageview.isHidden = false
            if index < count {//
                if let member  = delegate?.memberItem?(index: index){
                    member.getContactAvatarImage(imageview)
                    label.text = member.getRemarkNameInfo()
                }
                if let profile = delegate?.profileItem?(index: index){
                    let image = profile.getContactAvatarImage()
                    imageview.image = image
                    label.text = profile.profileName
                }

            }else
            {
                if index == count {
                    
                    if let hide = delegate?.inviteItemHide(),hide == true{//普通成员
                        if let count = delegate?.numberItems(), count < 5 {//群成员小于5人直接隐藏邀请
                            label.isHidden = hide
                            imageview.isHidden = hide
                        }else{//群成员大于5人之，显示第五人
                            label.isHidden = false
                            imageview.isHidden = false
                            if let member  = delegate?.memberItem?(index: index){
                                member.getContactAvatarImage(imageview)
                                label.text = member.getRemarkNameInfo()
                            }
                        }
                    }else{
                        label.isHidden = false
                        imageview.isHidden = false
                        label.text = "邀请"
                        imageview.isUserInteractionEnabled = true
                        imageview.image = UIImage.init(named: "pg_invite_friend")
                    }
                    
                }else
                {
                    imageview.isUserInteractionEnabled = false
                    imageview.isHidden = true
                    label.isHidden = true
                }
            }
        }
    }

}
