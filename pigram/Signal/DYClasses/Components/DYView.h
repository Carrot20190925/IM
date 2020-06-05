//
//  DYView.h
//  ProjectXZHB
//
//  Created by fangyuan on 2019/7/22.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


//该关键字的作用是 在xib中能实时看到修改属性的效果  或者纯代码布局后的效果
IB_DESIGNABLE
/**
 * 能够在xib中设置自定义的属性
 */
@interface DYView : UIView
@property (nonatomic, copy) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable BOOL masksToBounds;



@end

NS_ASSUME_NONNULL_END
