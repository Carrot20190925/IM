//
//  UIAlertController+dy_extension.h
//  ID贷
//
//  Created by apple on 2019/6/24.
//  Copyright © 2019 hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (dy_extension)

+ (instancetype)showCustomAlertWithTitle:(NSString *)title messgae:(NSString *)message confirmTitle:(NSString *)confirmTitle cancleTitle:(NSString *)cancleTitle confirmCallback:(void(^)(void))callback;

+ (instancetype)showEditAlertWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle placeHolder:(NSString *)holder confirmCallback:(void(^)(NSString *content))callback;
@end

NS_ASSUME_NONNULL_END
