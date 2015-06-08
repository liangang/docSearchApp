//
//  imdiPadDatabase.m
//  imdSearch
//
//  Created by Lion User on 12-7-17.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "imdiPadDatabase.h"
#import "DatabaseException.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "Url_iPad.h"
#import "DocDetail.h"

@implementation imdiPadDatabase
sqlite3 *iPadDb;
char *error;

+(NSString *)databasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:databaseName];
}

+(BOOL)connDatabase{
	if (sqlite3_open([[imdiPadDatabase databasePath] UTF8String], &iPadDb) != SQLITE_OK) {
        sqlite3_close(iPadDb);
		return NO;
    }else{
		return YES;
	}
}

#pragma mark - create table
+(void)createDatabase
{
    if ([self connDatabase]) {
        NSString *createSearchListTable = @"create table if not exists SearchListTable (externalId text, username text, sort text);";
        NSString *createFavListTable = @"create table if not exists FavListTable (externalId text, username text, author text, issue text, journal text, pubDate text, title text, volume text, pagination text);";
        NSString *createAskforListTable = @"create table if not exists AskforListTable (externalId text,username text, status text, pmid text, requestTime text, author text, issue text, journal text, pagination text, pubdate text, title text,volume text);";
        NSString *createHistoryListTable = @"create table if not exists HistoryListTable (searchword text, language text, username text);";
        NSString *createDocumentDetailTable = @"CREATE TABLE IF NOT EXISTS DocTable (externalId text primary key, CKID text,WFID text,WPID text,PMID text,text text,background text,objective text,methods text,results text,conclusions text,copyrights text,affiliation text,author text,category text,citation text,coreJournal text, iid text,issue text,journal text,keywords text,machineCategory text,numCited text,pagination text,pubDate text,reference text,referenceCount text,title text,volume text,ISSN text);";
        NSString *createDetailTable = @"create table if not exists DetailTable (externalId text, username text);";
        NSString *createUsernameTable = @"create table if not exists UsernameTable (username text primary key, email text, mobile text);";
        NSString *createHasSavedDocTable = @"create table if not exists SavedDocTable (externalId text,username text, affiliation text, author text, issue text, journal text, pagination text, pubdate text, title text,volume text,text text,background text,objective text,methods text,results text,conclusions text,copyrights text,keywords text);";
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [createUsernameTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                [self throwDatabaseException:errorMsg];
            }
            if (sqlite3_exec(iPadDb, [createSearchListTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
            
            if (sqlite3_exec(iPadDb, [createFavListTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
            
            if (sqlite3_exec(iPadDb, [createAskforListTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
            if (sqlite3_exec(iPadDb, [createHistoryListTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
            if (sqlite3_exec(iPadDb, [createDocumentDetailTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
            if (sqlite3_exec(iPadDb, [createDetailTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
            if (sqlite3_exec(iPadDb, [createHasSavedDocTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Data：%@", exception.name);
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
        
    }
}

+(void)closeDatabase
{
    sqlite3_close(iPadDb);
}

+(void)throwDatabaseException:(char *)errorMsg
{
    NSString *msg = [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding];
    NSException *e = [DatabaseException exceptionWithName:@"iPadDatabaseException" reason:msg userInfo:nil];
    @throw e;
}

#pragma mark -- SavedDocTable
+(void)insertSavedDocTable:(NSString *)externalId username:(NSString *)username affiliation:(NSString *)affiliation author:(NSString *)author issue:(NSString *)issue journal:(NSString *)journal pagination:(NSString *)pagination pubdate:(NSString *)pubdate title:(NSString *)title volume:(NSString *)volume text:(NSString *)text background:(NSString *)background objective:(NSString *)objective methods:(NSString *)methods results:(NSString *)results conclusions:(NSString *)conclusions copyrights:(NSString *)copyrights keywords:(NSString *)keywords
{
    if (externalId == nil || [externalId isEqualToString:@""] ||
        username == nil || [username isEqualToString:@""]) {
        char *errorMsg = "insertAskforListTable params error";
        [self throwDatabaseException:errorMsg];
    }
    if (affiliation == nil) {
        affiliation = @"";
    }
    if (author == nil) {
        author = @"";
    }
    if (issue == nil) {
        issue = @"";
    }
    if (journal == nil) {
        journal = @"";
    }
    if (pagination == nil) {
        pagination = @"";
    }
    if (pubdate == nil) {
        pubdate = @"";
    }
    if (title == nil) {
        title = @"";
    }
    if (volume == nil) {
        volume = @"";
    }
    if (text == nil) {
        text = @"";
    }
    if (background == nil) {
        background = @"";
    }
    if (objective == nil) {
        objective = @"";
    }
    if (methods == nil) {
        methods = @"";
    }
    if (results == nil) {
        results = @"";
    }
    if (conclusions == nil) {
        conclusions = @"";
    }
    if (copyrights == nil) {
        copyrights = @"";
    }
    if (keywords == nil) {
        keywords = @"";
    }
    if ([self connDatabase]) {
        NSString *insterSQL = [NSString stringWithFormat:@"insert into SavedDocTable  (externalId,username,affiliation, author, issue, journal, pagination, pubdate,title, volume,text,background,objective,methods,results,conclusions,copyrights,keywords) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",externalId,username,affiliation,author,issue,journal,pagination,pubdate,title,volume,text,background,objective,methods,results,conclusions,copyrights,keywords];
        
        const char *insert_stmt = [insterSQL UTF8String];
        sqlite3_stmt *stmt;
        
        @try {
            if (sqlite3_prepare_v2(iPadDb, insert_stmt, -1, &stmt, NULL) == SQLITE_OK)
            {
                NSLog(@"sqlite3 prepare ok");
                if (sqlite3_step(stmt) == SQLITE_DONE)
                {
                    NSLog(@"sqlite3 step done");
                    sqlite3_finalize(stmt);
                }
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}

+(void)deleteSavedDocTable:(NSString *)whereSql
{
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *delete = [NSString stringWithFormat:@"delete from SavedDocTable %@;",where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(NSMutableArray *)selectSavedDocTable:(NSString *)whereSql
{
    NSMutableArray *askforArray = [[NSMutableArray alloc]init ];
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@",whereSql];
    }
    if ([self connDatabase]) {
        NSString *query = [NSString stringWithFormat:@"select externalId,username,affiliation, author, issue, journal, pagination, pubdate,title, volume,text,background,objective,methods,results,conclusions,copyrights,keywords from SavedDocTable %@;",where];
        sqlite3_stmt *stmt;
        @try {
            if (sqlite3_prepare_v2(iPadDb, [query UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
                //        char *errorMsg = "select askforListTable error";
                //        [self throwDatabaseException:errorMsg];
                return nil;
            }
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                char *eId = (char *)sqlite3_column_text(stmt, 0);
                char *un = (char *)sqlite3_column_text(stmt, 1);
                char *pmid = (char *)sqlite3_column_text(stmt, 2);
                char *author = (char *)sqlite3_column_text(stmt, 3);
                char *issue = (char *)sqlite3_column_text(stmt, 4);
                char *journal = (char *)sqlite3_column_text(stmt, 5);
                char *pagination = (char *)sqlite3_column_text(stmt, 6);
                char *pubdate = (char *)sqlite3_column_text(stmt, 7);
                char *title = (char *)sqlite3_column_text(stmt, 8);
                char *volume = (char *)sqlite3_column_text(stmt, 9);
                char *text = (char *)sqlite3_column_text(stmt, 10);
                char *background = (char *)sqlite3_column_text(stmt, 11);
                char *objective = (char *)sqlite3_column_text(stmt, 12);
                char *methods = (char *)sqlite3_column_text(stmt, 13);
                char *results = (char *)sqlite3_column_text(stmt, 14);
                char *conclusions = (char *)sqlite3_column_text(stmt, 15);
                char *copyrights = (char *)sqlite3_column_text(stmt, 16);
                char *keywords = (char *)sqlite3_column_text(stmt, 17);
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                if (un != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) un];
                    [dic setObject:tmp forKey:KEY_USERID];
                }
                if (pmid != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) pmid];
                    [dic setObject:tmp forKey:KEY_DOC_PMID];
                }
                if (eId != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) eId];
                    [dic setObject:tmp forKey:KEY_DOC_EXTERNALID];
                }
                if (author != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)author];
                    NSArray *authors = [tmp componentsSeparatedByString:SEPARATING];
                    [dic setObject:authors forKey:KEY_DOC_AUTHOR];
                }
                if (issue != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)issue];
                    [dic setObject:tmp forKey:KEY_DOC_ISSUE];
                }
                if (journal != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)journal];
                    [dic setObject:tmp forKey:KEY_DOC_JOURNAL];
                }
                if (pubdate != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)pubdate];
                    [dic setObject:tmp forKey:KEY_DOC_PUB_DATE];
                }
                if (title != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)title];
                    [dic setObject:tmp forKey:KEY_DOC_TITLE];
                }
                if (volume != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)volume];
                    [dic setObject:tmp forKey:KEY_DOC_VOLUME];
                }
                if (pagination != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)pagination];
                    [dic setObject:tmp forKey:KEY_DOC_PAGINATION];
                }
                NSMutableDictionary *nmd = [[NSMutableDictionary alloc]init];
                if (text != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)text];
                    NSArray *textArray = [temp componentsSeparatedByString:@"::"];
                    NSLog(@"textArray ==== %@", textArray);
                    if ([Util checkArrayContentWithString:textArray]) {
                        [nmd setObject:textArray forKey:ABSTRACT_TEXT];
                    }
                }
                if (background != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)background];
                    NSArray *bgArray = [temp componentsSeparatedByString:@"::"];
                    NSLog(@"bgArray ==== %@", bgArray);
                    if ([Util checkArrayContentWithString:bgArray]) {
                        [nmd setObject:bgArray forKey:ABSTRACT_BACKGROUND];
                    }
                }
                if (objective != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)objective];
                    NSArray *ojtArray = [temp componentsSeparatedByString:@"::"];
                    NSLog(@"ojtArray ==== %@", ojtArray);
                    if ([Util checkArrayContentWithString:ojtArray]) {
                        [nmd setObject:ojtArray forKey:ABSTRACT_OBJECTIVE];
                    }
                }
                if (methods != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)methods];
                    NSArray *mtdArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:mtdArray]) {
                        [nmd setObject:mtdArray forKey:ABSTRACT_METHODS];
                    }
                }
                if (results != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)results];
                    NSArray *resArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:resArray]) {
                        [nmd setObject:resArray forKey:ABSTRACT_RESULTS];
                    }
                }
                if (conclusions != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)conclusions];
                    NSArray *cclArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:cclArray]) {
                        [nmd setObject:cclArray forKey:ABSTRACT_CONCLUSIONS];
                    }
                }
                if (copyrights != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)copyrights];
                    NSArray *crArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:crArray]) {
                        [nmd setObject:crArray forKey:ABSTRACT_COPYRIGHTS];
                    }
                }
                [dic setObject:nmd forKey:KEY_DOC_ABSTRACTTEXT];
                if (keywords != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)keywords];
                    NSArray *kwArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:kwArray]) {
                        [dic setObject:kwArray forKey:@"keywords"];
                    }
                }
                [askforArray addObject:dic];
            }
            sqlite3_finalize(stmt);
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
    return askforArray;
}
+(BOOL)isSelectId:(NSString *)externalId userName:(NSString *)name
{
    NSMutableArray *mutArray = [[NSMutableArray alloc]init];
    BOOL isId;
    if([self connDatabase]){
		NSString *query3 = [NSString stringWithFormat:@"SELECT externalId FROM SavedDocTable where username='%@';",name] ;
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(iPadDb, [query3 UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
                char *externalId = (char *)sqlite3_column_text(statement, 0);
                if(externalId!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)externalId];
                    [mutArray addObject:temp];
                    
                }
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(iPadDb);
    }
    
    
    if (![mutArray count]) {
        isId = NO;
    }else {
        for (int i=0; i < [mutArray count]; i++) {
            if ([[mutArray objectAtIndex:i] isEqualToString:externalId]) {
                isId = YES;
                break;
            }else {
                isId = NO;
            }
        }
        
    }
    
    return isId;
}


