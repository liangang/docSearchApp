//
//  SearchResultsList.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-21.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@interface SearchResultsList : UITableViewController <ASIHTTPRequestDelegate>
{
    NSMutableArray* resultsArray;
    NSString* queryStr;
    NSInteger count;
    NSInteger lastRequestCount;

    NSInteger pageNo;
    NSInteger pageSize;
    NSInteger sort;
    NSString* source;
    IBOutlet UIActivityIndicatorView* indicator;
    UIAlertView* alertView;
    ASIHTTPRequest* _httpRequest;
}
@property (nonatomic, retain) ASIHTTPRequest* httpRequest;


@property (nonatomic, retain) NSMutableArray* resultsArray;
@property (nonatomic, retain) NSString* queryStr;

@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger sort;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger lastRequestCount;

@property (nonatomic, retain) NSString* source;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* indicator;

@property (nonatomic,retain) UIAlertView* alertView;

-(void) loadMore:(NSMutableArray *)data;

-(void) popBack;

@end
