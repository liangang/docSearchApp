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

#import "msgPoller.h"
#import "downloader.h"

#import "PDFViewTiled.h"

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



@interface searchMainViewController : UIViewController < UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIPopoverControllerDelegate,UITextFieldDelegate,UIScrollViewDelegate> 
{
    
    msgPoller* poller;
    
    IBOutlet UIView* sideActionsView;
    IBOutlet UIView* listSearchView;
    IBOutlet UIView* listFavView;
    IBOutlet UIView* listDownloadView;
    
    IBOutlet UIView* resultAreaView;
    
    
    IBOutlet UIView* titleLeftView;
    IBOutlet UIView* titleActionsView;
    
    IBOutlet UIView* searchbarView;
    IBOutlet UIView* searchListView;
    IBOutlet UIView* searchResultView;
    IBOutlet UIView* searchResultCoverView;
    
    IBOutlet UIView* advanedView;
    
    IBOutlet UILabel* detailJournalAndDate;
    IBOutlet UILabel* detailTitle;
    IBOutlet UILabel* detailAuthors;
    IBOutlet UILabel* detailaffiliations;
    IBOutlet UILabel* detailAbstractText;
    IBOutlet UILabel* detailKeyword;
    
    IBOutlet UIScrollView* AbstractTextScrollView;
    
    UITableView* searchResultList;
    mySearchBar* searchBar;
    
    IBOutlet UITableView* advSearchList;
    IBOutlet UITableView* favList;
    IBOutlet UITableView* downList;
    
    
    int lastDisplayState;
    int displayState;
    
    NSDictionary* searchedResult;
    NSMutableArray* resultReadingStatus;
    
    int resultsCount;
    int displayCount;
    int currentDisplayingRow;
    
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
    
    NSArray* searchHistory;
    
    IBOutlet UIActivityIndicatorView* loadingIndicator;
    IBOutlet UILabel* loadingLabel;
    IBOutlet UILabel* errorLabel;
    
    BOOL newSearchStart;
    
    
    UIPopoverController* languageSelPopover;
    UIPopoverController* sortSelPopover;
    
    
    int currentActionSelected;
    
    int currentSearchLanguage;
    
    int currentSelectedSuggestion;
    
    
    int suggestionCount;
    NSMutableArray* suggestionArrays;
    
    UIButton* langSelButton;
    
    
    IBOutlet UIButton* sideActionSearchButton;
    IBOutlet UIButton* sideActionFavoriteButton;
    IBOutlet UIButton* sideActionDownloadedButton;
    IBOutlet UIButton* sideActionSettingsButton;
    IBOutlet UIButton* sideActionHelpButton;
    
    

    
    
    IBOutlet UIButton* backButton;
    IBOutlet UIButton* favoriteSaveButton;
    IBOutlet UILabel* searchTitle;
    
    BOOL advViewAnimating;
    
    int advancedQueryItemCount;
    int advancedQueryItemCountMax;
    
    BOOL newAdvSearch;
    BOOL coreJournalOn;
    
    NSDictionary* filterItemData;
    
    NSMutableArray* filterNames;
    NSMutableArray* filterValues;
    NSMutableArray* filterOperations;
    
    NSString* minYear;
    NSString* maxYear;
    NSString* sortMethod;
    
    int popedYearButton;
    
    //popover controller
    UIPopoverController *filterPopoverController;
    UIPopoverController *yearPopoverController;
    UIPopoverController *languagePopoverController;
    UIPopoverController *catalogPopoverController;
    UIPopoverController *sortPopoverController;
    UIPopoverController *sharePopoverController;
    
    int searchingType;
    
    
    id currentKeybordHolder;
    
    BOOL hasLogged;
    
    IBOutlet UIImageView* selectedDotSearch;
    IBOutlet UIImageView* selectedDotFav;
    IBOutlet UIImageView* selectedDotDownload;
    
    int currentDetailsFontSizeOffset;
    
    loginViewController* mainLoginViewController;
    
    NSMutableArray* downloadArrays;
    
    downloader* fullTextDownloader;
    
    PDFViewTiled* pdfView;
    PDFViewTiled* prePDFView;
    PDFViewTiled* nextPDFView;
    
    
    IBOutlet UIScrollView* detailView;
    
    IBOutlet UIButton* switchButton;
    
    int pdfValue;
    
    BOOL inFullText;
    
    IBOutlet UILabel* pageNo;
    
