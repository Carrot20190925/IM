//
//  DYScrollView.h
//  ID贷
//
//  Created by apple on 2019/6/21.
//  Copyright © 2019 hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 可滚动的view， 并且自动计算最大的可滚动范围
 *  在布局完成后将scrollView的子View全部添加到其中的contentView中
 *  
 */
@interface DYScrollView : UIScrollView

/**上下保留的margin值  默认是16*/
@property (nonatomic,assign) CGFloat margin;


+ (instancetype)scrollView;

- (void)updateContentView;

@end

NS_ASSUME_NONNULL_END
