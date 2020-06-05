//
//  WDButton.m
//  国学
//
//  Created by 老船长 on 2017/11/22.
//  Copyright © 2017年 汪宁. All rights reserved.
//

#import "DYButton.h"

@implementation DYButton

- (void)setText:(NSString *)text {
    [self setTitle:text forState:UIControlStateNormal];
}
- (void)setImage:(UIImage *)image {
    [self setImage:image forState:UIControlStateNormal];
}
- (void)setTextColor:(UIColor *)textColor {
    [self setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)setSeleText:(NSString *)text {
    [self setTitle:text forState:UIControlStateSelected];
}
- (void)setSeleImage:(UIImage *)image {
    [self setImage:image forState:UIControlStateSelected];
}
- (void)setSeleTextColor:(UIColor *)textColor {
    [self setTitleColor:textColor forState:UIControlStateSelected];
}

- (void)setHighlightText:(NSString *)text {
    [self setTitle:text forState:UIControlStateHighlighted];
}
- (void)setHighlightImage:(UIImage *)image {
    [self setImage:image forState:UIControlStateHighlighted];
}
- (void)setHighlightTextColor:(UIColor *)textColor {
    [self setTitleColor:textColor forState:UIControlStateHighlighted];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.direction == 1) {
        CGSize titleSize = self.titleLabel.bounds.size;
        CGSize imageSize = self.imageView.bounds.size;
        CGFloat interval = 0.1;
        [self setImageEdgeInsets:UIEdgeInsetsMake(0,0, titleSize.height + self.margin, -(titleSize.width + interval))];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(imageSize.height + interval, -(imageSize.width + interval), 0, 0)];
    } else if (self.direction == 2) {
        CGSize titleSize = self.titleLabel.bounds.size;
        CGSize imageSize = self.imageView.bounds.size;
        self.imageEdgeInsets = UIEdgeInsetsMake(0,titleSize.width, 0, -titleSize.width + -self.margin);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, 0, imageSize.width);
    } else if (self.direction == 3) {
        [self.titleLabel sizeToFit];
        self.imageView.frame = self.bounds;
        self.titleLabel.frame = self.imageView.frame;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self bringSubviewToFront:self.titleLabel];
    }
}
@end
