//
//  LoginSelectController.m
//  imdSearch
//
//  Created by Huajie Wu on 12-3-28.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "LoginSelectController.h"
#import "IPhoneHeader.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "TableViewFormatUtil.h"
#import "Strings.h"
#import "UserInfoViewController.h"
#import "JSON.h"

@interface LoginSelectController (ColorButton)
+(void) setColorButton:(UIButton *)btn;
@end

@interface LoginSelectController (nextStep)
- (void) nextStep:(id)sender;
@end

@implementation LoginSelectController

@synthesize doctor = _doctor, student = _student;
@synthesize loginCtr = _loginCtr;


- (void) dealloc {
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = LOGIN_SELECT_USERTYPE;
        
        _loginCtr = [[LoginNewUserController alloc] init];
         }
    return self;
}

- (void) nextStep:(id)sender
{
    if (self.doctor.selected) {
        [self.loginCtr setUserType:USERTYPE_DOCTOR];
        [self.doctor setSelected:true];
        [self.student setSelected:false];
    } else {
        [self.loginCtr setUserType:USERTYPE_STUDENT];
        [self.doctor setSelected:false];
        [self.student setSelected:true];
    }
    [self.navigationController pushViewController:self.loginCtr animated:YES];
}

-(void) popBack
{
    [self behavior:@"backButtonTapped"];
//  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择您的身份信息" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//  [alert show];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

+(void) setColorButton:(UIButton *)btn
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  if (self.type == PersonCenter | self.type == UserInfoCenter)
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_return"] style:UIBarButtonItemStylePlain target:self action:@selector(popBack)];
  

    [self.loginCtr setUserType:USERTYPE_DOCTOR];
    
    NSString *remind = @"睿医仅为\n<orangeColor>临床医师</orangeColor>和<blueColor>医学院校在校学生</blueColor>\n提供专业医学信息服务";
    self.selectRemind.text = remind;
    
    NSMutableArray *result = [NSMutableArray array];
    FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
	defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
	defaultStyle.font = [UIFont systemFontOfSize:17];
	defaultStyle.textAlignment = FTCoreTextAlignementCenter;
	[result addObject:defaultStyle];
    
    FTCoreTextStyle *grayStyle = [defaultStyle copy];
	[grayStyle setName:@"orangeColor"];
    [grayStyle setColor:[UIColor orangeColor]];
	[result addObject:grayStyle];
    
    FTCoreTextStyle *coloredStyle = [defaultStyle copy];
    [coloredStyle setName:@"blueColor"];
    [coloredStyle setColor:[UIColor blueColor]];
	[result addObject:coloredStyle];

    [self.selectRemind addStyles:result];
    [self.selectRemind fitToSuggestedHeight];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [TableViewFormatUtil backBarButtonItemInfoModify:self.navigationItem];
}

- (void)viewDidUnload
{
    [self behavior:@"viewDidUnload"];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(IBAction)selectUserType:(id)sender
{
    UIButton* btn = (UIButton *)sender;
  if (btn == self.doctor) {
    self.userType = USERTYPE_DOCTOR;
    [self behavior:@"doctorsButtonTapped"];
  } else {
    self.userType = USERTYPE_STUDENT;
    [self behavior:@"studentsButtonTapped"];
  }
  if (self.type == RegisterSelect) {
    [self.loginCtr setUserType:self.userType];
    [self.navigationController pushViewController:self.loginCtr animated:YES];
  }else
  {
    NSString *tempstr = [Strings getIdentity:self.userType];
    NSString *message = [NSString stringWithFormat:@"您的身份为'%@'，保存成功后将无法再次修改，请确认。",tempstr];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请确认您的身份" message:message delegate:self cancelButtonTitle:@"重新选择" otherButtonTitles:@"确认身份",nil];
    [alert show];
  }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0) {
    self.userType = @"";
  }
  if (self.type == PersonCenter) {
    if (buttonIndex == 1) {
      [self.navigationController popViewControllerAnimated:YES];
    }
  }else if(self.type == UserInfoCenter)
  {
      //保存选择的usertype类型 到服务器上
    if (buttonIndex == 1) {
       [self sendSaveUseInfoRequest];
    }
  }
}
- (void)sendSaveUseInfoRequest{
  NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:1];
  [dic setObject:self.userType forKey:@"userType"];
  
 ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath saveUserInfo]]];
  
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  [UrlRequest setToken:request];
  [request appendPostData:[[dic JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
  request.delegate = self;
  request.tag = 2014071617;
  [request setDidFinishSelector:@selector(saveUserInfoFinish:)];
  [request startAsynchronous];
}
- (void)saveUserInfoFinish:(ASIHTTPRequest *)request_{
  NSDictionary *saveInfo = [UrlRequest getJsonValue:request_];
  
  if ([[saveInfo objectForKey:@"success"] boolValue]) {
  UserInfoViewController *user = [[UserInfoViewController alloc] init];
  [UrlRequest send:[ImdUrlPath getUserInfo] delegate:user];
  
  [self.navigationController pushViewController:user animated:YES];
  }
}
- (void)behavior:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:REGISTER_CATEGORY paramJson:json];
}
@end
