//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSSignalService.h"
#import "NSNotificationCenter+OWS.h"
#import "OWSCensorshipConfiguration.h"
#import "OWSError.h"
#import "OWSHTTPSecurityPolicy.h"
#import "TSAccountManager.h"
#import "TSConstants.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

#import <ifaddrs.h>
#import <resolv.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <netdb.h>
#import <netinet/ip.h>
#import <net/ethernet.h>
#import <net/if_dl.h>

NS_ASSUME_NONNULL_BEGIN

NSString *const kisCensorshipCircumventionManuallyActivatedKey
    = @"kTSStorageManager_isCensorshipCircumventionManuallyActivated";
NSString *const kisCensorshipCircumventionManuallyDisabledKey
    = @"kTSStorageManager_isCensorshipCircumventionManuallyDisabled";
NSString *const kManualCensorshipCircumventionCountryCodeKey
    = @"kTSStorageManager_ManualCensorshipCircumventionCountryCode";

NSString *const kNSNotificationName_IsCensorshipCircumventionActiveDidChange =
    @"kNSNotificationName_IsCensorshipCircumventionActiveDidChange";

@interface OWSSignalService ()<OWSSignalServiceProtocol>

@property (atomic) BOOL hasCensoredPhoneNumber;

@property (atomic) BOOL isCensorshipCircumventionActive;

@end

#pragma mark -

@implementation OWSSignalService

#pragma mark - Dependencies

- (SDSDatabaseStorage *)databaseStorage
{
    return SDSDatabaseStorage.shared;
}

#pragma mark -

- (SDSKeyValueStore *)keyValueStore
{
    return [[SDSKeyValueStore alloc] initWithCollection:@"kTSStorageManager_OWSSignalService"];
}

#pragma mark -


@synthesize isCensorshipCircumventionActive = _isCensorshipCircumventionActive;

+ (instancetype)sharedInstance
{
    static OWSSignalService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initDefault];
    });
    return sharedInstance;
}

- (instancetype)initDefault
{
    self = [super init];
    if (!self) {
        return self;
    }

    [self observeNotifications];

    [self updateHasCensoredPhoneNumber];
    [self updateIsCensorshipCircumventionActive];

    OWSSingletonAssert();

    return self;
}

- (void)observeNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registrationStateDidChange:)
                                                 name:RegistrationStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localNumberDidChange:)
                                                 name:kNSNotificationName_LocalNumberDidChange
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateHasCensoredPhoneNumber
{
    NSString *localNumber = [TSAccountManager localNumber];

    if (localNumber) {
        self.hasCensoredPhoneNumber = [OWSCensorshipConfiguration isCensoredPhoneNumber:localNumber];
    } else {
        OWSLogError(@"no known phone number to check for censorship.");
        self.hasCensoredPhoneNumber = NO;
    }

    [self updateIsCensorshipCircumventionActive];
}

- (BOOL)isCensorshipCircumventionManuallyActivated
{
    __block BOOL result;
    [self.databaseStorage readWithBlock:^(SDSAnyReadTransaction *transaction) {
        result = [self.keyValueStore getBool:kisCensorshipCircumventionManuallyActivatedKey
                                defaultValue:NO
                                 transaction:transaction];
    }];
    return result;
}

- (void)setIsCensorshipCircumventionManuallyActivated:(BOOL)value
{
    [self.databaseStorage writeWithBlock:^(SDSAnyWriteTransaction *transaction) {
        [self.keyValueStore setBool:value key:kisCensorshipCircumventionManuallyActivatedKey transaction:transaction];
    }];

    [self updateIsCensorshipCircumventionActive];
}

- (BOOL)isCensorshipCircumventionManuallyDisabled
{
    __block BOOL result;
    [self.databaseStorage readWithBlock:^(SDSAnyReadTransaction *transaction) {
        result = [self.keyValueStore getBool:kisCensorshipCircumventionManuallyDisabledKey
                                defaultValue:NO
                                 transaction:transaction];
    }];
    return result;
}

- (void)setIsCensorshipCircumventionManuallyDisabled:(BOOL)value
{
    [self.databaseStorage writeWithBlock:^(SDSAnyWriteTransaction *transaction) {
        [self.keyValueStore setBool:value key:kisCensorshipCircumventionManuallyDisabledKey transaction:transaction];
    }];

    [self updateIsCensorshipCircumventionActive];
}


- (void)updateIsCensorshipCircumventionActive
{
    if (self.isCensorshipCircumventionManuallyDisabled) {
        self.isCensorshipCircumventionActive = NO;
    } else if (self.isCensorshipCircumventionManuallyActivated) {
        self.isCensorshipCircumventionActive = YES;
    } else if (self.hasCensoredPhoneNumber) {
        self.isCensorshipCircumventionActive = YES;
    } else {
        self.isCensorshipCircumventionActive = NO;
    }
}

