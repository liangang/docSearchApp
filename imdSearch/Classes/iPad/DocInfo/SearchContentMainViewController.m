//
//  SearchContentMainViewController.m
//  imdSearch
//
//  Created by xiangzhang on 4/15/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "SearchContentMainViewController.h"


#import "SearchDocViewController.h"
#import "GuideIndexiPadViewController.h"
#import "UserInfoPadViewController.h"
#import "MyDocumentPadViewController.h"

#import "imdSearchAppDelegate.h"
#import "DocDetailViewController.h"
#import "fullViewController.h"
#import "newVerifiedViewController.h"
#import "InviteRegisterPadViewController.h"
#import "RegisterSuccessViewController.h"

#import "ImdUrlPath.h"
#import "UrlRequest.h"

#import "myDatabaseOption.h"

#import "Util.h"
#import "ImdRate.h"
#import "ImdAppBehavior.h"

#import "searchHistory.h"
#import "CustomBadge.h"
#import "TKAlertCenter.h"

#pragma mark - origin search View need
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "searchWebViewController.h"
#import "RegisterCategoryViewController.h"

typedef NS_ENUM(NSInteger, MenuType){
    MenuTypeSearch = 0,
    MenuTypeMine,
    MenuTypeSetting,
    MenuTypeHelp
};

#define ShowLoginViewTag 2014052001

@interface SearchContentMainViewController ()<UIAlertViewDelegate,ASIHTTPRequestDelegate>{
     int newBadgeCount;
     MenuType currentType;
    BOOL isLocation;
}

@property (strong, nonatomic) SearchDocViewController *searchViewController;
@property (strong, nonatomic) MyDocumentPadViewController *myDocumentViewController;
@property (nonatomic, strong) settingViewController *settingViewController;
@property (strong, nonatomic) GuideIndexiPadViewController *guidIndexViewController;

@property (strong, nonatomic) DocDetailViewController *docDetailViewController;
@property (strong, nonatomic) fullViewController *fullViewController;
@property (strong, nonatomic) NSDictionary *detailDic;

@end

@implementation SearchContentMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isLocation = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.searchViewController = [[SearchDocViewController alloc] init];
    self.searchViewController.delegate = self;
    [self.slideInfoView addSubview:self.searchViewController.view];
    
    [self setMenuSelectStatus:MenuTypeSearch];
    currentType = MenuTypeSearch;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentLoginViewController:) name:@"presentLoginViewController" object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
-(BOOL)shouldAutorotate
{
  return YES;
}
-(NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (IBAction)searchBtnClick:(id)sender {
    currentType = MenuTypeSearch;
    
    [self setMenuSelectStatus:MenuTypeSearch];
    [self removeSubViewsFromView:self.contentInfoView];
    [self removeSubViewsFromView:self.slideInfoView];
    if (self.searchViewController == nil) {
        self.searchViewController = [[SearchDocViewController alloc] init];
        self.searchViewController.delegate = self;
    }
    
    [self.slideInfoView addSubview:self.searchViewController.view];
    
}

- (IBAction)myDocMenuBtnClick:(id)sender {
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!useLogined) {
        [self remindLogin];
        return;
    } else if(!appDelegate.auth.imdToken.length > 0) {
        [self remindLogin];
        return;
    }
    
    currentType = MenuTypeMine;
    [self setMenuSelectStatus:MenuTypeMine];
    
    [self removeSubViewsFromView:self.slideInfoView];
    [self removeSubViewsFromView:self.contentInfoView];
    
    if (self.myDocumentViewController == nil) {
        self.myDocumentViewController = [[MyDocumentPadViewController alloc] init];
        self.myDocumentViewController.delegate = self;
    }
    
    [self.slideInfoView addSubview:self.myDocumentViewController.view];
}

