//
//  UIViewController+dyExtension.m
//  ID贷
//
//  Created by apple on 2019/6/20.
//  Copyright © 2019 hansen. All rights reserved.
//

#import "UIViewController+dy_extension.h"
#import <objc/runtime.h>

@implementation UIViewController (dy_extension)


+ (instancetype)dy_initWithVCString:(NSString *)vcStr {
    
    Class class;
    
    @try {
        class = NSClassFromString(vcStr);
    } @catch (NSException *exception) {
        NSLog(@"dyLog -----%@", exception);
        return nil;
    }
    UIViewController *vc = [class new];
    
    return vc;
}

+ (void)load {
    
    Method present_orogin = class_getInstanceMethod(UIViewController.class, @selector(presentViewController:animated:completion:));
    Method new_present = class_getInstanceMethod(UIViewController.class, @selector(ex_presentViewController:animated:completion:));
    
    method_exchangeImplementations(present_orogin, new_present);
    
}

- (void)ex_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (viewControllerToPresent.modalPresentationStyle == UIModalPresentationPageSheet && [[UIDevice currentDevice].systemVersion floatValue] > 13.0) {
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self ex_presentViewController:viewControllerToPresent animated:flag completion:completion];
}
@end
