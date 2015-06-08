//
//  InviteRegisterPadViewController.m
//  imdSearch
//
//  Created by xiangzhang on 1/3/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "InviteRegisterPadViewController.h"

#import <CoreText/CoreText.h>
#import <ShareSDK/ShareSDK.h>

#import "ASIHTTPRequest.h"
#import "ImdUrlPath.h"
#import "FTCoreTextView.h"
#import "Strings.h"
#import "UrlRequest.h"

#import "JSON.h"
#import "ISBaseInfoManager.h"

#define USERNAMETAG 2014010201
#define USERTYPETAG 2014010202
#define USERSTATUSTAG 2014010203
#define USERREWARDTAG 2014010204

#define COMMONLINEHEIGHT 40
#define COMMOBCONTENTWIDTH 467
#define FONTSIZE 17

@interface InviteRegisterPadViewController ()<ASIHTTPRequestDelegate>

@property (nonatomic, retain) NSMutableArray *dataArray;
@property (nonatomic, retain) ASIHTTPRequest *request;

@property (strong, nonatomic) IBOutlet UIButton *inviteBtn;
@property (nonatomic, assign) int successNumber;
@property (nonatomic, assign) float rewardPoints;
@end

@implementation InviteRegisterPadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self requestInviteesInfo];
    
    self.inviteBtn.layer.masksToBounds = YES;
    self.inviteBtn.layer.cornerRadius = 5;
    self.inviteBtn.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark user has invited user
- (void)requestInviteesInfo{
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath getInviteesInfo]]];
    
    [self.request addRequestHeader:@"Content-Type" value:@"application/json"];
    [self.request addRequestHeader:@"Accept" value:@"application/json"];
    
    [UrlRequest setPadToken:self.request];
    self.request.delegate = self;
    [self.request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    
    NSArray *inviteArr = [request.responseString JSONValue];
    
    [self.dataArray addObjectsFromArray:inviteArr];
    [self initInviteSumInfo];
    
    [self.infoTableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    
}

- (void)initInviteSumInfo{
    self.successNumber = 0;
    self.rewardPoints = 0;
    
    for (NSDictionary *info in self.dataArray) {
        CGFloat point = [[info objectForKey:@"rewardPoint"] doubleValue];
        
        if (point > 0) {
            self.successNumber++;
            self.rewardPoints += point;
        }
    }
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return COMMONLINEHEIGHT + 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *str =[NSString stringWithFormat:@"好友注册<redColor>%d</redColor>人，邀请成功<redColor>%d</redColor>人，获得奖励<redColor>%0.1f</redColor>篇",[self.dataArray count],self.successNumber,self.rewardPoints];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, COMMOBCONTENTWIDTH, COMMONLINEHEIGHT + 8)];
    UIImageView *backImg = [[UIImageView alloc] initWithFrame:headerView.bounds];
    backImg.image = [UIImage imageNamed:@"img-card-top_2"];
    [headerView addSubview:backImg];
    
    FTCoreTextView *textView = [[FTCoreTextView alloc] initWithFrame:CGRectMake(4, 8, COMMOBCONTENTWIDTH-8, COMMONLINEHEIGHT - 8)];
    [textView setText:str];
    [textView addStyles:[self coreTextStyleWithRed]];
    [textView fitToSuggestedHeight];
    textView.center = headerView.center;
    
    [headerView addSubview:textView];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return COMMONLINEHEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIImageView *footerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-card-bottom_2"]];

    return footerView;
}

- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section{
    
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return COMMONLINEHEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"inviterIdentify";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        CGRect rect = cell.frame;
        rect.size = CGSizeMake(COMMOBCONTENTWIDTH, COMMONLINEHEIGHT);
        cell.frame = rect;
        
        CGFloat height = cell.frame.size.height - 20;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, COMMOBCONTENTWIDTH, COMMONLINEHEIGHT)];
        backView.tag = 20130102;
        
        rect.size.height = height;
        UIView *contentView = [[UIView alloc] initWithFrame:rect];
        contentView.backgroundColor = [UIColor clearColor];
        
        UILabel *useName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, height)];
        useName.tag = USERNAMETAG;
        useName.backgroundColor = [UIColor clearColor];
        useName.font = [UIFont systemFontOfSize:FONTSIZE];
        useName.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:useName];
        
        UILabel *userType = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 90, height)];
        userType.tag = USERTYPETAG;
        [userType setTextColor:RGBCOLOR(67, 94, 114)];
        userType.font = [UIFont systemFontOfSize:FONTSIZE];
        userType.backgroundColor = [UIColor clearColor];
        userType.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:userType];
        
        FTCoreTextView *userStatus = [[FTCoreTextView alloc] initWithFrame:CGRectMake(220, 0, 160, height)];
        userStatus.tag = USERSTATUSTAG;
        [contentView addSubview:userStatus];
        
        FTCoreTextView *userReward = [[FTCoreTextView alloc] initWithFrame:CGRectMake(380, 0, 90, height)];
        userReward.tag = USERREWARDTAG;
        [contentView addSubview:userReward];
        
        contentView.center = backView.center;
        [backView addSubview:contentView];
        [cell addSubview:backView];
    }
    
    NSDictionary *dictiony = [self.dataArray objectAtIndex:indexPath.row];
    
    UILabel *userName = (UILabel *)[cell viewWithTag:USERNAMETAG];
    [userName setText:[dictiony objectForKey:@"realname"]];
    
    NSString *userTypeStr = [dictiony objectForKey:@"userType"];
  NSString *typeStr;
  if (userTypeStr.length > 0) {
    typeStr = [userTypeStr isEqualToString:@"Doctor"] ? @"医师" :@"学生";
  }else
    typeStr = @"";
    UILabel *userType = (UILabel *)[cell viewWithTag:USERTYPETAG];
    [userType setText:typeStr];
    
    Boolean baseVerify = [[dictiony objectForKey:@"baseInfoVerified"] boolValue];
    Boolean emailVerify = [[dictiony objectForKey:@"emailVerified"] boolValue];
    Boolean mobileVerified = [[dictiony objectForKey:@"mobileVerified"] boolValue];
    
    NSString *activite = emailVerify || mobileVerified ? @"已激活/" : @"<grayColor>未激活</grayColor>/";
    NSString *verifyStr = baseVerify ? @"已验证" : @"<grayColor>未验证</grayColor>";
    
    FTCoreTextView *userStatus = (FTCoreTextView *)[cell viewWithTag:USERSTATUSTAG];
    [userStatus setText:[NSString stringWithFormat:@"%@%@",activite,verifyStr]];
    [userStatus addStyles:[self coreTextStyleWithStatus]];
    [userStatus fitToSuggestedHeight];
    
    double rewardPoint = [[dictiony objectForKey:@"rewardPoint"] doubleValue];
    NSString *pointStr = (rewardPoint == 0 ?  @"<grayColor>无</grayColor>" : [NSString stringWithFormat:@"<redColor>%0.1f</redColor>篇/天",rewardPoint]);
    
    FTCoreTextView *userReward = (FTCoreTextView *)[cell viewWithTag:USERREWARDTAG];
    [userReward setText:pointStr];
    [userReward addStyles:[self coreTextStyleWithRed]];
    [userReward fitToSuggestedHeight];
    
    UIView *mainView = (UIView *)[cell viewWithTag:20130102];
    if (indexPath.row % 2 == 0) {
        mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img-card-middle_2"]];
    }else{
        mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img-card-middle2_2"]];
    }
    
    return cell;
}

