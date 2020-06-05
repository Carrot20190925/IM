//
//  UIView+Extension.h

//
//  Created by apple on 14-10-7.
//  Copyright (c) 2014年 LUKHA_Lu. All rights reserved.
//

#define kScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height

#define kScreenWidthRatio kScreenWidth / 375
#define kScreenHeightRatio kScreenHeight / 667



#import <UIKit/UIKit.h>

@interface UIView (dy_extension)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign, readonly) CGFloat maxX;
@property (nonatomic, assign, readonly) CGFloat maxY;


//获取该视图的控制器
- (UIViewController*) viewController;

//删除当前视图内的所有子视图
- (void)removeChildViews;

//删除tableview底部多余横线
- (void)setExtraCellLineHidden: (UITableView *)tableView;

- (void)addRound:(CGFloat)radius;

- (void)addShadow:(CGFloat)shadowRadius round:(CGFloat)roundRadius;

- (void)addBoard:(CGFloat)radius color: (UIColor *)color;

- (void)addTarget:(id)target selector:(SEL)selector;
@end
