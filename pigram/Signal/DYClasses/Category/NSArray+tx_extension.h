//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (tx_extension)
//- (BOOL)containsObject:(id)anObject
- (BOOL)tx_contain:(BOOL (^)(id objct))handler;
@end

NS_ASSUME_NONNULL_END
