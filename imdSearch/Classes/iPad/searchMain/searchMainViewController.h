//
//  searchMainViewController.h
//  imdSearch
//
//  Created by 8fox on 9/27/11.
//  Copyright 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imdSearcher.h"
#import "mySearchBar.h"
#import "loginViewController.h"
#import "accountActivationViewController.h"

#import "msgPoller.h"
#import "downloader.h"

#import "PDFViewTiled.h"
#import "fullViewController.h"
#import "searchWebViewController.h"
#import "CustomBadge.h"
#import "RegisterSuccessViewController.h"
#import "NMCustomLabel.h"
//#import "TextLayoutLabel.h"

#import "RefreshView.h"
#import "AdvSearchViewController.h"
#import "GuideIndexiPadViewController.h"

#define DISPLAY_STATE_UNKNOWN -1
#define DISPLAY_STATE_FRONTPAGE 0
#define DISPLAY_STATE_SEARCHING 1
#define DISPLAY_STATE_RESULTS 2
#define DISPLAY_STATE_ADVSEARCH 3
#define DISPLAY_STATE_HELP 4
#define DISPLAY_STATE_FAVORATE 5
#define DISPLAY_STATE_DOWNLOADED 6
#define DISPLAY_STATE_SETTINGS 7
#define DISPLAY_STATE_SUGGESTION 8

#define REFRESHWAY_INCREASEWAY 0
#define REFRESHWAY_RELOADWAY 1

#define SIDEACTION_SEARCH 0
#define SIDEACTION_FAVORITE 1
#define SIDEACTION_DOWNLOADED 2
#define SIDEACTION_SETTINGS 3
#define SIDEACTION_HELP 4

#define FONT_OFFSET_ZERO 0
#define FONT_OFFSET_MINUS -5
#define FONT_OFFSET_PLUS 5

#define FAV_ADDING 1
#define FAV_REMOVING 2
#define FAV_NONE 0

#define ASKFULLTEXT_STATE_ASKFINISHED @"askFinished"
#define ASKFULLTEXT_STATE_DOWNLOADABLE @"downloadable"
#define ASKFULLTEXT_STATE_DOWNLOADING @"downloading"
#define ASKFULLTEXT_STATE_DOWNLOADED @"downloaded"


#define DOWNLOAD_DISPLAYING_FILE 0
#define DOWNLOAD_DISPLAYING_REQUEST 1

@interface searchMainViewController : UIViewController < UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIPopoverControllerDelegate,UITextFieldDelegate,UIScrollViewDelegate>
{
    //poller
    msgPoller* poller;
    
    //UI
    IBOutlet UIView* sideActionsView;
    IBOutlet UIView* listSearchView;
    IBOutlet UIView* listFavView;
    IBOutlet UIView* listDownloadView;
    
    IBOutlet UIView* resultAreaView;
    
    
    IBOutlet UIView* titleLeftView;
    IBOutlet UIView* titleLeftFavView;
    IBOutlet UIView* titleLeftDownView;
    
    
    IBOutlet UIView* titleActionsView;
    
    IBOutlet UIView* searchbarView;
    IBOutlet UIView* searchListView;
    IBOutlet UIView* searchResultView;
    IBOutlet UIView* searchResultCoverView;
    IBOutlet UIView* bigCoverView;
    
    
    IBOutlet UIView* downFileListView;
    IBOutlet UIView* downRequestListView;
    IBOutlet UIView* downAskSuccessListView;
    
    
    IBOutlet UIImageView* coverBg;
    
    
    
    NMCustomLabel* detailJournalAndDate;
    IBOutlet UILabel* detailTitle;
    IBOutlet UILabel* detailAuthors;
    IBOutlet UILabel* detailaffiliations;
    IBOutlet UILabel* detailAbstractText;
    IBOutlet UILabel* detailKeyword;
    
    IBOutlet UILabel* detailAbstractString;
    IBOutlet UILabel* detailKeywordString;
    
