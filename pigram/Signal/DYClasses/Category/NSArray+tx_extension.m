//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import "NSArray+tx_extension.h"



@implementation NSArray (tx_extension)
- (BOOL)tx_contain:(BOOL (^)(id _Nonnull))handler{
    BOOL isContain = NO;
    for (id objct in self) {
       isContain =  handler(objct);
        if (isContain) {
            return isContain;
        }
    }
    return isContain;
}
@end
