//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import "YAPDBMessageContentOfflineJobFinder.h"
#import "OWSBatchMessageProcessor.h"
#import "OWSStorage.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>
#import <YapDatabase/YapDatabaseAutoView.h>
#import <YapDatabase/YapDatabaseTransaction.h>
#import <YapDatabase/YapDatabaseViewTypes.h>

NSString *const YAPDBMessageContentJobFinderExtensionNameOffline = @"OWSMessageContentOfflineJobFinderExtensionName2Offline";
NSString *const YAPDBMessageContentJobFinderExtensionGroupOffline = @"OWSMessageContentOfflineJobFinderExtensionGroup2Offline";

@implementation YAPDBMessageContentOfflineJobFinder

- (NSArray<OWSMessageContentOfflineJob *> *)nextJobsForBatchSize:(NSUInteger)maxBatchSize
                                              transaction:(YapDatabaseReadTransaction *)transaction
{
    NSMutableArray<OWSMessageContentOfflineJob *> *jobs = [NSMutableArray new];
    YapDatabaseViewTransaction *viewTransaction = [transaction ext:YAPDBMessageContentJobFinderExtensionNameOffline];
    OWSAssertDebug(viewTransaction != nil);
    [viewTransaction enumerateKeysAndObjectsInGroup:YAPDBMessageContentJobFinderExtensionGroupOffline
                                         usingBlock:^(NSString *_Nonnull collection,
                                             NSString *_Nonnull key,
                                             id _Nonnull object,
                                             NSUInteger index,
                                             BOOL *_Nonnull stop) {
                                             OWSMessageContentOfflineJob *job = object;
                                             [jobs addObject:job];
                                             if (jobs.count >= maxBatchSize) {
                                                 *stop = YES;
                                             }
                                         }];

    return [jobs copy];
}

- (void)addJobWithEnvelopeData:(NSData *)envelopeData
                 plaintextData:(NSData *_Nullable)plaintextData
               wasReceivedByUD:(BOOL)wasReceivedByUD
                   transaction:(YapDatabaseReadWriteTransaction *)transaction
{
    OWSAssertDebug(envelopeData);
    OWSAssertDebug(transaction);

    OWSMessageContentOfflineJob *job = [[OWSMessageContentOfflineJob alloc] initWithEnvelopeData:envelopeData
                                                                     plaintextData:plaintextData
                                                                   wasReceivedByUD:wasReceivedByUD];
    [job anyInsertWithTransaction:transaction.asAnyWrite];
}

- (void)removeJobsWithIds:(NSArray<NSString *> *)uniqueIds transaction:(YapDatabaseReadWriteTransaction *)transaction
{
    [transaction removeObjectsForKeys:uniqueIds inCollection:[OWSMessageContentOfflineJob collection]];
}

+ (YapDatabaseView *)databaseExtension
{
    YapDatabaseViewSorting *sorting =
        [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(YapDatabaseReadTransaction *transaction,
            NSString *group,
            NSString *collection1,
            NSString *key1,
            id object1,
            NSString *collection2,
            NSString *key2,
            id object2) {
            if (![object1 isKindOfClass:[OWSMessageContentOfflineJob class]]) {
                OWSFailDebug(@"Unexpected object: %@ in collection: %@", [object1 class], collection1);
                return NSOrderedSame;
            }
            OWSMessageContentOfflineJob *job1 = (OWSMessageContentOfflineJob *)object1;

            if (![object2 isKindOfClass:[OWSMessageContentOfflineJob class]]) {
                OWSFailDebug(@"Unexpected object: %@ in collection: %@", [object2 class], collection2);
                return NSOrderedSame;
            }
            OWSMessageContentOfflineJob *job2 = (OWSMessageContentOfflineJob *)object2;

            return [job1.createdAt compare:job2.createdAt];
        }];

    YapDatabaseViewGrouping *grouping =
        [YapDatabaseViewGrouping withObjectBlock:^NSString *_Nullable(YapDatabaseReadTransaction *_Nonnull transaction,
            NSString *_Nonnull collection,
            NSString *_Nonnull key,
            id _Nonnull object) {
            if (![object isKindOfClass:[OWSMessageContentOfflineJob class]]) {
                OWSFailDebug(@"Unexpected object: %@ in collection: %@", object, collection);
                return nil;
            }

            // Arbitrary string - all in the same group. We're only using the view for sorting.
            return YAPDBMessageContentJobFinderExtensionGroupOffline;
        }];

    YapDatabaseViewOptions *options = [YapDatabaseViewOptions new];
    options.allowedCollections =
        [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithObject:[OWSMessageContentOfflineJob collection]]];

    return [[YapDatabaseAutoView alloc] initWithGrouping:grouping sorting:sorting versionTag:@"1" options:options];
}

+ (void)asyncRegisterDatabaseExtension:(OWSStorage *)storage
{
    YapDatabaseView *existingView = [storage registeredExtension:YAPDBMessageContentJobFinderExtensionNameOffline];
    if (existingView) {
        OWSFailDebug(@"%@ was already initialized.", YAPDBMessageContentJobFinderExtensionNameOffline);
        // already initialized
        return;
    }
    [storage asyncRegisterExtension:[self databaseExtension] withName:YAPDBMessageContentJobFinderExtensionNameOffline];
}


@end
