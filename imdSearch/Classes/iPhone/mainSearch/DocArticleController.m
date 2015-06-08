//
//  DocArticleController.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-21.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "DocArticleController.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "Strings.h"
#import "TableViewFormatUtil.h"
#import "imdSearchAppDelegate.h"
#import "UserManager.h"
#import "ImageViews.h"
#import "CompatibilityUtil.h"
#import "TKAlertCenter.h"
#import "imdSearchAppDelegate_iPhone.h"
#import "IPhoneHeader.h"
#import "MyDataBaseSql.h"
#import "MyDatabase.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "InviteRegisterViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "RealNameViewController.h"
#import "MyDocumentViewController.h"
#import "LoginSelectController.h"

@implementation DocArticleController

@synthesize alertView;
@synthesize progressVC;
@synthesize downtimer;
@synthesize isRecordWaiting;
@synthesize isMydocumentCN;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = DOC_ARTICLE_TEXT;
        _isOffline = NO;
        _pdfReader = [[PDFReaderController alloc] initWithNibName:nil bundle:nil];
        self.pdfReader.delegated = self;
        alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:SET_KNOW otherButtonTitles:nil];
        self.requestDocInfo = [[RequestDocInfo alloc] init];
        self.requestDocInfo.delegate = self;
        
        [self eventClickButtonInit];
    }
    return self;
}

-(void) popBack
{
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) dealloc
{
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
}

#pragma mark - init toolBar and back Button
- (void)eventClickButtonInit{
    _downsizeBtn = [self toolBarButtonItemInitWIthImage:@"toolbar_sizedown_default" seletor:@selector(downsizeText:)];
    
    _enlargeBtn = [self toolBarButtonItemInitWIthImage:@"toolbar_sizeup_default" seletor:@selector(enLargeText:)];
    
    _favBtn = [self toolBarButtonItemInitWIthImage:@"toolbar_fav_default" seletor:@selector(doFav:)];
    
    _downloadBtn =  [self toolBarButtonItemInitWIthImage:@"toolbar_download_default" seletor:@selector(downloadOrRequest:)];
    
    self.currentFontSize = FONT_1;
}

- (UILabel *)customLabelInit:(UIView*)parent
{
    UILabel* cl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 10)];
    
    [parent addSubview:cl];
    [cl setBackgroundColor:[UIColor clearColor]];
    cl.numberOfLines = 0;
    cl.textAlignment = NSTextAlignmentLeft;
    cl.textAlignment =NSLineBreakByWordWrapping;
    
    return cl;
}

- (UIBarButtonItem *)toolBarButtonItemInitWIthImage:(NSString *)img seletor:(SEL)selector{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:img] style:UIBarButtonItemStylePlain target:self action:selector];
    item.width = 68;
    [item setImageInsets:UIEdgeInsetsMake(3, -5, -3, 5)];
    return item;
}

