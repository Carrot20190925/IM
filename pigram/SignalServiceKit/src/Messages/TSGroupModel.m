//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "TSGroupModel.h"
#import "FunctionalUtil.h"
#import <SignalCoreKit/NSString+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN


const int32_t kGroupIdLength = 16;
NSUInteger const TSGroupModelSchemaVersion = 1;

@interface TSGroupModel ()

//@property (nullable, nonatomic) NSString *groupName;
@property (nonatomic, readonly) NSUInteger groupModelSchemaVersion;
@property (nullable, nonatomic) NSMutableDictionary <NSString *, PigramGroupMember *> *membersCache;
@property (nullable, nonatomic) NSMutableDictionary <NSString *, PigramGroupNotice *> *noticesCache;

@end

#pragma mark -

@implementation TSGroupModel
- (instancetype)initWithTitle:(nullable NSString *)title
                      members:(NSArray<PigramGroupMember *> *)members
                      groupId:(NSString *)groupId
                        owner:(nonnull NSString *)owner{
    self = [super init];
    if (!self) {
        return self;
    }
    _groupName = title;
    _allMembers = members;
    _groupId = groupId;
    _groupOwner = owner;
    _groupModelSchemaVersion = TSGroupModelSchemaVersion;
    [members enumerateObjectsUsingBlock:^(PigramGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.membersCache setObject:obj forKey:obj.userId];
    }];
    return self;
}
- (void)setNotices:(NSArray<PigramGroupNotice *> *)notices{
    _notices = notices;
    if (!notices) {
        [self.noticesCache removeAllObjects];
        [notices enumerateObjectsUsingBlock:^(PigramGroupNotice * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.noticesCache setObject:obj forKey:obj.id];
        }];
    }
    
}



- (void)setAllMembers:(NSArray<PigramGroupMember *> *)allMembers
{
    _allMembers = allMembers;
    [self.membersCache removeAllObjects];
    [allMembers enumerateObjectsUsingBlock:^(PigramGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            [self.membersCache setObject:obj forKey:obj.userId];
        }
    }];
}
#if TARGET_OS_IOS
- (instancetype)initWithTitle:(nullable NSString *)title
                      members:(NSArray<SignalServiceAddress *> *)members
                        image:(nullable UIImage *)image
                      groupId:(NSString *)groupId
{
    OWSAssertDebug(members);
//    OWSAssertDebug(groupId.length == kGroupIdLength);

    self = [super init];
    if (!self) {
        return self;
    }

    _groupName = title;
//    _groupMembers = [members copy];
    _groupImage = image; // image is stored in DB
    _groupId = groupId;
    _groupModelSchemaVersion = TSGroupModelSchemaVersion;

    return self;
}

- (instancetype)initWithGroupId:(NSString *)groupId
                   groupMembers:(NSArray<SignalServiceAddress *> *)groupMembers
                      groupName:(nullable NSString *)groupName
{
    OWSAssertDebug(groupMembers);
//    OWSAssertDebug(groupId.length == kGroupIdLength);

    self = [super init];
    if (!self) {
        return self;
    }

    _groupId = groupId;
//    _groupMembers = [groupMembers copy];
    _groupName = groupName;
    _groupModelSchemaVersion = TSGroupModelSchemaVersion;

    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self) {
        return self;
    }

//    OWSAssertDebug(self.groupId.length == kGroupIdLength);

    if (_groupModelSchemaVersion < 1) {
//        NSArray<NSString *> *_Nullable memberE164s = [coder decodeObjectForKey:@"groupMemberIds"];
//        if (memberE164s) {
//            NSMutableArray<SignalServiceAddress *> *memberAddresses = [NSMutableArray new];
//            for (NSString *phoneNumber in memberE164s) {
//                [memberAddresses addObject:[[SignalServiceAddress alloc] initWithPhoneNumber:phoneNumber]];
//            }
//            _groupMembers = [memberAddresses copy];
//        } else {
//            _groupMembers = @[];
//        }
    }

    _groupModelSchemaVersion = TSGroupModelSchemaVersion;
    if (self.groupId.length != 16) {
        NSLog(@"");
    }
    OWSLogInfo(@"groudId = %@",self.groupId);
//    NSLog(@"groudId = %@",self.groupId);
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToGroupModel:other];
}

- (BOOL)isEqualToGroupModel:(TSGroupModel *)other {
    if (self == other)
        return YES;
    if (![_groupId isEqualToString:other.groupId]) {
        return NO;
    }
    if (![_groupOwner isEqualToString:other.groupOwner]) {
        return NO;
    }
    if (![_avatar isEqualToString:other.avatar]) {
        return NO;
    }
    if (![_groupName isEqual:other.groupName]) {
        return NO;
    }
    if (![_linkString isEqualToString:other.linkString]) {
        return NO;
    }
    NSSet <PigramGroupNotice *> *myNotices = [NSSet setWithArray:_notices];
    NSSet <PigramGroupNotice *> *otherNotices = [NSSet setWithArray:other.notices];

    if (![myNotices isEqualToSet:otherNotices]) {
        return NO;
    }
    if (!(_groupImage != nil && other.groupImage != nil &&
          [UIImagePNGRepresentation(_groupImage) isEqualToData:UIImagePNGRepresentation(other.groupImage)])) {
        return NO;
    }
    if (_txGroupType != other.txGroupType ) {
        return NO;
    }
    NSSet<PigramGroupMember *> *myGroupMembersSet = [NSSet setWithArray:_allMembers];
    NSSet<PigramGroupMember *> *otherGroupMembersSet = [NSSet setWithArray:other.allMembers];
    return [myGroupMembersSet isEqualToSet:otherGroupMembersSet];
}

