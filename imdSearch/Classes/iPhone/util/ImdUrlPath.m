//
//  pathUrl.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-15.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "ImdUrlPath.h"
#import "myUrl.h"
#import "Util.h"

@implementation ImdUrlPath


+(NSString*) docSearchUrl:(NSString*)query src:(NSString*)src pageNo:(int)pn
                 pageSize:(int)ps sort:(int)sort
{
    NSString* qe = [Util URLencode:query stringEncoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/s/?q=%@&src=%@&pn=%d&ps=%d&sort=%d",MY_SEARCH_SERVER, qe, src, pn, ps, sort];
    
    //[qe autorelease];
    return url;
}

+(NSString* ) docSuggestUrl:(NSString*)query src:(NSString*)src max:(int)max
{
    NSString* qe = [Util URLencode:query stringEncoding:NSUTF8StringEncoding];
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/suggest/?q=%@&src=%@&max_matches=%d&use_similar=0",MY_SEARCH_SERVER, qe, src, max];
    
    //[qe autorelease];
    return url;
}

+(NSString* ) docArticleUrl:(NSString*)externelId
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/doc/%@/",MY_SEARCH_SERVER, externelId];
    return url;
}

+(NSString* ) docArticleUserOpUrl:(NSString*)externelId
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/docu/%@/",MY_SEARCH_SERVER, externelId];
    return url;
}

+(NSString* ) docDownloadUrl:(NSString*)externelId
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/download/%@/",MY_SEARCH_SERVER, externelId];
    return url;
}

+(NSString* ) docAskForPdfUrl:(NSString*)externelId
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/askforpdf/%@",MY_SEARCH_SERVER, externelId];
    NSLog(@"AskForPdf: %@", url);
    return url;
}

+(NSString* ) docRequestUrl:(NSString*)externelId title:(NSString*) title
{
    NSString *deviceNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceNumber"];
    //    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/askfor?id=%@&title=%@&devices=%@",temp, externelId, [Util URLencode:title stringEncoding:NSUTF8StringEncoding],[Util URLencode:deviceNumber stringEncoding:NSUTF8StringEncoding]];
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/askfor?id=%@&title=%@&devices=%@",MY_SEARCH_SERVER, externelId, [Util URLencode:title stringEncoding:NSUTF8StringEncoding],[Util URLencode:deviceNumber stringEncoding:NSUTF8StringEncoding]];
    return url;
}


+(NSString* ) docRequestListUrl:(BOOL)status start:(NSInteger) start limit:(NSInteger)limit
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/askforlist?status=%@&start=%d&limit=%d", MY_SEARCH_SERVER, status? @"true" : @"false", start, limit];
    return url;
}

+(NSString* ) docFavsUrl
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/favs", MY_SEARCH_SERVER];
    return url;
}

+(NSString* ) docFavUrl:(NSString*)externelId title:(NSString*) title
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/fav?id=%@&title=%@", MY_SEARCH_SERVER, externelId, [Util URLencode:title stringEncoding:NSUTF8StringEncoding]];
    return url;
}

+(NSString* ) docRemoveFavsUrl:(NSString*)externelId
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/removefav/%@", MY_SEARCH_SERVER, externelId];
    return url;
}

+ (NSString *)getDocListRecordUrl:(NSInteger)type start:(NSInteger)start limit:(NSInteger)limit{
    NSString *url = [NSString stringWithFormat:@"http://%@/client/docsearch/askforcompatiblelist?cat=%d&start=%d&limit=%d",MY_SEARCH_SERVER,type,start,limit];
    return url;
}

+ (NSString *)getFavListUrl:(NSInteger)type start:(NSInteger)start limit:(NSInteger)limit{
    NSString *url = [NSString stringWithFormat:@"http://%@/client/docsearch/askforfavlist?cat=%d&start=%d&limit=%d",MY_SEARCH_SERVER,type,start,limit];
    return url;
}

+(NSString* ) registerUrl
{
    NSString* url = [NSString stringWithFormat:@"http://%@/users",MY_SERVER];
    return url;
}


+(NSString* ) appVersionUrl
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/first",MY_SEARCH_SERVER];
    return url;
    
}

+(NSString* ) appFeebbackUrl
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/feedback", MY_SEARCH_SERVER];
    return url;
}

+(NSString* ) departmentUrl
{
    return [NSString stringWithFormat:@"http://%@/client/department", MY_SEARCH_SERVER];
}


