//
//  NSDictionary+dyExtension.m
//  ID贷
//
//  Created by apple on 2019/6/20.
//  Copyright © 2019 hansen. All rights reserved.


#import "NSDictionary+dy_extension.h"

@implementation NSDictionary (dy_extension)


- (NSDictionary *)handleDictNullToString {
    
    NSMutableDictionary *dictM = self.mutableCopy;
    
    [dictM enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:NSNull.class]) {
            dictM[key] = @"";
        }
        if ([obj isKindOfClass:NSDictionary.class]) {
            [obj handleDictNullToString];
        }
    }];
    
    return dictM.copy;
}
- (NSString *)toString {
    
    
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:0 error:0] encoding:NSUTF8StringEncoding];
    
}
@end
