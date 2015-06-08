//
//  DocArticleController.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-21.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "RequestDocInfo.h"
#import "PDFReaderController.h"
#import "LoginActiveController.h"
#import "NMCustomLabel.h"
#import "UserInfoViewController.h"
#import "EnumType.h"

@protocol DocArticleControlDelegate <NSObject>
@optional
- (void)docdetailRequestFinishedWithString:(NSString *)info;
- (void)checkSearchMgr;
- (void)showInviteRegisterViewController;
- (void)showUserInfoVC:(BOOL)temp;
@end

@interface DocArticleController : UIViewController <ASIHTTPRequestDelegate, UIScrollViewDelegate, LoginActiveDelegate, UIAlertViewDelegate,DocArticleControlDelegate,ASIProgressDelegate>
{
    UIAlertView *alertView1;
    BOOL isSuccess;
    BOOL ismaxValue;
    BOOL isRecordWaiting;
    UINavigationController* userNav;
}

@property (nonatomic, retain) ASIHTTPRequest* httpRequest;

@property (nonatomic,retain) UIAlertView* alertView;

@property(nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property(nonatomic, retain) IBOutlet UIView* articleView;

@property(nonatomic, retain) IBOutlet UILabel* journal;
@property(nonatomic, retain) IBOutlet UIImageView* docTitleBar;

@property(nonatomic, retain) IBOutlet UILabel* docTitle;
@property(nonatomic, retain) IBOutlet UILabel* authors;
@property(nonatomic, retain) IBOutlet UILabel* affiliation;

@property(nonatomic, retain) IBOutlet UIImageView* splitLine;

@property(nonatomic, retain) IBOutlet UIImageView* abstractHeaderBg;
@property(nonatomic, retain) IBOutlet UILabel* abstractHeader;
@property(nonatomic, retain) IBOutlet UILabel* abstractText;
@property(nonatomic, retain) IBOutlet UILabel* abstractBackground;
@property(nonatomic, retain) IBOutlet UILabel* abstractObjective;
@property(nonatomic, retain) IBOutlet UILabel* abstractMethods;
@property(nonatomic, retain) IBOutlet UILabel* abstractResults;
@property(nonatomic, retain) IBOutlet UILabel* abstractConclusions;
@property(nonatomic, retain) IBOutlet UILabel* abstractCopyrights;

@property(nonatomic, retain) IBOutlet UIImageView* keywordHeaderBg;
@property(nonatomic, retain) IBOutlet UILabel* keywordHeader;
@property(nonatomic, retain) IBOutlet UILabel* keywordText;

@property(nonatomic, retain) IBOutlet UIToolbar* toolBar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem* downsizeBtn;
@property(nonatomic, retain) IBOutlet UIBarButtonItem* enlargeBtn;
@property(nonatomic, retain) IBOutlet UIBarButtonItem* favBtn;
@property(nonatomic, retain) IBOutlet UIBarButtonItem* downloadBtn;

@property(nonatomic, retain) IBOutlet UIProgressView* progressVC;
@property(nonatomic, retain) NSString* externalId;
@property(nonatomic, retain) NSString* source;

@property(nonatomic, retain) PDFReaderController* pdfReader;

@property(strong, nonatomic) RequestDocInfo *requestDocInfo;

@property(nonatomic, assign) BOOL isOffline;
@property(nonatomic, assign) BOOL isAskFor;
@property(nonatomic, assign) NSUInteger currentFontSize;

@property(nonatomic, assign) BOOL isLogin;
@property(nonatomic, assign) BOOL isFav;
@property(nonatomic, assign) BOOL emailActive;
@property(nonatomic, assign) BOOL mobileActive;
@property(nonatomic, retain) NSString* downloadStatus;
@property(nonatomic, retain) NSString* fetchStatus;

@property(nonatomic, assign) CGFloat contentHeight;
@property(nonatomic, assign) int goSelect;

@property (nonatomic, retain) NSMutableDictionary* resultsJson;
@property (nonatomic, copy) NSString *detailTile;
@property(nonatomic, assign) BOOL isrequestWaiting;
@property(nonatomic, assign) BOOL isSearchList;
@property(nonatomic, retain) UserInfoViewController *user;

@property(nonatomic, retain) NSTimer *downtimer;
@property(nonatomic, assign) NSInteger downCount;
@property(nonatomic, assign) BOOL isRecordWaiting;

@property(nonatomic, assign) BOOL isMydocumentCN;
@property(nonatomic, assign) ListType listType;
-(IBAction)enLargeText:(id)sender;
-(IBAction)downsizeText:(id)sender;

-(IBAction)downloadOrRequest:(id)sender;
-(IBAction)doShare:(id)sender;
-(IBAction)doFav:(id)sender;
-(IBAction)removeFav:(id)sender;

-(void) layoutDocArticle:(NSDictionary*)resultsJsons;

-(void) scaleByFont:(NSUInteger) fontSize;

-(void) popBack;
-(void) setSourceOnRequest:(NSDictionary*)resultsJsons;

-(void) userLoginFinished:(BOOL)animated;
-(void) userLoginClose;
-(void) loginViewDismissed;

-(void) doDownload:(BOOL)isAskFor;
- (void) checkSearchMgrRequest;
-( void)doRequest;
@end
