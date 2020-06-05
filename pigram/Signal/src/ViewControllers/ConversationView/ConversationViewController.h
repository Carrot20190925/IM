//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import <SignalMessaging/OWSViewController.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ConversationViewAction) {
    ConversationViewActionNone,
    ConversationViewActionCompose,
    ConversationViewActionAudioCall,
    ConversationViewActionVideoCall,
};

@class TSInteraction;
@class TSThread;

@interface ConversationViewController : OWSViewController
@property (nonatomic, readonly) TSThread *thread;
//公告内容
@property (weak, nonatomic) UITextView* noticeContentTextView;
//展示最新公告的view
@property (strong, nonatomic) UIView* lastNoticeView;
#pragma mark -- 更新公告栏

//- (void)updateAnnouncementView;
- (void)configureForThread:(TSThread *)thread
                    action:(ConversationViewAction)action
            focusMessageId:(nullable NSString *)focusMessageId;

- (void)popKeyBoard;

- (void)scrollToFirstUnreadMessage:(BOOL)isAnimated;

#pragma mark 3D Touch Methods

- (void)peekSetup;
- (void)popped;

@end

#pragma mark - Internal Methods. Used in extensions

@class ConversationCollectionView;
@class ConversationViewModel;
@class SDSDatabaseStorage;

@interface ConversationViewController (Internal)

@property (nonatomic, readonly) ConversationCollectionView *collectionView;
@property (nonatomic, readonly) ConversationViewModel *conversationViewModel;
@property (nonatomic, readonly) SDSDatabaseStorage *databaseStorage;

@end

NS_ASSUME_NONNULL_END
