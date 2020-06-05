//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "ContactsManagerProtocol.h"
#import <Mantle/MTLModel+NSCoding.h>

NS_ASSUME_NONNULL_BEGIN

@class PigramGroupMember;
@class SignalServiceAddress;
@class PigramRoleRightBan;
@class PigramGroupNotice;
extern const int32_t kGroupIdLength;
//typedef enum {
//     PigramGroupRoleOwner,
//     PigramGroupRoleManager,
//     PigramGroupRoleMember
//}PigramGroupRole;
//成员权限
typedef NS_OPTIONS(UInt32, PigramMemberPerm){
    PigramMemberPermAll =            0,
    PigramMemberPermText =           1 << 0,
    PigramMemberPermSticker =        1 << 1,
    PigramMemberPermAudio =          1 << 2,
    PigramMemberPermVideo =          1 << 3,
};
typedef enum{
     TXGroupTypeUnknow = 0,
     TXGroupTypeJoined,
     TXGroupTypeExit,
     TXGroupTypeLimit,

    } TXGroupType;



typedef NS_ENUM(UInt32,PigramGroupRole){
    PigramGroupRoleOwner = 0,
    PigramGroupRoleManager = 1,
    PigramGroupRoleMember = 2
};
typedef enum {
    PigramGroupContextTargetNone = 0,
    PigramGroupContextTargetName = 1,
    PigramGroupContextTargetAvatar = 2,
    PigramGroupContextTargetOwner = 3,
    PigramGroupContextTargetManager = 4,
    PigramGroupContextTargetMember = 5,
    PigramGroupContextTargetNotice = 6,
    PigramGroupContextTargetPerm = 7,
    PigramGroupContextTargetBlackList = 8,
}PigramGroupContextTarget;

@interface TSGroupModel : MTLModel
@property (assign, nonatomic) TXGroupType  txGroupType;
//@property (nonatomic) NSArray<SignalServiceAddress *> *groupMembers;
@property (atomic) NSArray <PigramGroupMember *> *allMembers;
@property (nullable, nonatomic) NSString *groupName;
@property (readonly, nonatomic) NSString *groupId;
//1: normal, 2: dismissed, 3:limit;
@property (assign, nonatomic) NSInteger  groupStatus;
///群管理
//@property (nonatomic) NSArray<NSString *> *groupManagers;
@property (nullable, nonatomic) NSString *avatar;
///群主
@property (nonatomic) NSString *groupOwner;
///群公告 暂时只显示一条 {"id": string ,"notice": string }
@property (nonatomic) NSArray<PigramGroupNotice *> *notices;
///禁言成员
@property (nonatomic) NSArray<NSString *> *blackList;
///所有权限设置相关
@property (nonatomic) NSArray<PigramRoleRightBan *> *permRightBans;
@property (nullable, nonatomic) NSString* linkString;

/**
 * 通知范围管理
 *
 * {id : action}  id: 1:踢人通知群成员,2:退群通知群成员,3:禁言通知群成员,action: 1:通知群成员(默认),2:不通知群成员
 *
 */
@property (nonatomic, copy) NSDictionary *notificationMutes;
//发送消息类型
//@property (assign, nonatomic) PigramGroupContextTarget  target;
#if TARGET_OS_IOS
@property (nullable, nonatomic, strong) UIImage *groupImage;

/**
 * 成员人数
 */
@property (assign, nonatomic) NSInteger membersCount;

- (instancetype)initWithTitle:(nullable NSString *)title
                      members:(NSArray<SignalServiceAddress *> *)members
                        image:(nullable UIImage *)image
                      groupId:(NSString *)groupId;

- (instancetype)initWithGroupId:(NSString *)groupId
                   groupMembers:(NSArray<SignalServiceAddress *> *)groupMembers
                      groupName:(nullable NSString *)groupName;



- (instancetype)initWithTitle:(nullable NSString *)title
                      members:(NSArray<PigramGroupMember *> *)members
                      groupId:(NSString *)groupId
                       owner:(NSString *)owner;

- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToGroupModel:(TSGroupModel *)model;
- (NSString *)getInfoStringAboutUpdateTo:(TSGroupModel *)model contactsManager:(id<ContactsManagerProtocol>)contactsManager;

- (nullable PigramGroupMember *)memberWithUserId:(nullable NSString *)userid;
- (nullable PigramGroupNotice *)noticeWithNoticeId:(nullable NSString *)noticeId;

#endif

@property (nonatomic, readonly) NSString *groupNameOrDefault;

@end

NS_ASSUME_NONNULL_END
