//
//  DYMacro.h
//  ID贷
//
//  Created by apple on 2019/6/22.
//  Copyright © 2019 hansen. All rights reserved.
//

#ifndef DYMacro_h
#define DYMacro_h

#define kWeakly(self) typeof(self) __weak weakself = self;
#define kDefaultAvatarImage [UIImage imageNamed:@"defaultAvatar"]
#define kThemeTextColor [UIColor hex:@"#3ca6ff"]

#define kPGLocalizeString(str, descripe) NSLocalizedString(str, descripe)

#ifdef __OBJC__
#ifdef DEBUG
#define DYLog(fmt, ...) NSLog((@"%s [Line %d] "fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DYLog(...)
#define kWeakself(self) __weak __typeof(self)weakSelf = self
#define kColorWithHex(hex) [UIColor colorWithRed:((float)((hex & 0xff0000) >> 16))/255.0 green:((float)((hex & 0x00ff00) >> 8))/255.0 blue:((float)(hex & 0x0000ff))/255.0 alpha:1.0]

#define kThemeTextColor kColorWithHex(0x3ca6ff)

#define HEXCOLOR(hexValue)  [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1]
///<页面背景色
#define BaseColor HexColor(@"#F6F6F6")
///<导航栏背景色
#define Color_3 HexColor(@"#333333")
///<tab选项栏选中颜色
#define TABSelectColor HexColor(@"#a971fb")
///<分割线颜色
#define TBSeparaColor HexColor(@"#EBEBEB")
///<提交按钮颜色
#define MBTNColor HexColor(@"#FE3962")//ff3833  a971fb

#define MBTAColor(a) ApHexColor(@"#a971fb",a)
#define SexBack HexColor(@"#6cd1f1")


// 黑色
#define Color_0 HexColor(@"#1E1E1E")
#define Color_3 HexColor(@"#333333")
#define Color_6 HexColor(@"#666666")
#define Color_9 HexColor(@"#999999")
// 白色
#define Color_F HexColor(@"#FFFFFF")

#define kGETVALUE_HEIGHT(width,height,limit_width) ((limit_width)*(height)/(width))

// wx背景灰色
#define kBackgroundGrayColor [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]

#define COLOR_X(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1]

#pragma mark - UserDefault
#define SetUserDefaultKeyWithObject(key,object) [[NSUserDefaults standardUserDefaults] setObject:object forKey:key]
#define SetUserBoolKeyWithObject(key,object) [[NSUserDefaults standardUserDefaults] setBool:object forKey:key]

#define GetUserDefaultWithKey(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define GetUserDefaultBoolWithKey(key) [[NSUserDefaults standardUserDefaults] boolForKey:key]

#define DeleUserDefaultWithKey(key) [[NSUserDefaults standardUserDefaults] removeObjectForKey:key]
#define UserDefaultSynchronize  [[NSUserDefaults standardUserDefaults] synchronize]

#pragma mark - 沙盒路径
#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


//设备宏
#define SCREEN_WIDTH    UIScreen.mainScreen.bounds.size.width    //屏幕宽
#define SCREEN_HEIGHT   UIScreen.mainScreen.bounds.size.height   //屏幕高



// 判断是否是ipad
#define IS_Pad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
// 判断iPhone4系列
#define kiPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) && !IS_Pad : NO)
// 判断iPhone5系列
#define kiPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) && !IS_Pad : NO)
// 判断iPhone6系列
#define kiPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) && !IS_Pad : NO)
//判断iPhone6+系列
#define kiPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) && !IS_Pad : NO)
// 判断iPhone X
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !IS_Pad : NO)
// 判断iPHone XR
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !IS_Pad : NO)
// 判断iPhone XS
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !IS_Pad : NO)
// 判断iPhone XS Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !IS_Pad : NO)

#define Height_StatusBar ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 44.0 : 20.0)
#define Height_NavBar ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 88.0 : 64.0)
#define Height_TabBar ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 83.0 : 49.0)

/**
 * 屏幕适配--iPhoneX全系
 */
#define kiPhoneXAll ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)

/**
 * iPhoneX全系导航栏增加高度 (64->88)
 */
#define kiPhoneX_Top_Height (([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)?24:0)

/**
 * iPhoneX全系TabBar增加高度 (49->83)
 */
#define kiPhoneX_Bottom_Height  (([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)?34:0)

#endif

#import "UIView+dy_extension.h"
#import "NSString+dy_extension.h"
#import "UIColor+dy_extension.h"
#import "DYTableView.h"
#import "DYButton.h"
#import <masonry/masonry.h>
#import "UIImage+dy_extension.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <ToastSwiftFramework/Toast-Swift-Framework.h>
#endif

#endif /* DYMacro_h */
