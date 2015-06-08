//
//  IPhoneSettingsController.m
//  imdSearch
//
//  Created by Huajie Wu on 11-12-2.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "IPhoneSettingsController.h"
#import "Strings.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "UserManager.h"
#import "imdSearchAppDelegate.h"
#import "IPhoneSettingsText.h"
#import "IPhoneSettingsFeedback.h"
#import "LoginMobileActive.h"
#import "TableViewFormatUtil.h"
#import "ImageViews.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "imdSearchAppDelegate_iPhone.h"
#import "UserBaseInfoViewController.h"
#import "InviteRegisterViewController.h"

#define NOT_WIFI_ONLY @"notwifiOnly"
#define OPEN_Notification @"notification"

@interface IPhoneSettingsController (RateAppStore)

-(IBAction)reviewPressed:(id)sender;

- (void) updateVersionCell:(UITableViewCell*) cell text:(NSString*)text latest:(BOOL)isLatest;
- (void) updateCallCell:(UITableViewCell*) cell;
- (void) updateLogoCell:(UITableViewCell*) cell;

@end


@implementation IPhoneSettingsController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initializationhttprequest
        self.title = SETTINGS_CN;
        
        _downloadOnWiFiOnly = ![[[NSUserDefaults standardUserDefaults] objectForKey:NOT_WIFI_ONLY] boolValue];
        _openNotification = ![[[NSUserDefaults standardUserDefaults] objectForKey:OPEN_Notification] boolValue];
        _cacheAlertView = [[UIAlertView alloc] initWithTitle:IMD_CN message:SETTINGS_CLEAR_CACHE_MESSAGE delegate:self cancelButtonTitle:TEXT_CANCEL otherButtonTitles:TEXT_CONFIRM, nil];
        _isLatest = YES;
        self.latestVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        self.dataArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)dealloc
{
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TableViewFormatUtil backBarButtonItemInfoModify:self.navigationItem];
    
    [self getVersionAtAppStore];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) getVersionAtAppStore
{
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:URL_APPLOOKUP]];
    
    request.delegate = self;
    [request startAsynchronous];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isLogin = [UserManager isLogin];
    [self initDataSourceWithLoginInfo:self.isLogin];
}

-(void)requestFinished:(ASIHTTPRequest*)request
{
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    
    NSDecimalNumber* count = [resultsJson objectForKey:@"resultCount"];
    if ([count intValue] > 0) {
        NSArray *infoArray = [resultsJson objectForKey:@"results"];
        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
        NSString* versionOnAppStore = [releaseInfo objectForKey:@"version"];
        
        NSLog(@"local version:%@, app store version:%@", self.latestVersion, versionOnAppStore);
        
        if ([self.latestVersion isEqualToString:versionOnAppStore]) {
            self.isLatest = YES;
        } else {
            self.isLatest = NO;
            self.latestVersion = versionOnAppStore;
        }
        [self.tableView reloadData];
    }
}