#pragma mark -- UsernameTable
+(void)insertUsernameTable:(NSString *)username email:(NSString *)email mobile:(NSString *)mobile
{
    if (username == nil || [username isEqualToString:@""] ||
        email == nil || [email isEqualToString:@""] ||
        mobile == nil || [mobile isEqualToString:@""]) {
        char *errorMsg = "insertUsernameTable params error";
        [self throwDatabaseException:errorMsg];
    }
    if ([self connDatabase]) {
        NSString *insterSQL = [NSString stringWithFormat:@"insert into UsernameTable  (username,email,mobile) values (\"%@\",\"%@\",\"%@\")",username,email,mobile];
        
        const char *insert_stmt = [insterSQL UTF8String];
        sqlite3_stmt *stmt;
        
        @try {
            if (sqlite3_prepare_v2(iPadDb, insert_stmt, -1, &stmt, NULL) == SQLITE_OK)
            {
                NSLog(@"sqlite3 prepare ok");
                if (sqlite3_step(stmt) == SQLITE_DONE)
                {
                    NSLog(@"sqlite3 step done");
                    sqlite3_finalize(stmt);
                }
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)updateUsernameTable:(NSString *)username email:(NSString *)email mobile:(NSString *)mobile whereSql:(NSString *)whereSql
{
    if (username == nil || [username isEqualToString:@""] ||
        email == nil || [email isEqualToString:@""] ||
        mobile == nil || [mobile isEqualToString:@""]) {
        char *errorMsg = "updatUsernameTable params error";
        [self throwDatabaseException:errorMsg];
    }
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *update = [NSString stringWithFormat:@"update UsernameTable set username = ('%@'), email = ('%@'), mobile = ('%@') %@;",username,email,mobile,where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"errorMsg.");
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}

+(void)deleteUsernameTable:(NSString *)whereSql
{
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *delete = [NSString stringWithFormat:@"delete from UsernameTable %@;",where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}

+(NSMutableArray *)selectUsernameTable:(NSString *)whereSql
{
    NSMutableArray *unArray = [[NSMutableArray alloc]init ];
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@",whereSql];
    }
    if ([self connDatabase]) {
        NSString *query = [NSString stringWithFormat:@"select username, email, mobile from UsernameTable %@;",where];
        sqlite3_stmt *stmt;
        @try {
            if (sqlite3_prepare_v2(iPadDb, [query UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
                char *errorMsg = "select UernameTable error";
                [self throwDatabaseException:errorMsg];
            }
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                char *un = (char *)sqlite3_column_text(stmt, 0);
                char *em = (char *)sqlite3_column_text(stmt, 1);
                char *mo = (char *)sqlite3_column_int(stmt, 2);
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                if (un != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) un];
                    [dic setObject:tmp forKey:KEY_USERID];
                }
                if (em != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) em];
                    [dic setObject:tmp forKey:KEY_DOC_EMAIL_ACTIVE];
                }
                if (mo != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) mo];
                    [dic setObject:tmp forKey:KEY_DOC_MOBILE_ACTIVE];
                }
                [unArray addObject:dic];
            }
            sqlite3_finalize(stmt);
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
    return unArray;
}