+(NSString* ) mobileActiveCodeUrl
{
    return [NSString stringWithFormat:@"http://%@/client/validate/mobile/requestsms", MY_SEARCH_SERVER];
}

+(NSString* ) mobileActiveUrl
{
    return [NSString stringWithFormat:@"http://%@/client/validate/mobile/active", MY_SEARCH_SERVER];
}

+(NSString* ) userActiveUrl
{
    return [NSString stringWithFormat:@"http://%@/client/user/active", MY_SEARCH_SERVER];
}

+(NSString* ) emailActiveUrl
{
    return [NSString stringWithFormat:@"http://%@/client/user/sendActiveEmail", MY_SEARCH_SERVER];
}


+(NSString*) checkEmailUrl:(NSString*)email
{
    return [NSString stringWithFormat:@"http://%@/Profile/checkEmailAvailable/%@", NEW_SERVER, email];
}

+(NSString*) checkNickNameUrl:(NSString*)nickName
{
    return [NSString stringWithFormat:@"http://%@/client/checknickname/%@", MY_SEARCH_SERVER, [Util URLencode:nickName stringEncoding:NSUTF8StringEncoding]];
}

+(NSString*) checkMobileUrl:(NSString*)mobile
{
    return [NSString stringWithFormat:@"http://%@/Profile/checkMobileAvailable/%@", NEW_SERVER,mobile];
}

+(NSString* ) docArticleArrayexternelId
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/docs",MY_SEARCH_SERVER];
    return url;
}

+(NSString *) checkDocumentStatus
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/docsearch/askforstatus/",MY_SEARCH_SERVER];
    return url;
}
+(NSString *) checkUserInfo
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/baseInfoVerified",MY_SEARCH_SERVER];
    return url;
}
+(NSString *) getUserInfo
{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/userInfo2",MY_SEARCH_SERVER];
    return url;
}

+ (NSString *)findPasswordByEmail{
    //    NSString* url = [NSString stringWithFormat:@"http://%@/client/Password:findViaEmail",NEW_SERVER];
    NSString* url = [NSString stringWithFormat:@"http://%@/MobilePassword:findViaEmail",NEW_SERVER];
    return url;
}

+ (NSString *)findPasswordByMobil{
    NSString* url = [NSString stringWithFormat:@"http://%@/Password:findViaMobile",NEW_SERVER];
    return url;
}

+ (NSString *)checkActivationCode{
    NSString *url = [NSString stringWithFormat:@"http://%@/Password:checkActivationCode",NEW_SERVER];
    
    return url;
}

+ (NSString *)getDailylimit{
    NSString *url = [NSString stringWithFormat:@"http://%@/client/Profile:dailylimit",NEW_SERVER];
    
    return url;
}

+ (NSString *)resetUsePassword{
    NSString* url = [NSString stringWithFormat:@"http://%@/Password:resetViaMobile",NEW_SERVER];
    return url;
}

+ (NSString *)saveUserInfo{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/Profile",NEW_SERVER];
    return url;
}

+ (NSString *)mobileActiveInfo:(NSString *)mobileNum{
    NSString* url = [NSString stringWithFormat:@"http://%@/SignUp/requestMobileVerifyCode/%@/",NEW_SERVER,mobileNum];
    return url;
}

+ (NSString *)mobileActiveCheck{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/Profile:mobile",NEW_SERVER];
    return url;
}

+ (NSString *)emailActiveAccount{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/Profile:sendVerifyEmail",NEW_SERVER];
    return url;
}

+ (NSString *)emailModifyAccount{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/Profile:requestUpdateEmail",NEW_SERVER];
    return url;
}

+ (NSString *)verifyDocCardNum{
    NSString* url = [NSString stringWithFormat:@"http://%@/client/Profile:vcard",NEW_SERVER];
    return url;
}

+ (NSString *)getInviteesInfo{
    NSString *url = [NSString stringWithFormat:@"http://%@/client/Profile:invitees",NEW_SERVER];
    return url;
}

+ (NSString *)invitedFriendBy:(NSString *)uid{
    NSString *url = [NSString stringWithFormat:@"http://%@/Welcome?invitedBy=%@",NEW_SERVER,uid];
    return url;
}
+(NSString* ) docDownloadCN:(NSString*)externelId
{
  NSString *url = [NSString stringWithFormat:@"http://%@/docsearch/getDocFulltext/%@",MY_SEARCH_SERVER,externelId];
  return url;
}
@end
