//
//  DYUnreadView.swift
//  华商领袖
//
//  Created by hansen on 2019/5/14.
//  Copyright © 2019 huashanglingxiu. All rights reserved.
//

import UIKit

@objcMembers public class DYUnreadView: UIView {

    let kUnReadView_Margin_TB:CGFloat = 2.0;
    let kUnReadView_Margin_LB:CGFloat = 4.0;
    
    var bgColor = UIColor.red;
    var textColor = UIColor.white;
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.setupSubviews();
        self.distributionSubviews();
        
    }
    private var _bounds: CGRect?
    override public var bounds: CGRect {
        
        didSet {
            let width = self.bounds.size.width;
            let height = self.bounds.size.height;
            if width == 0 && height == 0 {
                //被系统tabbar改变bounds
                bounds = _bounds!;
            }
        }
       
    }
    func setUnreadNumber(_ number: Int) {
        self.isHidden = number == 0 ? true : false;
        var content = String(number);
//        if number > 99 {
//            content = "99+";
//        }
        if number > 999 {
            content = "\(number)"
//            content = String.init(format: "%.1lfk", (Double(number) / 1000.0))
//            content = "\(Double(number) / 1000.0)k"
        }
        
        self.label.text = content;
        self.distributionSubviews();
        
    }
    static func showWindowPosition(_ position: CGRect) {
        
        let view = DYUnreadView.init(frame: position);
        let window = UIApplication.shared.keyWindow;
        window?.addSubview(view);
        
    }
    
    private func setupSubviews() {
        self.backgroundColor = self.bgColor;
        self.addSubview(self.label);
        self.layer.cornerRadius = (self.label.height + CGFloat(2 * kUnReadView_Margin_TB)) * 0.5;
        self.layer.masksToBounds = true;
        self.isHidden = true;
    }
    private func distributionSubviews() {
        self.backgroundColor = self.bgColor;
        self.label.textColor = self.textColor;
        self.label.sizeToFit();
        var width = self.label.width + 2 * kUnReadView_Margin_LB;
        let height = self.label.height + 2 * kUnReadView_Margin_TB;
        if width < height {
            width = height;
        }
        self.bounds = CGRect.init(x: 0, y: 0, width: width, height: height);
        _bounds = self.bounds;
        self.label.frame = self.bounds;
        
    }
  
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center;
        label.textColor = self.textColor;
        label.font = UIFont.systemFont(ofSize: 12);
        label.text = "0";
        label.sizeToFit();
        return label;
        
    }()

   
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
