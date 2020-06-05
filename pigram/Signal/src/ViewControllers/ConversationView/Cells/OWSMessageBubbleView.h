//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSMessageView.h"

NS_ASSUME_NONNULL_BEGIN

@class ContactShareViewModel;
@class OWSContact;
@class OWSLayerView;
@class OWSLinkPreview;
@class OWSMessageFooterView;
@class OWSQuotedReplyModel;
@class StickerPackInfo;
@class TSAttachmentPointer;
@class TSAttachmentStream;
@class TSOutgoingMessage;

@protocol OWSMessageBubbleViewDelegate

/**
 * 长按图片
 */
@optional
- (void)didLongPressImageViewItem:(id<ConversationViewItem>)viewItem
attachmentStream:(TSAttachmentStream *)attachmentStream
       imageView:(UIView *)imageView;

@required
//点击分享的名片
- (void)didTapPigramShareItem:(id<ConversationViewItem>)viewItem;

- (void)didTapImageViewItem:(id<ConversationViewItem>)viewItem
           attachmentStream:(TSAttachmentStream *)attachmentStream
                  imageView:(UIView *)imageView;

- (void)didTapVideoViewItem:(id<ConversationViewItem>)viewItem
           attachmentStream:(TSAttachmentStream *)attachmentStream
                  imageView:(UIView *)imageView;

- (void)didTapAudioViewItem:(id<ConversationViewItem>)viewItem attachmentStream:(TSAttachmentStream *)attachmentStream;

- (void)didScrubAudioViewItem:(id<ConversationViewItem>)viewItem
                       toTime:(NSTimeInterval)time
             attachmentStream:(TSAttachmentStream *)attachmentStream;

- (void)didTapPdfForItem:(id<ConversationViewItem>)viewItem attachmentStream:(TSAttachmentStream *)attachmentStream;

- (void)didTapTruncatedTextMessage:(id<ConversationViewItem>)conversationItem;

- (void)didTapFailedIncomingAttachment:(id<ConversationViewItem>)viewItem;

- (void)didTapConversationItem:(id<ConversationViewItem>)viewItem quotedReply:(OWSQuotedReplyModel *)quotedReply;
- (void)didTapConversationItem:(id<ConversationViewItem>)viewItem
                                 quotedReply:(OWSQuotedReplyModel *)quotedReply
    failedThumbnailDownloadAttachmentPointer:(TSAttachmentPointer *)attachmentPointer;

- (void)didTapConversationItem:(id<ConversationViewItem>)viewItem linkPreview:(OWSLinkPreview *)linkPreview;

- (void)didTapContactShareViewItem:(id<ConversationViewItem>)viewItem;

- (void)didTapSendMessageToContactShare:(ContactShareViewModel *)contactShare
    NS_SWIFT_NAME(didTapSendMessage(toContactShare:));
- (void)didTapSendInviteToContactShare:(ContactShareViewModel *)contactShare
    NS_SWIFT_NAME(didTapSendInvite(toContactShare:));
- (void)didTapShowAddToContactUIForContactShare:(ContactShareViewModel *)contactShare
    NS_SWIFT_NAME(didTapShowAddToContactUI(forContactShare:));

- (void)didTapStickerPack:(StickerPackInfo *)stickerPackInfo NS_SWIFT_NAME(didTapStickerPack(_:));

/**
 * 点了 被@ 的人
 */
- (void)didTapMentionedText:(id<ConversationViewItem>)viewItem userid:(NSString *)userid;
#pragma mark -- 点击了短链接
- (void)didTapShareLinkText:(id<ConversationViewItem>)viewItem  link:(NSString *)link;

@property (nonatomic, readonly, nullable) NSString *lastSearchedText;

@end

#pragma mark -

@interface OWSMessageBubbleView : OWSMessageView

@property (nonatomic, nullable, readonly) UIView *bodyMediaView;
@property (nonatomic, nullable, readonly) OWSLayerView *bodyMediaGradientView;
@property (nonatomic, readonly) OWSMessageFooterView *footerView;
@property (nonatomic, weak) id<OWSMessageBubbleViewDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
