//
//  myDatabaseOption.h
//  imdSearch
//
//  Created by Lion User on 12-7-20.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocDetail.h"

@interface myDatabaseOption : NSObject

+(void)docuSave:(NSMutableDictionary *)info;
+(NSMutableDictionary *)getDetail:(NSString *)externalId;
+(BOOL)isMobileActive:(NSString *)username;
+(BOOL)isMailActive:(NSString *)username;
+(BOOL)isFav:(NSString *)externalId;
+(void)addFav:(NSString *)externalId author:(NSString *)author issue:(NSString *)issue journal:(NSString *)journal pubDate:(NSString *)pubDate title:(NSString *)title volume:(NSString *)volume pagination:(NSString *)pagination;
+(void)removeFav:(NSString *)externalId;

+(void)favsSave:(NSMutableArray *)info;
+(NSMutableArray *)getFavs;

+(void)askedSave:(NSMutableArray *)info;
+(NSMutableArray *)getAsked;

+(void)searchDetail:(NSString *)externalId;
+(NSArray *)getReads;
+(BOOL)isRead:(NSString *)externalId;

+(void)changeOlderVision;
+(void)savedDoc:(NSDictionary *)docInfo;
+(NSMutableArray *)getSavedDoc;
+(void)removeSavedDoc:(NSString *)externalId;
+(BOOL)isSaved:(NSString *)externalId;
+(BOOL)isSavedDocWithAnother:(NSString *)externalId;
@end
