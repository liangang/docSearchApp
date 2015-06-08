//
//  imdSearchAppDelegate_iPad.m
//  imdSearch
//
//  Created by 8fox on 9/9/11.
//  Copyright 2011 i-md.com. All rights reserved.
//

#import "imdSearchAppDelegate_iPad.h"

//#import "Reachability.h"
#import "NetStatusChecker.h"
#import "searchHistory.h"
#import "Util.h"

// dev.flurry.com
//#import "Flurry.h"
#import "ImdAppBehavior.h"
#import "ImdRate.h"
#import "Strings.h"
#import "UserManager.h"
#import "imdiPadDatabase.h"
#import "JSON.h"
#import "Url_iPad.h"
#import "PadText.h"
#import "ASIFormDataRequest.h"
#import "ISBaseInfoManager.h"
#import "UrlRequest.h"
#import "CompatibilityUtil.h"

#import <ShareSDK/ShareSDK.h>

#import "GuideIndexiPadViewController.h"

#import "SearchContentMainViewController.h"
#import "MyDatabase.h"
#import "DatabaseManager.h"

@implementation imdSearchAppDelegate_iPad

@synthesize httpRequest = _httpRequest;
@synthesize responseString;
@synthesize appStoreVersion;
@synthesize alertView1;
@synthesize urlApp;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"ImdAppBehavior flurryAppDefaultTracking");
    [ImdAppBehavior flurryAppDefaultTracking];
    [self abc];
    //    [Flurry startSession:@"EHUIZUZL6W3MW6C541ES"];
    NSLog(@"init rating");
    [ImdRate searchApp];
    NSLog(@"pad launch");
    self.auth = [[imdAuthor alloc] init];
    alertView1 = [[UIAlertView alloc] initWithTitle:UP_TITLE message:UP_MESSAGE delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"下次再说",nil];
    
    /**
     注册SDK应用，此应用请到http://www.sharesdk.cn中进行注册申请。
     此方法必须在启动时调用，否则会限制SDK的使用。
     **/
    [ShareSDK registerApp:@"103a34c6e7bf"];
    [self initializePlat];
    [ShareSDK setInterfaceOrientationMask:SSInterfaceOrientationMaskLandscape];
    
    //check first time
    BOOL firstLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"firstLogined"] boolValue];
    
    NSString* currentVer= [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [imdiPadDatabase createDatabase];
  [MyDatabase creatDatabase];
  [DatabaseManager createDataBase];
    if(!firstLogined)
    {
        NSLog(@"!firstLogined");
        //set init values
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"downWifiOnly"];
        [[NSUserDefaults standardUserDefaults] setObject:currentVer forKey:@"version"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [searchHistory clearHistory];
    }
    else
    {
        NSString* savedVer =[[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
        
        if(![savedVer isEqualToString:currentVer])
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"renewAuth"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"renewAuth"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:currentVer forKey:@"version"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *name = [Util getUsername];
    if (name.length > 0) {
        NSString *fNamne = [[NSUserDefaults standardUserDefaults] objectForKey:name];
        if (fNamne.length == 0) {
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:name];
        }
    }
    
    self.window.rootViewController = self.mainController; //iOS 6
    
    [self.window makeKeyAndVisible];
    //notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"netInited"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self adjustWithIOS6And7];
    
    if ([NetStatusChecker isNetworkAvailbe])
    {
        [self loadSecurity];
    }
    else
    {
        [self connectionServerFailed];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
}

- (void)dealloc
{
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

-(void)loadSecurity
{
    BOOL renewToken =[[[NSUserDefaults standardUserDefaults] objectForKey:@"renewAuth"] boolValue];
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    
    if(renewToken) {
        NSLog(@"renew token");
        [self.auth firstLogin];
    } else if(useLogined) {
        [self.auth postDeviceInfo];
        
    } else {
        BOOL firstLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"firstLogined"] boolValue];
        if(!firstLogined) {
            [self.auth firstLogin];
        } else {
            [self.mainController startReady];
        }
    }
}

-(void)postAuth
{
    [self.auth postAuthInfo:nil];
}

-(void)showFirstHelp
{
    BOOL firstHelped = [ISBaseInfoManager getFirstHelpInCurrentVersion];
    if (!firstHelped) {
        [self.mainController helpInfoBtnClick:nil];
        [ISBaseInfoManager setFirstHelpInCurrentVersion:TRUE];
    }
}

-(void)connectionServerFailed
{
    //[self.mainController.mainLoginViewController connectServerFailed];
    //retry
    BOOL netInited = [[[NSUserDefaults standardUserDefaults] objectForKey:@"netInited"] boolValue];
    [self.mainController startReady];
    
    [self showFirstHelp];
    [self.mainController performSelector:@selector(checkNewAskfor) withObject:nil afterDelay:0.5f];
    
    if(!netInited)
    {
        NSLog(@"checking net init");
        //retry in a time delay
        //    [self performSelector:@selector(loadSecurity) withObject:nil afterDelay:5.0f];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:nil cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
        [alertView show];
        return;
        
    } else {
        if ([NetStatusChecker isNetworkAvailbe]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:nil cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
            [alertView show];
            return;
            
        }
        [self loginFailed];
    }
}

-(void)connectionServerFinished
{
    NSLog(@"first login preparation ok");
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"netInited"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.mainController startReady];
    [self showFirstHelp];
    [self.mainController performSelector:@selector(checkNewAskfor) withObject:nil afterDelay:0.5f];
}

-(void)login
{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"login ok");
    
    [self.mainController startReady];
    
    [self.mainController.loginViewController loginSuccessfully];
}

