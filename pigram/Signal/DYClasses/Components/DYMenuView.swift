//
//  DYMenuView.swift
//  Project
//
//  Created by fangyuan on 2019/8/13.
//  Copyright © 2019 CDJay. All rights reserved.
//

import UIKit

protocol DYMenuProtocol {
    
}

@objcMembers class DYMenuView: UIView {
    
    var selectedCallback: ((_ index: Int) -> Void)?
    
    private var targetView: UIView?
    var defaultSelected: Int = 0;
    
    var titles: [String]
    lazy var contentView: UIView = {
        
        let view = UIView.init(frame: CGRect.zero);
        
        view.backgroundColor = UIColor.white;
        
        return view;
        
    }();
    
    required init(_ titles: [String]) {
        self.titles = titles;
        super.init(frame: CGRect.zero);
    }
    override func layoutSubviews() {
        super.layoutSubviews();
        if self.subviews.count == 0 {
            self.setupSubview();
        }
    }
    func setupContentView () {
        
        
    }
   
    static func onShow(targetView: UIView, titles: [String], finished: @escaping (_ index: Int) -> Void) ->DYMenuView {
        
        let view = self.init(titles);
        view.targetView = targetView;
        view.selectedCallback = finished;
        UIApplication.shared.keyWindow?.addSubview(view);
        view.mas_makeConstraints { (make) in
            make?.edges.offset()(0);
        };
        return view;
    }
    
    private func setupSubview() {
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(dismiss));
        self.addGestureRecognizer(tapGesture);
        
        self.backgroundColor = UIColor.HWColorWithHexString(hex: "000000", alpha: 0.3);
        guard let rect = self.targetView?.frame else {
            return;
        }
        
        let point = self.targetView?.convert(rect.origin, to: UIApplication.shared.keyWindow);
        
        self.addSubview(self.contentView);
        self.contentView.frame = CGRect.init(x: 0, y: point!.y + rect.height, width: self.width, height: 80);
        self.setupContentView();
    }
    
    
    @objc func dismiss() {
        
        self.removeFromSuperview();
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

@objcMembers class DYMenuLabelView: DYMenuView {
    
    lazy private var scrollView: UIScrollView = {
        
        let view = UIScrollView.init();
        view.backgroundColor = UIColor.white;
        return view;
    }()
    
    override func setupContentView() {
        
        self.contentView.addSubview(self.scrollView);
        
        self.scrollView.mas_makeConstraints { (make) in
            make?.edges.offset()(0);
        }
        
        var maxY = self.contentView.height;
        for (index, item) in self.titles.enumerated() {
            
            let btn = UIButton.init(type: .custom);
            btn.tag = index;
            btn.setTitle(item, for: .normal);
            btn.backgroundColor = index == defaultSelected ? UIColor.HWColorWithHexString(hex: "e41c27") : UIColor.gray;
            let width: CGFloat  = 88.0;
            let height: CGFloat = 24;
            let row :CGFloat = 3;
            let margin = (self.contentView.width - (width * row)) / 4;
            let line = index / Int(row);
            let y: CGFloat = 10.0 + (CGFloat(line) * height) + (CGFloat(line) * 10);
            let x = width * CGFloat(index % 3) + (margin * CGFloat(index % 3)) + margin;
            btn.frame = CGRect.init(x: x, y: y, width: width, height: height);
            btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside);
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12);
            btn.addRounded(radius: row);
            maxY = btn.frame.maxY + 10;
            self.scrollView.addSubview(btn);
        }
        self.scrollView.contentSize = CGSize.init(width: self.contentView.width, height: maxY);
      
    }
    @objc private func btnClick(_ sender: UIButton) {
        
        if self.selectedCallback != nil {
            self.selectedCallback!(sender.tag);
            self.dismiss();
        }
    }
    
}
