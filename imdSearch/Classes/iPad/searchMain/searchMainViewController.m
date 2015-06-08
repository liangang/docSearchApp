

//
//  searchMainViewController.m
//  imdSearch
//
//  Created by 8fox on 9/27/11.
//  Copyright 2011 i-md.com. All rights reserved.
//

#import "searchMainViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "imdSearcher.h"
#import "JSON.h"
#import "Util.h"
#import "advancedQueryItemsCell.h"
#import "advancedYearItemsCell.h"
#import "filterTableController.h"
#import "yearTableController.h"
#import "Strings.h"
#import "settingViewController.h"

#import "lanSelectViewController.h"
#import "searchHistory.h"

#import "catalogSelectViewController.h"
#import "sortSelectViewController.h"
#import "shareSelectViewController.h"

#import "imdSearchAppDelegate.h"

#import "MultipartLabel.h"
#import "fullViewController.h"
#import "TKAlertCenter.h"
#import "searchWebViewController.h"
#import "askFullTextViewController.h"

#import "NetStatusChecker.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "accountActivationViewController.h"
#import "Url_iPad.h"
#import "url.h"
#import "UrlRequest.h"
#import "SaveKey.h"
#import "ConfirmMainViewController.h"

#import "NMCustomLabel.h"
#import "PadText.h"

#import "ImdUrlPath.h"
#import "UrlRequest.h"

#import "ImdAppBehavior.h"

#import "myDatabaseOption.h"
#import "ShowDailog.h"
#import "newVerifiedViewController.h"
#import "RegisterSuccessViewController.h"
#import "InviteRegisterPadViewController.h"

#import "UINavigationController+DismissKeyboard.h"

#import "GuideIndexiPadViewController.h"

#define DETAIL_JOURNAL_DEFAULT_SIZE 16.0f
#define DEFAULT_LINE_SPACE 8.0f
#define DETAIL_AFFILIATIONS_DEFAULT_SIZE 16.0f
#define DETAIL_AUTHORS_DEFAULT_SIZE 16.0f

#define HTTP_REQUEST_DO_SEARCH @"search"
#define HTTP_REQUEST_SIMPLE_SUGGESTION @"suggestion"
#define HTTP_REQUEST_ADD_FAVORITE @"addFav"
#define HTTP_REQUEST_ASK_FOR_DOC @"askFullText"
#define HTTP_REQUEST_SEARCH_DETAIL @"searchDetail"
#define HTTP_REQUEST_DOWNLOAD_DOC @"requestPDF"
#define HTTP_REQUEST_GET_USER_STATUS @"userActiver"
#define HTTP_REQUEST_REMOVE_FAVORITE_DOC @"removeFav"
#define HTTP_REQUEST_FAVORITE_DETAIL @"askFavDetail"
#define HTTP_REQUEST_FAVORITE_EDIT_DETAIL @"favEditDetail"
#define HTTP_REQUEST_FAVORITE_LIST @"listFav"
#define HTTP_REQUEST_ASK_FOR_SYNC_LIST @"askforSyncList"
#define HTTP_REQUEST_ASKING_SYNC_LIST @"askingSyncList"
#define HTTP_REQUEST_LOCATION_DETAIL @"locationDetail"
#define HTTP_REQUEST_LOCATION_EDIT_DETAIL @"locationEditDetail"
#define HTTP_REQUEST_LOCATION_IS_FAV @"locationIsFav"
#define HTTP_REQUEST_JUMP_ASK_CHECK_STATUES @"jumpAskCheckStatus"

#define LOCATION_TAB_BAR_HAS_SAVED 0
#define LOCATION_TAB_BAR_ASKING 1
#define LOCATION_TAB_BAR_ASK_SUCCESS 2
#define UPPERLIMITALERTVIEWTAG 2014011302

@class ASIFormDataRequest;

@implementation searchMainViewController

@synthesize sideActionsView,listSearchView,listFavView,listDownloadView,resultAreaView,detailView;
@synthesize advButton,searchResultList,searchedResult,resultReadingStatus;

@synthesize titleLeftView,titleLeftFavView,titleLeftDownView,titleActionsView,searchbarView,searchListView,searchResultView,searchResultCoverView, bigCoverView;
@synthesize detailTitle,detailaffiliations,detailJournalAndDate,detailAuthors,detailAbstractText,detailKeyword,detailAbstractString,detailKeywordString,
AbstractTextScrollView;

@synthesize loadingIndicator,loadingLabel,errorLabel,loadingView;
@synthesize favList,downList,requestList,langSelButton;
@synthesize sideActionSearchButton,sideActionFavoriteButton,sideActionDownloadedButton,sideActionSettingsButton,sideActionHelpButton;
@synthesize backButton,favoriteSaveButton,searchTitle;
@synthesize currentKeybordHolder;
@synthesize selectedDotFav,selectedDotSearch,selectedDotDownload;
@synthesize mainLoginViewController,downloadArrays,requestArrays,requestDownArrays,fullTextDownloader,switchButton,pdfView,prePdfView,nextPdfView,pageNo,startCover,pdfBackView;
@synthesize favArrays,favDetail,favEditButton,resultLeftButton,resultRightButton;
@synthesize fullTextController,detailFavButton,coverBg,coreJournalSwitch,sciSwitch,reviewsSwitch,downEditButton,downTitle,favTitle,webVC,downRequestListButton,downFileListView,downRequestListView,helpCover,helpImageView,helpCoverButton,helpScrollView,helpPageControl, msgView, msgLabel,msgLoading,msgInfoImage;

@synthesize confirmViewController, confirmMainViewController;

@synthesize detailLine1, detailLine2;
@synthesize detailKeywordLabel, detailAbstractLabel;

@synthesize downAskDetail, detailSearch;

@synthesize httpRequestSearchAddFavoritedoc,httpRequestSearchAskforDoc,httpRequestSearchSort,httpRequestSearchDetail,httpRequestSearchDownloadDoc,httpRequestSearchGetUserStatus,httpRequestSearchRemoveFavoritedoc,httpRequestSearchResultSimpleSearch,httpRequestSearchSimpleSearch,httpRequestSearchSimpleSuggestion;
@synthesize httpRequestFavoritesSync,httpRequestFavoritesRemove,httpRequestFavoritesGetUserStatus,httpRequestFavoritesEditDetail,httpRequestFavoritesDownloadDoc,httpRequestFavoritesDetail,httpRequestFavoritesAskforDoc;
@synthesize httpRequestLocationAddFavoriteDoc,httpRequestLocationAskSync,httpRequestLocationDetail,httpRequestLocationDownloadDoc,httpRequestLocationEditDetail,httpRequestLocationGetUserStatus,httpRequestLocationRemoveFavoriteDoc;

@synthesize hasSavedButton, askingButton, askSuccessButton;
@synthesize askSuccessList;
@synthesize downAskSuccessListView;
@synthesize askingLoading, askSuccessLoading;
@synthesize locationTabBar;
@synthesize favView,askedView;
@synthesize hasNotification;
@synthesize httpRequest;
//,jumpExternalId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isFirstFav = true;
        isFirstAsked = true;
        NSLog(@"firstShow = %@", (firstShow?@"YES":@"NO"));
        firstShow = YES;
    }
    return self;
}

- (void)dealloc
{}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showBigCoverBgWithLoading:false];
    firstLoad =YES;
    advViewOn =NO;
    loadingMore =NO;
    self.hasNotification= NO;
    searchWebViewController* w =[[searchWebViewController alloc] initWithNibName:@"searchWebViewController" bundle:nil];
    self.webVC =w;
    
    showingBlackLoading =NO;
    showingBarLoading =NO;
    
    barLoadingRow =-1;
    barLoadingSection =-1;
    barLoadingAction =-1;
    
    downWifiOnly =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downWifiOnly"] boolValue];
    
    UIColor* leftTitleColor = RGBCOLOR(64, 84, 120);
    self.searchTitle.textColor = leftTitleColor;
    self.downTitle.textColor = leftTitleColor;
    self.favTitle.textColor = leftTitleColor;
    advancedQueryItemCount =1;
    
    isSort = false;
    [self locationTabBarViewLoading:LOCATION_TAB_BAR_HAS_SAVED];
    [self showAskSuccessLoading:NO];
    [self showAskingLoading:NO];
    
    NSString* mac = [Util getMacAddress];
    NSLog(@"========= MAC:%@",mac);
    
    NSArray *favnils = [[NSBundle mainBundle]loadNibNamed:@"RefreshView" owner:self options:nil];
    NSArray *askednils = [[NSBundle mainBundle]loadNibNamed:@"RefreshView" owner:self options:nil];
    self.favView = [favnils objectAtIndex:0];
    self.askedView = [askednils objectAtIndex:0];
    [favView setupWithOwner:self.favList delegate:self];
    [askedView setupWithOwner:self.askSuccessList delegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"did appear");
    if (!firstShow) {
        if (currentActionSelected == SIDEACTION_DOWNLOADED) {
            [self showAskingLoading:false];
            [self showAskSuccessLoading:false];
        }
        return;
    } else {
        firstShow = NO;
    }
    [self startLoading];
}

- (void)startLoading
{
    adview = [[AdvSearchViewController alloc]init];
    [self.view insertSubview:adview.view belowSubview:sideActionsView];
    adview.view.hidden = YES;
    adview.delegate = self;
    NSLog(@"start loading");
    inFullText = NO;
    self.pageNo.hidden =YES;
    //[searchHistory clearHistory];
    
    searchResultList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.searchListView.frame.size.width, self.searchListView.frame.size.height) style:UITableViewStylePlain];
    [searchResultList setDelegate:self];
    [searchResultList setDataSource:self];
    [searchResultList setBackgroundColor:[UIColor clearColor]];
    //searchResultList.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.searchListView.frame.size.width, 1)];
    //[searchResultList setSeparatorColor:[UIColor darkGrayColor]];
    [self.searchListView addSubview:searchResultList];
    
    //swipes
    UISwipeGestureRecognizer *swipeGesture = nil;
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(advSearchHandleAllSwipes:)];
    
	swipeGesture.cancelsTouchesInView = NO;
    swipeGesture.delaysTouchesEnded = NO;
    swipeGesture.delegate = self;
	swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
	[searchResultList addGestureRecognizer:swipeGesture];
    searchBar = [[mySearchBar alloc] initWithFrame:CGRectMake(2,6,self.searchbarView
                                                              .frame.size.width,self.searchbarView.frame.size.height)];
    
    //remove mysearch bg;
    UIView* segment = [searchBar.subviews objectAtIndex:0];
    [segment removeFromSuperview];
    searchBar.delegate = self;
    
    
    [self.searchbarView addSubview:searchBar];
    
    
    
    self.langSelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.langSelButton.frame = CGRectMake(5, 13, 46, 28);
    self.langSelButton.backgroundColor = [UIColor clearColor];
    
    
    if(currentSearchLanguage == SEARCH_MODE_CN)
    {
        
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-cn-normal"] forState:UIControlStateNormal];
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-cn-highlight.png"] forState:UIControlStateHighlighted];
        
        searchBar.placeholder = @"检索中文文献库";
    } else {
        
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-en-normal"] forState:UIControlStateNormal];
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-en-highlight.png"] forState:UIControlStateHighlighted];
        
        searchBar.placeholder = @"检索英文文献库";
    }
    
    //[self.langSelButton addTarget:self action:@selector(changeLanguage:) forControlEvents:UIControlEventTouchDown];
    
    [self.langSelButton addTarget:self action:@selector(popLanguageSelection:) forControlEvents:UIControlEventTouchDown];
    [self.searchbarView addSubview:langSelButton];
    
    self.searchResultCoverView.hidden = NO;
    self.loadingView.hidden=YES;
    
    
    //sideActionView
    self.sideActionsView.layer.cornerRadius = 2;
    
    self.sideActionsView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.sideActionsView.layer.shadowOpacity = 0.5;
    self.sideActionsView.layer.shadowRadius = 5.0;
    self.sideActionsView.layer.shadowOffset = CGSizeMake(0, 4);
    
    //listSearchView
    self.listSearchView.layer.cornerRadius = 2;
    
    self.listSearchView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.listSearchView.layer.shadowOpacity = 0.5;
    self.listSearchView.layer.shadowRadius = 3.0;
    self.listSearchView.layer.shadowOffset = CGSizeMake(0, 2);
    
    
    //ListFavView
    self.listFavView.layer.cornerRadius = 2;
    
    self.listFavView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.listFavView.layer.shadowOpacity = 0.5;
    self.listFavView.layer.shadowRadius = 3.0;
    self.listFavView.layer.shadowOffset = CGSizeMake(0, 2);
    
    
    //ListDownView
    self.listDownloadView.layer.cornerRadius = 2;
    
    self.listDownloadView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.listDownloadView.layer.shadowOpacity = 0.5;
    self.listDownloadView.layer.shadowRadius = 3.0;
    self.listDownloadView.layer.shadowOffset = CGSizeMake(0, 2);
    
    //title view
    self.titleLeftView.layer.cornerRadius = 2;
    
    self.titleLeftView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.titleLeftView.layer.shadowOpacity = 0.5;
    self.titleLeftView.layer.shadowRadius = 1.0;
    self.titleLeftView.layer.shadowOffset = CGSizeMake(0, 1);
    
    
    self.titleLeftFavView.layer.cornerRadius = 2;
    
    self.titleLeftFavView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.titleLeftFavView.layer.shadowOpacity = 0.5;
    self.titleLeftFavView.layer.shadowRadius = 1.0;
    self.titleLeftFavView.layer.shadowOffset = CGSizeMake(0, 1);
    
    self.titleLeftDownView.layer.cornerRadius = 2;
    
    self.titleLeftDownView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.titleLeftDownView.layer.shadowOpacity = 0.5;
    self.titleLeftDownView.layer.shadowRadius = 1.0;
    self.titleLeftDownView.layer.shadowOffset = CGSizeMake(0, 1);
    
    
    
    
    self.titleActionsView.layer.cornerRadius = 2;
    
    self.titleActionsView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.titleActionsView.layer.shadowOpacity = 1.0;
    self.titleActionsView.layer.shadowRadius = 3.0;
    self.titleActionsView.layer.shadowOffset = CGSizeMake(0, -1);
    
    
    //remove extra lines of adv table
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 50)];
    
    self.downList.tableFooterView =footer;
    self.favList.tableFooterView =footer;
    
    NSLog(@"first helped ture");
    displayState = DISPLAY_STATE_FRONTPAGE;
    self.backButton.hidden = YES;
    self.favoriteSaveButton.hidden = YES;
    self.searchTitle.text =@"文献检索";
    displayMax = 20;
    
    refreshWay = REFRESHWAY_INCREASEWAY;
    newSearchStart = YES;
    currentPage =1;
    fetchingPage =1;
    
    currentSearchLanguage = SEARCH_MODE_CN;
    currentResultLanguage = SEARCH_MODE_CN;
    
    [[NSUserDefaults standardUserDefaults] setInteger:currentSearchLanguage forKey:@"searchLan"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    currentActionSelected = SIDEACTION_SEARCH;
    [self refreshSideActionButtons];
    
    advancedQueryItemCount =1;
    advancedQueryItemCountMax =4;
    
    filterItemData = [self readPListBundleFile:@"searchFilters"];
    
    filterNames = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
    filterValues = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
    filterOperations = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
    
    for(int i =0; i < advancedQueryItemCountMax ;i++)
    {
        if(currentSearchLanguage == SEARCH_MODE_CN)
        {
            NSArray* TextCN = [filterItemData objectForKey:@"CN_TEXT"];
            [filterNames addObject:[TextCN objectAtIndex:0]];
        } else {
            NSArray* TextEN = [filterItemData objectForKey:@"EN_TEXT"];
            [filterNames addObject:[TextEN objectAtIndex:0]];
        }
        
        [filterValues addObject:@""];
        [filterOperations addObject:[NSNumber numberWithInt:OPERATION_AND]];
    }
    
    
    advViewAnimating = NO;
    newAdvSearch = NO;
    coreJournalOn =NO;
    sciOn = NO;
    reviewsOn = NO;
    
    minYear = @"";
    maxYear = @"";
    sortMethod =@"5";
    sortWay =0;
    catalogWay =0;
    
    
    yearTableController *content = [[yearTableController alloc] initWithNibName:@"yearTableController" bundle:nil];
    
    yearPopoverController = [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    
    yearPopoverController.popoverContentSize = CGSizeMake(320., 480.);
    yearPopoverController.delegate = self;
    
    currentDetailsFontSizeOffset = FONT_OFFSET_ZERO;
    
    [myDatabaseOption changeOlderVision];
    [self loginSuccessProcess:nil];
    
    self.requestArrays = [[[NSUserDefaults standardUserDefaults] objectForKey:@"requestArrays"] mutableCopy];
    
    NSLog(@"req arrays %@",requestArrays);
    if(requestArrays == nil)
    {
        requestArrays =[[NSMutableArray alloc] initWithCapacity:20];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.requestArrays forKey:@"requestArrays"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self updateRequestDown];
    
    self.detailView.scrollsToTop = NO;
	self.detailView.directionalLockEnabled = YES;
	self.detailView.showsVerticalScrollIndicator = NO;
	self.detailView.showsHorizontalScrollIndicator = NO;
	self.detailView.contentMode = UIViewContentModeRedraw;
	self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.detailView.minimumZoomScale = 0.5f;
    self.detailView.maximumZoomScale = 3.0f;
	self.detailView.contentSize = self.detailView.bounds.size;
	self.detailView.backgroundColor = [UIColor clearColor];
	self.detailView.delegate = self;
    
    //gesture recognition
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneTouch:)];
	tapGesture.cancelsTouchesInView = NO;
    tapGesture.delaysTouchesEnded = NO;
    tapGesture.delegate = self;
	tapGesture.numberOfTouchesRequired = 1;
    tapGesture.numberOfTapsRequired = 2; // One finger double tap
	[self.detailView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer* tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneTouch:)];
	tapGesture2.cancelsTouchesInView = NO;
    tapGesture2.delaysTouchesEnded = NO;
    tapGesture2.delegate = self;
	tapGesture2.numberOfTouchesRequired = 1;
    tapGesture2.numberOfTapsRequired = 1; // One finger double tap
	[self.detailView addGestureRecognizer:tapGesture2];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
    self.searchResultList =nil;
    self.sideActionsView =nil;
    self.listSearchView =nil;
    self.resultAreaView =nil;
    
    self.listFavView =nil;
    self.listDownloadView =nil;
    
    self.advButton =nil;
    
    self.detailJournalAndDate =nil;
    self.detailTitle =nil;
    self.detailAuthors =nil;
    self.detailaffiliations =nil;
    self.detailAbstractText =nil;
    self.detailKeyword =nil;
    
    self.detailKeywordString =nil;
    self.detailAbstractString =nil;
    
    self.detailLine1 = nil;
    self.detailLine2 = nil;
    
    self.AbstractTextScrollView =nil;
    
    self.titleLeftView =nil;
    self.titleLeftFavView =nil;
    self.titleLeftDownView =nil;
    
    
    self.titleActionsView =nil;
    
    self.searchbarView =nil;
    self.searchListView =nil;
    self.searchResultView =nil;
    self.searchResultCoverView =nil;
    
    self.loadingIndicator =nil;
    self.loadingLabel =nil;
    self.loadingView =nil;
    self.errorLabel =nil;
    
    self.searchedResult =nil;
    self.resultReadingStatus =nil;
    
    self.favList =nil;
    self.downList =nil;
    self.requestList =nil;
    
    self.langSelButton =nil;
    
    
    self.sideActionSearchButton =nil;
    self.sideActionFavoriteButton =nil;
    self.sideActionDownloadedButton =nil;
    self.sideActionSettingsButton =nil;
    self.sideActionHelpButton =nil;
    
    self.backButton =nil;
    self.favoriteSaveButton =nil;
    self.searchTitle =nil;
    
    self.currentKeybordHolder =nil;
    
    self.selectedDotSearch =nil;
    self.selectedDotFav =nil;
    self.selectedDotDownload =nil;
    self.mainLoginViewController =nil;
    
    self.downloadArrays =nil;
    self.fullTextDownloader =nil;
    
    self.detailView =nil;
    self.pdfView =nil;
    self.switchButton =nil;
    self.pageNo =nil;
    self.startCover =nil;
    
    self.favArrays =nil;
    self.favDetail =nil;
    self.favTitle =nil;
    self.detailFavButton =nil;
    
    self.coverBg =nil;
    self.downEditButton =nil;
    self.downTitle =nil;
    self.downRequestListButton =nil;
    
    self.downRequestListView =nil;
    self.downFileListView =nil;
    self.helpCover =nil;
    self.helpImageView =nil;
    self.helpCoverButton =nil;
    
    self.msgLabel =nil;
    self.msgLoading =nil;
    self.msgInfoImage =nil;
    self.msgView =nil;
}

