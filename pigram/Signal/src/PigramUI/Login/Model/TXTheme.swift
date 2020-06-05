//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

import UIKit
import Photos
public extension String {
    func isPassword() -> Bool{
//        let reg = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,20}$"
        let reg = "^(?=.*?[0-9])(?=.*?[a-zA-Z]).{8,20}$"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        return pre.evaluate(with: self)
    }
    
    func isPGAccount() -> Bool {
        let reg = "^[a-zA-Z0-9_]{5,}$"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        return pre.evaluate(with: self)
    }
}
//class PigramTXConfig: NSObject {
//    public static let PigramQRTypePerson = "0"
//    public static let PigramQRTypeGroup = "1"
//    public static let PigramQRTypeDevice = "2"
//
//}

class TXTheme: NSObject {
    @objc
    class func font(name:String,size:CGFloat) -> UIFont {
        let ensureSize = UIScreen.main.bounds.size.width / 375.0 * size
        return UIFont.init(name: name, size: ensureSize) ?? UIFont.systemFont(ofSize: ensureSize)
    }
    class func rgbColor(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat ,_ alpha:CGFloat) -> UIColor{
           return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
       }
    class func rgbColor(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat) -> UIColor{
        return self.rgbColor(r, g, b, 1.0)
    }
    static func thirdColor() -> UIColor{
        return self.rgbColor(246, 246, 246)
    }
    static func whiteColor() -> UIColor{
        return UIColor.white
    }
    static func titleColor() -> UIColor{
        return self.rgbColor(39, 61, 82)
    }
    static func secondColor() -> UIColor{
        return self.rgbColor(21, 126, 255)
    }
    static func secondColor(alpha:CGFloat) -> UIColor{
        return self.rgbColor(21, 126, 255,alpha)
    }
    static func fourthColor() -> UIColor{
        return self.rgbColor(104, 115, 128)
    }
    
    static func singleNumColor(num : CGFloat) -> UIColor{
        return self.rgbColor(num, num, num)
    }
    static func singleNumColor(num : CGFloat,alpha : CGFloat) -> UIColor{
        return self.rgbColor(num, num, num, alpha)
    }
    
    
    ///修改密码标题se
    static func changePasswordTitleColor() -> UIColor{
        return self.titleColor()
    }
    ///修改密码描述color
    static func changePasswordDescColor() -> UIColor{
        return self.fourthColor()
    }
    ///修改密码手机号color
    static func changePasswordPhoneColor() -> UIColor{
        return self.titleColor()
    }
    ///修改密码获取验证码color
    static func changePasswordVerifyColor() -> UIColor{
        return UIColor.white
    }
    ///修改密码手机号失效color
    static func changePasswordVerifyBackColor() -> UIColor{
        return self.secondColor()
    }
    ///修改密码手机号失效color
    static func changePasswordPhoneDisableColor() -> UIColor{
        return self.fourthColor()
    }
    ///更换手机号输入框背景色
    static func changePhoneInputBackColor() -> UIColor{
        return self.singleNumColor(num: 225,alpha: 0.5)
    }
    ///更换手机号选择新区号字色
    static func changePhoneSelectedCountryColor() -> UIColor{
        return self.secondColor()
    }
    ///更换手机号选择新区号分割线色
    static func changePhoneSegmentLineColor() -> UIColor{
        return self.singleNumColor(num: 229)
    }
    @objc
    static func mainTitleFont() -> UIFont{
        self.font(name: "PingFangSC-Semibold", size: 18)
    }
    static func secondTitleFont() -> UIFont{
        
        self.font(name: "PingFangSC-Medium", size: 15)
    }
    
    static func thirdTitleFont() -> UIFont{
        self.font(name: "PingFangSC-Regular", size: 15)
    }
    static func mainTitleFont(size:CGFloat) -> UIFont{
        self.font(name: "PingFangSC-Semibold", size: size)
    }
    static func secondTitleFont(size:CGFloat) -> UIFont{
        self.font(name: "PingFangSC-Medium", size: size)
    }
    
    ///修改密码标题font
    static func changePasswordTitleFont() -> UIFont{
        return self.secondTitleFont(size: 23)
    }
    ///修改密码描述font
    static func changePasswordDescFont() -> UIFont{
        return self.secondTitleFont(size: 12)
    }
    ///修改密码手机号font
    static func changePasswordPhoneFont() -> UIFont{
        return self.secondTitleFont(size: 15)
    }
    ///修改密码获取验证码font
    static func changePasswordVerifyFont() -> UIFont{
        return self.thirdTitleFont(size: 18)
    }
    ///修改密码手机号失效font
    static func changePasswordPhoneDisableFont() -> UIFont{
        return self.secondTitleFont(size: 12)
    }
       
