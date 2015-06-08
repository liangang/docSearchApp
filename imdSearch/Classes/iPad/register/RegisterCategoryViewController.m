//
//  RegisterCategoryViewController.m
//  imdSearch
//
//  Created by ding zhihong on 12-4-5.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "RegisterCategoryViewController.h"
#import "registerViewController.h"
#import "RegisterStudentsViewController.h"
#import "PadText.h"
#import "SaveKey.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "Strings.h"
#import "ASIHTTPRequest.h"
#import "UrlRequest.h"
#import "JSON.h"
#import "ImdUrlPath.h"
#import "newVerifiedViewController.h"

@implementation RegisterCategoryViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
    }
    return self;
}
-(void) popBack
{
  [self behavior:@"backButtonTapped"];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择您的身份信息" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
  [alert show];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // Do any additional setup after loading the view from its nib.
    NSString *remind = @"睿医仅为\n<orangeColor>临床医师</orangeColor>和<blueColor>医学院校在校学生</blueColor>\n提供专业医学信息服务";
    self.remindInfo.text = remind;
    
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
    
    [self.remindInfo addStyles:result];
    [self.remindInfo fitToSuggestedHeight];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self behavior:@"viewDidLoad"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)backButtonTapped:(id)sender
{
  if (self.type == UserInfoCenter)
  {
      //[self popBack];
    [self dismissViewControllerAnimated:YES completion:nil];
  }else if (self.type == PersonCenter)
  {
    [self.navigationController popViewControllerAnimated:YES];
  }
  else
  {
    [self behavior:@"backButtonTapped"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"tempRegInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (IBAction)doctorsButtonTapped:(id)sender
{
  if (self.type == PersonCenter | self.type == UserInfoCenter) {
    self.userType = USERTYPE_DOCTOR;
    [self alertShow];
  }else if(self.type == RegisterSelect)
  {
    [self behavior:@"doctorsButtonTapped"];
    [[NSUserDefaults standardUserDefaults] setObject:REGISTER_DOCTORS_MODEL forKey:SaveRegisterModel];
    [self goToRegisterViewController];
  }
}

- (IBAction)studentsButtonTapped:(id)sender
{
  if (self.type == PersonCenter| self.type == UserInfoCenter) {
    self.userType = USERTYPE_STUDENT;
    [self alertShow];
  }else if(self.type == RegisterSelect)
  {
    [self behavior:@"studentsButtonTapped"];
    [[NSUserDefaults standardUserDefaults] setObject:REGISTER_STUDENTS_MODEL forKey:SaveRegisterModel];
    [self goToRegisterViewController];
  }
}

- (void)goToRegisterViewController
{
    registerViewController* rvc=[[registerViewController alloc] initWithNibName:@"registerViewController" bundle:nil];
    
    rvc.delegate =self.delegate;
    
    [self.navigationController pushViewController:rvc animated:YES];
}
- (void)alertShow
{
  NSString *tempstr = [Strings getIdentity:self.userType];
  NSString *message = [NSString stringWithFormat:@"您的身份为'%@'，保存成功后将无法再次修改，请确认。",tempstr];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请确认您的身份" message:message delegate:self cancelButtonTitle:@"重新选择" otherButtonTitles:@"确认身份",nil];
  [alert show];
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
  
  [UrlRequest setPadToken:request];
  [request appendPostData:[[dic JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
  request.delegate = self;
  request.tag = 2014071711;
  [request setDidFinishSelector:@selector(saveUserInfoFinish:)];
  [request startAsynchronous];
}
- (void)saveUserInfoFinish:(ASIHTTPRequest *)request_{
  NSDictionary *saveInfo = [UrlRequest getJsonValue:request_];
  
  if ([[saveInfo objectForKey:@"success"] boolValue]) {
    newVerifiedViewController *verifiledVC = [[newVerifiedViewController alloc] init];
    [self getUserInfo:[ImdUrlPath getUserInfo] delegate:verifiledVC];
    
    [self.navigationController pushViewController:verifiledVC animated:YES];
  }
}
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

- (void)behavior:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:REGISTER_CATEGORY paramJson:json];
}

@end
