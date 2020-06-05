//
//  WDButton.h
//  国学
//
//  Created by 老船长 on 2017/11/22.
//  Copyright © 2017年 汪宁. All rights reserved.
//

#import <UIKit/UIKit.h>


IB_DESIGNABLE
typedef int ContentDirection;
@interface DYButton : UIButton
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) UIColor  *textColor;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSString *seleText;
@property (nonatomic, copy) UIColor  *seleTextColor;
@property (nonatomic, copy) UIImage *seleTmage;
@property (nonatomic, copy) NSString *highlightText;
@property (nonatomic, copy) UIColor  *highlightTextColor;
@property (nonatomic, copy) UIImage *highlightTmage;
///图片跟文字的间距
@property (nonatomic, assign) CGFloat margin;


/**1 图片在上 2 图片在右 3 图片文字都居中*/
@property (assign, nonatomic) IBInspectable ContentDirection direction;
@end