-(void)requestFailed:(ASIHTTPRequest*)request
{
    NSLog(@"version at APP Store failde");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    UIImageView *logoImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_wenxian"]];
    logoImg.center = footerView.center;
    [footerView addSubview:logoImg];
    self.tableView.tableFooterView = footerView;
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataArr count];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.dataArr objectAtIndex:section] count];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    NSNumber *item = [[self.dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    switch ([item intValue]) {
        case SettingItemLogin:
            {
                cell.textLabel.text = NSLocalizedString(@"setting_loginAccount", Nil);
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
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
                UISwitch *switchView = [[UISwitch alloc] init];
                switchView.onTintColor = APPDefaultColor;
                [switchView setOn:self.downloadOnWiFiOnly animated:NO];
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = switchView;
                cell.selectionStyle = UITableViewCellAccessoryNone;
            }
            break;
        case SettingItemDocNotification:
            {
                cell.textLabel.text = NSLocalizedString(@"setting_docNotification", nil);
                UISwitch *switchView = [[UISwitch alloc] init];
                switchView.onTintColor = APPDefaultColor;
                [switchView setOn:self.openNotification animated:NO];
                [switchView addTarget:self action:@selector(NotificationswitchChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = switchView;
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
        case SettingItemAboutUs:
            {
                cell.textLabel.text = NSLocalizedString(@"setting_aboutUs", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        case SettingItemComment:
            {
                cell.textLabel.text = NSLocalizedString(@"setting_commit", nil);
            }
            break;
        case SettingItemDisclaimer:
            {
                cell.textLabel.text = NSLocalizedString(@"setting_disclaimer", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        case SettingItemVersion:
            {
                if (self.isLatest) {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", SETTINGS_VERSION, self.latestVersion];
                    cell.textLabel.textColor = InfoColor;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", SETTINGS_VERSION_NEW, self.latestVersion];
                    cell.textLabel.textColor = RGBCOLOR(76, 86, 108);
                }
            }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    self.downloadOnWiFiOnly = switchControl.on;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!self.downloadOnWiFiOnly] forKey:NOT_WIFI_ONLY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) NotificationswitchChanged:(id)sender{
    UISwitch *switchControl = sender;
    self.openNotification = switchControl.on;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!self.openNotification] forKey:OPEN_Notification];
    [[NSUserDefaults standardUserDefaults] synchronize];
    BOOL temp = false;
    temp= [[[NSUserDefaults standardUserDefaults] objectForKey:OPEN_Notification] boolValue];
    
    if (temp) {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNumber *item = [[self.dataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    switch ([item intValue]) {
        case SettingItemLogin:
            {
                [self loginAccount:nil];
            }
            break;
        case SettingItemUserCenter:
            {
                UserBaseInfoViewController *viewController = [[UserBaseInfoViewController alloc] init];
                [self.navigationController pushViewController:viewController animated:YES];
            }
            break;
        case SettingItemsInviteRegister:
            {
                if (self.isLogin) {
                    InviteRegisterViewController *viewController = [[InviteRegisterViewController alloc] init];
                    [self.navigationController pushViewController:viewController animated:YES];
                }else{
                    [self loginAccount:nil];
                }
            }
            break;
        case SettingItemExitAccount:
            {
                [self logoutAccount:nil];
            }
            break;
        case SettingItemClearBuffer:
            {
                [self.cacheAlertView show];
            }
            break;
        case SettingItemFeedback:
        {
            IPhoneSettingsFeedback* feedback = [[IPhoneSettingsFeedback alloc] init];
            [self.navigationController pushViewController:feedback animated:YES];
        }
            break;
        case SettingItemAboutUs:
        {
            IPhoneSettingsText* aboutUs = [[IPhoneSettingsText alloc] init];
            aboutUs.type = SETTINGS_ABOUTUS;
            [self.navigationController pushViewController:aboutUs animated:YES];
        }
            break;
        case SettingItemComment:
        {
            [ImdAppBehavior goToGrade:[Util getUsername]];
            [self reviewPressed:nil];
        }
            break;
        case SettingItemDisclaimer:
        {
            IPhoneSettingsText* agreement = [[IPhoneSettingsText alloc]init];
            agreement.type = SETTINGS_AGREEMENT;
            [self.navigationController pushViewController:agreement animated:YES];
        }
            break;
        case SettingItemVersion:
            {
                if (!self.isLatest) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_APPSTORE]];
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                }
            }
            break;
        default:
            break;
    }
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == exitOut) {
        if (buttonIndex == 0) {
            [self exitLoginUser];
        }
    } else if (buttonIndex == 0) {
        NSString* tel = [NSString stringWithFormat:@"tel:%@", IMD_PNONE];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
    }
}

- (void)exitLoginUser
{
    [self logout:nil];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:SAVED_USER];
    [defaults synchronize];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.isLogin = false;
    [self initDataSourceWithLoginInfo:self.isLogin];
    [self.tableView reloadData];
  
    //清除我的文献里的数据
  imdSearchAppDelegate_iPhone *appdele = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
  [appdele.myViewController.colllectionListViewController.dataArr removeAllObjects];
  [appdele.myViewController.recordListViewController.dataArr removeAllObjects];
  [appdele.myViewController.colllectionListViewController.tableView reloadData];
}

-(IBAction)reviewPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REVIEW_APPSTORE]];
}

#pragma mark
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Do the logout.
    if (alertView == self.cacheAlertView && buttonIndex == 1) {
        [UrlRequest clearCache];
    }
}

- (void) logout:(id)sender
{
    [UserManager logout];
}

- (IBAction)logoutAccount:(id)sender{
    exitOut = [[UIActionSheet alloc]initWithTitle:LOGOUT_WARN delegate:self cancelButtonTitle:SETTINGS_CALL_CANCEL destructiveButtonTitle:LOGOUT_CONFIRM otherButtonTitles: nil];
    [exitOut showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)loginAccount:(id)sender{
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoginView:self title:IMD_CN];
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
    
    [self.dataArr addObject:@[[NSNumber numberWithInt:SettingItemVersion]]];
    
    [self.tableView reloadData];
}
@end