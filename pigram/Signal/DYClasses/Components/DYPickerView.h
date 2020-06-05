//
//  DYPickerView.h
//  ID贷
//
//  Created by apple on 2019/6/22.
//  Copyright © 2019 hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PickerResult)(id);

@protocol DYPickerViewProtocol <NSObject>

- (void)setupContentView;
- (void)confirmBtnClick;

@end

@interface DYPickerView : UIView <DYPickerViewProtocol>

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) PickerResult selectResult;


+ (instancetype)pickerView;

- (void)show;
- (void)dismiss;

@end


@interface DYSinglePickerView : DYPickerView

@property (nonatomic,copy) NSArray<NSString *> *sources;


@end


NS_ASSUME_NONNULL_END
