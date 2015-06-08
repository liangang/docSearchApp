    //
    //  MyDatabase.h
    //  imdSearch
    //
    //  Created by  侯建政 on 6/29/12.
    //  Copyright (c) 2012 i-md.com. All rights reserved.
    //

#import <Foundation/Foundation.h>
#import "sqlite3.h"

#define databataName    @"my.sqlite"
@interface MyDatabase : NSObject

+(void)creatDatabase;
+(NSString *)databataPath;
+(BOOL)connDatabase;
+(void)insertMySearchValue:(NSString *)author externalId:(NSString *)externalId issue:(NSString *)issue journal:(NSString *)journal pagination:(NSString *)pagination pubDate:(NSString *)pubDate title:(NSString *)title userid:(NSString *)userid ismgr:(NSString *)ismgr volume:(NSString *)volume;
+(void)cleanTable:(NSString *)tablename ismgr:(NSString *)ismgr userid:(NSString *)userid;
+(NSMutableArray *) readMgrData:(NSString *)ismgr userid:(NSString *)userid;
+(void)insertDocValue:(NSString *)CKID WFID:(NSString *)WFID WPID:(NSString *)WPID PMID:(NSString *)PMID text:(NSString *)text affiliation:(NSString *)affiliation author:(NSString *)author category:(NSString *)category citation:(NSString *)citation coreJournal:(NSString *)coreJournal externalId:(NSString *)externalId iid:(NSString *)iid issue:(NSString *)issue journal:(NSString *)journal keywords:(NSString *)keywords machineCategory:(NSString *)machineCategory numCited:(NSString *)numCited pagination:(NSString *)pagination pubDate:(NSString *)pubDate reference:(NSString *)reference referenceCount:(NSString *)referenceCount title:(NSString *)title volume:(NSString *)volume ismgr:(NSString *)ismgr filePath:(NSString *)filePath;

+(void)updateDocValue:(NSString *)CKID WFID:(NSString *)WFID WPID:(NSString *)WPID text:(NSString *)text affiliation:(NSString *)affiliation author:(NSString *)author category:(NSString *)category citation:(NSString *)citation coreJournal:(NSString *)coreJournal externalId:(NSString *)externalId iid:(NSString *)iid issue:(NSString *)issue journal:(NSString *)journal keywords:(NSString *)keywords machineCategory:(NSString *)machineCategory numCited:(NSString *)numCited pagination:(NSString *)pagination pubDate:(NSString *)pubDate reference:(NSString *)reference referenceCount:(NSString *)referenceCount title:(NSString *)title volume:(NSString *)volume ismgr:(NSString *)ismgr;
+(NSMutableDictionary *) readDocData:(NSString *)ismgr externalId:(NSString *)externalId;
+(BOOL)isSelectId:(NSString *)externalId ismgr:(NSString *)ismgr;
+(void)cleanFav:(NSString *)tablename ismgr:(NSString *)ismgr externalId:(NSString *)externalId userid:(NSString *)userid;
+(NSMutableArray *) readDocData:(NSString *)ismgr;
+(void)insertMyHistorTable:(NSString *)searchresult kind:(NSString *)kind userid:(NSString *)userid;
+(void)cleanHistoryTable:(NSString *)userid;
+(NSMutableArray *) readHistoryData:(NSString *)userid;
+(BOOL)isExistHistorylist:(NSString *)searchValue kind:(NSString *)kind userid:(NSString *)userid;
+(void)cleanMySearchTable:(NSString *)ismgr userid:(NSString *)userid;
+(BOOL)isSelectId:(NSString *)externalId ismgr:(NSString *)ismgr userid:(NSString *)userid;
+(void)cleanLocalTable:(NSString *)externalId userid:(NSString *)userid;
+(NSMutableArray *) readAskData:(NSString *)ismgr userid:(NSString *)userid;
@end
