//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "OWSAvatarBuilder.h"
#import <SignalServiceKit/TSThread.h>

NS_ASSUME_NONNULL_BEGIN

@class TSGroupThread;

@interface OWSGroupAvatarBuilder : OWSAvatarBuilder

- (instancetype)initWithThread:(TSGroupThread *)thread diameter:(NSUInteger)diameter;


- (instancetype)initWithAddress:(SignalServiceAddress *)address
                      colorName:(ConversationColorName )colorName
                       diameter:(NSUInteger)diameter;

+ (nullable UIImage *)defaultAvatarForGroupId:(NSString *)groupId
                        conversationColorName:(NSString *)conversationColorName
                                     diameter:(NSUInteger)diameter;

@end

NS_ASSUME_NONNULL_END
