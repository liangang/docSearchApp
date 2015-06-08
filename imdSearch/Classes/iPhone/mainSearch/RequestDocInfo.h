//
//  RequestDocInfo.h
//  imdSearch
//
//  Created by Huajie Wu on 11-12-6.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"


@protocol DocArticleControlDelegate;

@interface RequestDocInfo : NSObject <ASIHTTPRequestDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) BOOL emailActive;
@property (nonatomic, assign) BOOL mobileActive;

@property (nonatomic, assign) id<DocArticleControlDelegate> delegate;

@property (nonatomic, retain) ASIHTTPRequest* httpRequest;

@property (nonatomic, assign) UIAlertView* alertView;

@property (nonatomic, assign) BOOL isFetched;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, retain) NSMutableDictionary* localInfo;

-(BOOL)findInCache:(NSString*)externelId;

@end
