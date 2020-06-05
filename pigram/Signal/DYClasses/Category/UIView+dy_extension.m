//
//  UIView+Extension.m
//
//  Created by apple on 14-10-7.
//  Copyright (c) 2014年 LUKHA_Lu. All rights reserved.
//

#import "UIView+dy_extension.h"

@implementation UIView (dy_extension)

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (CGFloat)maxX {
    return self.x + self.width;
}

-(CGFloat)maxY {
    return self.y + self.height;
}


//获取该视图的控制器
- (UIViewController*) viewController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

//删除当前视图内的所有子视图
- (void) removeChildViews{
    for (UIView *cv in self.subviews) {
        [cv removeFromSuperview];
    }
}
//删除tableview底部多余横线
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    
    UIView *view = [UIView new];
    
    view.backgroundColor = [UIColor clearColor];
    
    [tableView setTableFooterView:view];
}

- (void)addRound:(CGFloat)radius {
    
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}


- (void)addShadow:(CGFloat)shadowRadius round:(CGFloat)roundRadius {
    self.layer.cornerRadius = roundRadius;
    self.layer.masksToBounds = false;
    self.layer.shadowRadius = shadowRadius;
    self.layer.shadowColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.5].CGColor;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0, 5);
}

- (void)addBoard:(CGFloat)radius color:(UIColor *)color {
    self.layer.borderWidth = radius;
    self.layer.borderColor = color.CGColor;
}

- (void)addTarget:(id)target selector:(SEL)selector {
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
}


@end



