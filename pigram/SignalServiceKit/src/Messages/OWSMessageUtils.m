//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSMessageUtils.h"
#import "AppContext.h"
#import "MIMETypeUtil.h"
#import "OWSMessageSender.h"
#import "TSAccountManager.h"
#import "TSAttachment.h"
#import "TSAttachmentStream.h"
#import "TSIncomingMessage.h"
#import "TSMessage.h"
#import "TSOutgoingMessage.h"
#import "TSQuotedMessage.h"
#import "TSThread.h"
#import "UIImage+OWS.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

#define kMaxMessageCount 2000

@implementation OWSMessageUtils

#pragma mark - Dependencies

- (SDSDatabaseStorage *)databaseStorage
{
    return SDSDatabaseStorage.shared;
}

#pragma mark -

+ (instancetype)sharedManager
{
    static OWSMessageUtils *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [self new];
    });
    return sharedMyManager;
}

- (instancetype)init
{
    self = [super init];

    if (!self) {
        return self;
    }

    OWSSingletonAssert();

    return self;
}

- (NSUInteger)unreadMessagesCount
{
    __block NSUInteger numberOfItems;
    [self.databaseStorage readWithBlock:^(SDSAnyReadTransaction *transaction) {
        numberOfItems = [InteractionFinder unreadCountInAllThreadsWithTransaction:transaction];
    }];

    return numberOfItems;
}

- (NSUInteger)unreadMessagesCountExcept:(TSThread *)thread
{
    __block NSUInteger numberOfItems;
    [self.databaseStorage readWithBlock:^(SDSAnyReadTransaction *transaction) {
        NSUInteger allCount = [InteractionFinder unreadCountInAllThreadsWithTransaction:transaction];
        InteractionFinder *interactionFinder = [[InteractionFinder alloc] initWithThreadUniqueId:thread.uniqueId];
        NSUInteger threadCount = [interactionFinder unreadCountWithTransaction:transaction];
        numberOfItems = (allCount - threadCount);
    }];

    return numberOfItems;
}

- (void)updateApplicationBadgeCount
{
    if (!CurrentAppContext().isMainApp) {
        return;
    }

    NSUInteger numberOfItems = [self unreadMessagesCount];
    [CurrentAppContext() setMainAppBadgeNumber:numberOfItems];
}

+ (void)clearEveryThreadRedundancyMessages {
    
    NSCalendar  *calendar = [[NSCalendar  alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents  *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDate *now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    NSString *key = [NSString stringWithFormat:@"%ld-%ld-%ld",comps.year,comps.month, comps.day];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:key] length] > 0) {
        return;
    }
        
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [SSKEnvironment.shared.databaseStorage asyncReadWithBlock:^(SDSAnyReadTransaction * _Nonnull read) {
            NSArray *threads = [TSThread anyFetchAllWithTransaction:read];
            for (TSThread *thread in threads) {
                InteractionFinder *finder = [[InteractionFinder alloc] initWithThreadUniqueId:thread.uniqueId];
                NSInteger allCount = [finder countWithTransaction:read];
                if (allCount > kMaxMessageCount) {
                    NSMutableArray *threadMessages = @[].mutableCopy;
                    [finder enumerateInteractionsWithTransaction:read error:nil block:^(TSInteraction * _Nonnull interaction, BOOL * _Nonnull stop) {
                        [threadMessages addObject:interaction];
                    }];
                    [threadMessages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        return [obj1 compareServerTimestampWithOther:obj2];
                    }];
                    NSArray *deleteMessages = [threadMessages subarrayWithRange:NSMakeRange(0, allCount - kMaxMessageCount)];
                    
                    [SSKEnvironment.shared.databaseStorage asyncWriteWithBlock:^(SDSAnyWriteTransaction * _Nonnull write) {
                        [deleteMessages enumerateObjectsUsingBlock:^(TSInteraction  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [obj anyRemoveWithTransaction:write];
                        }];
                    }];
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:key];
                }
            }
        }];
    });
}

@end

NS_ASSUME_NONNULL_END