    IBOutlet UIImageView* detailLine1;
    IBOutlet UIImageView* detailLine2;
    IBOutlet UIImageView* detailKeywordLabel;
    IBOutlet UIImageView* detailAbstractLabel;
    
    
    
    IBOutlet UIScrollView* AbstractTextScrollView;
    
    UITableView* searchResultList;
    mySearchBar* searchBar;
    
    IBOutlet UITableView* favList;
    IBOutlet UITableView* downList;
    IBOutlet UITableView* requestList;
    IBOutlet UITableView* askSuccessList;
    
    
    //displayState
    int lastDisplayState;
    int displayState;
    int searchLastState;
    
    //result
    NSDictionary* searchedResult;
    NSMutableArray* resultReadingStatus;
    
    int resultsCount;
    int displayCount;
    int currentDisplayingRow;
    int currentDisplayingSection;
    
    int displayMax;
    int currentPage;
    int fetchingPage;
    int totalPages;
    BOOL isSinglePage;
    
    int loadingRow;
    //int  upperLoadingRow;
    //int  lowerLoadingRow;
    
    int refreshWay;
    
    int firstRow;
    int lastRow;
    
    
    //history
    NSArray* searchHistory;
    
    IBOutlet UIActivityIndicatorView* loadingIndicator;
    IBOutlet UILabel* loadingLabel;
    IBOutlet UILabel* errorLabel;
    
    IBOutlet UIView* loadingView;
    
    BOOL newSearchStart;
    
    BOOL showingBlackLoading;
    
    BOOL showingBarLoading;
    int barLoadingAction;
    int barLoadingRow;
    int barLoadingSection;
    
    
    //popovers
    //UIPopoverController* languageSelPopover;
    //UIPopoverController* sortSelPopover;
    
    
    UIPopoverController* askFullTextPopover;
    //UIPopoverController* requestListPopover;
    
    
    int currentActionSelected;
    
    int currentSearchLanguage;
    int currentResultLanguage;
    
    int currentSelectedSuggestion;
    
    
    int suggestionCount;
    NSMutableArray* suggestionArrays;
    
    UIButton* langSelButton;
    
    
    //side buttons
    IBOutlet UIButton* sideActionSearchButton;
    IBOutlet UIButton* sideActionFavoriteButton;
    IBOutlet UIButton* sideActionDownloadedButton;
    IBOutlet UIButton* sideActionSettingsButton;
    IBOutlet UIButton* sideActionHelpButton;
    
    IBOutlet UIButton* backButton;
    IBOutlet UIButton* favoriteSaveButton;
    IBOutlet UILabel* searchTitle;
    
    //adv search
    BOOL advViewOn;
    BOOL advViewAnimating;
    
    int advancedQueryItemCount;
    int advancedQueryItemCountMax;
    
    BOOL newAdvSearch;
    BOOL coreJournalOn;
    BOOL sciOn;
    BOOL reviewsOn;
    
    IBOutlet UIButton* advButton;
    
    
    NSDictionary* filterItemData;
    
    NSMutableArray* filterNames;
    NSMutableArray* filterValues;
    NSMutableArray* filterOperations;
    
    NSString* minYear;
    NSString* maxYear;
    
    
    //sort
    NSString* sortMethod;
    int sortWay;
    
    int catalogWay;
    
    
    int popedYearButton;
    
    
    //adv popover
    //popover controller
    UIPopoverController *filterPopoverController;
    UIPopoverController *yearPopoverController;
    UIPopoverController *languagePopoverController;
    UIPopoverController *catalogPopoverController;
    UIPopoverController *sortPopoverController;
    UIPopoverController *sharePopoverController;
    
    
    //others
    int searchingType; //adv or sim search
    
    id currentKeybordHolder;
    
    BOOL hasLogged;
    
    IBOutlet UIImageView* selectedDotSearch;
    IBOutlet UIImageView* selectedDotFav;
    IBOutlet UIImageView* selectedDotDownload;
    
