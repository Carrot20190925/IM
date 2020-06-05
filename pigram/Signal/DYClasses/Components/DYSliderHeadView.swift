//
//  DYSliderHeadView.swift
//  华商领袖
//
//  Created by hansen on 2019/5/5.
//  Copyright © 2019 huashanglingxiu. All rights reserved.
//

import UIKit


@objc enum DYSliderHeaderType:Int {
    /// 固定title的宽度 根据内容宽度 决定是否可以滚动
    case normal
    /// 禁止滚动  平均分布
    case banScroll
    
}


@objcMembers class DYSliderModel {
    
    var title: String?
    var isSelect: Bool?
    var index: Int?
    var image: UIImage?
    
}
/**
 * 支持滑动的标题选择view
 */
enum DYButtonLayout {
    
    case imageBeLeft
    
    case imageBeTop
    
    case imageBeRight
    
    case imageLabelBeCenter
}

@objcMembers class DYSliderHeadView: UIView {

    private var dataSources: [DYSliderModel] = []
    var selectIndexBlock: ((_ index: Int) -> Void)?
    var btnLayout: DYButtonLayout = .imageBeLeft;
    var textColor: UIColor = UIColor.HWColorWithHexString(hex: "#333333");
    var selectColor = UIColor.blue;
    var currSelectIndex: Int = 0;
    var lineWidth:CGFloat = 30;
    var type: DYSliderHeaderType = .normal;
    var font: UIFont = UIFont.systemFont(ofSize: 14);
    var imageSize: CGSize?
    var images: [String]?
    var sliderPositionX: CGFloat = 0.0 {
        
        didSet {
            self.slider.frame = CGRect.init(x: self.sliderPositionX, y: self.slider.y, width: self.slider.width, height: self.slider.height)
        }
    
    }
    private let titles: [String]
    required init(titles: [String]) {
        self.titles = titles;
        super.init(frame: CGRect.zero)
        
    }
    func updateSelectIndexFromOther(_ index: Int) {
        if index == self.currSelectIndex {
            return;
        }
        
        if index > self.dataSources.count {
            return;
        }
//        self.collectionView.selectItem(at: IndexPath.init(item: index, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally);
        self.updateSlider(index: index);
        
    }
    override func layoutSubviews() {
        super.layoutSubviews();
        if self.subviews.count == 0 {
            self.setupSubview()
        }
    }
    private func setupSubview() {
        for item in self.titles {
            let index: Int = titles.firstIndex(of: item)!;
            let model = DYSliderModel.init();
            model.isSelect = index == self.currSelectIndex ? true : false;
            model.title = item;
            model.index = index;
            model.image = UIImage.init(named: item);
            if index < self.images?.count ?? 0 {
                let imgstr = self.images?[index];
                model.image = UIImage.init(named: imgstr ?? "");
            }
            var width = item.getTexWidth(font: UIFont.systemFont(ofSize: 14), height: 30) + 20;
            if width < 60 {
                width  = 60;
            }
            self.widthCache[index] = width;
            self.dataSources.append(model);
        }
        if self.type == .banScroll {
            for (index,_) in self.dataSources.enumerated() {
                let width = self.width / CGFloat(self.dataSources.count);
                self.widthCache[index] = width;
            }
        }
        self.addSubview(self.collectionView)
        self.collectionView.mas_makeConstraints { (make) in
            make?.edges.offset()(0);
        }
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.addSubview(self.slider)
        if self.dataSources.count > 0 {
            self.slider.isHidden = false;
            
            self.slider.frame = CGRect.init(x: (self.widthCache[self.currSelectIndex]! - lineWidth) * 0.5, y: self.height - 2, width: 30, height: 2);
        } else {
            self.slider.isHidden = true;
        }
        self.addSubview(self.lineView)
        self.lineView.mas_makeConstraints { (make) in
            make?.left.right().bottom()?.offset()(0);
            make?.height.offset()(1.0);
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
            self.updateSlider(index: self.currSelectIndex);
        });
     
    }
    func hideBottomLine() {
        self.lineView.isHidden = true;
    }
