//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import <SignalServiceKit/BaseModel.h>

NS_ASSUME_NONNULL_BEGIN
@class TSGroupModel;
@interface PigramGroupModel : BaseModel

@property (atomic, readonly) TSGroupModel *groupModel;
///群公告
@property (nonatomic) NSString *groupNotice;


@end

NS_ASSUME_NONNULL_END
