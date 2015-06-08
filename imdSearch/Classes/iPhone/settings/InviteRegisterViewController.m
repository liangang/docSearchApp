//
//  InviteRegisterViewController.m
//  imdSearch
//
//  Created by xiangzhang on 12/30/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import "InviteRegisterViewController.h"
#import "CompatibilityUtil.h"
#import <CoreText/CoreText.h>

#import "TableViewFormatUtil.h"
#import "ImageViews.h"
#import "Strings.h"
#import "ImdUrlPath.h"
#import "UrlRequest.h"
#import "FTCoreTextView.h"

#import "ASIHTTPRequest.h"
#import "JSON.h"

#import <ShareSDK/ShareSDK.h>
#import "ISBaseInfoManager.h"

#define USERNAMETAG 2014010201
#define USERTYPETAG 2014010202
#define USERSTATUSTAG 2014010203
#define USERREWARDTAG 2014010204

#define COMMONLINEHEIGHT 30
#define COMMOBCONTENTWIDTH 300

#define FontSize 14

@interface InviteRegisterViewController ()<ASIHTTPRequestDelegate>

@property (nonatomic, retain) NSMutableArray *dataArray;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, assign) int successNumber;
@property (nonatomic, assign) float rewardPoints;
@property (strong, nonatomic) IBOutlet UIButton *inviteBtn;

@end

@implementation InviteRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Custom initialization
        self.title = @"邀请好友注册";
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
     if (![CompatibilityUtil isIOS7Above]) {
         //ios6以下邮箱分享
       
     }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    if (self.request) {
        [self.request clearDelegatesAndCancel];
    }
}

#pragma mark user has invited user
- (void)requestInviteesInfo{
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath getInviteesInfo]]];
    
    [self.request addRequestHeader:@"Content-Type" value:@"application/json"];
    [self.request addRequestHeader:@"Accept" value:@"application/json"];
    
    [UrlRequest setToken:self.request];
    self.request.delegate = self;
    [self.request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    
    NSLog(@"%@",request.responseString);
    NSArray *inviteArr = [request.responseString JSONValue];
    
    [self.dataArray addObjectsFromArray:inviteArr];
    
    [self initInviteSumInfo];
    [self.tableView reloadData];
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
    NSString *str = [NSString stringWithFormat:@"好友注册<redColor>%d</redColor>人，邀请成功<redColor>%d</redColor>人，获得奖励<redColor>%0.1f</redColor>篇",[self.dataArray count],self.successNumber,self.rewardPoints];;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, COMMOBCONTENTWIDTH, COMMONLINEHEIGHT + 8)];
    UIImageView *backImg = [[UIImageView alloc] initWithFrame:headerView.bounds];
    backImg.image = [UIImage imageNamed:@"img_invite_up"];
    [headerView addSubview:backImg];
    
    FTCoreTextView *textView = [[FTCoreTextView alloc] initWithFrame:CGRectMake(0, 8, COMMOBCONTENTWIDTH, COMMONLINEHEIGHT - 8)];
    [textView setText:str];
    [textView addStyles:[self coreTextStyleWithRed]];
    [textView fitToSuggestedHeight];
    
    [headerView addSubview:textView];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return COMMONLINEHEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIImageView *footerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_invite_bottom"]];
    
    //    footerView.frame = CGRectMake(0, 0, COMMOBCONTENTWIDTH, COMMONLINEHEIGHT);
    
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
        rect.size.height = COMMONLINEHEIGHT;
        cell.frame = rect;
        
        CGFloat height = cell.frame.size.height - 4;
        
        UIView *backView = [[UIView alloc] initWithFrame:cell.bounds];
        backView.tag = 20130102;
        
        rect.size.height = height;
        UIView *contentView = [[UIView alloc] initWithFrame:rect];
        contentView.backgroundColor = [UIColor clearColor];
        
        UILabel *useName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, height)];
        useName.tag = USERNAMETAG;
        useName.backgroundColor = [UIColor clearColor];
        useName.font = [UIFont systemFontOfSize:FontSize];
        useName.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:useName];
        
        UILabel *userType = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 50, height)];
        userType.tag = USERTYPETAG;
        [userType setTextColor:RGBCOLOR(67, 94, 114)];
        userType.font = [UIFont systemFontOfSize:FontSize];
        userType.backgroundColor = [UIColor clearColor];
        userType.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:userType];
        
        FTCoreTextView *userStatus = [[FTCoreTextView alloc] initWithFrame:CGRectMake(130, 5, 95, height)];
        userStatus.tag = USERSTATUSTAG;
        [contentView addSubview:userStatus];
        
        FTCoreTextView *userReward = [[FTCoreTextView alloc] initWithFrame:CGRectMake(225, 5, 60, height)];
        userReward.tag = USERREWARDTAG;
        [contentView addSubview:userReward];
        
        contentView.center = backView.center;
        [backView addSubview:contentView];        [cell addSubview:backView];
    }
    
    NSDictionary *dictiony = [self.dataArray objectAtIndex:indexPath.row];
    
    UILabel *userName = (UILabel *)[cell viewWithTag:USERNAMETAG];
    [userName setText:[dictiony objectForKey:@"realname"]];
    
    UILabel *userType = (UILabel *)[cell viewWithTag:USERTYPETAG];
    NSString *userTypeStr = [dictiony objectForKey:@"userType"];
  NSString *typeStr;
  if (userTypeStr.length > 0) {
    typeStr  = [userTypeStr isEqualToString:@"Doctor"] ? @"医师" :@"学生";
  }else
    typeStr = @"";
  
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
        mainView.backgroundColor = RGBCOLOR(245, 239, 217);
    }else{
        mainView.backgroundColor = RGBCOLOR(255, 251, 238);
    }
    
    return cell;
}