#pragma mark -- HistoryListTable
+(void)insertHistoryListTable:(NSString *)searchword language:(NSString *)language username:(NSString *)username
{
    if (searchword == nil || [searchword isEqualToString:@""] ||
        language == nil || [language isEqualToString:@""] ||
        username == nil || [username isEqualToString:@""]) {
        char *errorMsg = "insertAskforListTable params error";
        [self throwDatabaseException:errorMsg];
    }
    if ([self connDatabase]) {
        NSString *insterSQL = [NSString stringWithFormat:@"insert into HistoryListTable  (searchword,language,username) values (\"%@\",\"%@\",\"%@\")",searchword,language,username];
        
        const char *insert_stmt = [insterSQL UTF8String];
        sqlite3_stmt *stmt;
        
        @try {
            if (sqlite3_prepare_v2(iPadDb, insert_stmt, -1, &stmt, NULL) == SQLITE_OK)
            {
                NSLog(@"sqlite3 prepare ok");
                if (sqlite3_step(stmt) == SQLITE_DONE)
                {
                    NSLog(@"sqlite3 step done");
                    sqlite3_finalize(stmt);
                }
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)updateHistoryListTable:(NSString *)searchword language:(NSString *)language username:(NSString *)username whereSql:(NSString *)whereSql
{
    if (searchword == nil || [searchword isEqualToString:@""] ||
        username == nil || [username isEqualToString:@""] ||
        language == nil || [language isEqualToString:@""]) {
        char *errorMsg = "updatHistoryListTable params error";
        [self throwDatabaseException:errorMsg];
    }
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *update = [NSString stringWithFormat:@"update HistoryListTable set searchword = ('%@'), username = ('%@'), language = ('%@') %@;",searchword,username,language,where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"errorMsg.");
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)deleteHistoryListTable:(NSString *)whereSql
{
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *delete = [NSString stringWithFormat:@"delete from HistoryListTable %@;",where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(NSMutableArray *)selectHistoryListTable:(NSString *)whereSql
{
    NSMutableArray *hisArray = [[NSMutableArray alloc]init ];
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@",whereSql];
    }
    if ([self connDatabase]) {
        NSString *query = [NSString stringWithFormat:@"select distinct searchword, language, username from HistoryListTable %@;",where];
        sqlite3_stmt *stmt;
        @try {
            if (sqlite3_prepare_v2(iPadDb, [query UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
                char *errorMsg = "select HistoryListTable error";
                [self throwDatabaseException:errorMsg];
            }
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                char *word = (char *)sqlite3_column_text(stmt, 0);
                char *lan = (char *)sqlite3_column_text(stmt, 1);
                char *un = (char *)sqlite3_column_text(stmt, 2);
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                if (word != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) word];
                    [dic setObject:tmp forKey:KEY_SEARCH_WORD];
                }
                if (un != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) un];
                    [dic setObject:tmp forKey:KEY_USERID];
                }
                if (lan != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) lan];
                    [dic setObject:tmp forKey:KEY_SEARCH_LANGUAGE];
                }
                [hisArray addObject:dic];
            }
            sqlite3_finalize(stmt);
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
    return hisArray;
}

#pragma mark -- AskforListTable
+(void)insertAskforListTable:(NSString *)externalId username:(NSString *)username status:(NSString *)status pmid:(NSString *)pmid requestTime:(NSString *)requestTime author:(NSString *)author issue:(NSString *)issue journal:(NSString *)journal pagination:(NSString *)pagination pubdate:(NSString *)pubdate title:(NSString *)title volume:(NSString *)volume
{
    if (externalId == nil || [externalId isEqualToString:@""] ||
        username == nil || [username isEqualToString:@""] ||
        status == nil || [status isEqualToString:@""] ||
        requestTime == nil || [requestTime isEqualToString:@""]) {
        char *errorMsg = "insertAskforListTable params error";
        [self throwDatabaseException:errorMsg];
    }
    if (pmid == nil) {
        pmid = @"";
    }
    if (author == nil) {
        author = @"";
    }
    if (issue == nil) {
        issue = @"";
    }
    if (journal == nil) {
        journal = @"";
    }
    if (pagination == nil) {
        pagination = @"";
    }
    if (pubdate == nil) {
        pubdate = @"";
    }
    if (title == nil) {
        title = @"";
    }
    if (volume == nil) {
        volume = @"";
    }
    if ([self connDatabase]) {
        NSString *insterSQL = [NSString stringWithFormat:@"insert into AskforListTable  (externalId,username,status,pmid,requestTime, author, issue, journal, pagination, pubdate,title, volume) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",externalId,username,status,pmid,requestTime,author,issue,journal,pagination,pubdate,title,volume];
        
        const char *insert_stmt = [insterSQL UTF8String];
        sqlite3_stmt *stmt;
        
        @try {
            if (sqlite3_prepare_v2(iPadDb, insert_stmt, -1, &stmt, NULL) == SQLITE_OK)
            {
                NSLog(@"sqlite3 prepare ok");
                if (sqlite3_step(stmt) == SQLITE_DONE)
                {
                    NSLog(@"sqlite3 step done");
                    sqlite3_finalize(stmt);
                }
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)updateAskforListTable:(NSString *)status whereSql:(NSString *)whereSql
{
    if (status == nil || [status isEqualToString:@""]) {
        char *errorMsg = "updateAskforListTable params error";
        [self throwDatabaseException:errorMsg];
    }
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *update = [NSString stringWithFormat:@"update AskforListTable set status = ('%@') %@;",status,where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"errorMsg.");
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)deleteAskforListTable:(NSString *)whereSql
{
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *delete = [NSString stringWithFormat:@"delete from AskforListTable %@;",where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(NSMutableArray *)selectAskforTable:(NSString *)whereSql
{
    NSMutableArray *askforArray = [[NSMutableArray alloc]init ];
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@",whereSql];
    }
    if ([self connDatabase]) {
        NSString *query = [NSString stringWithFormat:@"select externalId,username,status,pmid,requestTime, author, issue, journal, pagination, pubdate,title, volume from AskforListTable %@;",where];
        sqlite3_stmt *stmt;
        @try {
            if (sqlite3_prepare_v2(iPadDb, [query UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
                //        char *errorMsg = "select askforListTable error";
                //        [self throwDatabaseException:errorMsg];
                return nil;
            }
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                char *eId = (char *)sqlite3_column_text(stmt, 0);
                char *un = (char *)sqlite3_column_text(stmt, 1);
                char *status = (char *)sqlite3_column_text(stmt, 2);
                char *pmid = (char *)sqlite3_column_text(stmt, 3);
                char *requestTime = (char *)sqlite3_column_text(stmt, 4);
                char *author = (char *)sqlite3_column_text(stmt, 5);
                char *issue = (char *)sqlite3_column_text(stmt, 6);
                char *journal = (char *)sqlite3_column_text(stmt, 7);
                char *pagination = (char *)sqlite3_column_text(stmt, 8);
                char *pubdate = (char *)sqlite3_column_text(stmt, 9);
                char *title = (char *)sqlite3_column_text(stmt, 10);
                char *volume = (char *)sqlite3_column_text(stmt, 11);
                
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                if (un != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) un];
                    [dic setObject:tmp forKey:KEY_USERID];
                }
                if (status != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) status];
                    [dic setObject:tmp forKey:KEY_DOC_FETCH_STATUS];
                }
                if (pmid != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) pmid];
                    [dic setObject:tmp forKey:KEY_DOC_PMID];
                }
                if (requestTime != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)requestTime];
                    [dic setObject:tmp forKey:@"requestTime"];
                }
                NSMutableDictionary *shorDocInfo = [[NSMutableDictionary alloc]init ];
                if (eId != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) eId];
                    [shorDocInfo setObject:tmp forKey:@"id"];
                }
                if (author != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)author];
                    NSArray *authors = [tmp componentsSeparatedByString:SEPARATING];
                    [shorDocInfo setObject:authors forKey:KEY_DOC_AUTHOR];
                }
                if (issue != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)issue];
                    [shorDocInfo setObject:tmp forKey:KEY_DOC_ISSUE];
                }
                if (journal != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)journal];
                    [shorDocInfo setObject:tmp forKey:KEY_DOC_JOURNAL];
                }
                if (pubdate != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)pubdate];
                    [shorDocInfo setObject:tmp forKey:KEY_DOC_PUB_DATE];
                }
                if (title != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)title];
                    [shorDocInfo setObject:tmp forKey:KEY_DOC_TITLE];
                }
                if (volume != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)volume];
                    [shorDocInfo setObject:tmp forKey:KEY_DOC_VOLUME];
                }
                [dic setObject:shorDocInfo forKey:@"shortDocInfo"];
                [askforArray addObject:dic];
            }
            sqlite3_finalize(stmt);
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
    return askforArray;
}

