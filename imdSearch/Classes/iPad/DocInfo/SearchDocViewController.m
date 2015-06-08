//
//  SearchDocViewController.m
//  imdSearch
//
//  Created by xiangzhang on 4/16/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "SearchDocViewController.h"

#import "Url_iPad.h"
#import "PadText.h"

#import "Util.h"
#import "mySearchBar.h"
#import "imdSearcher.h"

#import "advancedQueryItemsCell.h"
#import "advancedYearItemsCell.h"
#import "sortSelectViewController.h"

#import "MultipartLabel.h"
#import "myDatabaseOption.h"
#import "searchHistory.h"
#import "DocListPadCell.h"
#import "NetStatusChecker.h"
#import "searchMainUtils.h"

#import "ASIHTTPRequest.h"
#import "ImdAppBehavior.h"
#import "JSON.h"
#import "TKAlertCenter.h"
#import "MBProgressHUD.h"

#define ResultIsRead  @"resulteIsRead"

typedef NS_ENUM(NSInteger, DisplayState){
    DisplayStateUnknown = -1,
    DisplayStateHistory,
    DisplayStateSearching,
    DisplayStateResults,
    DisplayStateAdvsearch,
    DisplayStateSuggestion
};

typedef NS_ENUM(NSInteger, DocSortWay){
    DocSortWayDefault = 0,
    DocSortWayTime,
    DocSortWayJourn
};

#define SuggestRequestTag 2014052101
#define resulteRequestTag 2014052102

#define PageSize 20

@interface SearchDocViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIPopoverControllerDelegate,ASIHTTPRequestDelegate>{
    BOOL loadMore;
    BOOL isNewStart;
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *searchArr;
@property (nonatomic, strong) NSMutableArray *historyArr;
@property (nonatomic, strong) NSMutableArray *suggestionArr;

@property (nonatomic, assign) SearchType searchType;
@property (nonatomic, assign) SearchMode searchMode;
@property (nonatomic, assign) DisplayState displayState;
@property (nonatomic, assign) DocSortWay docSortWay;

@property (nonatomic,strong) UIButton* resultLeftButton;
@property (nonatomic,strong) UIButton* resultRightButton;
@property (nonatomic,strong) UIPopoverController *sortPopoverController;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@property (assign, nonatomic) int loadedRow;
@property (assign, nonatomic) int currentPage;
@property (assign, nonatomic) int totalPage;
@property (assign, nonatomic) int resultsSum;

@property (nonatomic,strong) NSDictionary *searchedResult;
@property (nonatomic,strong) NSMutableArray *resultReadingStatus;

@property (nonatomic, strong) ASIHTTPRequest *suggestRequest;
@property (nonatomic, strong) ASIHTTPRequest *resulteRequest;

@end

@implementation SearchDocViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.searchType = SearchTypeNormal;
        self.searchMode = SearchModeCN;
        self.searchTypeSegmentView.selectedSegmentIndex = self.searchMode;
        self.docSortWay = DocSortWayDefault;
        self.resultsSum = 0;
//        self.currentPage = 1;
        self.dataArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.searchArr = [[NSMutableArray alloc] initWithCapacity:0];
        self.historyArr = [[NSMutableArray alloc] initWithCapacity:0];
        self.suggestionArr = [[NSMutableArray alloc] initWithCapacity:0];
        loadMore = FALSE;
        isNewStart = YES;
        self.advViewOn = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //title view
    [self cornerRadiusWithView:self.titleContentView];
    [self cornerRadiusWithView:self.searchBarContentView];
    [self cornerRadiusWithView:self.listContentView];
    
    self.searchTypeSegmentView.selectedSegmentIndex = SearchModeCN;
    
    if (!(IOS7)) {
        self.searchTypeSegmentView.layer.borderColor = APPDefaultColor.CGColor;
        self.searchTypeSegmentView.layer.borderWidth = 1.0f;
        self.searchTypeSegmentView.layer.cornerRadius = 4.0f;
        self.searchTypeSegmentView.layer.masksToBounds = YES;
    }
    
    [self searchBarViewInit];
    [self searchHistoryInfoShow];
  