    int currentDetailsFontSizeOffset;
    
    loginViewController* mainLoginViewController;
    
    NSMutableArray* downloadArrays;
    NSMutableArray* requestArrays;
    NSMutableArray* requestDownArrays;
    
    
    downloader* fullTextDownloader;
    
    UIView* pdfBackView;
    PDFViewTiled* pdfView;
    PDFViewTiled* prePDFView;
    PDFViewTiled* nextPDFView;
    
    
    
    IBOutlet UIScrollView* detailView;
    
    IBOutlet UIButton* switchButton;
    
    int pdfValue;
    
    BOOL inFullText;
    
    IBOutlet UILabel* pageNo;
    
    IBOutlet UIView* startCover;
    IBOutlet UIView* helpCover;
    
    IBOutlet UIButton* helpCoverButton;
    
    IBOutlet UIImageView* helpImageView;
    
    NSMutableArray* favArrays;
    //    NSMutableArray* favDetail;
    
    IBOutlet UIButton* favEditButton;
    IBOutlet UILabel* favTitle;
    BOOL firstLoad;
    
    IBOutlet UIButton* downEditButton;
    IBOutlet UILabel* downTitle;
    IBOutlet UIButton* downRequestListButton;
    
    UIButton* resultLeftButton;
    UIButton* resultRightButton;
    
    fullViewController* fullTextController;
    
    IBOutlet UIButton* detailFavButton;
    
    BOOL currentResultInFavorite;
    BOOL processingFav;
    
    int currentFavAction;
    
    UISwitch* coreJournalSwitch;
    UISwitch* sciSwitch;
    UISwitch* reviewsSwitch;
    searchWebViewController* webVC;
    
    int downloadDisplaying;
    int currentHelp;
    
    IBOutlet UIScrollView* helpScrollView;
    IBOutlet UIPageControl* helpPageControl;
    
    BOOL  pageControlBeingUsed;
    
    IBOutlet UIView* msgView;
    
    IBOutlet UILabel* msgLabel;
    IBOutlet UIActivityIndicatorView* msgLoading;
    IBOutlet UIImageView* msgInfoImage;
    
    BOOL downWifiOnly;
    int newBadgeCount;
    
    NSString* errorResponse;
    BOOL loadingMore;
    
    
    accountActivationViewController* confirmViewController;
    
    RegisterSuccessViewController* confirmMainViewController;
    int searchDisplayingRow;
    int settingDisplayState;
    int helpDisplayState;
    
    
    // dzh
    BOOL isAdvViewShow;
    
    NSDictionary* downAskDetail;
    NSDictionary* detailSearch;
    NSDictionary* favDetail;
    
    
    // Http Request
    //--  Search Page
    //----  Simple Search
    ASIHTTPRequest* httpRequestSearchSimpleSuggestion;
    ASIHTTPRequest* httpRequestSearchSimpleSearch;
    //----  Result List
    ASIHTTPRequest* httpRequestSearchDetail;
    ASIHTTPRequest* httpRequestSearchSort;
    ASIHTTPRequest* httpRequestSearchResultSimpleSearch;
    ASIHTTPRequest* httpRequestSearchAskforDoc;
    ASIHTTPRequest* httpRequestSearchDownloadDoc;
    ASIHTTPRequest* httpRequestSearchGetUserStatus;
    ASIHTTPRequest* httpRequestSearchAddFavoritedoc;
    ASIHTTPRequest* httpRequestSearchRemoveFavoritedoc;
    //--  Favorites Page
    //----  Favorites List
    ASIHTTPRequest* httpRequestFavoritesSync;
    ASIHTTPRequest* httpRequestFavoritesDetail;
    ASIHTTPRequest* httpRequestFavoritesAskforDoc;
    ASIHTTPRequest* httpRequestFavoritesDownloadDoc;
    ASIHTTPRequest* httpRequestFavoritesGetUserStatus;
    //----  Edit Favorites List
    ASIHTTPRequest* httpRequestFavoritesRemove;
    ASIHTTPRequest* httpRequestFavoritesEditDetail;
    //--  Location Docs Page
    //----  Location & Ask List
    ASIHTTPRequest* httpRequestLocationAskSync;
    ASIHTTPRequest* httpRequestLocationDetail;
    ASIHTTPRequest* httpRequestLocationDownloadDoc;
    ASIHTTPRequest* httpRequestLocationGetUserStatus;
    ASIHTTPRequest* httpRequestLocationAddFavoriteDoc;
    ASIHTTPRequest* httpRequestLocationRemoveFavoriteDoc;
    //----  Edit Location & Ask List
    //  ASIHTTPRequest* httpRequestLocationRemoveAskfor;
    ASIHTTPRequest* httpRequestLocationEditDetail;
    
