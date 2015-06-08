//
//  searchHistory.h
//  imdSearch
//
//  Created by 8fox on 10/25/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MAX_HISTORY 15

@interface searchHistory : NSObject
{


}

+(int)getAvailbleHistoryPos;
+(void)saveSearchHistory:(NSString*)searchWord Language:(NSString*)Lan;
+(void)removeSearchHistory:(NSString*)searchWord Language:(NSString*)Lan;
/**
 *  获取搜索历史
 *
 *  @return 搜索的历史
 */
+ (NSMutableArray *)getSavedSearchHistory;

+(NSString*)getSavedSearchHistory:(int)pos;
+(int)getHistoryCount;
+(void)clearHistory;

+(void)displayData;
@end
