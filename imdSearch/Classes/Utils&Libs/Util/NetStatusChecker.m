//
//  NetStatusChecker.m
//  imdSearch
//
//  Created by 立纲 吴 on 12/24/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "NetStatusChecker.h"
#import "Reachability.h"
#import "url.h"

@implementation NetStatusChecker

#pragma mark - network checking
+(BOOL)isNetworkAvailbe
{ 
    Reachability* wifiReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    
    switch (netStatus)
    {
      case NotReachable:
      {
        NSLog(@"Access Not Available");
        return NO;
        break;
      }
        
      case ReachableViaWWAN:
      {
        NSLog(@"Reachable WWAN");
        break;
      }
      case ReachableViaWiFi:
      {
        NSLog(@"Reachable WiFi 1");
        break;
      }
    }
    return YES;
}

+(BOOL)isUsingWifi
{
    Reachability* wifiReach = [Reachability reachabilityWithHostName: NETSTATUS_SERVER];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"Access Not Available");
            return NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"Reachable WiFi 2");
            return YES;
            break;
        }    
        case ReachableViaWWAN:
        {
            NSLog(@"Reachable WWAN");
            return NO;
            break;
        }
       
    }

    
    return NO;
}
@end
