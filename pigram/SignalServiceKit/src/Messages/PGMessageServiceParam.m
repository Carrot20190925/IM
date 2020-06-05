//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import "PGMessageServiceParam.h"
#import "TSConstants.h"
#import <SignalCoreKit/NSData+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

@implementation PGMessageServiceParam

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return [NSDictionary mtl_identityPropertyMapWithModel:[self class]];
}

- (instancetype)initWithType:(TSWhisperMessageType)type messageType:(PGMessageContentType)contentType destinations:(NSArray<NSString *> *)destinations device:(int)deviceId content:(NSData *)content isOnline:(BOOL)isOnline timestamp:(NSTimeInterval)timestamp
{
    self = [super init];

    if (!self) {
        return self;
    }

    _type = type;
    _contentType = contentType;
    _destinations = destinations;
    OWSAssertDebug(_destinations != nil);
    _destinationDeviceId = deviceId;
    _content = [content base64EncodedString];
    _online = isOnline;
    _timestamp = timestamp;

    return self;
}
@end
