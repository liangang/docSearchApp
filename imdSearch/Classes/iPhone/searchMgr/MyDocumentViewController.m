//
//  MyDocumentViewController.m
//  imdSearch
//
//  Created by xiangzhang on 3/18/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "MyDocumentViewController.h"

#import "ASIHTTPRequest.h"
#import "RefreshView.h"
#import "ImdAppBehavior.h"

#import "Util.h"
#import "Strings.h"
#import "publicMySearch.h"
#import "TableViewFormatUtil.h"
#import "UserManager.h"

#import "MyDataBaseSql.h"
#import "MyDatabase.h"

#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "DocArticleController.h"

#import "DocInfoRecord.h"
#import "MyDocListViewController.h"

#define defaultLimit 15
#define BackgroundRecord        @"noRecordBg"
#define BackgroundFav           @"noFavBg"
#define BackgroundLocation      @"noLocationBg"

@interface MyDocumentViewController ()<UIActionSheetDelegate,ASIHTTPRequestDelegate>{
  
}

@property (assign, nonatomic) ListType listType;
@property (assign, nonatomic) DocType docType_record;
@property (assign, nonatomic) DocType docType_collection;
@property (assign, nonatomic) DocType docType_location;
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UIView *bgView;

@property (strong, nonatomic) MyDocListViewController *locationListViewController;
@end

@implementation MyDocumentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _docType_record = _docType_collection = _docType_location = DocTypeAll;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"docType_all", nil) style:UIBarButtonItemStylePlain target:self action:@selector(docTypeSelect:)];
    self.navigationItem.title = NSLocalizedString(@"myDocument", nil);
    [TableViewFormatUtil setBorder:self.titleView Color:[UIColor lightGrayColor]];
    [TableViewFormatUtil backBarButtonItemInfoModify:self.navigationItem];
    
    [self addTableViewToContent];
  self.bgView.frame = self.contentScrollView.frame;
    self.bgImageView.center = CGPointMake(self.contentScrollView.center.x, self.contentScrollView.center.y-44);
    
    if (!(IOS7)) {
        self.docSegmentd.layer.borderColor = APPDefaultColor.CGColor;
        self.docSegmentd.layer.borderWidth = 1.0f;
        self.docSegmentd.layer.cornerRadius = 4.0f;
        self.docSegmentd.layer.masksToBounds = YES;
        CGRect rect = self.docSegmentd.frame;
        rect.size.height = 29;
        self.docSegmentd.frame = rect;
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // init tableView with Database info list
    [self segValueChanged:self.docSegmentd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollVIew init with diff TableView
- (void)addTableViewToContent{
    CGRect rect = self.contentScrollView.frame;
    self.contentScrollView.scrollEnabled = NO;
    [self.contentScrollView setContentSize:CGSizeMake(rect.size.width * 3, rect.size.height)];
    
    CGRect rect1 = CGRectMake(0, 0, rect.size.width, rect.size.height - (IOS7 ? 46 : 0));
    self.recordListViewController = [[MyDocListViewController alloc] init];
    self.recordListViewController.listDelegate = self;
    self.recordListViewController.listType = ListTypeRecord;
    [self.recordListViewController.view setFrame:rect1];
    [self.contentScrollView addSubview:self.recordListViewController.view];
    
    self.colllectionListViewController = [[MyDocListViewController alloc] init];
    self.colllectionListViewController.listDelegate = self;
    self.colllectionListViewController.listType = ListTypeCollection;
    rect1.origin.x += rect1.size.width;
    [self.colllectionListViewController.view setFrame:rect1];
    [self.contentScrollView addSubview:self.colllectionListViewController.view];
    
    self.locationListViewController = [[MyDocListViewController alloc] init];
    self.locationListViewController.listType = ListTypeLocation;
    self.locationListViewController.listDelegate = self;
    rect1.origin.x += rect1.size.width;
    [self.locationListViewController.view setFrame:rect1];
    [self.contentScrollView addSubview:self.locationListViewController.view];
}

#pragma mark - UIView touch event
- (IBAction)segValueChanged:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    switch ([segment selectedSegmentIndex]) {
        case ListTypeRecord:
            {
                self.listType = ListTypeRecord;
                [self setRightItemWithListType:self.listType DocType:self.docType_record];
                [self.contentScrollView setContentOffset:CGPointZero animated:NO];
              if ([self.recordListViewController.dataArr count] <=0) {
                [self.recordListViewController refresh];
              }
            }
            break;
            
        case ListTypeCollection:
            {
                self.listType = ListTypeCollection;
                [self setRightItemWithListType:self.listType DocType:self.docType_collection];
                [self.contentScrollView setContentOffset:CGPointMake(self.contentScrollView.frame.size.width, 0) animated:NO];
              if ([self.colllectionListViewController.dataArr count] <=0) {
                [self.colllectionListViewController refresh];
              }
            }
            break;
        case ListTypeLocation:
            {
                self.navigationItem.rightBarButtonItem = nil;
                self.listType = ListTypeLocation;
//                [self setRightItemWithListType:self.listType DocType:self.docType_location];
                [self.contentScrollView setContentOffset:CGPointMake(self.contentScrollView.frame.size.width*2, 0) animated:NO];
              
                [self.locationListViewController showLocationListInfo];
            }
            break;
        default:
            break;
    }
    
    [self setnoValueBackImage];
}

- (IBAction)docTypeSelect:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel_btn", nil) destructiveButtonTitle:NSLocalizedString(@"docType_all",nil) otherButtonTitles:NSLocalizedString(@"docType_ch",nil),NSLocalizedString(@"docType_en",nil), nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sheet showInView:self.view];
}