- (IBAction)settingBtnClick:(id)sender {
    [self setMenuSelectStatus:MenuTypeSetting];
    
    if (self.settingViewController == Nil) {
        self.settingViewController = [[settingViewController alloc] init];
        self.settingViewController.mainDelegate = self;
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.settingViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
    [navigationController setNavigationBarHidden:YES];
    
    navigationController.view.superview.frame = CGRectMake(512-270, 384-310,540, 620);//it's important to do this after
}


- (IBAction)helpInfoBtnClick:(id)sender {
    
    self.guidIndexViewController = [[GuideIndexiPadViewController alloc] init];
    
    [self.view addSubview:self.guidIndexViewController.view];
}

- (void)setMenuSelectStatus:(MenuType)type{
    switch (type) {
        case MenuTypeSearch:
            {
                self.searchBtn.selected = YES;
                self.myDocMenuBtn.selected = NO;
                self.settingBtn.selected = NO;
                self.helpInfoBtn.selected = NO;
            }
            break;
        case MenuTypeMine:
            {
                self.searchBtn.selected = NO;
                self.myDocMenuBtn.selected = YES;
                self.settingBtn.selected = NO;
                self.helpInfoBtn.selected = NO;
            }
            break;
        case MenuTypeSetting:
            {
                self.searchBtn.selected = NO;
                self.myDocMenuBtn.selected = NO;
                self.settingBtn.selected = YES;
                self.helpInfoBtn.selected = NO;
            }
            break;
        case MenuTypeHelp:
            {
                self.searchBtn.selected = NO;
                self.myDocMenuBtn.selected = NO;
                self.settingBtn.selected = NO;
                self.helpInfoBtn.selected = YES;
            }
        default:
            break;
    }
}

-(void)remindLogin {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"帐号登录" message:@"查看我的文献需登录帐号，请登录！" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
    
    alertView.tag =ShowLoginViewTag;
    
    [alertView show];
}

#pragma mark  - main delegate
- (void)backToMainView{
    [self setMenuSelectStatus:currentType];
}

- (void)settingViewShowInMainWithType:(SettingItems)item{
    switch (item) {
       case SettingItemLogin:
        {
            [self setMenuSelectStatus:currentType];
            [self performSelector:@selector(presentLoginViewController:) withObject:nil afterDelay:0.8f];
        }
            break;
        case SettingItemExitAccount:
            {
              [self.myDocumentViewController clearMyDocumentAllInfo];
                [self setMenuSelectStatus:currentType];
                
                [self clearAll];
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"logined"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self removeSubViewsFromView:self.contentInfoView];
              [self searchBtnClick:nil];
            }
            break;
        case SettingItemClearBuffer:
            {
                NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
                [Util DeleteAllInPath:filePath withExtention:@"pdf"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"清空缓存完毕。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alert show];
            }
            break;
            
        default:
            break;
    }
}

- (void)presentViewWithType:(PresentType)type{
    UINavigationController *navigationController = nil;
    
    switch (type) {
        case PresentTypeLoginView:
            {
                self.loginViewController  = [[loginViewController alloc] init];
                navigationController = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
            }
            break;
        case PresentTypeInviteFriendView:
            {
                InviteRegisterPadViewController *viewController = [[InviteRegisterPadViewController alloc] initWithNibName:@"InviteRegisterPadViewController" bundle:nil];
                
                navigationController  = [[UINavigationController alloc] initWithRootViewController:viewController];
               
            }
            break;
        case PresentTypeVerifiedView:
            {
                newVerifiedViewController *userInfoVerified = [[newVerifiedViewController alloc] init];
                [self getUserInfo:[ImdUrlPath getUserInfo] delegate:userInfoVerified];
                
                navigationController = [[UINavigationController alloc] initWithRootViewController:userInfoVerified];
            }
            break;
        case PresentTypeRegisterSuccessView:
            {
                RegisterSuccessViewController* m=[[RegisterSuccessViewController alloc] init];
                
                navigationController = [[UINavigationController alloc] initWithRootViewController:m];
            }
            break;
        case PresentUserTypeView:
      {
        RegisterCategoryViewController *regVC = [[RegisterCategoryViewController alloc] init];
        regVC.type = UserInfoCenter;
        navigationController = [[UINavigationController alloc] initWithRootViewController:regVC];
      }
        break;
        default:
            break;
    }
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
    [navigationController setNavigationBarHidden:YES];
    navigationController.view.superview.frame = CGRectMake(512-270, 384-310,540, 620);  //it's important to do this after
}

- (void)showMyDocumentWithListType:(ListType)type{
    [self myDocMenuBtnClick:nil];
    switch (type) {
        case ListTypeRecord:
            {
                self.myDocumentViewController.docSegment.selectedSegmentIndex = 0;
                [self.myDocumentViewController reloadRecordInfo];
            }
            break;
        case ListTypeCollection:
            {
                self.myDocumentViewController.docSegment.selectedSegmentIndex = 1;
                [self.myDocumentViewController reloadCollectionInfo];
            }
        case ListTypeLocation:
        {
             self.myDocumentViewController.docSegment.selectedSegmentIndex = 2;
            [self.myDocumentViewController reloadLocationInfo];
            
        }
        default:
            break;
    }
}

#pragma mark - getUserInfo Requets
-(ASIHTTPRequest*)getUserInfo:(NSString *)url delegate:(id)dlgt
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    [UrlRequest setPadToken:request];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"checkVer" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 6*10;
    request.delegate = dlgt;
    [request startAsynchronous];
    
    return request;
}

