//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class ECKeyPair;
@class OWSDevice;
@class PreKeyRecord;
@class SMKUDAccessKey;
@class SignalServiceAddress;
@class SignedPreKeyRecord;
@class TSRequest;
@class SSKProtoEnvelope;

typedef NS_ENUM(NSUInteger, RemoteAttestationService);
typedef NS_ENUM(NSUInteger, TSVerificationTransport) { TSVerificationTransportVoice = 1, TSVerificationTransportSMS };

@interface OWSRequestFactory : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (TSRequest *)enable2FARequestWithPin:(NSString *)pin;

+ (TSRequest *)disable2FARequest;

+ (TSRequest *)enableRegistrationLockV2RequestWithToken:(NSString *)token;

+ (TSRequest *)disableRegistrationLockV2Request;

+ (TSRequest *)acknowledgeMessageDeliveryRequestWithAddress:(SignalServiceAddress *)address timestamp:(UInt64)timestamp;
/**
 * 拉取离线消息后 对该消息进行应答  服务器离线缓存会清除这个消息
 */
+ (TSRequest *)acknowledgeMessageDeliveryRequestWithServerGuid:(NSString *)serverGuid;

/**
 * 批量ack 拉取离线消息后 对该消息进行应答  服务器离线缓存会清除这个消息
 */
+ (TSRequest *)acknowledgeMessagesDeliveryRequestWithEnvelopes:(NSArray <SSKProtoEnvelope *> *)envelopes;

+ (TSRequest *)deleteDeviceRequestWithDevice:(OWSDevice *)device;

+ (TSRequest *)deviceProvisioningCodeRequest;

+ (TSRequest *)deviceProvisioningRequestWithMessageBody:(NSData *)messageBody ephemeralDeviceId:(NSString *)deviceId;

+ (TSRequest *)getDevicesRequest;

+ (TSRequest *)getMessagesRequest;

+ (TSRequest *)getProfileRequestWithAddress:(SignalServiceAddress *)address
                                udAccessKey:(nullable SMKUDAccessKey *)udAccessKey
    NS_SWIFT_NAME(getProfileRequest(address:udAccessKey:));

+ (TSRequest *)turnServerInfoRequest;

+ (TSRequest *)allocAttachmentRequest;

+ (TSRequest *)contactsIntersectionRequestWithHashesArray:(NSArray<NSString *> *)hashes;

+ (TSRequest *)profileAvatarUploadFormRequest;

+ (TSRequest *)registerForPushRequestWithPushIdentifier:(NSString *)identifier voipIdentifier:(NSString *)voipId;

//+ (TSRequest *)updateAttributesRequest;

+ (TSRequest *)accountWhoAmIRequest;

+ (TSRequest *)unregisterAccountRequest;

+ (TSRequest *)requestPreauthChallengeRequestWithRecipientId:(NSString *)recipientId
                                                   pushToken:(NSString *)pushToken
    NS_SWIFT_NAME(requestPreauthChallengeRequest(recipientId:pushToken:));

+ (TSRequest *)requestVerificationCodeRequestWithPhoneNumber:(NSString *)phoneNumber
                                            preauthChallenge:(nullable NSString *)preauthChallenge
                                                captchaToken:(nullable NSString *)captchaToken
                                                   transport:(TSVerificationTransport)transport;

+ (TSRequest *)submitMessageRequestWithAddress:(SignalServiceAddress *)recipientAddress
                                      messages:(NSArray *)messages
                                     timeStamp:(uint64_t)timeStamp
                                   udAccessKey:(nullable SMKUDAccessKey *)udAccessKey;

/*
 * 为了服务器能够解开数据，向服务多传输一份未加密的protobuf数据  hansen
 */
+ (TSRequest *)submitMessageRequestWithAddress:(SignalServiceAddress *)recipientAddress
   messages:(NSArray *)messages
  timeStamp:(uint64_t)timeStamp
udAccessKey:(nullable SMKUDAccessKey *)udAccessKey unencrypted:(NSData *)plainText;


+ (TSRequest *)verifyCodeRequestWithVerificationCode:(NSString *)verificationCode
                                           forNumber:(NSString *)phoneNumber
                                                 pin:(nullable NSString *)pin
                                             authKey:(NSString *)authKey;

#pragma mark - carrot 新增接口 begin
//验证码验证
+ (TSRequest *)txVerifyCodeRequestWithVerificationCode:(NSString *)verificationCode
                                             forNumber:(NSString *)phoneNumber
                                                   pin:(nullable NSString *)pin
                                           authKey:(NSString *)authKey;
