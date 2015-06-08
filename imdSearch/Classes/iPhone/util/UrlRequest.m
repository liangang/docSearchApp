//
//  UrlRequest.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-15.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "UrlRequest.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "JSON.h"
#import "myUrl.h"
#import "imdSearchAppDelegate.h"
#import "imdSearchAppDelegate_iPhone.h"
#import "imdSearchAppDelegate_iPad.h"
#import "Strings.h"
#import "ImdUrlPath.h"
#import "UserManager.h"
#import "Reachability.h"
#import "ReaderDocument.h"


@implementation UrlRequest
+(ASIHTTPRequest*) sendPadWithTokenWithUserInfo:(NSString*)url userInfo:(NSDictionary*)userInfo delegate:(id)dlgt
{
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
  [ASIHTTPRequest setSessionCookies:nil];
  [request setUserInfo:userInfo];
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  imdSearchAppDelegate_iPad *appDelegate = (imdSearchAppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
  NSString* token = appDelegate.auth.imdToken;
  NSLog(@"Token %@", token);
  if (token != nil) {
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:token forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *systemverson = [[UIDevice currentDevice] systemVersion];
    [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];

      //[request setUserAgent:IOS_USER_AGENT_IPAD];
  }
  
  if (dlgt != nil) {
    request.delegate = dlgt;
    [request startAsynchronous];
  } else {
    [request start];
  }
  return request;
  
}

+(ASIHTTPRequest*) checkMobile:(NSString*)url delegate:(id)dlgt
{
    ASIHTTPRequest *request =
    [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    NSDictionary* userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:@"getMobile",@"checktype" ,nil];
    [request setUserInfo:userInfo];
    request.delegate = dlgt;
    [request startAsynchronous];
    return request;
}
+(ASIHTTPRequest*) sendProvince:(NSString*)url delegate:(id)dlgt
{
    ASIHTTPRequest *request =
    [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    request.delegate = dlgt;
    [request startAsynchronous];
    return request;
}
+(ASIHTTPRequest*) sendUpData:(NSString*)url delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    [UrlRequest setToken:request];
    request.delegate = dlgt;
    [request startAsynchronous];
    
    return request;
}
+(ASIHTTPRequest*) send:(NSString*)url mutArray:(NSMutableArray *)mtarray delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[[mtarray JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]] ;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [UrlRequest setToken:request];
    request.delegate = dlgt;
    [request startAsynchronous];
    
    return request;
}


+(ASIHTTPRequest*) send:(NSString*)url delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    NSDictionary* userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:@"getUserInfo",@"key" ,nil];
    [request setUserInfo:userInfo];
    [UrlRequest setToken:request];
    request.delegate = dlgt;
    [request startAsynchronous];
    
    return request;
}
+(ASIHTTPRequest*) sendPostWithUserInfo:(NSString*)url data:(NSMutableDictionary*)data userInfo:(NSDictionary*)userInfo delegate:(id)dlgt
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [ASIHTTPRequest setSessionCookies:nil];

    // [request setUserInfo:userInfo];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    NSString* token = appDelegate.myAuth.imdToken;
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
      NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
      NSString *systemverson = [[UIDevice currentDevice] systemVersion];
      [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];
    }
    
    request.delegate = dlgt;
    [request setRequestMethod:@"POST"];
    [request setUserInfo:userInfo];
    NSArray* keys = [data allKeys];
    for (int i = 0; i < [keys count]; i++) {
        [request addPostValue:[data objectForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
    }
    [request startAsynchronous];
    
    return request;
}


+(ASIHTTPRequest*) sendPost:(NSString*)url data:(NSMutableDictionary*)data delegate:(id)dlgt
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [ASIHTTPRequest setSessionCookies:nil];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    NSString* token = appDelegate.myAuth.imdToken;
    NSLog(@"Token %@", token);
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        
      NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
      NSString *systemverson = [[UIDevice currentDevice] systemVersion];
      [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];

    }
    
    request.delegate = dlgt;
    [request setRequestMethod:@"POST"];
    [request appendPostData:[[data JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //    NSArray* keys = [data allKeys];
    //    for (int i = 0; i < [keys count]; i++) {
    //        [request addPostValue:[data objectForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
    //     }
    [request startAsynchronous];
    
    return request;
}
+(ASIHTTPRequest*) sendPostFeedBack:(NSString*)url data:(NSMutableDictionary*)data delegate:(id)dlgt
{
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
  [ASIHTTPRequest setSessionCookies:nil];
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
  NSString* token = appDelegate.myAuth.imdToken;
  NSLog(@"Token %@", token);
  if (token != nil) {
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:token forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *systemverson = [[UIDevice currentDevice] systemVersion];
    [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];

  }
  
  request.delegate = dlgt;
  [request setRequestMethod:@"POST"];
    //[request appendPostData:[[data JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
  
  NSArray* keys = [data allKeys];
  for (int i = 0; i < [keys count]; i++) {
    [request addPostValue:[data objectForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
   }
  [request startAsynchronous];
  
  return request;
}

+(ASIHTTPRequest*) sendPostDataInBody:(NSString*)url data:(NSMutableDictionary*)data delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    request.delegate = dlgt;
    [request setRequestMethod:@"POST"];
    [UrlRequest setToken:request];
    [request appendPostData:[[data JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding ]];
    
    
    [request startAsynchronous];
    return request;
}

+(ASIHTTPRequest*) sendWithTokenWithUserInfo:(NSString*)url userInfo:(NSDictionary*)userInfo delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [ASIHTTPRequest setSessionCookies:nil];
    [request setUserInfo:userInfo];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    NSString* token = appDelegate.myAuth.imdToken;
    NSLog(@"Token %@", token);
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
      NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
      NSString *systemverson = [[UIDevice currentDevice] systemVersion];
      [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];

    }
    
    if (dlgt != nil) {
        request.delegate = dlgt;
        [request startAsynchronous];
    } else {
        [request start];
    }
    return request;
    
}


+(ASIHTTPRequest*) sendWithToken:(NSString*)url delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [ASIHTTPRequest setSessionCookies:nil];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    NSString* token = appDelegate.myAuth.imdToken;
    NSLog(@"Token %@", token);
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        
        [request setUseCookiePersistence:NO];
        
      NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
      NSString *systemverson = [[UIDevice currentDevice] systemVersion];
      [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];

    }
    
    if (dlgt != nil) {
        request.delegate = dlgt;
        [request startAsynchronous];
    } else {
        [request start];
    }
    
    return request;
}

