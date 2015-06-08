//
//  ISBaseInfoManager.m
//  imdSearch
//
//  Created by xiangzhang on 1/8/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "ISBaseInfoManager.h"


#define USERINFOID  @"userInfoId"

@implementation ISBaseInfoManager

+ (void)saveUserInfoId:(NSString *)uid{
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:USERINFOID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getUserInfoId{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERINFOID];
}

+ (BOOL)getFirstOpenInCurrentVersion{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *key = [NSString stringWithFormat:@"firstLogined_%@",version];
    BOOL isFirst = [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
    
    return isFirst;
}

+ (void)setFirstOpenInCurrentVersion:(BOOL)flag{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *key = [NSString stringWithFormat:@"firstLogined_%@",version];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:flag] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getFirstHelpInCurrentVersion{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *key = [NSString stringWithFormat:@"firstHelped_%@",version];
    
   return [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
}

+ (void)setFirstHelpInCurrentVersion:(BOOL)flag{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *key = [NSString stringWithFormat:@"firstHelped_%@",version];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:flag] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
