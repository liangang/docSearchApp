//
//  pathUrl.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-15.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImdUrlPath : NSObject

+(NSString* ) docSearchUrl:(NSString*)query src:(NSString*)src pageNo:(int)pn pageSize:(int)ps sort:(int)sort;

+(NSString* ) docSuggestUrl:(NSString*)query src:(NSString*)src max:(int)max;

+(NSString* ) docArticleUrl:(NSString*)externelId;

+(NSString* ) docArticleUserOpUrl:(NSString*)externelId;

+(NSString* ) docDownloadUrl:(NSString*)externelId;

+(NSString* ) docDownloadCN:(NSString*)externelId;

+(NSString* ) docRequestUrl:(NSString*)externelId title:(NSString*) title;

+(NSString* ) docRequestListUrl:(BOOL)status start:(NSInteger) start limit:(NSInteger)limit;

+(NSString* ) docAskForPdfUrl:(NSString*)externelId;

+(NSString* ) docFavsUrl;

+(NSString* ) docFavUrl:(NSString*)externelId title:(NSString*) title;

+(NSString* ) docRemoveFavsUrl:(NSString*)externelId;

/**
 *  获取用户的请求记录URL
 *
 *  @param type  请求类型，0全部类型，1中文，2英文
 *  @param start 开始时已有的条数
 *  @param limit 需要获取的条数
 *
 *  @return URL
 */
+ (NSString *)getDocListRecordUrl:(NSInteger)type start:(NSInteger)start limit:(NSInteger)limit;

/**
 *  获取用户收藏的文献记录
 *
 *  @param type  请求类型，0全部类型，1中文，2英文
 *  @param start 分页开始时已有的条数
 *  @param limit 分页的条数
 *
 *  @return URl
 */
+ (NSString *)getFavListUrl:(NSInteger)type start:(NSInteger)start limit:(NSInteger)limit;

+(NSString* ) departmentUrl;

+(NSString* ) registerUrl;

+(NSString* ) appVersionUrl;

+(NSString* ) appFeebbackUrl;

+(NSString* ) mobileActiveCodeUrl;

+(NSString* ) mobileActiveUrl;

+(NSString* ) userActiveUrl;

+(NSString*) emailActiveUrl;

+(NSString*) checkEmailUrl:(NSString*)email;

+(NSString*) checkNickNameUrl:(NSString*)nickName;

+(NSString*) checkMobileUrl:(NSString*)mobile;

+(NSString* ) docArticleArrayexternelId;

+(NSString *) checkDocumentStatus;

+(NSString *) checkUserInfo;

+(NSString *) getUserInfo;
+ (NSString *)getDailylimit;

+ (NSString *)findPasswordByEmail;
+ (NSString *)findPasswordByMobil;
+ (NSString *)checkActivationCode;

+ (NSString *)resetUsePassword;
+ (NSString *)saveUserInfo;
+ (NSString *)mobileActiveInfo:(NSString *)mobileNum;
+ (NSString *)mobileActiveCheck;
+ (NSString *)emailActiveAccount;
+ (NSString *)emailModifyAccount;

+ (NSString *)verifyDocCardNum;

+ (NSString *)getInviteesInfo;
+ (NSString *)invitedFriendBy:(NSString *)uid;

@end
