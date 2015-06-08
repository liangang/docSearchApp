//
//  IPhoneSearchMgr.h
//  imdSearch
//
//  Created by Huajie Wu on 12-2-14.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "RefreshView.h"

@interface IPhoneSearchMgr : UIViewController <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate,RefreshViewDelegate>
{
    BOOL isDownloadShown;
    BOOL isUpdataDetail;
    BOOL isGo;
}

@property (nonatomic, retain) ASIHTTPRequest* httpRequest;

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIView* noResultsView;
@property (nonatomic, retain) IBOutlet UIImageView* noResultsImageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* indicator;

@property (nonatomic, retain) NSMutableArray* downloadArray;
@property (nonatomic, retain) NSMutableArray* requestArray;
@property (nonatomic, retain) NSMutableDictionary* mgrDownload;
@property (nonatomic, retain) NSMutableDictionary* mgrRequest;

@property (nonatomic, retain) UIAlertView* alertView;
@property (nonatomic, assign) BOOL isDownloadShown;
@property (nonatomic, retain) IBOutlet UISegmentedControl* segCtr;

@property (nonatomic, assign) NSString *selectValue;
@property (nonatomic, retain) NSMutableDictionary* dicresultsJson;
@property (nonatomic, retain) NSMutableArray* waitrequestArray;
@property (nonatomic, assign) BOOL isWaitRequest;
@property (nonatomic, retain) RefreshView *refreshView;


- (NSMutableArray *)requestArrayInit:(NSMutableArray*)request download:(NSArray*)download;
- (void)removeItem:(NSUInteger)index;

- (void)toggleEditDone;

- (void)showView;
- (void)addWhichValue:(NSString *)ismgr;
- (void)showDownload;
- (void)showRequest;

- (void)showRequesting;

- (void)showNotInTabBar;
- (void)sync;
- (void)addRefreshView;

- (void)changeIconCount:(NSString *)externalId;
@end