#pragma mark - ios5 Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - ios6 Orientation
- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0)
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0)
{
    return (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
}
#pragma mark - swipe gesture
-(void)advSearchHandleAllSwipes:(UISwipeGestureRecognizer *)recognizer
{
    if( advViewAnimating) return;
	
    if (recognizer.direction & UISwipeGestureRecognizerDirectionRight)
    {
        [self advViewShow:nil];
    }
    
    if (recognizer.direction & UISwipeGestureRecognizerDirectionLeft)
    {
        [self advViewHide];
    }
    
    
}

#pragma mark - talbe delegate & datasource

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchResultList)
    {
        if(indexPath.row == loadingRow -1)
        {
            NSLog(@"refresh at this %d row",loadingRow);
            
            if(currentPage+1<=totalPages)
            {
                loadingMore =YES;
                [self performSelector:@selector(loadingNextBlock:) withObject:nil afterDelay:1.0f];
            }
        }
    }
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor* titleColor = [UIColor blackColor];
    UIColor* authorColor = RGBCOLOR(180, 180, 180);
    UIColor* journalColor = RGBCOLOR(180, 180, 180);
    
    if (tableView == self.searchResultList)
    {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        
        if(displayState == DISPLAY_STATE_RESULTS)
        {
            //[[cell subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
            for (UIView *view in [cell subviews]) {
                if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIActivityIndicatorView class]] || [view isKindOfClass:[UIImageView class]] || [view isKindOfClass:[MultipartLabel class]])
                    [view removeFromSuperview];
            }
            
            
            NSArray* results =[self.searchedResult objectForKey:@"results"];
            NSDictionary* result;
            
            if(results == (id)[NSNull null]  || [results count] ==0)
            {
                cell.textLabel.text = @"";
                
                UIImageView* noResultImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img-no-search-results"]];
                [cell addSubview:noResultImageView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                
                return  cell;
            }
            int rowNo = indexPath.row;
            if(rowNo == loadingRow-1 )
            {
                
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
            }
            result = [results objectAtIndex:rowNo];
            [self tableListItem:[results objectAtIndex:rowNo] cell:cell row:indexPath.row titleColor:titleColor authorColor:authorColor journalColor:journalColor];
            
            NSString *externalId = [result objectForKey:KEY_DOC_EXTERNALID];
            if(currentDisplayingRow == indexPath.row)
            {
                
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-results-selected-document"]];
                
                [self.resultReadingStatus replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
            }
            else
            {
                cell.backgroundView = nil;
                
                BOOL readFlag =  [myDatabaseOption isRead:externalId];//[[resultReadingStatus objectAtIndex:indexPath.row] boolValue];
                
                if(!readFlag)
                {
                    UIImageView* dotImage  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-results-unread-dot"]];
                    dotImage.frame = CGRectMake(4+2, 15+8,9, 9);
                    
                    [cell addSubview:dotImage];
                    
                    
                }
                
                
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return  cell;
            
        }
        else if(displayState == DISPLAY_STATE_SUGGESTION)
        {
            
            for (UIView *view in [cell subviews]) {
                if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIActivityIndicatorView class]] || [view isKindOfClass:[UIImageView class]] ||[view isKindOfClass:[MultipartLabel class]])
                    [view removeFromSuperview];
            }
            
            cell.textLabel.text =@"";
            
            MultipartLabel* ml = [[MultipartLabel alloc] initWithFrame:CGRectMake(16, 0, 300, 35)];
            ml.contentMode = UIViewContentModeBottomLeft;
            
            ml.backgroundColor =[UIColor clearColor];
            
            
            
            NSString* s=[suggestionArrays objectAtIndex:indexPath.row];
            
            if ([s rangeOfString:searchBar.text].location== NSNotFound)
            {
                [ml updateNumberOfLabels:1];
                [ml setText:s andFont:[UIFont systemFontOfSize:19] forLabel:0];
            }
            else
            {
                
                NSRange range = [s rangeOfString:searchBar.text];
                
                
                
                [ml updateNumberOfLabels:2];
                [ml setText:searchBar.text andFont:[UIFont boldSystemFontOfSize:19] andColor:[UIColor blackColor] forLabel:0];
                
                
                [ml setText:[s substringFromIndex:range.location+searchBar.text.length] andFont:[UIFont systemFontOfSize:19] forLabel:1];
                
            }
            
            //[ml setText:@"abc" andColor:[UIColor blueColor] forLabel:0];
            //[ml setText:@"mmm 99999 999  999sss" andColor:[UIColor redColor] forLabel:1];
            
            [cell addSubview:ml];
            
            //cell.textLabel.text = [NSString stringWithFormat:@"%@", [suggestionArrays objectAtIndex:indexPath.row]];
            
            cell.backgroundColor = [UIColor clearColor];
            
            
            /* if(indexPath.row != currentSelectedSuggestion)
             {
             cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-autoSugesstion-double-splitLIne"]] autorelease];
             }
             else
             {
             cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-autoSugesstion-selected-item"]] autorelease];
             
             }  */
            
            //[cell.textLabel setHighlightedTextColor:[UIColor blackColor]];
            
            return cell;
        }
        else if(displayState == DISPLAY_STATE_FRONTPAGE)
        {
            
            for (UIView *view in [cell subviews]) {
                if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIActivityIndicatorView class]] || [view isKindOfClass:[UIImageView class]] ||[view isKindOfClass:[MultipartLabel class]])
                    [view removeFromSuperview];
            }
            
            if(indexPath.section == 0)
            {
                
                int count =[searchHistory getHistoryCount];
                if(count ==0)
                {
                    cell.textLabel.text = @"无检索历史";
                    
                    //todo:change color
                    cell.textLabel.textColor = RGBCOLOR(127, 127, 127);
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                else if(indexPath.row == count)
                {
                    cell.textLabel.textColor = RGBCOLOR(100, 100, 100);
                    cell.textLabel.font = [UIFont fontWithName:@"Palatino" size:17.0];
                    cell.textLabel.text =@"清空历史记录...";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    
                }
                else
                {
                    
                    
                    int p = (MAX_HISTORY+[searchHistory getAvailbleHistoryPos]-1-indexPath.row)%MAX_HISTORY;
                    NSLog(@"----------qeqe-----------");
                    NSString* s=[searchHistory getSavedSearchHistory:p];
                    cell.textLabel.text =[s substringFromIndex:2];
                    
                    cell.textLabel.textColor = RGBCOLOR(50, 50, 50);
                    cell.textLabel.font = [UIFont fontWithName:@"Palatino" size:17.0];
                    cell.textLabel.textAlignment = NSTextAlignmentLeft;
                    [cell.textLabel sizeToFit];
                    
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                
            }
            //else if(indexPath.section == 1)
            //{
            //    cell.textLabel.text = @"请先登录";
            //}
            
            //[cell.textLabel setTextColor:[UIColor darkGrayColor]];
            //[cell.textLabel setHighlightedTextColor:[UIColor blackColor]];
        }
        else
        {
            
            for (UIView *view in [cell subviews]) {
                if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIActivityIndicatorView class]] || [view isKindOfClass:[UIImageView class]] || [view isKindOfClass:[MultipartLabel class]])
                    [view removeFromSuperview];
            }
            
            
            cell.textLabel.text = [NSString stringWithFormat:@"item %d", indexPath.row +1];
            
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
            [cell.textLabel setHighlightedTextColor:[UIColor blackColor]];
            
        }
        
        
        
        return cell;
    }
    else if(tableView == self.askSuccessList)
    {
        static NSString *CellIdentifier = @"deeAskSuccessListCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        for (UIView *view in [cell subviews]) {
            
            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIImageView class]])
                [view removeFromSuperview];
        }
        
        
        int rCount =[self.requestArrays count];
        
        NSLog(@"down arrays %@",self.requestArrays);
        
        if (rCount == 0)
        {
            UIImageView* noDownImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img-no-requested"]];
            [cell addSubview:noDownImageView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            hasAsked = false;
            return cell;
        }
        hasAsked = true;
        //    float leftOffset =21.0f;
        NSDictionary *dic =[self.requestArrays objectAtIndex:indexPath.row];
        NSLog(@"==============");
        NSLog(@"dic %@", dic);
        
        [self tableListItem:[dic objectForKey:@"shortDocInfo"] cell:cell row:indexPath.row titleColor:titleColor authorColor:authorColor journalColor:journalColor];
        
        cell.textLabel.text=@"";
        
        if(currentDisplayingSection == 0 && currentDisplayingRow == indexPath.row)
        {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-results-selected-document"]];
            
        }
        else
        {
            cell.backgroundView = nil;
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    else if(tableView == self.requestList)
    {
        static NSString *CellIdentifier = @"deeAskingListCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        for (UIView *view in [cell subviews]) {
            
            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIImageView class]])
                [view removeFromSuperview];
        }
        
        
        int rCount =[self.requestDownArrays count];
        
        NSLog(@"down arrays %@",self.requestDownArrays);
        
        if (rCount == 0)
        {
            UIImageView* noDownImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img-no-requesting"]];
            [cell addSubview:noDownImageView];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            hasAsking = false;
            return cell;
        }
        hasAsking = true;
        
        //    float leftOffset =21.0f;
        NSDictionary *dic =[self.requestDownArrays objectAtIndex:indexPath.row];
        NSLog(@"==============");
        NSLog(@"dic %@", dic);
        
        [self tableListItem:[dic objectForKey:@"shortDocInfo"] cell:cell row:indexPath.row titleColor:titleColor authorColor:authorColor journalColor:journalColor];
        
        cell.textLabel.text=@"";
        
        if(currentDisplayingSection == 0 && currentDisplayingRow == indexPath.row)
        {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-results-selected-document"]];
            
        }
        else
        {
            cell.backgroundView = nil;
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(tableView == self.downList)
    {
        static NSString *CellIdentifier = @"deeCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        for (UIView *view in [cell subviews]) {
            
            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIImageView class]])
                [view removeFromSuperview];
        }
        
        
        //    int rCount =[self.requestDownArrays count];
        int dCount =[self.downloadArrays count];
        
        NSLog(@"down arrays %@",self.downloadArrays);
        
        //    if(rCount==0 && dCount ==0)
        if (dCount == 0)
        {
            UIImageView* noDownImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img-saved-documents"]];
            [cell addSubview:noDownImageView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            hasSaveFile = false;
            
            return cell;
        }
        hasSaveFile = true;
        
        [self tableListItem:[self.downloadArrays objectAtIndex:dCount-1-indexPath.row] cell:cell row:indexPath.row titleColor:titleColor authorColor:authorColor journalColor:journalColor];
        cell.textLabel.text=@"";
        
        if (currentDisplayingRow == indexPath.row)
        {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-results-selected-document"]];
            
        } else {
            cell.backgroundView = nil;
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else if(tableView == self.favList) {
        static NSString *CellIdentifier = @"favCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        for (UIView *view in [cell subviews]) {
            
            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIImageView class]])
                [view removeFromSuperview];
        }
        
        int count =[self.favArrays count];
        if(self.favArrays ==nil ||count ==0)
        {
            UIImageView* noFavImageView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img-no-favorites"]];
            [cell addSubview:noFavImageView];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        float leftOffset =21.0f;
        
        //    NSDictionary* result =[self.favArrays objectAtIndex:count-1-indexPath.row];
        NSDictionary* result =[self.favArrays objectAtIndex:indexPath.row];
        //cell.textLabel.text = [result objectForKey:@"title"];
        
        
        NSString* rawTitleString = [result objectForKey:@"title"];
        NSString* titleString = [Util replaceEM:rawTitleString LeftMark:@"" RightMark:@""];
        
        CGSize sizeTitle = [titleString sizeWithFont:[UIFont fontWithName:@"Palatino-Bold" size:18.0] constrainedToSize:CGSizeMake(316, 60) lineBreakMode:NSLineBreakByWordWrapping];
        float titleHeight =((sizeTitle.height<42)?sizeTitle.height:42.0f);
        
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset,16,sizeTitle.width,titleHeight)];
        
        titleLabel.text = titleString;
        titleLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:18.0];
        titleLabel.textColor = titleColor;
        titleLabel.numberOfLines = 2;
        //titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        titleLabel.backgroundColor = [UIColor clearColor];
        
        [cell addSubview:titleLabel];
        
        NSArray* authors =[result objectForKey:@"author"];
        NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
        
        for(int i =0; i<[authors count];i++)
        {
            if(![s isEqualToString:@""])
                [s appendString:@" ,"];
            
            NSString* aStr = [authors objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            [s appendString:aStr];
        }
        
        UILabel* authorLable = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset,82,316,48)];
        
        authorLable.text = s;
        authorLable.font = [UIFont fontWithName:@"Palatino" size:14.0];
        authorLable.textColor = authorColor;
        authorLable.numberOfLines = 1;
        authorLable.backgroundColor = [UIColor clearColor];
        [cell addSubview:authorLable];
        
        s = [[NSMutableString alloc] initWithFormat:@""];
        
        NSString* journal =[result objectForKey:@"journal"];
        
        if(journal == (id)[NSNull null] || journal.length == 0 )
        {
            [s appendString:@""];
        }
        else
        {
            journal = [Util replaceEM:journal LeftMark:@"" RightMark:@""];
            [s appendString:journal];
        }
        
        if(![s isEqualToString:@""]) [s appendString:@" ,"];
        
        NSString* publishDate =[result objectForKey:@"pubDate"];
        if(publishDate == (id)[NSNull null] || publishDate.length == 0 )
        {
            [s appendString:@""];
        }
        else
        {
            publishDate = [Util replaceEM:publishDate LeftMark:@"" RightMark:@""];
            
            [s appendString:publishDate];
        }
        
        UILabel* journalAndDateLabel= [[UILabel alloc] initWithFrame:CGRectMake(leftOffset,122-18,316, 48)];
        
        journalAndDateLabel.text = s;
        journalAndDateLabel.numberOfLines = 1;
        journalAndDateLabel.font = [UIFont fontWithName:@"Palatino" size:14.0] ;
        journalAndDateLabel.textColor = journalColor;
        journalAndDateLabel.backgroundColor = [UIColor clearColor];
        
        [cell addSubview:journalAndDateLabel];
        
        cell.textLabel.text=@"";
        
        
        if(currentDisplayingRow == indexPath.row)
        {
            
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-results-selected-document"]];
            
            //[self.resultReadingStatus replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        }
        else
        {
            cell.backgroundView = nil;
            
            
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
        
    }
    else if(tableView == self.requestList)
    {
        static NSString *CellIdentifier = @"reqCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        for (UIView *view in [cell subviews])
        {
            
            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]] ||  [view isKindOfClass:[UIActivityIndicatorView class]])
                [view removeFromSuperview];
        }
        
        UILabel* title =[[UILabel alloc] initWithFrame:CGRectMake(5, 10, 270, 80)];
        [cell addSubview:title];
        title.numberOfLines =0;
        //title.backgroundColor =[UIColor blueColor];
        
        NSDictionary* item =[self.requestArrays objectAtIndex:[self.requestArrays count]-1-indexPath.row];
        
        
        
        NSString* titleString = [Util replaceEM:[item objectForKey:@"title"] LeftMark:@"" RightMark:@""];
        
        NSString* status =[item objectForKey:@"status"];
        
        title.text = titleString;
        
        if([status isEqualToString:ASKFULLTEXT_STATE_DOWNLOADABLE]
           || [status isEqualToString:ASKFULLTEXT_STATE_ASKFINISHED]
           || [status isEqualToString:ASKFULLTEXT_STATE_DOWNLOADING]
           
           )
        {
            UIButton* btn =[UIButton buttonWithType:UIButtonTypeCustom];
            
            [btn setBackgroundImage:[UIImage imageNamed:@"btn-2words-normal"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn-2words-highlight"] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn-2words-hightlight"] forState:UIControlStateHighlighted];
            
            [btn setTitle:@"下载" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            btn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
            
            btn.tag =[self.requestArrays count]-1-indexPath.row;
            
            [btn addTarget:self action:@selector(downRequest:) forControlEvents:UIControlEventTouchUpInside];
            
            btn.frame = CGRectMake(280, 30, 55, 29);
            [cell addSubview:btn];
        }
        
        /*if([status isEqualToString:ASKFULLTEXT_STATE_DOWNLOADING])
         {
         UIActivityIndicatorView* indicator =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
         
         [indicator startAnimating];
         indicator.frame =CGRectMake(280, 30, 40, 40);
         [cell addSubview:indicator];
         
         }
         
         if([status isEqualToString:ASKFULLTEXT_STATE_ASKFINISHED])
         {
         UILabel* st =[[UILabel alloc] initWithFrame:CGRectMake(280, 30, 60, 40)];
         st.text =@"准备中";
         [cell addSubview:st];
         [st release];
         }*/
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
        
    }
    
    
    static NSString *CellIdentifier = @"defaultCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text =@"defatult";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchResultList)
    {
        
        if(displayState == DISPLAY_STATE_FRONTPAGE)
            return 1;
        else
            return 1;
    } else
        return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchResultList)
    {
        
        if(displayState == DISPLAY_STATE_FRONTPAGE)
            return 50;
        else if(displayState == DISPLAY_STATE_RESULTS)
        {
            if(indexPath.row == loadingRow-1)
                return 88;
            
            NSArray* results =[self.searchedResult objectForKey:@"results"];
            if([results count] ==0) return 260;
            return 162;
        }
        else if(displayState == DISPLAY_STATE_SUGGESTION)
            return 46;
        else
            return 50;
    }
    
    if(tableView == self.downList)
    {
        
        //    int rCount =[self.requestDownArrays count];
        int dCount =[self.downloadArrays count];
        
        //    if(rCount ==0 && dCount==0) return 260;
        if (dCount == 0) {
            return 260;
        }
        
        return 162;
    }
    
    if (tableView == self.requestList) {
        int aCount = [self.requestDownArrays count];
        if (aCount == 0) {
            return 260;
        }
        return 162;
    }
    
    if (tableView == self.askSuccessList) {
        int rCount = [self.requestArrays count];
        if (rCount == 0) {
            return 260;
        }
        return 162;
    }
    
    if(tableView == self.favList)
    {
        int count =[self.favArrays count];
        if(count ==0)return 260;
        return 162;
    }
    //  if(tableView == self.requestList)
    //  {
    //
    //
    //    return 100;
    //  }
    
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchResultList)
    {
        if(displayState == DISPLAY_STATE_FRONTPAGE)
        {
            
            if(section == 0)
            {
                int count = [searchHistory getHistoryCount];
                if(count ==0) return 1;
                return count+1;
            }
            else if(section == 1)
            {
                return 1;
            }
            else
            {
                return 5;
            }
        }
        else if(displayState == DISPLAY_STATE_RESULTS)
        {
            
            NSLog(@"total pages %d",totalPages);
            
            if(totalPages == currentPage || isSinglePage)
                return displayCount;
            else
                return displayCount +1;
        }
        else if(displayState == DISPLAY_STATE_SUGGESTION)
        {
            return suggestionCount;
        }
        return 0;
    }
    else if(tableView == self.downList)
    {
        
        //    int rCount =[self.requestDownArrays count];
        int dCount =[self.downloadArrays count];
        
        if(dCount ==0) return 1;
        return dCount;
        
        //    if(rCount==0 && dCount==0) return 1;
        //
        //    if(section ==0)
        //    {
        //      if(rCount ==0 && dCount>0)return dCount;
        //
        //      return rCount;
        //
        //    }
        //
        //    if(section ==1) return dCount;
        
        //int count =[self.downloadArrays count];
        //if(count>0) return count;
        //return 1;
    }
    else if(tableView == self.askSuccessList)
    {
        int rCount = [self.requestArrays count];
        if (rCount > 0) {
            return rCount;
        }
        return 1;
    }
    else if(tableView == self.requestList){
        int aCount = [self.requestDownArrays count];
        if (aCount > 0) {
            return aCount;
        }
        return 1;
    }
    else if(tableView == self.favList)
    {
        //NSLog(@"f %d",[self.favArrays count]);
        int count =[self.favArrays count];
        if(count>0) return count;
        return 1;
    }
    else if(tableView == self.requestList)
    {
        return [self.requestArrays count];
        
    }
    
    return 0;
}

-(UITableViewCell *)tableListItem:(NSDictionary *)rt cell:(UITableViewCell *)cl row:(int)row titleColor:(UIColor *)titleColor authorColor:(UIColor *)authorColor journalColor:(UIColor *)journalColor
{
    //  result =;
    NSDictionary *result = [rt copy];
    UITableViewCell *cell = cl;
    
    NSString* rawTitleString = [result objectForKey:@"title"];
    NSString* titleString = [Util replaceEM:rawTitleString LeftMark:@"" RightMark:@""];
    
    CGSize sizeTitle = [titleString sizeWithFont:[UIFont fontWithName:@"Palatino-Bold" size:18.0] constrainedToSize:CGSizeMake(316-3, 60) lineBreakMode:NSLineBreakByWordWrapping];
    
    float leftOffset =21.0f;
    
    float titleHeight =((sizeTitle.height<42)?sizeTitle.height:42.0f);
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset ,38,sizeTitle.width,titleHeight)];
    
    titleLabel.text = titleString;
    titleLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:18.0];
    titleLabel.textColor = titleColor;
    titleLabel.numberOfLines = 2;
    
    //NSLog(@"title size %@ %f",titleString,sizeTitle.height);
    
    
    
    // titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    //UILineBreakModeWordWrap;
    
    titleLabel.backgroundColor = [UIColor clearColor];
    
    [cell addSubview:titleLabel];
    
    NSArray* authors =[result objectForKey:@"author"];
    NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
    //        NSLog(@"1==== %d", [s retainCount]);
    
    for(int i =0; i<[authors count];i++)
    {
        if(![s isEqualToString:@""])
            [s appendString:@" ,"];
        
        NSString* aStr = [authors objectAtIndex:i];
        aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
        [s appendString:aStr];
    }
    
    UILabel* authorLable = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset ,82 ,316,30)];
    authorLable.text = s;
    authorLable.font = [UIFont fontWithName:@"Palatino" size:14.0];
    authorLable.textColor = authorColor;
    authorLable.numberOfLines = 1;
    
    authorLable.backgroundColor = [UIColor clearColor];
    [cell addSubview:authorLable];
    
    //affliation
    NSArray* affiliations =[result objectForKey:@"affiliation"];
    NSMutableString* affiliationString = [[NSMutableString alloc] initWithFormat:@""];
    
    if(affiliations == (id)[NSNull null] || [affiliations count] == 0)
    {
        
    }
    else
    {
        for(int i =0; i<[affiliations count];i++)
        {
            if(![affiliationString isEqualToString:@""])
                [affiliationString appendString:@" ,"];
            
            NSString* aStr = [affiliations objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            [affiliationString appendString:aStr];
            
        }
    }
    
    //        s = [NSString stringWithFormat:@"%@", affiliationString];
    
    UILabel* myDetailAffiliations = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset ,122-18,316,30)];
    //        NSLog(@"==== %d", [s retainCount]);
    myDetailAffiliations.text = affiliationString;
    myDetailAffiliations.font = [UIFont fontWithName:@"Palatino" size:14.0];
    myDetailAffiliations.textColor = authorColor;
    myDetailAffiliations.numberOfLines = 1;
    
    myDetailAffiliations.backgroundColor = [UIColor clearColor];
    
    [cell addSubview:myDetailAffiliations];
    
    s = [[NSMutableString alloc] initWithFormat:@""];
    
    NSString* journal =[result objectForKey:@"journal"];
    
    if(journal == (id)[NSNull null] || journal.length == 0 )
    {
        [s appendString:@""];
    }
    else
    {
        journal = [Util replaceEM:journal LeftMark:@"" RightMark:@""];
        [s appendString:journal];
    }
    
    if(![s isEqualToString:@""]) [s appendString:@" ,"];
    
    NSString* publishDate =[result objectForKey:@"pubDate"];
    if(publishDate == (id)[NSNull null] || publishDate.length == 0 )
    {
        [s appendString:@""];
    }
    else
    {
        publishDate = [Util replaceEM:publishDate LeftMark:@"" RightMark:@""];
        
        [s appendString:publishDate];
    }
    
    NSString* volume = [result objectForKey:@"volume"];
    if (volume == (id)[NSNull null] || volume.length == 0)
    {
        [s appendString:@""];
    }
    else {
        volume = [Util replaceEM:volume LeftMark:@"" RightMark:@""];
        [s appendFormat:@";%@", volume];
    }
    
    NSString* issue = [result objectForKey:@"issue"];
    if (issue == (id)[NSNull null] || issue.length == 0)
    {
        [s appendString:@""];
    }
    else
    {
        issue = [Util replaceEM:issue LeftMark:@"" RightMark:@""];
        [s appendFormat:@"(%@)", issue];
    }
    
    NSString* pagination = [result objectForKey:@"pagination"];
    if (pagination == (id)[NSNull null] || pagination.length == 0) {
        [s appendString:@""];
    }
    else {
        pagination = [Util replaceEM:pagination LeftMark:@"" RightMark:@""];
        [s appendFormat:@":%@", pagination];
    }
    
    //        s = [NSString stringWithFormat:@"出处 %@", s];
    
    UILabel* journalAndDateLabel= [[UILabel alloc] initWithFrame:CGRectMake(leftOffset ,12 ,316, 30)];
    
    journalAndDateLabel.text = s;
    journalAndDateLabel.numberOfLines = 1;
    journalAndDateLabel.font = [UIFont fontWithName:@"Palatino" size:14.0] ;
    journalAndDateLabel.textColor = journalColor;
    journalAndDateLabel.backgroundColor = [UIColor clearColor];
    
    [cell addSubview:journalAndDateLabel];
    
    cell.textLabel.text=@"";
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchResultList)
    {
        if(displayState == DISPLAY_STATE_FRONTPAGE)
        {
            UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 30)];
            
            header.backgroundColor = [UIColor whiteColor];
            
            if(section == 0)
            {
                UIImageView* bgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-searchHistory-bar"]];
                [header addSubview:bgView];
            }
            else if(section ==1)
            {
                UIImageView* bgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-savedSearch-bar"]];
                [header addSubview:bgView];
            }
            else
            {
                UIImageView* bgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-topSearch-bar"]];
                [header addSubview:bgView];
            }
            
            return header;
        }
        else if(displayState == DISPLAY_STATE_RESULTS)
        {
            UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 40)];
            UIImageView* bgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-autoSugesstion-background"]];
            [header addSubview:bgView];
            
            UIButton* btLeft = [UIButton buttonWithType:UIButtonTypeCustom];
            btLeft.frame = CGRectMake(8, 6, 69, 29);
            
            [btLeft setBackgroundImage:[UIImage imageNamed:@"btn-4words-normal"] forState:UIControlStateNormal];
            [btLeft setBackgroundImage:[UIImage imageNamed:@"btn-4words-highlight"] forState:UIControlStateHighlighted];
            
            [btLeft setTitleColor:RGBCOLOR(43, 54, 78) forState:UIControlStateNormal];
            
            btLeft.titleLabel.font=[UIFont systemFontOfSize:15.0f];
            
            if(sortWay ==0)
            {
                [btLeft setTitle:@"相关排序" forState:UIControlStateNormal];
            }
            else if(sortWay ==1)
            {
                [btLeft setTitle:@"时间排序" forState:UIControlStateNormal];
            }
            else
            {
                [btLeft setTitle:@"期刊排序" forState:UIControlStateNormal];
            }
            
            [btLeft addTarget:self action:@selector(sortPressed:) forControlEvents:UIControlEventTouchDown];
            
            self.resultLeftButton =nil;
            self.resultLeftButton = btLeft;
            
            [header addSubview:btLeft];
            
            UILabel* labelCounts = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,348, 40)];
            labelCounts.textAlignment = NSTextAlignmentCenter;
            
            labelCounts.text = [NSString stringWithFormat:SEARCH_RESULT_COUNT,resultsCount];
            
            
            labelCounts.backgroundColor = [UIColor clearColor];
            [header addSubview:labelCounts];
            
            return header;
        }
        else if(displayState == DISPLAY_STATE_SUGGESTION)
        {
            UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 30)];
            UIImageView* bgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-autoSugesstion-display-tips"]];
            [header addSubview:bgView];
            
            
            
            return header;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchResultList)
    {
        if(displayState == DISPLAY_STATE_FRONTPAGE)
            return 30;
        
        if(displayState == DISPLAY_STATE_SUGGESTION)
            return 30;
        
        return 40;
    }
    
    return 0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchResultList)
    {
        if(displayState == DISPLAY_STATE_SUGGESTION)
        {
            currentSelectedSuggestion = indexPath.row;
            [self.searchResultList reloadData];
            searchBar.text = [suggestionArrays objectAtIndex:indexPath.row];
            
            //search it
            NSString *searchString = [searchBar text];
            [self finishSearchWithString:searchString];
            
            [self.currentKeybordHolder resignFirstResponder];
            
            
        }
        else if(displayState == DISPLAY_STATE_RESULTS)
        {
            if(currentDisplayingRow != indexPath.row)
            {
                if(indexPath.row == loadingRow-1)
                {return;}
                
                currentDisplayingRow = indexPath.row;
                currentDisplayingSection = indexPath.section;
                
                [self.resultReadingStatus replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
                
                if(barLoadingRow!=currentDisplayingRow || barLoadingSection!=currentDisplayingSection)
                    [self hideMsgBar];
                
                [self.searchResultList reloadData];
                [self displaySearchDetail];
            }
        }
        else if(displayState == DISPLAY_STATE_FRONTPAGE)
        {
            //hasLogged = NO;
            
            if(indexPath.section ==0)
            {
                int count =[searchHistory getHistoryCount];
                if(count ==0)
                {
                    return;
                }
                else if(indexPath.row == count)
                {
                    [searchHistory clearHistory];
                    [self.searchResultList reloadData];
                }
                else
                {
                    int p = (MAX_HISTORY+[searchHistory getAvailbleHistoryPos]-1-indexPath.row)%MAX_HISTORY;
                    NSLog(@"--------------+++++++++-------------");
                    NSString* s=[searchHistory getSavedSearchHistory:p];
                    
                    searchBar.text =[s substringFromIndex:2];
                    
                    //language!
                    NSLog(@"lang %@",[s substringToIndex:2]);
                    [self changeLanguageTo:[s substringToIndex:2]];
                    
                    //search it
                    NSString *searchString = [searchBar text];
                    [self finishSearchWithString:searchString];
                }
            }
            //else if(!hasLogged && indexPath.section == 1)
            //{
            //    [self presentLoginWindow:nil];
            //}
            
            
        }
        
    }
    
    if(tableView == self.favList)
    {
        currentDisplayingRow = indexPath.row;
        currentDisplayingSection = indexPath.section;
        
        if(barLoadingRow!=currentDisplayingRow || barLoadingSection!=currentDisplayingSection)
            [self hideMsgBar];
        
        
        [self.favList reloadData];
        [self loadFavDetail];
        
    }
    
    if (tableView == self.requestList) {
        if (!hasAsking) {
            return;
        }
        if (barLoadingRow!=currentDisplayingRow || barLoadingSection!=currentDisplayingSection) {
            [self hideMsgBar];
        }
        currentDisplayingSection = indexPath.section;
        currentDisplayingRow = indexPath.row;
        [self showCoverBgWithLoading:true];
        [self locationAskforDetail];
        [self.requestList reloadData];
    }
    
    if (tableView == self.askSuccessList) {
        if (!hasAsked) {
            return;
        }
        if (barLoadingRow!=currentDisplayingRow || barLoadingSection!=currentDisplayingSection) {
            [self hideMsgBar];
        }
        currentDisplayingSection = indexPath.section;
        currentDisplayingRow = indexPath.row;
        [self showCoverBgWithLoading:true];
        [self locationAskforDetail];
        [self.askSuccessList reloadData];
    }
    
    if(tableView == self.downList)
    {
        if (!hasSaveFile) {
            return;
        }
        if(barLoadingRow!=currentDisplayingRow || barLoadingSection!=currentDisplayingSection)
            [self hideMsgBar];
        [self showHasSaved:indexPath.section row:indexPath.row];
    }
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (aTableView == self.favList  &&
        editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"delete commited");
        
        //docsearch/removefav/:id/
        
        //    int count =[self.favArrays count];
        
        //    NSDictionary* item =[self.favArrays objectAtIndex:count-1-indexPath.row];
        NSDictionary* item =[self.favArrays objectAtIndex:indexPath.row];
        
        NSString* eId =[item objectForKey:@"externalId"];
        
        [self removeFav:eId];
        [self.favEditButton setTitle:@"编辑" forState:UIControlStateNormal];
        
    }
    
    if (aTableView == self.downList &&
        editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"delete commited");
        int dCount =[self.downloadArrays count];
        
        NSDictionary* item;
        item=[self.downloadArrays objectAtIndex:dCount-1-indexPath.row];
        NSLog(@"before delete item %@",item);
        
        
        NSString* eId =[item objectForKey:@"externalId"];
        NSString* fileName = [self fileNameWithExternelId:eId];
        NSString *filePath = [self filePathInDocuments:fileName];
        
        NSError *error;
        if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
        {
            
            NSLog(@"del failed %@",error);
        }
        if (![myDatabaseOption isSavedDocWithAnother:eId]) {
            [self removeDocumentFromLocation:fileName];
        }
        
        [self remvoeFromDownloadArraysWith:eId];
        
        
        NSLog(@"REQ ARRAY %@",self.requestDownArrays);
        
        
        [self.downList reloadData];
        [self.downList setEditing:NO animated:NO];
        
        //    [self.downEditButton setTitle:@"编辑" forState:UIControlStateNormal];
        
        
        
        currentDisplayingRow =0;
        currentDisplayingSection =0;
        
        //    rCount =[self.requestDownArrays count];
        dCount =[self.downloadArrays count];
        NSLog(@"%d",dCount);
        if(dCount == 0)
        {
            [self showCoverBgWithLoading:NO];
            self.downEditButton.hidden=YES;
            
        }
        else
        {
            self.downAskDetail = [self.downloadArrays objectAtIndex:[self.downloadArrays count]-1];
            [self displayDetails];
            self.downEditButton.hidden=NO;
            
        }
        
        
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    //if (self.editing) {
    
    if(aTableView == self.favList)
    {
        if([self.favArrays count] ==0)
            return UITableViewCellEditingStyleNone;
        else {
            return UITableViewCellEditingStyleDelete;
        }
    }
    
    
    if(aTableView == self.downList)
    {
        //    int rCount =[self.requestDownArrays count];
        int dCount =[self.downloadArrays count];
        
        if(dCount ==0)
            return UITableViewCellEditingStyleNone;
        else
            return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  if (tableView == self.downList) {
    //    int rCount =[self.requestDownArrays count];
    //    int dCount =[self.downloadArrays count];
    //    if (rCount > 0) {
    //      if (indexPath.section == 0) {
    //        return NO;
    //      }
    //    }
    //  }
    return YES;
}

#pragma mark - textfield delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.currentKeybordHolder  = nil;
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.currentKeybordHolder  = textField;
    return YES;
    
}

-(void)addKeyboardHolder:(id)sender
{
    self.currentKeybordHolder  = sender;
    
}

-(void)removeKeyboardHolder:(id)sender
{
    self.currentKeybordHolder  = nil;
    
    
}


#pragma mark -
#pragma mark Search bar delegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)aSearchBar
{
    self.currentKeybordHolder  = aSearchBar;
    adview.newSearchStart = NO;
    return  YES;//!isLoading;
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{
    //display suggestions
    
    displayState = DISPLAY_STATE_SUGGESTION;
    [self displayStates];
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        //do not waring at suggestion
        //[self netWorksWarning];
        return;
    }
    
    if(![aSearchBar.text isEqualToString:@""])
        self.httpRequestSearchSimpleSuggestion = [self searchSimpleSuggestion:aSearchBar.text lan:currentResultLanguage Delegate:self];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    
    // If the user finishes editing text in the search bar by, for example tapping away rather than selecting from the recents list, then just dismiss the popover.
    
    NSLog(@"end");
    
    [aSearchBar resignFirstResponder];
    self.currentKeybordHolder  = nil;
    
    // dingzh
    //  displayState = DISPLAY_STATE_FRONTPAGE;
    //  [self displayStates];
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if([searchText isEqualToString:@""])return;
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        //do not waring at suggestion
        //[self netWorksWarning];
        return;
    }
    
    // When the search string changes, filter the recents list accordingly.
    self.httpRequestSearchSimpleSuggestion = [self searchSimpleSuggestion:searchText lan:currentResultLanguage Delegate:self];
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    
    //NSLog(@"search");
    
    [aSearchBar resignFirstResponder];
    self.currentKeybordHolder  = nil;
    
    // When the search button is tapped, add the search term to recents and conduct the search.
    NSString *searchString = [aSearchBar text];
    //[recentSearchesController addToRecentSearches:searchString];
    
    [self finishSearchWithString:searchString];
    
    //self.advancedToolBar.hidden =YES;
    //self.searchResultsTable.hidden=YES;
    
    
}

- (void)finishSearchWithString:(NSString *)searchString {
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        [self netWorksWarning];
        return;
    }
    
    newSearchStart = YES;
    currentPage =1;
    fetchingPage =1;
    
    if(displayState == DISPLAY_STATE_FRONTPAGE || displayState == DISPLAY_STATE_RESULTS || displayState == DISPLAY_STATE_SUGGESTION)
    {
        
        NSString* lan;
        if (currentSearchLanguage == SEARCH_MODE_CN)
            lan =@"CN";
        else
            lan =@"EN";
        
        [searchHistory saveSearchHistory:searchString Language:lan];
        
        searchingType = SEARCHING_TYPE_SIMPLE;
        
        [ImdAppBehavior searchJsonLog:[Util getUsername] MACAddr:[Util getMacAddress] SearchJson:[NSString stringWithFormat:@"{\"type\":\"simple search\",\"search words\":\"%@\",\"page\":%i,\"lan\":%i,\"sort\":%i}", searchString, currentPage, currentSearchLanguage,[sortMethod intValue]]];
        
        self.httpRequestSearchSimpleSearch = [self searchSimpleSearch:searchString Page:currentPage Lan:currentSearchLanguage Delegate:self sort:[sortMethod intValue]];
    }
    
    //if(displayState == DISPLAY_STATE_ADVSEARCH)
    //  if(advViewOn)
    //  {
    //    [self newAdvSearch:nil];
    //  }
    
    
    [self showCoverBgWithLoading:YES];
}

#pragma mark - ASIHTTPRequest delegate
-(ASIHTTPRequest*)checkVer:(NSString *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //  NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    //  NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:YES];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"checkVer" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    
    request.timeOutSeconds = 6*10;
    request.delegate = self;
    [request startAsynchronous];
    
    return request;
}
-(ASIHTTPRequest*)getUserInfo:(NSString *)url delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //  NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    //  NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:YES];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"checkVer" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 6*10;
    request.delegate = dlgt;
    [request startAsynchronous];
    
    return request;
}

-(ASIHTTPRequest*)addFavoriteDoc:(NSString *)externalId fileTitle:(NSString *)title
{
    NSString* addFavURL =[NSString stringWithFormat:@"http://%@/docsearch/fav?id=%@&title=%@",SEARCH_SERVER,externalId,title];
    
    NSLog(@"addFav url = %@",addFavURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:addFavURL]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //  NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    //  NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:YES];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_ADD_FAVORITE forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    
    return request;
}

-(ASIHTTPRequest*)searchAddFavoriteDoc:(NSString *)externalId fileTitle:(NSString *)title
{
    if (externalId == nil || externalId.length == 0
        || title == nil || title.length == 0) {
        return nil;
    }
    if (self.httpRequestSearchAddFavoritedoc != nil){
        [self.httpRequestSearchAddFavoritedoc cancel];
    }
    return [self addFavoriteDoc:externalId fileTitle:title];
}


-(ASIHTTPRequest*)searchAskforDoc:(NSString *)externalId fileTitle:(NSString *)title rawTitle:(NSString *)rawtitle item:(NSDictionary*)result
{
    if (self.httpRequestSearchAskforDoc != nil) {
        [self.httpRequestSearchAskforDoc cancel];
    }
    return [self askforDoc:externalId fileTitle:title rawTitle:rawtitle item:result];
}