    //监听keyboard
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //[self seachTypeValueChange:self.searchTypeSegmentView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarViewInit{
    //清除UISearchbar的背景色
    NSArray *subViews = IOS7 ? ((UIView *)self.searchBar.subviews[0]).subviews : self.searchBar.subviews;
    for (UIView *subView in subViews) {
        if ([subView isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] ){
            //subview是背景图
            [subView removeFromSuperview];
        }
    }
//    iOS7 方法2
//    if ([self.searchBar respondsToSelector:@selector(barTintColor)]) {
//        [self.searchBar setBarTintColor:[UIColor clearColor]];
//    }
}

#pragma mark - UIButton Click
- (IBAction)heightBackBtnClick:(id)sender {
    if (self.searchType == SearchTypeNormal) {
        if (self.displayState == DisplayStateResults) {
            self.heightBackBtn.hidden = YES;
            [self searchHistoryInfoShow];
        }
    }else{
        if (self.advViewOn) {
            [self.view bringSubviewToFront:self.advSearchViewController.view];
            self.advViewOn = NO;
        }else{
            [self advanceViewHide];
            [self searchHistoryInfoShow];
        }
    }
}

- (IBAction)favouriteSaveBtnClick:(id)sender {
}

- (IBAction)advanceViewShow:(id)sender {
    [self.view endEditing:YES];
    self.searchType = SearchTypeAdvance;
    self.advanceBtn.hidden = YES;
    
    if(self.advSearchViewController == nil){
        self.advSearchViewController = [[AdvSearchViewController alloc] init];
        self.advSearchViewController.delegate = self;
    }
    self.advSearchViewController.view.frame = CGRectMake(-348, 40, 348, 748);
    [self.view addSubview:self.advSearchViewController.view];
    
    [UIView animateWithDuration:0.5f animations:^(void){
        self.advSearchViewController.view.frame = CGRectMake(0, 40, 348, 748);
    } completion:^(BOOL finished){
        self.titleInfoLabel.text = @"高级检索";
        self.heightBackBtn.hidden = NO;
        self.favouriteSaveBtn.hidden = YES;
    }];
}

- (void)advanceViewHide{
    [UIView animateWithDuration:0.5f animations:^(void){
        self.advSearchViewController.view.frame = CGRectMake(-348, 40, 348, 748);
    } completion:^(BOOL finished){
        [self.advSearchViewController.view removeFromSuperview];
        self.advanceBtn.hidden = NO;
        self.searchType = SearchTypeNormal;
        self.titleInfoLabel.text = @"文献检索";
        self.heightBackBtn.hidden = YES;
        self.favouriteSaveBtn.hidden = YES;
    }];
}

#pragma mark - adv delegate method

-(void)selectedOperation:(id)sender {
    advancedQueryItemsCell* cell = (advancedQueryItemsCell*)sender;
    
    if(cell.selectedOperation == OPERATION_AND)
        [self.filterOperations replaceObjectAtIndex:cell.tag withObject:[NSNumber numberWithInt:OPERATION_AND]];
    else if(cell.selectedOperation == OPERATION_OR)
        [self.filterOperations replaceObjectAtIndex:cell.tag withObject:[NSNumber numberWithInt:OPERATION_OR]];
    else
        [self.filterOperations replaceObjectAtIndex:cell.tag withObject:[NSNumber numberWithInt:OPERATION_NOT]];
    
}

#pragma mark - advance delegate change
-(void)SendAdvValue:(ASIHTTPRequest *)request
{
    self.advViewOn = YES;
    [self.view sendSubviewToBack:self.advSearchViewController.view];
    
    [self advanceRequestFinish:request];
}

-(void)advSearchHandleAllSwipes:(UISwipeGestureRecognizer *)recognizer
{
    if(self.advViewAnimating) return;
	
    if (recognizer.direction & UISwipeGestureRecognizerDirectionRight)
    {
        [self advanceViewShow:nil];
    }
    
    if (recognizer.direction & UISwipeGestureRecognizerDirectionLeft)
    {
        [self advanceViewHide];
    }
}


//检索类型变化
- (IBAction)seachTypeValueChange:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
   
    NSString* lan;
    if (control.selectedSegmentIndex == SEARCH_MODE_CN){
        lan = @"CN";
    }else{
        lan = @"EN";
    }
    [self changeLanguageTo:lan];
    
}

- (void) searchStatusUpdate{
    
    
}