//密码登录    
+ (TSRequest *)txLoginPassword:(NSString *)password
                                forNumber:(NSString *)phoneNumber
                                pin:(nullable NSString *)pin
                       authKey:(NSString *)authKey;

//注册账号
+ (TSRequest *)txRegisterWithNickName:(NSURL *)urlName
                            forNumber:(NSString *)phoneNumber
                                  pin:(nullable NSString *)pin
                              authKey:(NSString *)authKey;
//验证码登录接口
+ (TSRequest *)txLoginVerificationCode:(NSString *)verificationCode
                             forNumber:(NSString *)phoneNumber
                                   pin:(nullable NSString *)pin
                               authKey:(NSString *)authKey;
//设置密码
+ (TSRequest *)txSetupPassword:(NSString *)password
                                forNumber:(NSString *)phoneNumber
                                    pin:(nullable NSString *)pin
                                 authKey:(NSString *)authKey;

//注册接口
+ (TSRequest *)txVerifyCodeRequestWithVerificationCode:(NSString *)verificationCode
                                           forNumber:(NSString *)phoneNumber
                                                 pin:(nullable NSString *)pin
                                             authKey:(NSString *)authKey
                                           profileName:(NSString *)profileName;

#pragma mark - carrot 新增接口 end

#pragma mark - Prekeys

+ (TSRequest *)availablePreKeysCountRequest;

+ (TSRequest *)currentSignedPreKeyRequest;

+ (TSRequest *)recipientPreKeyRequestWithAddress:(SignalServiceAddress *)recipientAddress
                                        deviceId:(NSString *)deviceId
                                     udAccessKey:(nullable SMKUDAccessKey *)udAccessKey;

+ (TSRequest *)registerSignedPrekeyRequestWithSignedPreKeyRecord:(SignedPreKeyRecord *)signedPreKey;

+ (TSRequest *)registerPrekeysRequestWithPrekeyArray:(NSArray *)prekeys
                                         identityKey:(NSData *)identityKeyPublic
                                        signedPreKey:(SignedPreKeyRecord *)signedPreKey;

#pragma mark - Storage Service

+ (TSRequest *)storageAuthRequest;

#pragma mark - Remote Attestation

+ (TSRequest *)remoteAttestationRequestForService:(RemoteAttestationService)service
                                      withKeyPair:(ECKeyPair *)keyPair
                                      enclaveName:(NSString *)enclaveName
                                     authUsername:(NSString *)authUsername
                                     authPassword:(NSString *)authPassword;

+ (TSRequest *)remoteAttestationAuthRequestForService:(RemoteAttestationService)service;

#pragma mark - CDS

+ (TSRequest *)cdsEnclaveRequestWithRequestId:(NSData *)requestId
                                 addressCount:(NSUInteger)addressCount
                         encryptedAddressData:(NSData *)encryptedAddressData
                                      cryptIv:(NSData *)cryptIv
                                     cryptMac:(NSData *)cryptMac
                                  enclaveName:(NSString *)enclaveName
                                 authUsername:(NSString *)authUsername
                                 authPassword:(NSString *)authPassword
                                      cookies:(NSArray<NSHTTPCookie *> *)cookies;
+ (TSRequest *)cdsFeedbackRequestWithStatus:(NSString *)status
                                     reason:(nullable NSString *)reason NS_SWIFT_NAME(cdsFeedbackRequest(status:reason:));

#pragma mark - KBS

+ (TSRequest *)kbsEnclaveNonceRequestWithEnclaveName:(NSString *)enclaveName
                                        authUsername:(NSString *)authUsername
                                        authPassword:(NSString *)authPassword
                                             cookies:(NSArray<NSHTTPCookie *> *)cookies;

+ (TSRequest *)kbsEnclaveRequestWithRequestId:(NSData *)requestId
                                         data:(NSData *)data
                                      cryptIv:(NSData *)cryptIv
                                     cryptMac:(NSData *)cryptMac
                                  enclaveName:(NSString *)enclaveName
                                 authUsername:(NSString *)authUsername
                                 authPassword:(NSString *)authPassword
                                      cookies:(NSArray<NSHTTPCookie *> *)cookies;

#pragma mark - UD

+ (TSRequest *)udSenderCertificateRequest;

#pragma mark - Usernames

+ (TSRequest *)usernameSetRequest:(NSString *)username;
+ (TSRequest *)usernameDeleteRequest;
+ (TSRequest *)getProfileRequestWithUsername:(NSString *)username;

///群头像
+ (TSRequest *)groupAvatarRequest:(NSString *)formkey group_id:(NSString *)group_id;


@end

NS_ASSUME_NONNULL_END