-(ASIHTTPRequest*)askforDoc:(NSString *)externalId fileTitle:(NSString *)title rawTitle:(NSString *)rawtitle item:(NSDictionary*)result
{
    NSString* askURL =[NSString stringWithFormat:@"http://%@/docsearch/askfor?id=%@&title=%@",SEARCH_SERVER,externalId,title];
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:askURL]];
    
    NSLog(@"ask url =%@",askURL);
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
  NSString *curVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  NSString *systemVer =  [[UIDevice currentDevice] systemVersion];
  [request setUserAgent:[NSString stringWithFormat:@"imd-ios-iPad(version:%@,systemversion:%@)",curVer,systemVer]];
  
  
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //  NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    //  NSLog(@"token =%@",token);
    
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"askFullText" forKey:@"requestType"];
    [userInfo setObject:externalId forKey:@"askingId"];
    [userInfo setObject:rawtitle forKey:@"askingTitle"];
    [userInfo setObject:result forKey:@"item"];
    
    
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    
    
    return request;
}


-(ASIHTTPRequest*)searchDetail:(NSString *)externalId
{
    if (externalId == nil || externalId.length == 0) {
        return nil;
    }
    
    if (self.httpRequestSearchDetail != nil) {
        [self.httpRequestSearchDetail cancel];
    }
    
    NSString* url = [NSString stringWithFormat:@"http://%@/docsearch/docu/%@/",SEARCH_SERVER, externalId];
    NSLog(@"url =%@",url);
    
    ASIHTTPRequest* request =
    [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    
    //Create a cookie
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",CONFIRM_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_SEARCH_DETAIL forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    
    request.delegate =self;
    [request startAsynchronous];
    NSLog(@"startAsynchronous");
    
    return request;
}

-(ASIHTTPRequest*)searchDownloadDoc:(NSString *)fileName filePath:(NSString *)filePath externalId:(NSString *)eId fileTitle:(NSString *)fileTitle
{
    [ImdAppBehavior doDownloadLog:[Util getUsername] MACAddr:[Util getMacAddress] title:fileTitle pageName:PAGE_SEARCH];
    if (self.httpRequestSearchDownloadDoc != nil) {
        [self.httpRequestSearchDownloadDoc cancel];
    }
    return [self downloadDoc:fileName filePath:filePath externalId:eId fileTitle:fileTitle];
}

-(ASIHTTPRequest*)downloadDoc:(NSString *)fileName filePath:(NSString *)filePath externalId:(NSString *)eId fileTitle:(NSString *)fileTitle
{
    NSString* fileURL = [NSString stringWithFormat:@"http://%@/docsearch/download/%@/",PDFPROCESS_SERVER,eId];
    
    NSLog(@"url a = %@",fileURL);
    self.fullTextDownloader = nil;
    
    
    self.fullTextDownloader = [downloader requestWithURL:[NSURL URLWithString:fileURL]];
    //self.fullTextDownloader.fileName = @"result.pdf";
    
    [self.fullTextDownloader addRequestHeader:@"Content-Type" value:@"application/json"];
    [self.fullTextDownloader addRequestHeader:@"Accept" value:@"application/json"];
    
    self.fullTextDownloader.fileName =fileName;
    self.fullTextDownloader.fileURL = fileURL;
    self.fullTextDownloader.filePath = filePath;
    
    self.fullTextDownloader.timeOutSeconds = 120;
    
    //self.fullTextDownloader.downloadType = MEETING_SLIDERS;
    self.fullTextDownloader.retryingTimes = 0;
    self.fullTextDownloader.retryingMaxTimes = 1;
    
    [self.fullTextDownloader setDownloadDestinationPath:self.fullTextDownloader.filePath];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_DOWNLOAD_DOC forKey:@"requestType"];
    [userInfo setObject:self.fullTextDownloader.fileName forKey:@"downloadFile"];
    [userInfo setObject:fileTitle forKey:@"downloadTitle"];
    [userInfo setObject:filePath forKey:@"downloadPath"];
    
    [self.fullTextDownloader setUserInfo:userInfo];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/download"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [self.fullTextDownloader setUseCookiePersistence:NO];
    [self.fullTextDownloader setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
  NSString *curVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  NSString *systemVer =  [[UIDevice currentDevice] systemVersion];
  [self.fullTextDownloader setUserAgent:[NSString stringWithFormat:@"imd-ios-iPad(version:%@,systemversion:%@)",curVer,systemVer]];
    
    self.fullTextDownloader.delegate = self;
    [self.fullTextDownloader startAsynchronous];
    
    return self.fullTextDownloader;
}

-(ASIHTTPRequest*)searchGetUserStatus
{
    if (self.httpRequestSearchGetUserStatus != nil) {
        [self.httpRequestSearchGetUserStatus cancel];
    }
    return [self getUserStatus];
}

-(ASIHTTPRequest*)getUserStatus
{
    NSString* theUrl = [NSString stringWithFormat:
                        @"http://%@/user/active", CONFIRM_SERVER];
    
    NSLog(@"url =%@",theUrl);
    
    ASIHTTPRequest* request =
    [ASIHTTPRequest requestWithURL:[NSURL URLWithString:theUrl]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",CONFIRM_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_GET_USER_STATUS forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    
    request.delegate =self;
    [request startAsynchronous];
    NSLog(@"startAsynchronous");
    
    return request;
}


-(ASIHTTPRequest*)searchRemoveFavoritedoc:(NSString *)fid
{
    if (fid == nil || fid.length == 0) {
        return nil;
    }
    if (self.httpRequestSearchRemoveFavoritedoc) {
        [self.httpRequestSearchRemoveFavoritedoc cancel];
    }
    return [self removeFavoritedoc:fid];
}

-(ASIHTTPRequest*)removeFavoritedoc:(NSString *)fid
{
    NSString* removeFavURL =[NSString stringWithFormat:@"http://%@/docsearch/removefav/%@",SEARCH_SERVER,fid];
    
    NSLog(@"url = %@",removeFavURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:removeFavURL]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:YES];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_REMOVE_FAVORITE_DOC forKey:@"requestType"];
    [userInfo setObject:fid forKey:@"externalId"];
    
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    
    
    return request;
}

-(ASIHTTPRequest*)searchResultSimpleSearch:(NSString*)searchString Page:(int)pNo Lan:(int)LanMode Delegate:(id)d sort:(int)sort
{
    if (self.httpRequestSearchResultSimpleSearch != nil) {
        NSLog(@"self.httpRequestSearchResultSimpleSearch cancel");
        [self.httpRequestSearchResultSimpleSearch cancel];
    }
    
    return [imdSearcher simpleSearch:searchString Page:pNo Lan:LanMode Delegate:d sort:sort];
}

-(ASIHTTPRequest*)searchSimpleSearch:(NSString*)searchString Page:(int)pNo Lan:(int)LanMode Delegate:(id)d sort:(int)sort
{
    if (self.httpRequestSearchSimpleSearch != nil) {
        [self.httpRequestSearchSimpleSearch cancel];
    }
    return [imdSearcher simpleSearch:searchString Page:pNo Lan:LanMode Delegate:d sort:sort];
}

-(ASIHTTPRequest*)searchSimpleSuggestion:(NSString*)word lan:(int)LanMode Delegate:(id)d
{
    if (self.httpRequestSearchSimpleSuggestion != nil) {
        NSLog(@"self.httpRequestSearchSimpleSuggestion cancel");
        [self.httpRequestSearchSimpleSuggestion cancel];
    }
    return [imdSearcher fetchSuggestion:word lan:LanMode Delegate:d];
}

-(ASIHTTPRequest*)searchSortWithSimple:(NSString*)searchString Page:(int)pNo Lan:(int)LanMode Delegate:(id)d sort:(int)sort
{
    if (self.httpRequestSearchSort != nil) {
        [self.httpRequestSearchSort cancel];
    }
    return [imdSearcher simpleSearch:searchString Page:pNo Lan:LanMode Delegate:d sort:sort];
}

-(ASIHTTPRequest*)searchSortWithAdvanceForCN:(NSString*)startField QueryItems:(NSString*)items Option:(NSString*)optionList Page:(int)page Lan:(int)LanMode minYear:(NSString*)miny maxYear:(NSString*)maxy sort:(NSString*)sort coreJournal:(BOOL)isCoreJournal Delegate:(id)d
{
    if (self.httpRequestSearchSort != nil) {
        [self.httpRequestSearchSort cancel];
    }
    return [imdSearcher advacedSearch:startField QueryItems:items Option:optionList Page:page Lan:LanMode minYear:miny maxYear:maxy sort:sort coreJournal:isCoreJournal Delegate:d];
}

-(ASIHTTPRequest*)searchSortWithAdvanceForEN:(NSString*)startField QueryItems:(NSString *)items Option:(NSString *)optionList Page:(int)page Lan:(int)LanMode minYear:(NSString *)miny maxYear:(NSString *)maxy sort:(NSString *)sort sci:(BOOL)isSci reviews:(BOOL)isReviews Delegate:(id)d
{
    if (self.httpRequestSearchSort != nil) {
        [self.httpRequestSearchSort cancel];
    }
    return [imdSearcher advacedSearch:startField QueryItems:items Option:optionList Page:page Lan:LanMode minYear:miny maxYear:maxy sort:sort sci:isSci reviews:isReviews Delegate:d];
}

-(void)cancelSearchHttpRequests
{
    if (self.httpRequestSearchAddFavoritedoc != nil) {
        [self.httpRequestSearchAddFavoritedoc cancel];
        self.httpRequestSearchAddFavoritedoc = nil;
    }
    if (self.httpRequestSearchAskforDoc != nil) {
        [self.httpRequestSearchAskforDoc cancel];
        self.httpRequestSearchAskforDoc = nil;
    }
    if (self.httpRequestSearchDetail != nil) {
        [self.httpRequestSearchDetail cancel];
        self.httpRequestSearchDetail = nil;
    }
    if (self.httpRequestSearchDownloadDoc != nil) {
        [self.httpRequestSearchDownloadDoc cancel];
        self.httpRequestSearchDownloadDoc = nil;
    }
    if (self.httpRequestSearchGetUserStatus != nil) {
        [self.httpRequestSearchGetUserStatus cancel];
        self.httpRequestSearchGetUserStatus = nil;
    }
    if (self.httpRequestSearchRemoveFavoritedoc != nil) {
        [self.httpRequestSearchRemoveFavoritedoc cancel];
        self.httpRequestSearchRemoveFavoritedoc = nil;
    }
    if (self.httpRequestSearchResultSimpleSearch != nil) {
        [self.httpRequestSearchResultSimpleSearch cancel];
        self.httpRequestSearchResultSimpleSearch = nil;
    }
    if (self.httpRequestSearchSimpleSearch != nil) {
        [self.httpRequestSearchSimpleSearch cancel];
        self.httpRequestSearchSimpleSearch = nil;
    }
    if (self.httpRequestSearchSimpleSuggestion != nil) {
        [self.httpRequestSearchSimpleSuggestion cancel];
        self.httpRequestSearchSimpleSuggestion = nil;
    }
    if (self.httpRequestSearchSort != nil) {
        [self.httpRequestSearchSort cancel];
        self.httpRequestSearchSort = nil;
    }
}

-(ASIHTTPRequest*)favoritesAskforDoc:(NSString *)externalId fileTitle:(NSString *)title rawTitle:(NSString *)rawtitle item:(NSDictionary*)result
{
    if (self.httpRequestFavoritesAskforDoc != nil) {
        [self.httpRequestFavoritesAskforDoc cancel];
    }
    return [self askforDoc:externalId fileTitle:title rawTitle:rawtitle item:result];
}

-(ASIHTTPRequest*)favoritesDetail:(NSString *)externalId
{
    if (externalId == nil || externalId.length == 0) {
        return nil;
    }
    if (self.httpRequestFavoritesDetail != nil) {
        [self.httpRequestFavoritesDetail cancel];
    }
    NSString* url = [NSString stringWithFormat:@"http://%@/docsearch/docu/%@/",SEARCH_SERVER, externalId];
    NSLog(@"url =%@",url);
    
    ASIHTTPRequest* request =
    [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",CONFIRM_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_FAVORITE_DETAIL forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    
    request.delegate =self;
    [request startAsynchronous];
    NSLog(@"startAsynchronous");
    
    return request;
    
}

-(ASIHTTPRequest*)favoritesDownloadDoc:(NSString *)fileName filePath:(NSString *)filePath externalId:(NSString *)eId fileTitle:(NSString *)fileTitle
{
    [ImdAppBehavior doDownloadLog:[Util getUsername] MACAddr:[Util getMacAddress] title:fileTitle pageName:PAGE_FAV];
    if (self.httpRequestFavoritesDownloadDoc != nil) {
        [self.httpRequestFavoritesDownloadDoc cancel];
    }
    return [self downloadDoc:fileName filePath:filePath externalId:eId fileTitle:fileTitle];
}

-(ASIHTTPRequest*)favoritesEditDetail:(NSString *)eId
{
    // The method is not used. (zhding) 28-08-2012
    if (eId == nil || eId.length == 0) {
        return nil;
    }
    if (self.httpRequestFavoritesEditDetail != nil) {
        [self.httpRequestFavoritesEditDetail cancel];
    }
    
    NSString* fileURL = [NSString stringWithFormat:@"http://%@/docsearch/doc/%@/",SEARCH_SERVER,eId];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:fileURL]];
    
    NSLog(@"file url =%@",fileURL);
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_FAVORITE_EDIT_DETAIL forKey:@"requestType"];
    
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    return request;
}

-(ASIHTTPRequest*)favoritesGetUserStatus
{
    if (self.httpRequestFavoritesGetUserStatus != nil) {
        [self.httpRequestFavoritesGetUserStatus cancel];
    }
    return [self getUserStatus];
}

-(ASIHTTPRequest*)favoritesRemove:(NSString *)fId
{
    if (fId == nil || fId.length == 0) {
        return nil;
    }
    if (self.httpRequestFavoritesRemove != nil) {
        [self.httpRequestFavoritesRemove cancel];
    }
    return [self removeFavoritedoc:fId];
}

-(ASIHTTPRequest*)favoritesSync
{
    if (self.httpRequestFavoritesSync != nil) {
        [self.httpRequestFavoritesSync cancel];
    }
    NSString* listFavURL =[NSString stringWithFormat:@"http://%@/docsearch/favs",//@"www.qa.i-[md.com"];
                           SEARCH_SERVER];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:listFavURL]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:YES];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_FAVORITE_LIST forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    
    return request;
}

-(void)cancelFavoritesHttpRequests
{
    if (self.httpRequestFavoritesAskforDoc != nil) {
        [self.httpRequestFavoritesAskforDoc cancel];
        self.httpRequestFavoritesAskforDoc = nil;
    }
    if (self.httpRequestFavoritesDetail != nil) {
        [self.httpRequestFavoritesDetail cancel];
        self.httpRequestFavoritesDetail = nil;
    }
    if (self.httpRequestFavoritesDownloadDoc != nil) {
        [self.httpRequestFavoritesDownloadDoc cancel];
        self.httpRequestFavoritesDownloadDoc = nil;
    }
    if (self.httpRequestFavoritesEditDetail != nil) {
        [self.httpRequestFavoritesEditDetail cancel];
        self.httpRequestFavoritesEditDetail = nil;
    }
    if (self.httpRequestFavoritesGetUserStatus != nil) {
        [self.httpRequestFavoritesGetUserStatus cancel];
        self.httpRequestFavoritesGetUserStatus = nil;
    }
    if (self.httpRequestFavoritesRemove != nil) {
        [self.httpRequestFavoritesRemove cancel];
        self.httpRequestFavoritesRemove = nil;
    }
    if (self.httpRequestFavoritesSync != nil) {
        [self.httpRequestFavoritesSync cancel];
        self.httpRequestFavoritesSync = nil;
    }
}

-(ASIHTTPRequest*)locationAddFavoriteDoc:(NSString *)externalId fileTitle:(NSString *)title
{
    if (externalId == nil || externalId.length == 0 ||
        title == nil || title.length == 0) {
        return nil;
    }
    if (self.httpRequestLocationAddFavoriteDoc != nil) {
        [self.httpRequestLocationAddFavoriteDoc cancel];
    }
    return [self addFavoriteDoc:externalId fileTitle:title];
}

-(ASIHTTPRequest*)locationAskSync:(NSString *)limit
{
    if (self.httpRequestLocationAskSync != nil) {
        [self.httpRequestLocationAskSync cancel];
    }
    NSString* url = [NSString stringWithFormat:@"http://%@/docsearch/askforlist?status=%@&start=%d&limit=%d", SEARCH_SERVER,  limit, 0, 1000];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSLog(@"ask url =%@",url);
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    if ([limit isEqualToString:@"true"]) {
        [userInfo setObject:HTTP_REQUEST_ASK_FOR_SYNC_LIST forKey:@"requestType"];
    } else {
        [userInfo setObject:HTTP_REQUEST_ASKING_SYNC_LIST forKey:@"requestType"];
    }
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    
    return request;
}

-(ASIHTTPRequest*)locationDetail:(NSString *)eId
{
    // The Methode is not used. (zhding) 28-08-2012
    if (eId == nil || eId.length == 0) {
        return nil;
    }
    if (self.httpRequestLocationDetail != nil) {
        [self.httpRequestLocationDetail cancel];
    }
    NSString* fileURL = [NSString stringWithFormat:@"http://%@/docsearch/doc/%@/",SEARCH_SERVER,eId];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:fileURL]];
    
    NSLog(@"file url =%@",fileURL);
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_LOCATION_DETAIL forKey:@"requestType"];
    
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    return request;
}

-(ASIHTTPRequest*)locationDownloadDoc:(NSString *)fileName filePath:(NSString *)filePath externalId:(NSString *)eId fileTitle:(NSString *)fileTitle
{
    if (!self.downFileListView.hidden) {
        [ImdAppBehavior doDownloadLog:[Util getUsername] MACAddr:[Util getMacAddress] title:fileTitle pageName:PAGE_LOCA];
    } else if (!self.downRequestListView.hidden) {
        [ImdAppBehavior doDownloadLog:[Util getUsername] MACAddr:[Util getMacAddress] title:fileTitle pageName:PAGE_ASKING];
    } else if (!self.downAskSuccessListView.hidden) {
        [ImdAppBehavior doDownloadLog:[Util getUsername] MACAddr:[Util getMacAddress] title:fileTitle pageName:PAGE_ASKED];
    }
    if (self.httpRequestLocationDownloadDoc != nil) {
        [self.httpRequestLocationDownloadDoc cancel];
    }
    return [self downloadDoc:fileName filePath:filePath externalId:eId fileTitle:fileTitle];
}

-(ASIHTTPRequest*)locationEditDetail:(NSString *)eId
{
    // The Method is not used. (zhding) 28-08-2012
    if (eId == nil || eId.length == 0) {
        return nil;
    }
    if (self.httpRequestLocationEditDetail != nil) {
        [self.httpRequestLocationEditDetail cancel];
    }
    NSString* fileURL = [NSString stringWithFormat:@"http://%@/docsearch/doc/%@/",SEARCH_SERVER,eId];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:fileURL]];
    
    NSLog(@"file url =%@",fileURL);
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_LOCATION_EDIT_DETAIL forKey:@"requestType"];
    
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    return request;
}

-(ASIHTTPRequest*)locationGetUserStatus
{
    if (self.httpRequestLocationGetUserStatus != nil) {
        [self.httpRequestLocationGetUserStatus cancel];
    }
    return [self getUserStatus];
}

-(ASIHTTPRequest*)locationRemoveFavoriteDoc:(NSString *)fId
{
    if (fId == nil || fId.length == 0) {
        return nil;
    }
    if (self.httpRequestLocationRemoveFavoriteDoc != nil) {
        [self.httpRequestLocationRemoveFavoriteDoc cancel];
    }
    return [self removeFavoritedoc:fId];
}

-(void)cancelLocationHttpRequests
{
    if (self.httpRequestLocationAddFavoriteDoc != nil) {
        [self.httpRequestLocationAddFavoriteDoc cancel];
        self.httpRequestLocationAddFavoriteDoc = nil;
    }
    if (self.httpRequestLocationAskSync != nil) {
        [self.httpRequestLocationAskSync cancel];
        self.httpRequestLocationAskSync = nil;
    }
    if (self.httpRequestLocationDetail != nil) {
        [self.httpRequestLocationDetail cancel];
        self.httpRequestLocationDetail = nil;
    }
    if (self.httpRequestLocationDownloadDoc != nil) {
        [self.httpRequestLocationDownloadDoc cancel];
        self.httpRequestLocationDownloadDoc = nil;
    }
    if (self.httpRequestLocationEditDetail != nil) {
        [self.httpRequestLocationEditDetail cancel];
        self.httpRequestLocationEditDetail = nil;
    }
    if (self.httpRequestLocationGetUserStatus != nil) {
        [self.httpRequestLocationGetUserStatus cancel];
        self.httpRequestLocationGetUserStatus = nil;
    }
    if (self.httpRequestLocationRemoveFavoriteDoc != nil) {
        [self.httpRequestLocationRemoveFavoriteDoc cancel];
        self.httpRequestLocationRemoveFavoriteDoc = nil;
    }
}

-(void)searchRequestFinished:(ASIHTTPRequest*)request
{
    if (currentActionSelected != SIDEACTION_SEARCH) {
        // 不在search页面
        isSort = false;
    }
    
    NSData * responseData =[request rawResponseData];
    NSString* responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    // Use when fetching binary data
    //NSLog(@"ok %@",responseString);
    BOOL hasError = NO;
    
    NSDictionary* info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 )
    {
        // 没有返回数据
        info =nil;
        hasError = YES;
        isSort = false;
    }
    else
    {
        // json解析
        info =[responseString JSONValue];
    }
    
    if(info != nil)
    {
        // 有效json数据
        NSLog(@"get result %d",[info count]);
        
        // set language
        currentResultLanguage =currentSearchLanguage;
        
        NSLog(@"newSearchStart %d",newSearchStart);
        
        // reset display results
        displayState = DISPLAY_STATE_RESULTS;
        [self displayStates];
        
        // newSearchStart == 0 doSearch; 1 doNext
        if(newSearchStart)
        {
            if(self.searchedResult !=nil)
            {
                // clear result data
                self.searchedResult =nil;
                self.resultReadingStatus =nil;
            }
            
            self.searchedResult = info;
            self.resultReadingStatus = [NSMutableArray arrayWithCapacity:60];
            
            //set new count readingstatus
            NSArray* results =[info objectForKey:@"results"];
            for(int i =0;i<[results count];i++)
            {
                [self.resultReadingStatus addObject:[NSNumber numberWithBool:NO]];
            }
            currentDisplayingRow =0;
            currentDisplayingSection =0;
        }
        else // do Next
        {
            if (self.searchedResult != nil)
            {
                NSArray* results =[info objectForKey:@"results"];
                if(results == (id)[NSNull null] || [results count] ==0)
                {
                    // it's bug
                    NSLog(@"info error");
                }
                else
                {
                    // add new results to old results list.
                    int count = [results count];
                    NSMutableArray* oldResults =[[self.searchedResult objectForKey:@"results"] mutableCopy];
                    NSLog(@"old result %d",[oldResults count]);
                    
                    for(int i=0;i<count;i++)
                    {
                        [oldResults addObject:[results objectAtIndex:i]];
                    }
                    
                    NSLog(@"now result %d",[oldResults count]);
                    
                    [self.searchedResult setValue:oldResults forKey:@"results"];
                    //set new count readingstatus
                    for(int i =0;i<count;i++)
                    {
                        [self.resultReadingStatus addObject:[NSNumber numberWithBool:NO]];
                    }
                }
            }
            else // searchedResult == nil
            {
                self.searchedResult = info;
            }
        }
        
        resultsCount = [[self.searchedResult valueForKey:@"resultCount"] intValue];
        
        NSLog(@"result count %d",resultsCount);
        
        NSArray* results =[self.searchedResult objectForKey:@"results"];
        
        
        displayCount = [results count];
        
        self.searchResultCoverView.hidden = YES;
        self.loadingView.hidden =YES;
        
        [self calculatePages];
        
        //    currentDisplayingRow =0;
        //    currentDisplayingSection =0;
        [self.searchResultList reloadData];
        if (displayCount > 0) {
            [self displaySearchDetail];
        } else {
            self.searchResultCoverView.hidden = NO;
        }
        NSLog(@"load ok");
        
        if (isSort) {
            NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.searchResultList scrollToRowAtIndexPath:topIndexPath atScrollPosition:
             UITableViewScrollPositionTop animated:YES];
            isSort = false;
        }
    }
    else
    {
        hasError = YES;
        isSort = false;
    }
    
    if(hasError)
    {
        NSLog(@"sth wrong.");
        [self showCoverBgWithErrorMsg:@"检索出错,请稍候重试"];
    }
}

-(void)displaySearchDetail
{
    [self showCoverBgWithLoading:true];
    NSArray* rs = [self.searchedResult objectForKey:@"results"];
    NSDictionary* result = [rs objectAtIndex:currentDisplayingRow];
    NSString* eId = [result objectForKey:@"externalId"];
    NSString* fileTitle =[result objectForKey:@"title"];
    
    
    [self showDetail:eId];
    
    //    [ShowDailog showMsgOk:[exception name] msg:[exception description]];
    
    
    
    [ImdAppBehavior detailLog:[Util getUsername] MACAddr:[Util getMacAddress] title:fileTitle pageName:PAGE_SEARCH];
    
    //  self.httpRequestSearchDetail = [self searchDetail:eId];
}

-(void)searchDetailRequestFinished:(ASIHTTPRequest *)request
{
    [self showBigCoverBgWithLoading:false];
    if (currentActionSelected != SIDEACTION_SEARCH) {
        // 不在search页面
        return;
    }
    NSData * responseData =[request rawResponseData];
    NSString* responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    // Use when fetching binary data
    //NSLog(@"ok %@",responseString);
    BOOL hasError = NO;
    
    NSMutableDictionary* info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 )
    {
        // 没有返回数据
        info =nil;
        hasError = YES;
    }
    else
    {
        // json解析
        info =[responseString JSONValue];
    }
    //  NSMutableDictionary *doc = [info copy];
    [self searchDetailCopy:info];
}

-(void)searchDetailCopy:(NSMutableDictionary *)info
{
    if (info != nil) {
        self.detailSearch = [info copy];
        detailIsFav = [[self.detailSearch objectForKey:@"isFav"] intValue];
        [self displayDetails];
        currentFavAction = FAV_NONE;
    }
}

-(void)favoriteListRequestFinished:(ASIHTTPRequest *)request
{
    [self showBigCoverBgWithLoading:false];
    NSString* responseString =[request responseString];
    processingFav =NO;
    
    NSLog(@"ok %@",responseString);
    BOOL hasError = NO;
    NSLog(@"test 1");
    NSDictionary* info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 )
    {
        info =nil;
        hasError = YES;
    }
    else
    {
        info =[responseString JSONValue];
    }
    NSLog(@"test 2");
    if(info != nil)
    {
        if (isFirstFav) {
            isFirstFav = false;
        }
        [favView stopLoading];
        
        
        NSLog(@"get result %@",info);
        self.favArrays =nil;
        self.favArrays = [info objectForKey:@"favs"];
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (int i=0; i<[self.favArrays count]; i++) {
            [tempArray addObject:[self.favArrays objectAtIndex:[self.favArrays count]-i-1]];
        }
        [myDatabaseOption favsSave:tempArray];
        
        NSLog(@"fav array %@",favArrays);
        [self showFavs];
        
        NSLog(@"test 8");
    }
    else
    {
        hasError = YES;
    }
    
    if(hasError)
    {
        NSLog(@"sth wrong.");
    }
}

-(void)showFavs
{
    if(currentActionSelected == SIDEACTION_FAVORITE)
    {
        NSLog(@"test 3");
        [self.favList reloadData];
        [self.favList setEditing:NO animated:NO];
        
        [self.favEditButton setTitle:@"编辑" forState:UIControlStateNormal];
        NSLog(@"test 4");
        if([self.favArrays count]==0)
        {
            NSLog(@"test 5");
            [self showBigCoverBgWithLoading:false];
            self.favEditButton.hidden=YES;
        }
        else
        {
            NSLog(@"test 6");
            self.favEditButton.hidden=NO;
            [self loadFavDetail];
            
            currentResultInFavorite =YES;
            
            if(currentFavAction == FAV_ADDING)
            {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已添加到收藏夹！"];
            }
            else if(currentFavAction == FAV_REMOVING)
            {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已从收藏夹移除！"];
            }
            
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-selected"] forState:UIControlStateNormal];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-hightlight"] forState:UIControlStateHighlighted];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-hightlight"] forState:UIControlStateSelected];
        }
        currentFavAction = FAV_NONE;
        NSLog(@"test 7");
    }
}

-(void)favoriteDetailRequestFinished:(ASIHTTPRequest *)request
{
    [self showCoverBgWithLoading:NO];
    NSString* responseString =[request responseString];
    
    NSDictionary* info;
    if (responseString ==(id)[NSNull null] || responseString.length ==0 )
    {
        info =nil;
        [self showCoverBgWithErrorMsg:@"收藏数据查询错误，请稍后重试。"];
        return;
    }
    else
    {
        info =[responseString JSONValue];
    }
    
    if(info != nil)
    {
        [myDatabaseOption docuSave:[info copy]];
        self.favDetail =nil;
        self.favDetail =[info copy];
        
        [self displayDetails];
    }
}