#pragma mark - DocListDelegate
- (void)tableViewReload{
    [self setnoValueBackImage];
}

- (void)setnoValueBackImage{
    switch (self.docSegmentd.selectedSegmentIndex) {
        case ListTypeRecord:
        {
            if ([self.recordListViewController.dataArr count]>0) {
                [self.view sendSubviewToBack:self.bgView];
            }else{
                self.bgImageView.image = [UIImage imageNamed:BackgroundRecord];
                [self.view bringSubviewToFront:self.bgView];
            }
        }
            break;
        case ListTypeCollection:
        {
            if ([self.colllectionListViewController.dataArr count]>0) {
                [self.view sendSubviewToBack:self.bgView];
            }else{
                self.bgImageView.image = [UIImage imageNamed:BackgroundFav];
                [self.view bringSubviewToFront:self.bgView];
            }
        }
            break;
        case ListTypeLocation:
        {
            if ([self.locationListViewController.dataArr count]>0) {
                [self.view sendSubviewToBack:self.bgView];
            }else{
                self.bgImageView.image = [UIImage imageNamed:BackgroundLocation];
                [self.view bringSubviewToFront:self.bgView];
            }
        }
            break;
            
        default:
            break;
    }

}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
  if (buttonIndex != 3) {
    [self setRightItemWithListType:self.listType DocType:buttonIndex];
    
    [self updateDocListInfo];
  }
}

- (void)setRightItemWithListType:(ListType)type DocType:(DocType)docType{
    switch (self.listType) {
        case ListTypeRecord:
            {
                self.docType_record = docType;
            }
            break;
        case ListTypeCollection:
            {
                self.docType_collection = docType;
            }
            break;
        case ListTypeLocation:
            {
                self.docType_location = docType;
            }
            
        default:
            break;
    }
    
    [self setRightItemWithDocType:docType];
}

- (void)setRightItemWithDocType:(DocType)docType{
    switch (docType) {
        case DocTypeAll:
                [self setRightBarButtonTitle:NSLocalizedString(@"docType_all", nil)];
            break;
        case DocTypeCH:
                [self setRightBarButtonTitle:NSLocalizedString(@"docType_ch", nil)];
            break;
        case DocTypeEN:
                [self setRightBarButtonTitle:NSLocalizedString(@"docType_en", nil)];
            break;
        default:
            break;
    }
}

- (void)setRightBarButtonTitle:(NSString *)title{
    if (self.navigationItem.rightBarButtonItem == nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(docTypeSelect:)];
    }else{
        [self.navigationItem.rightBarButtonItem setTitle:title];
    }
}

- (void)updateDocListInfo{
    switch (self.listType) {
        case ListTypeRecord:
            if (self.recordListViewController.docType != self.docType_record) {
                self.recordListViewController.docType = self.docType_record;
                [self.recordListViewController refresh];
            }
            break;
        case ListTypeCollection:
            if (self.colllectionListViewController.docType != self.docType_collection) {
                self.colllectionListViewController.docType = self.docType_collection;
                [self.colllectionListViewController refresh];
            }
            break;
        case ListTypeLocation:
            
            break;
        default:
            break;
    }
}
@end