- (NSString *)getInfoStringAboutUpdateTo:(TSGroupModel *)newModel contactsManager:(id<ContactsManagerProtocol>)contactsManager {
    NSString *updatedGroupInfoString = @"";
    if (self == newModel) {
        return NSLocalizedString(@"GROUP_UPDATED", @"");
    }
    if (![_groupName isEqual:newModel.groupName]) {
        updatedGroupInfoString = [updatedGroupInfoString
            stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"GROUP_TITLE_CHANGED", @""),
                                                               newModel.groupName]];
    }
    if (_groupImage != nil && newModel.groupImage != nil &&
        !([UIImagePNGRepresentation(_groupImage) isEqualToData:UIImagePNGRepresentation(newModel.groupImage)])) {
        updatedGroupInfoString =
            [updatedGroupInfoString stringByAppendingString:NSLocalizedString(@"GROUP_AVATAR_CHANGED", @"")];
    }
    if ([updatedGroupInfoString length] == 0) {
        updatedGroupInfoString = NSLocalizedString(@"GROUP_UPDATED", @"");
    }
    NSSet *oldMembers = [NSSet setWithArray:_allMembers];
    NSSet *newMembers = [NSSet setWithArray:newModel.allMembers];

    NSMutableSet *membersWhoJoined = [NSMutableSet setWithSet:newMembers];
    [membersWhoJoined minusSet:oldMembers];

    NSMutableSet *membersWhoLeft = [NSMutableSet setWithSet:oldMembers];
    [membersWhoLeft minusSet:newMembers];


    if ([membersWhoLeft count] > 0) {
        NSArray *oldMembersNames = [[membersWhoLeft allObjects] map:^NSString *(SignalServiceAddress *item) {
            return [contactsManager displayNameForAddress:item];
        }];
        updatedGroupInfoString = [updatedGroupInfoString
                                  stringByAppendingString:[NSString
                                                           stringWithFormat:NSLocalizedString(@"GROUP_MEMBER_LEFT", @""),
                                                           [oldMembersNames componentsJoinedByString:@", "]]];
    }
    
    if ([membersWhoJoined count] > 0) {
        NSArray *newMembersNames = [[membersWhoJoined allObjects] map:^NSString *(SignalServiceAddress *item) {
            return [contactsManager displayNameForAddress:item];
        }];
        updatedGroupInfoString = [updatedGroupInfoString
                                  stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"GROUP_MEMBER_JOINED", @""),
                                                           [newMembersNames componentsJoinedByString:@", "]]];
    }

    return updatedGroupInfoString;
}

#endif

- (nullable NSString *)groupName
{
    return _groupName.filterStringForDisplay;
}

- (NSString *)groupNameOrDefault
{
    NSString *_Nullable groupName = self.groupName;
    return groupName.length > 0 ? groupName : TSGroupThread.defaultGroupName;
}
- (nullable PigramGroupNotice *)noticeWithNoticeId:(nullable NSString *)noticeId{
    if (noticeId == nil) {
        return nil;
    }
    __block PigramGroupNotice * notice =  [self.noticesCache objectForKey:noticeId];
    if (notice == nil) {
        [self.notices enumerateObjectsUsingBlock:^(PigramGroupNotice * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.id isEqualToString: noticeId]) {
                notice = obj;
                [self.noticesCache setObject:obj forKey:notice.id];
                *stop = YES;
            }
        }];
        return  notice;
    }else
    {
        return notice;
    }
}
- (nullable PigramGroupMember *)memberWithUserId:(nullable NSString *)userid {
    if (userid == nil) {
        return nil;
    }
    __block PigramGroupMember * member =  [self.membersCache objectForKey:userid];
    if (member == nil) {
        [self.allMembers enumerateObjectsUsingBlock:^(PigramGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userId isEqualToString: userid]) {
                member = obj;
                [self.membersCache setObject:obj forKey:member.userId];
                *stop = YES;
            }
        }];
        return  member;
    }else
    {
        return member;
    }
}

- (nullable NSMutableDictionary *)membersCache {
    if (!_membersCache) {
        _membersCache = [[NSMutableDictionary alloc]init];
    }
    return _membersCache;
}
- (nullable NSMutableDictionary *)noticesCache{
    if (!_noticesCache) {
        _noticesCache = [[NSMutableDictionary alloc]init];
    }
    return _noticesCache;
}

- (NSDictionary *)notificationMutes {
    
    if (_notificationMutes.count == 0) {
        _notificationMutes = @{@"1":@(1),@"2":@(1),@"3":@(1)};
    }
    
    return _notificationMutes;
}
@end

NS_ASSUME_NONNULL_END
