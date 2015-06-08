  //
  //  ImdAppBehavior.m
  //  imdSearch
  //
  //  Created by ding zhihong on 12-3-27.
  //  Copyright (c) 2012年 i-md.com. All rights reserved.
  //

#import "ImdAppBehavior.h"
#import "Flurry.h"
#import <CoreLocation/CoreLocation.h>
@implementation ImdAppBehavior

/*
 Flurry Default tracking:比如app每天使用次数，每天新用户数，每个app version使用的用户数等等。
 usage：
 #import "Flurry.h"
 - (void)applicationDidFinishLaunching:(UIApplication *)application {
 [imdBehavior flurryAppDefaultTracking];
 //your code
 }
 */
+ (void)flurryAppDefaultTracking
{
//  CLLocationManager *locationManager = [[CLLocationManager alloc] init];
//  [locationManager startUpdatingLocation];
//  
//  CLLocation *location = locationManager.location;
//  [Flurry setLatitude:location.coordinate.latitude
//            longitude:location.coordinate.longitude
//   horizontalAccuracy:location.horizontalAccuracy
//     verticalAccuracy:location.verticalAccuracy];
  NSLog(@"Flurry startSession:FLURRY_KEY");
    //  if ([FLURRY_RELEASE isEqualToString:@"YES"]) {
    //    [Flurry startSession:FLURRY_KEY];
    //  }
  
#ifndef DEBUG
  [Flurry startSession:FLURRY_KEY];
#else
  [Flurry startSession:FLURRY_TEST_KEY];
#endif
}

/*
 Register Behavior
 mobile客户端用户注册率：用户成功提交注册
 */
+ (void)registerFinished
{
  [Flurry logEvent:EVENT_REGISTER_Submit timed:YES];
}

+(void)registerBegin
{
  [Flurry logEvent:EVENT_REGISTER_BEGIN timed:YES];
}

/*
 注册
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 页面名称（分类选择，学生信息，注册成功，服务协议，医生信息1，医生信息2）；
 参数（根据页面动作另行设置）；
 */
+ (void)registerLog:(NSString *)username MACAddr:(NSString *)mac pageName:(NSString *)pageName paramJson:(NSString *)json
{
  NSLog(@"registerLog:%@ MACAddr:%@ pageName:%@ paramJson:%@",username,mac,pageName,json);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   pageName, KEY_PAGE_NAME,
   json, KEY_PARAM_JSON,
   nil];
  [Flurry logEvent:EVENT_REGISTER withParameters:param timed:YES];
}

/*
 搜索关键字
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 搜索Json数据；
 */
+ (void)searchJsonLog:(NSString *)username MACAddr:(NSString *)mac SearchJson:(NSString *)json
{
  NSLog(@"searchJsonLog:%@ MACAddr:%@ SearchJson:%@",username,mac,json);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   json, KEY_SEARCH_JSON,
   nil];
  [Flurry logEvent:EVENT_SEARCH_JSON withParameters:param timed:YES];
}

/*
 搜索下载下一页
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 搜索Json数据；
 */
+ (void)nextPageLog:(NSString *)username MACAddr:(NSString *)mac SearchJson:(NSString *)json
{
  NSLog(@"nextPageLog:%@ MACAddr:%@ SearchJson:%@",username,mac,json);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   json, KEY_SEARCH_JSON,
   nil];
  [Flurry logEvent:EVENT_NEXT_PAGE withParameters:param timed:YES];
}

/*
 搜索排序
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 排序名称（相关排序，时间排序，期刊排序）；
 */
+ (void)sortLog:(NSString *)username MACAddr:(NSString *)mac sortName:(NSString *)sortName
{
  NSLog(@"sortLog:%@ MACAddr:%@ SearchJson:%@",username,mac,sortName);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   sortName, KEY_SORT_NAME,
   nil];
  [Flurry logEvent:EVENT_SORT withParameters:param timed:YES];
}

/*
 Full Text
 1. 用户下载全文
 2. 索取全文的次数
 */
+ (void)downloadFullText
{
  [Flurry logEvent:EVENT_DOWNLOAD_FULL_TEXT timed:YES];
}

+ (void)askforFullText
{
  [Flurry logEvent:EVENT_ASKFOR_FULL_TEXT timed:YES];
}

/*
 用户评分
 带上用户信息
 */
+ (void)goToGrade:(NSString *)username
{
  NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys:username,@"username", nil];
  [Flurry logEvent:EVENT_GO_TO_GRADE withParameters:param timed:YES];
}

/*
 阅读
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 当前页；
 总页数；
 */
+ (void)readingLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title currentPage:(int)currentPage totalPage:(int)totalPage
{
  NSLog(@"readingLog:%@ MACAddr:%@ title:%@ currentPage:%i totalPage:%i",username,mac,title,currentPage,totalPage);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   title, KEY_TITLE,
   [NSString stringWithFormat:@"%i", currentPage], KEY_CURRENT_PAGE,
   [NSString stringWithFormat:@"%i", totalPage], KEY_TOTAL_PAGE,
   nil];
  [Flurry logEvent:EVENT_READING withParameters:param timed:YES];
}

/*
 阅读结束
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 当前页；
 总页数；
 */
+ (void)readOverLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title currentPage:(int)currentPage totalPage:(int)totalPage
{
  NSLog(@"readOverLog:%@ MACAddr:%@ title:%@ currentPage:%i totalPage:%i",username,mac,title,currentPage,totalPage);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   title, KEY_TITLE,
   [NSString stringWithFormat:@"%i", currentPage], KEY_CURRENT_PAGE,
   [NSString stringWithFormat:@"%i", totalPage], KEY_TOTAL_PAGE,
   nil];
  [Flurry logEvent:EVENT_READ_OVER withParameters:param timed:YES];
}