- (UIImageView*)headerBgInit:(UIView*)parent imageName:(NSString*) imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *iv = [[UIImageView alloc]initWithImage:image];
    [iv setOpaque:NO];
    [iv setBackgroundColor:[UIColor clearColor]];
    
    [parent addSubview:iv];
    [parent sendSubviewToBack:iv];
    
    return iv;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.user = [[UserInfoViewController alloc] init];
    self.user.delegate = self;
    userNav = [[UINavigationController alloc] initWithRootViewController:self.user];
    [TableViewFormatUtil setNavigationBar:userNav normal:IMG_ICON_FAVORATES_NORMAL highlight:IMG_ICON_FAVORATES_HIGHLIGHT barBg:IMG_BG_NAVGATIONBAR];
    
    [TableViewFormatUtil setShadow:self.navigationController.navigationBar];
    
    self.toolBar.layer.shadowOpacity = 0.4;
    self.toolBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.toolBar.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.toolBar.layer.shadowRadius = 2;
    
    [TableViewFormatUtil setContentBackGround:self.view image:IMG_BG_CONTENTSBACKGROUDN];
    
    [self.toolBar setItems:[NSArray arrayWithObjects:self.downsizeBtn, self.enlargeBtn, self.favBtn, self.downloadBtn, nil] animated:YES];
    self.scrollView.hidden = YES;
    if (!(IOS7)) {
        self.toolBar.tintColor =  RGBCOLOR(64,111,176);
    }
    
    self.journal = [self customLabelInit:self.scrollView];
    self.docTitle = [self customLabelInit:self.scrollView];
    self.authors = [self customLabelInit:self.scrollView];
    self.affiliation = [self customLabelInit:self.scrollView];
    
    self.abstractHeader = [self customLabelInit:self.scrollView];
    self.abstractText = [self customLabelInit:self.scrollView];
    self.abstractBackground = [self customLabelInit:self.scrollView];
    self.abstractObjective = [self customLabelInit:self.scrollView];
    self.abstractMethods = [self customLabelInit:self.scrollView];
    self.abstractResults = [self customLabelInit:self.scrollView];
    self.abstractConclusions = [self customLabelInit:self.scrollView];
    self.abstractCopyrights = [self customLabelInit:self.scrollView];
    
    self.keywordHeader = [self customLabelInit:self.scrollView];
    self.keywordText = [self customLabelInit:self.scrollView];
    
    self.abstractHeaderBg = [self headerBgInit:self.scrollView imageName:IMG_TAG];
    self.keywordHeaderBg = [self headerBgInit:self.scrollView imageName:IMG_TAG];
    self.docTitleBar = [self headerBgInit:self.scrollView imageName:@"preview_title_decorate"];
  self.downCount = 0;
  if (IOS7) {
    self.progressVC.hidden = NO;
  }else
  {
  self.progressVC.hidden = YES;
  }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    if ([self.resultsJson count]) {
        [self layoutDocArticle:self.resultsJson];
    }
    
    self.isFav = [MyDatabase isSelectId:self.externalId ismgr:IMD_Mydoc userid:[UserManager userName]];
    
    if (self.isFav) {
        [self.favBtn setImage:[UIImage imageNamed:@"toolbar_fav_press"]];
        [self.favBtn setAction:@selector(removeFav:)];
    } else {
        [self.favBtn setImage:[UIImage imageNamed:@"toolbar_fav_default"]];
        [self.favBtn setAction:@selector(doFav:)];
    }
    
    //[TableViewFormatUtil backBarButtonItemInfoModify:self.navigationItem];
    
    isSuccess = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewDidDisappear:(BOOL)animated
{
  [self.progressVC setProgress:0];
  [self.downtimer invalidate];
  self.downtimer = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ios6 Orientation
- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0)
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0)
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark layout
-(void) layoutDocArticle:(NSDictionary*)resultsJsons
{
    if (iPhone5) {
        self.scrollView.frame = CGRectMake(0, 0, 320, 460);
    }
    
    self.scrollView.hidden = NO;
    self.view.hidden = NO;
    //Set Results Count.
    [self.docTitle setText:[resultsJsons objectForKey:DOC_TITLE]];
    self.detailTile = [resultsJsons objectForKey:DOC_TITLE];
    NSString* journalStr = [resultsJsons objectForKey:DOC_JOURNAL];
    NSString* pubDate = [resultsJsons objectForKey:DOC_PUBDATE];
    NSString* volume = [resultsJsons objectForKey:DOC_VOLUME];
    NSString* issue = [resultsJsons objectForKey:DOC_ISSUE];
    NSString* pagination = [resultsJsons objectForKey:DOC_PAGINATION];
    
    [self.journal setText:[Strings getJournal:journalStr pubDate:pubDate volume:volume issue:issue pagination:pagination]];
    
    self.journal.textAlignment = NSTextAlignmentLeft;
    self.journal.textColor = [TableViewFormatUtil getFontColor1];
    
    self.docTitle.textAlignment = NSTextAlignmentLeft;
    self.docTitle.textColor =[UIColor blackColor];  //标题的文字颜色
    
    self.authors.textAlignment = NSTextAlignmentLeft;
    self.authors.textColor = [TableViewFormatUtil getFontColor1];
    
    self.affiliation.textAlignment = NSTextAlignmentLeft;
    self.affiliation.textColor = [TableViewFormatUtil getFontColor1];
    
    self.abstractHeader.textAlignment = NSTextAlignmentLeft;
    self.abstractHeader.textColor = [UIColor whiteColor];
    self.abstractHeader.shadowColor = [UIColor groupTableViewBackgroundColor];
    
    UIColor* myTextColor = RGBCOLOR(57, 77, 97);
    
    self.abstractText.textAlignment = NSTextAlignmentLeft;
    self.abstractText.textColor = myTextColor;
    
    self.abstractBackground.textAlignment = NSTextAlignmentLeft;
    self.abstractBackground.textColor = myTextColor;
    
    self.abstractObjective.textAlignment = NSTextAlignmentLeft;
    self.abstractObjective.textColor = myTextColor;
    
    self.abstractMethods.textAlignment = NSTextAlignmentLeft;
    self.abstractMethods.textColor = myTextColor;
    
    self.abstractResults.textAlignment = NSTextAlignmentLeft;
    self.abstractResults.textColor = myTextColor;
    
    self.abstractConclusions.textAlignment = NSTextAlignmentLeft;
    self.abstractConclusions.textColor = myTextColor;
    
    self.abstractCopyrights.textAlignment = NSTextAlignmentLeft;
    self.abstractCopyrights.textColor = myTextColor;
    
    self.keywordHeader.textAlignment = NSTextAlignmentLeft;
    self.keywordHeader.textColor = [UIColor whiteColor];
    
    self.keywordText.textAlignment = NSTextAlignmentLeft;
    self.keywordText.textColor = myTextColor;
    
    NSArray* authorArray = [resultsJsons objectForKey:DOC_AUTHOR];
    [self.authors setText:[Strings arrayToString:authorArray]];
    
    [self.affiliation setText:[Strings arrayToString:[resultsJsons objectForKey:DOC_AFFILIATION]]];
    
    if ([self.source isEqualToString:SEARCH_MODE_C])
        [self.abstractHeader setText:ARTICLE_ABSTRACT_CN];
    else
        [self.abstractHeader setText:ARTICLE_ABSTRACT];
    
    [self.abstractText setText:[Strings arrayToString:[[resultsJsons objectForKey:DOC_ABSTRCTTEXT] objectForKey:ABSTRACT_TEXT]]];
    
    [self.abstractBackground setText:[Strings arrayToString:[[resultsJsons objectForKey:DOC_ABSTRCTTEXT] objectForKey:ABSTRACT_BACKGROUND]]];
    
    [self.abstractObjective setText:[Strings arrayToString:[[resultsJsons objectForKey:DOC_ABSTRCTTEXT] objectForKey:ABSTRACT_OBJECTIVE]]];
    
    [self.abstractMethods setText:[Strings arrayToString:[[resultsJsons objectForKey:DOC_ABSTRCTTEXT] objectForKey:ABSTRACT_METHODS]]];
    
    [self.abstractResults setText:[Strings arrayToString:[[resultsJsons objectForKey:DOC_ABSTRCTTEXT] objectForKey:ABSTRACT_RESULTS]]];
    
    [self.abstractConclusions setText:[Strings arrayToString:[[resultsJsons objectForKey:DOC_ABSTRCTTEXT] objectForKey:ABSTRACT_CONCLUSIONS]]];
    
    [self.abstractCopyrights setText:[Strings arrayToString:[[resultsJsons objectForKey:DOC_ABSTRCTTEXT] objectForKey:ABSTRACT_COPYRIGHTS]]];
    
    if ([self.source isEqualToString:SEARCH_MODE_C])
        [self.keywordHeader setText:ARTICLE_KEYWORD_CN];
    else
        [self.keywordHeader setText:ARTICLE_KEYWORD];
    
    [self.keywordText setText:[Strings arrayToString:[resultsJsons objectForKey:DOC_KEYWORDS]]];
    
    [self scaleByFont:self.currentFontSize];
}

