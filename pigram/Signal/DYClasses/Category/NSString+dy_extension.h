//
//  NSString+extension.h
//  ID贷
//
//  Created by apple on 2019/6/19.
//  Copyright © 2019 hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (dy_extension)


/** 对字符串进行MD5处理
 *
 *
 */
//- (NSString *)md5;

+ (NSString *)getCurrentDeviceModel;

/* 验证手机号是否合法 */
+ (BOOL)isValidateMobile:(NSString *)mobile;

/* 验证邮箱是否合法 */
+ (BOOL)isValidateEmail:(NSString *)email;

/** 验证固定电话是否合法*/
+ (BOOL)isValidateFixedTelephone:(NSString *)fixedTelephone;

/** 验证是否合法*/
+ (BOOL)isMatchingWithRegularExpression:(NSString *)regularExpression text:(NSString *)text;
/**
 * 获取字符串占用宽度
 */
- (CGFloat)getWidthWithFont:(UIFont *)font height:(CGFloat)height;


/**
 * 随机生成一个长度的字符串
 */
+ (NSString *)generateRandomStringWithLength:(NSInteger)length;
@end

NS_ASSUME_NONNULL_END
