//
//  ColorEX.swift
//
//  Created by abc on 2019/3/22.
//  Copyright © 2019 huashanglingxiu. All rights reserved.
//

import UIKit
import Kingfisher


let kScreenWidth = UIScreen.main.bounds.width;
let kScreenHeight = UIScreen.main.bounds.height;


public extension UIColor {
    
    
    class func HWColorWithHexString(hex:String,alpha:CGFloat) -> UIColor {
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            let index = cString.index(after: cString.startIndex)
            cString = String(cString[index...])
        }
        if cString.count != 6 {
            return UIColor.black
        }
        let rRange = cString.startIndex ..< cString.index(cString.startIndex, offsetBy: 2)
        let rString = cString.substring(with: rRange)
        let gRange = cString.index(cString.startIndex, offsetBy: 2) ..< cString.index(cString.startIndex, offsetBy: 4)
        let gString = cString.substring(with: gRange)
        let bRange = cString.index(cString.startIndex, offsetBy: 4) ..< cString.index(cString.startIndex, offsetBy: 6)
        let bString = cString.substring(with: bRange)
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
    class func HWColorWithHexString(hex:String) -> UIColor {
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            let index = cString.index(after: cString.startIndex)
            cString = cString.substring(from: index)
        }
        if cString.count != 6 {
            return UIColor.black
        }
        let rRange = cString.startIndex ..< cString.index(cString.startIndex, offsetBy: 2)
        let rString = cString.substring(with: rRange)
        let gRange = cString.index(cString.startIndex, offsetBy: 2) ..< cString.index(cString.startIndex, offsetBy: 4)
        let gString = cString.substring(with: gRange)
        let bRange = cString.index(cString.startIndex, offsetBy: 4) ..< cString.index(cString.startIndex, offsetBy: 6)
        let bString = cString.substring(with: bRange)
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
    }
    
    class func dy_randomColor() -> UIColor {
        return UIColor.init(red: CGFloat(Double(arc4random()).truncatingRemainder(dividingBy: 255) / 255.0), green: CGFloat(Double(arc4random()).truncatingRemainder(dividingBy: 255) / 255.0), blue: CGFloat(Double(arc4random()).truncatingRemainder(dividingBy: 255) / 255.0), alpha: 1.0)
    }
    
    
}

public extension UIAlertController {
    
    class func initAlertCustomVC(message: String, confirmTitle: String, confirmBlock: ((UIAlertAction) ->Void)?) -> UIAlertController {
        let vc = UIAlertController.init(title: "温馨提示", message: message, preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
        let confirm = UIAlertAction.init(title: confirmTitle, style: UIAlertAction.Style.default, handler: confirmBlock)
        vc.addAction(cancle)
        vc.addAction(confirm)
        return vc
    }
    class func showCustomAlertVC(message: String, confirmTitle: String, confirmBlock: ((UIAlertAction) ->Void)?) {
        let vc = UIAlertController.init(title: "温馨提示", message: message, preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
        let confirm = UIAlertAction.init(title: confirmTitle, style: UIAlertAction.Style.default, handler: confirmBlock)
        vc.addAction(cancle)
        vc.addAction(confirm)
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)

    }
    
    class func initAlertPromtVC(message: String, confirmTitle: String,confirmBlock: ((UIAlertAction) ->Void)?) {
        let vc = UIAlertController.init(title: "温馨提示", message: message, preferredStyle: UIAlertController.Style.alert)
        let confirm = UIAlertAction.init(title: confirmTitle, style: UIAlertAction.Style.cancel, handler: confirmBlock)
        vc.addAction(confirm)
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    
}


public extension String {
    
    
    func IsIdentityCard() -> Bool {
        if self.count == 0 {
            return false
            
        }
        
        let regex = "^(\\d{14}|\\d{17})(\\d|[xX])$"
        let regextestcm = NSPredicate(format: "SELF MATCHES %@",regex)
        return regextestcm.evaluate(with: self)
    }
    