/*
 收藏
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 页面名称（文献检索，收藏夹，已保存本地，索取中文献，已索取到文献）；
 操作（添加，删除）；
 */
+ (void)doFavoriteLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title pageName:(NSString *)pageName action:(NSString *)action
{
  NSLog(@"doFavoriteLog:%@ MACAddr:%@ title:%@ pageName:%@ action:%@",username,mac,title,pageName,action);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   title, KEY_TITLE,
   pageName, KEY_PAGE_NAME,
   action, KEY_ACTION,
   nil];
  [Flurry logEvent:EVENT_DO_FAVORITE withParameters:param timed:YES];
}

/*
 索取
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 页面名称（文献检索，收藏夹，已保存本地，索取中文献，已索取到文献）；
 */
+ (void)doAskforLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title pageName:(NSString *)pageName
{
  NSLog(@"doAskforLog:%@ MACAddr:%@ title:%@ pageName:%@",username,mac,title,pageName);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   title, KEY_TITLE,
   pageName, KEY_PAGE_NAME,
   nil];
  [Flurry logEvent:EVENT_DO_ASK_FOR withParameters:param timed:YES];
}

/*
 下载
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 页面名称（文献检索，收藏夹，已保存本地，索取中文献，已索取到文献）； 
 */
+ (void)doDownloadLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title pageName:(NSString *)pageName
{
  NSLog(@"doDownloadLog:%@ MACAddr:%@ title:%@ pageName:%@",username,mac,title,pageName);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   title, KEY_TITLE,
   pageName, KEY_PAGE_NAME,
   nil];
  [Flurry logEvent:EVENT_DO_DOWNLOAD withParameters:param timed:YES];
}

/*
 细节页
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 页面名称（文献检索，收藏夹，已保存本地，索取中文献，已索取到文献）； 
 */
+ (void)detailLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title pageName:(NSString *)pageName
{
  NSLog(@"detailLog:%@ MACAddr:%@ title:%@ pageName:%@",username,mac,title,pageName);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   title, KEY_TITLE,
   pageName, KEY_PAGE_NAME,
   nil];
  [Flurry logEvent:EVENT_DETAIL withParameters:param timed:YES];
}

/*
 选择本地文献
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 */
+ (void)localDocLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title
{
  NSLog(@"localDocLog:%@ MACAddr:%@ title:%@",username,mac,title);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   title, KEY_TITLE,
   nil];
  [Flurry logEvent:EVENT_LOCAL_DOC withParameters:param timed:YES];
}

/*
 设置操作
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 设置名称（帐户管理，下载设置，清除缓存，反馈建议，去AppStor评分，关于我们，免责声明，睿医资讯，版本更新）；
 设置值（根据实际情况上传）；
 */
+ (void)doSettingLog:(NSString *)username MACAddr:(NSString *)mac setLabel:(NSString *)label setValue:(NSString *)value
{
  NSLog(@"doSettingLog:%@ MACAddr:%@ setLabel:%@ setValue:%@",username,mac,label,value);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   label, KEY_SET_LABEL,
   value, KEY_SET_VALUE,
   nil];
  [Flurry logEvent:EVENT_DO_SETTING withParameters:param timed:YES];
}

/*
 文献保存到本地
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 页面名称（文献检索，收藏夹，已保存本地，索取中文献，已索取到文献）；
 */
+ (void)saveDocLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title pageName:(NSString *)pageName
{
  NSLog(@"saveDocLog:%@ MACAddr:%@ title:%@ pageName:%@",username,mac,title,pageName);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   title, KEY_TITLE,
   pageName, KEY_PAGE_NAME,
   nil];
  [Flurry logEvent:EVENT_READING withParameters:param timed:YES];
}

/*
 按下本地文献按钮
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 */
+ (void)localDocButtonTappedLog:(NSString *)username MACAddr:(NSString *)mac
{
  NSLog(@"localDocButtonTappedLog:%@ MACAddr:%@",username,mac);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   nil];
  [Flurry logEvent:EVENT_LOCAL_DOC_BUTTON_TAPPED withParameters:param timed:YES];
}

/*
 按下索取中按钮
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 */
+ (void)localAskingButtonTappedLog:(NSString *)username MACAddr:(NSString *)mac
{
  NSLog(@"localAskingButtonTappedLog:%@ MACAddr:%@",username,mac);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   nil];
  [Flurry logEvent:EVENT_LOCAL_ASKING_BUTTON_TAPPED withParameters:param timed:YES];
}

/*
 按下已索取按钮
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 */
+ (void)localAskedButtonTappedLog:(NSString *)username MACAddr:(NSString *)mac
{
  NSLog(@"localAskedButtonTappedLog:%@ MACAddr:%@",username,mac);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   nil];
  [Flurry logEvent:EVENT_LOCAL_ASKED_BUTTON_TAPPED withParameters:param timed:YES];
}

/*
 错误信息
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 错误码（另行编制－iPhone与iPad统一编号）；
 错误信息（具体错误信息，实际情况，可与显示用户信息不同）；
 */
+ (void)exceptionLog:(NSString *)username MACAddr:(NSString *)mac exceptionCode:(NSString *)code exceptionMessage:(NSString *)message
{
  NSLog(@"exceptionLog:%@ MACAddr:%@ exceptionCode:%@ exceptionMessage:%@",username,mac,code,message);
  NSDictionary* param =
  [NSDictionary dictionaryWithObjectsAndKeys:
   username,KEY_USER_NAME,
   mac, KEY_MAC_ADDRESS,
   code, KEY_EXCEPTION_CODE,
   message, KEY_MESSAGE,
   nil];
  [Flurry logEvent:EVENT_EXCEPTION withParameters:param timed:YES];
}

@end
