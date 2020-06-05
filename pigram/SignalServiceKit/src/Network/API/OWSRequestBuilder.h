//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class TSRequest;

@interface OWSRequestBuilder : NSObject

/**
 * 生成修改昵称的request  已弃用
 */
+ (TSRequest *)profileNameSetRequestWithEncryptedPaddedName:(nullable NSData *)encryptedPaddedName;


+ (TSRequest *)profileNameSetRequestWithNoEncryptedName:(nullable NSString *)noEncryptName;
@end

NS_ASSUME_NONNULL_END
