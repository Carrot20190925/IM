//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

@class SignalServiceAddress;

@interface PGMessageServiceParam : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) TSWhisperMessageType type;
@property (nonatomic, readonly) int contentType;

@property (nonatomic, readonly) NSArray<NSString *> *destinations;
@property (nonatomic, readonly) int destinationDeviceId;

@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) BOOL online;
@property (nonatomic, readonly) NSTimeInterval timestamp;


/**
 * contentType == PGMessageContentType
 */
- (instancetype)initWithType:(TSWhisperMessageType)type
                    messageType:(int)contentType
                     destinations:(NSArray<NSString *> *)destinations
                      device:(int)deviceId
                     content:(NSData *)content
                    isOnline:(BOOL)isOnline
                    timestamp:(NSTimeInterval)timestamp;
@end

NS_ASSUME_NONNULL_END
