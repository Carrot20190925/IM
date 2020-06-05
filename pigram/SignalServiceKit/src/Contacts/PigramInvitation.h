//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "ContactsUpdater.h"

NS_ASSUME_NONNULL_BEGIN

@interface PigramInvitation : NSObject
//发起者昵称
@property (readonly, nonatomic) NSString *nick;
/**发起者电话号码*/
@property (nonatomic, copy) NSString  *sponsorTelephone;

//@property (nonatomic, assign) OWSPigramContactAction action;

@end

NS_ASSUME_NONNULL_END