    BOOL isSort;
    
    BOOL detailIsFav;
    
    // location tab between saved, asking, and ask success
    IBOutlet UIButton* hasSavedButton;
    IBOutlet UIButton* askingButton;
    IBOutlet UIButton* askSuccessButton;
    
    int locationTabBarStatus;
    
    IBOutlet UIActivityIndicatorView* askingLoading;
    IBOutlet UIActivityIndicatorView* askSuccessLoading;
    
    IBOutlet UIView* locationTabBar;
    
    RefreshView *favView;
    RefreshView *askedView;
    
    BOOL isFirstFav;
    BOOL isFirstAsked;
    
    BOOL fullTextIsShow;
    BOOL firstShow;
    NSString *jumpExternalId;
    BOOL isAskfor;
    BOOL hasSaveFile;
    BOOL hasAsking;
    BOOL hasAsked;
    AdvSearchViewController *adview;
    BOOL hasNotification;
    BOOL actionhighButton;
}

@property (nonatomic,retain) IBOutlet UIImageView* coverBg;
@property (nonatomic,retain) UITableView* searchResultList;
@property (nonatomic,retain) IBOutlet UIView* sideActionsView;
@property (nonatomic,retain) IBOutlet UIView* listSearchView;
@property (nonatomic,retain) IBOutlet UIView* resultAreaView;

@property (nonatomic,retain) IBOutlet UIView* listFavView;
@property (nonatomic,retain) IBOutlet UIView* listDownloadView;


@property (nonatomic,retain) IBOutlet UIButton* advButton;

@property (nonatomic,retain) NMCustomLabel* detailJournalAndDate;
@property (nonatomic,retain) IBOutlet UILabel* detailTitle;
@property (nonatomic,retain) IBOutlet UILabel* detailAuthors;
@property (nonatomic,retain) IBOutlet UILabel* detailaffiliations;
@property (nonatomic,retain) IBOutlet UILabel* detailAbstractText;
@property (nonatomic,retain) IBOutlet UILabel* detailKeyword;

@property (nonatomic,retain) IBOutlet UILabel* detailAbstractString;
@property (nonatomic,retain) IBOutlet UILabel* detailKeywordString;

@property (nonatomic,retain) IBOutlet UIImageView* detailLine1;
@property (nonatomic,retain) IBOutlet UIImageView* detailLine2;
@property (nonatomic,retain) IBOutlet UIImageView* detailKeywordLabel;
@property (nonatomic,retain) IBOutlet UIImageView* detailAbstractLabel;

@property (nonatomic,retain) IBOutlet UIScrollView* AbstractTextScrollView;

@property (nonatomic,retain) IBOutlet UIView* titleLeftView;
@property (nonatomic,retain) IBOutlet UIView* titleLeftFavView;
@property (nonatomic,retain) IBOutlet UIView* titleLeftDownView;

@property (nonatomic,retain) IBOutlet UIView* titleActionsView;

