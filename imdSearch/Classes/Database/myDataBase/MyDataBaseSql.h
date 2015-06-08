//
//  MyDataBaseSql.h
//  imdSearch
//
//  Created by  侯建政 on 7/3/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyDataBaseSql : NSObject

+(void) insertDetail:(NSMutableDictionary *)resultsJson ismgr:(NSString *)ismgr filePath:(NSString *)filePath;
+(void) insertMySearch:(NSMutableDictionary *)resultsJson ismgr:(NSString *)ismgr;
+(void) insertMyHistory:(NSMutableDictionary *)fullText userid:(NSString *)userid;
@end
