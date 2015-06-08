//
//  RequestDocInfo.m
//  imdSearch
//
//  Created by Huajie Wu on 11-12-6.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "RequestDocInfo.h"
#import "ASIHTTPRequestDelegate.h"
#import "UrlRequest.h"
#import "Strings.h"
#import "IPhoneHeader.h"
#import "DocArticleController.h"
#import "imdSearchAppDelegate_iPhone.h"

@implementation RequestDocInfo

@synthesize alertView, localInfo;
@synthesize httpRequest;
@synthesize isFetched ;
@synthesize isRequesting;
@synthesize delegate;
@synthesize emailActive, mobileActive;

-(id)init
{
    self = [super init];
    if (self) {
        localInfo = [[NSMutableDictionary alloc] init];
      
        isFetched = NO;
        isRequesting = NO;
    }
    return self;
}

-(void) dealloc
{
    if (httpRequest != nil) {
        [httpRequest clearDelegatesAndCancel];
    }
}

#pragma mark Asy Request

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSString* resultsJson = [request responseString];
    
    if ([self.delegate respondsToSelector:@selector(docdetailRequestFinishedWithString:)]) {
        [self.delegate docdetailRequestFinishedWithString:resultsJson];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    NSLog(@"request error %@", [request error]);
  UIAlertView *alertViews = [[UIAlertView alloc] initWithTitle:REQUEST_DOC message:REQUEST_DOC_FAILED delegate:nil cancelButtonTitle:REQUEST_DOC_CONFIRM otherButtonTitles:nil];
    [alertViews show];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)findInCache:(NSString*)externelId
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* array = [defaults arrayForKey:FULLTEXT_REQUEST_LIST];
    
    int i = 0;
    for (i = 0; i < [array count]; ++i) {
        NSString* cachedID = [[[array objectAtIndex:i] objectForKey:LOCAL_RESULT] objectForKey:DOC_EXTERNALID];
        if([cachedID isEqualToString:externelId]) {
            NSLog(@"This has been found in cache: %@", cachedID);
            break;
        }
    }
    if (i == [array count]) {
        return NO;
    } else {
        return YES;
    }
}
@end
