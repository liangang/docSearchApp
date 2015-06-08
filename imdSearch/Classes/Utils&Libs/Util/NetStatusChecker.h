//
//  NetStatusChecker.h
//  imdSearch
//
//  Created by 立纲 吴 on 12/24/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetStatusChecker : NSObject
+(BOOL)isNetworkAvailbe;
+(BOOL)isUsingWifi;

@end