#pragma  mark - fullMainViewController
-(void)saveDocInfo:(id)sender
{
    NSMutableDictionary *details = [self.detailDic copy];
    [myDatabaseOption docuSave:details];
}

-(IBAction)detailsDownFullText:(id)sender{
    [self addToDownloadArraysWith:self.detailDic];
    
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已加入本地文献"];
}

-(void)addToDownloadArraysWith:(NSDictionary*)result {
    NSString* eId =[result objectForKey:@"externalId"];
    
    NSLog(@"eid %@",eId);
    
    NSMutableArray *downloadArr = [myDatabaseOption getSavedDoc];
    
    int sum = [downloadArr count];
    BOOL inList = NO;
    
    for(int i = 0; i < sum; i++) {
        NSDictionary* m =[downloadArr objectAtIndex:i];
        if([eId isEqualToString:[m objectForKey:@"externalId"]]) {
            inList =YES;
            break;
        }
    }
    
    NSLog(@"inList ok");
    
    if(!inList)
    {
        [downloadArr addObject:result];
        
        [myDatabaseOption savedDoc:result];
    }
}

- (void)remvoeFromDownloadArraysWith:(NSString*)eId {
    
    NSMutableArray *downloadArr = [myDatabaseOption getSavedDoc];
    
    int sum = [downloadArr count];
    BOOL inList = NO;
    
    for(int i = 0; i < sum; i++)
    {
        NSDictionary* m =[downloadArr objectAtIndex:i];
        if([eId isEqualToString:[m objectForKey:@"externalId"]])
        {
            inList =YES;
            [downloadArr removeObjectAtIndex:i];
            [myDatabaseOption removeSavedDoc:eId];
            return;
        }
    }
}

#pragma mark - main delegate Show Document Detail info
- (void)showDocDetailInfo:(NSDictionary *)dic{
    [self removeSubViewsFromView:self.contentInfoView];
    
    self.detailDic = [dic copy];
    
    self.docDetailViewController = nil;
    self.docDetailViewController = [[DocDetailViewController alloc] init];
    self.docDetailViewController.delegate = self;
    self.docDetailViewController.docInfoDic = self.detailDic;
    [self.contentInfoView addSubview:self.docDetailViewController.view];
}
- (void)removeDocDetailInfo
{
    [self removeSubViewsFromView:self.contentInfoView];
}
- (void)showDocDetailWithExternalId:(NSString *)eId{
    [self removeSubViewsFromView:self.contentInfoView];
    
    self.docDetailViewController = nil;
    self.docDetailViewController = [[DocDetailViewController alloc] init];
    self.docDetailViewController.delegate = self;
    self.docDetailViewController.externelId = eId;
    [self.contentInfoView addSubview:self.docDetailViewController.view];
}
- (void)copyDocDetailInfo:(NSDictionary *)dic
{
    self.detailDic = [dic copy];
}
- (void)showDocDetailInfoFromDocument:(NSDictionary *)dic listType:(ListType )type isRecod:(NSString *)isrecord{
    [self removeSubViewsFromView:self.contentInfoView];
    
    self.detailDic = [dic copy];
  
    self.docDetailViewController = nil;
    self.docDetailViewController = [[DocDetailViewController alloc] init];
    self.docDetailViewController.delegate = self;
    self.docDetailViewController.docInfoDic = self.detailDic;
    self.docDetailViewController.meunSoruce = MenuTypeMine;
  self.docDetailViewController.isrecord = isrecord;
  self.docDetailViewController.documentType = type;
    [self.contentInfoView addSubview:self.docDetailViewController.view];
}

