//
//  imdSearchAppDelegate_iPad.h
//  imdSearch
//
//  Created by 8fox on 9/9/11.
//  Copyright 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imdSearchAppDelegate.h"
#import "ASIHTTPRequest.h"

#import "WXApi.h"
#import "WeiboApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

@class SearchContentMainViewController;

@interface imdSearchAppDelegate_iPad : imdSearchAppDelegate<UIApplicationDelegate> {

  ASIHTTPRequest* _httpRequest;
  NSString * responseString;
  UIAlertView *alertView1;
  NSString* appStoreVersion;
}

@property (nonatomic, retain) ASIHTTPRequest* httpRequest;
@property (nonatomic,copy) NSString * responseString;
@property (nonatomic,retain) UIAlertView *alertView1;
@property (nonatomic,copy) NSString *appStoreVersion;
@property (nonatomic, strong) IBOutlet SearchContentMainViewController *mainController;
@property (nonatomic,retain) NSString *urlApp;
@end
