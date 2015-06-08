//
//  UserManager.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-25.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "UserManager.h"
#import "IPhoneHeader.h"
#import "imdSearchAppDelegate_iPhone.h"

@implementation UserManager
{
    
}

+(BOOL) isLogin
{
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    return useLogined;
}


+(NSString*) userName
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
}


+ (BOOL) logout
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"logined"];

    [defaults removeObjectForKey:FULLTEXT_DOWNLOAD_LIST];
    [defaults removeObjectForKey:FULLTEXT_REQUEST_LIST];
    [defaults removeObjectForKey:QUERY_HISTORY_LIST];
    [defaults synchronize];

    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    [appDelegate logout];
    
    return YES;
}

@end