-(void)changeLanguageTo:(NSString*)lanStr {
    int preMode = self.searchMode;
    
    if([lanStr isEqualToString:@"CN"]) {
        self.searchMode = SearchModeCN;
        self.searchBar.placeholder = @"请输入检索关键词";
    } else {
        self.searchMode = SearchModeEN;
        self.searchBar.placeholder = @"请输入检索关键词";
    }
    
    
    self.filterNames = [[NSMutableArray alloc] initWithCapacity:self.advancedQueryItemCountMax];
    self.filterValues = [[NSMutableArray alloc] initWithCapacity:self.advancedQueryItemCountMax];
    self.filterOperations = [[NSMutableArray alloc] initWithCapacity:self.advancedQueryItemCountMax];
    
    self.filterItemData = [searchMainUtils readPListBundleFile:@"searchFilters"];
    
    for(int i =0; i< self.advancedQueryItemCountMax ;i++)
    {
        if(self.searchMode  == SearchModeCN)
        {
            NSArray* TextCN = [self.filterItemData objectForKey:@"CN_TEXT"];
            [self.filterNames addObject:[TextCN objectAtIndex:0]];
        } else {
            NSArray* TextEN = [self.filterItemData objectForKey:@"EN_TEXT"];
            [self.filterNames addObject:[TextEN objectAtIndex:0]];
        }
        
        [self.filterValues addObject:@""];
        [self.filterOperations addObject:[NSNumber numberWithInt:OPERATION_AND]];
    }
    
    //save mode
    [[NSUserDefaults standardUserDefaults] setInteger:self.searchMode forKey:@"searchLan"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    if(self.displayState == DisplayStateResults &&  preMode != self.displayState) {
        NSLog(@"change and search");
        
        if(![NetStatusChecker isNetworkAvailbe]) {
            return;
        }
        
        isNewStart = YES;
        
        self.currentPage = 1;
        
        if(self.searchType == SearchTypeAdvance)
        {
            [self.advSearchViewController advSearch:nil status:@"changeLanguageTo" sort:nil];
            
        } else {
            
            [self requestNormalSearch:self.searchBar.text Page:self.currentPage Lan:self.searchMode Delegate:self sort:self.docSortWay];
        }
    }
}

- (IBAction)sortPressed:(id)sender{
    sortSelectViewController *content = [[sortSelectViewController alloc] initWithNibName:@"sortSelectViewController" bundle:nil];
    
    self.sortPopoverController = [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate = self;
    content.selectedItem = self.docSortWay;
    
    //content.tag =[sender tag];
    
	self.sortPopoverController.popoverContentSize = CGSizeMake(160., 150.);
	self.sortPopoverController.delegate = self;
    
    UIButton* t =(UIButton*)sender;
    
    
    CGRect frame=CGRectMake(t.frame.origin.x + 2, t.frame.origin.y+130, t.frame.size.width, t.frame.size.height);
    
	[self.sortPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - change sort sortSelectViewController delegate
-(void)changeSort:(id)sender {
    isNewStart = YES;
    [self.sortPopoverController dismissPopoverAnimated:YES];
    
    sortSelectViewController* s =(sortSelectViewController*)sender;
    NSLog(@"sort change %d",s.selectedItem);
    
    if(s.selectedItem ==0) {
        [self.resultLeftButton setTitle:@"相关排序" forState:UIControlStateNormal];
    } else if(s.selectedItem ==1) {
        [self.resultLeftButton setTitle:@"时间排序" forState:UIControlStateNormal];
        
    } else {
        [self.resultLeftButton setTitle:@"期刊排序" forState:UIControlStateNormal];
        
    }
    
    self.docSortWay = s.selectedItem;
    NSString *sortMethod =[self fetchSortMethod:self.docSortWay];
    
    
    if(![NetStatusChecker isNetworkAvailbe]) {
        return;
    }
    
    //fetchingPage = currentPage;
    if (self.advSearchViewController.newSearchStart) {
        self.searchType = 1;
    }
    
    //self.currentPage =1;
    
    if(self.searchType == SEARCHING_TYPE_ADVANCED)
    {
        [self.advSearchViewController advSearch:nil status:@"changeSort" sort:sortMethod];
    } else {
        [self requestNormalSearch:self.searchBar.text Page:self.currentPage Lan:self.searchMode Delegate:self sort:[sortMethod intValue]];
    }
}

-(NSString*)fetchSortMethod:(int)way {
    if(way ==0) return @"5";
    if(way ==1) return @"1";
    if(way ==2) return @"3";
    
    return nil;
}

#pragma mark - utils 
- (void)cornerRadiusWithView:(UIView *)view{
    view.layer.cornerRadius = 2;
    view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowRadius = 1.0;
    view.layer.shadowOffset = CGSizeMake(0, 1);
}

- (void)searchHistoryInfoShow{
  self.docSortWay = DocSortWayDefault;
    self.displayState = DisplayStateHistory;
    
    self.historyArr = [searchHistory getSavedSearchHistory];
    self.dataArray = self.historyArr;
    [self.searchSuggestTableView reloadData];
}

#pragma mark - SearchBar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    if (self.searchType == SearchTypeAdvance) {
        self.advViewOn = FALSE;     //是否是高级检索，是的话显示，不是的话显示普通检索
        [self heightBackBtnClick:nil];
    }
    self.displayState = DisplayStateSuggestion;
    [self.dataArray removeAllObjects];
    [self.searchSuggestTableView reloadData];
    
    self.heightBackBtn.hidden = YES;
    
    if (![NetStatusChecker isNetworkAvailbe]) {
        return;
    }
    
    if (![searchBar.text isEqualToString:@""] && searchBar.text) {
        [self requestSuggestionKey:searchBar.text lan:self.searchMode delegate:self];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""]) {
      [self searchHistoryInfoShow];
      [self.delegate removeDocDetailInfo];
        return;
    }
    
    if (![NetStatusChecker isNetworkAvailbe]) {
        return;
    }
    
    self.displayState = DisplayStateSuggestion;
    [self requestSuggestionKey:searchText lan:self.searchMode delegate:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    
    [self SearchDocByKey:searchBar.text];
    
    self.heightBackBtn.hidden = NO;
}

- (void)SearchDocByKey:(NSString *)searchKey{
    if (![NetStatusChecker isNetworkAvailbe]) {
        return;
    }
    
    isNewStart = YES;
    self.currentPage = 1;
    
    if (self.displayState == DisplayStateSuggestion || self.displayState == DisplayStateHistory || self.displayState == DisplayStateResults) {
        NSString *language = nil;
        
        if (self.searchMode == SearchModeCN) {
            language = @"CN";
        }else{
            language = @"EN";
        }
        
        [searchHistory saveSearchHistory:searchKey Language:language];
        self.searchType = SearchTypeNormal;
        
        [self requestNormalSearch:searchKey Page:self.currentPage Lan:self.searchMode Delegate:self sort:self.docSortWay];
    }
}
- (void)keyboardDidHidden:(NSNotification *)notification
{
  if (!self.advViewOn) {
    if (self.displayState == DisplayStateSuggestion) {
      [self searchHistoryInfoShow];
    }
    
  }
}
#pragma mark - UItableView Delegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row == [self.dataArray count] - 1) && self.displayState == DisplayStateResults) {
        if (self.currentPage + 1 <= self.totalPage) {
            [self performSelector:@selector(loadingNextBlock:) withObject:nil afterDelay:1.0f];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger number = 0;
    NSInteger sum = [self.dataArray count];
    switch (self.displayState) {
        case DisplayStateSuggestion:
            {
                number = sum;
            }
            break;
        case DisplayStateHistory:
            {
                number = sum + 1;
            }
            break;
        case DisplayStateResults:
            {
                if (sum%PageSize == 0 && sum != 0) {
                    
                    number = sum + 1;
                }else{
                    number = sum;
                }
            }
            break;
        default:
            break;
    }
    
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.displayState == DisplayStateResults) {
        return 40;
    }
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    switch (self.displayState) {
        case DisplayStateHistory:
            {
                UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 30)];
                header.backgroundColor = RGBCOLOR(249, 249, 249);
                
                UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 338, 30)];
                title.textColor = APPDefaultColor;
                title.backgroundColor = [UIColor clearColor];
                
                if(section == 0)
                {
                    title.text = @"检索历史";
                } else if(section ==1) {
                     title.text = @"保存的检索";
                } else {
                    title.text = @"热点检索";
                }
                 [header addSubview:title];
                
                return header;
            }
            break;
        case DisplayStateSuggestion:
        {
            UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 30)];
            header.backgroundColor = RGBCOLOR(249, 249, 249);
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 338, 30)];
            title.textColor = APPDefaultColor;
            title.backgroundColor = [UIColor clearColor];
            title.text = @"检索词推荐";
            
            [header addSubview:title];
            
            return header;
        }
            break;
            case DisplayStateResults:
            {
                UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 40)];
                header.backgroundColor = NavigationColor;
                
                UIButton *btLeft = [UIButton buttonWithType:UIButtonTypeCustom];
                btLeft.frame = CGRectMake(8, 6, 69, 29);
                
                [btLeft setTitleColor:APPDefaultColor forState:UIControlStateNormal];
                
                btLeft.titleLabel.font = [UIFont systemFontOfSize:15.0f];
                
                if(self.docSortWay == DocSortWayDefault)
                {
                    [btLeft setTitle:@"相关排序" forState:UIControlStateNormal];
                } else if(self.docSortWay == DocSortWayTime) {
                    [btLeft setTitle:@"时间排序" forState:UIControlStateNormal];
                } else {
                    [btLeft setTitle:@"期刊排序" forState:UIControlStateNormal];
                }
                
                [btLeft addTarget:self action:@selector(sortPressed:) forControlEvents:UIControlEventTouchDown];
                
                self.resultLeftButton = nil;
                self.resultLeftButton = btLeft;
                
                [header addSubview:btLeft];
                
                UILabel* labelCounts = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,348, 40)];
                labelCounts.textAlignment = NSTextAlignmentRight;
                labelCounts.font = [UIFont systemFontOfSize:15];
                
                NSString *countStr = [NSString stringWithFormat:SEARCH_RESULT_COUNT,self.resultsSum];
                NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:countStr];
                NSRange range1 = [countStr rangeOfString:@"中"];
                NSRange range2 = [countStr rangeOfString:@"篇"];
                NSInteger location = range1.location + range1.length;
                NSInteger length = range2.location - location;
                [attStr addAttribute:NSForegroundColorAttributeName value:APPDefaultColor range:NSMakeRange(location, length)];
                
                labelCounts.attributedText = attStr;
                
                labelCounts.backgroundColor = [UIColor clearColor];
                [header addSubview:labelCounts];
                
                return header;
            }
            
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    switch (self.displayState) {
        case DisplayStateResults:
            height = 140;
            break;
        case DisplayStateSuggestion:
            height = 46;
            break;
        default:
            height = 50;
            break;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (self.displayState) {
        case DisplayStateSuggestion:
            {
                static NSString *CellIdentifier = @"suggestionCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                cell.textLabel.textColor = [UIColor lightGrayColor];
                NSString *suggestStr = [self.dataArray objectAtIndex:indexPath.row];
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:suggestStr];
                
                if ([suggestStr rangeOfString:self.searchBar.text].location == NSNotFound) {
                    cell.textLabel.attributedText = str;
                }else{
                    NSRange range = [suggestStr rangeOfString:self.searchBar.text];
                    
                    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(range.location, self.searchBar.text.length)];
                    
                    cell.textLabel.attributedText = str;
                }
                
                return cell;
            }
            break;
        case DisplayStateHistory:
            {
                static NSString *CellIdentifier = @"hsitoryCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }

                if ([self.dataArray count] == 0) {
                    cell.textLabel.text =  @"无检索历史";
                    cell.textLabel.textColor = RGBCOLOR(127, 127, 127);
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }else if([self.dataArray count] == indexPath.row){
                    cell.textLabel.textColor = RGBCOLOR(100, 100, 100);
                    cell.textLabel.font = [UIFont fontWithName:@"Palatino" size:17.0];
                    cell.textLabel.text =@"清除检索历史...";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                }else{
                    NSString *word = [self.dataArray objectAtIndex:indexPath.row];
                  if ([[word substringToIndex:2] isEqualToString:@"EN"]) {
                    cell.textLabel.text =[NSString stringWithFormat:@"英文:%@",[word substringFromIndex:2]];
                  }else
                  {
                  cell.textLabel.text =[NSString stringWithFormat:@"中文:%@",[word substringFromIndex:2]];
                  }
                    cell.textLabel.textColor = RGBCOLOR(50, 50, 50);
                    cell.textLabel.font = [UIFont fontWithName:@"Palatino" size:17.0];
                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
                    [cell.textLabel sizeToFit];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                return cell;
            }
            break;
            case DisplayStateResults:
            {
                if ([self.dataArray count] == 0) {
                    static NSString *CellIdentifier = @"cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    }
                    UIImageView* noResultImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img-no-search-results"]];
                    [cell addSubview:noResultImageView];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return cell;
                }else if(indexPath.row == [self.dataArray count]){
                    static NSString *CellIdentifier = @"cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    }
                    
                    UILabel* loading = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 200, 40)];
                    loading.text = @"正在读取...";
                    loading.backgroundColor = [UIColor clearColor];
                    [cell addSubview:loading];
                    
                    UIActivityIndicatorView* loadingSign = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [loadingSign startAnimating];
                    
                    loadingSign.center = CGPointMake(20, 40);
                    loadingSign.hidesWhenStopped = NO;
                    
                    [cell addSubview:loadingSign];

                    return cell;
                }else{
                    static NSString *CellIdentifier = @"resulteCell";
                    DocListPadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (cell == nil) {
                        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"DocListPadCell" owner:self options:nil] ;
                        for (id object in nibs) {
                            if ([object isKindOfClass:[DocListPadCell class]]) {
                                cell = [(DocListPadCell *) object initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                            }
                        }
                    }
                    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
                    [cell setCellInfoWithLocationInfo:dic];
                    
                    if (!(IOS7)) {  //ios 6的默认选中样式是蓝色的，需要自定义
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    return cell;
                }
            }
            break;
        default:
            {
                static NSString *CellIdentifier = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                cell.textLabel.text = [NSString stringWithFormat:@"item %d", indexPath.row +1];
                
                [cell.textLabel setTextColor:[UIColor darkGrayColor]];
                [cell.textLabel setHighlightedTextColor:[UIColor blackColor]];
                return cell;
            }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataArray count] <= 0) {
        return;
    }
    switch (self.displayState) {
        case DisplayStateSuggestion:
            {
                [self.view endEditing:YES];
                NSString *suggest = [self.dataArray objectAtIndex:indexPath.row];
                self.searchBar.text = suggest;
                
                [self SearchDocByKey:suggest];
                self.heightBackBtn.hidden = NO;
            }
            break;
        case DisplayStateHistory:
            {
              if (self.dataArray.count == indexPath.row) {
                [searchHistory clearHistory];
                [self.dataArray removeAllObjects];
                [self.searchSuggestTableView reloadData];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1.0];
                [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.searchSuggestTableView cache:NO];
                
                [UIView commitAnimations];
              }else
              {
                NSString *suggest = [[self.dataArray objectAtIndex:indexPath.row] substringFromIndex:2];
                NSString *ENorCN = [[self.dataArray objectAtIndex:indexPath.row] substringToIndex:2];
                self.searchBar.text = suggest;
                if ([ENorCN isEqualToString:@"EN"]) {
                  self.searchMode = SearchModeEN;
                  self.searchTypeSegmentView.selectedSegmentIndex = 1;
                }else
                {
                  self.searchTypeSegmentView.selectedSegmentIndex = 0;
                  self.searchMode = SearchModeCN;
                }
                [self SearchDocByKey:suggest];
                self.heightBackBtn.hidden = NO;
              }
            }
            break;
        case DisplayStateResults:
            {
                NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
                [dic setValue:[NSNumber numberWithBool:YES] forKey:ResultIsRead];
                [tableView reloadData];
                if (self.delegate && [self.delegate respondsToSelector:@selector(showDocDetailInfo:)]) {
                    [self.delegate showDocDetailInfo:dic];
                }
                [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        default:
            break;
    }
}