-(void)loginFailed
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"login failed");
    
    [self.mainController.loginViewController loginFailWarning];
    
}

-(void) requestTokenFailed;
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.mainController startReady];
    
    [self.mainController presentLoginViewController:nil];
}

-(void)registerloginFailed
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginNewDailog"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"login failed");
    
    [self.mainController.loginViewController registerloginFailWarning];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window  NS_AVAILABLE_IOS(6_0)
{
    return UIInterfaceOrientationMaskAll;
}
-(BOOL)shouldAutorotate
{
  return YES;
}
-(NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

//notification
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[NSUserDefaults standardUserDefaults] setObject:[Strings dissolutionDevToken:deviceToken] forKey:@"deviceNumber"];
  
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

//    if (application.applicationState == UIApplicationStateActive) {
//    } else if (application.applicationState == UIApplicationStateInactive) {
////        imdSearchAppDelegate_iPad *appDelegate = (imdSearchAppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
////        appDelegate.mainController.hasNotification = YES;
////        
////        [appDelegate.mainController sideActionPressed:appDelegate.mainController.sideActionDownloadedButton];
////        [appDelegate.mainController askSuccessButtonTapped:nil];
//        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//        
//    }
}

#pragma mark - get app store version
-(void)requestFinished:(ASIHTTPRequest *)request
{
    self.responseString =[request responseString];
    if ([self.responseString isEqualToString:@"true"] | [self.responseString isEqualToString:@"false"]) {
        [self UpdataAlert];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    self.responseString = @"true";
}

- (void)alertView:(UIAlertView *)alerts clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (alerts.tag == 1000 && buttonIndex == 1) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlApp]];
  }else if (alerts.tag == 1001 && buttonIndex == 1)
  {
    imdSearchAppDelegate_iPad *appDelegate = (imdSearchAppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainController showMyDocumentWithListType:ListTypeRecord];
  }

    if (alerts == self.alertView1) {
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_APPSTORE]];
        }
    }
}

-(void)UpdataAlert
{
    if (![self.responseString boolValue])
    {
        [alertView1 show];
    }
}

-(void)abc{
    
    NSString *curVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* url = [NSString stringWithFormat:@"%@?device=%@&v=%@",URL_UPGRADE,@"ipad",curVer];
    
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    
    ASIFormDataRequest* request =  [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.delegate = self;
    [request startAsynchronous];
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
