//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit


public class PGGroupsSectionModel {
//    
    public var isUnfold: Bool = false;
    public var groupsName: String?
    public var groupsCount: Int? {
       return self.groupModels.count
    }
    public var groupsId: String?
    public var ids: [String]?
    public var groupModels: [TSGroupModel] = [];
    
    init(dict: [String : Any]) {
        self.groupsId = dict["bunchId"] as? String;
        if  let ids = dict["ids"] as? [[String : Any]] {
            self.ids = ids.map({ (value) -> String in
                return value["id"] as! String;
            });
        }
        self.groupsName = dict["title"] as? String;
//        self.groupsCount = self.ids?.count;
        if self.ids?.count ?? 0 > 0 {
            kSignalDB.read { (read) in
                
                for item in self.ids ?? [] {
                    
                    if let model = TSGroupThread.anyFetchGroupThread(uniqueId: "g\(item)", transaction: read),model.groupModel.txGroupType == TXGroupTypeJoined {
                        self.groupModels.append(model.groupModel);
                        
                    }
                }
            }
        }
    }
    
    func removeModel(groupModel : TSGroupModel)  {
        self.groupModels = self.groupModels.filter { (model) -> Bool in
            return model.groupId != groupModel.groupId
        }
        
        self.ids = self.ids?.filter({ (id) -> Bool in
            return id != groupModel.groupId
        })

    }
    
    
    
    
}

/**
 * 群组列表页面的 section header view
 */
class PGGroupsHeaderView: UITableViewHeaderFooterView {

    
    private var arrowImgView: UIImageView?
    public var textView: UILabel?;
    private var selectImgView: UIImageView?
    public var tapClickBlock: (() -> Void)?
    public var longTapClickBlock: ((PGGroupsHeaderView) -> Void)?
    public var model: PGGroupsSectionModel? {
        
        didSet {
            
            if let _model = self.model {
                self.textView?.text = "\(_model.groupsName ?? "") (\(_model.groupsCount ?? 0))";
            }
        }
    }
    
    func setArrowImage(nomal : Bool) {
        
        guard  let _model = self.model else {
            return
        }
        if nomal {
            self.arrowImgView?.image = UIImage.init(named: _model.isUnfold ? "ic_chevron_down" : "NavBarBackRTL")?.asTintedImage(color: UIColor.hex("#273d52"));

        }else
        {
            self.arrowImgView?.image = UIImage.init(named: _model.isUnfold ? "pg_selected" : "pg_selecte_normal")?.withRenderingMode(.alwaysOriginal);

        }
    }
    
    
    
    
    override init(reuseIdentifier: String?) {

        super.init(reuseIdentifier: reuseIdentifier);
        self.initSubView();
    }
    
    private func initSubView() {
        
        self.arrowImgView = UIImageView.init(image: UIImage.init(named: "NavBarBackRTL")?.asTintedImage(color: UIColor.hex("#273d52")));
//        self.selectImgView = UIImageView.init(image: UIImage.init(named: "check-circle-outline-28"));
        self.textView = UILabel.init();
        self.textView?.font = UIFont.boldSystemFont(ofSize: 18);
        self.textView?.textColor = UIColor.hex("#273d52");
        
        self.contentView.addSubview(self.arrowImgView!);
        self.contentView.addSubview(self.textView!);
//        self.contentView.addSubview(self.selectImgView!);
        
        self.arrowImgView?.mas_makeConstraints({ (make) in
            make?.centerY.offset();
            make?.left.offset()(8);
            
        })
//        self.selectImgView?.mas_makeConstraints({ (make) in
//            make?.right?.offset()(-8);
//            make?.centerY.offset();
//            make?.size.offset()(20);
//        })
        self.textView?.mas_makeConstraints({ (make) in
            make?.centerY.offset();
            make?.left.equalTo()(self.arrowImgView?.mas_right)?.offset()(8);
        })
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapClick));
        let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longTapClick(_ :)));
        self.contentView.addGestureRecognizer(tap);
        self.contentView.addGestureRecognizer(longTap);
    }
    
    
    @objc
    private func tapClick() {
        self.model?.isUnfold = !(self.model?.isUnfold ?? false);
        self.tapClickBlock?();
        
    }
    
    @objc
    private func longTapClick(_ gestrue: UILongPressGestureRecognizer) {
        
        switch gestrue.state {
        case .began:
        
            self.longTapClickBlock?(self);
            
        default:
            break;
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    

}
