//
//  ImdRate.m
//  imdSearch
//
//  Created by ding zhihong on 12-3-30.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "ImdRate.h"
#import "iRate.h"

#define SEARCH_APP_ID 492028918

@implementation ImdRate

+ (void) searchApp
{
  [iRate sharedInstance].appStoreID = SEARCH_APP_ID;
  [iRate sharedInstance].debug = false;
}

/**
 * go to imdSearch App Page on App store
 */
+ (void)goToAppStore
{
  [[iRate sharedInstance] openRatingsPageInAppStore];
//  [[iRate sharedInstance] release];
}

@end
