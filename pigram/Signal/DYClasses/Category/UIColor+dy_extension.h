//
//  UIColor+Hex.h
//  HuiYinApp
//
//  Created by   on 16/8/1.
//  Copyright © 2016年 Manager. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (dy_extension)
/**
 *  渐变色
 *
 *  @param color 输入颜色
 */
+(CAGradientLayer *)shadowAsInverseWithColor:(UIColor *)color  frame:(CGRect)rect;
+(CAGradientLayer *)shadowAsInverseWithColors:(NSArray *)colors frame:(CGRect)rect;

+ (UIColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

/**
 *  Create a color from a HEX string.
 *  It supports the following type:
 *  - #RGB
 *  - #ARGB
 *  - #RRGGBB
 *  - #AARRGGBB
 *
 *  @param hex HEX string
 *
 *  @return Returns the UIColor instance
 */
+ (UIColor *)hex:(NSString *)hexString;

/**
 *  通过0xffffff的16进制数字创建颜色
 *
 *  @param aRGB 0xffffff
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithRGB:(NSUInteger)aRGB;


+ (UIColor *)dy_randomColor;


@end
