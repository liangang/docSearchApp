//
//  IPhoneMySearchController.h
//  imdSearch
//
//  Created by Huajie Wu on 12-2-14.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "RefreshView.h"
@interface IPhoneMySearchController : UIViewController <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate,RefreshViewDelegate>
{
    NSMutableArray* favs;
    NSMutableDictionary* mgrFavs;

    IBOutlet UIActivityIndicatorView* indicator;
    UIAlertView* alertView;
    IBOutlet UITableView* _tableView;
    IBOutlet UIView* noResultsView;
    ASIHTTPRequest* _httpRequest;
    int selectIndex;
    
    BOOL isUpdataDetail;
    BOOL isDeleteDoc;
    NSMutableDictionary* dicresultsJson;
    NSString *text;
    NSString *aaffiliation;
    NSString *author;
    NSString *category;
    NSString *citation;
    NSString *keywords;
    NSString *machineCategory;
    NSString *reference;

    RefreshView *refreshView;
}

@property (nonatomic, retain) NSMutableArray* favs;
@property (nonatomic, retain) NSMutableDictionary* mgrFavs;
@property (nonatomic,retain) UIAlertView* alertView;

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* indicator;
@property (nonatomic,retain) IBOutlet UITableView* tableView;
@property (nonatomic,retain) IBOutlet UIView* noResultsView;
@property (nonatomic,retain) IBOutlet UIImageView* noResultsImageView;
@property (nonatomic,retain) ASIHTTPRequest* httpRequest;
@property (nonatomic,assign) int selectIndex;
@property (nonatomic, retain) NSMutableDictionary* dicresultsJson;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *aaffiliation;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *citation;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, copy) NSString *machineCategory;
@property (nonatomic, copy) NSString *reference;
@property (nonatomic, retain)  RefreshView *refreshView;
//-(void) userLoginFinished;
//-(void) loginViewDismissed;
//-(void) userLoginClose;
-(void) removeFavs:(NSUInteger)index;
-(void)toggleEditDone;

-(void)sync;
- (void)refresh;
@end
