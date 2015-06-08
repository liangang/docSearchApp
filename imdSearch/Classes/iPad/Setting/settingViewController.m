//
//  settingViewController.m
//  imdSearch
//
//  Created by 8fox on 10/21/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "settingViewController.h"
#import "settingDetailViewController.h"
#import "ImdRate.h"
#import "Url_iPad.h"
#import "PadText.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "ImdAppBehavior.h"
#import "Util.h"

#import "UserInfoPadViewController.h"
#import "InviteRegisterPadViewController.h"
#import "LoginController.h"
#import "Strings.h"

#define LINE_NUMBER 7
#define LEFT_SIDE 20
#define BUTTON_WIDTH 500
#define BUTTON_HEIGHT 46
#define BUTTON_2_LINE_HEIGHT 90
#define PADDING 10

#define IMD_NEWS_ID 519002672
#define OPEN_Notification @"notification"

@interface settingViewController(){
}

@property (retain, nonatomic) NSMutableArray *dataArr;
@property (assign, nonatomic) BOOL isLogin;
@end


@implementation settingViewController
@synthesize closeButton,delegate;
@synthesize settingList, locationVersion, lastVersion;
@synthesize settingTableList, trackViewUrl,httprequest;
@synthesize openNotification;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"init Setting View Controller");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        locationVersion = [infoDict objectForKey:@"CFBundleVersion"];
        lastVersion = @"";
        openNotification = ![[[NSUserDefaults standardUserDefaults] objectForKey:OPEN_Notification] boolValue];
        [self getVersionAtAppStore];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc
{
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    netSwitch = [[UISwitch alloc] init];
    switchView = [[UISwitch alloc] init];
    // Do any additional setup after loading the view from its nib.
    
    self.dataArr = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    [self initDataSourceWithLoginInfo:self.isLogin];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.settingList =nil;
    self.delegate =nil;
    self.closeButton =nil;
    self.lastVersion = nil;
    self.trackViewUrl = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - button functions

-(IBAction)closeIt:(id)sender
{
    if (self.httprequest != nil) {
        [self.httprequest clearDelegatesAndCancel];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(backToMainView)])
    {
		[self.mainDelegate backToMainView];
    }
}

-(void)login:(id)sender
{
    [ImdAppBehavior doSettingLog:[Util getUsername] MACAddr:[Util getMacAddress] setLabel:SET_L_ACCOUNT_MANAGE setValue:@"Login"];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(settingViewShowInMainWithType:)]) {
        [self.mainDelegate settingViewShowInMainWithType:SettingItemLogin];
    }
    
}

-(void)logout:(id)sender
{
    [ImdAppBehavior doSettingLog:[Util getUsername] MACAddr:[Util getMacAddress] setLabel:SET_L_ACCOUNT_MANAGE setValue:@"Logout"];
    [self logoutWarning];
}