#pragma mark -- DetailTable
+(void)insertDetailTable:(NSString *)externalId username:(NSString *)username
{
    if (externalId == nil || [externalId isEqualToString:@""] ||
        username == nil || [username isEqualToString:@""]) {
        char *errorMsg = "insertDetailTable params error";
        [self throwDatabaseException:errorMsg];
    }
    if ([self connDatabase]) {
        NSString *insterSQL = [NSString stringWithFormat:@"insert into DetailTable  (externalId,username) values (\"%@\",\"%@\")",externalId,username];
        
        const char *insert_stmt = [insterSQL UTF8String];
        sqlite3_stmt *stmt;
        
        @try {
            if (sqlite3_prepare_v2(iPadDb, insert_stmt, -1, &stmt, NULL) == SQLITE_OK)
            {
                NSLog(@"sqlite3 prepare ok");
                if (sqlite3_step(stmt) == SQLITE_DONE)
                {
                    NSLog(@"sqlite3 step done");
                    sqlite3_finalize(stmt);
                }
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)updateDetailTable:(NSString *)externalId username:(NSString *)username whereSql:(NSString *)whereSql
{
    if (externalId == nil || [externalId isEqualToString:@""] ||
        username == nil || [username isEqualToString:@""]) {
        char *errorMsg = "updateDetailTable params error";
        [self throwDatabaseException:errorMsg];
    }
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *update = [NSString stringWithFormat:@"update DetailTable set externalId = ('%@'), username = ('%@') %@;",externalId,username,where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"errorMsg.");
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)deleteDetailTable:(NSString *)whereSql
{
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *delete = [NSString stringWithFormat:@"delete from DetailTable %@;",where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(NSMutableArray *)selectDetailTable:(NSString *)whereSql
{
    NSMutableArray *detailArray = [[NSMutableArray alloc]init ];
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@",whereSql];
    }
    if ([self connDatabase]) {
        NSString *query = [NSString stringWithFormat:@"select externalId, username from DetailTable %@;",where];
        sqlite3_stmt *stmt;
        @try {
            if (sqlite3_prepare_v2(iPadDb, [query UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
                char *errorMsg = "select DetailTable error";
                [self throwDatabaseException:errorMsg];
            }
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                char *eId = (char *)sqlite3_column_text(stmt, 0);
                char *un = (char *)sqlite3_column_text(stmt, 1);
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                if (eId != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) eId];
                    [dic setObject:tmp forKey:KEY_DOC_EXTERNALID];
                }
                if (un != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) un];
                    [dic setObject:tmp forKey:KEY_USERID];
                }
                [detailArray addObject:dic];
            }
            sqlite3_finalize(stmt);
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
    return detailArray;
}

#pragma mark -- FavListTable
+(void)insertFavListTable:(NSString *)externalId username:(NSString *)username author:(NSString *)author issue:(NSString *)issue journal:(NSString *)journal pubDate:(NSString *)pubDate title:(NSString *)title volume:(NSString *)volume pagination:(NSString *)pagination
{
    if (externalId == nil || [externalId isEqualToString:@""] ||
        username == nil || [username isEqualToString:@""]) {
        char *errorMsg = "insertFavListTable params error";
        [self throwDatabaseException:errorMsg];
    }
    if (author == nil) {
        author = @"";
    }
    if (issue == nil) {
        issue = @"";
    }
    if (journal == nil) {
        journal = @"";
    }
    if (pubDate == nil) {
        pubDate = @"";
    }
    if (title == nil) {
        title = @"";
    }
    if (volume == nil) {
        volume = @"";
    }
    if (pagination == nil) {
        pagination = @"";
    }
    if ([self connDatabase]) {
        NSString *insterSQL = [NSString stringWithFormat:@"insert into FavListTable  (externalId,username,author,issue,journal,pubDate,title,volume, pagination) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\");",externalId,username,author,issue,journal,pubDate,title,volume, pagination];
        
        const char *insert_stmt = [insterSQL UTF8String];
        sqlite3_stmt *stmt;
        
        @try {
            if (sqlite3_prepare_v2(iPadDb, insert_stmt, -1, &stmt, NULL) == SQLITE_OK)
            {
                NSLog(@"sqlite3 prepare ok");
                if (sqlite3_step(stmt) == SQLITE_DONE)
                {
                    NSLog(@"sqlite3 step done");
                    sqlite3_finalize(stmt);
                }
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)updateFavListTable:(NSString *)externalId username:(NSString *)username whereSql:(NSString *)whereSql
{
    if (externalId == nil || [externalId isEqualToString:@""] ||
        username == nil || [username isEqualToString:@""]) {
        char *errorMsg = "updateFavListTable params error";
        [self throwDatabaseException:errorMsg];
    }
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *update = [NSString stringWithFormat:@"update FavListTable set externalId = ('%@'), username = ('%@') %@;",externalId,username,where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"errorMsg.");
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)deleteFavListTable:(NSString *)whereSql
{
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *delete = [NSString stringWithFormat:@"delete from FavListTable %@;",where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(NSMutableArray *)selectFavListTable:(NSString *)whereSql
{
    NSMutableArray *favArray = [[NSMutableArray alloc]init ];
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@",whereSql];
    }
    if ([self connDatabase]) {
        NSString *query = [NSString stringWithFormat:@"select externalId, username, author, issue, journal, pubDate, title, volume, pagination from FavListTable %@;",where];
        sqlite3_stmt *stmt;
        @try {
            int code = sqlite3_prepare_v2(iPadDb, [query UTF8String], -1, &stmt, NULL);
            if (code != SQLITE_OK) {
                //        char *errorMsg = "select DetailTable error";
                //        [self throwDatabaseException:errorMsg];
                return nil;
            }
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                char *eId = (char *)sqlite3_column_text(stmt, 0);
                char *un = (char *)sqlite3_column_text(stmt, 1);
                char *author = (char *)sqlite3_column_text(stmt, 2);
                char *issue = (char *)sqlite3_column_text(stmt, 3);
                char *journal = (char *)sqlite3_column_text(stmt, 4);
                char *pubDate = (char *)sqlite3_column_text(stmt, 5);
                char *title = (char *)sqlite3_column_text(stmt, 6);
                char *volume = (char *)sqlite3_column_text(stmt, 7);
                char *pagination = (char *)sqlite3_column_text(stmt, 8);
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                if (eId != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) eId];
                    [dic setObject:tmp forKey:KEY_DOC_EXTERNALID];
                }
                if (un != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) un];
                    [dic setObject:tmp forKey:KEY_USERID];
                }
                if (author != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)author];
                    NSArray *auArray = [tmp componentsSeparatedByString:SEPARATING];
                    [dic setObject:auArray forKey:KEY_DOC_AUTHOR];
                }
                if (issue != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)issue];
                    [dic setObject:tmp forKey:KEY_DOC_ISSUE];
                }
                if (journal != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)journal];
                    [dic setObject:tmp forKey:KEY_DOC_JOURNAL];
                }
                if (pagination != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)pagination];
                    [dic setObject:tmp forKey:KEY_DOC_PAGINATION];
                }
                if (pubDate != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)pubDate];
                    [dic setObject:tmp forKey:KEY_DOC_PUB_DATE];
                }
                if (title != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)title];
                    [dic setObject:tmp forKey:KEY_DOC_TITLE];
                }
                if (volume != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)volume];
                    [dic setObject:tmp forKey:KEY_DOC_VOLUME];
                }
                [favArray addObject:dic];
            }
            sqlite3_finalize(stmt);
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
    return favArray;
}

