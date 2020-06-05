//
//  UIAlertController+dy_extension.m
//  ID贷
//
//  Created by apple on 2019/6/24.
//  Copyright © 2019 hansen. All rights reserved.
//

#import "UIAlertController+dy_extension.h"

@implementation UIAlertController (dy_extension)


+ (instancetype)showCustomAlertWithTitle:(NSString *)title messgae:(NSString *)message confirmTitle:(NSString *)confirmTitle cancleTitle:(NSString *)cancleTitle confirmCallback:(void (^)(void))callback {
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        callback();
    }];
    [vc addAction:confirm];
    [vc addAction:[UIAlertAction actionWithTitle:cancleTitle style:UIAlertActionStyleCancel handler:nil]];

    return vc;
}

+ (instancetype)showEditAlertWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle placeHolder:(NSString *)holder confirmCallback:(void (^)(NSString *content))callback {
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = holder;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *content = vc.textFields.firstObject.text;
        if (content.length == 0) {
//            [SVProgressHUD showInfoWithStatus:@"不能为空！"];
            return;
        }
        callback(content);
    }];
    [vc addAction:confirm];
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    return vc;
}
@end