- (void)setIsCensorshipCircumventionActive:(BOOL)isCensorshipCircumventionActive
{
    @synchronized(self)
    {
        if (_isCensorshipCircumventionActive == isCensorshipCircumventionActive) {
            return;
        }

        _isCensorshipCircumventionActive = isCensorshipCircumventionActive;
    }

    [[NSNotificationCenter defaultCenter]
        postNotificationNameAsync:kNSNotificationName_IsCensorshipCircumventionActiveDidChange
                           object:nil
                         userInfo:nil];
}

- (BOOL)isCensorshipCircumventionActive
{
    @synchronized(self)
    {
        return _isCensorshipCircumventionActive;
    }
}

- (NSURL *)domainFrontBaseURL
{
    OWSAssertDebug(self.isCensorshipCircumventionActive);
    OWSCensorshipConfiguration *censorshipConfiguration = [self buildCensorshipConfiguration];
    return censorshipConfiguration.domainFrontBaseURL;
}

- (AFHTTPSessionManager *)buildSignalServiceSessionManager
{
    if (self.isCensorshipCircumventionActive) {
        OWSCensorshipConfiguration *censorshipConfiguration = [self buildCensorshipConfiguration];
        OWSLogInfo(@"using reflector HTTPSessionManager via: %@", censorshipConfiguration.domainFrontBaseURL);
        return [self reflectorSignalServiceSessionManagerWithCensorshipConfiguration:censorshipConfiguration];
    } else {
        return self.defaultSignalServiceSessionManager;
    }
}

- (AFHTTPSessionManager *)defaultSignalServiceSessionManager
{
    NSURL *baseURL = [[NSURL alloc] initWithString:textSecureServerURL];
    OWSAssertDebug(baseURL);
    NSURLSessionConfiguration *sessionConf = NSURLSessionConfiguration.ephemeralSessionConfiguration;
    AFHTTPSessionManager *sessionManager =
        [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:sessionConf];

//    sessionManager.securityPolicy = [OWSHTTPSecurityPolicy sharedPolicy];
//    sessionManager.securityPolicy.allowInvalidCertificates = false;
//    sessionManager.securityPolicy.validatesDomainName = false;
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    // Disable default cookie handling for all requests.
    sessionManager.requestSerializer.HTTPShouldHandleCookies = NO;

    [sessionManager.requestSerializer setValue:[self getIPAddress:YES] forHTTPHeaderField:@"X-Forwarded-For"];
    [sessionManager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"X-Signal-Agent"];

    return sessionManager;
}

- (AFHTTPSessionManager *)reflectorSignalServiceSessionManagerWithCensorshipConfiguration:
    (OWSCensorshipConfiguration *)censorshipConfiguration
{
    NSURLSessionConfiguration *sessionConf = NSURLSessionConfiguration.ephemeralSessionConfiguration;

    NSURL *frontingURL = censorshipConfiguration.domainFrontBaseURL;
    NSURL *baseURL = [frontingURL URLByAppendingPathComponent:serviceCensorshipPrefix];
    AFHTTPSessionManager *sessionManager =
        [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:sessionConf];

//    sessionManager.securityPolicy = censorshipConfiguration.domainFrontSecurityPolicy;

    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [sessionManager.requestSerializer setValue:censorshipConfiguration.signalServiceReflectorHost
                            forHTTPHeaderField:@"Host"];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    // Disable default cookie handling for all requests.
    sessionManager.requestSerializer.HTTPShouldHandleCookies = NO;

    return sessionManager;
}

#pragma mark - Profile Uploading

- (AFHTTPSessionManager *)CDNSessionManager
{
    AFHTTPSessionManager *result;
    if (self.isCensorshipCircumventionActive) {
        OWSCensorshipConfiguration *censorshipConfiguration = [self buildCensorshipConfiguration];
        OWSLogInfo(@"using reflector CDNSessionManager via: %@", censorshipConfiguration.domainFrontBaseURL);
        result = [self reflectorCDNSessionManagerWithCensorshipConfiguration:censorshipConfiguration];
    } else {
        result = self.defaultCDNSessionManager;
    }
    // By default, CDN content should be binary.
    result.responseSerializer = [AFHTTPResponseSerializer serializer];
    return result;
}