-(void)removeFavAction:(ASIHTTPRequest *)request
{
    NSDictionary* requestInfo =[request userInfo];
    NSString* eId =[requestInfo objectForKey:@"externalId"];
    if (currentActionSelected == SIDEACTION_SEARCH) {
        [self searchRemoveFav:eId];
        detailIsFav = false;
        [self displayDetails];
        return;
    }
    
    if (currentActionSelected == SIDEACTION_DOWNLOADED) {
        [self downRemoveFav:eId];
        detailIsFav = false;
        [self displayDetails];
        return;
    }
    //if(currentActionSelected == SIDEACTION_FAVORITE)
    {
        [self favoRemoveFav:eId];
        currentDisplayingRow =0;
        currentDisplayingSection = 0;
        
        processingFav =NO;
        
        if([self.favArrays count] ==1)
        {
            self.favArrays =nil;
            [self.favList reloadData];
            
            if(currentActionSelected == SIDEACTION_FAVORITE)
                [self showCoverBgWithLoading:NO];
        }
        else
        {
            NSLog(@"fav array before del %@",self.favArrays);
            
            int c=[self.favArrays count];
            for(int i =0;i<c;i++)
            {
                NSDictionary* m =[self.favArrays objectAtIndex:i];
                NSString *mId = [m objectForKey:KEY_DOC_EXTERNALID];
                if([eId isEqualToString:mId])
                {
                    NSLog(@"eId === %@",eId);
                    if ([self.favArrays count]) {
                        [self.favArrays removeObject:m];
                        break;
                    }
                }
            }
        }
        
        NSLog(@"after del fav array %@",self.favArrays);
        
        if(currentActionSelected == SIDEACTION_FAVORITE)
        {
            currentResultInFavorite =YES;
            [self.favList reloadData];
            [self.favList setEditing:NO animated:NO];
            [self loadFavDetail];
        }
        else
            currentResultInFavorite =NO;
        
        currentFavAction = FAV_NONE;
        
        if(currentResultInFavorite)
        {
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-selected"] forState:UIControlStateNormal];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-highlight"] forState:UIControlStateHighlighted];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-highlight"] forState:UIControlStateSelected];
        }
        else
        {
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-normal"] forState:UIControlStateNormal];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-highlight"] forState:UIControlStateHighlighted];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-highlight"] forState:UIControlStateSelected];
        }
        
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已从收藏夹移除！"];
    }
    
}

-(void)locationIsFavRequstFinished:(ASIHTTPRequest *)request
{
    NSLog(@"is fav %@", [request responseString]);
    if ([[request responseString] isEqualToString:@"true"]) {
        detailIsFav = true;
    } else {
        detailIsFav = false;
    }
    [self displayDetails];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@",[request responseString]);
    NSDictionary *requestInfo =[request userInfo];
    NSString *rType = [requestInfo objectForKey:@"requestType"];
    //请求加进去
    NSLog(@"request finished rtype =%@",rType);
    
    if ([rType isEqualToString:@"userActiver"]) {
        NSLog(@"response:%@", [request responseString]);
        NSDictionary *resultsJson = [UrlRequest getJsonValue:request];
        int ec = [[resultsJson objectForKey:@"emailActive"] intValue];
        int mc = [[resultsJson objectForKey:@"mobileActive"] intValue];
        NSLog(@"mc = %i & ec = %i", mc, ec);
        if (mc == 1 && ec == 1) {
            [self showToUpperLimitAlert];
        } else {
            if (mc == 1) {
                [[NSUserDefaults standardUserDefaults] setValue:@"true" forKey:SaveMobileConfirmState];
            } else {
                [[NSUserDefaults standardUserDefaults] setValue:@"false" forKey:SaveMobileConfirmState];
            }
            if (ec == 1) {
                [[NSUserDefaults standardUserDefaults] setValue:@"true" forKey:SaveEmailConfirmState];
            } else {
                [[NSUserDefaults standardUserDefaults] setValue:@"false" forKey:SaveEmailConfirmState];
            }
        }
    } else if([rType isEqualToString:HTTP_REQUEST_DO_SEARCH]) {
        self.httpRequestSearchSimpleSearch = nil;
        [self searchRequestFinished:request];
    } else if([rType isEqualToString:HTTP_REQUEST_SIMPLE_SUGGESTION]) {
        self.httpRequestSearchSimpleSuggestion = nil;
        if(displayState == DISPLAY_STATE_SUGGESTION)
        {
            NSString* responseString=[request responseString];
            NSLog(@"ok %@",responseString);
            BOOL hasError = NO;
            responseString = [responseString stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
            
            NSMutableArray* info;
            if (responseString ==(id)[NSNull null] || responseString.length ==0 )
            {
                info =nil;
                hasError = YES;
            } else {
                info =[responseString JSONValue];
            }
            
            if(hasError)
            {
                NSLog(@"sth wrong with json");
            } else if(info != nil) {
                suggestionArrays = info;
                suggestionCount =[suggestionArrays count];
                currentSelectedSuggestion = -1;
                [self.searchResultList reloadData];
            }
        }
    } else if([rType isEqualToString:HTTP_REQUEST_SEARCH_DETAIL]) {
        self.httpRequestSearchDetail = nil;
        NSString* str = [request responseString];
        NSLog(@"detail === %@", str);
        [self searchDetailRequestFinished:request];
    } else if([rType isEqualToString:@"requestPDF"]) {
        NSString* s =[request responseString];
        NSLog(@"rs= %@",s);
        
        if(s!= nil && [Util isHtml:s])
        {
            //self.PDFErrorLabel.hidden = NO;
            NSLog(@"html or bad response");
            [self hideMsgBar];
            [self showCoverBgWithErrorMsg:@"文件出错，请稍后重试"];
            
            NSString* filePath = [requestInfo objectForKey:@"downloadPath"];
            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
            {
                //TODO: Handle/Log error
                NSLog(@"del failed %@",error);
            }
            [self enabledSwitchButton];  // DZH
            return;
        } else {
            NSLog(@"loading pdf");
            NSString* fileName = [requestInfo objectForKey:@"downloadFile"];
            NSString* fileTitle = [requestInfo objectForKey:@"downloadTitle"];
            NSString* filePath =[requestInfo objectForKey:@"downloadPath"];
            
            fullViewController* fVC =[[fullViewController alloc] initWithNibName:@"fullViewController" bundle:nil];
            fVC.currentPdfName =fileName;
            fVC.currentPdfTitle =fileTitle;
            
            //bug happens here
            //debug mode loadPDFTest different from release mode
            BOOL pdfFailed =NO;
            
            NSString* response =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
            
            NSLog(@"got response %@",response);
            if([response isEqualToString:@"MAXVALUE"])
            {
                [self showToUpperLimitAlert];
                return;
            } else if([response isEqualToString:@"FAIL"]) {
                [self showMsgBarWithInfo:DOWNLOAD_DOC_FAILED];
                pdfFailed =YES;
            } else if([response isEqualToString:@"QUEUE"]) {
                [self showMsgBarWithInfo:DOWNLOAD_DOC_QUEUE];
            }else if ([response isEqualToString:@"INACTIVE"]) {
                UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的帐号尚未激活，暂无法获取文献全文，请先激活手机或邮箱。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"前去激活",nil];
                alertE.tag = 5;
                [alertE show];
                pdfFailed =YES;
                [self hideMsgBar];
            }else if ([response isEqualToString:@"UNVERIFIED"]) {
                NSString *name = [Util getUsername];
                NSString *isOk = [[NSUserDefaults standardUserDefaults] objectForKey:name];
                pdfFailed =YES;
                [self hideMsgBar];
                if ([isOk isEqualToString:@"0"]) {
                    UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的身份尚未通过实名验证，请先收藏文献。验证后即可免费获取全文。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"完善帐号信息",nil];
                    alertE.tag = 7;
                    [alertE show];
                }else if([isOk isEqualToString:@"1"])
                {
                    UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的身份验证已经提交,我们将在两个工作日内完成验证。身份验证通过后即可免费获取全文。您可先收藏此文献。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"重新修改", nil];
                    alertE.tag = 6;
                    [alertE show];
                }
            } else {
                NSLog(@"res =%@",response);
                if(response ==nil)
                    pdfFailed =NO;
                else {
                    pdfFailed =YES;
                }
            }
            
            if(pdfFailed)
            {
                NSError *error;
                if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
                {
                    //TODO: Handle/Log error
                    NSLog(@"del failed %@",error);
                }
                else
                {
                    NSLog(@"delete ok");
                }
                
            }
            else {
                if(currentDisplayingRow!= barLoadingRow||currentActionSelected!=barLoadingAction)
                {
                    NSLog(@"not same %d %d",barLoadingRow,barLoadingAction);
                    [self hideMsgBar];
                } else {
                    [self hideMsgBar];
                    self.fullTextController =fVC;
                    [self.fullTextController setViewDelegate:self];
                    [self presentViewController:self.fullTextController animated:YES completion:nil];
                    
                    fullTextIsShow = YES;
                }
            }
            
        }
        [self enabledSwitchButton];  // DZH
    }
    else if([rType isEqualToString:HTTP_REQUEST_FAVORITE_LIST])
    {
        self.httpRequestFavoritesSync = nil;
        NSLog(@"list ok %@",[request responseString]);
        [self favoriteListRequestFinished:request];
    }
    else if([rType isEqualToString:HTTP_REQUEST_LOCATION_IS_FAV])
    {
        [self locationIsFavRequstFinished:request];
    }
    else if([rType isEqualToString:@"removeFav"])
    {
        NSLog(@"remove fav %@",[request responseString]);
        currentFavAction = FAV_REMOVING;
        [self showBigCoverBgWithLoading:NO];
        [self removeFavAction:request];
    }
    else if([rType isEqualToString:@"addFav"])
    {
        NSLog(@"add ok %@",[request responseString]);
        //to do:add notification of the work done.
        currentFavAction = FAV_ADDING;
        [self showBigCoverBgWithLoading:NO];
        if (currentActionSelected == SIDEACTION_FAVORITE) {
            [self loadFav];
        } else if (currentActionSelected == SIDEACTION_SEARCH) {
            @try {
                [self searchAddFav];
                detailIsFav = true;
                [self displayDetails];
            }
            @catch (NSException *exception) {
                NSLog(@"exception : %@", exception);
            }
        } else if (currentActionSelected == SIDEACTION_DOWNLOADED) {
            @try {
                [self downAddFav];
                detailIsFav = true;
                [self displayDetails];
            }
            @catch (NSException *exception) {
                NSLog(@"exception : %@", exception);
            }
        }
    }
    else if([rType isEqualToString:@"askFullText"])
    {
        NSLog(@"responseString %@",[request responseString]);
        NSString* responseString =[request responseString];
        
        if([responseString isEqualToString:@"SUCCESS"])
        {
            NSLog(@"ask for 7777");
            //[self showCoverBgWithErrorMsg:@"索取成功,将尽快发送到您的注册邮箱"];
            NSString* email =
            [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
            [self hideMsgBar];
            NSString* externalId =[requestInfo objectForKey:@"askingId"];
            if ([Strings phoneNumberJudge:email]) {
                UIAlertView* myAlert = [[UIAlertView alloc] initWithTitle:@"索取请求发送成功" message:@"文献全文将在两个工作日内发送到您的“本地文献”，请注意查看“已索取“" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"立即查看", nil];
                jumpExternalId = externalId;
                [myAlert show];
            }else
            {
                UIAlertView* myAlert = [[UIAlertView alloc] initWithTitle:@"索取请求发送成功" message:[NSString stringWithFormat:@"请求发送成功, 文献将在两个工作日内发到您的注册邮箱,请注意查收\n%@", email] delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"立即查看", nil];
                jumpExternalId = externalId;
                [myAlert show];
            }
            NSLog(@"asking info %@",requestInfo);
            NSString* title =[requestInfo objectForKey:@"askingTitle"];
            NSString* item =[requestInfo objectForKey:@"item"];
            
            
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:10];
            
            [dict setObject:externalId forKey:@"externalId"];
            [dict setObject:title forKey:@"fileTitle"];
            
            [dict setObject:ASKFULLTEXT_STATE_ASKFINISHED forKey:@"status"];
            //[dict setObject:ASKFULLTEXT_STATE_DOWNLOADABLE forKey:@"status"];
            
            [dict setObject:item forKey:@"item"];
            
            [self disabledSwitchButton];
            [self askfullSuccess];
            
        }
        else if([responseString isEqualToString:@"MAXVALUE"])
        {
            [self showToUpperLimitAlert];
        }else if ([responseString isEqualToString:@"INACTIVE"]) {
            UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的帐号尚未激活，暂无法获取文献全文，请先激活手机或邮箱。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"前去激活",nil];
            alertE.tag = 5;
            [alertE show];
            [self hideMsgBar];
        }else if ([responseString isEqualToString:@"UNVERIFIED"])
        {
            NSString *name = [Util getUsername];
            NSString *isOk = [[NSUserDefaults standardUserDefaults] objectForKey:name];
            [self hideMsgBar];
            if ([isOk isEqualToString:@"0"]) {
                UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的身份尚未通过实名验证，请先收藏文献。验证后即可免费获取全文。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"完善帐号信息",nil];
                alertE.tag = 7;
                [alertE show];
            }else if([isOk isEqualToString:@"1"])
            {
                UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的身份验证已经提交,我们将在两个工作日内完成验证。身份验证通过后即可免费获取全文。您可先收藏此文献。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"重新修改", nil];
                alertE.tag = 6;
                [alertE show];
            }
        }
        else
        {
            //error
            [self showMsgBarWithInfo:ASKFOR_DOC_FAILED];
            //[self enabledSwitchButton];
            
        }
        // DZH
        
    }
    else if([rType isEqualToString:HTTP_REQUEST_JUMP_ASK_CHECK_STATUES])
    {
        BOOL hasError = NO;
        NSLog(@"ask for status %@",[request responseString]);
        
        NSString* responseString =[request responseString];
        
        NSDictionary* info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 )
        {
            info =nil;
            hasError = YES;
        }
        else
        {
            info =[responseString JSONValue];
        }
        
        if(info != nil)
        {
            NSArray* array =[info objectForKey:@"statusList"];
            NSLog(@"array %@",array);
            
            NSDictionary* dict =[array objectAtIndex:0];
            
            NSString* status =[dict objectForKey:@"status"];
            
            NSLog(@"status %@",status);
            
            if([status isEqualToString:@"SUCCESS"])
            {
                locationTabBarStatus = LOCATION_TAB_BAR_ASK_SUCCESS;
                [self sideActionPressed:self.sideActionDownloadedButton];
                [self askSuccessButtonTapped:nil];
            }
            else if([status isEqualToString:@"FAIL"])
            {
                [self showMsgBarWithInfo:@"索取的文献失败，请稍后重试。"];
            }
            else  if([status isEqualToString:@"WAITING"])
            {
                locationTabBarStatus = LOCATION_TAB_BAR_ASKING;
                [self sideActionPressed:self.sideActionDownloadedButton];
                [self askingButtonTapped:nil];
            }
            else  if([status isEqualToString:@"MAXVALUE"])
            {
                locationTabBarStatus = LOCATION_TAB_BAR_HAS_SAVED;
                [self sideActionPressed:self.sideActionDownloadedButton];
                [self hasSavedButtonTapped:nil];
            }
            else
            {
                locationTabBarStatus = LOCATION_TAB_BAR_HAS_SAVED;
                [self sideActionPressed:self.sideActionDownloadedButton];
                [self hasSavedButtonTapped:nil];
            }
        }
        
        if(hasError)
        {
            
            [self showMsgBarWithInfo:@"索取状态出错，请稍后重试。"];
            
        }
        [self enabledSwitchButton];  // DZH
    }
    else if([rType isEqualToString:@"askforStatus"])
    {
        
        BOOL hasError = NO;
        NSLog(@"ask for status %@",[request responseString]);
        
        NSString* responseString =[request responseString];
        
        NSDictionary* info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 )
        {
            info =nil;
            hasError = YES;
        }
        else
        {
            info =[responseString JSONValue];
        }
        
        if(info != nil)
        {
            NSArray* array =[info objectForKey:@"statusList"];
            NSLog(@"array %@",array);
            
            NSDictionary* dict =[array objectAtIndex:0];
            
            NSString* status =[dict objectForKey:@"status"];
            
            NSLog(@"status %@",status);
            
            if([status isEqualToString:@"SUCCESS"])
            {
                
                NSString* externalId =[dict objectForKey:@"externalId"];
                NSString* internalId =[dict objectForKey:@"internalId"];
                NSString* title =[requestInfo objectForKey:@"fileTitle"];
                
                //[self showCoverBgWithErrorMsg:@"索取的文献已成功，可以下载。"];
                
                for (int i=0; i<[self.requestArrays count]; i++)
                {
                    NSMutableDictionary* item =[[self.requestArrays objectAtIndex:i] mutableCopy];
                    
                    if([externalId isEqualToString:[item objectForKey:@"externalId"]])
                    {
                        [item setObject:ASKFULLTEXT_STATE_DOWNLOADABLE forKey:@"status"];
                        [item setObject:internalId forKey:@"internalId"];
                        //[item setObject:title forKey:@"fileTitle"];
                        
                        [self.requestArrays replaceObjectAtIndex:i withObject:item];
                        break;
                    }
                    
                    
                }
                
                [self showMsgBarWithLoading:@"正在为您获取全文..."];
                NSString* fn = [self fileNameWithExternelId:externalId];
                NSString* fp = [self filePathInCache:fn];
                
                [self downloadAskPDFwithExternalId:externalId andInternalId:internalId displayFullText:YES title:title filePath:fp fileName:fn];
                
                
                
                
                
                [[NSUserDefaults standardUserDefaults] setObject:self.requestArrays forKey:@"requestArrays"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self updateRequestDown];
                //NSLog(@"request arrays %@",self.requestArrays);
                
            }
            else if([status isEqualToString:@"FAIL"])
            {
                [self showMsgBarWithInfo:@"索取的文献失败，请稍后重试。"];
            }
            else  if([status isEqualToString:@"WAITING"])
            {
                [self showMsgBarWithInfo:@"索取的文献还在准备中，请稍后重试。"];
            }
            else  if([status isEqualToString:@"MAXVALUE"])
            {
                [self showMsgBarWithInfo:@"索取的文献还在准备中，请稍后重试。"];
            }
            
            else
            {
                [self showMsgBarWithInfo:@"索取的文献状态未知，请稍后重试。"];
                
            }
        }
        
        if(hasError)
        {
            
            [self showMsgBarWithInfo:@"索取状态出错，请稍后重试。"];
            
        }
        [self enabledSwitchButton];  // DZH
    }
    else if([rType isEqualToString:@"askforReqArray"])
    {
        
        BOOL hasError = NO;
        NSLog(@"ask for list status %@",[request responseString]);
        
        NSString* responseString =[request responseString];
        
        NSDictionary* info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 )
        {
            info =nil;
            hasError = YES;
        }
        else
        {
            info =[responseString JSONValue];
        }
        
        if(info != nil)
        {
            NSLog(@"got array %@",info);
        }
        
        if(hasError)
        {
            NSLog(@"list down status error");
        }
    } else if([rType isEqualToString:HTTP_REQUEST_ASKING_SYNC_LIST]) {
        [self showAskingLoading:NO];
        NSLog(@"ask for sync list %@",[request responseString]);
        NSString* responseString = [request responseString];
        
        NSDictionary* info;
        if (responseString == (id)[NSNull null] || responseString.length == 0) {
            info = nil;
        } else {
            info = [responseString JSONValue];
        }
        
        self.requestDownArrays = nil;
        if (info != nil) {
            NSLog(@"full list %@",info);
            
            NSArray* array = [info objectForKey:@"askforList"];
            NSMutableArray* newArray = [[NSMutableArray alloc]init ];
            if ([array count]) {
                for (int i = 0; i < [array count]; i++) {
                    NSMutableDictionary *doc = [array objectAtIndex:i];
                    NSMutableDictionary *dInfo = [doc objectForKey:@"shortDocInfo"];
                    NSString *iid = [dInfo objectForKey:KEY_DOC_ID];
                    if (![iid isEqualToString:@"(null)"]) {
                        [newArray addObject:doc];
                    }
                }
            }
            self.requestDownArrays = [newArray copy];
        }
        
        [self updateRequestDown];
        
        [self.requestList reloadData];
    } else if([rType isEqualToString:HTTP_REQUEST_ASK_FOR_SYNC_LIST]) {
        [self showAskSuccessLoading:NO];
        NSLog(@"ask for sync list %@",[request responseString]);
        NSString* responseString = [request responseString];
        
        NSDictionary* info;
        if (responseString == (id)[NSNull null] || responseString.length == 0) {
            info = nil;
        } else {
            info = [responseString JSONValue];
        }
        
        if (info != nil) {
            NSLog(@"full list %@",info);
            
            NSArray* array = [info objectForKey:@"askforList"];
            NSMutableArray* newArray = [[NSMutableArray alloc]init ];
            if ([array count]) {
                for (int i = 0; i < [array count]; i++) {
                    NSMutableDictionary *doc = [array objectAtIndex:i];
                    NSMutableDictionary *dInfo = [doc objectForKey:@"shortDocInfo"];
                    NSString *iid = [dInfo objectForKey:KEY_DOC_ID];
                    if (![iid isEqualToString:@"(null)"]) {
                        [newArray addObject:doc];
                    }
                }
            }
            
            self.requestArrays = nil;
            self.requestArrays = [newArray copy];
            
            [myDatabaseOption askedSave:self.requestArrays];
            if (isFirstAsked) {
                isFirstAsked = false;
            }
            [askedView stopLoading];
        }
        
        [self updateRequestDown];
        [self.askSuccessList reloadData];
    } else if([rType isEqualToString:@"downAskDetail"]) {
        [self showCoverBgWithLoading:false];
        NSLog(@"down ask detail %@",[request responseString]);
        NSString* responseString = [request responseString];
        
        NSDictionary* info;
        if (responseString == (id)[NSNull null] || responseString.length == 0) {
            info = nil;
        } else {
            info = [responseString JSONValue];
        }
        
        if (info != nil) {
            [myDatabaseOption docuSave:[info copy]];
            self.downAskDetail = [info copy];
            if ([[self.downAskDetail objectForKey:@"isFav"]intValue] == 0) {
                detailIsFav = false;
            } else {
                detailIsFav = true;
            }
        } else {
            self.downAskDetail = nil;
            detailIsFav = false;
        }
        [self displayDetails];
    } else if([rType isEqualToString:@"askforListStatus"]) {
        BOOL hasError = NO;
        NSLog(@"ask for list status %@",[request responseString]);
        
        NSString* responseString =[request responseString];
        
        NSDictionary* info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 )
        {
            info =nil;
            hasError = YES;
        }
        else
        {
            info =[responseString JSONValue];
        }
        
        if(info != nil)
        {
            NSLog(@"full list %@",info);
            NSArray* array =[info objectForKey:@"statusList"];
            
            for(int j=0;j<[array count];j++)
            {
                NSDictionary* dict =[array objectAtIndex:j];
                NSString* externalId =[dict objectForKey:@"externalId"];
                NSString* internalId =[dict objectForKey:@"internalId"];
                
                NSString* status =[dict objectForKey:@"status"];
                
                if([status isEqualToString:@"SUCCESS"]) {
                    for(int i=0;i< [self.requestArrays count];i++)
                    {
                        NSMutableDictionary *item =[[self.requestArrays objectAtIndex:i] mutableCopy];
                        
                        if([externalId isEqualToString:[item objectForKey:@"externalId"]])
                        {
                            NSLog(@"eid %@",externalId);
                            NSLog(@"item = %@",item);
                            
                            [item setObject:ASKFULLTEXT_STATE_DOWNLOADABLE forKey:@"status"];
                            [item setObject:internalId forKey:@"internalId"];
                            
                            [self.requestArrays replaceObjectAtIndex:i withObject:item];
                            break;
                        }
                    }
                } else if(![status isEqualToString:@"WAITING"]) {
                    for(int i=0;i<[self.requestArrays count];i++)
                    {
                        NSDictionary* m =[self.requestArrays objectAtIndex:i];
                        NSMutableDictionary* item =[[m objectForKey:@"item"] mutableCopy];
                        
                        if([externalId isEqualToString:[item objectForKey:@"externalId"]])
                        {
                            [self.requestArrays removeObjectAtIndex:i];
                            break;
                        }
                    }
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:self.requestArrays forKey:@"requestArrays"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self updateRequestDown];
            [self.downList reloadData];
        }
        
        if(hasError)
        {
            NSLog(@"list down status error");
        }
    } else if([rType isEqualToString:HTTP_REQUEST_FAVORITE_DETAIL]) {
        NSLog(@"ask fav detail %@",[request responseString]);
        [self favoriteDetailRequestFinished:request];
    } else if([rType isEqualToString:@"askPDF"]) {
        
        NSString* s =[request responseString];
        NSLog(@"rs= %@",s);
        
        if(s!= nil && [Util isHtml:s])
        {
            NSLog(@"html or bad response");
            
            int count =[self.requestArrays count];
            NSString* eId =[requestInfo objectForKey:@"externalId"];
            
            for(int i=0;i<count;i++)
            {
                NSDictionary* dict = [self.requestArrays objectAtIndex:i];
                NSDictionary* item = [dict objectForKey:@"shortDocInfo"];
                NSString* enterelId = [item objectForKey:@"id"];
                if([eId isEqualToString:enterelId])
                {
                    //          [self.requestArrays removeObjectAtIndex:i];
                    [self addToDownloadArraysWith:[downAskDetail objectForKey:@"article"]];
                    break;
                }
            }
            
            [self showMsgBarWithInfo:@"下载等待中，请稍后重试"];
            
            
            NSString* filePath =[requestInfo objectForKey:@"downloadPath"];
            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
            {
                //TODO: Handle/Log error
                NSLog(@"del failed %@",error);
            }
            [self enabledSwitchButton]; // DZH
            return;
        }
        else
        {
            NSLog(@"loading pdf");
            NSString* fileName = [requestInfo objectForKey:@"downloadFile"];
            NSString* fileTitle = [requestInfo objectForKey:@"downloadTitle"];
            NSString* filePath = [requestInfo objectForKey:@"downloadPath"];
            
            NSLog(@"fileName %@",fileName);
            NSLog(@"fileTitle %@",fileTitle);
            NSLog(@"filePath %@",filePath);
            
            //for debug white screen
            BOOL pdfFailed =NO;
            
            NSString* response =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
            
            //if(![errorResponse isEqualToString:@""])response = errorResponse;
            
            NSLog(@"got response %@",response);
            
            if([response isEqualToString:@"MAXVALUE"])
            {
                isAskfor = false;
                [self checkUserConfirmInfo];
                pdfFailed =YES;
            } else if([response isEqualToString:@"FAIL"]) {
                [self showMsgBarWithInfo:@"对不起，您申请的文献全文未找到。"];
                pdfFailed =YES;
            } else {
                NSLog(@"res =%@",response);
                if(response ==nil)
                    pdfFailed =NO;
                else {
                    pdfFailed =YES;
                }
            }
            
            
          
        }
        [self enabledSwitchButton];
    }
    else if([rType isEqualToString:@"registerNew"])
    {
        NSLog(@"register ok %@",[request responseString]);
        
        BOOL hasError = NO;
        
        NSString* responseString =[request responseString];
        
        NSDictionary* info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 )
        {
            info =nil;
            hasError = YES;
        }
        else
        {
            info =[responseString JSONValue];
        }
        
        if(info != nil)
        {
            int status =[[info objectForKey:@"status"] intValue];
            
            if( status==1)
            {                NSString* uName =[requestInfo objectForKey:@"username"];
                NSString* uPass =[requestInfo objectForKey:@"password"];
                [uName lowercaseString];
                
                imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                
                [[NSUserDefaults standardUserDefaults] setObject:uName forKey:@"savedUser"];
                //todo not save pass
                [[NSUserDefaults standardUserDefaults] setObject:uPass forKey:@"savedPass"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [appDelegate.auth postAuthInfo:nil];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                hasError = YES;
            }
        }
        
        if(hasError)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(BOOL)loadPDFTest:(NSString*)pdfFileName
{
    NSURL* fileURL;
    NSString* filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:pdfFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        filePath = [documentsDirectory stringByAppendingPathComponent:pdfFileName];
    }
    
    fileURL =[NSURL fileURLWithPath:filePath];
    
    PDFViewTiled* thePDFView;
    
    @try
    {
        thePDFView = [[PDFViewTiled alloc] initWithURL:fileURL page:1 password:nil frame:[self.detailView bounds]];
    } @catch(NSException* ex) {
        NSLog(@"Bad pdf");
        errorResponse = @"";
        
        NSString* response =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        errorResponse =response;
        
        NSLog(@"response from pdf test [%@]",response);
        
        //if(showingBarLoading)
        {
            if([response isEqualToString:@"FAIL"]) {
                [self showMsgBarWithInfo:@"对不起，您申请的文献全文未找到。"];
            } else if([response isEqualToString:@"MAXVALUE"]) {
                //                [self showToUpperLimitAlert];
            } else {
                [self showMsgBarWithInfo:@"下载未完成，请稍后重试"];
            }
            
            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
            {
                //TODO: Handle/Log error
                NSLog(@"del failed %@",error);
            } else {
                NSLog(@"del ok");
            }
        }
        return NO;
    }
    
    return YES;
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"isCanceled = %d", (int)[request isCancelled]);
    if ([request isCancelled]) {
        return;
    }
    
    NSLog(@"request failed %@",[request responseString]);
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    
    NSDictionary* requestInfo =[request userInfo];
    NSString* rType = [requestInfo objectForKey:@"requestType"];
    
    if([rType isEqualToString:HTTP_REQUEST_SIMPLE_SUGGESTION]){
        self.httpRequestSearchSimpleSuggestion = nil;
        return;
    }
    
    if ([rType isEqualToString:HTTP_REQUEST_DO_SEARCH]) {
        self.httpRequestSearchSimpleSearch = nil;
    }
    
    if ([rType isEqualToString:HTTP_REQUEST_SEARCH_DETAIL]) {
        self.httpRequestSearchDetail = nil;
        NSLog(@"Search Detail is bug");
        [self hideMsgBar];
        return;
    }
    
    if([rType isEqualToString:@"askPDF"])
    {
        int count =[self.downloadArrays count];
        NSString* eId =[requestInfo objectForKey:@"externalId"];
        
        for(int i=0;i<count;i++)
        {
            NSMutableDictionary* item =[[self.downloadArrays objectAtIndex:i] mutableCopy];
            if([eId isEqualToString:[item objectForKey:@"externalId"]])
            {
                [item setObject:ASKFULLTEXT_STATE_DOWNLOADABLE forKey:@"status"];
                [self.requestArrays replaceObjectAtIndex:i withObject:item];
                
                [[NSUserDefaults standardUserDefaults] setObject:self.requestArrays forKey:@"requestArrays"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self updateRequestDown];
                break;
            }
        }
        
        [self enabledSwitchButton];
        return;
    }
    else if([rType isEqualToString:@"registerNew"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"提交注册失败，请稍后重试。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    } else if([rType isEqualToString:@"downAskDetail"]) {
        [self showCoverBgWithLoading:false];
        [self showCoverBgWithErrorMsg:@"发生错误,请稍后重试。"];
    } else if([rType isEqualToString:@"requestPDF"]){
        [self showCoverBgWithErrorMsg:@"载入PDF出错。"];
    } else if([rType isEqualToString:HTTP_REQUEST_ASK_FOR_SYNC_LIST]) {
        [self showAskSuccessLoading:NO];
        [self.requestList reloadData];
    }
    
    if(!self.loadingView.hidden)
    {
        [self showCoverBgWithErrorMsg:@"发生错误,请稍后重试。"];
    }
    
    if (![self.switchButton isEnabled]) {
        [self hideMsgBar];
        [self enabledSwitchButton];  // DZH
    }
    if (![bigCoverView isHidden]) {
        [self showBigCoverBgWithLoading:false];
    }
    askingLoading.hidden = YES;
    askSuccessLoading.hidden = YES;
}

