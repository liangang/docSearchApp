  //
  //  ImdAppBehavior.h
  //  imdSearch
  //
  //  Created by ding zhihong on 12-3-27.
  //  Copyright (c) 2012年 i-md.com. All rights reserved.
  //

#import <Foundation/Foundation.h>

#define FLURRY_RELEASE @"YES"

/*
 睿医文献 App Flurry Key
 */


#define FLURRY_KEY @"WXTM28LSA82CKSSD4BJD"
#define FLURRY_TEST_KEY @"EHUIZUZL6W3MW6C541ES"

/*
 Event Ids
 */
#define EVENT_REGISTER_BEGIN @"Register Begin"
#define EVENT_REGISTER_Submit @"Register Submit"
//#define EVENT_SEARCH @"Search"
//#define EVENT_RESULT_MORE @"Result more"
#define EVENT_DOWNLOAD_FULL_TEXT @"Download Full Text"
#define EVENT_ASKFOR_FULL_TEXT @"Askfor Full Text"
#define EVENT_GO_TO_GRADE @"Go to grade page"

#define EVENT_SEARCH_JSON @"Search"
#define EVENT_NEXT_PAGE @"NextPage"
#define EVENT_SORT @"Sort"
#define EVENT_READING @"Reading"
#define EVENT_DO_FAVORITE @"Favorite"
#define EVENT_DO_ASK_FOR @"Askfor"
#define EVENT_DO_DOWNLOAD @"Download"
#define EVENT_DETAIL @"ShowDetail"
#define EVENT_REGISTER @"Register"
#define EVENT_LOCAL_DOC @"LocalDoc"
#define EVENT_DO_SETTING @"Settings"
#define EVENT_SAVE_DOC @"SaveDoc"
#define EVENT_LOCAL_DOC_BUTTON_TAPPED @"LocalDocButtonPressed"
#define EVENT_LOCAL_ASKING_BUTTON_TAPPED @"LocalAskingButtonPressed"
#define EVENT_LOCAL_ASKED_BUTTON_TAPPED @"LocalAskedButtonPressed"
#define EVENT_READ_OVER @"ReadEnd"
#define EVENT_EXCEPTION @"Exception"

/*
 Event Param Keys
 */
//#define KEY_SEARCH_WORDS @"search words"
//#define KEY_IS_ADVANCE_SEARCH @"is Advance search"
//#define KEY_IS_PRESSED_BUTTON @"is pressed button"
//#define KEY_IS_DRAWN_ACTION @"is drawn action"

#define KEY_USER_NAME @"username"
#define KEY_MAC_ADDRESS @"DID"
#define KEY_SEARCH_JSON @"search_json"
#define KEY_SORT_NAME @"sort_name"
#define KEY_TITLE @"title"
#define KEY_CURRENT_PAGE @"current_page"
#define KEY_TOTAL_PAGE @"total_page"
#define KEY_PAGE_NAME @"page_name"
#define KEY_ACTION @"action"
#define KEY_PAGE_TITLE @"page_title"
#define KEY_PARAM_JSON @"param_json"
#define KEY_SET_LABEL @"setting_label"
#define KEY_SET_VALUE @"setting_value"
#define KEY_EXCEPTION_CODE @"exception_code"
#define KEY_MESSAGE @"message"

/*
 Event Param Value
 */
#define REGISTER_CATEGORY @"分类选择"
#define REGISTER_STUDENT_INFO @"学生信息"
#define REGISTER_SUCCESS @"注册成功"
#define REGISTER_SERVER_PROP @"服务协议"
#define REGISTER_DOCTOR_1 @"医生信息-1"
#define REGISTER_DOCTOR_2 @"医生信息-2"
#define SelectProfessional @"职称选择"
#define SelectDepartment @"科室选择"
/*
 Event Page name
 */
#define PAGE_FULL @"全文阅读"
#define PAGE_SEARCH @"文献"
#define PAGE_FAV @"收藏夹"
#define PAGE_LOCA @"已保存本地"
#define PAGE_ASKING @"索取中文献"
#define PAGE_ASKED @"已索取到文献"
#define PAGE_LocaSave @"本地文献"
#define PAGE_SET @"设置"
/*
 Event Action
 */
#define ACT_ADD @"添加"
#define ACT_DEL @"删除"

/*
 Event setLabel
 */
#define SET_L_ACCOUNT_MANAGE @"帐户管理"
#define SET_L_DOWNLOAD @"下载设置"
#define SET_L_CLEAR_CACHE @"清除缓存"
#define SET_L_FEEDBACK @"反馈建议"
#define SET_L_RATING @"去AppStor评分"
#define SET_L_ABOUT @"关于我们"
#define SET_L_RESPONSIBLE @"免责声明"
#define SET_L_NEWS @"睿医资讯"
#define SET_L_VERSION @"版本更新"