#pragma mark -
- (NSArray *)coreTextStyleWithRed{
    /****************** the init Core Text Style  start ******************/
    NSMutableArray *result = [NSMutableArray array];
    FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
	defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
	defaultStyle.font = [UIFont systemFontOfSize:FontSize];
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
	defaultStyle.font = [UIFont systemFontOfSize:FontSize];
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

#pragma mark - post action.

- (void) popBack:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)inviteReigisterBtn:(id)sender {
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"icon@2x" ofType:@"png"];
    
    NSString *url = [ImdUrlPath invitedFriendBy:[ISBaseInfoManager getUserInfoId]];
  NSArray *shareList;
  if (![CompatibilityUtil isIOS7Above]) {
    shareList  = [ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeQQSpace,ShareTypeQQ,ShareTypeWeixiSession,ShareTypeWeixiTimeline, nil];
  }else
   shareList  = [ShareSDK getShareListWithType:ShareTypeSMS,ShareTypeMail,ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeQQSpace,ShareTypeQQ,ShareTypeWeixiSession,ShareTypeWeixiTimeline, nil];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@%@",SETTINGS_INVITE_COMMON,url]
                                       defaultContent:SETTINGS_INVITE_COMMON
                                                image:[ShareSDK imageWithPath:imgPath]
                                                title:@"睿医文献"
                                                  url:url
                                          description:SETTINGS_INVITE_COMMON
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [publishContent addSMSUnitWithContent:[NSString stringWithFormat:@"%@%@",SETTINGS_INVITE_SMS,url]];
    [publishContent addWeixinTimelineUnitWithType:[NSNumber numberWithInteger:SSPublishContentMediaTypeNews]
                                          content:SETTINGS_INVITE_TIMELINES
                                            title:@"邀请好友注册"
                                              url:url
                                            image:INHERIT_VALUE
                                     musicFileUrl:nil
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    
    
    id<ISSShareOptions> shareOptions = [ShareSDK simpleShareOptionsWithTitle:@"邀请好友注册" shareViewDelegate:nil];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:shareOptions
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
