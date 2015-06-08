//
//  UrlRequest.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-15.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface UrlRequest : NSObject
//+(ASIHTTPRequest*) getUserInfo:(NSString*)url delegate:(id)dlgt;
+(ASIHTTPRequest*) sendPadWithTokenWithUserInfo:(NSString*)url userInfo:(NSDictionary*)userInfo delegate:(id)dlgt;
+(ASIHTTPRequest*) checkMobile:(NSString*)url delegate:(id)dlgt;
+(ASIHTTPRequest*) sendUpData:(NSString*)url delegate:(id)dlgt;
+(ASIHTTPRequest*) send:(NSString*)url mutArray:(NSMutableArray *)mtarray delegate:(id)dlgt;
+(ASIHTTPRequest*) send:(NSString*)url delegate:(id)dlgt;

+(ASIHTTPRequest*) sendPostWithUserInfo:(NSString*)url data:(NSMutableDictionary*)data userInfo:(NSDictionary*)userInfo delegate:(id)dlgt;

+(ASIHTTPRequest*) sendPost:(NSString*)url data:(NSMutableDictionary*)data delegate:(id)dlgt;

+(ASIHTTPRequest*) sendPostDataInBody:(NSString*)url data:(NSMutableDictionary*)data delegate:(id)dlgt;

+(ASIHTTPRequest*) sendWithTokenWithUserInfo:(NSString*)url userInfo:(NSDictionary*)userInfo delegate:(id)dlgt;

+(ASIHTTPRequest*) sendWithToken:(NSString*)url delegate:(id)dlgt;
+(ASIHTTPRequest*) downloadCNFile:(NSString*)externalId delegate:(id)dlgt;
+(ASIHTTPRequest*) sendPostFeedBack:(NSString*)url data:(NSMutableDictionary*)data delegate:(id)dlgt;
/**
 *  发送请求到后台，带上ipad的token
 *
 *  @param url   请求的url
 *  @param dlgt delegate设置
 *
 *  @return 请求的asi
 */
+(ASIHTTPRequest*) sendWithPadToken:(NSString*)url delegate:(id)dlgt;

+(NSDictionary*) getJsonValue:(ASIHTTPRequest* )request;

+(NSDictionary*) getJsonValueFromString:(NSString* )string;

+(NSArray*) getJsonArrayValue:(ASIHTTPRequest* )request;

+(ASIHTTPRequest*) askForPdf:(NSString*)externalId delegate:(id)dlgt;

+(ASIHTTPRequest*) downloadFile:(NSString*)externalId delegate:(id)dlgt;

+(ASIHTTPRequest*)requestDoc:(NSString*)externalId title:(NSString*)title delegate:(id)dlgt;

+(void) setToken:(ASIHTTPRequest*) request;
+(void) setPadToken:(ASIHTTPRequest*) request;

+(NSString*) getDownloadFilePath:(NSString*)externalId;

+(NSString*) getCachePath:(NSString*)externalId;

+(BOOL) clearCache;

+(NSString*) getSavedFilePath:(NSString*)externalId;

+(BOOL) isWiFi;
+(ASIHTTPRequest*) sendProvince:(NSString*)url delegate:(id)dlgt;
@end