@property (nonatomic,retain) IBOutlet UIView* searchbarView;
@property (nonatomic,retain) IBOutlet UIView* searchListView;
@property (nonatomic,retain) IBOutlet UIView* searchResultView;
@property (nonatomic,retain) IBOutlet UIView* searchResultCoverView;
@property (nonatomic,retain) IBOutlet UIView* bigCoverView;

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic,retain) IBOutlet UILabel* loadingLabel;
@property (nonatomic,retain) IBOutlet UILabel* errorLabel;

@property (nonatomic,retain) IBOutlet UIView* loadingView;

@property (nonatomic,retain) NSDictionary* searchedResult;
@property (nonatomic,retain) NSMutableArray* resultReadingStatus;

@property (nonatomic,retain) IBOutlet UITableView* favList;
@property (nonatomic,retain) IBOutlet UITableView* downList;
@property (nonatomic,retain) IBOutlet UITableView* requestList;
@property (nonatomic,retain) IBOutlet UITableView* askSuccessList;

@property (nonatomic,retain) IBOutlet UIView* downFileListView;
@property (nonatomic,retain) IBOutlet UIView* downRequestListView;
@property (nonatomic,retain) IBOutlet UIView* downAskSuccessListView;

@property (nonatomic,retain) UIButton* langSelButton;
@property (nonatomic,retain) IBOutlet UIButton* helpCoverButton;

@property (nonatomic,retain) IBOutlet UIButton* sideActionSearchButton;
@property (nonatomic,retain) IBOutlet UIButton* sideActionFavoriteButton;
@property (nonatomic,retain) IBOutlet UIButton* sideActionDownloadedButton;
@property (nonatomic,retain) IBOutlet UIButton* sideActionSettingsButton;
@property (nonatomic,retain) IBOutlet UIButton* sideActionHelpButton;

@property (nonatomic,retain) IBOutlet UIButton* backButton;
@property (nonatomic,retain) IBOutlet UIButton* favoriteSaveButton;
@property (nonatomic,retain) IBOutlet UILabel* searchTitle;

@property (nonatomic,retain) id currentKeybordHolder;

@property (nonatomic,retain) IBOutlet UIImageView* selectedDotSearch;
@property (nonatomic,retain) IBOutlet UIImageView* selectedDotFav;
@property (nonatomic,retain) IBOutlet UIImageView* selectedDotDownload;
@property (nonatomic,retain) loginViewController* mainLoginViewController;

@property (nonatomic,retain) NSMutableArray* downloadArrays;
@property (nonatomic,retain) NSMutableArray* requestArrays;
@property (nonatomic,retain) NSMutableArray* requestDownArrays;


@property (nonatomic,retain) downloader* fullTextDownloader;

@property (nonatomic,retain) IBOutlet UIScrollView* detailView;
@property (nonatomic,retain) PDFViewTiled* pdfView;
@property (nonatomic,retain) PDFViewTiled* prePdfView;
@property (nonatomic,retain) PDFViewTiled* nextPdfView;
@property (nonatomic,retain) UIView* pdfBackView;
@property (nonatomic,retain) UISwitch* coreJournalSwitch;
@property (nonatomic,retain) UISwitch* sciSwitch;
@property (nonatomic,retain) UISwitch* reviewsSwitch;

@property (nonatomic,retain) IBOutlet UIButton* switchButton;
@property (nonatomic,retain) IBOutlet UILabel* pageNo;
@property (nonatomic,retain) IBOutlet UIView* startCover;
@property (nonatomic,retain) IBOutlet UIView* helpCover;
@property (nonatomic,retain) IBOutlet UIImageView* helpImageView;

@property (nonatomic,retain) NSMutableArray* favArrays;
//@property (nonatomic,retain) NSMutableArray* favDetail;

@property (nonatomic,retain) IBOutlet UIButton* favEditButton;

@property (nonatomic,retain) IBOutlet UIButton* downEditButton;