-(void) scaleByFont:(NSUInteger) fontSize
{
    UIFont* font1 = [UIFont fontWithName:FONT_TYPE size:fontSize -2 ];
    UIFont* font2 = [UIFont fontWithName:FONT_TYPE size:fontSize + 2];
    
    UIFont* font3 = [UIFont fontWithName:FONT_BOLD size:fontSize + 10];
    self.journal.font = font1;
    self.docTitle.font = font3;
    self.authors.font = font1;
    self.affiliation.font = font1;
    
    //    abstractHeader.font = font2Bold;
    self.abstractHeader.font = [UIFont fontWithName:FONT_TYPE size:13.0];
    
    self.abstractText.font = font2;
    self.abstractBackground.font = font2;
    self.abstractObjective.font = font2;
    self.abstractMethods.font = font2;
    self.abstractResults.font = font2;
    self.abstractConclusions.font = font2;
    self.abstractCopyrights.font = font2;
    
    //    keywordHeader.font = font2Bold;
    self.keywordHeader.font = [UIFont fontWithName:FONT_TYPE size:13.0];
    
    self.keywordText.font = font2;
    
    NSInteger yOffSet = CONTENT_MARGIN;
    NSInteger contentWidth = 300;
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.journal text:self.journal.text y:yOffSet contentWidth:contentWidth];
    
    
    NSInteger temp = yOffSet;
    
    //  yOffSet = [TableViewFormatUtil layoutLabelByStringWithLeft:docTitle text:docTitle.text y:yOffSet contentWidth:contentWidth marginLeft:CONTENT_MARGIN_LEFT];
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.docTitle text:self.docTitle.text y:yOffSet contentWidth:contentWidth];
    
    
    [self.docTitleBar setFrame:CGRectMake(0, temp, self.docTitleBar.frame.size.width, self.docTitle.frame.size.height - 4)];
    
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.authors text:self.authors.text y:yOffSet contentWidth:contentWidth];
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.affiliation text:self.affiliation.text y:yOffSet contentWidth:contentWidth];
    
    //Set in ScollView.
    //NSInteger yOffSetInScroll = CONTENT_MARGIN;
    //[scrollView setFrame:CGRectMake(0.0, yOffSet, scrollView.frame.size.width, scrollView.frame.size.height)];
    
    //scrollView.hidden = NO;
    //Abstract.
    
    yOffSet = [TableViewFormatUtil layoutImageView:self.splitLine y:yOffSet];
    
    yOffSet = yOffSet + 10;
    
    [self.abstractHeaderBg setFrame:CGRectMake(CONTENT_MARGIN_LEFT, yOffSet, self.abstractHeaderBg.frame.size.width, self.abstractHeaderBg.frame.size.height)];
    
    yOffSet = yOffSet + 4;
    
    yOffSet = [TableViewFormatUtil layoutLabelByStringWithLeft:self.abstractHeader text:self.abstractHeader.text y:yOffSet contentWidth:contentWidth marginLeft:23];
    
    //  yOffSet = [TableViewFormatUtil layoutLabelByString:abstractHeader text:abstractHeader.text y:yOffSet contentWidth:contentWidth];
    
    yOffSet = yOffSet + 10;
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.abstractText text:self.abstractText.text y:yOffSet contentWidth:contentWidth];
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.abstractBackground text:self.abstractBackground.text y:yOffSet contentWidth:contentWidth];
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.abstractObjective text:self.abstractObjective.text y:yOffSet contentWidth:contentWidth];
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.abstractMethods text:self.abstractMethods.text y:yOffSet contentWidth:contentWidth];
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.abstractResults text:self.abstractResults.text y:yOffSet contentWidth:contentWidth];
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.abstractConclusions text:self.abstractConclusions.text y:yOffSet contentWidth:contentWidth];
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.abstractCopyrights text:self.abstractCopyrights.text y:yOffSet contentWidth:contentWidth];
    
    //Keyword.
    [self.keywordHeaderBg setFrame:CGRectMake(CONTENT_MARGIN_LEFT, yOffSet, self.keywordHeaderBg.frame.size.width, self.keywordHeaderBg.frame.size.height)];
    yOffSet = yOffSet + 4;
    
    yOffSet = [TableViewFormatUtil layoutLabelByStringWithLeft:self.keywordHeader text:self.keywordHeader.text y:yOffSet contentWidth:contentWidth marginLeft:23];
    
    yOffSet = yOffSet + 10;
    
    yOffSet = [TableViewFormatUtil layoutLabelByString:self.keywordText text:self.keywordText.text y:yOffSet contentWidth:contentWidth];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, yOffSet)];
    self.contentHeight = yOffSet;
}

#pragma mark Zoom in ScrollView
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.articleView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollViewP withView:(UIView *)view atScale:(float)scale
{
    if (scrollViewP == self.scrollView) {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, self.contentHeight * scale)];
    }
}
#pragma mark Asy Request

-(void) setSourceOnRequest:(NSDictionary*)resultsJsons
{
    NSString* pmid = [resultsJsons objectForKey:DOC_PMID];
    
    if (pmid != nil && pmid.length > 0 &&![pmid isEqualToString:@"(null)"])
        self.source = SEARCH_MODE_E;
    else
        self.source = SEARCH_MODE_C;
}


