//
//  DYPickerView.m
//  ID贷
//
//  Created by apple on 2019/6/22.
//  Copyright © 2019 hansen. All rights reserved.
//

#import "DYPickerView.h"
#import "DYMacro.h"


@interface DYPickerView ()

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,weak) UILabel *titleLabel;


@end
@implementation DYPickerView


+ (instancetype)pickerView {
    
    DYPickerView *view = [self new];
    return view;
}
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    [self setupSubView];
    return self;
}

- (void)setupSubView{
    self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.5];
    [self addTarget:self selector:@selector(dismiss)];
   
    self.contentView = [UIView new];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.equalTo(self).multipliedBy(0.4);
    }];
    
    
    UIView *toolView = [UIView new];
    toolView.backgroundColor = [UIColor whiteColor];
    [self addSubview:toolView];
    [toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.offset(44);
        make.bottom.equalTo(self.contentView.mas_top);
    }];
    UIButton *cancle = [UIButton new];
    [cancle setTitle:@"取消" forState:UIControlStateNormal];
    [cancle setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancle addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:cancle];
    [cancle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(8);
        make.centerY.offset(0);
        make.height.offset(44);
        make.width.offset(60);
    }];
    UILabel *label = [UILabel new];
    label.font = [UIFont boldSystemFontOfSize:17];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [toolView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.offset(200);
    }];
    UIButton *confirm = [UIButton new];
    [confirm setTitle:@"确认" forState:UIControlStateNormal];
    [confirm setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [confirm addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:confirm];
    [confirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-8);
        make.centerY.offset(0);
        make.height.offset(44);
        make.width.offset(60);
    }];
    
    [self setupContentView];
    
}
- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}
- (void)confirmBtnClick {
    [self dismiss];
}

- (void)show {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];

}
- (void)setupContentView {
    
}

- (void)dismiss {
    [self removeFromSuperview];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@interface DYSinglePickerView ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic,strong) UIPickerView *picker;


@end
@implementation DYSinglePickerView {
    
    NSUInteger _currentIndex;
    
}



-(void)setupContentView {
    
    self.picker = [UIPickerView new];
    self.picker.dataSource = self;
    self.picker.delegate = self;
    [self.contentView addSubview:self.picker];
    [self.picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
}

- (void)confirmBtnClick {
    if (self.selectResult) {
        self.selectResult(@(_currentIndex));
    }
    [self dismiss];

}


- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.sources.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.sources[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    _currentIndex = row;
}


@end
