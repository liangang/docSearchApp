//
//  imdiPadDatabase.h
//  imdSearch
//
//  Created by Lion User on 12-7-17.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

#define databaseName @"iPadDB001.sqlite"

@interface imdiPadDatabase : NSObject
+(void)createDatabase;
+(NSString *)databasePath;
+(BOOL)connDatabase;
+(void)closeDatabase;
+(void)throwDatabaseException:(char *)errorMsg;

  //-- SavedDocTable
+(void)insertSavedDocTable:(NSString *)externalId username:(NSString *)username affiliation:(NSString *)affiliation author:(NSString *)author issue:(NSString *)issue journal:(NSString *)journal pagination:(NSString *)pagination pubdate:(NSString *)pubdate title:(NSString *)title volume:(NSString *)volume text:(NSString *)text background:(NSString *)background objective:(NSString *)objective methods:(NSString *)methods results:(NSString *)results conclusions:(NSString *)conclusions copyrights:(NSString *)copyrights keywords:(NSString *)keywords;
+(void)deleteSavedDocTable:(NSString *)whereSql;
+(NSMutableArray *)selectSavedDocTable:(NSString *)whereSql;
+(BOOL)isSelectId:(NSString *)externalId userName:(NSString *)name;
  //-- DocTable
+(void)insertDocTable:(NSString *)externalID CKID:(NSString *)CKID WFID:(NSString *)WFID WPID:(NSString *)WPID PMID:(NSString *)PMID text:(NSString *)text background:(NSString *)background objective:(NSString *)objective methods:(NSString *)methods results:(NSString *)results conclusions:(NSString *)conclusions copyrights:(NSString *)copyrights affiliation:(NSString *)affiliation author:(NSString *)author category:(NSString *)category citation:(NSString *)citation corejournal:(NSString *)corejournal iid:(NSString *)iid issue:(NSString *)issue journal:(NSString *)journal keywords:(NSString *)keywords machineCategory:(NSString *)machineCategory numcited:(NSString *)numcited pagination:(NSString *)pageination pubDate:(NSString *)pubDate reference:(NSString *)reference referenceCount:(NSString *)referenceCount title:(NSString *)title volume:(NSString *)volume ISSN:(NSString *)ISSN;
+(void)updateDocTable:(NSString *)externalID CKID:(NSString *)CKID WFID:(NSString *)WFID WPID:(NSString *)WPID PMID:(NSString *)PMID text:(NSString *)text background:(NSString *)background objective:(NSString *)objective methods:(NSString *)methods results:(NSString *)results conclusions:(NSString *)conclusions copyrights:(NSString *)copyrights affiliation:(NSString *)affiliation author:(NSString *)author category:(NSString *)category citation:(NSString *)citation corejournal:(NSString *)corejournal iid:(NSString *)iid issue:(NSString *)issue journal:(NSString *)journal keywords:(NSString *)keywords machineCategory:(NSString *)machineCategory numcited:(NSString *)numcited pagination:(NSString *)pageination pubDate:(NSString *)pubDate reference:(NSString *)reference referenceCount:(NSString *)referenceCount title:(NSString *)title volume:(NSString *)volume ISSN:(NSString *)ISSN whereSql:(NSString *)whereSql;
+(void)deleteDocTable:(NSString *)whereSql;
+(NSMutableDictionary *)selectDocTable:(NSString *)externalId;
+(NSMutableArray *)selectDocsTable:(NSString *)whereSql;

  //-- AskforListTable
+(void)insertAskforListTable:(NSString *)externalId username:(NSString *)username status:(NSString *)status pmid:(NSString *)pmid requestTime:(NSString *)requestTime author:(NSString *)author issue:(NSString *)issue journal:(NSString *)journal pagination:(NSString *)pagination pubdate:(NSString *)pubdate title:(NSString *)title volume:(NSString *)volume;
+(void)updateAskforListTable:(NSString *)status whereSql:(NSString *)whereSql;
+(void)deleteAskforListTable:(NSString *)whereSql;
+(NSMutableArray *)selectAskforTable:(NSString *)whereSql;

  //-- FavListTable
+(void)insertFavListTable:(NSString *)externalId username:(NSString *)username author:(NSString *)author issue:(NSString *)issue journal:(NSString *)journal pubDate:(NSString *)pubDate title:(NSString *)title volume:(NSString *)volume pagination:(NSString *)pagination;
+(void)updateFavListTable:(NSString *)externalId username:(NSString *)username whereSql:(NSString *)whereSql;
+(void)deleteFavListTable:(NSString *)whereSql;
+(NSMutableArray *)selectFavListTable:(NSString *)whereSql;

  //-- HistoryListTable
+(void)insertHistoryListTable:(NSString *)searchword language:(NSString *)language username:(NSString *)username;
+(void)updateHistoryListTable:(NSString *)searchword language:(NSString *)language username:(NSString *)username whereSql:(NSString *)whereSql;
+(void)deleteHistoryListTable:(NSString *)whereSql;
+(NSMutableArray *)selectHistoryListTable:(NSString *)whereSql;

  //-- SearchListTable
+(void)insertSearchListTable:(NSString *)externalId username:(NSString *)username sort:(NSString *)sort;
+(void)updateSearchListTable:(NSString *)externalId username:(NSString *)username sort:(NSString *)sort whereSql:(NSString *)whereSql;
+(void)deleteSearchListTable:(NSString *)whereSql;
+(NSMutableArray *)selectSearchListTable:(NSString *)whereSql;

  //-- DetailTable
+(void)insertDetailTable:(NSString *)externalId username:(NSString *)username;
+(void)updateDetailTable:(NSString *)externalId username:(NSString *)username whereSql:(NSString *)whereSql;
+(void)deleteDetailTable:(NSString *)whereSql;
+(NSMutableArray *)selectDetailTable:(NSString *)whereSql;

  //-- UsernameTable
+(void)insertUsernameTable:(NSString *)username email:(NSString *)email mobile:(NSString *)mobile;
+(void)updateUsernameTable:(NSString *)username email:(NSString *)email mobile:(NSString *)mobile whereSql:(NSString *)whereSql;
+(void)deleteUsernameTable:(NSString *)whereSql;
+(NSMutableArray *)selectUsernameTable:(NSString *)whereSql;

@end
