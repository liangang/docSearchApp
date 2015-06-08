//
//  IPhoneMainSearch.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-11.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginController.h"
#import "StartCoverViewController.h"
#import "SearchResults.h"

@interface IPhoneMainSearch : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UINavigationControllerDelegate, UITableViewDelegate>{
    
    BOOL isFirstTime;
    UIImageView *imageView;
}

@property (nonatomic, retain) NSMutableArray *suggestions;
@property (nonatomic, retain) NSMutableArray *queryHistory;

@property (nonatomic, retain) ASIHTTPRequest *httpRequest;

@property (nonatomic, retain) UIAlertView *alertView;

@property (nonatomic, retain) SearchResults *resultsList;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, retain) IBOutlet UITableView *historyTable;

@property (nonatomic, assign) BOOL isFirstTime;

- (void)doSearch:(NSString*) queryStr source:(NSString*)source;

- (void)willStartLogin;
- (void)didFinishStart;
- (void)dismissCover;
- (void)clearHistory;
@end
