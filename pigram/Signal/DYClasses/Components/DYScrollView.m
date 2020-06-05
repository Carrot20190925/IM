//
//  DYScrollView.m
//  ID贷
//
//  Created by apple on 2019/6/21.
//  Copyright © 2019 hansen. All rights reserved.
//

#import "DYScrollView.h"


@interface DYScrollView ()
@property (nonatomic,strong) UIView *contentView;

@end

@implementation DYScrollView {
    
}

+ (instancetype)scrollView {
    DYScrollView *view = [DYScrollView new];
    [view setupSubView];
    return view;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupSubView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setupSubView];
    return self;
}

- (void)setupSubView {
   
    self.contentView = [UIView new];
    [self addSubview:self.contentView];
    self.margin = 16;
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.centerX.offset(0);
        make.height.equalTo(self);
    }];
  
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.contentView.subviews.count > 0) {
        return;
    }
    [self updateContentView];
    [self updateHeight];
}

- (void)updateContentView {
    for (UIView *subView in self.subviews) {
        if (subView != self.contentView) {
            [self.contentView addSubview:subView];
        }
    }
}

- (void)updateHeight {
    
    CGFloat maxY = self.height + self.margin;
    for (UIView *subView in self.contentView.subviews) {
        CGFloat subMaxY = CGRectGetMaxY(subView.frame);
        if (subMaxY > maxY) {
            maxY = subMaxY;
        }
    }
    self.contentSize = CGSizeMake(self.width, maxY);
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.centerX.offset(0);
        make.height.offset(maxY);
    }];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