    static func thirdTitleFont(size:CGFloat) -> UIFont{
        self.font(name: "PingFangSC-Regular", size: size)
    }
    class func color(colorName:String) -> UIColor {
//        if #available(iOS 11.0, *) {
//            return UIColor.init(named: colorName) ?? UIColor.blue
//        } else {
        return self.colorWithHexString(hexString:colorName,alpha: 1.0) ?? UIColor.blue          // Fallback on earlier versions
//        }
    }
    
    class func colorWithHexString (hexString:String,alpha:CGFloat)-> UIColor? {
        
        var hex = hexString
        if hex.hasPrefix("#") {
            hex = String(hex[hex.index(after: hex.startIndex)...])
        }
        guard let hexVal = Int(hex, radix: 16) else {
            return nil
        }
        
        if hex.count == 6 {
            return  UIColor.init(red:   CGFloat( (hexVal & 0xFF0000) >> 16 ) / 255.0,
            green: CGFloat( (hexVal & 0x00FF00) >> 8 ) / 255.0,
            blue:  CGFloat( (hexVal & 0x0000FF) >> 0 ) / 255.0, alpha:alpha)
        }
        return nil
    }
    
    
    static func formartString(string : String) -> String{
           let num = string.length / 3
           var remainder = string.length % 3
           var firstString : String
           var secondString : String
           let thirdString : String
           var parserText = string
           
           if num > 0,remainder > 0 {
               thirdString = string.substring(from: string.length - (num + 1))
               parserText = string.substring(to: string.length - thirdString.length)
               remainder = parserText.length % num
               if remainder > 0 {
                   secondString = parserText.substring(from: parserText.length - (num + 1))
               }else{
                   secondString = parserText.substring(from: parserText.length - num)
               }
               firstString = parserText.substring(to: parserText.length - secondString.length)
               
               return firstString + " " + secondString + " " + thirdString
               
           }else if num > 0, remainder == 0{
               thirdString = string.substring(from: string.length - (num))
               parserText = string.substring(to: string.length - thirdString.length)
               secondString = parserText.substring(from: parserText.length - num)
               firstString = parserText.substring(to: parserText.length - secondString.length)
               return firstString + " " + secondString + " " + thirdString

           }else{
               return parserText
           }
       }
    
    
    
    
    
    static func getQRCodeImage(_ url: String?,fgImage:UIImage?) -> UIImage?{
           if url == nil {
               return nil
           }
           // 创建二维码滤镜
           let filter = CIFilter.init(name: "CIQRCodeGenerator")
           // 恢复滤镜默认设置
           filter?.setDefaults()
           // 设置滤镜输入数据
           let data = url!.data(using: String.Encoding.utf8)
           filter?.setValue(data, forKey: "inputMessage")
           // 设置二维码的纠错率
           filter?.setValue("M", forKey: "inputCorrectionLevel")
           // 从二维码滤镜里面, 获取结果图片
           guard let outImage = filter?.outputImage else {return nil}
           var image = outImage
           // 生成一个高清图片
           let transform = CGAffineTransform.init(scaleX: 10, y: 10)
           image = image.transformed(by: transform)
           // 图片处理
           let resultImage = UIImage(ciImage: image)
           // 设置二维码中心显示的小图标
           guard let centerImage = fgImage else {
               return resultImage
           }
           return getClearImage(resultImage, centerImage)
          
       }
        // 使图片放大也可以清晰
       static func getClearImage(_ sourceImage: UIImage,_ centerImage: UIImage) -> UIImage? {
               
           let size = sourceImage.size
           // 开启图形上下文
           UIGraphicsBeginImageContext(size)
               
           // 绘制大图片
           sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
               
           // 绘制二维码中心小图片
           let width: CGFloat = 100
           let height: CGFloat = 100
           let x: CGFloat = (size.width - width) * 0.5
           let y: CGFloat = (size.height - height) * 0.5
           centerImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
           // 取出结果图片
           guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else {
               return nil
           }
           // 关闭上下文
           UIGraphicsEndImageContext()
           return resultImage
       }
    