-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self performSelector:@selector(downLoadButtonEnbled) withObject:self afterDelay:15.0];
    NSLog(@"%@",[request responseString]);
    NSLog(@"error %d", [request responseStatusCode]);
    NSDictionary *info = [request userInfo];
    NSString* rType = [info objectForKey:@"key"];
    self.view.hidden = NO;
    if ([rType isEqualToString:@"getPDF"]) {
        [self pdfDownOrRequestRequestFinished:request];
        return;
    }
    NSDictionary* res = [UrlRequest getJsonValue:request];
    NSMutableArray* requestStatus =[res objectForKey:REQUEST_TYPE_STATUS];
    if ([requestStatus count]) {
        NSString *status = [[requestStatus objectAtIndex:0] objectForKey:RETINFO_STATUS];
        if ([status isEqualToString:@""]) {
          if (isMydocumentCN) {
            UIAlertView *alertD = [[UIAlertView alloc]initWithTitle:@"文献无全文" message:REQUEST_DOC_FAILED delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
            [alertD show];
          }else
            [self doRequest];
        }else if([status isEqualToString:RETINFO_STATUS_SUCC]){
            //      UIAlertView* alert = [[UIAlertView alloc] initWithTitle:REQUEST_DOC message:REQUEST_DOC_DID delegate:self cancelButtonTitle:IKNOW_TEXT otherButtonTitles:CHECKNOW_TEXT, nil];
            //      [alert show];
            [self doDownload:self.isAskFor];
            isSuccess = YES;
            return;
        }else if ([status isEqualToString:RETINFO_STATUS_WAIT]) {
          if (self.navigationController.viewControllers.count > 0) {
          self.isRecordWaiting = [[self.navigationController.viewControllers objectAtIndex:0] isKindOfClass:[MyDocumentViewController class]];
          }
          if (self.isRecordWaiting) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:REQUEST_DOC message:REQUEST_DOC_DID_AGAIN delegate:self cancelButtonTitle:IKNOW_TEXT otherButtonTitles:nil];
            [alert show];
          }else
          {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:REQUEST_DOC message:REQUEST_DOC_DID delegate:self cancelButtonTitle:IKNOW_TEXT otherButtonTitles:CHECKNOW_TEXT,nil];
            [alert show];
          }
          self.isRecordWaiting = NO;
            [self downLoadButtonEnbled];
            
            isSuccess = NO;
        }
    }else {
        NSDictionary* userInfo =[request userInfo];
        NSString* requestType =[userInfo objectForKey:REQUEST_TYPE];
        if ([requestType isEqualToString:REQUEST_TYPE_DO_FAV]) {
            NSString* ret = [request responseString];
            NSLog(@"ret: %@", ret);
            if ([ret isEqualToString:@"true"]) {
                [self.favBtn setImage:[UIImage imageNamed:@"toolbar_fav_press"]];
                [self.favBtn setAction:@selector(removeFav:)];
                self.isFav = true;
                [[TKAlertCenter defaultCenter] postAlertWithMessage:FAVORITES_SUCCESS];
                [MyDataBaseSql insertDetail:self.resultsJson ismgr:IMD_Mydoc filePath:@"NO Value !"];
                
            }
            
            else
                [[TKAlertCenter defaultCenter] postAlertWithMessage:FAVORITES_FAILED];
        } else if ([requestType isEqualToString:REQUEST_TYPE_REMOVE_FAV]) {
            NSString* ret = [request responseString];
            NSLog(@"xxxxret: %@", ret);
            if ([ret isEqualToString:@"true"]) {
                [self.favBtn setImage:[UIImage imageNamed:@"toolbar_fav_default"]];
                [self.favBtn setAction:@selector(doFav:)];
                self.isFav = false;
                [[TKAlertCenter defaultCenter] postAlertWithMessage:FAVORITES_REMOVED];
                [MyDatabase cleanFav:@"MySearchTable" ismgr:IMD_Mydoc externalId:self.externalId userid:[UserManager userName]];
            }
        } else {
            NSDictionary* resultsUserOp = [UrlRequest getJsonValue:request];
            self.resultsJson = [resultsUserOp objectForKey:ARTICLE_USER_OP];
            NSLog(@"resultsJson======%@",self.resultsJson);
            if (!self.isSearchList) {
                [MyDataBaseSql insertDetail:self.resultsJson ismgr:IMD_Mydoc filePath:@"NO Value !"];
            }
            self.isLogin = [[resultsUserOp objectForKey:ARTICLE_USER_ISLOGIN] boolValue];
            
            self.emailActive = [[resultsUserOp objectForKey:ARTICLE_USER_EMAILACTIVE] boolValue];
            self.mobileActive = [[resultsUserOp objectForKey:ARTICLE_USER_MOBILEACTIVE] boolValue];
            
            if (self.resultsJson == nil) {
                NSLog(@"Nil Results");
                self.resultsJson = [MyDatabase readDocData:IMD_Mydoc externalId:self.externalId];
                [self layoutDocArticle:self.resultsJson];
                return;
            }
            
            if ([UserManager isLogin]) {
                self.isFav = [[resultsUserOp objectForKey:ARTICLE_USER_ISFAV] boolValue];
                if (self.isFav) {
                    [self.favBtn setImage:[UIImage imageNamed:@"toolbar_fav_press"]];
                    [self.favBtn setAction:@selector(removeFav:)];
                }
                if ([self.source isEqualToString:SEARCH_MODE_E])
                    self.fetchStatus = [resultsUserOp objectForKey:ARTICLE_USER_FETCHSTATUS];
            }
            
            //Check if results is nil.
            if (self.resultsJson == nil) {
                NSLog(@"Nil Results");
                return;
            } else {
                [self layoutDocArticle:self.resultsJson];
                if ([self.source isEqualToString:SEARCH_MODE_C])
                    [self.pdfReader.localInfo setObject:self.resultsJson forKey:LOCAL_RESULT];
                else
                    [self.requestDocInfo.localInfo setObject:self.resultsJson forKey:LOCAL_RESULT];
                [self.pdfReader.localInfo setObject:self.resultsJson forKey:LOCAL_RESULT];
            }
            self.view.hidden = NO;
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [self downLoadButtonEnbled];
    NSLog(@"request failed %@",[request responseString]);
    NSLog(@"error %d", [request responseStatusCode]);
    self.resultsJson = [MyDatabase readDocData:IMD_Mydoc externalId:self.externalId];
    if ([self.resultsJson count]) {
        [self layoutDocArticle:self.resultsJson];
    }
    
    self.view.hidden = NO;
    alertView1 = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:SETTINGS_CALL_CANCEL otherButtonTitles:nil];
    [alertView1 show];
}

