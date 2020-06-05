//
//  NSDictionary+dyExtension.h
//  ID贷
//
//  Created by apple on 2019/6/20.
//  Copyright © 2019 hansen. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (dy_extension)

- (NSDictionary *)handleDictNullToString;
- (NSString *)toString;

@end

NS_ASSUME_NONNULL_END