    IBOutlet UIView* startCover;
    
    NSMutableArray* favArrays;

    IBOutlet UIButton* favEditButton;
    
}

- (void)finishSearchWithString:(NSString *)searchString;
- (void)displayDetails;
- (BOOL)loadPDF:(NSString*)pdfFileName;

- (void)calculatePages;
- (void)popLanguageSelection:(UIButton*)sender;
- (void)changeLanguage:(UIButton*)sender;

- (IBAction)sideActionPressed:(id)sender;

- (void)refreshSideActionButtons;

- (void)sortPressed:(id)sender;
- (void)catalogPressed:(id)sender;

- (IBAction)backPressed:(id)sender;
- (IBAction)favSavePressed:(id)sender;
- (void) addQueryItem:(id)sender;

- (void)advViewShow;
- (void)advViewHide;

- (void)movingShowCompleted;
- (void)movingHideCompleted;
- (void)displayStates;

- (void)filterSelected:(id)sender;
- (void)textValueInputed:(id)sender;
- (void)selectedOperation:(id)sender;

- (NSDictionary*)readPListBundleFile:(NSString*)fileName;
- (void)advSearchButtonTapped:(id)sender;


- (void)closeSetting:(id)sender;
- (void)presentSettingWindow;

- (void)closeLogin:(id)sender;
- (void)presentLoginWindow:(id)sender;
- (void)login:(id)sender;

- (IBAction)detailsFontZoomOut:(id)sender;
- (IBAction)detailsFontZoomIn:(id)sender;
- (IBAction)detailsAddFav:(id)sender;
- (IBAction)detailsDownFullText:(id)sender;
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
- (IBAction)EditButtonTapped;


@property (nonatomic,retain) UITableView* searchResultList;
@property (nonatomic,retain) IBOutlet UIView* sideActionsView;
@property (nonatomic,retain) IBOutlet UIView* listSearchView;
@property (nonatomic,retain) IBOutlet UIView* resultAreaView;

@property (nonatomic,retain) IBOutlet UIView* listFavView;
@property (nonatomic,retain) IBOutlet UIView* listDownloadView;

@property (nonatomic,retain) IBOutlet UIView* advanedView;

@property (nonatomic,retain) IBOutlet UILabel* detailJournalAndDate;
@property (nonatomic,retain) IBOutlet UILabel* detailTitle;
@property (nonatomic,retain) IBOutlet UILabel* detailAuthors;
@property (nonatomic,retain) IBOutlet UILabel* detailaffiliations;
@property (nonatomic,retain) IBOutlet UILabel* detailAbstractText;
@property (nonatomic,retain) IBOutlet UILabel* detailKeyword;

@property (nonatomic,retain) IBOutlet UIScrollView* AbstractTextScrollView;

@property (nonatomic,retain) IBOutlet UIView* titleLeftView;
@property (nonatomic,retain) IBOutlet UIView* titleActionsView;

@property (nonatomic,retain) IBOutlet UIView* searchbarView;
@property (nonatomic,retain) IBOutlet UIView* searchListView;
@property (nonatomic,retain) IBOutlet UIView* searchResultView;
@property (nonatomic,retain) IBOutlet UIView* searchResultCoverView;

@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic,retain) IBOutlet UILabel* loadingLabel;
@property (nonatomic,retain) IBOutlet UILabel* errorLabel;

@property (nonatomic,retain) NSDictionary* searchedResult;
@property (nonatomic,retain) NSMutableArray* resultReadingStatus;

@property (nonatomic,retain) IBOutlet UITableView* advSearchList;
@property (nonatomic,retain) UITableView* favList;
@property (nonatomic,retain) UITableView* downList;

@property (nonatomic,retain) UIButton* langSelButton;


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
@property (nonatomic,retain) downloader* fullTextDownloader;

@property (nonatomic,retain) IBOutlet UIScrollView* detailView;
@property (nonatomic,retain) PDFViewTiled* pdfView;
@property (nonatomic,retain) PDFViewTiled* prePdfView;
@property (nonatomic,retain) PDFViewTiled* nextPdfView;

@property (nonatomic,retain) IBOutlet UIButton* switchButton;
@property (nonatomic,retain) IBOutlet UILabel* pageNo;
@property (nonatomic,retain) IBOutlet UIView* startCover;

@property (nonatomic,retain) NSMutableArray* favArrays;
@property (nonatomic,retain) IBOutlet UIButton* favEditButton;

@end
