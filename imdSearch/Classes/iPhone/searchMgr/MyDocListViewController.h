//
//  MyDocListViewController.h
//  imdSearch
//
//  Created by xiangzhang on 3/25/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EnumType.h"

@class ASIHTTPRequest;

@protocol MyDocListDelegate <NSObject>

- (void)tableViewReload;

@end

@interface MyDocListViewController : UITableViewController

@property (nonatomic, strong) id<MyDocListDelegate> listDelegate;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) ListType listType;
@property (nonatomic, assign) DocType docType;

@property (nonatomic, strong) ASIHTTPRequest *listRequest;


- (void)refresh;

- (void)clearRequestDelegate;

- (void)getRecordInfoRequest:(DocType)type startIndex:(NSInteger)start;
- (void)getcollectionInfoRequest:(DocType)type start:(NSInteger)start;
- (void)collectionItemRemove:(NSString *)externalId;

- (void)requestCollectionFinish:(ASIHTTPRequest *)request;
- (void)showLocationListInfo;
@end
