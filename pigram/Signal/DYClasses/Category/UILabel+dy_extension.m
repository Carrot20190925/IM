//
//  UILabel+dy_extension.m
//  ID贷
//
//  Created by apple on 2019/6/21.
//  Copyright © 2019 hansen. All rights reserved.
//

#import "UILabel+dy_extension.h"
#import <objc/runtime.h>

#define kStandardScreenWidth 375.0
@implementation UILabel (dy_extension)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Method orgi_method = class_getInstanceMethod(self, @selector(setFont:));
        Method new_method = class_getInstanceMethod(self, @selector(new_setFont:));
        method_exchangeImplementations(orgi_method, new_method);
        
//        Method orgi_text_method = class_getInstanceMethod(self, @selector(setText:));
//        Method new_text_method = class_getInstanceMethod(self, @selector(new_setText:));
//        method_exchangeImplementations(orgi_text_method, new_text_method);
    });
    
    
}

- (void)new_setFont:(UIFont *)font {
    
//    CGFloat fontSize = kScreenWidth * (font.pointSize / kStandardScreenWidth);
//    font = [UIFont systemFontOfSize:fontSize];
    [self new_setFont:font];
    
}
//- (void)new_setText:(NSString *)text {
//
//    DYLog(@"new_setText ------ %@",text);
//    text = kMy_Language(text);
//    DYLog(@"new_setText value ==  %@",text);
//
//    [self new_setText: text];
//}
@end


