//
//  MyDocmentListPadViewController.h
//  imdSearch
//
//  Created by xiangzhang on 4/15/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EnumType.h"
#import "SearchContentMainViewController.h"

@class ASIHTTPRequest;

@protocol MyDocumentListDelegate <NSObject>

- (void)reloadtableView;

@end

/**
 *  根据内容分类类型的不同来进行不同的显示，通过ListType 来进行判别
 *  分类主要有文献记录，我的收藏，本地文献三个分类
 */
@interface MyDocmentListPadViewController : UITableViewController

@property (nonatomic, assign) id<MyDocumentListDelegate> listDelegate;
@property (nonatomic, assign) id<SearchContentShowDelegate> mainDelegate;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) ListType listType;
@property (nonatomic, assign) DocType docType;

@property (nonatomic, strong) ASIHTTPRequest *listRequest;
@property (nonatomic, assign) int currentDisplayingRow;
/**
 *  用于刷新数据
 */
- (void)refresh;
- (void)showLocationListInfo;
@end