-(void) doDownload:(BOOL)isAskFor
{
    if (![UserManager isLogin]) {
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView:self title:DOWNLOAD_FREE_DOC];
        [self downLoadButtonEnbled];
        return;
    }
    if (self.isrequestWaiting) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:REQUEST_DOC message:REQUEST_DOC_ISREQUESTING delegate:nil cancelButtonTitle:IKNOW_TEXT otherButtonTitles:nil];
        [alert show];
        
        [self downLoadButtonEnbled];
        return;
    }
  if (self.externalId == nil || self.externalId.length == 0) {
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"ID为空无法下载"];
    return;
  }
    self.pdfReader.currentId = self.externalId;
    if (self.isOffline || [self.pdfReader findInCache:self.externalId]) {
        self.isOffline = NO;
        [self judgeIosVersionTurn];
        
        [self.pdfReader loadPDF:self.pdfReader.filePath];
        [self.pdfReader setRightBarButtons:self.isOffline];
        //[self.pdfReader changeButtonOrientation];
        if ([self.resultsJson count]) {
            [self.pdfReader.localInfo setObject:self.resultsJson forKey:LOCAL_RESULT];
        }
        [self downLoadButtonEnbled];
        NSLog(@"resultsJsonsssss=%@",self.resultsJson);
        NSLog(@"[self.pdfReader findInCache:self.externalId]%@",self.externalId);
    } else {
        imdSearchAppDelegate_iPhone *appDelegateIPhone = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
        
        if (appDelegateIPhone.settings.downloadOnWiFiOnly && ![UrlRequest isWiFi]) {
            self.alertView.title = HINT_TEXT;
            self.alertView.message = DOWNLOAD_WIFI_ONLY;
            [self.alertView show];
            [self downLoadButtonEnbled];
        } else {
            self.pdfReader.tmpFilePath = [UrlRequest getDownloadFilePath:self.externalId];
            self.pdfReader.filePath = [UrlRequest getSavedFilePath:self.externalId];
            
            if (![UserManager isLogin]) {
                imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate showLoginView:self title:DOWNLOAD_FREE_DOC];
                [self downLoadButtonEnbled];
                return;
            }
            if ([self.source isEqualToString:@"en"]) {
                self.pdfReader.emailActive = self.emailActive;
                self.pdfReader.mobileActive = self.mobileActive;
                
                if (self.pdfReader.httpRequest != nil)
                    [self.pdfReader.httpRequest clearDelegatesAndCancel];
                
                [ImdAppBehavior askforFullText];
                self.pdfReader.httpRequest = [UrlRequest askForPdf:self.externalId delegate:self];
              self.downtimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(downTimer) userInfo:nil repeats:YES];
              [ImdAppBehavior downloadFullText];
            } else {
                
                self.pdfReader.emailActive = self.emailActive;
                self.pdfReader.mobileActive = self.mobileActive;
                
                if (self.pdfReader.httpRequest != nil)
                    [self.pdfReader.httpRequest clearDelegatesAndCancel];
              if (self.isMydocumentCN) {
                self.pdfReader.httpRequest = [UrlRequest downloadCNFile:self.externalId delegate:self];
              }else
                self.pdfReader.httpRequest = [UrlRequest downloadFile:self.externalId delegate:self];
              
               [self.progressVC setProgress:0];
              self.downtimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(downTimer) userInfo:nil repeats:YES];
                [ImdAppBehavior downloadFullText];
            }
            
            self.pdfReader.view.hidden = YES;
            imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
            appDelegate.imageView.hidden = YES;
            appDelegate.SearchimageView.hidden = YES;
            appDelegate.FullTextimageView.hidden = NO;
            appDelegate.backNavigationBar.hidden = NO;
            //[self.indicator startAnimating];
            [self.pdfReader.localInfo setObject:self.resultsJson forKey:LOCAL_RESULT];
            
        }
    }
}
-(void)downTimer
{
  self.downCount = self.progressVC.progress *100;
  self.downCount = self.downCount + 2;
  [self.progressVC setProgress:self.downCount/100.00];
}
-(void)setProgress:(float)newProgress{
  
  [self.progressVC setProgress:newProgress];
  
  if (newProgress == 1) {
    [self.progressVC setProgress:0];
    [self.downtimer invalidate];
    self.downtimer = nil;
    self.downCount = 0;
  }
}
-(void) judgeIosVersionTurn
{
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
    {
        [self.navigationController pushViewController:self.pdfReader animated:YES];
    }
    else
    {
        [self.navigationController presentViewController:self.pdfReader animated:YES completion:Nil];
    }
}

