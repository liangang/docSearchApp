//
//  MyDatabase.m
//  imdSearch
//
//  Created by  侯建政 on 6/29/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "MyDatabase.h"
#import "publicMySearch.h"
#import "publicDoc.h"
#import "Strings.h"


@implementation MyDatabase
sqlite3 *imdDatabase;
char *error;

+(NSString *)databataPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:databataName];
}
+(BOOL)connDatabase{
	if (sqlite3_open([[MyDatabase databataPath] UTF8String], &imdDatabase) != SQLITE_OK) {
        sqlite3_close(imdDatabase);
		return NO;
    }else{
		return YES;
	}
}
#pragma mark -
#pragma mark 创建表
+(void)creatDatabase{
	if([self connDatabase]){
		char *errorMsg;
        //我的收藏表
        NSString *createMysearchTable = Create_MySearchTable;
		if (sqlite3_exec (imdDatabase, [createMysearchTable UTF8String],NULL, NULL, &errorMsg) != SQLITE_OK) {
			sqlite3_close(imdDatabase);
		}
        
        NSString *createDocTable =  Create_DetailTable;
		if (sqlite3_exec (imdDatabase, [createDocTable UTF8String],NULL, NULL, &errorMsg) != SQLITE_OK) {
			sqlite3_close(imdDatabase);
		}
        NSString *createHistoryTable = Create_SearchHistory ;
		if (sqlite3_exec (imdDatabase, [createHistoryTable UTF8String],NULL, NULL, &errorMsg) != SQLITE_OK) {
			sqlite3_close(imdDatabase);
		}
    }
    sqlite3_close(imdDatabase);
}
#pragma mark -
#pragma mark 向搜索历史表中插入数据
+(void)insertMyHistorTable:(NSString *)searchresult kind:(NSString *)kind userid:(NSString *)userid{
    if([self connDatabase]){
		NSString *strSQL=[NSString stringWithFormat:@"insert into MyHistorTable (searchresult,kind,userid) values ('%@','%@','%@')",searchresult,kind,userid];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(imdDatabase, [strSQL UTF8String], -1, &stmt, nil) == SQLITE_OK) {
            
            sqlite3_bind_text(stmt, 1, [searchresult UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [kind UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [userid UTF8String], -1, NULL);
        }
        if (sqlite3_step(stmt) != SQLITE_DONE)
            //            NSAssert1(0, @"Error insert table: %s", error);
            sqlite3_finalize(stmt);
	}
	sqlite3_close(imdDatabase);
}
//删除表
+(void)cleanHistoryTable:(NSString *)userid{
	char *errorMsg;
	if([self connDatabase]){
		NSString *deleteStr=[NSString stringWithFormat:@"DELETE FROM MyHistorTable where userid='%@'",userid];
		if (sqlite3_exec (imdDatabase, [deleteStr UTF8String],NULL, NULL, &errorMsg) == SQLITE_OK){
			NSLog(@"删除成功");
		}else {
			NSLog(@"删除失败");
		}
	}
	sqlite3_close(imdDatabase);
}
//读取历史表
+(NSMutableArray *) readHistoryData:(NSString *)userid
{
	NSMutableArray  *hisArray = [[NSMutableArray alloc] init];
	if([self connDatabase]){
		NSString *query3 = [NSString stringWithFormat:@"SELECT searchresult,kind FROM MyHistorTable where userid='%@';",userid];
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(imdDatabase, [query3 UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
                //首先创建好对象，准备装值
                char *searchresult = (char *)sqlite3_column_text(statement, 0);
				char *kind = (char *)sqlite3_column_text(statement, 1);
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
				if(searchresult!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)searchresult];
                    [dic setObject:temp forKey:QUERY_HISTORY_STRING];
				}
				if(kind!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)kind];
                    [dic setObject:temp forKey:QUERY_HISTORY_SOURCE];
				}
                [hisArray addObject:dic];
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(imdDatabase);
	}
	return hisArray;
}
+(BOOL)isExistHistorylist:(NSString *)searchValue kind:(NSString *)kind userid:(NSString *)userid
{
    BOOL isId;
    NSMutableArray *mutArray = [MyDatabase readHistoryData:userid];
    
    
    if (![mutArray count]) {
        isId = NO;
    }else {
        for (int i=0; i < [mutArray count]; i++) {
            if ([[[mutArray objectAtIndex:i] objectForKey:QUERY_HISTORY_STRING] isEqualToString:searchValue] && [[[mutArray objectAtIndex:i] objectForKey:QUERY_HISTORY_SOURCE] isEqualToString:kind]) {
                isId = YES;
                break;
            }else {
                isId = NO;
            }
        }
        
    }
    
    return isId;
    
}
#pragma mark -
#pragma mark  我的收藏插入数据
+(void)insertMySearchValue:(NSString *)author externalId:(NSString *)externalId issue:(NSString *)issue journal:(NSString *)journal pagination:(NSString *)pagination pubDate:(NSString *)pubDate title:(NSString *)title userid:(NSString *)userid ismgr:(NSString *)ismgr volume:(NSString *)volume{
	if([self connDatabase]){
		NSString *strSQL = @"insert into MySearchTable (author,externalId,issue,journal,pagination, pubDate,title,userid,ismgr,volume) values (?,?,?,?,?,?,?,?,?,?)";
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(imdDatabase, [strSQL UTF8String], -1, &stmt, nil) == SQLITE_OK) {
            
            sqlite3_bind_text(stmt, 1, [author UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [externalId UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [issue UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 4, [journal UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 5, [pagination UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 6, [pubDate UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 7, [title UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 8, [userid UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 9, [ismgr UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 10, [volume UTF8String], -1, NULL);
        }
        
        if (sqlite3_step(stmt) != SQLITE_DONE)
            NSAssert1(0, @"Error insert table: %s", error);
        sqlite3_finalize(stmt);
	}
	sqlite3_close(imdDatabase);
}

+(void)cleanMySearchTable:(NSString *)ismgr userid:(NSString *)userid
{
    [MyDatabase cleanTable:@"MySearchTable" ismgr:ismgr userid:userid];
}
//删除表
+(void)cleanTable:(NSString *)tablename ismgr:(NSString *)ismgr userid:(NSString *)userid{
	char *errorMsg;
	if([self connDatabase]){
		NSString *deleteStr=[NSString stringWithFormat:@"DELETE FROM %@ where ismgr='%@' and userid='%@'",tablename,ismgr,userid];
		if (sqlite3_exec (imdDatabase, [deleteStr UTF8String],NULL, NULL, &errorMsg) == SQLITE_OK){
			NSLog(@"删除成功");
		}else {
			NSLog(@"删除失败");
		}
	}
	sqlite3_close(imdDatabase);
}
#pragma mark -
#pragma mark  我的收藏读取数据
+(NSMutableArray *) readMgrData:(NSString *)ismgr userid:(NSString *)userid{
    //事先创建可变数据了，为了装对象，对象里装具体每行各字段的信息
	NSMutableArray  *fav = [[NSMutableArray alloc] init];
	if([self connDatabase]){
		NSString *query3 = [NSString stringWithFormat:@"SELECT author,externalId,issue,journal,pagination, pubDate,title,userid,volume,id FROM MySearchTable where ismgr='%@' and userid='%@' order by id desc;",ismgr,userid];
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(imdDatabase, [query3 UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
                //首先创建好对象，准备装值
				publicMySearch *valueSearch = [[publicMySearch alloc]init];
                char *author = (char *)sqlite3_column_text(statement, 0);
				char *externalId = (char *)sqlite3_column_text(statement, 1);
				char *issue = (char *)sqlite3_column_text(statement, 2);
				char *journal = (char *)sqlite3_column_text(statement, 3);
                char *pagination = (char *)sqlite3_column_text(statement, 4);
				char *pubDate = (char *)sqlite3_column_text(statement, 5);
				char *title = (char *)sqlite3_column_text(statement, 6);
				char *userid = (char *)sqlite3_column_text(statement, 7);
                char *volume = (char *)sqlite3_column_text(statement, 8);
                NSArray *array = [[NSArray alloc]init];
                //在把char指针转化为NSString时，要先确定不为空，否则强行转化会崩溃
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
				if(author!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)author];
                    array = [temp componentsSeparatedByString:@"::"];
                    [dic setObject:array forKey:@"author"];
				}
				if(externalId!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)externalId];
                    valueSearch.externalId = temp;
                    [dic setObject:valueSearch.externalId forKey:@"externalId"];
				}
                if(issue!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)issue];
                    valueSearch.issue = temp;
                    [dic setObject:valueSearch.issue forKey:@"issue"];
				}
                if(journal!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)journal];
                    valueSearch.journal = temp;
                    [dic setObject:valueSearch.journal forKey:@"journal"];
				}
                if(pagination!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)pagination];
                    valueSearch.pagination = temp;
                    [dic setObject:valueSearch.pagination forKey:@"pagination"];
				}
                if(pubDate!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)pubDate];
                    valueSearch.pubDate = temp;
                    [dic setObject:valueSearch.pubDate forKey:@"pubDate"];
				}
                if(title!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)title];
                    valueSearch.title = temp;
                    [dic setObject:valueSearch.title forKey:@"title"];
				}
                if(userid!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)userid];
                    valueSearch.userid = temp;
                    [dic setObject:valueSearch.userid forKey:@"userid"];
				}
                if (volume != nil) {
                    NSString *temp = [NSString stringWithUTF8String:(const char *)volume];
                    valueSearch.volume = temp;
                    [dic setObject:valueSearch.volume forKey:@"volume"];
                }
                // author,externalId,issue,journal,pagination, pubDate,title,userid,ismgr
				[fav addObject:dic];
                
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(imdDatabase);
	}
	return fav;
}
#pragma mark -
#pragma mark  简介表插入数据
+(void)insertDocValue:(NSString *)CKID WFID:(NSString *)WFID WPID:(NSString *)WPID PMID:(NSString *)PMID text:(NSString *)text affiliation:(NSString *)affiliation author:(NSString *)author category:(NSString *)category citation:(NSString *)citation coreJournal:(NSString *)coreJournal externalId:(NSString *)externalId iid:(NSString *)iid issue:(NSString *)issue journal:(NSString *)journal keywords:(NSString *)keywords machineCategory:(NSString *)machineCategory numCited:(NSString *)numCited pagination:(NSString *)pagination pubDate:(NSString *)pubDate reference:(NSString *)reference referenceCount:(NSString *)referenceCount title:(NSString *)title volume:(NSString *)volume ismgr:(NSString *)ismgr filePath:(NSString *)filePath{
	if([self connDatabase]){
		NSString *strSQL = @"insert into DocTable (CKID ,WFID,WPID,PMID,text,affiliation,author,category,citation,coreJournal,externalId, iid ,issue,journal,keywords,machineCategory,numCited,pagination,pubDate,reference,referenceCount,title,volume,ismgr,filePath) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(imdDatabase, [strSQL UTF8String], -1, &stmt, nil) == SQLITE_OK) {
            
            sqlite3_bind_text(stmt, 1, [CKID UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [WFID UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [WPID UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 4, [PMID UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 5, [text UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 6, [affiliation UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 7, [author UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 8, [category UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 9, [citation UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 10, [coreJournal UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 11, [externalId UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 12, [iid UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 13, [issue UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 14, [journal UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 15, [keywords UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 16, [machineCategory UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 17, [numCited UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 18, [pagination UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 19, [pubDate UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 20, [reference UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 21, [referenceCount UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 22, [title UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 23, [volume UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 24, [ismgr UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 25, [filePath UTF8String], -1, NULL);
        }
        if (sqlite3_step(stmt) != SQLITE_DONE)
            NSAssert1(0, @"Error insert table: %s", error);
        sqlite3_finalize(stmt);
	}
	sqlite3_close(imdDatabase);
}
//更新detail里边的数据
+(void)updateDocValue:(NSString *)CKID WFID:(NSString *)WFID WPID:(NSString *)WPID text:(NSString *)text affiliation:(NSString *)affiliation author:(NSString *)author category:(NSString *)category citation:(NSString *)citation coreJournal:(NSString *)coreJournal externalId:(NSString *)externalId iid:(NSString *)iid issue:(NSString *)issue journal:(NSString *)journal keywords:(NSString *)keywords machineCategory:(NSString *)machineCategory numCited:(NSString *)numCited pagination:(NSString *)pagination pubDate:(NSString *)pubDate reference:(NSString *)reference referenceCount:(NSString *)referenceCount title:(NSString *)title volume:(NSString *)volume ismgr:(NSString *)ismgr{
	char *errorMsg;
	if([self connDatabase]){
		NSString *update1=[NSString stringWithFormat:@"UPDATE DocTable SET CKID=('%@'),WFID=('%@'),WPID=('%@'),text=('%@'),affiliation=('%@'),author=('%@'),category=('%@'),citation=('%@'),coreJournal=('%@'),iid=('%@'),issue=('%@'),journal=('%@'),keywords=('%@'),machineCategory=('%@'),numCited=('%@'),pagination=('%@'),pubDate=('%@'),reference=('%@'),referenceCount=('%@'),title=('%@'),volume=('%@'),ismgr=('%@') WHERE externalId=('%@');",CKID ,WFID,WPID,text,affiliation,author,category,citation,coreJournal, iid ,issue,journal,keywords,machineCategory,numCited,pagination,pubDate,reference,referenceCount,title,volume,ismgr,externalId];
		sqlite3_exec(imdDatabase,[update1 UTF8String],NULL,NULL,&errorMsg);
		sqlite3_close(imdDatabase);
	}
}
+(BOOL)isSelectId:(NSString *)externalId ismgr:(NSString *)ismgr
{
    NSMutableArray *mutArray = [[NSMutableArray alloc]init];
    BOOL isId;
    if([self connDatabase]){
		NSString *query3 = [NSString stringWithFormat:@"SELECT externalId FROM DocTable where ismgr='%@';",ismgr] ;
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(imdDatabase, [query3 UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
                char *externalId = (char *)sqlite3_column_text(statement, 0);
                if(externalId!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)externalId];
                    [mutArray addObject:temp];
                    
                }
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(imdDatabase);
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
+(BOOL)isSelectId:(NSString *)externalId ismgr:(NSString *)ismgr userid:(NSString *)userid
{
    NSMutableArray *mutArray = [[NSMutableArray alloc]init];
    BOOL isId;
    if([self connDatabase]){
		NSString *query3 = [NSString stringWithFormat:@"SELECT externalId FROM MySearchTable where ismgr='%@' and userid='%@';",ismgr,userid] ;
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(imdDatabase, [query3 UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
                char *externalId = (char *)sqlite3_column_text(statement, 0);
                if(externalId!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)externalId];
                    [mutArray addObject:temp];
                    
                }
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(imdDatabase);
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

+(NSMutableDictionary *) readDocData:(NSString *)ismgr externalId:(NSString *)externalId{
    //事先创建可变数据了，为了装对象，对象里装具体每行各字段的信息
	NSMutableDictionary  *doc = [[NSMutableDictionary alloc] init];
	if([self connDatabase]){
		NSString *query3 = [NSString stringWithFormat:@"SELECT CKID ,WFID,WPID,PMID,text,affiliation,author,category,citation,coreJournal,externalId, iid ,issue,journal,keywords,machineCategory,numCited,pagination,pubDate,reference,referenceCount,title,volume FROM DocTable where ismgr='%@' and externalId='%@';",ismgr,externalId];
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(imdDatabase, [query3 UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
                //首先创建好对象，准备装值
				publicDoc *valueDoc = [[publicDoc alloc]init];
                char *CKID = (char *)sqlite3_column_text(statement, 0);
				char *WFID = (char *)sqlite3_column_text(statement, 1);
				char *WPID = (char *)sqlite3_column_text(statement, 2);
                char *PMID = (char *)sqlite3_column_text(statement, 3);
				char *text = (char *)sqlite3_column_text(statement, 4);
                char *affiliation = (char *)sqlite3_column_text(statement, 5);
				char *author = (char *)sqlite3_column_text(statement, 6);
				char *category = (char *)sqlite3_column_text(statement, 7);
				char *citation = (char *)sqlite3_column_text(statement, 8);
                char *coreJournal = (char *)sqlite3_column_text(statement, 9);
				char *externalId = (char *)sqlite3_column_text(statement, 10);
				char *iid = (char *)sqlite3_column_text(statement, 11);
				char *issue = (char *)sqlite3_column_text(statement, 12);
                char *journal = (char *)sqlite3_column_text(statement, 13);
				char *keywords = (char *)sqlite3_column_text(statement, 14);
				char *machineCategory = (char *)sqlite3_column_text(statement, 15);
				char *numCited = (char *)sqlite3_column_text(statement, 16);
                char *pagination = (char *)sqlite3_column_text(statement, 17);
				char *pubDate = (char *)sqlite3_column_text(statement, 18);
				char *reference = (char *)sqlite3_column_text(statement, 19);
				char *referenceCount = (char *)sqlite3_column_text(statement, 20);
                char *title = (char *)sqlite3_column_text(statement, 21);
				char *volume = (char *)sqlite3_column_text(statement, 22);
				
                
                
                if(CKID!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)CKID];
                    valueDoc.CKID = temp;
                    [doc setObject:valueDoc.CKID forKey:@"CKID"];
				}
				if(WFID!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)WFID];
                    valueDoc.WFID = temp;
                    [doc setObject:valueDoc.WFID forKey:@"WFID"];
				}
                if(WPID!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)WPID];
                    valueDoc.WPID = temp;
                    [doc setObject:valueDoc.WPID forKey:@"WPID"];
				}
                if(PMID!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)PMID];
                    valueDoc.PMID = temp;
                    [doc setObject:valueDoc.PMID forKey:@"PMID"];
				}
                
                if(text!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)text];
                    valueDoc.text = [temp componentsSeparatedByString:@"::"];
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                    [dic setObject:valueDoc.text forKey:@"text"];
                    [doc setObject:dic forKey:@"abstractText"];
				}
                if(affiliation!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)affiliation];
                    valueDoc.affiliation = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.affiliation forKey:@"affiliation"];
				}
                if(author!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)author];
                    valueDoc.author = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.author forKey:@"author"];
				}
                if(category!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)category];
                    valueDoc.category = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.category forKey:@"category"];
				}
                if(citation!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)citation];
                    valueDoc.citation = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.citation forKey:@"citation"];
				}
                if(coreJournal!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)coreJournal];
                    valueDoc.coreJournal = temp;
                    [doc setObject:valueDoc.coreJournal forKey:@"coreJournal"];
				}
                if(externalId!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)externalId];
                    valueDoc.externalId = temp;
                    [doc setObject:valueDoc.externalId forKey:@"externalId"];
				}
                if(iid!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)iid];
                    valueDoc.iid = temp;
                    [doc setObject:valueDoc.iid forKey:@"id"];
                }
                if(issue!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)issue];
                    valueDoc.issue = temp;
                    [doc setObject:valueDoc.issue forKey:@"issue"];
                }
                if(journal!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)journal];
                    valueDoc.journal = temp;
                    [doc setObject:valueDoc.journal forKey:@"journal"];
                }
                if(keywords!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)keywords];
                    valueDoc.keywords = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.keywords forKey:@"keywords"];
                }
                if(machineCategory!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)machineCategory];
                    valueDoc.machineCategory = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.machineCategory forKey:@"machineCategory"];
                }
                if(numCited!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)numCited];
                    valueDoc.numCited = temp;
                    [doc setObject:valueDoc.numCited forKey:@"numCited"];
				}
                if(pagination!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)pagination];
                    valueDoc.pagination = temp;
                    [doc setObject:valueDoc.pagination forKey:@"pagination"];
                    
				}
                if(pubDate!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)pubDate];
                    valueDoc.pubDate = temp;
                    [doc setObject:valueDoc.pubDate forKey:@"pubDate"];
                }
                if(reference!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)reference];
                    valueDoc.reference = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.reference forKey:@"reference"];
                }
                if(referenceCount!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)referenceCount];
                    valueDoc.referenceCount = temp;
                    [doc setObject:valueDoc.referenceCount forKey:@"referenceCount"];
                }
                if(title!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)title];
                    valueDoc.title = temp;
                    [doc setObject:valueDoc.title forKey:@"title"];
                }
                if(volume!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)volume];
                    valueDoc.volume = temp;
                    [doc setObject:valueDoc.volume forKey:@"volume"];
                }
            }
			sqlite3_finalize(statement);
		}
		sqlite3_close(imdDatabase);
	}
    
	return doc;
}
//取消收藏
+(void)cleanFav:(NSString *)tablename ismgr:(NSString *)ismgr externalId:(NSString *)externalId userid:(NSString *)userid {
	char *errorMsg;
	if([self connDatabase]){
		NSString *deleteStr=[NSString stringWithFormat:@"DELETE FROM %@ where ismgr='%@' and externalId='%@' and userid='%@'",tablename,ismgr,externalId,userid];
		if (sqlite3_exec (imdDatabase, [deleteStr UTF8String],NULL, NULL, &errorMsg) == SQLITE_OK){
			NSLog(@"fav删除成功");
		}else {
			NSLog(@"fav删除失败");
		}
	}
	sqlite3_close(imdDatabase);
}
//读取已下载的list and detail
+(NSMutableArray *) readDocData:(NSString *)ismgr{
    //事先创建可变数据了，为了装对象，对象里装具体每行各字段的信息
    NSMutableArray *result = [[NSMutableArray alloc]init];
	
	if([self connDatabase]){
		NSString *query3 = [NSString stringWithFormat:@"SELECT CKID ,WFID,WPID,text,affiliation,author,category,citation,coreJournal,externalId, iid ,issue,journal,keywords,machineCategory,numCited,pagination,pubDate,reference,referenceCount,title,volume,filePath,id FROM DocTable where ismgr='%@' order by id desc;",ismgr];
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(imdDatabase, [query3 UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
                NSMutableDictionary  *doc = [[NSMutableDictionary alloc] init];
                NSMutableDictionary  *dic = [[NSMutableDictionary alloc] init];
                //首先创建好对象，准备装值
				publicDoc *valueDoc = [[publicDoc alloc]init];
                char *CKID = (char *)sqlite3_column_text(statement, 0);
				char *WFID = (char *)sqlite3_column_text(statement, 1);
				char *WPID = (char *)sqlite3_column_text(statement, 2);
				char *text = (char *)sqlite3_column_text(statement, 3);
                char *affiliation = (char *)sqlite3_column_text(statement, 4);
				char *author = (char *)sqlite3_column_text(statement, 5);
				char *category = (char *)sqlite3_column_text(statement, 6);
				char *citation = (char *)sqlite3_column_text(statement, 7);
                char *coreJournal = (char *)sqlite3_column_text(statement, 8);
				char *externalId = (char *)sqlite3_column_text(statement, 9);
				char *iid = (char *)sqlite3_column_text(statement, 10);
				char *issue = (char *)sqlite3_column_text(statement, 11);
                char *journal = (char *)sqlite3_column_text(statement, 12);
				char *keywords = (char *)sqlite3_column_text(statement, 13);
				char *machineCategory = (char *)sqlite3_column_text(statement, 14);
				char *numCited = (char *)sqlite3_column_text(statement, 15);
                char *pagination = (char *)sqlite3_column_text(statement, 16);
				char *pubDate = (char *)sqlite3_column_text(statement, 17);
				char *reference = (char *)sqlite3_column_text(statement, 18);
				char *referenceCount = (char *)sqlite3_column_text(statement, 19);
                char *title = (char *)sqlite3_column_text(statement, 20);
				char *volume = (char *)sqlite3_column_text(statement, 21);
				char *filePath = (char *)sqlite3_column_text(statement, 22);
                
                
                if(CKID!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)CKID];
                    valueDoc.CKID = temp;
                    [doc setObject:valueDoc.CKID forKey:@"CKID"];
				}
				if(WFID!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)WFID];
                    valueDoc.WFID = temp;
                    [doc setObject:valueDoc.WFID forKey:@"WFID"];
				}
                if(WPID!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)WPID];
                    valueDoc.WPID = temp;
                    [doc setObject:valueDoc.WPID forKey:@"WPID"];
				}
                if(text!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)text];
                    valueDoc.text = [temp componentsSeparatedByString:@"::"];
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                    [dic setObject:valueDoc.text forKey:@"text"];
                    [doc setObject:dic forKey:@"abstractText"];
				}
                if(affiliation!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)affiliation];
                    valueDoc.affiliation = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.affiliation forKey:@"affiliation"];
				}
                if(author!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)author];
                    valueDoc.author = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.author forKey:@"author"];
				}
                if(category!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)category];
                    valueDoc.category = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.category forKey:@"category"];
				}
                if(citation!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)citation];
                    valueDoc.citation = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.citation forKey:@"citation"];
				}
                if(coreJournal!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)coreJournal];
                    valueDoc.coreJournal = temp;
                    [doc setObject:valueDoc.coreJournal forKey:@"coreJournal"];
				}
                if(externalId!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)externalId];
                    valueDoc.externalId = temp;
                    [doc setObject:valueDoc.externalId forKey:@"externalId"];
				}
                if(iid!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)iid];
                    valueDoc.iid = temp;
                    [doc setObject:valueDoc.iid forKey:@"id"];
                }
                if(issue!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)issue];
                    valueDoc.issue = temp;
                    [doc setObject:valueDoc.issue forKey:@"issue"];
                }
                if(journal!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)journal];
                    valueDoc.journal = temp;
                    [doc setObject:valueDoc.journal forKey:@"journal"];
                }
                if(keywords!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)keywords];
                    valueDoc.keywords = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.keywords forKey:@"keywords"];
                }
                if(machineCategory!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)machineCategory];
                    valueDoc.machineCategory = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.machineCategory forKey:@"machineCategory"];
                }
                if(numCited!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)numCited];
                    valueDoc.numCited = temp;
                    [doc setObject:valueDoc.numCited forKey:@"numCited"];
				}
                if(pagination!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)pagination];
                    valueDoc.pagination = temp;
                    [doc setObject:valueDoc.pagination forKey:@"pagination"];
                    
				}
                if(pubDate!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)pubDate];
                    valueDoc.pubDate = temp;
                    [doc setObject:valueDoc.pubDate forKey:@"pubDate"];
                }
                if(reference!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)reference];
                    valueDoc.reference = [temp componentsSeparatedByString:@"::"];
                    [doc setObject:valueDoc.reference forKey:@"reference"];
                }
                if(referenceCount!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)referenceCount];
                    valueDoc.referenceCount = temp;
                    [doc setObject:valueDoc.referenceCount forKey:@"referenceCount"];
                }
                if(title!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)title];
                    valueDoc.title = temp;
                    [doc setObject:valueDoc.title forKey:@"title"];
                }
                if(volume!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)volume];
                    valueDoc.volume = temp;
                    [doc setObject:valueDoc.volume forKey:@"volume"];
                }
                if(filePath!=nil){
					NSString *temp = [NSString stringWithUTF8String:(const char *)filePath];
                    valueDoc.filePath = temp;
                    [dic setObject:valueDoc.filePath forKey:LOCAL_PDF_PATH];
                }
                
                [dic setObject:doc forKey:LOCAL_RESULT];
                [result addObject:dic];
            }
			sqlite3_finalize(statement);
		}
		sqlite3_close(imdDatabase);
	}
    
	return result;
}
//删除本地的数据
+(void)cleanLocalTable:(NSString *)externalId userid:(NSString *)userid{
	char *errorMsg;
	if([self connDatabase]){
		NSString *deleteStr=[NSString stringWithFormat:@"DELETE FROM DocTable where externalId='%@' and ismgr='%@'",externalId,userid];
		if (sqlite3_exec (imdDatabase, [deleteStr UTF8String],NULL, NULL, &errorMsg) == SQLITE_OK){
			NSLog(@"删除成功");
		}else {
			NSLog(@"删除失败");
		}
	}
	sqlite3_close(imdDatabase);
}
//索取中 已索取读数据库
+(NSMutableArray *) readAskData:(NSString *)ismgr userid:(NSString *)userid{
    //事先创建可变数据了，为了装对象，对象里装具体每行各字段的信息
	NSMutableArray  *fav = [[NSMutableArray alloc] init];
	if([self connDatabase]){
		NSString *query3 = [NSString stringWithFormat:@"SELECT author,externalId,issue,journal,pagination, pubDate,title,userid,volume FROM MySearchTable where ismgr='%@' and userid='%@';",ismgr,userid];
		sqlite3_stmt *statement;
		if (sqlite3_prepare_v2(imdDatabase, [query3 UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
                //首先创建好对象，准备装值
				publicMySearch *valueSearch = [[publicMySearch alloc]init];
                char *author = (char *)sqlite3_column_text(statement, 0);
				char *externalId = (char *)sqlite3_column_text(statement, 1);
				char *issue = (char *)sqlite3_column_text(statement, 2);
				char *journal = (char *)sqlite3_column_text(statement, 3);
                char *pagination = (char *)sqlite3_column_text(statement, 4);
				char *pubDate = (char *)sqlite3_column_text(statement, 5);
				char *title = (char *)sqlite3_column_text(statement, 6);
				char *userid = (char *)sqlite3_column_text(statement, 7);
                char *volume = (char *)sqlite3_column_text(statement, 8);
                NSArray *array = [[NSArray alloc]init];
                //在把char指针转化为NSString时，要先确定不为空，否则强行转化会崩溃
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                NSString *ss;
                ss = nil;
                if(externalId!=nil){
					ss = [NSString stringWithUTF8String:(const char *)externalId];
                }
                if (![ss isEqualToString:@"(null)"] && ss!=nil) {
                    if(author!=nil){
                        NSString *temp = [NSString stringWithUTF8String:(const char *)author];
                        array = [temp componentsSeparatedByString:@"::"];
                        [dic setObject:array forKey:@"author"];
                    }
                    if(externalId!=nil){
                        NSString *temp = [NSString stringWithUTF8String:(const char *)externalId];
                        valueSearch.externalId = temp;
                        [dic setObject:valueSearch.externalId forKey:@"externalId"];
                    }
                    if(issue!=nil){
                        NSString *temp = [NSString stringWithUTF8String:(const char *)issue];
                        valueSearch.issue = temp;
                        [dic setObject:valueSearch.issue forKey:@"issue"];
                    }
                    if(journal!=nil){
                        NSString *temp = [NSString stringWithUTF8String:(const char *)journal];
                        valueSearch.journal = temp;
                        [dic setObject:valueSearch.journal forKey:@"journal"];
                    }
                    if(pagination!=nil){
                        NSString *temp = [NSString stringWithUTF8String:(const char *)pagination];
                        valueSearch.pagination = temp;
                        [dic setObject:valueSearch.pagination forKey:@"pagination"];
                    }
                    if(pubDate!=nil){
                        NSString *temp = [NSString stringWithUTF8String:(const char *)pubDate];
                        valueSearch.pubDate = temp;
                        [dic setObject:valueSearch.pubDate forKey:@"pubDate"];
                    }
                    if(title!=nil){
                        NSString *temp = [NSString stringWithUTF8String:(const char *)title];
                        valueSearch.title = temp;
                        [dic setObject:valueSearch.title forKey:@"title"];
                    }
                    if(userid!=nil){
                        NSString *temp = [NSString stringWithUTF8String:(const char *)userid];
                        valueSearch.userid = temp;
                        [dic setObject:valueSearch.userid forKey:@"userid"];
                    }
                    if (volume != nil) {
                        NSString *temp = [NSString stringWithUTF8String:(const char *)volume];
                        valueSearch.volume = temp;
                        [dic setObject:valueSearch.volume forKey:@"volume"];
                    }
                    // author,externalId,issue,journal,pagination, pubDate,title,userid,ismgr
                    [fav addObject:dic];
                    
                }
            }
			sqlite3_finalize(statement);
		}
		sqlite3_close(imdDatabase);
	}
	return fav;
}

@end
