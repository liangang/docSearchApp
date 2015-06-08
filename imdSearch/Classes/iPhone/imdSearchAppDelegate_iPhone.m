//
//  imdSearchAppDelegate_iPhone.m
//  imdSearch
//
//  Created by wuhuajie on 9/9/11.
//  Copyright 2011 i-md.com. All rights reserved.
//

#import "imdSearchAppDelegate_iPhone.h"
#import "IPhoneMainSearch.h"
#import "IPhoneSettingsController.h"
#import "IPhoneSearchMgr.h"
#import "IPhoneMySearchController.h"
#import "Strings.h"
#import "ImageViews.h"
#import "UserManager.h"
#import "TableViewFormatUtil.h"
#import "CompatibilityUtil.h"
#import "IPhoneHeader.h"
#import "FulltextNotification.h"
#import "ImdAppBehavior.h"
#import "MyDatabase.h"
#import "DatabaseManager.h"
#import "Util.h"
#import <AudioToolbox/AudioServices.h>
#import <QuartzCore/QuartzCore.h>
#import "JSON.h"
#import "Url_iPad.h"
#import "PadText.h"
#import "ISBaseInfoManager.h"


#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"

@implementation UINavigationBar (CustomImage)

- (void)drawRect:(CGRect)rect {
    if ([CompatibilityUtil isIOS5Above]) {
        NSLog(@"Use IOS5 origin version UINavigationBar");
        [super drawRect:rect];
    } else {
        NSLog(@"Use IOS4 workaround for UINavigationBar");
        UIImage *image = [UIImage imageNamed: IMG_BG_NAVGATIONBAR];
        [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
}
@end

@implementation imdSearchAppDelegate_iPhone

@synthesize myTabBarController, mainSearch, loginController, loginNav, settings;
@synthesize mySearch, searchMgr;
@synthesize alertView,alertView1;
@synthesize rootView, isCreated;
@synthesize myAuth;
@synthesize accountActiveNav;
@synthesize accountActive ;
@synthesize helper;
@synthesize imageView;
@synthesize httpRequest;
@synthesize responseString;
@synthesize appStoreVersion;
@synthesize SearchimageView;
@synthesize FullTextimageView;
@synthesize backPdf;
@synthesize delegate;
@synthesize backNavigationBar;
@synthesize myViewController;
@synthesize urlApp;
- (void)dealloc
{
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    NSLog(@"phone launch");
#endif
    SearchimageView.hidden = YES;
    FullTextimageView.hidden = YES;
    backNavigationBar.hidden = YES;
    [ImdAppBehavior flurryAppDefaultTracking];
    [self Mustupdate];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    [super application: application didFinishLaunchingWithOptions:launchOptions];
    
    /**
     注册SDK应用，此应用请到http://www.sharesdk.cn中进行注册申请。
     此方法必须在启动时调用，否则会限制SDK的使用。
     **/
    [ShareSDK registerApp:@"103a34c6e7bf"];
    [self initializePlat];
    
    alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
    alertView1 = [[UIAlertView alloc] initWithTitle:UP_TITLE message:UP_MESSAGE delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"下次再说",nil];
    
    //[self.window addSubview:self.rootView];
    [self.window makeKeyAndVisible];
    backPdf.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BACK_CN style:UIBarButtonItemStylePlain target:self action:@selector(backToPdf)];
    
    if ([CompatibilityUtil isIOS5Above]) {
        [backNavigationBar setBackgroundImage:[UIImage imageNamed:IMG_BG_NAVGATIONBAR] forBarMetrics:UIBarMetricsDefault];
    }
    
    myTabBarController = [[UITabBarController alloc] init];
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
    {
        self.window.rootViewController = myTabBarController; //iOS 6
    } else {
        [self.window.rootViewController addChildViewController:myTabBarController];//iOS 5 or less
    }
    
    myTabBarController.tabBar.hidden = YES;
    myTabBarController.tabBar.layer.shadowOffset = CGSizeMake(0, 0);
    myTabBarController.tabBar.layer.shadowColor = [UIColor clearColor].CGColor;
    myTabBarController.tabBar.layer.shadowOpacity = 0.4;
    myTabBarController.tabBar.layer.shadowRadius = 2;
    isCreated = NO;
    
    NSLog(@"rootCtr: %@", self.window.rootViewController);
    firstLogined = [ISBaseInfoManager getFirstOpenInCurrentVersion];
    
    [self loadSecurity];
    //[mainSearch release];
    NSLog(@"App start finished.");
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    application.applicationIconBadgeNumber = 0;
    
    self.imageView.highlighted = YES;
    
    [MyDatabase creatDatabase];
    [DatabaseManager createDataBase];
    
    NSString *name = [UserManager userName];
    if (name.length > 0) {
        NSString *fNamne = [[NSUserDefaults standardUserDefaults] objectForKey:name];
        if (fNamne.length == 0) {
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:name];
        }
    }
    if (iPhone5) {
        rootView.frame = CGRectMake(0, 0, 320 , 568);
        self.imageView.highlightedImage = [UIImage imageNamed:@"default_r7"];
    }
    
    [self adjustWithIOS6And7];
    
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
  [[NSUserDefaults standardUserDefaults] setObject:[Strings dissolutionDevToken:deviceToken] forKey:@"deviceNumber"];
  
//  NSMutableArray *mut = [[NSUserDefaults standardUserDefaults] objectForKey:Alert_Count];
//    if ([mut count]) {
//        for (int i = 0; i<[mut count]; i++) {
//            if ([[[mut objectAtIndex:i] objectForKey:SAVED_USER] isEqualToString:[UserManager userName]]) {
//                [UIApplication sharedApplication].applicationIconBadgeNumber = [[[mut objectAtIndex:i] objectForKey:Array_ID] count];
//            }
//        }
//    }
//    if (![UserManager userName]) {
//        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
//    }
    //3GS: 607c2b99f2abdca1fa0ab069e5414faf54c789bdc8a9c98d0bd51264adcce654
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in registration. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //Is called when application is running in the foreground.
    NSLog(@"userInfo====%@",userInfo);
  self.urlApp = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"url"];
  NSString *message = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
    //发新产品链接
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  if (self.urlApp.length > 0) {
  UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"睿医提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往下载", nil];
    alerts.tag = 1000;
    [alerts show];
  }else
  {
    UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"索取成功" message:[NSString stringWithFormat:@"%@",message] delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"前往查看",nil];
    alerts.tag = 1001;
    [alerts show];
  }