@interface ImdAppBehavior : NSObject

/*
 Flurry Default tracking:比如app每天使用次数，每天新用户数，每个app version使用的用户数等等。
 usage：
 #import "Flurry.h"
 - (void)applicationDidFinishLaunching:(UIApplication *)application {
 [imdBehavior flurryAppDefaultTracking];
 //your code
 }
 */
+ (void)flurryAppDefaultTracking;

/*
 Register Behavior
 mobile客户端用户注册率：用户成功完成一次注册
 */
+ (void)registerFinished;
+ (void)registerBegin;

/*
 注册
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 页面名称（分类选择，学生信息，注册成功，服务协议，医生信息1，医生信息2）；
 参数（根据页面动作另行设置）；
 */
+ (void)registerLog:(NSString *)username MACAddr:(NSString *)mac pageName:(NSString *)pageName paramJson:(NSString *)json;


/*
 搜索关键字
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 搜索Json数据；
 */
+ (void)searchJsonLog:(NSString *)username MACAddr:(NSString *)mac SearchJson:(NSString *)json;

/*
 搜索下载下一页
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 搜索Json数据；
 */
+ (void)nextPageLog:(NSString *)username MACAddr:(NSString *)mac SearchJson:(NSString *)json;

/*
 搜索排序
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 排序名称（相关排序，时间排序，期刊排序）；
 */
+ (void)sortLog:(NSString *)username MACAddr:(NSString *)mac sortName:(NSString *)sortName;

/*
 Full Text
 1. 用户下载全文
 2. 索取全文的次数
 */
+ (void)downloadFullText;
+ (void)askforFullText;

/*
 用户评分
 带上用户信息
 */
+ (void)goToGrade:(NSString *)username;

/*
 阅读
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 当前页；
 总页数；
 */
+ (void)readingLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title currentPage:(int)currentPage totalPage:(int)totalPage;

/*
 阅读结束
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 当前页；
 总页数；
 */
+ (void)readOverLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title currentPage:(int)currentPage totalPage:(int)totalPage;

/*
 收藏
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 页面名称（文献检索，收藏夹，已保存本地，索取中文献，已索取到文献）；
 操作（添加，删除）；
 */
+ (void)doFavoriteLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title pageName:(NSString *)pageName action:(NSString *)action;

/*
 索取
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 页面名称（文献检索，收藏夹，已保存本地，索取中文献，已索取到文献）；
 */
+ (void)doAskforLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title pageName:(NSString *)pageName;

/*
 下载
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 页面名称（文献检索，收藏夹，已保存本地，索取中文献，已索取到文献）； 
 */
+ (void)doDownloadLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title pageName:(NSString *)pageName;

/*
 细节页
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 页面名称（文献检索，收藏夹，已保存本地，索取中文献，已索取到文献）； 
 */
+ (void)detailLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title pageName:(NSString *)pageName;

/*
 选择本地文献
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 */
+ (void)localDocLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title;

/*
 设置操作
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 设置名称（帐户管理，下载设置，清除缓存，反馈建议，去AppStor评分，关于我们，免责声明，睿医资讯，版本更新）；
 设置值（根据实际情况上传）；
 */
+ (void)doSettingLog:(NSString *)username MACAddr:(NSString *)mac setLabel:(NSString *)label setValue:(NSString *)value;

/*
 文献保存到本地
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 文献名；
 页面名称（文献检索，收藏夹，已保存本地，索取中文献，已索取到文献）；
 */
+ (void)saveDocLog:(NSString *)username MACAddr:(NSString *)mac title:(NSString *)title pageName:(NSString *)pageName;

/*
 按下本地文献按钮
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 */
+ (void)localDocButtonTappedLog:(NSString *)username MACAddr:(NSString *)mac;

/*
 按下索取中按钮
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 */
+ (void)localAskingButtonTappedLog:(NSString *)username MACAddr:(NSString *)mac;

/*
 按下已索取按钮
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 */
+ (void)localAskedButtonTappedLog:(NSString *)username MACAddr:(NSString *)mac;

/*
 错误信息
 上传：用户名，如无上传“null”；
 网卡MAC地址；
 错误码（另行编制－iPhone与iPad统一编号）；
 错误信息（具体错误信息，实际情况，可与显示用户信息不同）；
 */
+ (void)exceptionLog:(NSString *)username MACAddr:(NSString *)mac exceptionCode:(NSString *)code exceptionMessage:(NSString *)message;


@end