    //MARK: 判断字符串中是否有中文
    func isIncludeChinese() -> Bool {
        for ch in self.unicodeScalars {
            if (0x4e00 < ch.value  && ch.value < 0x9fff) { return true } // 中文字符范围：0x4e00 ~ 0x9fff
        }
        return false
    }
    //MARK: 将中文字符串转换为拼音
    ///
    /// - Parameter hasBlank: 是否带空格（默认不带空格）
    func transformToPinyin(hasBlank: Bool = false) -> String {
        
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef,nil, kCFStringTransformToLatin, false) // 转换为带音标的拼音
        CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false) // 去掉音标
        let pinyin = stringRef as String
        return hasBlank ? pinyin : pinyin.replacingOccurrences(of: " ", with: "")
    }
    
    //MARK: 获取中文首字母
    ///
    /// - Parameter lowercased: 是否小写（默认大写）
    func transformToPinyinHead(lowercased: Bool = false) -> String {
        let removeSpace = self.replacingOccurrences(of: " ", with: "")
        let pinyin = removeSpace.transformToPinyin(hasBlank: true).capitalized // 字符串转换为首字母大写
        var headPinyinStr = ""
        for ch in pinyin {
            if ch <= "Z" && ch >= "A" {
                headPinyinStr.append(ch) // 获取所有大写字母
            }
        }
        if headPinyinStr.length == 0 {
            headPinyinStr = "#";
        }
        return lowercased ? headPinyinStr.lowercased()[0] : headPinyinStr[0];
    }
    
    
    func IsBankCard() -> Bool {
        if self.count == 0 {
            return false
        }
        let number = self
        var oddSum = 0
        var evenSum = 0
        var allSum = 0
        let cardNumberLength = number.lengthOfBytes(using: String.Encoding.utf8)
        let lastIndex = number.index(number.endIndex, offsetBy: -1)
        let lastNum = Int(number.substring(from: lastIndex))!
        let num = number.substring(to: lastIndex)
        
        for i in (1...cardNumberLength-1).reversed() {
            let start = num.index(num.startIndex, offsetBy: i-1)
            let end = num.index(num.startIndex, offsetBy: i)
            var tempNumber = Int(num.substring(with: start..<end))!
            if cardNumberLength % 2 == 1 {
                if (i % 2 == 0) {
                    tempNumber *= 2
                    if tempNumber >= 10 {
                        tempNumber -= 9
                    }
                    evenSum += tempNumber
                }else {
                    oddSum += tempNumber
                }
            }else {
                if (i % 2 == 1) {
                    tempNumber *= 2
                    if tempNumber >= 10 {
                        tempNumber -= 9
                    }
                    evenSum += tempNumber
                }else {
                    oddSum += tempNumber
                }
            }
        }
        
        allSum = oddSum + evenSum
        allSum += lastNum
        if allSum % 10 == 0 {
            return true
        }
      return false
    }
    
    func isTellephoneNumber()->Bool
    {
        let mobile = "^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$"
        let  CM = "^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$"
        let  CU = "^1(3[0-2]|5[256]|8[56])\\d{8}$"
        let  CT = "^1((33|53|8[09])[0-9]|349)\\d{7}$"
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        let regextestcm = NSPredicate(format: "SELF MATCHES %@",CM )
        let regextestcu = NSPredicate(format: "SELF MATCHES %@" ,CU)
        let regextestct = NSPredicate(format: "SELF MATCHES %@" ,CT)
        if ((regextestmobile.evaluate(with: self) == true)
            || (regextestcm.evaluate(with: self)  == true)
            || (regextestct.evaluate(with: self) == true)
            || (regextestcu.evaluate(with: self) == true))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func getTextHeigh(font:UIFont,width:CGFloat) -> CGFloat {
         let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        let normalText = self as NSString
        let size = CGSize.init(width: width,height: CGFloat(MAXFLOAT))
        
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context:nil).size
         return stringSize.height
    }
    