-(void)downRequest:(id)sender {
    if(![NetStatusChecker isNetworkAvailbe])
    {
        [self netWorksWarning];
        return;
    }
    
    downWifiOnly =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downWifiOnly"] boolValue];
    if(downWifiOnly && ![NetStatusChecker isUsingWifi])
    {
        [self wifiDownloadWarning];
        return;
    }
    
    int index =((UIButton*)sender).tag;
    
    NSLog(@"down %d",index);
    
    NSMutableDictionary* item =[[self.requestArrays objectAtIndex:index] mutableCopy];
    
    [item setObject:ASKFULLTEXT_STATE_DOWNLOADING forKey:@"status"];
    
    NSString* eId =[item objectForKey:@"externalId"];
    NSString* iId =[item objectForKey:@"internalId"];
    
    [self.requestArrays replaceObjectAtIndex:index withObject:item];
    
    [self.requestList reloadData];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.requestArrays forKey:@"requestArrays"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateRequestDown];
    
    NSString* title =[item objectForKey:@"fileTitle"];
    NSString* fn = [self fileNameWithExternelId:eId];
    NSString* fp = [self filePathInCache:fn];
    [self downloadAskPDFwithExternalId:eId andInternalId:iId displayFullText:NO title:title filePath:fp fileName:fn];
}

-(NSString*) fileNameWithExternelId:(NSString*)externelId {
    NSString* fileId =[Util md5:externelId];
    NSString* fileName = [NSString stringWithFormat:@"%@.pdf",fileId];
    return fileName;
}

-(NSString*)filePathInCache:(NSString *)fileName {
    NSString *filePath =
    [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:fileName];
    NSLog(@"filePath %@",filePath);
    return filePath;
}

-(NSString*)filePathInDocuments:(NSString*)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

-(void)downloadAskPDFwithExternalId:(NSString*)Eid andInternalId:(NSString*)Iid displayFullText:(BOOL)displayIt title:(NSString *)title filePath:(NSString *)filePath fileName:(NSString *)fileName {
    NSString* fileURL = [NSString stringWithFormat:@"http://%@/docsearch/askforpdf/%@",PDFPROCESS_SERVER,Eid];
    
    NSLog(@"url a = %@",fileURL);
    self.fullTextDownloader = nil;
    
    self.fullTextDownloader = [downloader requestWithURL:[NSURL URLWithString:fileURL]];
    
    [self.fullTextDownloader addRequestHeader:@"Content-Type" value:@"application/json"];
    [self.fullTextDownloader addRequestHeader:@"Accept" value:@"application/json"];
    
    self.fullTextDownloader.fileName =fileName;
    self.fullTextDownloader.fileURL = fileURL;
    self.fullTextDownloader.filePath = filePath;
    
    self.fullTextDownloader.timeOutSeconds = 120;
    
    //self.fullTextDownloader.downloadType = MEETING_SLIDERS;
    self.fullTextDownloader.retryingTimes = 0;
    self.fullTextDownloader.retryingMaxTimes = 1;
    
    [self.fullTextDownloader setDownloadDestinationPath:self.fullTextDownloader.filePath];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"askPDF" forKey:@"requestType"];
    [userInfo setObject:self.fullTextDownloader.fileName forKey:@"downloadFile"];
    
    [userInfo setObject:title forKey:@"downloadTitle"];
    [userInfo setObject:filePath forKey:@"downloadPath"];
    
    
    [userInfo setObject:Eid forKey:@"externalId"];
    [userInfo setObject:title forKey:@"fileTitle"];
    [userInfo setObject:filePath forKey:@"filePath"];
    [userInfo setObject:[NSNumber numberWithBool:displayIt] forKey:@"fullTextOption"];
    
    
    [self.fullTextDownloader setUserInfo:userInfo];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/download"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [self.fullTextDownloader setUseCookiePersistence:NO];
    [self.fullTextDownloader setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    //[self.fullTextDownloader setUserAgent:@"imd-ios"];
    
    
    self.fullTextDownloader.delegate = self;
    [self.fullTextDownloader startAsynchronous];
}


#pragma mark - display functions

