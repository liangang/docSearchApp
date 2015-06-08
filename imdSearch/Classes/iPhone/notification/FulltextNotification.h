//
//  FulltextNotification.h
//  imdSearch
//
//  Created by Huajie Wu on 12-3-23.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FulltextNotification : NSObject


+ (void) startDownloadingDataFromProvider;
+ (void) sendProviderDeviceToken:(const void *) tokenBytes;

@end
