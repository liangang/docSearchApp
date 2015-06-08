//
//  MyDocumentPadViewController.m
//  imdSearch
//
//  Created by xiangzhang on 4/15/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "MyDocumentPadViewController.h"

#import "MyDocmentListPadViewController.h"

#import "EnumType.h"
#import "sortInfoSelectViewController.h"

@interface MyDocumentPadViewController()<MyDocumentListDelegate>

@property (assign, nonatomic) ListType listType;
/**
 *  不同lisType的docType，文献类型
 */
@property (assign, nonatomic) DocType docType_record;
@property (assign, nonatomic) DocType docType_collection;
@property (assign, nonatomic) DocType docType_location;
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;

/**
 *  选中文献类型的PopoverController
 */
@property (strong, nonatomic) UIPopoverController *sortPopoverController;

/**
 *  文献信息的显示controller，放到一个UIScrollView中
 */
@property (strong, nonatomic) MyDocmentListPadViewController *recordListViewController;
@property (strong, nonatomic) MyDocmentListPadViewController *colllectionListViewController;
@property (strong, nonatomic) MyDocmentListPadViewController *locationListViewController;

@end

@implementation MyDocumentPadViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [self addTableViewToContent];
    
    self.bgImageView.center = self.contentScrollView.center;
    
    /**
     *  iOS 6 是对segment的界面平面化处理
     */
    if (!(IOS7)) {
        self.docSegment.layer.borderColor = APPDefaultColor.CGColor;
        self.docSegment.layer.borderWidth = 1.0f;
        self.docSegment.layer.cornerRadius = 4.0f;
        self.docSegment.layer.masksToBounds = YES;
        CGRect rect = self.docSegment.frame;
        rect.size.height = 29;
        self.docSegment.frame = rect;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button delegate
- (IBAction)docTypeChange:(id)sender {
    sortInfoSelectViewController *viewController = [[sortInfoSelectViewController alloc] initWithNibName:@"sortInfoSelectViewController" bundle:nil];
    viewController.delegate = self;
    viewController.dataArray = [[NSMutableArray alloc] initWithArray:@[NSLocalizedString(@"docType_all",nil),NSLocalizedString(@"docType_ch",nil),NSLocalizedString(@"docType_en",nil)]];
    
    if (self.listType == ListTypeRecord) {
        viewController.selectedItem = self.docType_record;
    }else if (self.listType == ListTypeCollection){
        viewController.selectedItem = self.docType_collection;
    }
    
    self.sortPopoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.sortPopoverController.popoverContentSize = CGSizeMake(160., 150.);
	self.sortPopoverController.delegate = self;
    
    CGRect typeFrame = self.docTypeBtn.frame;
    CGRect frame = CGRectMake(typeFrame.origin.x , typeFrame.origin.y, typeFrame.size.width, typeFrame.size.height);
    
    [self.sortPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


#pragma mark - sortSelect delegate
-(void)selectSortWithPosition:(NSInteger)item{
    [self.sortPopoverController dismissPopoverAnimated:YES];
    
    if (self.listType ==  ListTypeRecord) {
        self.docType_record = item;
    }else if (self.listType == ListTypeCollection){
        self.docType_collection = item;
    }
    
    [self setRightItemWithDocType:item];
    
    [self updateDocListInfo];
}

/**
 *  segmentedControl的值变化引起的页面显示变化
 *
 */
- (IBAction)segmentValueChange:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    switch ([segment selectedSegmentIndex]) {
        case ListTypeRecord:
        {
            self.docTypeBtn.hidden = NO;
            self.listType = ListTypeRecord;
            [self setRightItemWithListType:self.listType DocType:self.docType_record];
            [self.contentScrollView setContentOffset:CGPointZero animated:NO];
          self.recordListViewController.currentDisplayingRow = -1;
          if ([self.recordListViewController.dataArr count] <=0) {
            [self.recordListViewController refresh];
          }

        }
            break;
            
        case ListTypeCollection:
        {
             self.docTypeBtn.hidden = NO;
            self.listType = ListTypeCollection;
            [self setRightItemWithListType:self.listType DocType:self.docType_collection];
            [self.contentScrollView setContentOffset:CGPointMake(self.contentScrollView.frame.size.width, 0) animated:NO];
          self.colllectionListViewController.currentDisplayingRow = -1;
          if ([self.colllectionListViewController.dataArr count] <=0) {
            [self.colllectionListViewController refresh];
          }
        }
            break;
        case ListTypeLocation:
        {
            self.docTypeBtn.hidden = YES;
            self.listType = ListTypeLocation;
          self.locationListViewController.currentDisplayingRow = -1;
            [self.contentScrollView setContentOffset:CGPointMake(self.contentScrollView.frame.size.width*2, 0) animated:NO];
          [self.locationListViewController showLocationListInfo];
        }
            break;
        default:
            break;
    }
    
}

- (void)reloadRecordInfo{
    self.recordListViewController.docType = self.docType_record;
    [self.recordListViewController refresh];
}

- (void)reloadCollectionInfo{
    
    self.colllectionListViewController.docType = self.docType_collection;
    [self.colllectionListViewController refresh];
}

- (void)reloadLocationInfo{
    [self.locationListViewController refresh];
}

/**
 *  设置文献显示类型的标题
 *
 *  @param type    显示类型：文献记录，我的收藏，本地文献
 *  @param docType  文献类型：全部文学，英文文献，中文文献
 */
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

/**
 *  根据docType设置title
 *
 *  @param docType 文献类型
 */
- (void)setRightItemWithDocType:(DocType)docType{
    NSString *title = nil;
    
    switch (docType) {
        case DocTypeAll:
                title = NSLocalizedString(@"docType_all", nil);
            break;
        case DocTypeCH:
                title = NSLocalizedString(@"docType_ch", nil);
            break;
        case DocTypeEN:
                title = NSLocalizedString(@"docType_en", nil);
            break;
        default:
            break;
    }
    
    [self.docTypeBtn setTitle:title forState:UIControlStateNormal];
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

#pragma mark - MyDocumentListDelegate 
//设置相应页面无数据时的背景
- (void)reloadtableView{
    switch (self.docSegment.selectedSegmentIndex) {
        case ListTypeRecord:
        {
//            if ([self.recordListViewController.dataArr count]>0) {
//                [self.view sendSubviewToBack:self.bgImageView];
//            }else{
//                self.bgImageView.image = [UIImage imageNamed:BackgroundRecord];
//                [self.view bringSubviewToFront:self.bgImageView];
//            }
        }
            break;
        case ListTypeCollection:
        {
//            if ([self.colllectionListViewController.dataArr count]>0) {
//                [self.view sendSubviewToBack:self.bgImageView];
//            }else{
//                self.bgImageView.image = [UIImage imageNamed:BackgroundFav];
//                [self.view bringSubviewToFront:self.bgImageView];
//            }
        }
            break;
        case ListTypeLocation:
        {
//            if ([self.locationListViewController.dataArr count]>0) {
//                [self.view sendSubviewToBack:self.bgImageView];
//            }else{
//                self.bgImageView.image = [UIImage imageNamed:BackgroundLocation];
//                [self.view bringSubviewToFront:self.bgImageView];
//            }
        }
            break;
            
        default:
            break;
    }
    

}

#pragma mark -
/**
 *  增加ViewControl到页面上
 */
- (void)addTableViewToContent{
    CGRect rect = self.contentScrollView.frame;
    self.contentScrollView.scrollEnabled = NO;
    [self.contentScrollView setContentSize:CGSizeMake(rect.size.width * 3, rect.size.height)];
    
    CGRect rect1 = CGRectMake(0, 0, rect.size.width, rect.size.height);
  if (self.recordListViewController == nil) {
    self.recordListViewController = [[MyDocmentListPadViewController alloc] init];
  }
    self.recordListViewController.listType = ListTypeRecord;
    self.recordListViewController.mainDelegate = self.delegate;
    [self.recordListViewController.view setFrame:rect1];
    [self.contentScrollView addSubview:self.recordListViewController.view];
  
  if (self.colllectionListViewController == nil) {
    self.colllectionListViewController = [[MyDocmentListPadViewController alloc] init];
  }
    self.colllectionListViewController.listType = ListTypeCollection;
    self.colllectionListViewController.mainDelegate = self.delegate;
    rect1.origin.x += rect1.size.width;
    [self.colllectionListViewController.view setFrame:rect1];
    [self.contentScrollView addSubview:self.colllectionListViewController.view];
  
  if (self.locationListViewController == nil) {
    self.locationListViewController = [[MyDocmentListPadViewController alloc] init];
  }
    self.locationListViewController.listType = ListTypeLocation;
    self.locationListViewController.mainDelegate = self.delegate;
    rect1.origin.x += rect1.size.width;
    [self.locationListViewController.view setFrame:rect1];
    [self.contentScrollView addSubview:self.locationListViewController.view];
}
- (void)clearMyDocumentAllInfo
{
  [self.colllectionListViewController.dataArr removeAllObjects];
  [self.colllectionListViewController.tableView reloadData];
  [self.recordListViewController.dataArr removeAllObjects];
  [self.recordListViewController.tableView reloadData];
  [self.locationListViewController.dataArr removeAllObjects];
  [self.locationListViewController.tableView reloadData];
}
@end