#pragma mark - search list request
-(void)loadingNextBlock:(id)sender
{
    if(![NetStatusChecker isNetworkAvailbe]) {
       [[TKAlertCenter defaultCenter] postAlertWithMessage:@"无法连接到互联网，请查看设置"];
        loadMore =NO;
        return;
    }
    
    isNewStart = NO;
    int fetchPage  = self.currentPage + 1;
    if(self.searchType == SearchTypeAdvance) {
        if (fetchPage > 1) {
            self.advSearchViewController.newSearchStart = NO;
            self.advSearchViewController.currentPage = fetchPage-1;
        }
        [self.advSearchViewController advSearch:nil status:@"loadingNextBlock" sort:nil];
    } else {
        [self requestNormalSearch:self.searchBar.text Page:fetchPage Lan:self.searchMode Delegate:self sort:self.docSortWay];
    }
}

#pragma  mark - ASIHTTPRequest 
- (void)requestSuggestionKey:(NSString *)key lan:(int)mode delegate:(id)delegate{
   
    if (self.suggestRequest != nil) {
      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.suggestRequest clearDelegatesAndCancel];
    }
    
     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.suggestRequest = [imdSearcher fetchSuggestion:key lan:mode Delegate:self];
    self.suggestRequest.tag = SuggestRequestTag;
    self.displayState = DisplayStateSuggestion;
}

