//
//  UserManager.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-25.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject


+ (BOOL) isLogin;
+ (NSString*) userName;
+ (BOOL) logout;
@end
