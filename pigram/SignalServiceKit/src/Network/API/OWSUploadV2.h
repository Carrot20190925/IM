//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/AnyPromise.h>

NS_ASSUME_NONNULL_BEGIN

@class AnyPromise;
@class TSAttachmentStream;

typedef void (^UploadProgressBlock)(NSProgress *progress);

// A strong reference should be maintained to this object
// until it completes.  If it is deallocated, the upload
// may be cancelled.
//
// This class can be safely accessed and used from any thread.
@interface OWSAvatarUploadV2 : NSObject

// This property is set on success for non-nil uploads.
@property (nonatomic, nullable) NSString *urlPath;

- (AnyPromise *)uploadAvatarToService:(NSData *_Nullable)avatarData
                     clearLocalAvatar:(dispatch_block_t)clearLocalAvatar
                        progressBlock:(UploadProgressBlock)progressBlock;


//- (AnyPromise *)uploadGroupAvatarToService:(NSData *_Nullable)avatarData
//clearLocalAvatar:(dispatch_block_t)clearLocalAvatar
//   progressBlock:(UploadProgressBlock)progressBlock;
@end

@protocol OWSAttachmentUploadV2Protocol <NSObject>
@optional
- (void)uploadFile:(NSData *)data name: (NSString*)name resovel:(PMKResolver) resolve  progressBlock:(UploadProgressBlock)progressBlock;
@end

#pragma mark -

// A strong reference should be maintained to this object
// until it completes.  If it is deallocated, the upload
// may be cancelled.
//
// This class can be safely accessed and used from any thread.
@interface OWSAttachmentUploadV2 : NSObject

// These properties are set on success.
@property (nonatomic, nullable) NSData *encryptionKey;
@property (nonatomic, nullable) NSData *digest;
@property (nonatomic) UInt64 serverId;

- (AnyPromise *)uploadAttachmentToService:(TSAttachmentStream *)attachmentStream
                            progressBlock:(UploadProgressBlock)progressBlock;
- (AnyPromise *)uploadGroupAvatarToService:(NSData *)avatarData clearLocalAvatar:(dispatch_block_t)clearLocalAvatar progressBlock:(UploadProgressBlock)progressBlock group_id:(NSString *)group_id;
@end

NS_ASSUME_NONNULL_END