-(void) doRequest
{
    if (self.requestDocInfo.isRequesting) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:REQUEST_DOC message:REQUEST_DOC_ISREQUESTING delegate:nil cancelButtonTitle:IKNOW_TEXT otherButtonTitles:nil];
        [alert show];
        [self downLoadButtonEnbled];
    } else if (self.requestDocInfo.isFetched) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:REQUEST_DOC message:REQUEST_DOC_DID delegate:self cancelButtonTitle:IKNOW_TEXT otherButtonTitles:CHECKNOW_TEXT, nil];
        [alert show];
        [self downLoadButtonEnbled];
    } else {
        self.requestDocInfo.emailActive = self.emailActive;
        self.requestDocInfo.mobileActive = self.mobileActive;
        
        if (self.requestDocInfo.httpRequest != nil)
            [self.requestDocInfo.httpRequest clearDelegatesAndCancel];
        
        self.requestDocInfo.httpRequest = [UrlRequest requestDoc:self.externalId title:self.docTitle.text delegate:self.requestDocInfo];
    }
    if (![MyDatabase isSelectId:self.externalId ismgr:IMD_Mydoc]) {
        [MyDataBaseSql insertDetail:self.resultsJson ismgr:IMD_Mydoc filePath:@"NO Value !"];
    }
    
}

#pragma mark Bar button selector
-(IBAction)downloadOrRequest:(id)sender
{
    [self downLoadButtonNotEnble];
    if (![UserManager isLogin]) {
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView:self title:REQUEST_FREE_DOC];
        [self downLoadButtonEnbled];
        return;
    }
    if (self.isrequestWaiting) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:REQUEST_DOC message:REQUEST_DOC_ISREQUESTING delegate:nil cancelButtonTitle:IKNOW_TEXT otherButtonTitles:nil];
        [alert show];
        
        [self downLoadButtonEnbled];
        return;
    }
  if (self.listType == ListTypeLocation) {
    if ([MyDatabase isSelectId:self.externalId ismgr:[UserManager userName]]) {
     
      [self judgeIosVersionTurn];
      self.pdfReader.filePath = [UrlRequest getSavedFilePath:self.externalId];
      [self.pdfReader loadPDF:self.pdfReader.filePath];
     
      [self.pdfReader.navigationItem.rightBarButtonItem setTitle:LOAD_LOCAL_SAVED];
      self.pdfReader.navigationItem.rightBarButtonItem.enabled = NO;
        //[self.pdfReader changeButtonOrientation];
      
      [self downLoadButtonEnbled];
      return;
    }
  }
    [self downloadOrRequestHttp];
}

- (void)downloadOrRequestHttp
{
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.myAuth.imdToken.length > 0) {
        [self setSourceOnRequest:self.resultsJson];
        if ([self.source isEqualToString:SEARCH_MODE_C] || self.isAskFor){
            [self doDownload:self.isAskFor];
            [ImdAppBehavior detailLog:[Util getUsername] MACAddr:[Util getMacAddress] title:self.detailTile pageName:PAGE_LOCA];
        }else{
            [ImdAppBehavior detailLog:[Util getUsername] MACAddr:[Util getMacAddress] title:self.detailTile pageName:PAGE_ASKING];
            NSMutableArray *mutArray = [[NSMutableArray alloc]init];
            [mutArray addObject:self.externalId];
            if (self.httpRequest != nil)
                [self.httpRequest clearDelegatesAndCancel];
            if (self.requestDocInfo.httpRequest != nil)
                [self.requestDocInfo.httpRequest clearDelegatesAndCancel];
    
            self.httpRequest = [UrlRequest send:[ImdUrlPath checkDocumentStatus] mutArray:mutArray delegate:self];
        }
    }else {
        [appDelegate showLoginView:self title:REQUEST_FREE_DOC];
        [self downLoadButtonEnbled];
        return;
    }
}
-(IBAction)doShare:(id)sender
{
}

-(IBAction)removeFav:(id)sender
{
    if (![UserManager isLogin]) {
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView:self title:FAVORITES_DOC];
        return;
    }
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.myAuth.imdToken.length > 0) {
        [appDelegate showLoginView:self title:REQUEST_FREE_DOC];
        return;
    }
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:REQUEST_TYPE_REMOVE_FAV forKey:REQUEST_TYPE];
    
    if (self.httpRequest != nil)
        [self.httpRequest clearDelegatesAndCancel];
    
    self.httpRequest = [UrlRequest sendWithTokenWithUserInfo:[ImdUrlPath docRemoveFavsUrl:self.externalId] userInfo:userInfo delegate:self];
    
}

-(IBAction)doFav:(id)sender
{
    if (![UserManager isLogin]) {
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView:self title:FAVORITES_DOC];
        return;
    }
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.myAuth.imdToken.length > 0) {
        [appDelegate showLoginView:self title:REQUEST_FREE_DOC];
        return;
    }
  if (self.externalId == nil || self.externalId.length == 0) {
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"ID为空无法下载"];
    return;
  }
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:REQUEST_TYPE_DO_FAV forKey:REQUEST_TYPE];
    
    if (self.httpRequest != nil)
        [self.httpRequest clearDelegatesAndCancel];
    
    self.httpRequest = [UrlRequest sendWithTokenWithUserInfo:[ImdUrlPath docFavUrl:self.externalId title:self.docTitle.text] userInfo:userInfo delegate:self];
    if (self.resultsJson != nil) {
        [MyDataBaseSql insertMySearch:self.resultsJson ismgr:IMD_Mydoc];
    }
    [ImdAppBehavior detailLog:[Util getUsername] MACAddr:[Util getMacAddress] title:self.detailTile pageName:PAGE_FAV ];
}


-(IBAction)downsizeText:(id)sender
{
    
//    [self.enlargeBtn setBackgroundImage:[UIImage imageNamed:@"toolbar_sizedown_default"] forState:UIControlStateNormal barMetrics:UIMenuControllerArrowLeft];
    if (self.currentFontSize >= FONT_1 * 2)
        [self.enlargeBtn setImage:[UIImage imageNamed:@"toolbar_sizeup_default"]];
    if (self.currentFontSize >= FONT_1 / 2 ) {
        self.currentFontSize = self.currentFontSize - 1;
        [self scaleByFont:self.currentFontSize];
    } else {
        [self.downsizeBtn setImage:[UIImage imageNamed:@"toolbar_sizedown_press"]];
    }
}


