//
//  NSDate+dy_extension.h
//  ID贷
//
//  Created by apple on 2019/6/24.
//  Copyright © 2019 hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (dy_extension)

+ (NSTimeInterval)dy_dateStrToIntervalWithDateStr:(NSString *)dateStr dateFormat:(NSString *)format;

+ (NSString *)dy_timeStampToDateStrWithInterval:(NSTimeInterval)interval dataFormat:(NSString *)format;

@end

NS_ASSUME_NONNULL_END
