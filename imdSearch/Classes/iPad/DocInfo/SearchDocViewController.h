//
//  SearchDocViewController.h
//  imdSearch
//
//  Created by xiangzhang on 4/16/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AdvSearchViewController.h"
#import "SearchContentMainViewController.h"

typedef NS_ENUM(NSInteger, SearchType){
    SearchTypeNormal = 0,
    SearchTypeAdvance
};

@interface SearchDocViewController : UIViewController

@property (assign, nonatomic) id<SearchContentShowDelegate> delegate;
@property (strong, nonatomic) AdvSearchViewController *advSearchViewController;

@property (strong, nonatomic) IBOutlet UIView *titleContentView;
@property (strong, nonatomic) IBOutlet UIImageView *titleBgImg;
@property (strong, nonatomic) IBOutlet UILabel *titleInfoLabel;
@property (strong, nonatomic) IBOutlet UIButton *heightBackBtn;
@property (strong, nonatomic) IBOutlet UIButton *favouriteSaveBtn;
@property (strong, nonatomic) IBOutlet UIButton *advanceBtn;
@property (strong, nonatomic) IBOutlet UISegmentedControl *searchTypeSegmentView;
@property (nonatomic, strong) IBOutlet UITableView *searchSuggestTableView;


@property (strong, nonatomic) IBOutlet UIView *searchBarContentView;
@property (strong, nonatomic) IBOutlet UIView *listContentView;

// 高级检索需要用到的属性
@property (assign, nonatomic)   BOOL advViewOn;
@property (assign, nonatomic)   BOOL advViewAnimating;

@property (assign, nonatomic)   int advancedQueryItemCount;
@property (assign, nonatomic)   int advancedQueryItemCountMax;

@property (assign, nonatomic)   BOOL newAdvSearch;
@property (assign, nonatomic)   BOOL coreJournalOn;
@property (assign, nonatomic)   BOOL sciOn;
@property (assign, nonatomic)   BOOL reviewsOn;

@property (strong, nonatomic) NSDictionary *filterItemData;
@property (strong, nonatomic) NSMutableArray *filterNames;
@property (strong, nonatomic) NSMutableArray *filterValues;
@property (strong, nonatomic) NSMutableArray *filterOperations;
@property (strong, nonatomic) NSString  *minYear;
@property (strong, nonatomic) NSString  *maxYear;


- (IBAction)heightBackBtnClick:(id)sender;
- (IBAction)favouriteSaveBtnClick:(id)sender;

- (IBAction)advanceViewShow:(id)sender;
- (void)advanceViewHide;
- (IBAction)seachTypeValueChange:(id)sender;

-(void)selectedOperation:(id)sender;
@end