-(void)requestNormalSearch:(NSString *)searchKey Page:(int)pNo Lan:(int)lanMode Delegate:(id)delegate sort:(int)sort{
    if (self.resulteRequest != nil) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.resulteRequest clearDelegatesAndCancel];
    }
    
    if (isNewStart) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    [ImdAppBehavior searchJsonLog:[Util getUsername] MACAddr:[Util getMacAddress] SearchJson:[NSString stringWithFormat:@"{\"type\":\"simple search\",\"search words\":\"%@\",\"page\":%i,\"lan\":%i,\"sort\":%i}", searchKey, pNo, lanMode, sort]];
    self.resulteRequest = [imdSearcher simpleSearch:searchKey Page:pNo Lan:lanMode Delegate:delegate sort:sort];
    
    self.resulteRequest.tag = resulteRequestTag;
}

#pragma mark - AISHTTPRequest delegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSLog(@"requestFinished is %@",request.responseString);
    
    if (request.tag == SuggestRequestTag) {
        self.displayState = DisplayStateSuggestion;
        
        NSString *valueStr=[request responseString];
        
        BOOL hasError = NO;
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
        
        NSMutableArray* info;
        if (valueStr ==(id)[NSNull null] || valueStr.length ==0 )
        {
            info =nil;
            hasError = YES;
        } else {
            info =[valueStr JSONValue];
        }
        
        if(hasError)
        {
            NSLog(@"sth wrong with json");
        } else if(info != nil) {
            self.suggestionArr = info;
            self.dataArray = self.suggestionArr;
            [self.searchSuggestTableView reloadData];
        }
    }else if (request.tag == resulteRequestTag){
        self.displayState = DisplayStateResults;
        NSData * responseData = [request rawResponseData];
        NSString* responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *info = [responseString JSONValue];
        
        if (info) {
            NSArray *results = [info objectForKey:@"results"];
            
            for (NSMutableDictionary *dic in results) {
                [dic setValue:[NSNumber numberWithBool:NO] forKey:ResultIsRead];
            }
            
            if (isNewStart) {
                if (self.searchArr) {
                    self.searchArr = nil;
                }
                
                self.searchArr = [[NSMutableArray alloc] initWithArray:results];
            }else{
                [self.searchArr addObjectsFromArray:results];
                
                self.currentPage++;
            }
        }
        self.resultsSum = [[info objectForKey:@"resultCount"] intValue];
        
        self.dataArray = self.searchArr;
        
        [self calculatePages];
        [self.searchSuggestTableView reloadData];
        
        if (isNewStart) {
            if ([self.dataArray count] >= 1) {
                NSDictionary *dic = [self.dataArray objectAtIndex:0];
                [dic setValue:[NSNumber numberWithBool:YES] forKey:ResultIsRead];
                [self.searchSuggestTableView reloadData];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(showDocDetailInfo:)]) {
                    [self.delegate showDocDetailInfo:dic];
                }
                
                [self.searchSuggestTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)advanceRequestFinish:(ASIHTTPRequest *)request{
    NSData * responseData =[request rawResponseData];
    NSString* responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    BOOL hasError = NO;
    NSDictionary* info;
    
    if (responseString ==(id)[NSNull null] || responseString.length ==0 ) {
        // 没有返回数据
        info =nil;
        hasError = YES;
    } else {
        // json解析
        info =[responseString JSONValue];
    }
    
    if (info) {
        self.displayState = DisplayStateResults;
        if (self.advSearchViewController.newSearchStart) {
            self.searchArr = [info objectForKey:@"results"];
            self.currentPage = 1;
        }else{
            NSArray *results =[info objectForKey:@"results"];
            [self.searchArr addObjectsFromArray:results];
            self.currentPage++;
        }
        
        self.resultsSum = [[info objectForKey:@"resultCount"] intValue];
        self.dataArray = self.searchArr;
        [self calculatePages];
        [self.searchSuggestTableView reloadData];
    }
}

- (void)calculatePages
{
    if(self.resultsSum % PageSize == 0)
    {
        self.totalPage = self.resultsSum/PageSize;
    } else {
       self.totalPage = self.resultsSum/PageSize + 1;
    }
}
@end
