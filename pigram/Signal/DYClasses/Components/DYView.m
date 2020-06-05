//
//  DYView.m
//  ProjectXZHB
//
//  Created by fangyuan on 2019/7/22.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "DYView.h"

@implementation DYView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = [borderColor CGColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setMasksToBounds:(BOOL)masksToBounds {
    _masksToBounds = masksToBounds;
    self.layer.masksToBounds = masksToBounds;
}

@end