//    NSMutableArray *mut = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:Alert_Count] ];
//    for (int i = 0; i<[mut count]; i++) {
//        if ([[[mut objectAtIndex:i] objectForKey:SAVED_USER] isEqualToString:[UserManager userName]]) {
//            NSMutableArray *mut2 = [NSMutableArray arrayWithArray:[[mut objectAtIndex:i] objectForKey:Array_ID]];
//            if ([userInfo objectForKey:Alert_ID]) {
//                [mut2 addObject:[userInfo objectForKey:Alert_ID]];
//            }
//            
//            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[mut objectAtIndex:i]];
//            [dic setObject:mut2 forKey:Array_ID];
//            [mut replaceObjectAtIndex:i withObject:dic];
//            [UIApplication sharedApplication].applicationIconBadgeNumber = [[[mut objectAtIndex:i] objectForKey:Array_ID] count];
//            [[NSUserDefaults standardUserDefaults] setObject:mut forKey:Alert_Count];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            break;
//        }
//    }
//    if (application.applicationState == UIApplicationStateActive) {
//        
//    } else if (application.applicationState == UIApplicationStateInactive) {
//        imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
//        appDelegate.myTabBarController.selectedIndex = 2;
//        UINavigationController* LocalNav = [appDelegate.myTabBarController.viewControllers objectAtIndex:2];
//        [[LocalNav.viewControllers objectAtIndex:0] sync];
//        [[LocalNav.viewControllers objectAtIndex:0] showRequest];
//    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
}