@property (nonatomic,retain) IBOutlet UILabel* downTitle;
@property (nonatomic,retain) IBOutlet UILabel* favTitle;


@property (nonatomic,retain) IBOutlet UIButton* downRequestListButton;

@property (nonatomic,retain) UIButton* resultLeftButton;
@property (nonatomic,retain) UIButton* resultRightButton;

@property (nonatomic,retain) IBOutlet UIButton* detailFavButton;
@property (nonatomic,retain) GuideIndexiPadViewController *viewController;

@property (nonatomic,retain) fullViewController* fullTextController;
@property (nonatomic,retain) searchWebViewController* webVC;

@property (nonatomic,retain) IBOutlet UIScrollView* helpScrollView;
@property (nonatomic,retain) IBOutlet UIPageControl* helpPageControl;

@property (nonatomic,retain) IBOutlet UIView* msgView;
@property (nonatomic,retain) IBOutlet UILabel* msgLabel;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* msgLoading;
@property (nonatomic,retain) IBOutlet UIImageView* msgInfoImage;

@property (nonatomic,retain) accountActivationViewController* confirmViewController;
@property (nonatomic,retain) RegisterSuccessViewController* confirmMainViewController;


@property (nonatomic,retain) NSDictionary* downAskDetail;
@property (nonatomic,retain) NSDictionary* detailSearch;
@property (nonatomic,retain) NSDictionary* favDetail;

// Http Request
//--  Search Page
//----  Simple Search
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchSimpleSuggestion;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchSimpleSearch;
//----  Result List
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchDetail;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchSort;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchResultSimpleSearch;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchAskforDoc;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchDownloadDoc;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchGetUserStatus;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchAddFavoritedoc;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchRemoveFavoritedoc;
//--  Favorites Page
//----  Favorites List
@property (nonatomic,retain) ASIHTTPRequest* httpRequestFavoritesSync;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestFavoritesDetail;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestFavoritesAskforDoc;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestFavoritesDownloadDoc;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestFavoritesGetUserStatus;
//----  Edit Favorites List
@property (nonatomic,retain) ASIHTTPRequest* httpRequestFavoritesRemove;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestFavoritesEditDetail;
//--  Location Docs Page
//----  Location & Ask List
@property (nonatomic,retain) ASIHTTPRequest* httpRequestLocationAskSync;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestLocationDetail;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestLocationDownloadDoc;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestLocationGetUserStatus;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestLocationAddFavoriteDoc;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestLocationRemoveFavoriteDoc;
//----  Edit Location & Ask List
//  ASIHTTPRequest* httpRequestLocationRemoveAskfor;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestLocationEditDetail;
@property (nonatomic,retain) ASIHTTPRequest* httpRequest;

@property (nonatomic,retain) IBOutlet UIButton* hasSavedButton;
@property (nonatomic,retain) IBOutlet UIButton* askingButton;
@property (nonatomic,retain) IBOutlet UIButton* askSuccessButton;

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* askingLoading;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* askSuccessLoading;
@property (nonatomic,retain) IBOutlet UIView* locationTabBar;
@property (nonatomic,retain) RefreshView  *favView;
@property (nonatomic,retain) RefreshView  *askedView;
@property (nonatomic,assign) BOOL hasNotification;
- (void)finishSearchWithString:(NSString *)searchString;
- (void)displayDetails;
//- (BOOL)loadPDF:(NSString*)pdfFileName;
- (BOOL)loadPDFTest:(NSString*)pdfFileName;

- (void)calculatePages;
- (void)popLanguageSelection:(UIButton*)sender;
- (void)changeLanguage:(UIButton*)sender;
- (void)changeLanguageTo:(NSString*)lanStr;

- (IBAction)sideActionPressed:(id)sender;
- (void)refreshSideActionButtons;

- (void)sortPressed:(id)sender;
- (void)catalogPressed:(id)sender;

- (IBAction)backPressed:(id)sender;
- (IBAction)favSavePressed:(id)sender;
- (void) addQueryItem:(id)sender;