       static func saveImage(image: UIImage) {
        let photoAuthorStatus = PHPhotoLibrary.authorizationStatus()
        switch (photoAuthorStatus) {
        case PHAuthorizationStatus.authorized:
              self.saveImageToLibrary(image: image)
              break;
        case PHAuthorizationStatus.denied:
            OWSAlerts.showAlert(title: "请到设置里面开通相册访问权限")
//              NSLog(@"不允许授权");
              break;
        case PHAuthorizationStatus.notDetermined:
//              NSLog(@"不确定");
           fallthrough
        case PHAuthorizationStatus.restricted:
//              NSLog(@"限制");
            PHPhotoLibrary.requestAuthorization { (staus) in
               if staus == PHAuthorizationStatus.authorized{
                   self.saveImageToLibrary(image: image)

               }
            }
              break;
          default:
              break;
        }
            
    }
    static func turnImageAction(image:UIImage) -> UIImage{
        var newImage = UIImage.init(ciImage: image.ciImage!)
        UIGraphicsBeginImageContext(newImage.size)
        newImage.draw(in: CGRect.init(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    static private func saveImageToLibrary(image : UIImage){
//        let newImage = self.turnImageAction(image: image)
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (isSuccess, error) in
            DispatchQueue.main.async {
                if isSuccess {
                      OWSAlerts.showAlert(title: "保存成功")
                  } else {
                      OWSAlerts.showAlert(title: "保存失败")
                  }
            }

        }
    }
    
   static private func saveButtonEventWithImage(image: UIImage) {
//        let newImage = UIImage.image(image)
    
//    UIImage *newImage = [UIImage imageWithCIImage:image];
//
//       UIGraphicsBeginImageContext(newImage.size);
//       //  绘制二维码图片
//       [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
//
//       //  从图片上下文中取出图片
//       newImage  = UIGraphicsGetImageFromCurrentImageContext();
//
//       //  关闭图片上下文
//       UIGraphicsEndImageContext();
//    let newImage = UIImage.i
    
        //保存完后调用的方法
         let selector = #selector(onCompleteCapture(image:error:contextInfo:))
        //保存
         UIImageWriteToSavedPhotosAlbum(image, self, selector, nil)
    }

    //图片保存完后调用的方法
    @objc
    static private  func onCompleteCapture(image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
         if error == nil {
            //保存失败
            OWSAlerts.showAlert(title: "保存失败")

        }else {
            OWSAlerts.showAlert(title: "保存成功")
            //保存成功
        }
    }
        
}






extension TXTheme{
    @objc
    static func alertActionWithMessage(title:String?, message:String?,fromController:UIViewController?,success:@escaping() -> Void){
            guard let from = fromController else {
                return
            }
           let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
           let action = UIAlertAction.init(title: "确定", style: .default) { (action) in
                   success()
           }
           let action1 = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
                   
           }
           alert.addAction(action)
           alert.addAction(action1)
           from.presentAlert(alert, animated: true)
    }
}


extension TXTheme {
    //MARK:-  格式化电话号码
   static func phoneNumFormartString(string : String) -> String{
        let num = string.length / 3
        var remainder = string.length % 3
        var firstString : String
        var secondString : String
        let thirdString : String
        var parserText = string
        
        if num > 0,remainder > 0 {
            thirdString = string.substring(from: string.length - (num + 1))
            parserText = string.substring(to: string.length - thirdString.length)
            remainder = parserText.length % num
            if remainder > 0 {
                secondString = parserText.substring(from: parserText.length - (num + 1))
            }else{
                secondString = parserText.substring(from: parserText.length - num)
            }
            firstString = parserText.substring(to: parserText.length - secondString.length)
            
            return firstString + " " + secondString + " " + thirdString
            
        }else if num > 0, remainder == 0{
            thirdString = string.substring(from: string.length - (num))
            parserText = string.substring(to: string.length - thirdString.length)
            secondString = parserText.substring(from: parserText.length - num)
            firstString = parserText.substring(to: parserText.length - secondString.length)
            return firstString + " " + secondString + " " + thirdString

        }else{
            return parserText
        }
    }
}
//MARK:-  颜色扩张
extension TXTheme {
    //MARK:-  PG号界面
    ///标题tag 的颜色
    static func PG_titleTagColor() -> UIColor{
        return self.rgbColor(39, 61, 82)
    }
    ///提示颜色
    static func PG_toastColor() -> UIColor{
        return self.rgbColor(112, 233, 32)
    }
    ///描述颜色
    static func PG_descColor() -> UIColor{
        return self.rgbColor(136, 148, 159)
    }
    ///链接颜色
    static func PG_linkColor() -> UIColor{
        return self.rgbColor(21, 126, 255)
    }
    ///保存背景色
    static func PG_saveBackColor() -> UIColor{
        return self.self.rgbColor(21, 126, 255)
    }
    ///保存字色
    static func PG_saveTitleColor() -> UIColor{
        return UIColor.white
    }

    
    
}
//MARK:-  字体扩展

extension TXTheme {
    //MARK:-  PG号界面

    ///标题tag font
    static func PG_titleTagFont() -> UIFont{
        return self.thirdTitleFont(size: 15)
    }
    ///提示font
    static func PG_toastFont() -> UIFont{
        return self.thirdTitleFont(size: 12)
    }
    ///描述font
    static func PG_descFont() -> UIFont{
        return self.thirdTitleFont(size: 12)
    }
    ///链接font
    
    static func PG_linkFont() -> UIFont{
        return self.thirdTitleFont(size: 12)
    }
    ///保存font
    static func PG_saveFont() -> UIFont{
        return self.thirdTitleFont(size: 18)
    }

}