- (void)dismissCover
{
    if (self.isCreated)
        return;
    
    myTabBarController.tabBar.hidden = NO;
    loginController = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
    loginNav = [[UINavigationController alloc] initWithRootViewController:loginController];
    
    myTabBarController.tabBar.backgroundColor = NavigationColor;
    
    pdfView = [[PDFReaderController alloc]init];
    
    mainSearch = [[IPhoneMainSearch alloc] init];
    UINavigationController* resultsNav = [[UINavigationController alloc] initWithRootViewController:mainSearch];
    [TableViewFormatUtil setNavigationBar:resultsNav normal:@"tabbar_search_default" highlight:@"tabbar_search_selected" barBg:@""];
    
//    searchMgr = [[IPhoneSearchMgr alloc] init];
//    UINavigationController* myNav = [[UINavigationController alloc] initWithRootViewController:searchMgr];
    myViewController = [[MyDocumentViewController alloc] init];
    UINavigationController *myNav = [[UINavigationController alloc] initWithRootViewController:myViewController];
    [TableViewFormatUtil setNavigationBar:myNav normal:@"tabbar_mine_default" highlight:@"tabbar_mine_selected" barBg:@""];
    myNav.title = NSLocalizedString(@"tab_myDoc", Nil);
    
    settings = [[IPhoneSettingsController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController* settingsNav = [[UINavigationController alloc] initWithRootViewController:settings];
    [TableViewFormatUtil setNavigationBar:settingsNav normal:@"tabbar_setting_default" highlight:@"tabbar_setting_selected" barBg:@""];
    settingsNav.title = NSLocalizedString(@"tab_setting", Nil);
    
    //Add to tabbars.
    NSArray* controllers = @[resultsNav, myNav, settingsNav];
    myTabBarController.viewControllers = controllers;
    myTabBarController.delegate = self;
    self.window.rootViewController = myTabBarController;
    
    if (!firstLogined)
      [self showHelp];
    
    self.isCreated = YES;
}

-(void) showHelp
{
//    if (self.helper == nil) {
//        self.helper = [[IPhoneHelper alloc] init];
//        [self.window addSubview:self.helper.view];
//    }
    if (self.indexViewController == nil) {
        self.indexViewController = [[GuidIndexViewController alloc] init];
        [self.window addSubview:self.indexViewController.view];
    }
}


- (void)adjustWithIOS6And7{
    //Universal
    [[UINavigationBar appearance] setTitleTextAttributes: @{ UITextAttributeTextColor: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:17], UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]}];
    
    if (IOS7) {
        [[UINavigationBar appearance] setTintColor:APPDefaultColor];        //设置navigation bar item 颜色
        [[UINavigationBar appearance] setBarTintColor:NavigationColor];     //设置navigation bar  背景颜色
    }else{
        [[UINavigationBar appearance] setTintColor:NavigationColor];        //设置navigation bar  背景颜色
        
        //设置UITabbar的样式
        [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBg"]];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage new]];   //去除选中时的高亮效果
        [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:APPDefaultColor} forState:UIControlStateHighlighted];
        
        //设置iOS6返回键的样式
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"backArrow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(8, 0) forBarMetrics:UIBarMetricsDefault];
        
//        设置UIBarButtonItem的样式
        [[UIBarButtonItem appearance] setTitleTextAttributes: @{UITextAttributeTextColor: APPDefaultColor, UITextAttributeFont: [UIFont systemFontOfSize:15], UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]} forState:UIControlStateNormal];
        [[UIBarButtonItem appearance] setTitleTextAttributes: @{UITextAttributeTextColor: APPDefaultColor, UITextAttributeFont: [UIFont systemFontOfSize:15], UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]} forState:UIControlStateHighlighted];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        
        
        //    iOS 6 text 适配
        
        
        [[UISegmentedControl appearance] setBackgroundImage:[CompatibilityUtil imageWithColor:APPDefaultColor size:CGSizeMake(1, 29)]
                                                   forState:UIControlStateSelected
                                                 barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearance] setBackgroundImage:[CompatibilityUtil imageWithColor:NavigationColor size:CGSizeMake(1, 29)]
                                                   forState:UIControlStateNormal
                                                 barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearance] setDividerImage:[CompatibilityUtil imageWithColor:APPDefaultColor size:CGSizeMake(1, 29)]
                                     forLeftSegmentState:UIControlStateNormal
                                       rightSegmentState:UIControlStateSelected
                                              barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                                  UITextAttributeTextColor: APPDefaultColor,
                                                                  UITextAttributeFont: [UIFont systemFontOfSize:14],
                                                                  UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)] }
                                                       forState:UIControlStateNormal];
        
        [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                                  UITextAttributeTextColor: NavigationColor,
                                                                  UITextAttributeFont: [UIFont systemFontOfSize:14],
                                                                  UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)]}
                                                       forState:UIControlStateSelected];
        