-(void)downOptionChanged:(id)sender
{
    UISwitch* theSwitch =(UISwitch*)sender;
    
    NSLog(@"switch %d",theSwitch.on);
    [ImdAppBehavior doSettingLog:[Util getUsername] MACAddr:[Util getMacAddress] setLabel:SET_L_DOWNLOAD setValue:[NSString stringWithFormat:@"switch %d", theSwitch.on]];
    
    [[NSUserDefaults standardUserDefaults] setObject:
     [NSNumber numberWithBool:theSwitch.on] forKey:@"downWifiOnly"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"%d", [self.dataArr count]);
    return [self.dataArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%d", [[self.dataArr objectAtIndex:section] count]);
    return [[self.dataArr objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = nil;
    NSNumber *item = [[self.dataArr objectAtIndex:section] objectAtIndex:0];
    if ([item intValue] == SettingItemUserCenter || [item intValue] == SettingItemLogin) {
        title = @"个人中心";
    }else if ([item intValue] == SettingItemFeedback){
        title = @"系统设置";
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

    NSNumber *item = [[self.dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    switch ([item intValue]) {
        case SettingItemLogin:
        {
            cell.textLabel.text = NSLocalizedString(@"setting_loginAccount", nil);
        }
            break;
            
        case SettingItemUserCenter:
        {
            cell.imageView.image = [UIImage imageNamed:@"setting_user"];
            cell.textLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey: @"savedUser"];
            cell.textLabel.textColor = APPDefaultColor;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case SettingItemsInviteRegister:
        {
            cell.imageView.image = [UIImage imageNamed:@"setting_invitation"];
            cell.textLabel.text = NSLocalizedString(@"setting_inviteUser", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case SettingItemExitAccount:
        {
            cell.textLabel.text = NSLocalizedString(@"setting_logon", nil);
            cell.textLabel.textColor = APPDefaultColor;
        }
            break;
        case SettingItemWIFIOn:
        {
            cell.textLabel.text = NSLocalizedString(@"setting_wifi", nil);
            
            BOOL  downWifiOnly =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"downWifiOnly"] boolValue];
            UISwitch *wifiSwitchView = [[UISwitch alloc] init];
            wifiSwitchView.onTintColor = APPDefaultColor;
            [wifiSwitchView setOn:downWifiOnly animated:NO];
            [wifiSwitchView addTarget:self action:@selector(downOptionChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = wifiSwitchView;
            cell.selectionStyle = UITableViewCellAccessoryNone;
            
        }
            break;
            
        case SettingItemDocNotification:
        {
            cell.textLabel.text = NSLocalizedString(@"setting_docNotification", nil);
            
            UISwitch *notiSwitchView = [[UISwitch alloc] init];
            notiSwitchView.onTintColor = APPDefaultColor;
            [notiSwitchView setOn:self.openNotification animated:NO];
            [notiSwitchView addTarget:self action:@selector(NotificationswitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = notiSwitchView;
            cell.selectionStyle = UITableViewCellAccessoryNone;
        }
            break;
            
        case SettingItemClearBuffer:
        {
            cell.textLabel.text = NSLocalizedString(@"setting_clearCaBuffer", nil);
            cell.textLabel.textColor = APPDefaultColor;
        }
            break;
        case SettingItemFeedback:
        {
            cell.textLabel.text = NSLocalizedString(@"setting_feedback", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case SettingItemComment:
        {
            cell.textLabel.text = NSLocalizedString(@"setting_commit", nil);
        }
            break;
        case SettingItemAboutUs:
        {
            cell.textLabel.text = NSLocalizedString(@"setting_aboutUs", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case SettingItemDisclaimer:
        {
            cell.textLabel.text =  NSLocalizedString(@"setting_disclaimer", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case SettingItemAPP:
        {
            UIImageView* bg =[[UIImageView alloc] initWithImage: [UIImage imageNamed:@"img-cross-sale-info-app"]];
            bg.frame = CGRectMake(30, 10, BUTTON_WIDTH - 20, 67);
            [cell addSubview:bg];
            CGRect rect = cell.frame;
            rect.size.height = 80;
            cell.frame = rect;
        }
            break;
            
        case SettingItemVersion:
        {
            NSString *versionInfo = nil;
            if ([lastVersion isEqualToString:@""]) {
                versionInfo = [NSString stringWithFormat:SETTING_IS_LAST_VERSION, locationVersion];
            } else {
                NSLog(@"Have new version:");
                versionInfo = [NSString stringWithFormat: SETTING_HAVE_NEW_VERSION, lastVersion];
            }
            
            cell.textLabel.text = versionInfo;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    if (!(IOS7)) {
        CGSize cellSize = cell.bounds.size;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor = [UIColor whiteColor];
        cell.backgroundView = bgView;
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(10, cellSize.height - 1, 475, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:line];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *item = [[self.dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([item intValue] == SettingItemAPP) {
        return 80;
    }else{
        return 44;
    }
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSNumber *item = [[self.dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    switch ([item intValue]) {
        case SettingItemLogin :
        {
            if (self.isLogin) {
                
            }else{
                [self login:nil];
            }
        }
            break;
        case SettingItemExitAccount:
            {
                [self logoutAccount];
            }
            break;
        case SettingItemUserCenter:
        {
            [self userInfoClick:nil];
        }
            break;
        case SettingItemsInviteRegister:
        {
            if (self.isLogin) {
                InviteRegisterPadViewController *viewController = [[InviteRegisterPadViewController alloc] init];
                [self.navigationController pushViewController:viewController animated:YES];
            }else{
                [self login:nil];
            }
        }
            break;
        case SettingItemWIFIOn:
        {
        }
            break;
        case SettingItemDocNotification:
        {
            
        }
            break;
        case SettingItemClearBuffer:
        {
            [self cleanCatch];
        }
            break;
        case SettingItemFeedback:
        {
            [self toFeedbackDetail:nil];
        }
            break;
        case SettingItemComment:
        {
            [self doRating];
        }
            break;
        case SettingItemAboutUs:
        {
            [self toAboutDetail:nil];
        }
            break;
        case SettingItemDisclaimer:
        {
            [self toResponsibleDetail:nil];
        }
            break;
        case SettingItemAPP:
        {
            [self shareAppNews];
        }
            break;
            
        case SettingItemVersion:
        {
            if (![lastVersion isEqualToString:@""]) {
                [self updateVersion];
            }
            
        }
            break;
            
        default:
            break;
    }
    
}

-(void)logoutWarning
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message: @"退出登录帐号后，相关数据将被清空。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出登录", nil];
    alert.tag =0;
    [alert show];
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:
(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"log out canceled");
    }else{
        NSLog(@"logout self");
        [self logoutAccount];
    }
}

- (void)logoutAccount{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.openNotification = NO;
    [switchView setOn:self.openNotification animated:NO];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    if (self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(settingViewShowInMainWithType:)]) {
        [self.mainDelegate settingViewShowInMainWithType:SettingItemExitAccount];
    }
}

-(void)cleanCatch
{
    [ImdAppBehavior doSettingLog:[Util getUsername] MACAddr:[Util getMacAddress] setLabel:SET_L_CLEAR_CACHE setValue:@"clean cache"];
    NSLog(@"cleanCatch");
    if (self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(settingViewShowInMainWithType:)]) {
        [self.mainDelegate settingViewShowInMainWithType:SettingItemClearBuffer];
    }
    
//    if (delegate && [delegate respondsToSelector:@selector(deleteCacheSetting)])
//    {
//		[delegate performSelector:@selector(deleteCacheSetting) withObject:nil];
//    }
}

- (IBAction)userInfoClick:(id)sender{
    UserInfoPadViewController *viewController = [[UserInfoPadViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];}

#pragma mark - detail pushing
-(void)toFeedbackDetail:(id)sender
{
    [ImdAppBehavior doSettingLog:[Util getUsername] MACAddr:[Util getMacAddress] setLabel:SET_L_ABOUT setValue:@"toFeedbackDeatail"];
    [self toDetail:DETAIL_TYPE_FEEDBACK];
}

-(void)toAboutDetail:(id)sender
{
    [ImdAppBehavior doSettingLog:[Util getUsername] MACAddr:[Util getMacAddress] setLabel:SET_L_ABOUT setValue:@"toAboutDetail"];
    [self toDetail:DETAIL_TYPE_ABOUT_US];
}

-(void)toResponsibleDetail:(id)sender
{
    [ImdAppBehavior doSettingLog:[Util getUsername] MACAddr:[Util getMacAddress] setLabel:SET_L_RESPONSIBLE setValue:@"toResponsibleDetail"];
    [self toDetail:DETAIL_TYPE_POLOCY];
}

-(void)toDetail:(int)tag
{
    NSLog(@"clicked");
    
    settingDetailViewController* dVC = [[settingDetailViewController alloc] initWithNibName: @"settingDetailViewController" bundle:nil];
    dVC.detailType = tag;
    
    [self.navigationController pushViewController:dVC animated:YES];
}

#pragma mark - do rating
- (void) doRating
{
    [ImdAppBehavior doSettingLog:[Util getUsername] MACAddr:[Util getMacAddress] setLabel:SET_L_RATING setValue:@"doRating"];
    NSLog(@"doRating...");
    //[ImdRate goToAppStore];
    NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:
                          @"savedUser"];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REVIEW_APPSTORE]];
    if (username == nil) {
        username = @"";
    }
}

#pragma mark - share Application
-(void)shareAppNews
{
    [ImdAppBehavior doSettingLog:[Util getUsername] MACAddr:[Util getMacAddress] setLabel:SET_L_NEWS setValue:@"shareAppNews"];
    NSString *str = APP_STORE_VERSION_URL;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark - get app store version
- (void) getVersionAtAppStore
{
    NSString* appURL = [NSString stringWithFormat:
                        APP_STORE_VERSION_URL, APP_STORE_ID];
    NSLog(@"appURL %@",appURL);
    
    self.httprequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:appURL]];
    self.httprequest.delegate = self;
    [self.httprequest startAsynchronous];
}

-(void)requestFinished:(ASIHTTPRequest*)request
{
    NSLog(@"version at APP Store %@",[request responseString]);
    NSDictionary *jsonData = [[request responseString] JSONValue];
    NSDecimalNumber* count = [jsonData objectForKey:@"resultCount"];
    if ([count intValue] > 0) {
        NSLog(@"resultCount > 0");
        NSArray *infoArray = [jsonData objectForKey:@"results"];
        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
        NSString* appStoreVersion = [releaseInfo objectForKey:@"version"];
        trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
        NSLog(@"version:%@", appStoreVersion);
        NSLog(@"trackViewUrl:%@", trackViewUrl);
        if (![appStoreVersion isEqualToString:@""] &&
            ![appStoreVersion isEqualToString:locationVersion]){
            NSArray* aasv = [appStoreVersion componentsSeparatedByString:@"."];
            NSArray* alv = [locationVersion componentsSeparatedByString:@"."];
            if (aasv != nil && aasv.count == 3 &&alv != nil && alv.count == 3) {
                NSLog(@"aasv: %@", aasv);
                NSLog(@"alv: %@", alv);
                
                if ([[aasv objectAtIndex:0] intValue] >
                    [[alv objectAtIndex:0] intValue] ||
                    [[aasv objectAtIndex:1] intValue] >
                    [[alv objectAtIndex:1] intValue] ||
                    [[aasv objectAtIndex:2] intValue] >
                    [[alv objectAtIndex:2] intValue]) {
                    lastVersion = [releaseInfo objectForKey:@"version"];
                }
            }
        }
        [settingTableList reloadData];
    }
    NSLog(@"endddd");
}

-(void)requestFailed:(ASIHTTPRequest*)request
{
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    NSLog(@"version at APP Store failde");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}

- (void) updateVersion
{
    [ImdAppBehavior doSettingLog:[Util getUsername] MACAddr:[Util getMacAddress] setLabel:SET_L_VERSION setValue:@"updateVersion"];
    NSLog(@"updateVersion");
    UIApplication* application = [UIApplication sharedApplication];
    [application openURL:[NSURL URLWithString:trackViewUrl]];
}

-(void) NotificationswitchChanged:(id)sender{
    UISwitch* switchControl = sender;
    self.openNotification = switchControl.on;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!self.openNotification] forKey:OPEN_Notification];
    [[NSUserDefaults standardUserDefaults] synchronize];
    BOOL temp = false;
    temp= [[[NSUserDefaults standardUserDefaults] objectForKey:OPEN_Notification] boolValue];
    if (temp) {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }else {
        BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey: @"logined"] boolValue];
        if (useLogined) {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
        }
        
    }
    
}

- (void)initDataSourceWithLoginInfo:(BOOL)isLogin{
    [self.dataArr removeAllObjects];
    
    if (isLogin) {
        [self.dataArr addObject:@[[NSNumber numberWithInt:SettingItemUserCenter],[NSNumber numberWithInt:SettingItemsInviteRegister]]];
        [self.dataArr addObject:@[[NSNumber numberWithInt:SettingItemExitAccount]]];
    }else{
        [self.dataArr addObject:@[[NSNumber numberWithInt:SettingItemLogin],[NSNumber numberWithInt:SettingItemsInviteRegister]]];
    }
    
    [self.dataArr addObject:@[[NSNumber numberWithInt:SettingItemWIFIOn],[NSNumber numberWithInt:SettingItemDocNotification]]];
    
    [self.dataArr addObject:@[[NSNumber numberWithInt:SettingItemClearBuffer]]];
    [self.dataArr addObject:@[[NSNumber numberWithInt:SettingItemFeedback], [NSNumber numberWithInt:SettingItemComment]]];
    [self.dataArr addObject:@[[NSNumber numberWithInt:SettingItemAboutUs],[NSNumber numberWithInt:SettingItemDisclaimer]]];
    
    [self.dataArr addObject:@[[NSNumber numberWithInt:SettingItemAPP]]];
    
    [self.dataArr addObject:@[[NSNumber numberWithInt:SettingItemVersion]]];
    
    [self.settingTableList reloadData];
}
@end