-(void)displayDetails
{
    self.searchResultCoverView.hidden = YES;
    self.loadingView.hidden =YES;
    self.detailView.hidden =YES;
    self.AbstractTextScrollView.hidden =NO;
    self.switchButton.hidden = NO;
    [self enabledSwitchButton];  // DZH
    
    
    for (UIView *view in [self.AbstractTextScrollView subviews]) {
        if([view isKindOfClass:[NMCustomLabel class]])
            [view removeFromSuperview];
    }
    
    NSDictionary* result;
    if(currentActionSelected == SIDEACTION_DOWNLOADED)
    {
        if(locationTabBarStatus == LOCATION_TAB_BAR_ASKING)
        {
            if (self.downAskDetail != nil) {
                result = [self.downAskDetail objectForKey:@"article"];
            } else {
                NSLog(@"it is a bug.");
                [self showCoverBgWithLoading:NO];
                return;
            }
        } else if(locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS) {
            if (self.downAskDetail != nil) {
                result = [self.downAskDetail objectForKey:@"article"];
            } else {
                NSLog(@"it is a bug.");
                [self showCoverBgWithLoading:NO];
                return;
            }
        } else {
            if (self.downAskDetail != nil) {
                result = self.downAskDetail;
            } else {
                NSLog(@"it is a bug.");
                [self showCoverBgWithLoading:NO];
                return;
            }
        }
        if(currentFavAction == FAV_ADDING)
        {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已添加到收藏夹！"];
            currentResultInFavorite =YES;
        } else if(currentFavAction == FAV_REMOVING) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已从收藏夹移除！"];
            currentResultInFavorite =NO;
        }
        
        if (detailIsFav) {
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-selected"] forState:UIControlStateNormal];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-hightlight"] forState:UIControlStateHighlighted];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-hightlight"] forState:UIControlStateSelected];
        } else {
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-normal"] forState:UIControlStateNormal];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-highlight"] forState:UIControlStateHighlighted];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-highlight"] forState:UIControlStateSelected];
        }
        
        currentFavAction = FAV_NONE;
    } else if(currentActionSelected == SIDEACTION_SEARCH) {
        if (self.detailSearch != nil) {
            result = [self.detailSearch objectForKey:@"article"];
        } else {
            [self showCoverBgWithLoading:NO];
            return;
        }
        
        if(currentFavAction == FAV_ADDING)
        {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已添加到收藏夹！"];
            currentResultInFavorite =YES;
        } else if(currentFavAction == FAV_REMOVING) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已从收藏夹移除！"];
            currentResultInFavorite =NO;
        }
        
        if (detailIsFav) {
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-selected"] forState:UIControlStateNormal];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-hightlight"] forState:UIControlStateHighlighted];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-has-hightlight"] forState:UIControlStateSelected];
        } else {
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-normal"] forState:UIControlStateNormal];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-highlight"] forState:UIControlStateHighlighted];
            [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-highlight"] forState:UIControlStateSelected];
        }
        currentFavAction = FAV_NONE;
    } else if(currentActionSelected == SIDEACTION_FAVORITE) {
        if (self.favDetail != nil) {
            result = [self.favDetail objectForKey:@"article"];
        } else {
            [self showCoverBgWithLoading:NO];
            return;
        }
    }
    
    NSString* PMID =[result objectForKey:@"PMID"];
    int lanInResult;
    
    if(PMID == nil || PMID.length == 0)
        lanInResult = SEARCH_MODE_CN;
    else
        lanInResult = SEARCH_MODE_EN;
    
    
    
    float yOffset =10;
    float xOffset =2;
    
    UIColor* jourTextColor =RGBCOLOR(212, 73, 48);
    UIColor* lightFullTextColor = RGBCOLOR(0, 0, 0);
    UIColor* titleColor = RGBCOLOR(0, 0, 0);
    UIColor* abstractTextColor = RGBCOLOR(0, 0, 0);
    
    //journal and date
    NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
    
    
    NSString* journal =[result objectForKey:@"journal"];
    if(journal == (id)[NSNull null] || journal.length == 0 )
    {
        [s appendString:@""];
    } else {
        journal = [Util replaceEM:journal LeftMark:@"" RightMark:@""];
        
        [s appendString:journal];
    }
    
    if(![s isEqualToString:@""]) [s appendString:@" ,"];
    
    NSString* publishDate =[result objectForKey:@"pubDate"];
    if(publishDate == (id)[NSNull null] || publishDate.length == 0 )
    {
        [s appendString:@""];
    } else {
        publishDate = [Util replaceEM:publishDate LeftMark:@"" RightMark:@""];
        [s appendString:publishDate];
    }
    
    NSString* volume = [result objectForKey:@"volume"];
    if (volume == (id)[NSNull null] || volume.length == 0) {
        [s appendString:@""];
    } else {
        volume = [Util replaceEM:volume LeftMark:@"" RightMark:@""];
        [s appendFormat:@";%@", volume];
    }
    
    NSString* issue = [result objectForKey:@"issue"];
    if (issue == (id)[NSNull null] || issue.length == 0) {
        [s appendString:@""];
    } else {
        issue = [Util replaceEM:issue LeftMark:@"" RightMark:@""];
        [s appendFormat:@"(%@)", issue];
    }
    
    NSString* pagination = [result objectForKey:@"pagination"];
    if (pagination == (id)[NSNull null] || pagination.length == 0) {
        [s appendString:@""];
    } else {
        pagination = [Util replaceEM:pagination LeftMark:@"" RightMark:@""];
        [s appendFormat:@":%@", pagination];
    }
    
    NMCustomLabel *detailJournal = [[NMCustomLabel alloc] init];
    detailJournal.text = s;
    detailJournal.font =
    [UIFont fontWithName:@"Palatino" size:
     DETAIL_JOURNAL_DEFAULT_SIZE + currentDetailsFontSizeOffset];
    //  detailJournal.kern = 1;
    detailJournal.textColor = jourTextColor;
    detailJournal.backgroundColor = [UIColor clearColor];
    detailJournal.lineHeight =
    DETAIL_JOURNAL_DEFAULT_SIZE + currentDetailsFontSizeOffset +
    DEFAULT_LINE_SPACE;
    detailJournal.frame = CGRectMake(xOffset, yOffset, 558, 4000);
    [detailJournal sizeToFit];
    
    yOffset =yOffset + detailJournal.frame.size.height + 5;
    
    [self.AbstractTextScrollView addSubview:detailJournal];
    
    // Line1
    [detailLine1 setImage:[UIImage imageNamed:@"img-abstract-title-seperate-line"]];
    detailLine1.frame = CGRectMake(xOffset, yOffset, 558, 2);
    
    yOffset =yOffset + detailLine1.frame.size.height + 14;
    
    //title
    NSString* title = [result objectForKey:@"title"];
    
    if(title == (id)[NSNull null] || title.length == 0 )
        title =@"";
    else
        title = [Util replaceEM:title LeftMark:@"" RightMark:@""];
    
    NMCustomLabel *myDetailTitle = [[NMCustomLabel alloc] init];
    
    myDetailTitle.text = title;
    myDetailTitle.font =[UIFont fontWithName:
                         @"Palatino-Bold" size:30.0 +currentDetailsFontSizeOffset];
    //  myDetailTitle.kern = 1; // 设成0.8 会造成缺少最后几个字符的情况。
    myDetailTitle.lineHeight = 30.0 +currentDetailsFontSizeOffset + 2;
    myDetailTitle.textColor = titleColor;
    myDetailTitle.backgroundColor = [UIColor clearColor];
    
    myDetailTitle.frame = CGRectMake(xOffset, yOffset, 558, 4000);
    [myDetailTitle sizeToFit];
    
    yOffset = yOffset + myDetailTitle.frame.size.height + 14;
    
    [self.AbstractTextScrollView addSubview:myDetailTitle];
    
    // Line2
    [detailLine2 setImage:[UIImage imageNamed:@"img-abstract-title-seperate-line"]];
    detailLine2.frame = CGRectMake(xOffset, yOffset, 558, 2);
    
    yOffset = yOffset + detailLine2.frame.size.height + 5;
    
    //authors
    NSArray* authors =[result objectForKey:@"author"];
    NSMutableString* authorString = [[NSMutableString alloc] initWithFormat:@""];
    
    for(int i =0; i<[authors count];i++) {
        if(![authorString isEqualToString:@""])
            [authorString appendString:@" ,"];
        NSString* aStr = [authors objectAtIndex:i];
        aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
        [authorString appendString:aStr];
    }
    
    NMCustomLabel* myDetailAuthors = [[NMCustomLabel alloc] init];
    myDetailAuthors.text = authorString;
    myDetailAuthors.textColor = lightFullTextColor;
    myDetailAuthors.backgroundColor = [UIColor clearColor];
    myDetailAuthors.font =
    [UIFont fontWithName:@"Palatino" size:
     DETAIL_AUTHORS_DEFAULT_SIZE + currentDetailsFontSizeOffset];
    myDetailAuthors.frame = CGRectMake(xOffset, yOffset, 558, 4000);
    //  myDetailAuthors.kern = 1;
    myDetailAuthors.lineHeight = DETAIL_AUTHORS_DEFAULT_SIZE +
    currentDetailsFontSizeOffset + DEFAULT_LINE_SPACE;
    [myDetailAuthors sizeToFit];
    
    
    yOffset = yOffset + myDetailAuthors.frame.size.height + 6;
    
    [self.AbstractTextScrollView addSubview:myDetailAuthors];
    
    //affliation
    
    NSArray* affiliations =[result objectForKey:@"affiliation"];
    NSMutableString* affiliationString = [[NSMutableString alloc] initWithFormat:@""];
    
    if(affiliations == (id)[NSNull null] || [affiliations count] == 0) {
        
    } else {
        for(int i =0; i<[affiliations count];i++)
        {
            if(![affiliationString isEqualToString:@""])
                [affiliationString appendString:@" ,"];
            
            NSString* aStr = [affiliations objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            [affiliationString appendString:aStr];
            
        }
    }
    
    NMCustomLabel* myDetailAffiliations = [[NMCustomLabel alloc] init];
    myDetailAffiliations.text = affiliationString;
    myDetailAffiliations.textColor = lightFullTextColor;
    myDetailAffiliations.backgroundColor = [UIColor clearColor];
    myDetailAffiliations.font =
    [UIFont fontWithName:@"Palatino" size:
     DETAIL_AFFILIATIONS_DEFAULT_SIZE + currentDetailsFontSizeOffset];
    //  myDetailAffiliations.kern = 1;
    myDetailAffiliations.lineHeight = DETAIL_AFFILIATIONS_DEFAULT_SIZE +
    currentDetailsFontSizeOffset + DEFAULT_LINE_SPACE;
    myDetailAffiliations.frame = CGRectMake(xOffset, yOffset, 558, 4000);
    [myDetailAffiliations sizeToFit];
    
    yOffset = yOffset + myDetailAffiliations.frame.size.height + 40;
    
    [self.AbstractTextScrollView addSubview:myDetailAffiliations];
    
    //  BOOL hasAbstractWord =YES;
    
    NSDictionary* abstractTextDic = [result objectForKey:@"abstractText"];
    NSArray* textArray =[abstractTextDic objectForKey:ABSTRACT_TEXT];
    NSArray* backgroundArray = [abstractTextDic objectForKey:ABSTRACT_BACKGROUND];
    NSArray* objectiveArray = [abstractTextDic objectForKey:ABSTRACT_OBJECTIVE];
    NSArray* mathodsArray = [abstractTextDic objectForKey:ABSTRACT_METHODS];
    NSArray* resultsArray = [abstractTextDic objectForKey:ABSTRACT_RESULTS];
    NSArray* conclusionsArray = [abstractTextDic objectForKey:ABSTRACT_CONCLUSIONS];
    NSArray* copyrightsArray = [abstractTextDic objectForKey:ABSTRACT_COPYRIGHTS];
    NSMutableString* abstractText =[NSMutableString stringWithString:@""];
    
    if (textArray != (id)[NSNull null] && [textArray count] > 0) {
        NSLog(@"textArray============ %@",textArray);
        for(int i =0; i<[textArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""]) {
                [abstractText appendString:@" ,"];
            }
            
            NSString* aStr =[textArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (backgroundArray != (id)[NSNull null] && [backgroundArray count] > 0) {
        NSLog(@"backgroundArray============ %@",backgroundArray);
        for(int i =0; i<[backgroundArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[backgroundArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (objectiveArray != (id)[NSNull null] && [objectiveArray count] > 0) {
        NSLog(@"objectiveArray============ %@",objectiveArray);
        for(int i =0; i<[objectiveArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[objectiveArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (mathodsArray != (id)[NSNull null] && [mathodsArray count] > 0) {
        NSLog(@"mathodsArray============ %@",mathodsArray);
        for(int i =0; i<[mathodsArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[mathodsArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (resultsArray != (id)[NSNull null] && [resultsArray count] > 0) {
        NSLog(@"resultsArray============ %@",resultsArray);
        for(int i =0; i<[resultsArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[resultsArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (conclusionsArray != (id)[NSNull null] && [conclusionsArray count] > 0) {
        NSLog(@"conclusionsArray============ %@",conclusionsArray);
        for(int i =0; i<[conclusionsArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[conclusionsArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (copyrightsArray != (id)[NSNull null] && [copyrightsArray count] > 0) {
        NSLog(@"copyrightsArray============ %@",copyrightsArray);
        for(int i =0; i<[copyrightsArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[copyrightsArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    UIImage* abstractImg;
    
    if(lanInResult == SEARCH_MODE_CN){
        //      abstractWord =@"摘要";
        abstractImg = [UIImage imageNamed:@"img-tag-abstract-cn"];
    } else {
        //      abstractWord =@"Abstract";
        abstractImg = [UIImage imageNamed:@"img-tag-abstract-en"];
    }
    
    [detailAbstractLabel setImage:abstractImg];
    detailAbstractLabel.frame = CGRectMake(xOffset, yOffset, 74, 21);
    detailAbstractLabel.hidden = NO;
    yOffset = yOffset + detailAbstractLabel.frame.size.height + 5;
    
    NMCustomLabel *detailAbstractTextCustom = [[NMCustomLabel alloc] init];
    detailAbstractTextCustom.text = abstractText;
    detailAbstractTextCustom.textColor = abstractTextColor;
    detailAbstractTextCustom.backgroundColor = [UIColor clearColor];
    detailAbstractTextCustom.font =
    [UIFont fontWithName:@"Palatino" size:18.0+currentDetailsFontSizeOffset];
    detailAbstractTextCustom.lineHeight = 18 + currentDetailsFontSizeOffset + 8;
    detailAbstractTextCustom.frame = CGRectMake(xOffset, yOffset, 558, 6000);
    [detailAbstractTextCustom sizeToFit];
    
    yOffset = yOffset + detailAbstractTextCustom.frame.size.height + 40;
    
    [self.AbstractTextScrollView addSubview:detailAbstractTextCustom];
    //keywords
    NSArray* keywords =[result objectForKey:@"keywords"];
    //NSString* keywordMark = @"Keyword ";
    //NSMutableString* keywordsString = [[NSMutableString alloc] initWithFormat:@"        "];
    NSMutableString* keywordsString = [[NSMutableString alloc] initWithFormat:@""];
    
    BOOL hasKeywords =YES;
    
    if(keywords == (id)[NSNull null] || [keywords count] == 0) {
        hasKeywords =NO;
    } else {
        for(int i =0; i<[keywords count];i++)
        {
            if(![keywordsString isEqualToString:@""])
                [keywordsString appendString:@" ,"];
            
            NSString* aStr = [keywords objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            [keywordsString appendString:aStr];
            
        }
    }
    
    UIImage* keyImg;
    
    if (lanInResult == SEARCH_MODE_CN) {
        keyImg = [UIImage imageNamed:@"img-tag-keywords-cn"];
    } else {
        keyImg = [UIImage imageNamed:@"img-tag-keywords-en"];
    }
    [detailKeywordLabel setImage:keyImg];
    detailKeywordLabel.frame = CGRectMake(xOffset, yOffset ,74, 21);
    detailKeywordLabel.hidden = NO;
    yOffset = yOffset + detailKeywordLabel.frame.size.height + 5;
    
    NMCustomLabel *detailKeywordCustom = [[NMCustomLabel alloc] init];
    
    detailKeywordCustom.text = keywordsString;
    detailKeywordCustom.textColor = lightFullTextColor;
    detailKeywordCustom.backgroundColor = [UIColor clearColor];
    detailKeywordCustom.font =[UIFont fontWithName:@"Palatino" size:
                               18.0+currentDetailsFontSizeOffset];
    detailKeywordCustom.lineHeight = 17 + currentDetailsFontSizeOffset + 8;
    //  detailKeywordCustom.kern = 1;
    detailKeywordCustom.frame = CGRectMake(xOffset, yOffset, 558, 4000);
    [detailKeywordCustom sizeToFit];
    
    yOffset = yOffset + detailKeywordCustom.frame.size.height +40;
    
    [self.AbstractTextScrollView addSubview:detailKeywordCustom];
    
    self.AbstractTextScrollView.contentSize = CGSizeMake(558, yOffset);
    //  self.AbstractTextScrollView.contentSize = CGSizeMake(558, 100);
}


- (void)calculatePages
{
    currentPage = fetchingPage;
    
    if(resultsCount % displayMax == 0)
    {
        totalPages = resultsCount/displayMax;
    } else {
        totalPages = resultsCount/displayMax+1;
    }
    
    isSinglePage = (totalPages == 1);
    
    NSArray* results =[self.searchedResult objectForKey:@"results"];
    
    if(results == (id)[NSNull null]  || [results count] ==0)
    {
        NSLog(@"error");
    }
    else
    {
        loadingRow = [results count]+1;
    }
}

-(void)loadingNextBlock:(id)sender
{
    if(![NetStatusChecker isNetworkAvailbe]) {
        [self netWorksWarning];
        loadingMore =NO;
        return;
    }
    
    if (adview.newSearchStart) {
        searchingType = 1;
    }
    
    fetchingPage = currentPage +1;
    newSearchStart = NO;
    if(searchingType == SEARCHING_TYPE_ADVANCED) {
        if (fetchingPage > 1) {
            adview.newSearchStart = NO;
            adview.currentPage = fetchingPage-1;
        }
        [adview advSearch:nil status:@"loadingNextBlock" sort:nil];
        
    } else {
        [ImdAppBehavior nextPageLog:[Util getUsername] MACAddr:[Util getMacAddress] SearchJson:[NSString stringWithFormat:@"{\"type\":\"simple search\",\"search words\":\"%@\",\"page\":%i,\"lan\":%i,\"sort\":%i}", searchBar.text, fetchingPage, currentResultLanguage,[sortMethod intValue]]];
        
        self.httpRequestSearchSimpleSearch = [self searchSimpleSearch:searchBar.text Page:fetchingPage Lan:currentResultLanguage Delegate:self sort:[sortMethod intValue]];
    }
    
}

#pragma mark - change search language
-(void)popLanguageSelection:(UIButton*)sender {
    
    NSLog(@"filter tapped");
    if(languagePopoverController!=nil) {
        languagePopoverController = nil;
    }
    
    lanSelectViewController *content = [[lanSelectViewController alloc] initWithNibName:@"lanSelectViewController" bundle:nil];
    //content.searchLanguage = currentSearchLanguage;
    
    languagePopoverController= [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    //content.tag =[sender tag];
    
    
	languagePopoverController.popoverContentSize = CGSizeMake(160., 100.);
	languagePopoverController.delegate = self;
    
    UIButton* t =(UIButton*)sender;
    
    CGRect frame=CGRectMake(t.frame.origin.x + 72, t.frame.origin.y + 40, t.frame.size.width, t.frame.size.height);
    
    // Present the popover from the button that was tapped in the detail view.
	[languagePopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)changeLanguage:(UIButton*)sender {
    [self showBigCoverBgWithLoading:NO];
    //NSLog(@"changing mode");
    [languagePopoverController dismissPopoverAnimated:YES];
    
    lanSelectViewController* c = (lanSelectViewController*)sender;
    
    NSString* lan;
    if(c.selectedItem == SEARCH_MODE_CN)
    {
        lan =@"CN";
        //currentSearchLanguage = SEARCH_MODE_CN;
    } else {
        lan =@"EN";
        //currentSearchLanguage = SEARCH_MODE_EN;
    }
    
    [self changeLanguageTo:lan];
    
}


-(void)advChangeLanguage:(id)sender {
    UISegmentedControl* sw =(UISegmentedControl*)sender;
    if(sw.selectedSegmentIndex == SEARCH_MODE_CN)
    {
        [self changeLanguageTo:@"CN"];
    } else {
        [self changeLanguageTo:@"EN"];
    }
    
}

-(void)changeLanguageTo:(NSString*)lanStr {
    if([lanStr isEqualToString:@"CN"]) {
        currentSearchLanguage = SEARCH_MODE_CN;
    } else {
        currentSearchLanguage = SEARCH_MODE_EN;
    }
    
    if(currentSearchLanguage == SEARCH_MODE_CN) {
        
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-cn-normal"] forState:UIControlStateNormal];
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-cn-highlight.png"] forState:UIControlStateHighlighted];
        searchBar.placeholder = @"检索中文文献库";
        
    } else {
        
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-en-normal"] forState:UIControlStateNormal];
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-en-highlight.png"] forState:UIControlStateHighlighted];
        searchBar.placeholder = @"检索英文文献库";
        
    }
    
    //if(displayState == DISPLAY_STATE_ADVSEARCH)
    {
        
        filterNames = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
        filterValues = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
        filterOperations = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
        
        filterItemData = [self readPListBundleFile:@"searchFilters"];
        
        for(int i =0; i<advancedQueryItemCountMax ;i++)
        {
            if(currentSearchLanguage == SEARCH_MODE_CN)
            {
                NSArray* TextCN = [filterItemData objectForKey:@"CN_TEXT"];
                [filterNames addObject:[TextCN objectAtIndex:0]];
            }
            else
            {
                NSArray* TextEN = [filterItemData objectForKey:@"EN_TEXT"];
                [filterNames addObject:[TextEN objectAtIndex:0]];
            }
            
            [filterValues addObject:@""];
            [filterOperations addObject:[NSNumber numberWithInt:OPERATION_AND]];
        }
    }
    
    //save mode
    [[NSUserDefaults standardUserDefaults] setInteger:currentSearchLanguage forKey:@"searchLan"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    if(displayState == DISPLAY_STATE_RESULTS &&  currentSearchLanguage !=currentResultLanguage) {
        NSLog(@"change and search");
        
        if(![NetStatusChecker isNetworkAvailbe]) {
            [self netWorksWarning];
            return;
        }
        
        newSearchStart = YES;
        
        currentPage =1;
        fetchingPage =1;
        
        if(searchingType == SEARCHING_TYPE_ADVANCED)
        {
            [adview advSearch:nil status:@"changeLanguageTo" sort:nil];
            
        } else {
            [ImdAppBehavior searchJsonLog:[Util getUsername] MACAddr:[Util getMacAddress] SearchJson:[NSString stringWithFormat:@"{\"type\":\"simple search\",\"search words\":\"%@\",\"page\":%i,\"lan\":%i,\"sort\":%i}", searchBar.text, fetchingPage, currentSearchLanguage,[sortMethod intValue]]];
            self.httpRequestSearchSimpleSearch = [self searchSimpleSearch:searchBar.text Page:fetchingPage Lan:currentSearchLanguage Delegate:self sort:[sortMethod intValue]];
        }
    }
}



#pragma mark - change catalog
-(void)changeCatalog:(id)sender {
    [catalogPopoverController dismissPopoverAnimated:YES];
    NSLog(@"catalog change");
}


#pragma mark - change sort
-(void)changeSort:(id)sender {
    newSearchStart = YES;
    [sortPopoverController dismissPopoverAnimated:YES];
    
    sortSelectViewController* s =(sortSelectViewController*)sender;
    NSLog(@"sort change %d",s.selectedItem);
    
    if(s.selectedItem ==0) {
        [self.resultLeftButton setTitle:@"相关排序" forState:UIControlStateNormal];
    } else if(s.selectedItem ==1) {
        [self.resultLeftButton setTitle:@"时间排序" forState:UIControlStateNormal];
        
    } else {
        [self.resultLeftButton setTitle:@"期刊排序" forState:UIControlStateNormal];
        
    }
    
    
    sortWay =s.selectedItem;
    sortMethod =[self fetchSortMethod:sortWay];
    
    
    if(![NetStatusChecker isNetworkAvailbe]) {
        [self netWorksWarning];
        return;
    }
    
    //fetchingPage = currentPage;
    if (adview.newSearchStart) {
        searchingType = 1;
    }
    
    currentPage =1;
    fetchingPage =1;
    isSort = true;
    
    if(searchingType == SEARCHING_TYPE_ADVANCED)
    {
        [adview advSearch:nil status:@"changeSort" sort:sortMethod ]; 
    } else {
        [ImdAppBehavior sortLog:[Util getUsername] MACAddr:[Util getMacAddress] sortName:[NSString stringWithFormat:@"{\"type\":\"simple search\",\"search words\":\"%@\",\"page\":%i,\"lan\":%i,\"sort\":%i}", searchBar.text, fetchingPage, currentResultLanguage,[sortMethod intValue]]];
        self.httpRequestSearchSimpleSearch = [self searchSimpleSearch:searchBar.text Page:fetchingPage Lan:currentResultLanguage Delegate:self sort:[sortMethod intValue]];
    }
}


#pragma mark - refresh sideActions
- (void)refreshSideActionButtons
{
    selectedDotSearch.hidden = !(currentActionSelected == SIDEACTION_SEARCH);
    selectedDotFav.hidden = !(currentActionSelected == SIDEACTION_FAVORITE);
    selectedDotDownload.hidden = !(currentActionSelected == SIDEACTION_DOWNLOADED);
    
    if(currentActionSelected == SIDEACTION_SEARCH) {
        [self.sideActionSearchButton setImage:[UIImage imageNamed:@"icon-search-selected"] forState:UIControlStateNormal];
    } else {
        [self.sideActionSearchButton setImage:[UIImage imageNamed:@"icon-search-normal"] forState:UIControlStateNormal];
    }
    
    if(currentActionSelected == SIDEACTION_FAVORITE) {
        [self.sideActionFavoriteButton setImage:[UIImage imageNamed:@"icon-favoritesFolder-selected"] forState:UIControlStateNormal];
    } else {
        [self.sideActionFavoriteButton setImage:[UIImage imageNamed:@"icon-favoritesFolder-normal"] forState:UIControlStateNormal];
    }
    
    
    if(currentActionSelected == SIDEACTION_DOWNLOADED) {
        [self.sideActionDownloadedButton setImage:[UIImage imageNamed:@"icon-downloadFolder-selected"] forState:UIControlStateNormal];
    } else {
        [self.sideActionDownloadedButton setImage:[UIImage imageNamed:@"icon-downloadFolder-normal"] forState:UIControlStateNormal]; 
    }
    
    
    if(currentActionSelected == SIDEACTION_SETTINGS) {
        [self.sideActionSettingsButton setImage:[UIImage imageNamed:@"icon-setting-selected"] forState:UIControlStateNormal];
    }  else {
        [self.sideActionSettingsButton setImage:[UIImage imageNamed:@"icon-setting-normal"] forState:UIControlStateNormal]; 
    }
    
    if(currentActionSelected == SIDEACTION_HELP)  {
        [self.sideActionHelpButton setImage:[UIImage imageNamed:@"icon-help-selected"] forState:UIControlStateNormal];
    } else {
        [self.sideActionHelpButton setImage:[UIImage imageNamed:@"icon-help-normal"] forState:UIControlStateNormal];
    }
}

#pragma mark - pressed sideActions
- (IBAction)sideActionPressed:(id)sender {
    adview.view.hidden = YES;
    NSLog(@"side Action");
    NSLog(@"side action pressed");
    [adview.currentKeybordHolder resignFirstResponder];
    
    
    UIButton* button =(UIButton*)sender;
    
    if (currentActionSelected == SIDEACTION_SEARCH) {
        searchLastState = displayState;
        searchDisplayingRow = currentDisplayingRow;
        NSLog(@"Search State = %i", searchLastState);
    }
    
    if(button == self.sideActionSearchButton)
    {
        NSLog(@"Search Button");
        [self cancelFavoritesHttpRequests];
        [self cancelLocationHttpRequests];
        [self showBigCoverBgWithLoading:NO];
        if(!advViewOn)
        {
            if (currentActionSelected == SIDEACTION_SEARCH ||
                searchLastState == DISPLAY_STATE_SUGGESTION) {
                displayState = DISPLAY_STATE_FRONTPAGE;
            } else {
                displayState = searchLastState;
            }
            currentActionSelected = SIDEACTION_SEARCH;
            //      [self loadFav];
            if (displayState == DISPLAY_STATE_RESULTS) {
                currentDisplayingRow = searchDisplayingRow;
                [self displayDetails];
            }
            
            if (isAdvViewShow == true && displayState == DISPLAY_STATE_FRONTPAGE) {
                NSLog(@"isAdvViewShow is true");
                [self advViewShow:nil];
            }
        }
        
    } else if(button == self.sideActionFavoriteButton) {
        [self cancelSearchHttpRequests];
        [self cancelLocationHttpRequests];
        BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(!useLogined) {
            [self remindLogin];
            return;
        } else if(!appDelegate.auth.imdToken.length > 0) {
            [self remindLogin];
            return;
        }
        
        advViewOn =NO;
        currentActionSelected = SIDEACTION_FAVORITE;
        displayState = DISPLAY_STATE_FAVORATE;
        currentDisplayingRow =0;
        currentDisplayingSection =0;
        [self showBigCoverBgWithLoading:YES];
        [self showFavList];
        
    } else if(button == self.sideActionDownloadedButton) {
        [self cancelSearchHttpRequests];
        [self cancelFavoritesHttpRequests];
        if (self.hasNotification) {
            [self sideLocalDocuments:2];
        }else{
            [self sideLocalDocuments:0];
        }
    } else if(button == self.sideActionSettingsButton) {
        settingDisplayState = currentActionSelected;
        currentActionSelected = SIDEACTION_SETTINGS;
        [self presentSettingWindow];
    } else if(button == self.sideActionHelpButton) {
        
        self.viewController = [[GuideIndexiPadViewController alloc] init];
        [self.view addSubview:self.viewController.view];
        
//        helpDisplayState = currentActionSelected;
//        currentActionSelected = SIDEACTION_HELP;
//        //for #3505
//        //displayState = DISPLAY_STATE_HELP;
//        
//        pageControlBeingUsed = NO;
//        
//        for (UIView *view in [self.helpScrollView subviews]) {
//            if([view isKindOfClass:[UIImageView class]])
//                [view removeFromSuperview];
//        }
//        
//        for (int i = 0; i < 5; i++)
//        {
//            CGRect frame;
//            frame.origin.x = self.helpScrollView.frame.size.width * i;
//            frame.origin.y = 0;
//            frame.size = self.helpScrollView.frame.size;
//            
//            UIImageView *subview = [[UIImageView alloc] initWithFrame:frame];
//            subview.image =[UIImage imageNamed:[NSString stringWithFormat:@"img-help-step-0%d",i+1]];
//            
//            self.helpCoverButton.enabled = NO;
//            [self.helpScrollView addSubview:subview];
//        }
//        
//        self.helpScrollView.contentOffset =CGPointMake(0, 0);
//        
//        self.helpScrollView.contentSize = CGSizeMake(self.helpScrollView.frame.size.width * 5, self.helpScrollView.frame.size.height);
//        
//        self.helpPageControl.currentPage = 0;
//        
//        self.helpCover.hidden =NO;
    }
    
    if(barLoadingAction != currentActionSelected)
        [self hideMsgBar];
    
    [self refreshSideActionButtons];
    [self displayStates];
}

-(void)sideLocalDocuments:(int)sender {
    advViewOn =NO;
    [self clearBadges];
    
    [self.currentKeybordHolder resignFirstResponder];
    NSLog(@"down");
    
    currentActionSelected = SIDEACTION_DOWNLOADED;
    displayState = DISPLAY_STATE_DOWNLOADED;
    if (sender == 2) {
        locationTabBarStatus = sender;
    }
    switch (locationTabBarStatus) {
        case LOCATION_TAB_BAR_HAS_SAVED:
            [self hasSavedListLoading];
            break;
            
        case LOCATION_TAB_BAR_ASKING:
            [self askingListLoading];
            break;
            
        case LOCATION_TAB_BAR_ASK_SUCCESS:
            [self askSuccessListLoading];
            break;
            
        default:
            break;
    }
}

-(void)loadFavDetail {
    if(self.favArrays ==nil|| [self.favArrays count] ==0)
    {
        [self showBigCoverBgWithLoading:NO];
        return;
    }
    if(![NetStatusChecker isNetworkAvailbe])
    {
        NSLog(@"loadFavDetail 1");
        [self netWorksWarning];
        return;
    }
    NSLog(@"loadFavDetail 2");
    @try {
        NSLog(@"loadFavDetail 2。22");
        NSDictionary* item =[self.favArrays objectAtIndex:currentDisplayingRow];
        NSLog(@"loadFavDetail 2。52");
        NSString* eId =[item objectForKey:@"externalId"];
        NSLog(@"loadFavDetail 3");
        [self showCoverBgWithLoading:YES];
        
        NSString* title =[item objectForKey:@"title"];
        [ImdAppBehavior detailLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_FAV];
        
        //    self.httpRequestFavoritesDetail = [self favoritesDetail:eId];
        [self showFavDetail:eId];
        NSLog(@"loadFavDetail 4");
    }
    @catch (NSException *exception) {
        NSLog(@"loadFavDetail exception %@", exception);
    }
}


#pragma mark - result head buttons

- (void)sortPressed:(id)sender {
    sortSelectViewController *content = [[sortSelectViewController alloc] initWithNibName:@"sortSelectViewController" bundle:nil];
    //content.searchLanguage = currentSearchLanguage;
    
    sortPopoverController= [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    content.selectedItem =sortWay;
    
    //content.tag =[sender tag];
    
	sortPopoverController.popoverContentSize = CGSizeMake(160., 150.);
	sortPopoverController.delegate = self;
    
    UIButton* t =(UIButton*)sender;
    
    
    CGRect frame=CGRectMake(t.frame.origin.x + 72, t.frame.origin.y+90, t.frame.size.width, t.frame.size.height);
    
    // Present the popover from the button that was tapped in the detail view.
	[sortPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (void)catalogPressed:(id)sender {
    NSLog(@"catalog tapped");
    
    catalogSelectViewController *content = [[catalogSelectViewController alloc] initWithNibName:@"catalogSelectViewController" bundle:nil];
    //content.searchLanguage = currentSearchLanguage;
    
    catalogPopoverController= [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    //content.tag =[sender tag];
    
	catalogPopoverController.popoverContentSize = CGSizeMake(280., 100.);
	catalogPopoverController.delegate = self;
    
    UIButton* t =(UIButton*)sender;
    
    
    CGRect frame=CGRectMake(t.frame.origin.x + 72, t.frame.origin.y+90, t.frame.size.width, t.frame.size.height);

    // Present the popover from the button that was tapped in the detail view.
	[catalogPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - title buttons
-(IBAction)backPressed:(id)sender {
    if(displayState == DISPLAY_STATE_RESULTS)
    {
        if(advViewOn)
            [self advViewShow:nil];
        
        displayState = DISPLAY_STATE_FRONTPAGE;
        
    } else if(advViewOn) {
        [self advViewHide];
        displayState = DISPLAY_STATE_FRONTPAGE;//lastDisplayState;
    }
    
    [self displayStates];
}

-(IBAction)favSavePressed:(id)sender {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Informaion"
                                                        message:@"search saved" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)remindLogin {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"收藏/获取全文需要帐号登录" delegate:self
                                              cancelButtonTitle:@"确认" otherButtonTitles:nil];
    
    alertView.tag =123;
    
    [alertView show];
}

#pragma mark - move show/hide complete function
-(IBAction)advViewShow:(id)sender {
    [self performSelector:@selector(advSearched) withObject:self afterDelay:0.3];
}

-(void)advSearched {
    newSearchStart = YES;
    NSLog(@"let adv search out");
    if (self.httpRequestSearchSimpleSearch != nil) {
        NSLog(@"self.httpRequestSearchResultSimpleSearch cancel");
        [self cancelSearchHttpRequests];
    }
    [self.currentKeybordHolder resignFirstResponder];
    
    //do not show at suggestion state
    if(displayState == DISPLAY_STATE_SUGGESTION)
    {
    }
    
    searchBar.text =@"";
    adview.view.hidden = NO;
    adview.view.frame = CGRectMake(-348, 40, 348, 748);
    
    
    [UIView beginAnimations:@"move show" context:nil];
    [UIView setAnimationDuration:0.5f];
    adview.view.frame = CGRectMake(64, 40, 348, 748);
    [UIView setAnimationDidStopSelector:
     @selector(movingShowCompleted)];
    [UIView setAnimationDelegate: self];
    [UIView commitAnimations];
    
    advViewAnimating =YES;
    isAdvViewShow = true;
    NSLog(@"isAdvViewShow is true");
}

-(void)advViewHide {
    
    NSLog(@"let adv search hide");
    
    adview.view.frame = CGRectMake(64, 40, 348, 748);
    [adview.currentKeybordHolder resignFirstResponder];
    adview.newSearchStart = NO;
    
    [UIView beginAnimations:@"move hide" context:nil];
    [UIView setAnimationDuration:0.5f];
    adview.view.frame = CGRectMake(-348, 40, 348, 748);
    [UIView setAnimationDidStopSelector:
     @selector(movingHideCompleted)];
    [UIView setAnimationDelegate: self];
    [UIView commitAnimations];
    
    advViewAnimating =YES;
    isAdvViewShow = false;
    NSLog(@"isAdvViewShow is false");
}


-(void)movingShowCompleted {
    NSLog(@"show completed");
    advViewAnimating =NO;
    
    lastDisplayState = displayState;
    //displayState = DISPLAY_STATE_ADVSEARCH;
    displayState = DISPLAY_STATE_FRONTPAGE;
    advViewOn =YES;
    [self displayStates];
    
    newAdvSearch = YES;
}

-(void)movingHideCompleted {
    NSLog(@"hide completed");
    advViewAnimating =NO;
    
    displayState = DISPLAY_STATE_FRONTPAGE;
    advViewOn =NO;
    //lastDisplayState;
    [self displayStates];
    //advancedQueryItemCount =1;
    newAdvSearch = NO;
}


#pragma mark - display state
-(void)displayStates {
    if(advViewOn && displayState == DISPLAY_STATE_FRONTPAGE) {
        self.searchTitle.text = @"高级检索";
        self.backButton.hidden = NO;
        self.favoriteSaveButton.hidden = YES;
        //self.searchResultCoverView.hidden = NO;
        //self.coverBg.image = [UIImage imageNamed:@"bg-default"];
        [self showCoverBgWithLoading:NO];
        
        
        self.searchResultList.frame = CGRectMake(0, 0, self.searchListView.frame.size.width, self.searchListView.frame.size.height);
        
        
        self.listFavView.hidden =YES;
        self.listDownloadView.hidden =YES;
        self.listSearchView.hidden =NO;
        
        self.advButton.hidden =YES;
        return;
    }
    
    if(displayState == DISPLAY_STATE_FRONTPAGE) {
        self.backButton.hidden = YES;
        self.favoriteSaveButton.hidden = YES;
        self.searchTitle.text =@"文献检索";
        
        self.searchResultList.frame = CGRectMake(0, 0, self.searchListView.frame.size.width, self.searchListView.frame.size.height);
        //self.searchResultCoverView.hidden = NO;
        self.coverBg.image = [UIImage imageNamed:@"bg-default"];
        [self showCoverBgWithLoading:NO];
        
        [self.searchResultList reloadData];
        
        self.listFavView.hidden =YES;
        self.listDownloadView.hidden =YES;
        self.listSearchView.hidden =NO;
        
        self.advButton.hidden =NO;
        
    }
    
    if(displayState == DISPLAY_STATE_SEARCHING)
    {
        
    }
    
    if(displayState == DISPLAY_STATE_RESULTS) {
        self.backButton.hidden = NO;
        //self.favoriteSaveButton.hidden = NO;
        self.searchTitle.text =@"检索结果";
        //self.searchResultCoverView.hidden = YES;
        self.loadingView.hidden=YES;
        
        
        adview.view.hidden = YES;
        self.searchResultList.frame = CGRectMake(0, 0, self.searchListView.frame.size.width, self.searchListView.frame.size.height);
        
        self.listFavView.hidden =YES;
        self.listDownloadView.hidden =YES;
        self.listSearchView.hidden =NO;
        self.coverBg.image = [UIImage imageNamed:@"bg-loadingFullText"];
        
        self.advButton.hidden =NO;
        
    }
    
    if(displayState == DISPLAY_STATE_SUGGESTION) {
        self.backButton.hidden = YES;
        self.favoriteSaveButton.hidden = YES;
        self.searchTitle.text =@"文献检索";
        self.searchResultList.frame = CGRectMake(0, 0, self.searchListView.frame.size.width, 300);
        //self.searchResultCoverView.hidden = NO;
        [self.searchResultList reloadData];
        self.searchResultCoverView.hidden = NO;
        self.loadingView.hidden=YES;
        
        self.coverBg.image = [UIImage imageNamed:@"bg-default"];
        
        self.advButton.hidden =NO;
    }
    
    if(displayState == DISPLAY_STATE_FAVORATE) {
        self.listFavView.hidden =NO;
        self.listDownloadView.hidden =YES;
        self.listSearchView.hidden =YES;
        [self.favList reloadData];
        
        //[self showCoverBgWithLoading:NO];
        
        if([self.favArrays count]==0) {
            [self showCoverBgWithLoading:NO];
            self.favEditButton.hidden=YES;
        } else {
            self.favEditButton.hidden=NO;
            
        }
    }
    
    if(displayState == DISPLAY_STATE_DOWNLOADED) {
        self.listFavView.hidden =YES;
        self.listDownloadView.hidden =NO;
        self.listSearchView.hidden =YES;
        [self.downList reloadData];
    }
}

#pragma mark - loadPlist

- (NSDictionary*)readPListBundleFile:(NSString*)fileName {
	NSString *plistPath;
	plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	
	NSMutableDictionary* temp =[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
	if (!temp) {
		NSLog(@"Error reading plist of %@",fileName);
	}
	
	return temp;
}

#pragma mark - adv delegate method

-(void)selectedOperation:(id)sender {
    advancedQueryItemsCell* cell = (advancedQueryItemsCell*)sender;
    
    if(cell.selectedOperation == OPERATION_AND)
        [filterOperations replaceObjectAtIndex:cell.tag withObject:[NSNumber numberWithInt:OPERATION_AND]];
    else if(cell.selectedOperation == OPERATION_OR)
        [filterOperations replaceObjectAtIndex:cell.tag withObject:[NSNumber numberWithInt:OPERATION_OR]];
    else
        [filterOperations replaceObjectAtIndex:cell.tag withObject:[NSNumber numberWithInt:OPERATION_NOT]];
    
    //NSLog(@"%@",filterOperations);
}

#pragma mark - setting delegate
- (void)closeSetting:(id)sender {
    //[self cancelSearchHttpRequests];
    [self dismissViewControllerAnimated:YES completion:nil];
    currentActionSelected = settingDisplayState;
    //for #3505
    //displayState = DISPLAY_STATE_FRONTPAGE;
    
    [self refreshSideActionButtons];
    [self displayStates];
}

- (void)presentInviteFriendWindow{
    InviteRegisterPadViewController *viewController = [[InviteRegisterPadViewController alloc] initWithNibName:@"InviteRegisterPadViewController" bundle:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
    [navigationController setNavigationBarHidden:YES];
    navigationController.view.superview.frame = CGRectMake(512-270, 384-310,540, 620);
}

-(void)presentVerifiedWindow {
    newVerifiedViewController *userInfoVerified = [[newVerifiedViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userInfoVerified];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self getUserInfo:[ImdUrlPath getUserInfo] delegate:userInfoVerified];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    [navigationController setNavigationBarHidden:YES];
    navigationController.view.superview.frame = CGRectMake(512-270, 384-310,540, 620);//it's important to do this after
}

-(void)presentSettingWindow {
    settingViewController* m=[[settingViewController alloc] initWithNibName:@"settingViewController" bundle:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:m];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    //  [self presentModalViewController:navigationController animated:YES];
    [self presentViewController:navigationController animated:YES completion:nil];
    [navigationController setNavigationBarHidden:YES];
    
    navigationController.view.superview.frame = CGRectMake(512-270, 384-310,540, 620);//it's important to do this after
    
    m.delegate =self;
}

#pragma mark - login delegate
- (void)closeLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loginSuccessProcess:(id)sender {
    [self.searchResultList reloadData];
    self.downloadArrays = [myDatabaseOption getSavedDoc];
    if (![self.downloadArrays count]) {
        self.downloadArrays =[[NSMutableArray alloc] initWithCapacity:20];
    }
}

-(void)reloadSearchHistoryList {
    [self.searchResultList reloadData];
}

- (void)loginNew:(id)sender {
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.auth postAuthInfo:@"register"];
    
    NSString* dailog = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginNewDailog"];
    if (dailog == nil || ![dailog isEqualToString:@"TRUE"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)registerNew:(id)sender {
    NSDictionary* dict =[[NSUserDefaults standardUserDefaults] objectForKey:@"tempRegInfo"];
    //NSString* theURL =[NSString stringWithFormat:@"http://%@/register",@"192.168.1.21:9000/client"];
    NSString* theURL =[NSString stringWithFormat:@"http://%@/register",SEARCH_SERVER];
    
    NSLog(@"url =%@",theURL);
    NSLog(@"dict =%@",dict);
    
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:theURL]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:[dict objectForKey:@"username"] forKey:@"userid"];
    [request setPostValue:[dict objectForKey:@"realName"] forKey:@"realname"];
    [request setPostValue:[dict objectForKey:@"password"] forKey:@"password"];
    [request setPostValue:[dict objectForKey:@"nickName"] forKey:@"nickname"];
    [request setPostValue:[dict objectForKey:@"department"] forKey:@"department"];
    [request setPostValue:[dict objectForKey:@"title"] forKey:@"title"];
    [request setPostValue:[dict objectForKey:@"hospital"] forKey:@"hospital"];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"registerNew" forKey:@"requestType"];
    [userInfo setObject:[dict objectForKey:@"username"] forKey:@"username"];
    [userInfo setObject:[dict objectForKey:@"password"] forKey:@"password"];
    
    [request setUserInfo:userInfo];
    
    request.delegate =self;
    [request startAsynchronous];
}

-(void)forgetPass:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSelector:@selector(presentForgetPassWindow:) withObject:nil afterDelay:0.8f];
}

-(void)presentForgetPassWindow:(id)sender
{
    [self.view addSubview:self.webVC.view];
    [self.webVC loadURL:@"http://www.i-md.com/user/forgotPassword"];
}

-(void)presentRegisterWindow:(id)sender
{
    [self.view addSubview:self.webVC.view];
    [self.webVC loadURL:@"http://www.i-md.com/register"];
}

-(void)presentLoginWindow:(id)sender
{
    [self logout:nil];
    loginViewController* m=[[loginViewController alloc] initWithNibName:@"loginViewController" bundle:nil];
    
    UINavigationController* nv =[[UINavigationController alloc] initWithRootViewController:m];
    nv.navigationBarHidden =YES;
    
    nv.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nv animated:YES completion:nil];
    
    nv.view.superview.frame = CGRectMake(512-270, 384-310,540, 620);//it's important to do this after
    m.delegate =self;
    self.mainLoginViewController =m;
    
}

-(void)presentConfirmWindow:(id)sender
{
    accountActivationViewController* aavc =
    [[accountActivationViewController alloc] initWithNibName:
     @"accountActivationViewController" bundle:nil];
    UINavigationController* nc =
    [[UINavigationController alloc] initWithRootViewController:aavc];
    nc.navigationBarHidden = YES;
    
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nc animated:YES completion:nil];
    
    nc.view.superview.frame = CGRectMake(512-270, 384-310, 540, 620);
    aavc.delegate = self;
    confirmViewController = aavc;
}

- (void)login:(id)sender
{
    [self closeSetting:nil];
    
    [self performSelector:@selector(presentLoginWindow:) withObject:nil afterDelay:0.8f];
    
    isFirstFav = true;
    isFirstAsked = true;
}

- (void)logout:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    currentResultInFavorite =NO;
    
    [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-normal"] forState:UIControlStateNormal];
    [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-highlight"] forState:UIControlStateHighlighted];
    [self.detailFavButton setImage:[UIImage imageNamed:@"btn-favorites-highlight"] forState:UIControlStateSelected];
    
    [self clearAll];
    [self closeSetting:nil];
    [adview tableViewReload];
}

#pragma mark - result details actions
-(IBAction)detailsFontZoomOut:(id)sender
{
    //FONT -
    if( currentDetailsFontSizeOffset == FONT_OFFSET_ZERO)
        currentDetailsFontSizeOffset = FONT_OFFSET_MINUS;
    else if(currentDetailsFontSizeOffset == FONT_OFFSET_PLUS)
        currentDetailsFontSizeOffset = FONT_OFFSET_ZERO;
    
    [self displayDetails];
    
}

-(IBAction)detailsFontZoomIn:(id)sender
{
    //FONT +
    if( currentDetailsFontSizeOffset == FONT_OFFSET_ZERO)
        currentDetailsFontSizeOffset = FONT_OFFSET_PLUS;
    else if(currentDetailsFontSizeOffset == FONT_OFFSET_MINUS)
        currentDetailsFontSizeOffset = FONT_OFFSET_ZERO;
    
    [self displayDetails];
}

-(IBAction)detailsAddFav:(id)sender
{
    //todo: check if logined in
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!useLogined) {
        [self remindLogin];
        return;
    } else if(!appDelegate.auth.imdToken.length > 0) {
        [self remindLogin];
        return;
    }
    
    if(processingFav)
        return;
    [self showBigCoverBgWithLoading:YES];
    
    if(currentActionSelected == SIDEACTION_DOWNLOADED)
    {
        currentFavAction = FAV_NONE;
        // Dzh
        if (detailIsFav) {
            [self removeFav:nil];
        } else {
            [self addFav:nil];
        }
        return;
    } else  if(currentActionSelected == SIDEACTION_FAVORITE) {
        currentFavAction = FAV_NONE;
        [self removeFav:nil];
        
    } else {
        currentFavAction = FAV_NONE;
        // Dzh
        if (detailIsFav) {
            [self removeFav:nil];
        } else {
            [self addFav:nil];
        }
    }
}



-(IBAction)detailsDownFullText:(id)sender {
    // Zhihong.Ding: 保存下载全文到本地
    NSLog(@"add to list");
    
    NSArray* results;
    
    if(currentActionSelected == SIDEACTION_SEARCH)
        results=[self.searchedResult objectForKey:@"results"];
    else if(currentActionSelected == SIDEACTION_FAVORITE)
        results=self.favArrays;
    
    
    
    if(results == (id)[NSNull null]  || [results count] ==0)
    {
        NSLog(@"no results");
        return;
    }
    
    NSLog(@"results = %@",results);
    
    NSDictionary* result;
    if(currentActionSelected == SIDEACTION_SEARCH)
        result=[results objectAtIndex:currentDisplayingRow];
    else if(currentActionSelected == SIDEACTION_FAVORITE)
        result=[results objectAtIndex:currentDisplayingRow];
    
    [self addToDownloadArraysWith:result];
    
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已加入本地文献"];
}

-(void)addToDownloadArraysWith:(NSDictionary*)result {
    NSString* eId =[result objectForKey:@"externalId"];
    
    NSLog(@"eid %@",eId);
    
    int c= [self.downloadArrays count];
    BOOL inList = NO;
    
    for(int i =0;i<c;i++)
    {
        NSDictionary* m =[self.downloadArrays objectAtIndex:i];
        if([eId isEqualToString:[m objectForKey:@"externalId"]])
        {
            inList =YES;
            break;
        }
        
    }
    
    NSLog(@"inList ok");
    
    if(!inList)
    {
        [self.downloadArrays addObject:result];
        
        [myDatabaseOption savedDoc:result];
    }
}

- (void)remvoeFromDownloadArraysWith:(NSString*)eId {
    int c= [self.downloadArrays count];
    BOOL inList = NO;
    
    for(int i =0;i<c;i++)
    {
        NSDictionary* m =[self.downloadArrays objectAtIndex:i];
        if([eId isEqualToString:[m objectForKey:@"externalId"]])
        {
            inList =YES;
            
            [self.downloadArrays removeObjectAtIndex:i];
            
            [myDatabaseOption removeSavedDoc:eId];
            return;
        }
    }
}


-(void)removeDocumentFromLocation:(NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError* error = [[NSError alloc] init];
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]){
            NSLog(@"remove %@ error: %@", filePath, [error localizedFailureReason]);
        }
        NSLog(@"remove %@", filePath);
    }
}

-(void)disabledSwitchButton {
    self.switchButton.enabled = false;
}

-(void)enabledSwitchButton {
    self.switchButton.enabled = true;
}

-(IBAction)fulltextButtonTapped {
    [self disabledSwitchButton];  // dzh
    if (currentActionSelected == SIDEACTION_DOWNLOADED && locationTabBarStatus == LOCATION_TAB_BAR_HAS_SAVED) {
        NSLog(@"downLoad table bar has saved");
    } else {
        if(![NetStatusChecker isNetworkAvailbe])
        {
            [self netWorksWarning];
            [self enabledSwitchButton];  // DZH
            return;
        }
    }
    
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!useLogined)
    {
        [self remindLogin];
        return;
    } else if(!appDelegate.auth.imdToken.length > 0) {
        [self remindLogin];
        return;
    }
    
    [self downOrRequest];
}

- (void)downOrRequest {
    NSArray* results;
    NSDictionary* result;
    
    if(currentActionSelected == SIDEACTION_DOWNLOADED)
    {
        if (locationTabBarStatus == LOCATION_TAB_BAR_ASKING) {
            UIAlertView* myAlert = [[UIAlertView alloc] initWithTitle:@"已发送过索取请求" message:@"请查收您的“注册邮箱”或者关注“本地文献”中“索取中/已索取”文献列表" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
            
            [myAlert show];
            return;
        }
        else if(locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS) {
            results =self.requestArrays;
            if (self.downAskDetail != nil) {
                result = [self.downAskDetail objectForKey:@"article"];
            } else {
                NSLog(@"it is a bug.");
            }
        }
        else {
            results =self.downloadArrays;
            //      result =[results objectAtIndex:[results count]-1-
            //               currentDisplayingRow];
            result = self.downAskDetail;
        }
    }
    else  if(currentActionSelected == SIDEACTION_FAVORITE)
    {
        
        results =self.favArrays;
        result =[results objectAtIndex:currentDisplayingRow];
    }
    else
    {
        results =[self.searchedResult objectForKey:@"results"];
        result =[results objectAtIndex:currentDisplayingRow];
        
    }
    
    
    if([results count] ==0) {
        [self enabledSwitchButton];  // dzh
        return;
    }
    
    
    if(currentActionSelected == SIDEACTION_DOWNLOADED)
    {
        
        NSString* eId =[result objectForKey:@"externalId"];
        NSString* fileId =[Util md5:eId];
        NSString* fileName = [NSString stringWithFormat:@"%@.pdf",fileId];
        NSString* fileTitle =[result objectForKey:@"title"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        
        NSLog(@"filePath %@",filePath);
        
        //check if local file exitst, if exist just display it
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            NSLog(@"found local file %@ %@",filePath,result);
            
            //NSString* fileName = [filePath lastPathComponent];
            
            fullViewController* fVC =[[fullViewController alloc] initWithNibName:@"fullViewController" bundle:nil];
            fVC.currentPdfName =fileName;
            fVC.currentPdfTitle =fileTitle;
            fVC.exterid = eId;
            if([self loadPDFTest:fileName])
            {
                NSLog(@"loaded");
                self.fullTextController =nil;
                self.fullTextController =fVC;
                //      fVC.delegate = self;
                //        [self.view addSubview:fVC.view];
                [self presentViewController:fVC animated:YES completion:nil];
                fullTextIsShow = YES;
                if(currentActionSelected == SIDEACTION_DOWNLOADED){
                    fVC.saveButton.hidden =YES;
                } else {
                    fVC.saveButton.hidden =NO;
                }
                [self enabledSwitchButton];  // DZH
                return;
            }
            else
            {
                
                NSError *error;
                if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
                {
                    //TODO: Handle/Log error
                    
                    NSLog(@"del failed %@",error);
                }
                [self enabledSwitchButton];  // DZH
                // return;
                
            }
        }
        else
        {
            NSLog(@"not found file");
            int rCount  =[self.requestArrays count];
            NSLog(@"rCount:%i", rCount);
            if(locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS ||
               locationTabBarStatus == LOCATION_TAB_BAR_HAS_SAVED)
            {
                
                downWifiOnly =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downWifiOnly"] boolValue];
                if(downWifiOnly && ![NetStatusChecker isUsingWifi])
                {
                    NSLog(@"downWifiOnly");
                    [self wifiDownloadWarning];
                    [self enabledSwitchButton];  // DZH
                    return;
                    
                }
                
                
                //todo：download directly
                NSLog(@"down this directly");
                
                [self showMsgBarWithLoading:@"正在为您获取全文..."];
                [ImdAppBehavior downloadFullText];
                
                NSString* eId =[result objectForKey:@"externalId"];
                NSString* iId =[result objectForKey:@"internalId"];
                NSString* title =[result objectForKey:@"fileTitle"];
                if (title == (id)[NSNull null] || title.length == 0) {
                    title = [result objectForKey:@"title"];
                }
                NSString* fn = [self fileNameWithExternelId:eId];
                NSString* fp = [self filePathInDocuments:fn];
                [self downloadAskPDFwithExternalId:eId andInternalId:iId displayFullText:YES title:title
                                          filePath:fp fileName:fn];
            }
        }
        return;
    }
    
    if(currentActionSelected == SIDEACTION_FAVORITE)
    {
        
        NSString* eId =[result objectForKey:@"externalId"];
        NSString* fileId =[Util md5:eId];
        NSString* fileName = [NSString stringWithFormat:@"%@.pdf",fileId];
        NSString* fileTitle =[result objectForKey:@"title"];
        NSString *filePath =
		[[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:fileName];
        NSLog(@"filePath %@",filePath);
        
        //check if local file exitst, if exist just display it
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            NSLog(@"found local file %@",filePath);
            
            fullViewController* fVC =[[fullViewController alloc] initWithNibName:@"fullViewController" bundle:nil];
            fVC.currentPdfName =fileName;
            fVC.currentPdfTitle =fileTitle;
            fVC.exterid = eId;
            if([self loadPDFTest:fileName])
            {
                NSLog(@"loaded");
                self.fullTextController =nil;
                self.fullTextController =fVC;
                //      fVC.delegate = self;
                //        [self.view addSubview:fVC.view];
                [self presentViewController:fVC animated:YES completion:nil];
                fullTextIsShow = YES;
                fVC.saveButton.hidden =NO;
                
                [self enabledSwitchButton];  // DZH
                return;
            }
            else
            {
                /*self.loadingLabel.hidden = YES;
                 [self.loadingIndicator stopAnimating];
                 self.errorLabel.text =@"pdf出错,请稍候重试";
                 self.errorLabel.hidden = NO;*/
                
                NSError *error;
                if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
                {
                    //TODO: Handle/Log error
                    
                    NSLog(@"del failed %@",error);
                }
                [self enabledSwitchButton];  // DZH
                // return;
                
            }
        }
        
    }
    
    inFullText = YES;
    
    int lan;
    
    if(currentActionSelected == SIDEACTION_DOWNLOADED)
    {
        NSString* PMID =[result objectForKey:@"PMID"];
        
        if(PMID == nil)
            lan = SEARCH_MODE_CN;
        else
            lan = SEARCH_MODE_EN;
        
        
    }
    else if (currentActionSelected == SIDEACTION_FAVORITE){
        NSString* PMID =[[self.favDetail objectForKey:@"article"] objectForKey:@"PMID"];
        
        if(PMID == nil || [PMID isEqualToString:@""])
            lan = SEARCH_MODE_CN;
        else
            lan = SEARCH_MODE_EN;
    }
    else
    {
        //lan =currentResultLanguage;
        NSString*PMID = [result objectForKey:@"PMID"];
        if(PMID == nil || [PMID isEqualToString:@""])
            lan = SEARCH_MODE_CN;
        else
            lan = SEARCH_MODE_EN;
    }
    
    
    if (lan == SEARCH_MODE_CN)
    {
        NSLog(@"cn fulltext");
        
        NSString* eId =[result objectForKey:@"externalId"];
        NSString* fileId =[Util md5:eId];
        NSString* fileName = [NSString stringWithFormat:@"%@.pdf",fileId];
        NSString* fileTitle =[result objectForKey:@"title"];
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:fileName];
        NSLog(@"filePath %@",filePath);
        
        //check if local file exitst, if exist just display it
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            NSLog(@"found local file %@",filePath);
            
            //NSString* fileName = [filePath lastPathComponent];
            fullViewController* fVC =[[fullViewController alloc] initWithNibName:@"fullViewController" bundle:nil];
            fVC.currentPdfName =fileName;
            fVC.currentPdfTitle =fileTitle;
            fVC.exterid = eId;
            if([self loadPDFTest:fileName])
            {
                ///NSLog(@"loaded");
                self.fullTextController =nil;
                self.fullTextController =fVC;
                
                [self presentViewController:fVC animated:YES completion:nil];
                fullTextIsShow = YES;
                [self enabledSwitchButton]; // DZH
                return;
            }
            else
            {
                NSError *error;
                if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
                {
                    //TODO: Handle/Log error
                    NSLog(@"del failed %@",error);
                }
                [self enabledSwitchButton];  // DZH
            }
        }
        
        downWifiOnly =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downWifiOnly"] boolValue];
        if(downWifiOnly && ![NetStatusChecker isUsingWifi])
        {
            [self wifiDownloadWarning];
            [self enabledSwitchButton];  // DZH
            return;
        }
        
        [self showMsgBarWithLoading:@"正在为您获取全文..."];
        
        [ImdAppBehavior downloadFullText];
        
        NSString* fileURL = [NSString stringWithFormat:@"http://%@/docsearch/download/%@/",PDFPROCESS_SERVER,eId];
        
        NSLog(@"url a = %@",fileURL);
        self.fullTextDownloader = nil;
        
        
        self.fullTextDownloader = [downloader requestWithURL:[NSURL URLWithString:fileURL]];
        //self.fullTextDownloader.fileName = @"result.pdf";
        
        [self.fullTextDownloader addRequestHeader:@"Content-Type" value:@"application/json"];
        [self.fullTextDownloader addRequestHeader:@"Accept" value:@"application/json"];
        
        self.fullTextDownloader.fileName =fileName;
        self.fullTextDownloader.fileURL = fileURL;
        self.fullTextDownloader.filePath = filePath;
        
        self.fullTextDownloader.timeOutSeconds = 120;
        
        //self.fullTextDownloader.downloadType = MEETING_SLIDERS;
        self.fullTextDownloader.retryingTimes = 0;
        self.fullTextDownloader.retryingMaxTimes = 1;
        
        [self.fullTextDownloader setDownloadDestinationPath:self.fullTextDownloader.filePath];
        
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
        [userInfo setObject:@"requestPDF" forKey:@"requestType"];
        [userInfo setObject:self.fullTextDownloader.fileName forKey:@"downloadFile"];
        [userInfo setObject:fileTitle forKey:@"downloadTitle"];
        [userInfo setObject:filePath forKey:@"downloadPath"];
        
        [self.fullTextDownloader setUserInfo:userInfo];
        
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
        NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
        NSLog(@"token =%@",token);
        //[request addRequestHeader:@"Cookie" value:token];
        
        //Create a cookie
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/download"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [self.fullTextDownloader setUseCookiePersistence:NO];
        [self.fullTextDownloader setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
      NSString *curVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
      NSString *systemVer =  [[UIDevice currentDevice] systemVersion];
      [self.fullTextDownloader setUserAgent:[NSString stringWithFormat:@"imd-ios-iPad(version:%@,systemversion:%@)",curVer,systemVer]];
        
        self.fullTextDownloader.delegate = self;
        [self.fullTextDownloader startAsynchronous];
        
    } else {
        NSString* eId =[result objectForKey:@"externalId"];
        
        if (currentActionSelected == SIDEACTION_SEARCH) {
            NSString* status = [self.detailSearch objectForKey:@"fetchStatus"];
            if (status != nil && ![status isEqualToString:@"SUCCESS"] &&
                ![status isEqualToString:@""]) {
                [self hideMsgBar];
                UIAlertView* myAlert = [[UIAlertView alloc] initWithTitle:@"已发送过索取请求" message:@"请查收您的“注册邮箱”或者关注“本地文献”中“索取中/已索取”文献列表" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"立即查看", nil];
                jumpExternalId = eId;
                [myAlert show];
                return;
            }
        }
        
        if (currentActionSelected == SIDEACTION_FAVORITE) {
            NSString* status = [self.favDetail objectForKey:@"fetchStatus"];
            if (status != nil && ![status isEqualToString:@"SUCCESS"] &&
                ![status isEqualToString:@""]) {
                [self hideMsgBar];
                UIAlertView* myAlert = [[UIAlertView alloc] initWithTitle:@"已发送过索取请求" message:@"请查收您的“注册邮箱”或者关注“本地文献”中“索取中/已索取”文献列表" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"立即查看", nil];
                jumpExternalId = eId;
                [myAlert show];
                return;
            }
        }
        //EN
        
        NSString* fileId =[Util md5:eId];
        NSString* fileName = [NSString stringWithFormat:@"%@.pdf",fileId];
        NSString* fileTitle =[result objectForKey:@"title"];
        NSString *filePath =
        [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:fileName];
        NSLog(@"filePath %@",filePath);
        
        //check if local file exitst, if exist just display it
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            NSLog(@"found local en file %@",filePath);
            
            //NSString* fileName = [filePath lastPathComponent];
            
            fullViewController* fVC =[[fullViewController alloc] initWithNibName:@"fullViewController" bundle:nil];
            fVC.currentPdfName =fileName;
            fVC.currentPdfTitle =fileTitle;
            fVC.exterid = eId;
            if([self loadPDFTest:fileName])
            {
                ///NSLog(@"loaded");
                self.fullTextController =nil;
                self.fullTextController =fVC;
                
                [self presentViewController:fVC animated:YES completion:nil];
                fullTextIsShow = YES;
                [self enabledSwitchButton];  // DZH
                return;
            }
            else
            {
                NSError *error;
                if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
                {
                    //TODO: Handle/Log error
                    NSLog(@"del failed %@",error);
                }
                [self enabledSwitchButton];  // DZH
            }
        }
        
        BOOL inList = NO;
        
        if (currentActionSelected == SIDEACTION_SEARCH &&
            [[self.detailSearch objectForKey:@"fetchStatus"] isEqualToString:@"SUCCESS"]) {
            inList = YES;
            result = self.detailSearch;
        }
        
        if (currentActionSelected == SIDEACTION_FAVORITE &&
            [[self.favDetail objectForKey:@"fetchStatus"] isEqualToString:@"SUCCESS"]) {
            inList = YES;
            result = self.favDetail;
        }
        
        if(!inList)
        {
            [self showMsgBarWithLoading:@"正在检查索取状态"];
            [self askForPDF:nil];
        } else {
            NSLog(@"in list,check it");
            NSDictionary* m = [result objectForKey:@"article"];
            downWifiOnly =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downWifiOnly"] boolValue];
            
            if(downWifiOnly && ![NetStatusChecker isUsingWifi])
            {
                [self wifiDownloadWarning];
                [self enabledSwitchButton];  // DZH
                return ;
            }
            
            NSLog(@"down this");
            [self showMsgBarWithLoading:@"正在为您获取全文..."];
            [ImdAppBehavior downloadFullText];
            
            NSString* eId =[m objectForKey:@"externalId"];
            NSString* iId =[m objectForKey:@"internalId"];
            
            NSString* fn = [self fileNameWithExternelId:eId];
            NSString* fp = [self filePathInCache:fn];
            [self downloadAskPDFwithExternalId:eId andInternalId:iId displayFullText:YES title:fileTitle filePath:fp fileName:fn];
        }
    }
}

-(IBAction)detailsShare:(id)sender {
    shareSelectViewController *content = [[shareSelectViewController alloc] initWithNibName:@"shareSelectViewController" bundle:nil];
    
    sharePopoverController= [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    //content.tag =[sender tag];
    
	sharePopoverController.popoverContentSize = CGSizeMake(280., 150.);
	sharePopoverController.delegate = self;
    
    UIButton* t =(UIButton*)sender;
    CGRect frame=CGRectMake(t.frame.origin.x +420, t.frame.origin.y, t.frame.size.width, t.frame.size.height);
    
    // Present the popover from the button that was tapped in the detail view.
	[sharePopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - share function
- (void)shareSelected:(id)sender {
    [sharePopoverController dismissPopoverAnimated:YES];
    
    NSLog(@"share selected");
}

#pragma mark - polling functions
- (IBAction)backToCallingApp:(id)sender {
    NSURL *url = [NSURL URLWithString:@"NovartisDemo:meeting"];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)registerOK:(id)sender
{
}

#pragma mark - page controls
-(void) nextPage {
    
    if(pdfValue == self.pdfView.pageCount) return;
    
    pdfValue++;
    if(pdfValue>=self.pdfView.pageCount)
    {
        pdfValue=self.pdfView.pageCount;
    }
    
    [UIView beginAnimations:@"move to left" context:nil];
    [UIView setAnimationDuration:0.3f];
    
    
    CGRect frame =self.pdfView.frame;
    self.pdfView.frame =CGRectMake(-frame.size.width, 0, frame.size.width, frame.size.height);
    self.nextPdfView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    [UIView setAnimationDidStopSelector:@selector(swipeLeftCompleted)];
    [UIView setAnimationDelegate: self];
    [UIView commitAnimations];
    
    self.pageNo.text =[NSString stringWithFormat:@"%d/%d",pdfValue,self.pdfView.pageCount];
}

-(void) prePage {
    
    if(pdfValue == 1) return;
    
    pdfValue--;
    if(pdfValue<=1) {
        pdfValue=1;
    }
    
    [UIView beginAnimations:@"move to right" context:nil];
    [UIView setAnimationDuration:0.3f];
    
    CGRect frame =self.pdfView.frame;
    
    self.pdfView.frame =CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height);
    
    self.prePdfView.frame = frame;
    
    [UIView setAnimationDidStopSelector:@selector(swipeRightCompleted)];
    [UIView setAnimationDelegate: self];
    [UIView commitAnimations];
    
    self.pageNo.text =[NSString stringWithFormat:@"%d/%d",pdfValue,self.pdfView.pageCount];
    
}


- (void)pdfHandleAllSwipes:(UISwipeGestureRecognizer *)recognizer {
    if(self.detailView.zoomScale!=1.0f)     return;
	
    if (recognizer.direction & UISwipeGestureRecognizerDirectionLeft) {
		NSLog(@"left");
        
        [self nextPage];
        return;
    }
    
    if (recognizer.direction & UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"right");
        
        [self prePage];
        return;
	}
}


- (void)helpSwipes:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction & UISwipeGestureRecognizerDirectionLeft) {
		NSLog(@"help left");
        
        if(currentHelp ==2)return;
        currentHelp++;
        //self.helpPageControl.currentPage =currentHelp;
        [self.helpPageControl setCurrentPage:currentHelp];
        [self changePage];
        
        return;
    }
    
    if (recognizer.direction & UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"help right");
        if(currentHelp ==0) return;
        
        currentHelp--;
        //[self changeHelp:nil];
        //self.helpPageControl.currentPage =currentHelp;
        [self.helpPageControl setCurrentPage:currentHelp];
        [self changePage];
        
        return;
	}
}

#pragma mark - zoom
-(IBAction)pdfZoomOut {
    CGFloat zoomScale = self.detailView.zoomScale;
    zoomScale -=0.2f;
    [self.detailView setZoomScale:zoomScale animated:YES];
}

-(IBAction)pdfZoomIn {
    CGFloat zoomScale = self.detailView.zoomScale;
    zoomScale +=0.2f;
    [self.detailView setZoomScale:zoomScale animated:YES];
}

#pragma mark - UIScrollView delegate


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return  self.pdfBackView;
}


-(void)handleOneTouch:(UITapGestureRecognizer *)recognizer {
    NSLog(@"handle one touch called");
 	NSInteger numberOfTaps = recognizer.numberOfTapsRequired;
    
    if(2 == numberOfTaps)
    {
        [self.detailView setZoomScale:1.0f animated:YES];
        
    } 
}

- (void)startReady
{
    self.startCover.hidden = YES;
}

- (void)checkNewAskfor {
    // 显示新到信息
    newBadgeCount=[[[NSUserDefaults standardUserDefaults] objectForKey:@"newBadges"] intValue];
    //newBadgeCount =2;
    if(newBadgeCount>0)
    {
        [self displayBadges];
    }
}

- (void)showHelpCover {
    //    self.helpCover.hidden = NO;
    [self sideActionPressed:self.sideActionHelpButton];
}

-(void)hideHelpCover {
    self.helpCover.hidden = YES;
}

- (void)loadFav {
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    
    if(!useLogined)
    {
        [self showBigCoverBgWithLoading:false];
        return;
    }
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        //[self netWorksWarning];
        [self showBigCoverBgWithLoading:false];
        [self showCoverBgWithErrorMsg:@"网络出错-­‐请检查网络设置"];
        return;
    }
    
    self.httpRequestFavoritesSync = [self favoritesSync];
    
}


- (void)addFav:(NSString*)fid {
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        [self netWorksWarning];
        return;
    }
    
    NSArray* results;
    if(currentActionSelected == SIDEACTION_SEARCH)
        results=[self.searchedResult objectForKey:@"results"];
    else if(currentActionSelected == SIDEACTION_DOWNLOADED)
    {
        if(locationTabBarStatus == LOCATION_TAB_BAR_ASKING)
            results =self.requestDownArrays;
        else if (locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS)
        {
            results = self.requestArrays;
        }
        else
            results=self.downloadArrays;
    }
    
    if(results == (id)[NSNull null]  || [results count] ==0)
    {
        NSLog(@"no results");
        return;
    }
    
    //NSLog(@"results = %@",results);
    
    NSDictionary* result;
    
    if(currentActionSelected == SIDEACTION_SEARCH)
        result = [self.detailSearch objectForKey:@"article"];
    else if(currentActionSelected == SIDEACTION_DOWNLOADED)
    {
        if (locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS ||
            locationTabBarStatus == LOCATION_TAB_BAR_ASKING)
        {
            result = [[results objectAtIndex:currentDisplayingRow]objectForKey:@"shortDocInfo"];
        }
        else
            result = [results objectAtIndex:[results count] - currentDisplayingRow - 1];
    }
    
    NSLog(@"result =%@",result);
    
    
    NSString* eId =[result objectForKey:@"externalId"];
    if (eId == nil) {
        eId = [result objectForKey:@"id"];
    }
    if(fid ==nil)fid =eId;
    
    NSString* title = [result objectForKey:@"title"];
    //to fix crash when addfav to askedfor docs.
    if(title == nil)
        title =[result objectForKey:@"fileTitle"];
    NSLog(@"title =%@",title);
    
    
    if (currentActionSelected == SIDEACTION_SEARCH) {
        [ImdAppBehavior doFavoriteLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_SEARCH action:ACT_ADD];
    } else if (currentActionSelected == SIDEACTION_DOWNLOADED) {
        if (!self.downFileListView.hidden) {
            [ImdAppBehavior doFavoriteLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_LOCA action:ACT_ADD];
        } else if (!self.downRequestListView.hidden) {
            [ImdAppBehavior doFavoriteLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_ASKING action:ACT_ADD];
        } else if (!self.downAskSuccessListView.hidden) {
            [ImdAppBehavior doFavoriteLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_ASKED action:ACT_ADD];
        }
    }
    
    
    title = [Util replaceEM:title LeftMark:@"" RightMark:@""];
    title =[Util URLencode:title stringEncoding:NSUTF8StringEncoding];
    
    NSString* addFavURL =[NSString stringWithFormat:@"http://%@/docsearch/fav?id=%@&title=%@",SEARCH_SERVER,fid,title];
    
    NSLog(@"addFav url = %@",addFavURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:addFavURL]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:YES];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"addFav" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
}

- (void)removeFav:(NSString*)fid {
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        [self netWorksWarning];
        return;
    }
    
    NSArray* results;
    if(currentActionSelected == SIDEACTION_DOWNLOADED)
    {
        //    int rCount =[self.requestDownArrays count];
        
        if(locationTabBarStatus == LOCATION_TAB_BAR_ASKING)
            results =self.requestDownArrays;
        else if (locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS)
        {
            results = self.requestArrays;
        }
        else
            results=self.downloadArrays;
    }
    else if(currentActionSelected == SIDEACTION_FAVORITE)
        results=self.favArrays;
    
    if(currentActionSelected != SIDEACTION_SEARCH)
    {
        if (results == (id)[NSNull null]  || [results count] == 0)
        {
            NSLog(@"no results");
            return;
        }
    }
    
    NSDictionary* result;
    
    if(currentActionSelected == SIDEACTION_SEARCH)
        result = [self.detailSearch objectForKey:@"article"];
    else if(currentActionSelected == SIDEACTION_DOWNLOADED) {
        //    if(locationTabBarStatus == LOCATION_TAB_BAR_ASKING)
        //      results =self.requestDownArrays;
        //    else
        if (locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS ||
            locationTabBarStatus == LOCATION_TAB_BAR_ASKING)
        {
            result = [[results objectAtIndex:currentDisplayingRow]objectForKey:@"shortDocInfo"];
        }
        else
            result = [results objectAtIndex:[results count] - currentDisplayingRow-1];
        NSLog(@"result == %@", result);
    } else
        result=[results objectAtIndex:currentDisplayingRow];
    NSString* eId =[result objectForKey:@"externalId"];
    if (eId == nil) {
        eId = [result objectForKey:@"id"];
    }
    if(fid ==nil)fid =eId;
    
    NSLog(@"removing %@",fid);
    
    NSString* title = [result objectForKey:@"title"];
    //to fix crash when addfav to askedfor docs.
    if(title == nil)
        title =[result objectForKey:@"fileTitle"];
    NSLog(@"title =%@",title);
    
    
    if (currentActionSelected == SIDEACTION_SEARCH) {
        [ImdAppBehavior doFavoriteLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_SEARCH action:ACT_DEL];
    } else if (currentActionSelected == SIDEACTION_FAVORITE) {
        [ImdAppBehavior doFavoriteLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_FAV action:ACT_DEL];
    } else if (currentActionSelected == SIDEACTION_DOWNLOADED) {
        if (!self.downFileListView.hidden) {
            [ImdAppBehavior doFavoriteLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_LOCA action:ACT_DEL];
        } else if (!self.downRequestListView.hidden) {
            [ImdAppBehavior doFavoriteLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_ASKING action:ACT_DEL];
        } else if (!self.downAskSuccessListView.hidden) {
            [ImdAppBehavior doFavoriteLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_ASKED action:ACT_DEL];
        }
    }
    
    NSString* removeFavURL =[NSString stringWithFormat:@"http://%@/docsearch/removefav/%@",SEARCH_SERVER,fid];
    
    NSLog(@"url = %@",removeFavURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:removeFavURL]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:YES];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"removeFav" forKey:@"requestType"];
    [userInfo setObject:fid forKey:@"externalId"];
    
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    
}

- (IBAction)favEditButtonTapped {
    if([self.favList isEditing])
    {
        [self.favList setEditing:NO animated:YES];
        [self.favEditButton setTitle:@"编辑" forState:UIControlStateNormal];
        
    } else {
        [self.favList setEditing:YES animated:YES];
        [self.favEditButton setTitle:@"完成" forState:UIControlStateNormal];
    }
}

- (IBAction)downEditButtonTapped {
    int rCount = [self.requestDownArrays count];
    int dCount = [self.downloadArrays count];
    if(rCount == 0 && dCount ==0)   return;
}

-(IBAction)fullTextSwitchScreen:(id)sender {
    self.listSearchView.hidden =YES;
}

-(NSString*)fetchSortMethod:(int)way {
    if(way ==0) return @"5";
    if(way ==1) return @"1";
    if(way ==2) return @"3";
    return nil;
}

-(void)showBigCoverBgWithLoading:(BOOL)isLoading {
    if (isLoading) {
        self.bigCoverView.hidden = NO;
    } else {
        self.bigCoverView.hidden = YES;
    }
}

-(void)showCoverBgWithLoading:(BOOL)isLoading {
    self.searchResultCoverView.hidden =NO;
    
    if(isLoading) {
        self.loadingView.hidden =NO;
        //self.loadingLabel.hidden = NO;
        //[self.loadingIndicator startAnimating];
        self.errorLabel.hidden =YES;
        self.coverBg.image = [UIImage imageNamed:@"bg-loadingFullText"];
        
    } else {
        self.loadingView.hidden =YES;
        //self.loadingLabel.hidden = YES;
        //[self.loadingIndicator stopAnimating];
        self.errorLabel.hidden =YES;
        self.coverBg.image = [UIImage imageNamed:@"bg-default"];
    }
}

-(void)showCoverBgWithErrorMsg:(NSString*)errMsg {
    self.loadingView.hidden =YES;
    self.coverBg.image = [UIImage imageNamed:@"bg-loadingFullText"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:errMsg delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    alert.tag =0;
    [alert show];
}

-(IBAction)checkRequestList:(id)sender {
    
    if([self.requestArrays count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"没有索取中的文件" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
        
    } //*/
    
    if(downloadDisplaying  == DOWNLOAD_DISPLAYING_FILE) {
        [UIView beginAnimations:@"FlipViewToRequest" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationRepeatAutoreverses:NO];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.downRequestListView cache:YES];//oglFlip, fromLeft
        
        
        self.downFileListView.hidden =YES;
        self.downRequestListView.hidden =NO;
        //    self.downEditButton.hidden =YES;
        self.downTitle.text =@"索取文献";
        
        
        [UIView commitAnimations];
        downloadDisplaying = DOWNLOAD_DISPLAYING_REQUEST;
        
    } else {
        [UIView beginAnimations:@"FlipViewToFile" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationRepeatAutoreverses:NO];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.downFileListView cache:YES];//oglFlip, fromLeft
        
        self.downFileListView.hidden =NO;
        self.downRequestListView.hidden =YES;
        //    self.downEditButton.hidden =NO;
        self.downTitle.text =@"本地文献";
        
        [UIView commitAnimations];
        
        downloadDisplaying = DOWNLOAD_DISPLAYING_FILE;
    }
}

-(void)askForPDF:(id)sender {
    [ImdAppBehavior askforFullText];
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        [self netWorksWarning];
        [self enabledSwitchButton];  // DZH
        return;
    }
    //[askFullTextPopover dismissPopoverAnimated:YES];
    
    NSArray* results;
    NSDictionary* result;
    
    if(currentActionSelected == SIDEACTION_DOWNLOADED)
    {
        results =self.downloadArrays;
        result =[results objectAtIndex:[results count] - 1 - currentDisplayingRow];
    } else if(currentActionSelected == SIDEACTION_FAVORITE) {
        results =self.favArrays;
        result = [self.favDetail objectForKey:KEY_DOCU];
    } else {
        results =[self.searchedResult objectForKey:@"results"];
        result =[results objectAtIndex:currentDisplayingRow];
    }
    
    NSString* externalId = [NSString stringWithFormat:@"%@", [result objectForKey:@"externalId"]];
    
    NSString* rawtitle = [NSString stringWithFormat:@"%@", [result objectForKey:@"title"]];
    NSString *r1 = [rawtitle stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
    NSString *r2 = [r1 stringByReplacingOccurrencesOfString:@"</em>" withString:@""];
    NSString* title =[Util URLencode:r2 stringEncoding:NSUTF8StringEncoding];
    
    if (currentActionSelected == SIDEACTION_SEARCH) {
        [ImdAppBehavior doAskforLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_SEARCH];
    } else if (currentActionSelected == SIDEACTION_FAVORITE) {
        [ImdAppBehavior doAskforLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_FAV];
    } else if (currentActionSelected == SIDEACTION_DOWNLOADED) {
        if (!self.downFileListView.hidden) {
            [ImdAppBehavior doAskforLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_LOCA];
        } else if (!self.downRequestListView.hidden) {
            [ImdAppBehavior doAskforLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_ASKING];
        } else if (!self.downAskSuccessListView.hidden) {
            [ImdAppBehavior doAskforLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_ASKED];
        }
    }
    
    //NSString* askURL =[NSString stringWithFormat:@"http://%@/docsearch/askfor?id=%@&title=%@",@"www.qa.i-md.com",externalId,title];
    NSString *deviceNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceNumber"];
    NSString* askURL =[NSString stringWithFormat:@"http://%@/docsearch/askfor?id=%@&title=%@&devices=%@",SEARCH_SERVER,externalId,title,[Util URLencode:deviceNumber stringEncoding:NSUTF8StringEncoding]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:askURL]];
    NSLog(@"ask url =%@",askURL);
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
  NSString *curVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  NSString *systemVer =  [[UIDevice currentDevice] systemVersion];
  [self.fullTextDownloader setUserAgent:[NSString stringWithFormat:@"imd-ios-iPad(version:%@,systemversion:%@)",curVer,systemVer]];
  
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"askFullText" forKey:@"requestType"];
    [userInfo setObject:externalId forKey:@"askingId"];
    [userInfo setObject:rawtitle forKey:@"askingTitle"];
    [userInfo setObject:result forKey:@"item"];
    
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    
    [self showMsgBarWithLoading:@"正在为您获取全文..."];
}

-(void)loadRequestArray {
    if(![NetStatusChecker isNetworkAvailbe])
    {
        //[self netWorksWarning];
        return;
    }
    
    NSString* askURL =[NSString stringWithFormat:@"http://%@/docsearch/askforlist?status=%@&start=%d&limit=%d", SEARCH_SERVER, @"true", 0, 30];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:askURL]];
    
    NSLog(@"askrqarray url =%@",askURL);
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"askforReqArray" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
}

-(void)loadAskforSync:(BOOL)limit {
    if (limit) {
        [self locationAskSync:@"true"];
    } else {
        [self locationAskSync:@"false"];
    }
}

-(BOOL)loadRequestStatusWithExternalId:(NSString *)externalId {
    if (externalId == nil || [externalId isEqualToString:@""]) {
        return false;
    }
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        return false;
    }
    
    NSString* askURL =[NSString stringWithFormat:@"http://%@/docsearch/askforstatus",SEARCH_SERVER];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:askURL]];
    
    NSLog(@"ask url =%@",askURL);
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    request.requestMethod =@"POST";
    
    NSMutableArray* askforId=[[NSMutableArray alloc] initWithCapacity:20];
    
    [askforId addObject:externalId];
    
    [request appendPostData:[[askforId JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_JUMP_ASK_CHECK_STATUES forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    return true;
}

-(void)loadRequestStatus {
    if(![NetStatusChecker isNetworkAvailbe])
    {
        return;
    }
    
    int count =[self.requestArrays count];
    
    if(count==0)return;
    
    NSString* askURL =[NSString stringWithFormat:@"http://%@/docsearch/askforstatus",SEARCH_SERVER];
    //NSString* askURL =[NSString stringWithFormat:@"http://%@/docsearch/askforstatus",@"192.168.1.21:9000/client"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:askURL]];
    
    NSLog(@"ask url =%@",askURL);
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    request.requestMethod =@"POST";
    //[request addRequestHeader:@"charset" value:@"utf-8"];
    
    NSMutableArray* askforId=[[NSMutableArray alloc] initWithCapacity:20];
    
    for(int i=0;i<count;i++)
    {
        NSDictionary* item =[self.requestArrays objectAtIndex:i];
        [askforId addObject:[item objectForKey:@"externalId"]];
    }
    
    [request appendPostData:[[askforId JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"askforListStatus" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    
}

-(IBAction)changeHelp:(id)sender {
    if(currentHelp ==0)
    {
        //currentHelp++;
        self.helpImageView.image =[UIImage imageNamed:@"iPad-DocumentSearch_help_01"];
    }
    else if(currentHelp ==1)
    {
        self.helpImageView.image =[UIImage imageNamed:@"iPad-DocumentSearch_help_02"];
    }
    else if(currentHelp ==2)
    {
        self.helpImageView.image =[UIImage imageNamed:@"iPad-DocumentSearch_help_03"];
    }
    else
    {
        self.helpImageView.image =[UIImage imageNamed:@"iPad-DocumentSearch_help_04"];
    }
}



-(void)checkFavStatus:(NSString*)externalId {
    
}

#pragma mark - RefreshViewDelegate
- (void)refreshViewDidCallBack {
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    if(!useLogined)
    {
        [self remindLogin];
        return;
    }
    if (![selectedDotFav isHidden]) {
        
        [self loadFav];
        [favView startLoading];
    }
    if (![selectedDotDownload isHidden] && locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS) {
        [self loadAskforSync:YES];
        
        [askedView startLoading];
    }
}

#pragma mark - Scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (![self.selectedDotFav isHidden]) {
        [favView scrollViewDidScroll:sender];
    }
    
    if (![self.selectedDotDownload isHidden] && locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS) {
        [askedView scrollViewDidScroll:sender];
    }
    
    if(sender!= self.helpScrollView)    return;
    
    if (!pageControlBeingUsed)
    {
        CGFloat pageWidth = self.helpScrollView.frame.size.width;
        if(self.helpScrollView.contentOffset.x > self.helpScrollView.contentSize.width-pageWidth*5/6)
        {
            [self exitHelp:nil];
            pageControlBeingUsed =YES;
        }
        
        int page = floor((self.helpScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        NSLog(@"page == %i", page);
        if (page == 4) {
            helpCoverButton.enabled = YES;
        } else {
            helpCoverButton.enabled = NO;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
    if (![selectedDotFav isHidden]) {
        [favView scrollViewWillBeginDragging:scrollView];
    }
    if (![selectedDotDownload isHidden] && locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS) {
        [askedView scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

// 拖动结束后
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == AbstractTextScrollView) {
        return;
    }
    if (![selectedDotFav isHidden]) {
        [favView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (![selectedDotDownload isHidden] && locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS) {
        [askedView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

//-()

- (IBAction)changePage {
    //NSLog(@"change page");
    
	// Update the scroll view to the appropriate page
	CGRect frame;
	frame.origin.x = self.helpScrollView.frame.size.width * self.helpPageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.helpScrollView.frame.size;
	
    [self.helpScrollView scrollRectToVisible:frame animated:YES];
    
	pageControlBeingUsed = YES;
}

-(void)showMsgBarWithLoading:(NSString*)text {
    NSLog(@"showing bar %@",text);
    showingBarLoading =YES;
    
    barLoadingRow =currentDisplayingRow;
    barLoadingAction =currentActionSelected;
    
    self.msgLabel.text =text;
    self.msgLoading.hidden =NO;
    self.msgInfoImage.hidden=YES;
    
    self.msgLabel.textColor = RGBCOLOR(64, 84, 120);
    self.msgLabel.font =[UIFont systemFontOfSize:18.0];
    [self.msgLabel sizeToFit];
    
    float msgw= self.msgLabel.frame.size.width+40;
    
    self.msgLoading.frame =CGRectMake((604-msgw)/2, 10, 20, 20);
    self.msgLabel.frame =CGRectMake((604-msgw)/2+40, 10,self.msgLabel.frame.size.width, self.msgLabel.frame.size.height);
    
    [UIView beginAnimations:@"msg show" context:nil];
    [UIView setAnimationDuration:0.3f];
    self.msgView.frame = CGRectMake(0, 40, 592, 40);
    [UIView commitAnimations];
}

- (void)showMsgBarWithInfo:(NSString *)text
{
    showingBarLoading =YES;
    
    barLoadingRow = currentDisplayingRow;
    barLoadingAction = currentActionSelected;
    
    self.msgLabel.text = text;
    self.msgLoading.hidden = YES;
    self.msgInfoImage.hidden= NO;
    
    self.msgLabel.textColor = RGBCOLOR(64, 84, 120);
    self.msgLabel.font =[UIFont systemFontOfSize:18.0];
    [self.msgLabel sizeToFit];
    
    float msgw= self.msgLabel.frame.size.width+40;
    
    self.msgInfoImage.frame =CGRectMake((604-msgw)/2, 10, 28, 28);
    self.msgLabel.frame =CGRectMake((604-msgw)/2+40, 10,self.msgLabel.frame.size.width, self.msgLabel.frame.size.height);
    
    [UIView beginAnimations:@"msg show" context:nil];
    [UIView setAnimationDuration:0.3f];
    self.msgView.frame = CGRectMake(0, 40, 592, 40);
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(hideMsgBar) withObject:nil afterDelay:10.0f];
}

-(void)hideMsgBar
{
    showingBarLoading =NO;
    
    barLoadingRow = -1;
    barLoadingAction = -1;
    
    [UIView beginAnimations:@"msg hide" context:nil];
    [UIView setAnimationDuration:0.3f];
    self.msgView.frame = CGRectMake(0, 0, 592, 40);
    [UIView commitAnimations];
}

#pragma mark - alertview warning
-(void)netWorksWarning
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"无法连接到互联网，请查看设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}

-(void)wifiDownloadWarning
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"您设置了只在wifi网络环境下载全文" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}

-(void)clearAll
{
    [searchHistory clearHistory];
    self.downloadArrays =nil;
    self.favArrays =nil;
    self.requestArrays =nil;
    self.requestDownArrays =nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"downloadArrays"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"requestArrays"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.downloadArrays =[[NSMutableArray alloc] initWithCapacity:20];
    self.requestArrays =[[NSMutableArray alloc] initWithCapacity:20];
    
    [self updateRequestDown];
    [self showCoverBgWithLoading:NO];
}

-(void)deleteLocat:(BOOL)showAlertView
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [paths objectAtIndex:0];
    [Util DeleteAllInPath:filePath withExtention:@"pdf"];
    if (showAlertView) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"清空本地保存文献完毕。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)deleteCacheSetting
{
    [self deleteCache:true];
}

-(void)deleteCache:(BOOL)showAlertView
{
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    [Util DeleteAllInPath:filePath withExtention:@"pdf"];
    if (showAlertView) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"清空缓存完毕。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
}

-(IBAction)exitHelp:(id)sender
{
    //  NSLog(@"help ====== %@");
    if ([helpCoverButton isHidden]) {
        return;
    }
    self.helpCover.hidden =YES;
    
    //for #3505
    //[self sideActionPressed:self.sideActionSearchButton];
    currentActionSelected = helpDisplayState;
    NSLog(@"display state =%d",displayState);
    [self refreshSideActionButtons];
    [self displayStates];
}

-(int)getDownableRequestCount
{
    int c =[self.requestArrays count];
    if(c==0) return 0;
    
    int rCount = 0;
    for (int i=0; i<c; i++) {
        NSDictionary* item =[self.requestArrays objectAtIndex:i];
        NSString* status =[item objectForKey:@"status"];
        if([status isEqualToString:ASKFULLTEXT_STATE_DOWNLOADABLE])
            rCount++;
    }
    
    return rCount;
}

-(void)updateRequestDown
{
    int c =[self.requestArrays count];
    if (locationTabBarStatus == LOCATION_TAB_BAR_ASKING) {
        c = [self.requestDownArrays count];
    }
    if(c ==0)
    {
        if (locationTabBarStatus == LOCATION_TAB_BAR_ASKING) {
            self.requestDownArrays =nil;
            [self.requestList reloadData];
        }
        
        if (locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS) {
            self.requestArrays =nil;
            [self.askSuccessList reloadData];
        }
        NSLog(@"requestDownArrays reloadData");
        return;
    }
    currentDisplayingRow = 0;
    currentDisplayingSection = 0;
    [self showCoverBgWithLoading:YES];
    [self locationAskforDetail];
    
    NSLog(@"req down %@",self.requestDownArrays);
}

#pragma mark - custum badge
-(void)clearBadges
{
    for (UIView *view in [self.view subviews])
    {
        if([view isKindOfClass:[CustomBadge class]])
            [view removeFromSuperview];
    }
    newBadgeCount =0;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:newBadgeCount] forKey:@"newBadges"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)displayBadges
{
    for (UIView *view in [self.view subviews])
    {
        if([view isKindOfClass:[CustomBadge class]])
            [view removeFromSuperview];
    }
    
    CustomBadge *customBadge1 = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d",newBadgeCount]
                                                   withStringColor:[UIColor whiteColor]
                                                    withInsetColor:[UIColor redColor]
                                                    withBadgeFrame:YES
                                               withBadgeFrameColor:[UIColor whiteColor]
                                                         withScale:1.0
                                                       withShining:YES];
    
    [customBadge1 setFrame:CGRectMake(32, 230, customBadge1.frame.size.width, customBadge1.frame.size.height)];
    [customBadge1 setUserInteractionEnabled:NO];
    
    [self.view addSubview:customBadge1];
}

- (void)showToUpperLimitAlert{
    [self hideMsgBar];
    UIAlertView *limitAlertView = [[UIAlertView alloc] initWithTitle:DOWLOAD_UPPERNUM message:DOWNLOAD_DOC_MAXVALUE_NOTHING delegate:self cancelButtonTitle:SET_KNOW otherButtonTitles:SET_INVITE, nil];
    limitAlertView.tag = UPPERLIMITALERTVIEWTAG;
    [limitAlertView show];
}

#pragma mark  - alertveiw delegate
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self enabledSwitchButton];
    if ([actionSheet.message isEqualToString:@"您的身份验证已经提交，我们正在验证中。身份验证通过后即可免费下载全文。您可先收藏此文献。"] && buttonIndex == 1) {
        self.httpRequest = [self checkVer:[ImdUrlPath checkUserInfo]];
    }
    
    if (([actionSheet.title isEqualToString:@"索取请求发送成功"] || [actionSheet.title isEqualToString:@"已发送过索取请求"]) && buttonIndex == 1) {
        [self loadRequestStatusWithExternalId:jumpExternalId];
    } else if(actionSheet.tag ==123) {
        [self presentLoginWindow:nil];
    }
    
    if (actionSheet.tag == 6 && buttonIndex == 1) {
        self.switchButton.enabled = true;
        [self presentVerifiedWindow];
    }
    
    if (actionSheet.tag == 5 && buttonIndex == 1) {
        RegisterSuccessViewController* m=[[RegisterSuccessViewController alloc] init];
        UINavigationController* nv =[[UINavigationController alloc] initWithRootViewController:m];
        nv.navigationBarHidden =YES;
        
        nv.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:nv animated:YES completion:nil];
        nv.view.superview.frame = CGRectMake(512-270, 384-310,540, 620);//it's important to do this after
        self.confirmMainViewController = m;
    }
    
    if (actionSheet.tag == 7 && buttonIndex == 1) {
        self.switchButton.enabled = true;
        [self presentVerifiedWindow];
    }
    
    if (actionSheet.tag == UPPERLIMITALERTVIEWTAG && buttonIndex == 1) {
        [self presentInviteFriendWindow];
    }
}


- (void) checkUserConfirmInfo
{
    NSString* theUrl = [NSString stringWithFormat:@"http://%@/user/active", CONFIRM_SERVER];
    
    NSLog(@"url =%@",theUrl);
    
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:theUrl]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",CONFIRM_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"userActiver" forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    
    request.delegate =self;
    [request startAsynchronous];
    NSLog(@"startAsynchronous");
    
}

-(void)getDetailInfo:(NSString*)externelId
{
    NSString* url = [NSString stringWithFormat:@"http://%@/docsearch/docu/%@/",SEARCH_SERVER, externelId];
    NSLog(@"url =%@",url);
    
    ASIHTTPRequest* request =
    [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",CONFIRM_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"downAskDetail" forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    
    request.delegate =self;
    [request startAsynchronous];
    NSLog(@"startAsynchronous");
}

#pragma mark - Location Doc function
-(void)setLocationDetailIsFav
{
    if (self.downloadArrays == nil || [self.downloadArrays count] == 0) {
        return;
    }
    detailIsFav = false;
    NSArray* results = self.downloadArrays;
    NSDictionary* result =[results objectAtIndex:[self.downloadArrays count]-1-currentDisplayingRow];
    [self checkLocationDocFavStatus:[result objectForKey:@"externalId"]];
}

-(void)checkLocationDocFavStatus:(NSString *)externelId
{
    if (externelId == nil || externelId.length == 0) {
        return;
    }
    NSLog(@"externelId %@", externelId);
    if (currentActionSelected != SIDEACTION_DOWNLOADED) {
        return;
    }
    if(![NetStatusChecker isNetworkAvailbe])
    {
        return;
    }
    NSString* url = [NSString stringWithFormat:@"http://%@/docsearch/isfav/%@/",SEARCH_SERVER, externelId];
    NSLog(@"url =%@",url);
    
    ASIHTTPRequest* request =
    [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",CONFIRM_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_LOCATION_IS_FAV forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    
    request.delegate =self;
    [request startAsynchronous];
    NSLog(@"startAsynchronous");
}

-(void)locationAskforDetail
{
    if (locationTabBarStatus == LOCATION_TAB_BAR_ASKING && (self.requestDownArrays == nil || [self.requestDownArrays count] == 0)) {
        return;
    }
    
    if (locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS && (self.requestArrays == nil || [self.requestArrays count] == 0)) {
        return;
    }
    
    if (locationTabBarStatus == LOCATION_TAB_BAR_ASKING) {
        NSDictionary* item = [self.requestDownArrays objectAtIndex:currentDisplayingRow];
        NSDictionary* info = [item objectForKey:@"shortDocInfo"];
        NSString* externelId = [info objectForKey:@"id"];
        NSString* title =[item objectForKey:@"title"];
        [ImdAppBehavior detailLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_ASKING];
        [self showDownDetail:externelId];
    }
    
    if (locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS) {
        NSDictionary* item = [self.requestArrays objectAtIndex:currentDisplayingRow];
        NSDictionary* info = [item objectForKey:@"shortDocInfo"];
        NSString* externelId = [info objectForKey:@"id"];
        NSString* title =[item objectForKey:@"title"];
        [ImdAppBehavior detailLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title pageName:PAGE_ASKED];
        [self showDownDetail:externelId];
    }
}

#pragma mark - location tab bar action
-(void)locationTabBarViewLoading:(int)tabBarStatus
{
    if (tabBarStatus < 0 || tabBarStatus > 2) {
        return;
    }
    switch (tabBarStatus) {
        case LOCATION_TAB_BAR_HAS_SAVED:
            [hasSavedButton setImage:[UIImage imageNamed:@"btn-have-saved-selected.png"] forState:UIControlStateNormal];
            [askingButton setImage:[UIImage imageNamed:@"btn-requesting-normal.png"] forState:
             UIControlStateNormal];
            [askSuccessButton setImage:[UIImage imageNamed:@"tab-have-requested-normal.png"] forState:UIControlStateNormal];
            
            self.downFileListView.hidden = NO;
            self.downRequestListView.hidden = YES;
            self.downAskSuccessListView.hidden = YES;
            
            break;
        case LOCATION_TAB_BAR_ASKING:
            [hasSavedButton setImage:[UIImage imageNamed:@"btn-have-saved-normal.png"] forState:UIControlStateNormal];
            [askingButton setImage:[UIImage imageNamed:@"btn-requesting-selected.png"] forState:UIControlStateNormal];
            [askSuccessButton setImage:[UIImage imageNamed:@"btn-have-requested-normal.png"] forState:UIControlStateNormal];
            
            self.downFileListView.hidden = YES;
            self.downRequestListView.hidden = NO;
            self.downAskSuccessListView.hidden = YES;
            
            break;
        case LOCATION_TAB_BAR_ASK_SUCCESS:
            [hasSavedButton setImage:[UIImage imageNamed:@"btn-have-saved-normal.png"] forState:UIControlStateNormal];
            [askingButton setImage:[UIImage imageNamed:@"btn-requesting-normal.png"] forState:UIControlStateNormal];
            [askSuccessButton setImage:[UIImage imageNamed:@"btn-have-requested-selected.png"] forState:UIControlStateNormal];
            
            self.downFileListView.hidden = YES;
            self.downRequestListView.hidden = YES;
            self.downAskSuccessListView.hidden = NO;
            
            break;
        default:
            break;
    }
    locationTabBarStatus = tabBarStatus;
    
    self.locationTabBar.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.locationTabBar.layer.shadowOpacity = 0.8;
    self.locationTabBar.layer.shadowRadius = 1.0;
    self.locationTabBar.layer.shadowOffset = CGSizeMake(0, 1);
}

-(void)showAskingLoading:(BOOL)show
{
    if (show) {
        askingLoading.hidden = NO;
        [self showAskSuccessLoading:NO];
    } else {
        askingLoading.hidden = YES;
    }
}

-(void)showAskSuccessLoading:(BOOL)show
{
    if (show) {
        askSuccessLoading.hidden = NO;
        [self showAskingLoading:NO];
    } else {
        askSuccessLoading.hidden = YES;
    }
}

-(IBAction)hasSavedButtonTapped:(id)sender
{
    [ImdAppBehavior localDocButtonTappedLog:[Util getUsername] MACAddr:[Util getMacAddress]];
    NSLog(@"hasSavedButtonTapped");
    if (![self.askingLoading isHidden] ||
        ![self.askSuccessLoading isHidden]) {
        return;
    }
    [self locationTabBarViewLoading:LOCATION_TAB_BAR_HAS_SAVED];
    [self hasSavedListLoading];
}

-(IBAction)askingButtonTapped:(id)sender
{
    if(![NetStatusChecker isNetworkAvailbe])
    {
        [self netWorksWarning];
        return;
    }
    [ImdAppBehavior localAskingButtonTappedLog:[Util getUsername] MACAddr:[Util getMacAddress]];
    NSLog(@"askingButtonTapped");
    if (![self.askSuccessLoading isHidden]) {
        return;
    }
    [self showCoverBgWithLoading:NO];
    [self locationTabBarViewLoading:LOCATION_TAB_BAR_ASKING];
    [self askingListLoading];
}

-(IBAction)askSuccessButtonTapped:(id)sender
{
    if(![NetStatusChecker isNetworkAvailbe])
    {
        [self netWorksWarning];
        return;
    }
    [ImdAppBehavior localAskedButtonTappedLog:[Util getUsername] MACAddr:[Util getMacAddress]];
    NSLog(@"askSuccessButtonTapped");
    if (![self.askingLoading isHidden]) {
        return;
    }
    [self showCoverBgWithLoading:NO];
    [self locationTabBarViewLoading:LOCATION_TAB_BAR_ASK_SUCCESS];
    [self askSuccessListLoading];
}

-(void)hasSavedListLoading
{
    NSLog(@"hasSavedListLoading");
    [self showAskingLoading:NO];
    [self showAskSuccessLoading:NO];
    
    [self showHasSaved:0 row:0];
    
    [self showBigCoverBgWithLoading:NO];
}

-(void)askingListLoading
{
    NSLog(@"askingListLoading");
    // TODO (zhihong.ding): impl asking list loading process
    [self showAskingLoading:YES];
    self.requestDownArrays = nil;
    [self.requestList reloadData];
    
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    
    if(useLogined)
    {
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(!appDelegate.auth.imdToken.length > 0)
        {
            [self showAskingLoading:NO];
            [self remindLogin];
            return;
        }
        [self loadAskforSync:NO];
    } else {
        [self showAskingLoading:NO];
        [self remindLogin];
    }
}

-(void)askSuccessListLoading
{
    NSLog(@"askSuccessListLoading");
    [self showAskSuccessLoading:YES];
    
    [self.askSuccessList reloadData];
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    
    if(useLogined)
    {
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(!appDelegate.auth.imdToken.length > 0)
        {
            [self showAskingLoading:NO];
            [self remindLogin];
            return;
        }
        [self showAskedList];
    } else {
        [self showAskSuccessLoading:NO];
        [self remindLogin];
    }
}

#pragma mark -- detail option
-(void)showDetail:(NSString *)externalId
{
    if (externalId == nil || [externalId isEqualToString:@""]) {
        return;
    }
    [myDatabaseOption searchDetail:externalId];
    self.httpRequestSearchDetail = [self searchDetail:externalId];
}

-(void)saveDocInfo:(id)sender
{
    NSMutableDictionary *details = [self.detailSearch copy];
    [myDatabaseOption docuSave:details];
}

-(void)showFavDetail:(NSString *)externalId
{
    if (externalId == nil || [externalId isEqualToString:@""]) {
        return;
    }
    NSMutableDictionary *myDetail = [myDatabaseOption getDetail:externalId];
    if (myDetail == nil) {
        self.httpRequestFavoritesDetail = [self favoritesDetail:externalId];
    } else {
        NSLog(@"favDetail == %@", myDetail);
        self.favDetail =[myDetail copy];
        
        [self displayDetails];
    }
}

-(void)showDownDetail:(NSString *)externalId
{
    if (externalId == nil || [externalId isEqualToString:@""] || [externalId isEqualToString:@"(null)"]) {
        return;
    }
    NSMutableDictionary *myDetail = [myDatabaseOption getDetail:externalId];
    if (myDetail == nil) {
        [self getDetailInfo:externalId];
    } else {
        NSLog(@"downDetail == %@", myDetail);
        self.downAskDetail = [myDetail copy];
        if ([[self.downAskDetail objectForKey:@"isFav"]intValue] == 0) {
            detailIsFav = false;
        } else {
            detailIsFav = true;
        }
        [self displayDetails];
    }
}

-(void)showFavList
{
    if (isFirstFav) {
        [self loadFav];
    } else {
        [self showBigCoverBgWithLoading:false];
        self.favArrays = nil;
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (int i=0; i<[[myDatabaseOption getFavs] count]; i++) {
            [tempArray addObject:[[myDatabaseOption getFavs] objectAtIndex:[[myDatabaseOption getFavs] count]-i-1]];
        }
        self.favArrays = tempArray;
        [self showFavs];
    }
}

-(void)showAskedList
{
    if (isFirstAsked) {
        [self loadAskforSync:YES];
    } else {
        [self showAskSuccessLoading:NO];
        self.requestArrays = nil;
        self.requestArrays = [myDatabaseOption getAsked];
        [self updateRequestDown];
        [self.askSuccessList reloadData];
    }
}

-(void)showHasSaved:(int)section row:(int)row
{
    [self.downList reloadData];
    if (self.downloadArrays == nil || [self.downloadArrays count] == 0 ||
        row > [self.downloadArrays count] - 1 ||
        row < 0) {
        [self showCoverBgWithLoading:NO];
        return;
    }
    currentDisplayingSection = section;
    currentDisplayingRow = row;
    
    @try {
        //flurry behavior
        NSDictionary* result =[self.downloadArrays objectAtIndex:[self.downloadArrays count]-1-row];
        NSString* rawTitleString = [result objectForKey:@"title"];
        NSString* title = [Util replaceEM:rawTitleString LeftMark:@"" RightMark:@""];
        [ImdAppBehavior localDocLog:[Util getUsername] MACAddr:[Util getMacAddress] title:title];    }
    @catch (NSException *exception) {
        [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:[exception name] exceptionMessage:exception.description];
    }
    
    NSMutableDictionary *downDoc = [self.downloadArrays objectAtIndex:[self.downloadArrays count]-1-currentDisplayingRow];
    NSString *eid = [downDoc objectForKey:KEY_DOC_EXTERNALID];
    
    NSMutableDictionary *doc = [myDatabaseOption getDetail:eid];
    self.downAskDetail = nil;
    if (doc != nil) {
        NSMutableDictionary *article = [doc objectForKey:KEY_DOCU];
        self.downAskDetail = [article copy];
        NSLog(@"downAskDetail = %@", self.downAskDetail);
        if ([[doc objectForKey:KEY_DOC_ISFAV]intValue] == 0) {
            detailIsFav = false;
        } else {
            detailIsFav = true;
        }
    } else {
        self.downAskDetail = [downDoc copy];
        [self setLocationDetailIsFav];
    }
    
    [self displayDetails];
}

#pragma mark - turn screen at full text
-(void)popFulltext:(id)sender
{
    NSLog(@"popFulltext");
    fullTextIsShow = NO;
}

#pragma mark - add fav press
-(void)searchAddFav
{
    NSDictionary *doc = [self.detailSearch objectForKey:@"article"];
    NSString *eId = [doc objectForKey:KEY_DOC_EXTERNALID];
    NSArray* authArray = [doc objectForKey:KEY_DOC_AUTHOR];
    NSString *author = [Util arrayToString:authArray sep:SEPARATING];
    NSString *issue = [doc objectForKey:KEY_DOC_ISSUE];
    NSString *journal = [doc objectForKey:KEY_DOC_JOURNAL];
    NSString *pagination = [doc objectForKey:KEY_DOC_PAGINATION];
    NSString *pubDate = [doc objectForKey:KEY_DOC_PUB_DATE];
    NSString *title = [doc objectForKey:KEY_DOC_TITLE];
    NSString *volume = [doc objectForKey:KEY_DOC_VOLUME];
    [myDatabaseOption addFav:eId author:author issue:issue journal:journal pubDate:pubDate title:title volume:volume pagination:pagination];
}

-(void)downAddFav
{
    NSDictionary *doc;
    if(locationTabBarStatus == LOCATION_TAB_BAR_ASKING)
    {
        if (self.downAskDetail != nil) {
            doc = [self.downAskDetail objectForKey:@"article"];
        } else {
            NSLog(@"it is a bug.");
            [self showCoverBgWithLoading:NO];
            return;
        }
    } else if(locationTabBarStatus == LOCATION_TAB_BAR_ASK_SUCCESS) {
        if (self.downAskDetail != nil) {
            doc = [self.downAskDetail objectForKey:@"article"];
        } else {
            NSLog(@"it is a bug.");
            [self showCoverBgWithLoading:NO];
            return;
        }
    } else {
        if (self.downAskDetail != nil) {
            doc = self.downAskDetail;
        } else {
            NSLog(@"it is a bug.");
            [self showCoverBgWithLoading:NO];
            return;
        }
    }
    
    NSString *eId = [doc objectForKey:KEY_DOC_EXTERNALID];
    NSArray* authArray = [doc objectForKey:KEY_DOC_AUTHOR];
    NSString *author = [Util arrayToString:authArray sep:SEPARATING];
    NSString *issue = [doc objectForKey:KEY_DOC_ISSUE];
    NSString *journal = [doc objectForKey:KEY_DOC_JOURNAL];
    NSString *pagination = [doc objectForKey:KEY_DOC_PAGINATION];
    NSString *pubDate = [doc objectForKey:KEY_DOC_PUB_DATE];
    NSString *title = [doc objectForKey:KEY_DOC_TITLE];
    NSString *volume = [doc objectForKey:KEY_DOC_VOLUME];
    [myDatabaseOption addFav:eId author:author issue:issue journal:journal pubDate:pubDate title:title volume:volume pagination:pagination];
}

#pragma mark - remove fav press
-(void)searchRemoveFav:(NSString *)externalId
{
    [myDatabaseOption removeFav:externalId];
}

-(void)favoRemoveFav:(NSString *)externalId
{
    [myDatabaseOption removeFav:externalId];
}

-(void)downRemoveFav:(NSString *)externalId
{
    [myDatabaseOption removeFav:externalId];
}

#pragma mark - askfull success
-(void)askfullSuccess
{
    [self searchAskfullSuccess];
    [self favoriteAskfullSuccess];
}

-(void)searchAskfullSuccess
{
    if (currentActionSelected != SIDEACTION_SEARCH) {
        return;
    }
    
    NSDictionary *doc = [self.detailSearch objectForKey:@"article"];
    NSString *eId = [doc objectForKey:KEY_DOC_EXTERNALID];
    [self searchDetail:eId];
}

-(void)favoriteAskfullSuccess
{
    if (currentActionSelected != SIDEACTION_FAVORITE) {
        return;
    }
    NSDictionary *doc = [self.favDetail objectForKey:@"article"];
    NSString *eId = [doc objectForKey:KEY_DOC_EXTERNALID];
    [self favoritesDetail:eId];
}

-(void)SendAdvValue:(ASIHTTPRequest *)request
{
    [self searchRequestFinished:request];
}
@end