//        UIsearchBar style 设置
        [[UISearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBg"]];
        [[UISearchBar appearance] setScopeBarBackgroundImage:[UIImage imageNamed:@"navigationBg"]];
        [[UISearchBar appearance] setScopeBarButtonTitleTextAttributes:@{UITextAttributeTextColor: APPDefaultColor, UITextAttributeFont:[UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
        [[UISearchBar appearance] setScopeBarButtonTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor], UITextAttributeFont:[UIFont systemFontOfSize:14]} forState:UIControlStateHighlighted];
        [[UISearchBar appearance] setScopeBarButtonBackgroundImage:[UIImage imageNamed:@"bgScope_normal"] forState:UIControlStateNormal];
        [[UISearchBar appearance] setScopeBarButtonBackgroundImage:[UIImage imageNamed:@"bgScope_selected"] forState:UIControlStateHighlighted];
        [[UISearchBar appearance] setScopeBarButtonBackgroundImage:[UIImage imageNamed:@"bgScope_selected"] forState:UIControlStateSelected];
        
//        UIToolbar style 设置
    }
}

-(void) versionChecked:(NSString*)latest forceUpdate:(BOOL)forceUpdate
{
    [[NSUserDefaults standardUserDefaults] setObject:latest forKey:APP_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)loadSecurity
{
    self.myAuth = [[UserAuth alloc] init];
    
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    
    if(useLogined) {
        [self.myAuth requireToken];
    } else {
        firstLogined = [ISBaseInfoManager getFirstOpenInCurrentVersion];
        if(!firstLogined)
        {
            [self.myAuth performSelectorInBackground:@selector(firstLogin) withObject:nil];
        } else {
            [self dismissCover];
            NSLog(@"not first, no logined: %@", self.myAuth.imdToken);
        }
    }
}

-(void)postAuth
{
    [self.myAuth postAuthInfo];
}

-(void)connectionServerFailed
{
    //[self.mainController.mainLoginViewController connectServerFailed];
}

-(void)connectionServerFinished
{
    NSLog(@"first login preparation ok");
    [self dismissCover];
    [self.alertView show];
}

-(void)login
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"login ok");
    [self dismissCover];
}

-(void)loginFailed
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"login failed");
}

#pragma mark Login Process
-(void) showLoginView:(UIViewController*)controller title:(NSString*) title
{
    self.loginController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.loginNav popToRootViewControllerAnimated:YES];
    self.loginController.sourceCtr = controller;
    [controller presentViewController:self.loginNav animated:YES completion:nil];
//    [TableViewFormatUtil setShadow:self.loginNav.navigationBar];
}

#pragma mark Account active Process
-(void) showAccoutActiveView:(UIViewController*)controller title:(NSString*) title emailActive:(BOOL)emailActive mobileActive:(BOOL)mobileActive fromRegister:(BOOL)fromRegister
{
    //Lazy alloction.
    if (self.accountActive == nil) {
        self.accountActive = [[LoginActiveController alloc] init];
    }
    if (self.accountActiveNav == nil) {
        self.accountActiveNav = [[UINavigationController alloc] initWithRootViewController:self.accountActive];
        
        [TableViewFormatUtil setNavigationBar:self.accountActiveNav normal:IMG_ICON_SETTINGS_NORMAL highlight:IMG_ICON_SETTINGS_HIGHLIGHT barBg:IMG_BG_NAVGATIONBAR];
    }
    
    NSLog(@"email: %d, mobile: %d", emailActive, mobileActive);
    
    self.accountActive.isEmailActive = emailActive;
    self.accountActive.isMobileActive = mobileActive;
    self.accountActive.fromRegister = fromRegister;
    
    self.accountActive.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [controller presentViewController:self.accountActiveNav animated:YES completion:nil];
    self.accountActive.delegate = controller;
}

#pragma mark new auth process
-(void) firstLoginFinished
{
    [self dismissCover];
}

-(void) firstLoginFailed
{
    [self dismissCover];
    [self.alertView show];
}

-(void) requireTokenFinished
{
    [self dismissCover];
}

-(void) requireTokenFailed
{
    [self dismissCover];
    [self.alertView show];
}

-(void) requestTokenFailed
{
    [self dismissCover];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showLoginView:self.mainSearch title:@"重新登录"];
}

-(void) userLoginFinished:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"login ok");
    
    [self.loginController userLoginFinished:animated];
}

-(void) userLoginFailed
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"login failed");
    [self.loginController userLoginFailed:self.settings];
}

-(void) registerloginFailed
{
    [self.alertView setMessage:@"注册成功，服务器忙请重新登录"];
    [self.alertView show];
}

#pragma mark tabBarController

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
    if ((viewController == [tabBarController.viewControllers objectAtIndex:1]) && ![UserManager isLogin]) {
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView:self.mainSearch title:SEARCHMGR_CN];
        
        self.searchMgr.view.hidden = NO;
        return NO;
    }
    
    if ((viewController == [tabBarController.viewControllers objectAtIndex:1]) && !self.myAuth.imdToken.length > 0) {
        if([UserManager isLogin])
        {
            [self.settings exitLoginUser];
        }
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView:self.mainSearch title:SEARCHMGR_CN];
        
        self.searchMgr.view.hidden = NO;
        return NO;
    }
    
    if (viewController == [tabBarController.viewControllers objectAtIndex:1]) {
        [ImdAppBehavior doAskforLog:[Util getUsername] MACAddr:[Util getMacAddress] title:@"点击" pageName:PAGE_LocaSave];
    }
    
    if (viewController == [tabBarController.viewControllers objectAtIndex:2]) {
        [ImdAppBehavior doAskforLog:[Util getUsername] MACAddr:[Util getMacAddress] title:@"点击" pageName:PAGE_SET];
    }
    
    return YES;
}

