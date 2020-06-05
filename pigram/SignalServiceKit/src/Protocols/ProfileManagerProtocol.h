//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

@class OWSAES256Key;
@class SDSAnyReadTransaction;
@class SDSAnyWriteTransaction;
@class SignalServiceAddress;
@class TSThread;

NS_ASSUME_NONNULL_BEGIN

@protocol ProfileManagerProtocol <NSObject>

- (OWSAES256Key *)localProfileKey;

- (nullable NSData *)profileKeyDataForAddress:(SignalServiceAddress *)address
                                  transaction:(SDSAnyReadTransaction *)transaction;
- (void)setProfileKeyData:(NSData *)profileKeyData
               forAddress:(SignalServiceAddress *)address
              transaction:(SDSAnyWriteTransaction *)transaction;

- (BOOL)isUserInProfileWhitelist:(SignalServiceAddress *)address transaction:(SDSAnyReadTransaction *)transaction;

- (BOOL)isThreadInProfileWhitelist:(TSThread *)thread transaction:(SDSAnyReadTransaction *)transaction;

- (void)addUserToProfileWhitelist:(SignalServiceAddress *)address;
- (void)addGroupIdToProfileWhitelist:(NSString *)groupId;

- (void)fetchLocalUsersProfile;

- (void)fetchProfileForAddress:(SignalServiceAddress *)address;

- (void)warmCaches;

- (nullable NSString *)localProfileName;

- (NSString *)txGetEncodeProfileNameWithNickName:(NSString *)nickName;////新增暴露接口
@end

NS_ASSUME_NONNULL_END
