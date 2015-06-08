//
//  DatabaseManager.m
//  imdSearch
//
//  Created by xiangzhang on 3/26/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "DatabaseManager.h"

#define Create_MySearchTable @"CREATE TABLE IF NOT EXISTS docrecordTable (id integer primary key AUTOINCREMENT, userid text, externalId text, title text, author text, journal text, volume text, issue text, pagination text, pubDate text,kind text, type text, isRead INTEGER, UNIQUE(externalId));"

@implementation DatabaseManager
sqlite3 *database;
char *error;

+ (NSString *)getDataBaseFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:DataBaseNameFile];
}

+ (BOOL)connectionDatabase{
    if (sqlite3_open([[DatabaseManager getDataBaseFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
		return NO;
    }else{
		return YES;
	}
}

+ (void)createDataBase{
    if ([self connectionDatabase]) {
        char *errorMsg;
        NSString *createRecordSql = Create_MySearchTable;
        if (sqlite3_exec(database, [createRecordSql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            sqlite3_close(database);
        }
        
    }
    
    sqlite3_close(database);
}

+ (void)insertToDataBaseWithRecord:(DocInfoRecord *)record{
    if ([self connectionDatabase]) {
        NSString *strSql = @"insert into docrecordTable(userid, externalId, title, author, journal, volume, issue, pagination, pubDate, kind, type, isRead) values (?,?,?,?,?,?,?,?,?,?,?,?)";
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, [strSql UTF8String], -1, &stmt, Nil) == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, [[record userid] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [[record externalId] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [[record title] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 4, [[record author] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 5, [[record journal] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 6, [[record volume] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 7, [[record issue] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 8, [[record pagination] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 9, [[record pubDate] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 10, [[record kind] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 11, [[record type] UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 12, [record isRead]);
        }
        
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            sqlite3_finalize(stmt);
        }
    }
    sqlite3_close(database);
}

+ (NSMutableArray *)getRecordFromDatabaseWithUserId:(NSString *)userId{
    NSMutableArray *dataArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *sql = @"select userid, externalId, title, author, journal, volume, issue, pagination, pubDate, kind, type, isRead from docrecordTable where userid = '%@' limit 15";
    NSString *sqlStr = [NSString stringWithFormat:sql,userId];
    if ([self connectionDatabase]) {
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, [sqlStr UTF8String], -1, &stmt, nil) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                DocInfoRecord *record = [[DocInfoRecord alloc] init];
                char *userId = (char *)sqlite3_column_text(stmt, 0);
                record.userid = [NSString stringWithUTF8String:userId==NULL?"":userId];
                char *externalId = (char *)sqlite3_column_text(stmt, 1);
                record.externalId = [NSString stringWithUTF8String:externalId==NULL?"":externalId];
                char *title = (char *)sqlite3_column_text(stmt, 2);
                record.title = [NSString stringWithUTF8String:title==NULL?"":title];
                char *author = (char *)sqlite3_column_text(stmt, 3);
                record.author = [NSString stringWithUTF8String:author==NULL?"":author];
                char *journal = (char *)sqlite3_column_text(stmt, 4);
                record.journal = [NSString stringWithUTF8String:journal==NULL?"":journal];
                char *volume = (char *)sqlite3_column_text(stmt, 5);
                record.volume = [NSString stringWithUTF8String:volume==NULL?"":volume];
                char *issue = (char *)sqlite3_column_text(stmt, 6);
                record.issue = [NSString stringWithUTF8String:issue==NULL?"":issue];
                char *pagination = (char *)sqlite3_column_text(stmt, 7);
                record.pagination = [NSString stringWithUTF8String:pagination==NULL?"":pagination];
                char *pubDate = (char *)sqlite3_column_text(stmt, 8);
                record.pubDate = [NSString stringWithUTF8String:pubDate==NULL?"":pubDate];
                char *kind = (char *)sqlite3_column_text(stmt, 9);
                record.kind = [NSString stringWithUTF8String:kind==NULL?"":kind];
                char *type = (char *)sqlite3_column_text(stmt, 10);
                record.type = [NSString stringWithUTF8String:type==NULL?"":type];
                record.isRead = (NSInteger)sqlite3_column_int(stmt, 11);
                [dataArr addObject:record];
            }
        }
    }
    return dataArr;
}

+ (void)updataRecordReadStatus:(BOOL)isRead externalId:(NSString *)externalId withUserId:(NSString *)userId{
    char *errorMsg;
    if ([self connectionDatabase]) {
        NSString *strSql = [NSString stringWithFormat:@"UPDATE docrecordTable SET isRead= %d where externalId='%@' and userid = '%@'",isRead, externalId,userId];
        sqlite3_exec(database, [strSql UTF8String], NULL, NULL, &errorMsg);
    }
    sqlite3_close(database);
}

+ (void)deleteRecordInfo:(DocInfoRecord *)record{
    char *errorMsg;
	if([self connectionDatabase]){
		NSString *deleteStr = [NSString stringWithFormat:@"DELETE FROM docrecordTable where externalId='%@' and userid='%@'",record.externalId,record.userid];
		if (sqlite3_exec (database, [deleteStr UTF8String],NULL, NULL, &errorMsg) == SQLITE_OK){
			NSLog(@"删除成功");
		}else {
			NSLog(@"删除失败");
		}
	}
	sqlite3_close(database);
}
@end
