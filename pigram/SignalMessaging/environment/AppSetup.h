//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

// This is _NOT_ a singleton and will be instantiated each time that the SAE is used.
@interface AppSetup : NSObject

+ (void)setupEnvironmentWithAppSpecificSingletonBlock:(dispatch_block_t)appSpecificSingletonBlock
                                  migrationCompletion:(dispatch_block_t)migrationCompletion;


/**
 * 退出登录从新 设置数据库
 */
+ (void)resetDatabase;
@end

NS_ASSUME_NONNULL_END