#pragma mark -
- (NSArray *)coreTextStyleWithRed{
    /****************** the init Core Text Style  start ******************/
    NSMutableArray *result = [NSMutableArray array];
    FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
	defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
	defaultStyle.font = [UIFont systemFontOfSize:FONTSIZE];
	defaultStyle.textAlignment = FTCoreTextAlignementCenter;
	[result addObject:defaultStyle];
    
    FTCoreTextStyle *grayStyle = [defaultStyle copy];
	[grayStyle setName:@"grayColor"];
    [grayStyle setColor:[UIColor lightGrayColor]];
	[result addObject:grayStyle];
    
    FTCoreTextStyle *coloredStyle = [defaultStyle copy];
    [coloredStyle setName:@"redColor"];
    [coloredStyle setColor:[UIColor redColor]];
	[result addObject:coloredStyle];
    /******************* the init Core Text Style  start *******************/
    
    return result;
}

- (NSArray *)coreTextStyleWithStatus{
    NSMutableArray *result = [NSMutableArray array];
    
    /****************** the init Core Text Style  start ******************/
    FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
	defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
	defaultStyle.font = [UIFont systemFontOfSize:FONTSIZE];
    defaultStyle.color = RGBCOLOR(67, 94, 114);
	defaultStyle.textAlignment = FTCoreTextAlignementCenter;
	[result addObject:defaultStyle];
    
    FTCoreTextStyle *grayStyle = [defaultStyle copy];
	[grayStyle setName:@"grayColor"];
    [grayStyle setColor:[UIColor lightGrayColor]];
	[result addObject:grayStyle];
    /******************* the init Core Text Style  start *******************/
    
    return result;
}

#pragma mark - UIButton Click event
- (IBAction)dismissView:(id)sender {
    NSArray *viewControllers = [self.navigationController viewControllers];
    if ([viewControllers count] == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (BOOL) isIOS7Above{
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    return YES;
  return NO;
}

- (IBAction)inviteFriendClick:(id)sender {
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"icon@2x" ofType:@"png"];
    
    NSString *url = [ImdUrlPath invitedFriendBy:[ISBaseInfoManager getUserInfoId]];
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@%@",SETTINGS_INVITE_COMMON,url]
                                       defaultContent:SETTINGS_INVITE_COMMON
                                                image:[ShareSDK imageWithPath:imgPath]
                                                title:@"睿医文献"
                                                  url:url
                                          description:SETTINGS_INVITE_COMMON
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [publishContent addSMSUnitWithContent:[NSString stringWithFormat:@"%@%@",SETTINGS_INVITE_SMS,url]];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSShareOptions> shareOptions = [ShareSDK simpleShareOptionsWithTitle:@"内容分享" shareViewDelegate:nil];
    NSArray *shareList;
  if (![self isIOS7Above]) {
    shareList  = [ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeQQSpace, nil];
  }else
    shareList = [ShareSDK getShareListWithType:ShareTypeSMS,ShareTypeMail,ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeQQSpace, nil];
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:shareOptions
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
    
}

// New Autorotation support.
- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0){
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0){
    return UIInterfaceOrientationMaskLandscape;
}

// Returns interface orientation masks.
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation NS_AVAILABLE_IOS(6_0){
    return UIInterfaceOrientationMaskLandscape;
}

- (void)dealloc {
    if (self.request) {
        [self.request clearDelegatesAndCancel];
    }
}

- (void)viewDidUnload {
    [self setInfoTableView:nil];
    [super viewDidUnload];
}
@end
