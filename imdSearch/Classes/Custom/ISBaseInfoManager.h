//
//  ISBaseInfoManager.h
//  imdSearch
//
//  Created by xiangzhang on 1/8/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISBaseInfoManager : NSObject

+ (void)saveUserInfoId:(NSString *)uid;
+ (NSString *)getUserInfoId;

+ (void)setFirstOpenInCurrentVersion:(BOOL)flag;
+ (BOOL)getFirstOpenInCurrentVersion;

+ (void)setFirstHelpInCurrentVersion:(BOOL)flag;
+ (BOOL)getFirstHelpInCurrentVersion;
@end