+(ASIHTTPRequest*) sendWithPadToken:(NSString*)url delegate:(id)dlgt{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [ASIHTTPRequest setSessionCookies:nil];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    imdSearchAppDelegate_iPad *appDelegate = (imdSearchAppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
    NSString* token = appDelegate.auth.imdToken;
    NSLog(@"Token %@", token);
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        
        [request setUseCookiePersistence:NO];
      
      NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
      NSString *systemverson = [[UIDevice currentDevice] systemVersion];
      [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];

        // [request setUserAgent:IOS_USER_AGENT_IPAD];
    }
    
    if (dlgt != nil) {
        request.delegate = dlgt;
        request.timeOutSeconds = 6000;
        [request startAsynchronous];
    } else {
        [request start];
    }
    
    return request;
    
}

+(ASIHTTPRequest*) downloadFile:(NSString*)externalId delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath docDownloadUrl:externalId]]];
    request.timeOutSeconds = 120;
    
  NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  NSString *systemverson = [[UIDevice currentDevice] systemVersion];
  [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];

  
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    [request setDownloadDestinationPath:[UrlRequest getDownloadFilePath:externalId]];
    [request setDownloadProgressDelegate:dlgt];
    request.showAccurateProgress=YES;
    [UrlRequest setToken:request];
    NSDictionary* userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:@"getPDF",@"key" ,nil];
    [request setUserInfo:userInfo];
    request.delegate = dlgt;
    [request startAsynchronous];
    
    return request;
}
+(ASIHTTPRequest*) downloadCNFile:(NSString*)externalId delegate:(id)dlgt
{
  ASIHTTPRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath docDownloadCN:externalId]]];
  request.timeOutSeconds = 120;
  
  NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  NSString *systemverson = [[UIDevice currentDevice] systemVersion];
  [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];

  
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  [request setDownloadDestinationPath:[UrlRequest getDownloadFilePath:externalId]];
  [request setDownloadProgressDelegate:dlgt];
  request.showAccurateProgress=YES;
  [UrlRequest setToken:request];
  NSDictionary* userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:@"getPDF",@"key" ,nil];
  [request setUserInfo:userInfo];
  request.delegate = dlgt;
  [request startAsynchronous];
  
  return request;
}
+(ASIHTTPRequest*) askForPdf:(NSString*)externalId delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath docAskForPdfUrl:externalId]]];
    request.timeOutSeconds = 120;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    [request setDownloadDestinationPath:[UrlRequest getDownloadFilePath:externalId]];
    NSLog(@"DL: %@", [UrlRequest getDownloadFilePath:externalId]);
    [UrlRequest setToken:request];
    
    //To avoid the request doc without ios version.
    [request setUserAgent:[ASIHTTPRequest defaultUserAgentString]];
    NSDictionary* userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:@"getPDF",@"key" ,nil];
    [request setUserInfo:userInfo];
    request.delegate = dlgt;
    [request startAsynchronous];
    
    return request;
}

