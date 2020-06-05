//
//  UIImage+dy_extension.h
//  Project
//
//  Created by fangyuan on 2019/8/15.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (dy_extension)


+ (UIImage*)imageWithColor:(UIColor*)color;

- (UIImage *)dy_rotateImageWithAngle:(CGFloat)angle resize:(CGSize)size;

+ (UIImage *)dy_circleImageWithColor:(UIColor *)color size:(CGFloat)size;
+ (UIImage *)dy_circleImageWithColor:(UIColor *)color size:(CGFloat)size attribute:(NSAttributedString *)attr;
+ (UIImage *)imageWithClipImage:(UIImage *)image;
+ (UIImage *)imageWithBorder:(CGFloat)borderW color:(UIColor *)borderColor image:(UIImage *)image;
/**
 * 识别二维码
 */
- (void)detectorQRImageWithFinished:(void(^)( NSArray<CIQRCodeFeature *> * _Nullable,  NSError * _Nullable))finished;
@end

NS_ASSUME_NONNULL_END
