//
//  DatabaseManager.h
//  imdSearch
//
//  Created by xiangzhang on 3/26/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "sqlite3.h"

#import "DocInfoRecord.h"

#define DataBaseNameFile @"docRecord.sqlite"

@interface DatabaseManager : NSObject
/**
 *  创建所需要的数据库的文件
 */
+ (void)createDataBase;

/**
 *  获取数据库的路径
 *
 *  @return 数据库所在路径
 */
+ (NSString *)getDataBaseFilePath;

/**
 *  连接数据库
 *
 *  @return 是否连接成功
 */
+ (BOOL)connectionDatabase;

/**
 *  插入数据到数据库中
 *
 *  @param record 插入数据的model
 */
+ (void)insertToDataBaseWithRecord:(DocInfoRecord *)record;

/**
 *  获取数据库中得数据
 *
 *  @return 保存在数据库中的数据
 */
+ (NSMutableArray *)getRecordFromDatabaseWithUserId:(NSString *)userId;

/**
 *  更新用户的文献读取记录状态
 *
 *  @param isRead 是否已读取
 */
+ (void)updataRecordReadStatus:(BOOL)isRead externalId:(NSString *)externalId withUserId:(NSString *)userId;

/**
 *  删除特定的记录信息
 *
 *  @param record 文献记录的model
 */
+ (void)deleteRecordInfo:(DocInfoRecord *)record;


@end