-(IBAction)advViewShow:(id)sender;
- (void)advViewHide;

- (void)movingShowCompleted;
- (void)movingHideCompleted;
- (void)displayStates;

- (void)filterSelected:(id)sender;
- (void)selectedOperation:(id)sender;

- (NSDictionary*)readPListBundleFile:(NSString*)fileName;

- (void)advSearch:(id)sender;


- (void)closeSetting:(id)sender;
- (void)presentSettingWindow;

- (void)closeLogin:(id)sender;
- (void)presentLoginWindow:(id)sender;
- (void)login:(id)sender;
- (void)logout:(id)sender;

- (void)presentConfirmWindow:(id)sender;

- (IBAction)detailsFontZoomOut:(id)sender;
- (IBAction)detailsFontZoomIn:(id)sender;
- (IBAction)detailsAddFav:(id)sender;
- (IBAction)detailsDownFullText:(id)sender;
- (void)addToDownloadArraysWith:(NSDictionary*)result;
- (void)remvoeFromDownloadArraysWith:(NSString*)eid;


- (IBAction)detailsShare:(id)sender;

- (IBAction)backToCallingApp:(id)sender;
- (void)shareSelected:(id)sender;

- (IBAction)fulltextButtonTapped;

- (void)nextPage;
- (void)prePage;

-(IBAction)pdfZoomIn;
-(IBAction)pdfZoomOut;

- (void)startReady;
- (void)loadFav;
-(void)loadFavDetail;

- (void)addFav:(NSString*)id;
- (void)removeFav:(NSString*)id;


- (IBAction)favEditButtonTapped;
- (IBAction)downEditButtonTapped;

-(IBAction)fullTextSwitchScreen:(id)sender;
-(void)startLoading;

-(NSString*)fetchSortMethod:(int)way;

//-(void)swipeRightCompleted;
//-(void)swipeLeftCompleted;

-(void)downRequest:(id)sender;
-(void)downloadAskPDFwithExternalId:(NSString*)Eid andInternalId:(NSString*)Iid displayFullText:(BOOL)displayIt title:(NSString*)title filePath:(NSString*)filePath fileName:(NSString*)fileName;


-(void)showCoverBgWithLoading:(BOOL)isLoading;
-(void)showCoverBgWithErrorMsg:(NSString*)errMsg;

-(IBAction)checkRequestList:(id)sender;
-(void)askForPDF:(id)sender;

-(void)loadRequestArray;
-(void)loadRequestStatus;
-(void)checkFavStatus:(NSString*)externalId;

-(IBAction)changeHelp:(id)sender;
-(IBAction)changePage;


-(void)showMsgBarWithLoading:(NSString*)text;
-(void)showMsgBarWithInfo:(NSString*)text;

-(void)hideMsgBar;

-(void)netWorksWarning;
-(void)wifiDownloadWarning;

//-(void)logoutWarning;

-(void)clearAll;

-(IBAction)exitHelp:(id)sender;
-(int)getDownableRequestCount;
-(void)updateRequestDown;

-(void)clearBadges;
-(void)displayBadges;

-(void)remindLogin;

-(void)showHelpCover;
-(void)hideHelpCover;

-(IBAction)hasSavedButtonTapped:(id)sender;
-(IBAction)askingButtonTapped:(id)sender;
-(IBAction)askSuccessButtonTapped:(id)sender;

-(void)refresh;
-(void)popFulltext:(id)sender;

-(void)saveDocInfo:(id)sender;
-(void)loginSuccessProcess:(id)sender;

-(void)cancelSearchHttpRequests;
-(void)cancelFavoritesHttpRequests;
-(void)sideLocalDocuments:(int)sender;
-(ASIHTTPRequest*)checkVer:(NSString *)url;
-(void)advSearchHandleAllSwipes:(UISwipeGestureRecognizer *)recognizer;
@end