    func getTexWidth(font:UIFont,height:CGFloat) -> CGFloat {
        
        let normalText = self as NSString
        let size = CGSize.init(width: CGFloat(MAXFLOAT), height: height)
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context:nil).size
        return stringSize.width
    }
    
    
    static func recognizeBankNameBy(_ bankCard: String) -> String {
       
        let path = Bundle.main.path(forResource: "banks", ofType: "plist")
        let dict = NSDictionary.init(contentsOfFile: path!) as! [String : String]
        let result = dict[bankCard]  ?? "未知"
        
        return result
    }
    
    var length: Int {
        return self.count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)), upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}



public extension UIButton {
    
    

    
}

public extension UIView{
    enum ViewBorderSide {
        case top
        case right
        case bottom
        case left
    }

    // MARK: - 尺寸相关
    var x:CGFloat{
        get{
            return self.frame.origin.x
        } set{
            self.frame.origin.x = newValue
        }
    }
    
    var y:CGFloat{
        get{
            return self.frame.origin.y
        }set{
            self.frame.origin.y = newValue
        }
    }
    
    var width:CGFloat{
        get{
            return self.frame.size.width
        }set{
            self.frame.size.width = newValue
        }
    }
    
    var height:CGFloat{
        get{
            return self.frame.size.height
        }set{
            self.frame.size.height = newValue
        }
    }
    
    var size:CGSize{
        get{
            return self.frame.size
        }set{
            self.frame.size = newValue
        }
    }
    var centerX:CGFloat{
        get{
            return self.center.x
        }
        set{
            self.center.x = newValue
        }
    }
    var centerY:CGFloat{
        get{
            return self.center.y
        }
        set{
            self.center.y = newValue
        }
    }
    // MARK: - 尺寸裁剪相关
    /// 添加圆角  radius: 圆角半径
    func addRounded(radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    /// 添加部分圆角(有问题右边且不了) corners: 需要实现为圆角的角，可传入多个 radius: 圆角半径
    func addRounded(radius:CGFloat, corners: UIRectCorner) {
        let maskPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize.init(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer;
    }
    
    // MARK: - 添加边框
    /// 添加边框 width: 边框宽度 默认黑色
    func addBorder(width : CGFloat) { // 黑框
        self.layer.borderWidth = width;
        self.layer.borderColor = UIColor.black.cgColor;
    }
    /// 添加边框 width: 边框宽度 borderColor:边框颜色
    func addBorder(width : CGFloat, borderColor : UIColor) { // 颜色自己给
        self.layer.borderWidth = width;
        self.layer.borderColor = borderColor.cgColor;
    }
    func addBorder(side: ViewBorderSide, thickness: CGFloat, color: UIColor, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) {
        
        switch side {
        case .top:
            // Add leftOffset to our X to get start X position.
            // Add topOffset to Y to get start Y position
            // Subtract left offset from width to negate shifting from leftOffset.
            // Subtract rightoffset from width to set end X and Width.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: 0 + topOffset,
                                                                   width: self.frame.size.width - leftOffset - rightOffset,
                                                                   height: thickness), color: color)
            self.layer.addSublayer(border)
        case .right:
            // Subtract the rightOffset from our width + thickness to get our final x position.
            // Add topOffset to our y to get our start y position.
            // Subtract topOffset from our height, so our border doesn't extend past teh view.
            // Subtract bottomOffset from the height to get our end.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: self.frame.size.width-thickness-rightOffset,
                                                                   y: 0 + topOffset, width: thickness,
                                                                   height: self.frame.size.height - topOffset - bottomOffset), color: color)
            self.layer.addSublayer(border)
        case .bottom:
            // Subtract the bottomOffset from the height and the thickness to get our final y position.
            // Add a left offset to our x to get our x position.
            // Minus our rightOffset and negate the leftOffset from the width to get our endpoint for the border.
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: self.frame.size.height-thickness-bottomOffset,
                                                                   width: self.frame.size.width - leftOffset - rightOffset, height: thickness), color: color)
            self.layer.addSublayer(border)
        case .left:
            let border: CALayer = _getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                                                   y: 0 + topOffset,
                                                                   width: thickness,
                                                                   height: self.frame.size.height - topOffset - bottomOffset), color: color)
            self.layer.addSublayer(border)
        }
    }
    // 添加圆角和阴影
    func addRoundedOrShadow(radius:CGFloat)  {
        self.layer.cornerRadius = radius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1 // 不透明度
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
    }
    
    
    func onClick(_ target: Any,_ selector: Selector) {
        
        let tap = UITapGestureRecognizer.init(target: target, action: selector);
        self.isUserInteractionEnabled = true;
        self.addGestureRecognizer(tap);
    }
    
    func addTarget(_ target: Any, selector: Selector) {
        
        let gesture = UITapGestureRecognizer.init(target: target, action: selector);
        
        self.addGestureRecognizer(gesture);
    }
    
    
    fileprivate func _getOneSidedBorder(frame: CGRect, color: UIColor) -> CALayer {
          let border:CALayer = CALayer()
          border.frame = frame
          border.backgroundColor = color.cgColor
          return border
      }
    
}

