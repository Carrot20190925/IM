//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class OWSMessageContentJob;
@class OWSStorage;
@class YapDatabaseReadTransaction;
@class YapDatabaseReadWriteTransaction;

NS_ASSUME_NONNULL_BEGIN

@interface YAPDBMessageContentOfflineJobFinder : NSObject

- (NSArray<OWSMessageContentJob *> *)nextJobsForBatchSize:(NSUInteger)maxBatchSize
                                              transaction:(YapDatabaseReadTransaction *)transaction;

- (void)addJobWithEnvelopeData:(NSData *)envelopeData
                 plaintextData:(NSData *_Nullable)plaintextData
               wasReceivedByUD:(BOOL)wasReceivedByUD
                   transaction:(YapDatabaseReadWriteTransaction *)transaction;

- (void)removeJobsWithIds:(NSArray<NSString *> *)uniqueIds transaction:(YapDatabaseReadWriteTransaction *)transaction;

+ (void)asyncRegisterDatabaseExtension:(OWSStorage *)storage;


@end

NS_ASSUME_NONNULL_END