#pragma mark -- SearchListTable
+(void)insertSearchListTable:(NSString *)externalId username:(NSString *)username sort:(NSString *)sort
{
    if (externalId == nil || [externalId isEqualToString:@""] ||
        username == nil || [username isEqualToString:@""] ||
        sort == nil || [sort isEqualToString:@""]) {
        char *errorMsg = "insertFavListTable params error";
        [self throwDatabaseException:errorMsg];
    }
    if ([self connDatabase]) {
        NSString *insterSQL = [NSString stringWithFormat:@"insert into SearchListTable (externalId,username,sort) values (\"%@\",\"%@\",\"%@\")",externalId,username,sort];
        
        const char *insert_stmt = [insterSQL UTF8String];
        sqlite3_stmt *stmt;
        
        @try {
            if (sqlite3_prepare_v2(iPadDb, insert_stmt, -1, &stmt, NULL) == SQLITE_OK)
            {
                NSLog(@"sqlite3 prepare ok");
                if (sqlite3_step(stmt) == SQLITE_DONE)
                {
                    NSLog(@"sqlite3 step done");
                    sqlite3_finalize(stmt);
                }
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)updateSearchListTable:(NSString *)externalId username:(NSString *)username sort:(NSString *)sort whereSql:(NSString *)whereSql
{
    if (externalId == nil || [externalId isEqualToString:@""] ||
        username == nil || [username isEqualToString:@""] ||
        sort == nil || [sort isEqualToString:@""]) {
        char *errorMsg = "updateSearchListTable params error";
        [self throwDatabaseException:errorMsg];
    }
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *update = [NSString stringWithFormat:@"update FavListTable set externalId = ('%@'), username = ('%@'), sort = ('%@') %@;",externalId,username,sort,where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"errorMsg.");
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)deleteSearchListTable:(NSString *)whereSql
{
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *delete = [NSString stringWithFormat:@"delete from SearchListTable %@;",where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(NSMutableArray *)selectSearchListTable:(NSString *)whereSql
{
    NSMutableArray *searchArray = [[NSMutableArray alloc]init ];
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@",whereSql];
    }
    if ([self connDatabase]) {
        NSString *query = [NSString stringWithFormat:@"select externalId, username, sort from SearchListTable %@;",where];
        sqlite3_stmt *stmt;
        @try {
            if (sqlite3_prepare_v2(iPadDb, [query UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
                char *errorMsg = "select DetailTable error";
                [self throwDatabaseException:errorMsg];
            }
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                char *eId = (char *)sqlite3_column_text(stmt, 0);
                char *un = (char *)sqlite3_column_text(stmt, 1);
                char *sort = (char *)sqlite3_column_text(stmt, 2);
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                if (eId != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) eId];
                    [dic setObject:tmp forKey:KEY_DOC_EXTERNALID];
                }
                if (un != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) un];
                    [dic setObject:tmp forKey:KEY_USERID];
                }
                if (sort != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) sort];
                    [dic setObject:tmp forKey:KEY_SEARCH_SORT];
                }
                [searchArray addObject:dic];
            }
            sqlite3_finalize(stmt);
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
    return searchArray;
}

#pragma mark -- DocTable
+(void)insertDocTable:(NSString *)externalID CKID:(NSString *)CKID WFID:(NSString *)WFID WPID:(NSString *)WPID PMID:(NSString *)PMID text:(NSString *)text background:(NSString *)background objective:(NSString *)objective methods:(NSString *)methods results:(NSString *)results conclusions:(NSString *)conclusions copyrights:(NSString *)copyrights affiliation:(NSString *)affiliation author:(NSString *)author category:(NSString *)category citation:(NSString *)citation corejournal:(NSString *)corejournal iid:(NSString *)iid issue:(NSString *)issue journal:(NSString *)journal keywords:(NSString *)keywords machineCategory:(NSString *)machineCategory numcited:(NSString *)numcited pagination:(NSString *)pageination pubDate:(NSString *)pubDate reference:(NSString *)reference referenceCount:(NSString *)referenceCount title:(NSString *)title volume:(NSString *)volume ISSN:(NSString *)ISSN
{
    if (externalID == nil || [externalID isEqualToString:@""]) {
        char *errorMsg = "insertDocTable params error";
        [self throwDatabaseException:errorMsg];
    }
    if (CKID == nil) {
        CKID = @"";
    }
    if (WFID == nil) {
        WFID = @"";
    }
    if (WPID == nil) {
        WPID = @"";
    }
    if (PMID == nil) {
        PMID = @"";
    }
    if (text == nil) {
        text = @"";
    }
    if (background == nil) {
        background = @"";
    }
    if (objective == nil) {
        objective = @"";
    }
    if (methods == nil) {
        methods = @"";
    }
    if (results == nil) {
        results = @"";
    }
    if (conclusions == nil) {
        conclusions = @"";
    }
    if (copyrights == nil) {
        copyrights = @"";
    }
    if (affiliation == nil) {
        affiliation = @"";
    }
    if (author == nil) {
        author = @"";
    }
    if (category == nil) {
        category = @"";
    }
    if (citation == nil) {
        citation = @"";
    }
    if (corejournal == nil) {
        corejournal = @"";
    }
    if (iid == nil) {
        iid = @"";
    }
    if (issue == nil) {
        issue = @"";
    }
    if (journal == nil) {
        journal = @"";
    }
    if (keywords == nil) {
        keywords = @"";
    }
    if (machineCategory == nil) {
        machineCategory = @"";
    }
    if (numcited == nil) {
        numcited = @"";
    }
    if (pageination == nil) {
        pageination = @"";
    }
    if (pubDate == nil) {
        pubDate = @"";
    }
    if (reference == nil) {
        reference = @"";
    }
    if (referenceCount == nil) {
        referenceCount = @"";
    }
    if (title == nil) {
        title = @"";
    }
    if (volume == nil) {
        volume = @"";
    }
    if (ISSN == nil) {
        ISSN = @"";
    }
    if ([self connDatabase]) {
        //    NSString *insert = [NSString stringWithFormat:@"insert into DocTable (externalId,CKID,WFID,WPID,PMID,text,background,objective,methods,results,conclusions,copyrights,affiliation,author,category,citation,coreJournal,iid,issue,journal,keywords,machineCategory,numCited,pagination,pubDate,reference,referenceCount,title,volume,ISSN) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"];
        NSString *insert = [NSString stringWithFormat:@"insert into DocTable (externalId,CKID,WFID,WPID,PMID,text,background,objective,methods,results,conclusions,copyrights,affiliation,author,category,citation,coreJournal,iid,issue,journal,keywords,machineCategory,numCited,pagination,pubDate,reference,referenceCount,title,volume,ISSN) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\");",externalID,CKID,WFID,WPID,PMID,text,background,objective,methods,results,conclusions,copyrights,affiliation,author,category,citation,corejournal,iid,issue,journal,keywords,machineCategory,numcited,pageination,pubDate,reference,referenceCount,title,volume,ISSN];
        @try {
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(iPadDb, [insert UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
                //        sqlite3_bind_text(stmt, 1, [externalID UTF8String], -1, NULL);
                //        sqlite3_bind_text(stmt, 2, [CKID UTF8String], -1, NULL);
                //        sqlite3_bind_text(stmt, 3, [WFID UTF8String], -1, NULL);
                //        sqlite3_bind_text(stmt, 4, [externalID UTF8String], -1, NULL);
                if (sqlite3_step(stmt) == SQLITE_DONE) {
                    sqlite3_finalize(stmt);
                }
            }
            
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)updateDocTable:(NSString *)externalID CKID:(NSString *)CKID WFID:(NSString *)WFID WPID:(NSString *)WPID PMID:(NSString *)PMID text:(NSString *)text background:(NSString *)background objective:(NSString *)objective methods:(NSString *)methods results:(NSString *)results conclusions:(NSString *)conclusions copyrights:(NSString *)copyrights affiliation:(NSString *)affiliation author:(NSString *)author category:(NSString *)category citation:(NSString *)citation corejournal:(NSString *)corejournal iid:(NSString *)iid issue:(NSString *)issue journal:(NSString *)journal keywords:(NSString *)keywords machineCategory:(NSString *)machineCategory numcited:(NSString *)numcited pagination:(NSString *)pageination pubDate:(NSString *)pubDate reference:(NSString *)reference referenceCount:(NSString *)referenceCount title:(NSString *)title volume:(NSString *)volume ISSN:(NSString *)ISSN whereSql:(NSString *)whereSql
{
    if (externalID == nil || [externalID isEqualToString:@""]) {
        char *errorMsg = "updateDocTable params error";
        [self throwDatabaseException:errorMsg];
    }
    if (CKID == nil) {
        CKID = @"";
    }
    if (WFID == nil) {
        WFID = @"";
    }
    if (WPID == nil) {
        WPID = @"";
    }
    if (PMID == nil) {
        PMID = @"";
    }
    if (text == nil) {
        text = @"";
    }
    if (background == nil) {
        background = @"";
    }
    if (objective == nil) {
        objective = @"";
    }
    if (methods == nil) {
        methods = @"";
    }
    if (results == nil) {
        results = @"";
    }
    if (conclusions == nil) {
        conclusions = @"";
    }
    if (copyrights == nil) {
        copyrights = @"";
    }
    if (affiliation == nil) {
        affiliation = @"";
    }
    if (author == nil) {
        author = @"";
    }
    if (category == nil) {
        category = @"";
    }
    if (citation == nil) {
        citation = @"";
    }
    if (corejournal == nil) {
        corejournal = @"";
    }
    if (iid == nil) {
        iid = @"";
    }
    if (issue == nil) {
        issue = @"";
    }
    if (journal == nil) {
        journal = @"";
    }
    if (keywords == nil) {
        keywords = @"";
    }
    if (machineCategory == nil) {
        machineCategory = @"";
    }
    if (numcited == nil) {
        numcited = @"";
    }
    if (pageination == nil) {
        pageination = @"";
    }
    if (pubDate == nil) {
        pubDate = @"";
    }
    if (reference == nil) {
        reference = @"";
    }
    if (referenceCount == nil) {
        referenceCount = @"";
    }
    if (title == nil) {
        title = @"";
    }
    if (volume == nil) {
        volume = @"";
    }
    if (ISSN == nil) {
        ISSN = @"";
    }
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *update = [NSString stringWithFormat:@"update DocTable set externalId = ('%@'), CKID = ('%@'), WFID = ('%@'), WPID = ('%@'), PMID = ('%@'), text = ('%@'), background = ('%@'), objective = ('%@'), methods = ('%@'), results = ('%@'), conclusions = ('%@'), copyrights = ('%@'), affiliation = ('%@'), author = ('%@'), category = ('%@'), citation = ('%@'), coreJournal = ('%@'), iid = ('%@'), issue = ('%@'), journal = ('%@'), keywords = ('%@'), machineCategory = ('%@'), numCited = ('%@'), pageination = ('%@'),pubDate = ('%@'), reference = ('%@'), referenceCount = ('%@'), title = ('%@'), volume = ('%@'), ISSN = ('%@') %@;",externalID,CKID,WFID,WPID,PMID,text,background,objective,methods,results,conclusions,copyrights,affiliation,author,category,citation,corejournal,iid,issue,journal,keywords,machineCategory,numcited,pageination,pubDate,reference,referenceCount,title,volume,ISSN,where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [update UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"errorMsg.");
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(void)deleteDocTable:(NSString *)whereSql
{
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@", whereSql];
    }
    if ([self connDatabase]) {
        NSString *delete = [NSString stringWithFormat:@"delete from DocTable %@;",where];
        char *errorMsg;
        @try {
            if (sqlite3_exec(iPadDb, [delete UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                [self throwDatabaseException:errorMsg];
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}
+(NSMutableDictionary *)selectDocTable:(NSString *)externalId
{
    if ([self connDatabase]) {
        NSString *where = [NSString stringWithFormat:@"where externalId = '%@'",externalId];
        NSString *query = [NSString stringWithFormat:@"select externalId,CKID,WFID,WPID,PMID,text,background,objective,methods,results,conclusions,copyrights,affiliation,author,category,citation,coreJournal,iid,issue,journal,keywords,machineCategory,numCited,pagination,pubDate,reference,referenceCount,title,volume,ISSN from DocTable %@;",where];
        sqlite3_stmt *stmt;
        @try {
            int state = sqlite3_prepare_v2(iPadDb, [query UTF8String], -1, &stmt, NULL);
            if (state!= SQLITE_OK) {
                char *errorMsg = "select DocTable error";
                [self throwDatabaseException:errorMsg];
            }
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init ];
            BOOL haveValue = false;
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                haveValue = true;
                char *eId = (char *)sqlite3_column_text(stmt, 0);
                char *ckid = (char *)sqlite3_column_text(stmt, 1);
                char *wfid = (char *)sqlite3_column_text(stmt, 2);
                char *wpid = (char *)sqlite3_column_text(stmt, 3);
                char *pmid = (char *)sqlite3_column_text(stmt, 4);
                char *text = (char *)sqlite3_column_text(stmt, 5);
                char *background = (char *)sqlite3_column_text(stmt, 6);
                char *objective = (char *)sqlite3_column_text(stmt, 7);
                char *methods = (char *)sqlite3_column_text(stmt, 8);
                char *results = (char *)sqlite3_column_text(stmt, 9);
                char *conclusions = (char *)sqlite3_column_text(stmt, 10);
                char *copyrights = (char *)sqlite3_column_text(stmt, 11);
                char *affiliation = (char *)sqlite3_column_text(stmt, 12);
                char *author = (char *)sqlite3_column_text(stmt, 13);
                char *category = (char *)sqlite3_column_text(stmt, 14);
                char *citation = (char *)sqlite3_column_text(stmt, 15);
                char *coreJournal = (char *)sqlite3_column_text(stmt, 16);
                char *iid = (char *)sqlite3_column_text(stmt, 17);
                char *issue = (char *)sqlite3_column_text(stmt, 18);
                char *journal = (char *)sqlite3_column_text(stmt, 19);
                char *keywords = (char *)sqlite3_column_text(stmt, 20);
                char *machineCategory = (char *)sqlite3_column_text(stmt, 21);
                char *numCited = (char *)sqlite3_column_text(stmt, 22);
                char *pagination = (char *)sqlite3_column_text(stmt, 23);
                char *pubDate = (char *)sqlite3_column_text(stmt, 24);
                char *reference = (char *)sqlite3_column_text(stmt, 25);
                char *referenceCount = (char *)sqlite3_column_text(stmt, 26);
                char *title = (char *)sqlite3_column_text(stmt, 27);
                char *volume = (char *)sqlite3_column_text(stmt, 28);
                char *ISSN = (char *)sqlite3_column_text(stmt, 29);
                
                
                if (eId != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) eId];
                    [dic setObject:tmp forKey:KEY_DOC_EXTERNALID];
                }
                if (ckid != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)ckid];
                    [dic setObject:tmp forKey:KEY_DOC_CKID];
                }
                if (wfid != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)wfid];
                    [dic setObject:tmp forKey:KEY_DOC_WFID];
                }
                if (wpid != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)wpid];
                    [dic setObject:tmp forKey:KEY_DOC_WPID];
                }
                if (pmid != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)pmid];
                    [dic setObject:tmp forKey:KEY_DOC_PMID];
                }
                NSMutableDictionary *nmd = [[NSMutableDictionary alloc]init];
                if (text != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)text];
                    NSArray *textArray = [temp componentsSeparatedByString:@"::"];
                    NSLog(@"textArray ==== %@", textArray);
                    if ([Util checkArrayContentWithString:textArray]) {
                        [nmd setObject:textArray forKey:@"text"];
                    }
                }
                if (background != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)background];
                    NSArray *bgArray = [temp componentsSeparatedByString:@"::"];
                    NSLog(@"bgArray ==== %@", bgArray);
                    if ([Util checkArrayContentWithString:bgArray]) {
                        [nmd setObject:bgArray forKey:@"background"];
                    }
                }
                if (objective != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)objective];
                    NSArray *ojtArray = [temp componentsSeparatedByString:@"::"];
                    NSLog(@"ojtArray ==== %@", ojtArray);
                    if ([Util checkArrayContentWithString:ojtArray]) {
                        [nmd setObject:ojtArray forKey:@"objective"];
                    }
                }
                if (methods != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)methods];
                    NSArray *mtdArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:mtdArray]) {
                        [nmd setObject:mtdArray forKey:@"methods"];
                    }
                }
                if (results != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)results];
                    NSArray *resArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:resArray]) {
                        [nmd setObject:resArray forKey:@"results"];
                    }
                }
                if (conclusions != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)conclusions];
                    NSArray *cclArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:cclArray]) {
                        [nmd setObject:cclArray forKey:@"conclusions"];
                    }
                }
                if (copyrights != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)copyrights];
                    NSArray *crArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:crArray]) {
                        [nmd setObject:crArray forKey:@"copyrights"];
                    }
                }
                [dic setObject:nmd forKey:@"abstractText"];
                if (affiliation != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)affiliation];
                    NSArray *afArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:afArray]) {
                        [dic setObject:afArray forKey:@"affiliation"];
                    }
                }
                if (author != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)author];
                    NSArray *authArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:authArray]) {
                        [dic setObject:authArray forKey:@"author"];
                    }
                }
                if (category != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)category];
                    NSArray *cgArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:cgArray]) {
                        [dic setObject:cgArray forKey:@"category"];
                    }
                }
                if (citation != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)citation];
                    NSArray *citArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:citArray]) {
                        [dic setObject:citArray forKey:@"citation"];
                    }
                }
                if (coreJournal != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)coreJournal];
                    [dic setObject:temp forKey:@"coreJournal"];
                    //          [dic setCoreJournal:temp];
                }
                if (iid != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)iid];
                    [dic setObject:temp forKey:@"id"];
                    //          [dic setIid:temp];
                }
                if (issue != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)issue];
                    [dic setObject:temp forKey:@"issue"];
                    //          [dic setIssue:temp];
                }
                if (journal != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)journal];
                    [dic setObject:temp forKey:@"journal"];
                    //          [dic setJournal:temp];
                }
                if (keywords != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)keywords];
                    NSArray *kwArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:kwArray]) {
                        [dic setObject:kwArray forKey:@"keywords"];
                    }
                }
                if (machineCategory != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)machineCategory];
                    NSArray *mcArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:mcArray]) {
                        [dic setObject:mcArray forKey:@"machineCategory"];
                    }
                }
                if (numCited != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)numCited];
                    [dic setObject:temp forKey:@"numCited"];
                    //          [dic setNumCited:temp];
                }
                if (pagination != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)pagination];
                    [dic setObject:temp forKey:@"pagination"];
                    //          [dic setPagination:temp];
                }
                if (pubDate != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)pubDate];
                    [dic setObject:temp forKey:@"pubDate"];
                    //          [dic setPubDate:temp];
                }
                if (reference != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)reference];
                    NSArray *rfArray = [temp componentsSeparatedByString:@"::"];
                    if ([Util checkArrayContentWithString:rfArray]) {
                        [dic setObject:rfArray forKey:@"reference"];
                    }
                }
                if (referenceCount != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)referenceCount];
                    [dic setObject:temp forKey:@"referenceCount"];
                    //          [dic setReferenceCount:temp];
                }
                if (title != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)title];
                    [dic setObject:temp forKey:@"title"];
                    //          [dic setTitle:temp];
                }
                if (volume != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)volume];
                    [dic setObject:temp forKey:@"volume"];
                    //          [dic setVolume:temp];
                }
                if (ISSN != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)ISSN];
                    [dic setObject:temp forKey:@"ISSN"];
                    //          [dic setISSN:temp];
                }
                break;
            }
            sqlite3_finalize(stmt);
            if (haveValue) {
                return dic;
            } else {
                return nil;
            }
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
}

