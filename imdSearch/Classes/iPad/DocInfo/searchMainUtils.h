//
//  searchMainUtils.h
//  imdSearch
//
//  Created by xiangzhang on 4/15/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface searchMainUtils : NSObject
/**
 *  获取pdf的文件名
 *
 *  @param externelId pdf的唯一id
 *
 *  @return 文件名
 */
+ (NSString *) fileNameWithExternelId:(NSString*)externelId;

/**
 *  获取cache文件夹中得文件路径
 *
 *  @param fileName 文件名
 *
 *  @return 文件路径
 */
+ (NSString *)filePathInCache:(NSString *)fileName;

/**
 *  获取documents文件夹中文件的路径
 *
 *  @param fileName 文件名
 *
 *  @return 文件路径
 */
+ (NSString *)filePathInDocuments:(NSString *)fileName;

/**
 *  获取plist文件的信息
 *
 *  @param fileName plist文件名
 *
 *  @return 信息字典
 */
+ (NSDictionary*)readPListBundleFile:(NSString*)fileName;

@end
