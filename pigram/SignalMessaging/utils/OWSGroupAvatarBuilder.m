//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "OWSGroupAvatarBuilder.h"
#import "OWSContactsManager.h"
#import "TSGroupThread.h"
#import "UIColor+OWS.h"
#import <SignalCoreKit/NSData+OWS.h>
#import <SignalMessaging/SignalMessaging-Swift.h>
#import <SignalServiceKit/SSKEnvironment.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSGroupAvatarBuilder ()

@property (nonatomic, readonly) TSGroupThread *thread;
@property (nonatomic, readonly) NSUInteger diameter;
@property (nonatomic, readonly) SignalServiceAddress *address;
@property (nonatomic, readonly) ConversationColorName colorName;


@end

@implementation OWSGroupAvatarBuilder

- (instancetype)initWithThread:(TSGroupThread *)thread diameter:(NSUInteger)diameter
{
    self = [super init];
    if (!self) {
        return self;
    }

    _thread = thread;
    _diameter = diameter;

    return self;
}
- (instancetype)initWithAddress:(id)address colorName:(id)colorName diameter:(NSUInteger)diameter {
    self = [super init];
    if (!self) {
        return self;
    }

    _address = address;
    _diameter = diameter;
    _colorName = colorName;

    return self;
    
}
#pragma mark - Dependencies

+ (OWSContactsManager *)contactsManager
{
    return (OWSContactsManager *)SSKEnvironment.shared.contactsManager;
}

#pragma mark -

- (nullable UIImage *)buildSavedImage
{
    SignalServiceAddress *address = [[SignalServiceAddress alloc] initWithPhoneNumber:self.thread.groupModel.groupId ?: self.address.groupid];
    return [OWSGroupAvatarBuilder.contactsManager imageForAddressWithSneakyTransaction:address];
//    return self.thread.groupModel.groupImage;
}

- (nullable UIImage *)buildDefaultImage
{
    return [self.class defaultAvatarForGroupId:self.thread.groupModel.groupId ?: self.address.groupid
                         conversationColorName:self.thread.conversationColorName ?: self.colorName
                                      diameter:self.diameter];
}

+ (nullable UIImage *)defaultAvatarForGroupId:(NSString *)groupId
                        conversationColorName:(NSString *)conversationColorName
                                     diameter:(NSUInteger)diameter
{
    NSString *cacheKey = [NSString stringWithFormat:@"%@-%d", groupId, Theme.isDarkThemeEnabled];

    UIImage *_Nullable cachedAvatar =
        [OWSGroupAvatarBuilder.contactsManager.avatarCache imageForKey:cacheKey diameter:(CGFloat)diameter];
    if (cachedAvatar) {
        return cachedAvatar;
    }

#ifdef SHOW_COLOR_PICKER
    UIColor *backgroundColor =
        [OWSConversationColor conversationColorOrDefaultForColorName:conversationColorName].themeColor;
#else
    UIColor *backgroundColor = [OWSConversationColor ows_pigramThemeColor];
#endif
    UIImage *_Nullable image =
        [OWSGroupAvatarBuilder groupAvatarImageWithBackgroundColor:backgroundColor diameter:diameter];
    if (!image) {
        OWSFailDebug(@"Could not create group avatar.");
        return nil;
    }

    [OWSGroupAvatarBuilder.contactsManager.avatarCache setImage:image forKey:cacheKey diameter:diameter];
    return image;
}

+ (nullable UIImage *)groupAvatarImageWithBackgroundColor:(UIColor *)backgroundColor diameter:(NSUInteger)diameter
{
    UIImage *icon = [UIImage imageNamed:@"group-avatar"];
    // The group-avatar asset is designed for the kStandardAvatarSize.
    // Adjust its size to reflect the actual output diameter.
    CGFloat scaling = diameter / (CGFloat)kStandardAvatarSize;
    CGSize iconSize = CGSizeScale(icon.size, scaling);
    return
        [OWSAvatarBuilder avatarImageWithIcon:icon iconSize:iconSize backgroundColor:backgroundColor diameter:diameter];
}

@end

NS_ASSUME_NONNULL_END