-(IBAction)enLargeText:(id)sender
{
    //UIBarButtonItem* enLarge = (UIBarButtonItem*)sender;
    if (self.currentFontSize <= FONT_1 / 2)
        [self.downsizeBtn setImage:[UIImage imageNamed:@"toolbar_sizedown_default"]];
    if (self.currentFontSize <= FONT_1 * 2 ) {
        self.currentFontSize = self.currentFontSize + 1;
        [self scaleByFont:self.currentFontSize];
    } else {
        [self.enlargeBtn setImage:[UIImage imageNamed:@"toolbar_sizeup_press"]];
    }
}


-(void) userLoginFinished
{
    //IOS 5.0 above.
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) userLoginFinished:(BOOL)animated{
}

-(void) userLoginClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) loginViewDismissed
{
}


#pragma mark - LoginActiveDelegate
- (void)MobileActiveSuccess:(LoginActiveController *)controller
{
    self.mobileActive = YES;
    [self downloadOrRequest:nil];
}


- (void)alertView:(UIAlertView *)myAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([myAlertView.message isEqualToString:REQUEST_DOC_DID] && buttonIndex == 1) {
            [self checkMydocument];
    }
    
    if ([myAlertView.title isEqualToString:REQUEST_DOC_SUCCESS_TITLE] && buttonIndex == 1) {
        [self checkMydocument];
    }
    
    if (myAlertView == alertView && buttonIndex == 0) {
        imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
        appDelegate.myTabBarController.selectedIndex = 3;
    }
    
    if (myAlertView == alertView1 && buttonIndex == 0) {
        [self popBack];
    }
    
    if (myAlertView.tag == 5 && buttonIndex == 1) {
        imdSearchAppDelegate_iPhone* app = (imdSearchAppDelegate_iPhone*) [[UIApplication sharedApplication] delegate];
        [app showAccoutActiveView:self title:@"" emailActive:self.emailActive mobileActive:self.mobileActive fromRegister:NO];
    }
    
    if ((myAlertView.tag == 6 || myAlertView.tag == 7) && buttonIndex == 1) {
        [UrlRequest send:[ImdUrlPath getUserInfo] delegate:self.user];
    }
    
    if (myAlertView.tag == 8 && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_IMD_HELP]];
    }
    
    if (myAlertView.tag == MAXNUMBERTAG && buttonIndex == 1) {
        [self showInviteRegisterViewController];
    }
    
}

#pragma mark - doc detail delegate
- (void)showUserInfoVC:(BOOL)temp
{
  if (temp) {
    [self presentViewController:userNav animated:YES completion:nil];
  }else
  {
    LoginSelectController *loginSelect = [[LoginSelectController alloc] init];
    loginSelect.type = UserInfoCenter;
    userNav = [[UINavigationController alloc] initWithRootViewController:loginSelect];
    [self presentViewController:userNav animated:YES completion:nil];
  }
}
- (void)showInviteRegisterViewController{
    InviteRegisterViewController *viewController = [[InviteRegisterViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void) checkMydocument
{
    [self.navigationController popViewControllerAnimated:NO];
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    UINavigationController* LocalNav = [appDelegate.myTabBarController.viewControllers objectAtIndex:1];
    MyDocumentViewController *myVc = [LocalNav.viewControllers objectAtIndex:0];
    myVc.docSegmentd.selectedSegmentIndex = 0;
    [myVc.recordListViewController refresh];
    appDelegate.myTabBarController.selectedIndex = 1;
}

- (void)docdetailRequestFinishedWithString:(NSString *)info{
    
    if ([info isEqualToString:@"SUCCESS"]) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSArray* array = [defaults arrayForKey:FULLTEXT_REQUEST_LIST];
        
        NSString* exterelId = [[self.requestDocInfo.localInfo objectForKey:LOCAL_RESULT]objectForKey:DOC_EXTERNALID];
        if (![self.requestDocInfo findInCache: exterelId]) {
            NSMutableArray* mutableArray = [NSMutableArray arrayWithArray:array];
            [mutableArray addObject:self.requestDocInfo.localInfo];
            [defaults setObject:mutableArray forKey:FULLTEXT_REQUEST_LIST];
            [defaults synchronize];
        }
        self.requestDocInfo.isFetched = YES;
        if ([Strings phoneNumberJudge:[UserManager userName]]) {
            //add tin
            UIAlertView* myAlert = [[UIAlertView alloc] initWithTitle:REQUEST_DOC_SUCCESS_TITLE message:@"文献全文将在两个工作日内发送到您的“本地文献”，请注意查看“已索取”" delegate:self cancelButtonTitle:IKNOW_TEXT otherButtonTitles:CHECKNOW_TEXT, nil];
            
            [myAlert show];
        }else
        {
            UIAlertView* myAlert = [[UIAlertView alloc] initWithTitle:REQUEST_DOC_SUCCESS_TITLE message:REQUEST_DOC_SUCCESS delegate:self cancelButtonTitle:IKNOW_TEXT otherButtonTitles:CHECKNOW_TEXT, nil];
            
            [myAlert show];
        }
    } else if ([info isEqualToString:@"MAXVALUE"]) {
        //add tin
        UIAlertView *maxAlertView = [[UIAlertView alloc] initWithTitle:DOWLOAD_UPPERNUM message:DOWNLOAD_DOC_MAXVALUE delegate:self cancelButtonTitle:SET_KNOW otherButtonTitles:SET_INVITE, nil];
        maxAlertView.tag = MAXNUMBERTAG;
        [maxAlertView show];
    } else if ([info isEqualToString:@"FAIL"]) {
      [self.alertView setTitle:@"文献无全文"];
        [self.alertView setMessage:REQUEST_DOC_FAILED];
        [self.alertView show];
    }else if ([info isEqualToString:@"UNVERIFIED"]) {
        NSString *name = [UserManager userName];
        NSString *isOk = [[NSUserDefaults standardUserDefaults] objectForKey:name];
        if ([isOk isEqualToString:@"0"]) {
            UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的身份尚未通过实名验证，请先收藏文献。验证后即可免费获取文献全文。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"完善帐号信息",nil];
            alertE.tag = 7;
            [alertE show];
        }else if([isOk isEqualToString:@"1"])
        {
            UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的身份验证已经提交,我们将在两个工作日内完成验证。身份验证通过后即可免费获取全文。您可先收藏此文献。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"重新修改", nil];
            alertE.tag = 6;
            [alertE show];
        }
    }else if ([info isEqualToString:@"INACTIVE"]) {
        UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的帐号注册尚未完成，请先激活手机或邮箱。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"前去激活",nil];
        alertE.tag = 5;
        [alertE show];
    }
}

