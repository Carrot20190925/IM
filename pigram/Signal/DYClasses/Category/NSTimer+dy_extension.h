//
//  NSTimer+dy_extension.h
//  ID贷
//
//  Created by apple on 2019/7/2.
//  Copyright © 2019 hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (dy_extension)

+ (NSTimer *)dy_scheduledWeakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;
@end

NS_ASSUME_NONNULL_END