@objc
extension UIImage {
    
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    static func from(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    func resize(width:CGFloat, height:CGFloat) -> UIImage? {
        if width == 0 || height == 0{
            return nil;
        }
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: width, height: height), false, 0.0)
        let myImageRect = CGRect.init(x: 0, y: 0, width: width, height: height);
        self.draw(in: myImageRect);
        let image = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return image;
    }
    
    /**
     * 识别图中的二维码
     */
    @objc
    public func detectorImage(_ finished: ([CIQRCodeFeature]?,Error?) -> Void) {
        
        // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
        // 声明一个 CIDetector，并设定识别类型 CIDetectorTypeText
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh]);
        
        if self.ciImage == nil {
            
            let error = NSError.init(domain: "不支持的图片格式", code: -1001, userInfo: nil);
            
            finished(nil, error);
            return;
        }
        //获取识别结果
        let ciImg = CIImage.init(cgImage: self.cgImage!);
        let results = detector?.features(in: ciImg);
        if results?.count == 0 {
            let error = NSError.init(domain: "未能识别图中二维码", code: -1001, userInfo: nil);
            
            finished(nil, error);
            return;
        }
        
        guard let _results = results as? [CIQRCodeFeature] else {
            let error = NSError.init(domain: "未能识别图中二维码", code: -1001, userInfo: nil);
            
            finished(nil, error);
            return;
        }
        
        finished(_results,nil);
    }
}


extension UIImageView{
    
    func setKingFisherImage(urlStr: String, placeholder: UIImage) {
        
        self.kf.setImage(with: URL.init(string: urlStr), placeholder: placeholder, options: nil, progressBlock: nil) { (_) in
            
        }
    }
    
    func setCornerImage(){
        //异步绘制图像
//        DispatchQueue.global().async(execute: {
            //1.建立上下文
        
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
            
            //获取当前上下文
            let ctx = UIGraphicsGetCurrentContext()
            
            //设置填充颜色
            UIColor.white.setFill()
            UIRectFill(self.bounds)
            
            //2.添加圆及裁切
            ctx?.addEllipse(in: self.bounds)
            //裁切
            ctx?.clip()
            
            //3.绘制图像
            self.draw(self.bounds)
            
            //4.获取绘制的图像
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            //5关闭上下文
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async(execute: {
                self.image = image
            })
//        })
    }
    
    func setCornerImage(_ cornerRadius: CGFloat){
        //异步绘制图像
        //        DispatchQueue.global().async(execute: {
       UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
                   
        
        //获取当前上下文
        let ctx = UIGraphicsGetCurrentContext()
        
        //设置填充颜色
        UIColor.white.setFill()
        UIRectFill(self.bounds)
        
        //2.添加圆及裁切
        ctx?.addEllipse(in: self.bounds)
        //裁切
        ctx?.clip()
        
        //3.绘制图像
        self.draw(self.bounds)
        
        //4.获取绘制的图像
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //5关闭上下文
        UIGraphicsEndImageContext()
        
        DispatchQueue.main.async(execute: {
            self.image = image
        })
        //        })
    }
    
}

