//
//  UIButtonCus.m
//  FjeapStudy
//
//  Created by fjeap.com on 16/7/12.
//  Copyright © 2016年 wc All rights reserved.
//

#import "UIButton+Ani.h"
#import <objc/runtime.h>


static const NSTimeInterval defautltTimeInterval = 1.0;
@interface UIButton()

@property (assign, nonatomic) BOOL isIngoreClick;  //不顾点击

@end

@implementation UIButton (UIButtonAni)

+ (void)load{
    //Method Swizzling
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        /*
         struct objc_method {
         SEL _Nonnull method_name                                 OBJC2_UNAVAILABLE;
         char * _Nullable method_types                            OBJC2_UNAVAILABLE;
         IMP _Nonnull method_imp                                  OBJC2_UNAVAILABLE;
         }
         */
        //获取方法
        SEL defaultButtonActionSEL = @selector(sendAction:to:forEvent:);
        SEL changeButtonActionSEL = @selector(mySendAction:to:forEvent:);
        Method defaultButtonActionMethod = class_getInstanceMethod(self, defaultButtonActionSEL);
        Method changeButtonActionMethod = class_getInstanceMethod(self, changeButtonActionSEL);
        
        //添加方法
        BOOL isAdd = class_addMethod(self, defaultButtonActionSEL, method_getImplementation(changeButtonActionMethod), method_getTypeEncoding(changeButtonActionMethod));
        
        if ( isAdd ) {
            //添加成功，那么就替换实现方法
            class_replaceMethod(self, changeButtonActionSEL, method_getImplementation(defaultButtonActionMethod), method_getTypeEncoding(defaultButtonActionMethod));
        } else {
            //添加不成功，说明已经有方法了，那么直接执行方法实现的对调
            method_exchangeImplementations(defaultButtonActionMethod, changeButtonActionMethod);
        }
        
    });
}

- (void)mySendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    
    if ( [NSStringFromClass([self class]) isEqualToString:@"UIButton"] ) {
        if ( self.isIngoreClick ) {
            //不能点击
            return;
        } else {
            self.noClickInterval = (self.noClickInterval == 0) ? defautltTimeInterval : self.noClickInterval;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.noClickInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isIngoreClick = NO;
            });
        }
        
    }
    
    self.isIngoreClick = YES;
    //这里并不会造成死循环，因为已经替换实现方法了
    [self mySendAction:action to:target forEvent:event];
}


#pragma mark - AssociatedObject

- (void)setNoClickInterval:(NSTimeInterval)noClickInterval
{
    objc_setAssociatedObject(self, @selector(noClickInterval), @(noClickInterval), OBJC_ASSOCIATION_ASSIGN);
}

- (NSTimeInterval)noClickInterval
{
    return [objc_getAssociatedObject(self, @selector(noClickInterval)) doubleValue];
}

- (void)setIsIngoreClick:(BOOL)isIngoreClick
{
    objc_setAssociatedObject(self, @selector(isIngoreClick), @(isIngoreClick), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isIngoreClick
{
    return [objc_getAssociatedObject(self, @selector(isIngoreClick)) boolValue];
}

-(void)addTouchAni{
    [self addTarget:self action:@selector(starAni) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(endAni) forControlEvents:UIControlEventTouchDragOutside];
    [self addTarget:self action:@selector(endAni) forControlEvents:UIControlEventTouchUpInside];

}

-(void)starAni{
    self.transform = CGAffineTransformMakeScale(1.05, 1.05);
}

-(void)endAni{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

-(void)delayEnable {//延迟一段时间才能点
    [self addTarget:self action:@selector(delayEnableAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void)delayEnableAction{
    self.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.userInteractionEnabled = YES;
    });
}
- (void)layoutButtonWithEdgeInsetsStyle:(GLButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space {
    /**
     *  知识点：titleEdgeInsets是title相对于其上下左右的inset，跟tableView的contentInset是类似的，
     *  如果只有title，那它上下左右都是相对于button的，image也是一样；
     *  如果同时有image和label，那这时候image的上左下是相对于button，右边是相对于label的；title的上右下是相对于button，左边是相对于image的。
     */
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    switch (style) {
            case GLButtonEdgeInsetsStyleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);
        }
            break;
            case GLButtonEdgeInsetsStyleLeft:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
        }
            break;
            case GLButtonEdgeInsetsStyleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWith, 0, 0);
        }
            break;
            case GLButtonEdgeInsetsStyleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0);
        }
            break;
        default:
            break;
    }
    // 4. 赋值
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}

@end