+(NSMutableArray *)selectDocsTable:(NSString *)whereSql
{
    NSMutableArray *docArray = [[NSMutableArray alloc]init ];
    NSString *where = @"";
    if (whereSql != nil && ![whereSql isEqualToString:@""]) {
        where = [NSString stringWithFormat:@"where %@",whereSql];
    }
    if ([self connDatabase]) {
        NSString *query = [NSString stringWithFormat:@"select externalId,CKID,WFID,WPID,PMID,text,background,objective,methods,results,conclusions,copyrights,affiliation,author,category,citation,coreJournal,iid,issue,journal,keywords,machineCategory,numCited,pagination,pubDate,reference,referenceCount,title,volume,ISSN from DocTable %@;",where];
        sqlite3_stmt *stmt;
        @try {
            int state = sqlite3_prepare_v2(iPadDb, [query UTF8String], -1, &stmt, NULL);
            if (state!= SQLITE_OK) {
                char *errorMsg = "select DocTable error";
                [self throwDatabaseException:errorMsg];
            }
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                char *eId = (char *)sqlite3_column_text(stmt, 0);
                char *ckid = (char *)sqlite3_column_text(stmt, 1);
                char *wfid = (char *)sqlite3_column_text(stmt, 2);
                char *wpid = (char *)sqlite3_column_text(stmt, 3);
                char *pmid = (char *)sqlite3_column_text(stmt, 4);
                char *text = (char *)sqlite3_column_text(stmt, 5);
                char *background = (char *)sqlite3_column_text(stmt, 6);
                char *objective = (char *)sqlite3_column_text(stmt, 7);
                char *methods = (char *)sqlite3_column_text(stmt, 8);
                char *results = (char *)sqlite3_column_text(stmt, 9);
                char *conclusions = (char *)sqlite3_column_text(stmt, 10);
                char *copyrights = (char *)sqlite3_column_text(stmt, 11);
                char *affiliation = (char *)sqlite3_column_text(stmt, 12);
                char *author = (char *)sqlite3_column_text(stmt, 13);
                char *category = (char *)sqlite3_column_text(stmt, 14);
                char *citation = (char *)sqlite3_column_text(stmt, 15);
                char *coreJournal = (char *)sqlite3_column_text(stmt, 16);
                char *iid = (char *)sqlite3_column_text(stmt, 17);
                char *issue = (char *)sqlite3_column_text(stmt, 18);
                char *journal = (char *)sqlite3_column_text(stmt, 19);
                char *keywords = (char *)sqlite3_column_text(stmt, 20);
                char *machineCategory = (char *)sqlite3_column_text(stmt, 21);
                char *numCited = (char *)sqlite3_column_text(stmt, 22);
                char *pagination = (char *)sqlite3_column_text(stmt, 23);
                char *pubDate = (char *)sqlite3_column_text(stmt, 24);
                char *reference = (char *)sqlite3_column_text(stmt, 25);
                char *referenceCount = (char *)sqlite3_column_text(stmt, 26);
                char *title = (char *)sqlite3_column_text(stmt, 27);
                char *volume = (char *)sqlite3_column_text(stmt, 28);
                char *ISSN = (char *)sqlite3_column_text(stmt, 29);
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init ];
                if (eId != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *) eId];
                    [dic setObject:tmp forKey:KEY_DOC_EXTERNALID];
                }
                if (ckid != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)ckid];
                    [dic setObject:tmp forKey:KEY_DOC_CKID];
                }
                if (wfid != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)wfid];
                    [dic setObject:tmp forKey:KEY_DOC_WFID];
                }
                if (wpid != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)wpid];
                    [dic setObject:tmp forKey:KEY_DOC_WPID];
                }
                if (pmid != nil) {
                    NSString *tmp = [NSString stringWithUTF8String:(const char *)pmid];
                    [dic setObject:tmp forKey:KEY_DOC_PMID];
                }
                NSMutableDictionary *nmd = [[NSMutableDictionary alloc]init];
                if (text != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)text];
                    NSArray *textArray = [temp componentsSeparatedByString:@"::"];
                    [nmd setObject:textArray forKey:@"text"];
                }
                if (background != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)background];
                    NSArray *bgArray = [temp componentsSeparatedByString:@"::"];
                    [nmd setObject:bgArray forKey:@"background"];
                }
                if (objective != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)objective];
                    NSArray *ojtArray = [temp componentsSeparatedByString:@"::"];
                    [nmd setObject:ojtArray forKey:@"objective"];
                }
                if (methods != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)methods];
                    NSArray *mtdArray = [temp componentsSeparatedByString:@"::"];
                    [nmd setObject:mtdArray forKey:@"methods"];
                }
                if (results != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)results];
                    NSArray *resArray = [temp componentsSeparatedByString:@"::"];
                    [nmd setObject:resArray forKey:@"results"];
                }
                if (conclusions != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)conclusions];
                    NSArray *cclArray = [temp componentsSeparatedByString:@"::"];
                    [nmd setObject:cclArray forKey:@"conclusions"];
                }
                if (copyrights != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)copyrights];
                    NSArray *crArray = [temp componentsSeparatedByString:@"::"];
                    [nmd setObject:crArray forKey:@"copyrights"];
                }
                [dic setObject:nmd forKey:@"abstractText"];
                
                if (affiliation != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)affiliation];
                    NSArray *afArray = [temp componentsSeparatedByString:@"::"];
                    [dic setObject:afArray forKey:@"affiliation"];
                }
                if (author != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)author];
                    NSArray *authArray = [temp componentsSeparatedByString:@"::"];
                    [dic setObject:authArray forKey:@"author"];
                }
                if (category != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)category];
                    NSArray *cgArray = [temp componentsSeparatedByString:@"::"];
                    [dic setObject:cgArray forKey:@"category"];
                }
                if (citation != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)citation];
                    NSArray *citArray = [temp componentsSeparatedByString:@"::"];
                    [dic setObject:citArray forKey:@"citation"];
                }
                if (coreJournal != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)coreJournal];
                    [dic setObject:temp forKey:@"coreJournal"];
                }
                if (iid != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)iid];
                    [dic setObject:temp forKey:@"id"];
                }
                if (issue != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)issue];
                    [dic setObject:temp forKey:@"issue"];
                }
                if (journal != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)journal];
                    [dic setObject:temp forKey:@"journal"];
                }
                if (keywords != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)keywords];
                    NSArray *kwArray = [temp componentsSeparatedByString:@"::"];
                    [dic setObject:kwArray forKey:@"keywords"];
                }
                if (machineCategory != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)machineCategory];
                    NSArray *mcArray = [temp componentsSeparatedByString:@"::"];
                    [dic setObject:mcArray forKey:@"machineCategory"];
                }
                if (numCited != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)numCited];
                    [dic setObject:temp forKey:@"numCited"];
                }
                if (pagination != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)pagination];
                    [dic setObject:temp forKey:@"pagination"];
                }
                if (pubDate != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)pubDate];
                    [dic setObject:temp forKey:@"pubDate"];
                }
                if (reference != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)reference];
                    NSArray *rfArray = [temp componentsSeparatedByString:@"::"];
                    [dic setObject:rfArray forKey:@"reference"];
                }
                if (referenceCount != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)referenceCount];
                    [dic setObject:temp forKey:@"referenceCount"];
                }
                if (title != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)title];
                    [dic setObject:temp forKey:@"title"];
                }
                if (volume != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)volume];
                    [dic setObject:temp forKey:@"volume"];
                }
                if (ISSN != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)ISSN];
                    [dic setObject:temp forKey:@"ISSN"];
                }
                [docArray addObject:dic];
            }
            sqlite3_finalize(stmt);
        }
        @catch (NSException *exception) {
            [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:exception.name exceptionMessage:exception.description];
            @throw exception;
        }
        @finally {
            [self closeDatabase];
        }
    }
    return docArray;
}

@end
