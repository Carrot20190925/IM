//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit

class TXGeneralSetView: UIView {

    
    enum ActionType {
        case begin
        case end
    }
    var tagViews : [TXSetDrawView] = []
    var sliderBtn : UIView!
    var selectedView : UIView!
    var startPoint = CGPoint.init()
    var sliderStartX : CGFloat = 0.0
    var lineView : UIView!
    var action : ((_ type : ActionType) -> Void)?
    var setBackView:UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func setupUI(){
        let setBackView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.width(), height: self.height()))
        let smallA = UILabel.init()
        smallA.text = "A"
        smallA.sizeToFit()
        let bigA = UILabel.init()
        bigA.text = "A"
        bigA.sizeToFit()
        let lineView = UIView.init()
        lineView.backgroundColor = UIColor.lightGray
        let selectedView = UIView.init()
        selectedView.backgroundColor = UIColor.blue
        let btn = UIView.init()
        btn.backgroundColor = UIColor.green
        setBackView.addSubview(smallA)
        setBackView.addSubview(bigA)
        setBackView.addSubview(lineView)
        setBackView.addSubview(selectedView)
        let smallWidth = smallA.width()
        let bigWidht = bigA.width()

        let lineWidth = self.width() - 40 - smallWidth - bigWidht - 50;
        let space = lineWidth / 5.0
        let width : CGFloat = 15.0
        var x : CGFloat = 20 + smallWidth + 25 - width * 0.5
        let y : CGFloat = (80 - width) * 0.5
        for _ in 0...5 {
             let tagView = TXSetDrawView.init(frame: CGRect.init(x: x, y: y, width: width, height: width))
             tagView.backgroundColor = UIColor.clear
             setBackView.addSubview(tagView)
             x += space
             self.tagViews.append(tagView)
         }
        setBackView.addSubview(btn)
        self.addSubview(setBackView)
        let lineHeight:CGFloat = 3
        smallA.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(20)
            make?.centerY.mas_equalTo()(self.mas_centerY)
            make?.width.mas_equalTo()(smallWidth)
        }
        bigA.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(-20)
            make?.centerY.mas_equalTo()(self.mas_centerY)
            make?.width.mas_equalTo()(bigWidht)
        }
        lineView.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(smallA.mas_right)?.offset()(25)
            make?.right.mas_equalTo()(bigA.mas_left)?.offset()(-25)
            make?.centerY.mas_equalTo()(self.mas_centerY)
            make?.height.mas_equalTo()(lineHeight)
        }
        selectedView.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(smallA.mas_right)?.offset()(25)
            make?.centerY.mas_equalTo()(self.mas_centerY)
            make?.height.mas_equalTo()(lineHeight)
            make?.width.mas_equalTo()(0)
        }
        btn.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(lineView.mas_left)?.offset()(-20)
            make?.centerY.mas_equalTo()(self.mas_centerY)
            make?.size.mas_equalTo()(40)
        }
        self.sliderBtn = btn
        self.lineView = lineView
        self.selectedView = selectedView
        self.setBackView = setBackView
     
    }
    private func chatPreview(){
        let preview = UIView.init()
        
        let tagLabel = UILabel.init()
        tagLabel.text = "聊天预览"
        let timeLabel = UILabel.init()
        timeLabel.text = "14:30"
        let segmentView = UIView.init()
        segmentView.backgroundColor = UIColor.blue
        let firstLabel = UILabel.init()
        let secondLabel = UILabel.init()
//        let attributeText = NSMutableAttributedString.init(string: "", attributes: <#T##[NSAttributedString.Key : Any]?#>)
//        firstLabel.text
//        SSKEnvironment.shared.blockingManager
        preview.addSubview(tagLabel)
        preview.addSubview(timeLabel)
        preview.addSubview(firstLabel)
        preview.addSubview(secondLabel)
        
        
        
        
        
        
        
        
        
        self.addSubview(preview)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.setBackView) else {
            return
        }
        let frame = self.sliderBtn.frame
        if frame.contains(point) {
            self.startPoint = point
            self.sliderStartX = frame.origin.x
            self.action?(.begin)
        }
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self.setBackView) else {
           return
        }
        self.setupSliderBtnWithEndPoint(point: point)
      
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let point = touch?.location(in: self) else {
           return
        }
        self.setupSliderBtnWithEndPoint(point: point)
        self.action?(.end)

    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.action?(.end)
    }
    
    private func setupSliderBtnWithEndPoint(point : CGPoint){
        let dif = point.x - self.startPoint.x
        var endX = self.sliderStartX + dif
        let maxX = self.lineView.x + self.lineView.width() - self.sliderBtn.width() * 0.5
        if endX > maxX {
           endX = maxX
        }
        let minX = self.lineView.x - self.sliderBtn.width() * 0.5
        if endX < minX {
           endX = minX
        }
        var frame = self.selectedView.frame
        frame.size.width = endX - self.selectedView.x + self.sliderBtn.width() * 0.5
        self.selectedView.frame = frame
        self.sliderBtn.x = endX
        
        for tagView in self.tagViews {
            if tagView.x < endX {
                tagView.centerColor = UIColor.blue
                tagView.setNeedsDisplay()
            }else{
                tagView.centerColor = UIColor.lightGray
                tagView.setNeedsDisplay()
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