//-(void) checkSearchMgrRequest
//{
//    IPhoneSearchMgr* searchMgr = [[IPhoneSearchMgr alloc] init];
//    [searchMgr showNotInTabBar];
//    [searchMgr showRequest];
//    self.navigationItem.backBarButtonItem = nil;
//    [self.navigationController pushViewController:searchMgr animated:YES];
//}

-(void)pdfDownOrRequestRequestFinished:(ASIHTTPRequest *)request
{
    NSString* s =[request responseString];
    self.pdfReader.saveToLocal.hidden = NO;
    if (s != nil) {
    }
    else
    {
        NSLog(@"loading pdf: %@", self.pdfReader.tmpFilePath);
        
        if(![self.pdfReader loadPDF:self.pdfReader.tmpFilePath]) {
            // [self clearCaches:self.currentId];
            NSLog(@"load pdf failed");
            self.pdfReader.saveToLocal.hidden = YES;
            NSString* response =[NSString stringWithContentsOfFile:self.pdfReader.
                                 tmpFilePath encoding:NSUTF8StringEncoding error:NULL];
            NSString* status = response;
            UIAlertView *alertD = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的帐号未通过手机或者邮箱验证，请先进行验证。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认",nil];
            if ([status isEqualToString:@"FAIL"]) {
                UIAlertView *alertD = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的帐号未通过手机或者邮箱验证，请先进行验证。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"睿医帮助",nil];
                alertD.tag = 8;
                [alertD setTitle:@"文献无全文"];
                [alertD setMessage:DOWNLOAD_DOC_FAILEDS];
                [alertD show];
                [self downLoadButtonEnbled];
            } else if ([status isEqualToString:@"QUEUE"]) {
                [alertD setTitle:@"文献无全文"];
                [alertD setMessage:DOWNLOAD_DOC_FAILEDS];
                [alertD show];
                [self downLoadButtonEnbled];
            } else if ([status isEqualToString:@"MAXVALUE"]) {
                UIAlertView *maxAlertView = [[UIAlertView alloc] initWithTitle:DOWLOAD_UPPERNUM message:DOWNLOAD_DOC_MAXVALUE delegate:self cancelButtonTitle:SET_KNOW otherButtonTitles:SET_INVITE, nil];
                maxAlertView.tag = MAXNUMBERTAG;
                [maxAlertView show];
                [self downLoadButtonEnbled];
            }else if ([status isEqualToString:@"INACTIVE"]) {
                UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的帐号尚未激活，暂无法获取文献全文，请先激活手机或邮箱。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"前去激活",nil];
                alertE.tag = 5;
                [alertE show];
                [self downLoadButtonEnbled];
            }else if ([status isEqualToString:@"UNVERIFIED"])
            {
                NSString *name = [UserManager userName];
                NSString *isOk = [[NSUserDefaults standardUserDefaults] objectForKey:name];
                if ([isOk isEqualToString:@"0"]) {
                    UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的身份尚未通过实名验证，请先收藏文献。验证后即可免费获取全文。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"完善帐号信息",nil];
                    alertE.tag = 7;
                    [alertE show];
                    [self downLoadButtonEnbled];
                }else if([isOk isEqualToString:@"1"])
                {
                    UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的身份验证已经提交,我们将在两个工作日内完成验证。身份验证通过后即可免费获取全文。您可先收藏此文献。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"重新修改", nil];
                    alertE.tag = 6;
                    [alertE show];
                    [self downLoadButtonEnbled];
                }
                
            }
            else {
                UIAlertView *alertD = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的帐号尚未激活，暂无法获取文献全文，请先激活手机或邮箱。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"睿医帮助",nil];
                alertD.tag = 8;
                [alertD setTitle:DOWNLOAD_DOC];
                [alertD setMessage:DOWNLOAD_DOC_FAILEDS];
                [alertD show];
                [self downLoadButtonEnbled];
            }
            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:self.pdfReader.tmpFilePath error:&error]) {
                //TODO: Handle/Log error
                NSLog(@"del failed %@",error);
            }
            [self downLoadButtonEnbled];
            return;
            //self.PDFErrorLabel.hidden = NO;
        } else {
            [self downLoadButtonEnbled];
            [self judgeIosVersionTurn];
            self.pdfReader.view.hidden = NO;
            [self.pdfReader setRightBarButtons:NO];
        }
    }
}
//downloadBtn enable
-(void)downLoadButtonEnbled
{
    self.downloadBtn.enabled = YES;
}

-(void)downLoadButtonNotEnble
{
    self.downloadBtn.enabled = NO;
}
@end