- (AFHTTPSessionManager *)defaultCDNSessionManager
{
    
    NSURL *baseURL = [[NSURL alloc] initWithString:[self getCDNServer]];
    OWSAssertDebug(baseURL);
    
    NSURLSessionConfiguration *sessionConf = NSURLSessionConfiguration.ephemeralSessionConfiguration;
    AFHTTPSessionManager *sessionManager =
        [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:sessionConf];

//    sessionManager.securityPolicy = [OWSHTTPSecurityPolicy sharedPolicy];
    
    // Default acceptable content headers are rejected by AWS
    sessionManager.responseSerializer.acceptableContentTypes = nil;

    [sessionManager.requestSerializer setValue:[self getIPAddress:YES] forHTTPHeaderField:@"X-Forwarded-For"];
    [sessionManager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"X-Signal-Agent"];

    return sessionManager;
}

- (AFHTTPSessionManager *)reflectorCDNSessionManagerWithCensorshipConfiguration:
    (OWSCensorshipConfiguration *)censorshipConfiguration
{
    NSURLSessionConfiguration *sessionConf = NSURLSessionConfiguration.ephemeralSessionConfiguration;

    NSURL *frontingURL = censorshipConfiguration.domainFrontBaseURL;
    NSURL *baseURL = [frontingURL URLByAppendingPathComponent:cdnCensorshipPrefix];
    AFHTTPSessionManager *sessionManager =
        [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:sessionConf];

//    sessionManager.securityPolicy = censorshipConfiguration.domainFrontSecurityPolicy;

    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [sessionManager.requestSerializer setValue:censorshipConfiguration.CDNReflectorHost forHTTPHeaderField:@"Host"];

    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];

    return sessionManager;
}

#pragma mark - Storage Service

- (AFHTTPSessionManager *)storageServiceSessionManager
{
    NSURL *baseURL = [[NSURL alloc] initWithString:storageServiceURL];
    OWSAssertDebug(baseURL);

    NSURLSessionConfiguration *sessionConf = NSURLSessionConfiguration.ephemeralSessionConfiguration;
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL
                                                                    sessionConfiguration:sessionConf];

//    sessionManager.securityPolicy = [OWSHTTPSecurityPolicy sharedPolicy];
    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];

    // Disable default cookie handling for all requests.
    sessionManager.requestSerializer.HTTPShouldHandleCookies = NO;

    return sessionManager;
}

#pragma mark - Events

- (void)registrationStateDidChange:(NSNotification *)notification
{
    [self updateHasCensoredPhoneNumber];
}

- (void)localNumberDidChange:(NSNotification *)notification
{
    [self updateHasCensoredPhoneNumber];
}

#pragma mark - Manual Censorship Circumvention

- (OWSCensorshipConfiguration *)buildCensorshipConfiguration
{
    OWSAssertDebug(self.isCensorshipCircumventionActive);

    if (self.isCensorshipCircumventionManuallyActivated) {
        NSString *countryCode = self.manualCensorshipCircumventionCountryCode;
        if (countryCode.length == 0) {
            OWSFailDebug(@"manualCensorshipCircumventionCountryCode was unexpectedly 0");
        }

        OWSCensorshipConfiguration *configuration =
            [OWSCensorshipConfiguration censorshipConfigurationWithCountryCode:countryCode];
        OWSAssertDebug(configuration);

        return configuration;
    }

    OWSCensorshipConfiguration *_Nullable configuration =
        [OWSCensorshipConfiguration censorshipConfigurationWithPhoneNumber:TSAccountManager.localNumber];
    if (configuration != nil) {
        return configuration;
    }

    return OWSCensorshipConfiguration.defaultConfiguration;
}

- (nullable NSString *)manualCensorshipCircumventionCountryCode
{
    __block NSString *_Nullable result;
    [self.databaseStorage readWithBlock:^(SDSAnyReadTransaction *transaction) {
        result = [self.keyValueStore getString:kManualCensorshipCircumventionCountryCodeKey transaction:transaction];
    }];
    return result;
}

- (void)setManualCensorshipCircumventionCountryCode:(nullable NSString *)value
{
    [self.databaseStorage writeWithBlock:^(SDSAnyWriteTransaction *transaction) {
        [self.keyValueStore setString:value key:kManualCensorshipCircumventionCountryCodeKey transaction:transaction];
    }];
}


#pragma mark 获取本机ip地址

/*
 * 获取设备当前网络IP地址
 */
#define MDNS_PORT       5353
#define QUERY_NAME      "_apple-mobdev2._tcp.local"
#define DUMMY_MAC_ADDR  @"02:00:00:00:00:00"
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddr];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        address = addresses[key];
        //筛选出IP地址格式
        if([self isValidatIP:address]) *stop = YES;
    }];
    return address ? address : @"127.0.0.1";
}
- (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        return firstMatch;
    }
    return NO;
}

- (NSDictionary *)getIPAddr
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end

NS_ASSUME_NONNULL_END