//   设置固有的size  在nnavigation push pop的时候回联通这个view带上动画
    override var intrinsicContentSize: CGSize {
        
        return self.bounds.size;
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var widthCache: [Int : CGFloat]  = [:];
    private lazy var slider: UIView = {
        let view = UIView()
        view.backgroundColor = self.selectColor;
        view.bounds = CGRect.init(x: 0, y: 0, width: self.lineWidth, height: 2);
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout.init();
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
    
        let view = UICollectionView.init(frame: CGRect.init(), collectionViewLayout: layout);
        view.backgroundColor = UIColor.white;
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell");
        view.showsHorizontalScrollIndicator = false;
        view.showsVerticalScrollIndicator = false;
        return view
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.alpha = 0.5;
        return view
    }()
    private func updateSlider(index: Int) {
        
        let beforeCell = self.collectionView.cellForItem(at: IndexPath.init(item: self.currSelectIndex, section: 0));
        if beforeCell != nil {
            let beforeView =  beforeCell?.contentView.subviews.first as! DYButton;
            if self.currSelectIndex < index {
                self.collectionView.scrollToItem(at: IndexPath.init(item: index, section: 0), at: UICollectionView.ScrollPosition.right, animated: true);
                
            } else {
                self.collectionView.scrollToItem(at: IndexPath.init(item: index, section: 0), at: UICollectionView.ScrollPosition.left, animated: true);
                
            }
            let cell = collectionView.cellForItem(at: IndexPath.init(item: index, section: 0));
            let label = cell?.contentView.subviews.first as! DYButton;
            let model = self.dataSources[index];
            label.text = model.title;
            self.currSelectIndex = index;
            //        var x: CGFloat = CGFloat(index * self.widthCache[index]) + 15;
            var x: CGFloat = (self.widthCache[index]! - self.lineWidth)  * 0.5;
        
            if index > 0 {
                for i in 0...index-1 {
                    let width = self.widthCache[i];
                    x += width!;
                }
            }
            
            UIView.animate(withDuration: 0.25) {
                self.updateLabelStatus(isSelect: false, label: beforeView);
                self.updateLabelStatus(isSelect: true, label: label);
                self.slider.frame.origin.x = x;
            };
        }
        
        
    }
    
    private func updateLabelStatus(isSelect:Bool, label: DYButton) {
        let fontSize = label.titleLabel?.font.pointSize;
        label.titleLabel?.font = UIFont.systemFont(ofSize: isSelect ? fontSize! + 2 : fontSize! - 2);
        label.textColor = isSelect ? self.selectColor : self.textColor;
    }

    
   

}

extension DYSliderHeadView: UICollectionViewDataSource, UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSources.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let btn: DYButton?
        if cell.contentView.subviews.count == 0 {
            var dict = [DYButtonLayout.imageBeLeft : 0,DYButtonLayout.imageBeTop : 1,DYButtonLayout.imageBeRight : 2,DYButtonLayout.imageLabelBeCenter : 3];
            btn = DYButton.init();
            btn?.direction = ContentDirection(dict[self.btnLayout]!);
            btn?.textColor = self.textColor;
            btn?.titleLabel?.font = UIFont.systemFont(ofSize: 14);
            cell.contentView.addSubview(btn!);
            btn?.mas_makeConstraints({ (make) in
                make?.edges.offset();
            })
            btn?.isUserInteractionEnabled = false;
            
        } else {
            btn = cell.contentView.subviews.first as? DYButton
        }
        let model = self.dataSources[indexPath.item];
        if model.isSelect == true && indexPath.item == self.currSelectIndex {
            btn?.titleLabel?.font = UIFont.systemFont(ofSize: 16);
        }
        btn?.titleLabel?.textColor = model.isSelect == true ? self.selectColor : UIColor.HWColorWithHexString(hex: "#333333");
        btn?.setTitle(self.dataSources[indexPath.item].title, for: .normal);
        if self.imageSize?.width ?? 0 > 0 && self.imageSize?.height ?? 0 > 0 {
            btn?.setImage(model.image?.resize(width: self.imageSize?.width ?? 0, height: self.imageSize?.height ?? 0), for: .normal);

        } else {
            btn?.setImage(model.image, for: .normal);

        }

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.updateSlider(index: indexPath.item);
        if self.selectIndexBlock != nil {
            self.selectIndexBlock!(indexPath.item);
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: self.widthCache[indexPath.item]!, height: collectionView.height);
    }
    
}