extension Date {
    
    //MARK: -根据后台时间戳返回几分钟前，几小时前，几天前
    static func updateTimeToCurrennTime(timeStamp: Double) -> String {
        //获取当前的时间戳
        let currentTime = Date().timeIntervalSince1970
        print(currentTime,   timeStamp, "sdsss")
        //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
        let timeSta:TimeInterval = TimeInterval(timeStamp / 1000)
        //时间差
        let reduceTime : TimeInterval = currentTime - timeSta
        //时间差小于60秒
        if reduceTime < 60 {
            return "刚刚"
        }
        //时间差大于一分钟小于60分钟内
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins)分钟前"
        }
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours)小时前"
        }
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days)天前"
        }
        if days > 30 {
            return "\(days / 30)月前"
        }
        //不满足上述条件---或者是未来日期-----直接返回日期
        let date = NSDate(timeIntervalSince1970: timeSta)
        let dfmatter = DateFormatter()
        //yyyy-MM-dd HH:mm:ss
        dfmatter.dateFormat="yyyy年MM月dd日 HH:mm:ss"
        return dfmatter.string(from: date as Date)
    }
    
    static func getFormdateYMDHM(timeStamp: Double) -> String {
        let timeSta:TimeInterval = TimeInterval(timeStamp / 1000)

        let date = NSDate(timeIntervalSince1970: timeSta)
        let dfmatter = DateFormatter()
        dfmatter.locale = .current;
        //yyyy-MM-dd HH:mm:ss
        dfmatter.dateFormat="yyyy-MM-dd HH:mm"
        return dfmatter.string(from: date as Date)
    }
    
    static func dateFormatterStrToTimeStamp(_ dateStr: String, format: String) -> TimeInterval{
        if dateStr.count == 0 {
            return 0;
        }
        let dateFormat = DateFormatter.init();
        dateFormat.dateFormat = format;//"yyyy-MM-dd HH:mm";
        dateFormat.timeZone = .autoupdatingCurrent;
        dateFormat.locale = .current;
        let date = dateFormat.date(from: dateStr);

        return date!.timeIntervalSince1970 * 1000;
        
    }
}


extension UIMenuController {
    
    
    static func showMenu(_ titles: [String], _ selectors: [Selector]) -> UIMenuController {
        
        let contrl = UIMenuController.init();
        
        for (index,item) in titles.enumerated() {
            let selector = selectors[index];
            let menu = UIMenuItem.init(title: item, action: selector);
            contrl.menuItems?.append(menu);
        }
        return contrl;
    }
    
}

extension Array {
    
    //MARK: 数组内中文按拼音字母排序
    ///
    /// - Parameter ascending: 是否升序（默认升序）
    func sortedByPinyin(ascending: Bool = true) -> Array<String>? {
        if self is Array<String> {
            return (self as! Array<String>).sorted { (value1, value2) -> Bool in
                let pinyin1 = value1.transformToPinyin()
                let pinyin2 = value2.transformToPinyin()
                return pinyin1.compare(pinyin2) == (ascending ? .orderedAscending : .orderedDescending)
            }
        }
        return nil
    }
    
}
extension Character
{
    func toInt() -> Int
    {
        var intFromCharacter:Int = 0
        for scalar in String(self).unicodeScalars
        {
            intFromCharacter += Int(scalar.value)
        }
        return intFromCharacter
    }
}

extension UINavigationController {
    @objc
    public func setSecondSubVC(_ vc: UIViewController) {
        
        if self.viewControllers.count > 0 {
            self.setViewControllers([self.viewControllers[0], vc], animated: true);
        }
    }
    
}


extension Dictionary {
    
    
    
}