- (void)showDocDetailWithExternalIdFromDocument:(NSString *)eId listType:(ListType )type isRecod:(NSString *)isrecord{
    [self removeSubViewsFromView:self.contentInfoView];
  
    self.docDetailViewController = nil;
    self.docDetailViewController = [[DocDetailViewController alloc] init];
    self.docDetailViewController.delegate = self;
    self.docDetailViewController.externelId = eId;
    self.docDetailViewController.meunSoruce = MenuTypeMine;
  self.docDetailViewController.isrecord = isrecord;
  self.docDetailViewController.documentType = type;
    [self.contentInfoView addSubview:self.docDetailViewController.view];
}

- (void)showPDFWithexternalId:(NSString *)eId fileName:(NSString *)fileName pdfTitle:(NSString *)fileTitle{
    fullViewController *viewController = [[fullViewController alloc] initWithNibName:@"fullViewController" bundle:nil];
  NSString *documentPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
  NSString *cachPath = [NSString stringWithFormat:@"%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"],fileName];
  if ([viewController loadPdf:documentPath] || [viewController loadPdf:cachPath]) {
    viewController.exterid = eId;
    viewController.currentPdfName = fileName;
    viewController.currentPdfTitle = fileTitle;
    self.fullViewController = viewController;
    
    [self presentViewController:self.fullViewController animated:YES completion:nil];
    viewController.saveButton.hidden = isLocation;
  }else
  {
    [self.docDetailViewController showMsgBarWithInfo:@"对不起，您申请的文献全文未找到."];
  }
}

- (void)removeSubViewsFromView:(UIView *)parentView{
    NSArray *subViews = [parentView subviews];
    
    for (UIView *view in subViews) {
        [view removeFromSuperview];
    }
}

#pragma  mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == ShowLoginViewTag) {
        [self presentLoginViewController:nil];
    }
}

- (IBAction)presentLoginViewController:(id)sender{
    loginViewController *viewController=[[loginViewController alloc] initWithNibName:@"loginViewController" bundle:nil];
    
    UINavigationController *nv =[[UINavigationController alloc] initWithRootViewController:viewController];
    nv.navigationBarHidden =YES;
    
    nv.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nv animated:YES completion:nil];
    
    nv.view.superview.frame = CGRectMake(512-270, 384-310,540, 620);//it's important to do this after
    viewController.delegate =self;
    self.loginViewController = viewController;
}

#pragma mark - LoginViewController delegate
- (void)closeLogin:(id)sender {
    [self setMenuSelectStatus:currentType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loginSuccessProcess:(id)sender {
    [self.searchViewController.searchSuggestTableView reloadData];
}

#pragma mark - ASIHTTPRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *requestInfo = [request userInfo];
    
    if (request.tag == 2014052601) {
        BOOL hasError = NO;
        
        NSString *responseString =[request responseString];
        NSDictionary *info = [responseString JSONValue];
        
        if(info)
        {
            int status =[[info objectForKey:@"status"] intValue];
            
            if( status == 1)
            {
                NSString *uName =[requestInfo objectForKey:@"username"];
                NSString *uPass =[requestInfo objectForKey:@"password"];
                [uName lowercaseString];
                
                imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                
                [[NSUserDefaults standardUserDefaults] setObject:uName forKey:@"savedUser"];    //todo not save pass
                [[NSUserDefaults standardUserDefaults] setObject:uPass forKey:@"savedPass"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [appDelegate.auth postAuthInfo:nil];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                hasError = YES;
            }
        }
        
        if(hasError)
        {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"睿医提醒你:网络出错-­‐请检查网络设置"];
        }
    }
}

#pragma mark - origin searchViewController deal
/**
 *  注册完成后的处理
 *
 *  @param sender
 */
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
    request.tag = 2014052601;
    [request startAsynchronous];
}


-(void)presentForgetPassWindow:(id)sender
{
    searchWebViewController *viewController = [[searchWebViewController alloc] init];
    [self.view addSubview:viewController.view];
    [viewController loadURL:@"http://www.i-md.com/user/forgotPassword"];
}

-(void)presentRegisterWindow:(id)sender
{
    searchWebViewController *viewController = [[searchWebViewController alloc] init];
    [self.view addSubview:viewController.view];
    [viewController loadURL:@"http://www.i-md.com/register"];
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

- (void)startReady{
    self.mainCoverView.hidden = YES;
    [self.view sendSubviewToBack:self.mainCoverView];
}

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

-(void)clearAll
{
    [searchHistory clearHistory];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"downloadArrays"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"requestArrays"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