-(void)showAlert
{
    [self.alertView show];
}

-(void)logout
{
    searchMgr.requestArray = nil;
}

#pragma mark - get app store version
-(void)requestFinished:(ASIHTTPRequest *)request
{
    self.responseString = [request responseString];
    if ([self.responseString isEqualToString:@"true"] | [self.responseString isEqualToString:@"false"]) {
        [self UpdataAlert];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    self.responseString = @"true";
    NSLog(@"request failed %@",[request responseString]);
}

- (void)alertView:(UIAlertView *)alerts clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (alerts.tag == 1000 && buttonIndex == 1) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlApp]];
  }else if (alerts.tag == 1001 && buttonIndex == 1)
  {
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    appDelegate.myTabBarController.selectedIndex = 1;
    UINavigationController* LocalNav = [appDelegate.myTabBarController.viewControllers objectAtIndex:1];
    MyDocumentViewController *myVc = [LocalNav.viewControllers objectAtIndex:0];
    myVc.docSegmentd.selectedSegmentIndex = 0;
    [myVc segValueChanged:myVc.docSegmentd];
//    [[LocalNav.viewControllers objectAtIndex:0] showRequest];
  }
    if (alerts == self.alertView1) {
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_APPSTORE]];
        }
    }
    if ([alerts.message isEqualToString:@"注册成功，服务器忙请重新登录"] && buttonIndex == 0) {
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView:self.settings title:IMD_CN];
    }
}

-(void)Mustupdate
{
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    
    NSString *curVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* url = [NSString stringWithFormat:@"%@?device=%@&v=%@",URL_UPGRADE,@"iphone",curVer];
    ASIHTTPRequest* request =[ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.delegate = self;
    [request startAsynchronous];
}

-(void)UpdataAlert
{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    if (![self.responseString boolValue])
    {
        [alertView1 show];
    }
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    NSArray *arr = self.myTabBarController.viewControllers;
    NSLog(@"////%d",[arr count]);
    if ([arr count] == 0) {
        return UIInterfaceOrientationMaskPortrait;
    }
    for (int i=0; i<[arr count];i++) {
        UINavigationController* vc = [arr objectAtIndex:i];
        NSLog(@"....%d",[vc.viewControllers count]);
        UIViewController *pdf = [vc.viewControllers objectAtIndex:[vc.viewControllers count]-1];
        if ([pdf isKindOfClass:[pdfView class]]) {
            if (!pdf.view.hidden) {
                return UIInterfaceOrientationMaskAll;
            }
            return UIInterfaceOrientationMaskPortrait;
        }
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)backToPdf
{
    if (delegate && [delegate respondsToSelector:@selector(popBack)])
    {
		[delegate performSelector:@selector(popBack) withObject:self];
    }
}

- (void)initializePlat
{
    /***
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectSinaWeiboWithAppKey:@"3235556418"
                               appSecret:@"a0255bbdf4f45831e5528dcf4649bfae"
                             redirectUri:@"http://www.i-md.com"];
    /**
     连接腾讯微博开放平台应用以使用相关功能，此应用需要引用TencentWeiboConnection.framework
     http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
     **/
    [ShareSDK connectTencentWeiboWithAppKey:@"801463158"
                                  appSecret:@"f317814194abcbde52cfd44c81b50985"
                                redirectUri:@"http://www.i-md.com"
                                   wbApiCls:[WeiboApi class]];
    
    //连接短信分享
    [ShareSDK connectSMS];
    
    
    /**
     连接QQ空间应用以使用相关功能，此应用需要引用QZoneConnection.framework
     http://connect.qq.com/intro/login/上申请加入QQ登录，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入TencentOpenAPI.framework,并引入QQApiInterface.h和TencentOAuth.h，将QQApiInterface和TencentOAuth的类型传入接口
     **/
    [ShareSDK connectQZoneWithAppKey:@"100588492"
                           appSecret:@"651069d71bbd4e96be6e60536b4bab13"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
     http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    //旧版中申请的AppId（如：QQxxxxxx类型），可以通过下面方法进行初始化
    //    [ShareSDK connectQQWithAppId:@"QQ075BCD15" qqApiCls:[QQApi class]];
    
    [ShareSDK connectQQWithQZoneAppKey:@"100588492"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wx2f8100a7aa95c501" wechatCls:[WXApi class]];
    
    //连接邮件
    [ShareSDK connectMail];
}
@end