+ (ASIHTTPRequest*)requestDoc:(NSString*)externalId title:(NSString*)title delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath docRequestUrl:externalId title:title]]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    NSLog(@"%@", [ImdUrlPath docRequestUrl:externalId title:title]);
    [UrlRequest setToken:request];
    
    request.delegate = dlgt;
    [request startAsynchronous];
    return request;
}

+(NSString*) getDownloadFilePath:(NSString*)externalId
{
    NSString* fileName =[NSString stringWithFormat:@"%@-pdf", externalId];
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:fileName];
}

+(NSString*) getCachePath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/"];
}

+(BOOL) clearCache
{
    NSError *error = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString* support = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/"];
    
    
    BOOL ret = YES;
    for (NSString* file in [fm contentsOfDirectoryAtPath:support error:&error]) {
        NSString* filePath = [NSString stringWithFormat:@"%@/%@", support, file];
        
        BOOL success = [fm removeItemAtPath:filePath error:&error];
        if (!success || error) {
            ret = NO;
            NSLog(@"Error: %@", error.localizedDescription);
        }
        NSLog(@"remove support file : %@", filePath);
    }
    
    for (NSString* file in [fm contentsOfDirectoryAtPath:[self getCachePath] error:&error]) {
        NSString* filePath = [NSString stringWithFormat:@"%@/%@", [self getCachePath], file];
        
        BOOL success = [fm removeItemAtPath:filePath error:&error];
        if (!success || error) {
            ret = NO;
            NSLog(@"Error: %@", error.localizedDescription);
        }
        NSLog(@"remove file: %@", filePath);
    }
    return ret;
}


+(NSString*) getSavedFilePath:(NSString*)externalId
{
    NSString* fileName =[NSString stringWithFormat:@"%@", externalId];
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
}

+(void) setToken:(ASIHTTPRequest*) request
{
    
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    NSString* token = appDelegate.myAuth.imdToken;
    
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSLog(@"Token %@", token);
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
      NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
      NSString *systemverson = [[UIDevice currentDevice] systemVersion];
      [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];
    }
}

+(void) setPadToken:(ASIHTTPRequest*) request{
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    //Create a cookie
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        
        [properties setValue:[NSString stringWithFormat:@".%@",CONFIRM_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
      NSString *curdic = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
      NSString *systemverson = [[UIDevice currentDevice] systemVersion];
      [request setUserAgent:[NSString stringWithFormat:IOS_USER_AGENT_IPAD,curdic,systemverson]];

        //[request setUserAgent:IOS_USER_AGENT_IPAD];
    }
}

+(NSDictionary*) getJsonValue:(ASIHTTPRequest* )request
{
    //NSData * responseData =[request rawResponseData];
    //NSString* responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSString* responseString = [request responseString];
    NSDictionary* info = nil;
    if (responseString != nil && responseString.length > 0) {
        info =[responseString JSONValue];
    }
    return info;
}

+(NSDictionary*) getJsonValueFromString:(NSString* )string
{
    //NSData * responseData =[request rawResponseData];
    //NSString* responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@", responseString);
    NSDictionary* info = nil;
    if (string != nil && string.length > 0) {
        info =[string JSONValue];
    }
    return info;
}


+(NSArray*) getJsonArrayValue:(ASIHTTPRequest* )request
{
    //NSData * responseData =[request rawResponseData];
    //NSString* responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSString* responseString = [request responseString];
    //NSLog(@"%@", responseString);
    NSArray* info = nil;
    if (responseString != nil && responseString.length > 0) {
        info =[responseString JSONValue];
    }
    return info;
}

+(BOOL) isWiFi
{
    Reachability* r = [Reachability reachabilityWithHostName:MY_AUTH_SERVER];
    
    BOOL isWiFi = NO;
    switch ([r currentReachabilityStatus]) {
        case NotReachable: {
            NSLog(@"Access Not Available");
            isWiFi = NO;
            break;
        }            
        case ReachableViaWWAN: {
            NSLog(@"Reachable WWAN");
            isWiFi = NO;
            break;
        }
        case ReachableViaWiFi: {
            NSLog(@"Reachable WiFi");
            isWiFi = YES;
            break;
        }
    }
    return isWiFi;
}
@end
