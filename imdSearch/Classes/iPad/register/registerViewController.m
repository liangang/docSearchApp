//
//  registerViewController.m
//  imdSearch
//
//  Created by 立纲 吴 on 1/11/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "registerViewController.h"
#import "registerFinishViewController.h"
#import "ASIHTTPRequest.h"
#import "Util.h"
#import "url.h"
#import "JSON.h"
#import "PadText.h"
#import "Url_iPad.h"
#import "serviceProtocolViewController.h"
#import "SaveKey.h"
#import "RegisterStudentsViewController.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "Strings.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "loginViewController.h"

#define PHONEALERTVIEWTAG   2013110401
#define EMAILALERTVIEWTAG   2013110402

@implementation registerViewController{
    BOOL dismissView;
    BOOL isMobileSucc;
}

@synthesize delegate;
@synthesize fieldEmail,fieldUserName,fieldPass,fieldPassConfirm,fieldNickName;
@synthesize emailRegisted;
@synthesize nextButton;
@synthesize readPorotol;
@synthesize mobileRegisted,fieldMobileTF;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isMobileSucc = YES;
    }
    return self;
}

-(void)dealloc
{
    
    self.fieldEmail =nil;
    self.fieldUserName =nil;
    self.fieldPassConfirm =nil;
    self.fieldPass =nil;
    self.fieldNickName =nil;
    
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
    [self behavior:@"viewDidLoad"];
    nextButton.enabled = false;
    
    self.fieldPass.secureTextEntry = YES;
    self.fieldPassConfirm.secureTextEntry =YES;
    
    mailChecked =NO;
    
    [readPorotol setImage:
     [UIImage imageNamed:@"btn-checkbox-selected"] forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.fieldPass.text =@"";
    self.fieldPassConfirm.text =@"";
    
    [self.fieldMobileTF becomeFirstResponder];
    self.fieldMobileTF.keyboardType = UIKeyboardTypeNumberPad;
    
    dismissView = NO;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.fieldEmail =nil;
    self.fieldUserName =nil;
    self.fieldPassConfirm =nil;
    self.fieldPass =nil;
    self.fieldNickName =nil;
    self.emailRegisted = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)serviceProtocolButtonTapped:(id)sender
{
    [self behavior:@"serviceProtocolButtonTapped"];
    serviceProtocolViewController* rcvc =
    [[serviceProtocolViewController alloc] initWithNibName:
     @"serviceProtocolViewController" bundle:nil];
    rcvc.delegate = self.delegate;
    [self.navigationController pushViewController:rcvc animated:YES];
    [readPorotol setImage:[UIImage imageNamed:@"btn-checkbox-selected"] forState:UIControlStateNormal];
}

-(IBAction)backButtonTapped:(id)sender
{
    [self behavior:@"backButtonTapped"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"tempRegInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dismissView = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)nextButtonTapped:(id)sender
{
    [self behavior:@"nextButtonTapped"];
    [self.fieldEmail resignFirstResponder];
    [self.fieldMobileTF resignFirstResponder];
    if (self.fieldMobileTF.text.length == 0) {
        [self alertWithMsg:@"手机号码为必填项，请输入正确手机号码。"];
        [self.fieldMobileTF becomeFirstResponder];
        return;
    }
    
    if (self.fieldMobileTF.text.length > 0){
        if (![Strings phoneNumberJudge:self.fieldMobileTF.text]) {
            self.fieldMobileTF.text = nil;
            [self.fieldMobileTF becomeFirstResponder];
            [self alertWithMsg:@"您输入的手机号码错误，请输入正确的手机号码。"];
            return;
        }
    }
    
    if (self.fieldEmail.text.length > 0) {
        if (![Strings validEmail:self.fieldEmail.text]) {
            [self.fieldEmail becomeFirstResponder];
            [self alertWithMsg:@"您输入的电子邮箱错误，请输入正确的电子邮箱。"];
            return;
        }
    }
    
    if (self.fieldMobileTF.text.length > 0 && self.fieldEmail.text.length > 0) {
        if (mailChecked && mobileChecked) {
            [self antherCheck];
        }
    }else if (self.fieldMobileTF.text.length > 0 && self.fieldEmail.text.length == 0) {
        if(mobileChecked)
        {
            [self antherCheck];
        }
    }else if (self.fieldMobileTF.text.length == 0 && self.fieldEmail.text.length > 0){
        if(mailChecked)
        {
            [self antherCheck];
        }
    }
}

-(void)antherCheck
{
    NSLog(@"checking name");
    
    if(![Strings judgeStringAsc:self.fieldUserName.text] || self.fieldUserName.text.length < 2)
    {
        NSLog(@"name check failed");
        [self alertWithMsg:INFO_ENTER_YOUR_NAME];
        
        [self.fieldUserName becomeFirstResponder];
        
        self.fieldUserName.textColor =[UIColor redColor];
        return;
    }
    
    NSLog(@"checking pass");
    if([self.fieldPass.text isEqualToString:@""] || (self.fieldPass.text.length <6 || self.fieldPass.text.length>40))
    {
        NSLog(@"pass check failed");
        [self alertWithMsg:INFO_ENTER_YOUR_PASSWORD];
        
        [self.fieldPass becomeFirstResponder];
        
        self.fieldPass.textColor =[UIColor redColor];
        
        return;
    }
    
    NSLog(@"checking passConfirm");
    if([self.fieldPassConfirm.text isEqualToString:@""] || ![self.fieldPassConfirm.text isEqualToString:self.fieldPass.text])
    {
        NSLog(@"pasconfirm check failed");
        [self alertWithMsg:INFO_CONFIRM_PASSWORD_IS_WRONG];
        
        [self.fieldPassConfirm becomeFirstResponder];
        
        self.fieldPassConfirm.textColor =[UIColor redColor];
        return;
    }
    
    NSLog(@"no nickname checking");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_REGISTER_TITLE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_REGISTER_DEPARTMENT_INFO];
    
    NSMutableDictionary* dict =[[NSMutableDictionary alloc] initWithCapacity:10];
    
    if (self.fieldEmail.text.length > 0) {
        [dict setObject:self.fieldEmail.text forKey:KEY_REGISTER_USERNAME];
    }
    
    if (self.fieldMobileTF.text.length > 0) {
        [dict setObject:self.fieldMobileTF.text forKey:REGISTER_INFO_MOBILE];
    }
    
    [dict setObject:self.fieldUserName.text forKey:KEY_REGISTER_REALNAME];
    [dict setObject:self.fieldPass.text forKey:KEY_REGISTER_PASSWORD];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"tempRegInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString* model = [[NSUserDefaults standardUserDefaults] objectForKey:SaveRegisterModel];
    
    if ([model isEqualToString:REGISTER_DOCTORS_MODEL]) {
        registerFinishViewController* nextRegisterPartVC = [[registerFinishViewController alloc] initWithNibName:@"registerFinishViewController" bundle:nil];
        nextRegisterPartVC.delegate =self.delegate;
        
        [self.navigationController pushViewController:nextRegisterPartVC animated:YES];
    } else {
        RegisterStudentsViewController* rsvc = [[RegisterStudentsViewController alloc] initWithNibName:@"RegisterStudentsViewController" bundle:nil];
        rsvc.delegate = self.delegate;
        [self.navigationController pushViewController:rsvc animated:YES];
    }
}

-(void)alertWithMsg:(NSString*)text
{
    [self behavior:[NSString stringWithFormat:@"alertWithMsg:%@", text]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:text delegate:nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if(textField == self.fieldMobileTF)
  {
    [textField resignFirstResponder];
    [self.fieldEmail becomeFirstResponder];
  }
    if(textField == self.fieldEmail)
    {
        [textField resignFirstResponder];
        [self.fieldUserName becomeFirstResponder];
    }
    
    if(textField == self.fieldUserName)
    {
        [textField resignFirstResponder];
        [self.fieldPass becomeFirstResponder];
    }
    
    if(textField == self.fieldPass)
    {
        [textField resignFirstResponder];
        [self.fieldPassConfirm becomeFirstResponder];
    }
    
    if(textField == self.fieldPassConfirm)
    {
        [textField resignFirstResponder];
        [self.fieldNickName becomeFirstResponder];
    }
    
    if(textField == self.fieldNickName)
    {
        [textField resignFirstResponder];
        [self nextButtonTapped:nil];
    }
    
    return YES;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (dismissView) {
        return;
    }
    
    textField.textColor =[UIColor blackColor];
    
    if(textField == self.fieldEmail && self.fieldEmail.text.length > 0)
    {
        if ([Strings validEmail:self.fieldEmail.text]) {
            self.fieldEmail.textColor =[UIColor blackColor];
            [self checkMail:1];
        } else {
            [self alertWithMsg:@"您输入的电子邮箱错误，请输入正确的电子邮箱。"];
            isMobileSucc = FALSE;
            self.fieldEmail.text = nil;
            [self performSelector:@selector(textFIeldBecomFirestResponder:) withObject:self.fieldEmail afterDelay:0.5];
        }
        
    }else if (textField == self.fieldMobileTF)
    {
        if (self.fieldMobileTF.text.length == 0) {
            isMobileSucc = FALSE;
            [self alertWithMsg:@"手机号码为必填项，请输入正确手机号码。"];
            [self performSelector:@selector(textFIeldBecomFirestResponder:) withObject:self.fieldMobileTF afterDelay:0.5];
            return;
        }
        
        if ([Strings phoneNumberJudge:self.fieldMobileTF.text]) {
            self.fieldMobileTF.textColor =[UIColor blackColor];
            if (self.fieldMobileTF.text.length > 0) {
                [UrlRequest checkMobile:[ImdUrlPath checkMobileUrl:self.fieldMobileTF.text] delegate:self];
                mobileChecked = NO;
            }
        }else{
            isMobileSucc = FALSE;
            
            [self alertWithMsg:@"您输入的手机号码错误，请输入正确的手机号码。"];
            self.fieldMobileTF.text = nil;
            
            [self performSelector:@selector(textFIeldBecomFirestResponder:) withObject:self.fieldMobileTF afterDelay:0.5];
        }
    }
//    else if (textField == self.fieldUserName){
//        if (![Strings judgeStringAsc:self.fieldUserName.text] || self.fieldUserName.text.length <2) {
//            self.fieldUserName.text = nil;
//            
//            if (isMobileSucc) {
//                [self alertWithMsg:@"请填写您的中文姓名"];
//                [self performSelector:@selector(textFIeldBecomFirestResponder:) withObject:self.fieldUserName afterDelay:0.5];
//            }
//            
//            return;
//        }
//
//    }
  
}

- (void)textFIeldBecomFirestResponder:(UITextField *)field{
    [field becomeFirstResponder];
}

-(void)checkMail:(int)status
{
    if([self.fieldEmail.text isEqualToString:@""]) return;
    
    //  NSString* mailString =
    //  [Util URLencode:self.fieldEmail.text stringEncoding:NSUTF8StringEncoding];
    
    NSString* urlString =
    [NSString stringWithFormat:CHECK_EMAIL_URL,NEW_SERVER_IPAD,self.fieldEmail.text];
    
    NSLog(@"checking mail url = %@",urlString);
    ASIHTTPRequest *request =
    [ASIHTTPRequest requestWithURL:
     [NSURL URLWithString:urlString]];
    
    
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    //[request setRequestMethod:@"POST"];
    
    //imdPadAppDelegate *appDelegate = (imdPadAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithCapacity:5];
    if (status == 0) {
        [userInfo setObject:REQUEST_CHECK_EMAIL_NEXT forKey:REQUEST_TYPE];
    } else {
        [userInfo setObject:REQUEST_CHECK_EMAIL forKey:REQUEST_TYPE];
    }
    [request setUserInfo:userInfo];
    mailChecked =NO;
    
    request.delegate = self;
    [request startAsynchronous];
    
}


-(void)requestFinished:(ASIHTTPRequest*)request
{
    NSDictionary* requestInfo =[request userInfo];
    NSString* rType = [requestInfo objectForKey:@"checktype"];
    if ([rType isEqualToString:@"getMobile"]) {
        mobileChecked = [[request responseString] boolValue];
        if (mobileChecked ==1) {
            self.mobileRegisted.hidden = YES;
            isMobileSucc = YES;
        }else{
            self.mobileRegisted.hidden = NO;
             isMobileSucc = NO;
            [self showAccountHasUsedWithTag:PHONEALERTVIEWTAG];
        }
    }else{
        BOOL checkEmail;
        checkEmail = [[request responseString] boolValue];
        
        if(checkEmail ==1){
            mailChecked =YES;
            NSLog(@"checkMail ok");
            self.emailRegisted.hidden = YES;
        }else{
            self.emailRegisted.hidden = NO;
            NSLog(@"checkMail failed");
            [self showAccountHasUsedWithTag:EMAILALERTVIEWTAG];
            
            return;
        }
    }
}


-(void)requestFailed:(ASIHTTPRequest*)request
{
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    NSLog(@"request failed");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}

-(IBAction)textFieldEditDidEnd:(id)sender
{
    if ([[readPorotol imageForState:UIControlStateNormal] isEqual:
         [UIImage imageNamed:@"btn-checkbox-selected"]] ) {
        nextButton.enabled = true;
    } else {
        nextButton.enabled = false;
    }
}

-(IBAction)readPorotolTapped:(id)sender
{
    [self behavior:@"readPorotolTapped"];
    if ([[readPorotol imageForState:UIControlStateNormal] isEqual:
         [UIImage imageNamed:@"btn-checkbox-selected"]]) {
        [readPorotol setImage:
         [UIImage imageNamed:@"btn-checkbox-normal"] forState:
         UIControlStateNormal];
    } else {
        [readPorotol setImage:
         [UIImage imageNamed:@"btn-checkbox-selected"] forState:UIControlStateNormal];
    }
    [self textFieldEditDidEnd:sender];
}

-(IBAction)fieldEmailTapped:(id)sender
{
    [self behavior:@"fieldEmailTapped"];
    NSLog(@"fieldEmailTapped");
    //  fieldEmail.textColor = [UIColor blackColor];
    self.emailRegisted.hidden = YES;
}
-(IBAction)fieldMobileTapped:(id)sender
{
    self.mobileRegisted.hidden = YES;
}
- (void)behavior:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:REGISTER_DOCTOR_1 paramJson:json];
}

- (void)showAccountHasUsedWithTag:(int)tag{
    NSString *account = nil;
    if (tag == EMAILALERTVIEWTAG) {
        account = self.fieldEmail.text;
    }else if (tag == PHONEALERTVIEWTAG){
        account = self.fieldMobileTF.text;
    }
    
    UIAlertView *alertView_ = [[UIAlertView alloc] initWithTitle:@"手机/邮箱已注册" message:[NSString stringWithFormat:@"对不起，%@已被注册。请输入新的手机/邮箱。要使用本帐号，请选择“找回密码”。",account] delegate:self cancelButtonTitle:@"找回密码" otherButtonTitles:@"重新输入", nil];
    alertView_.tag = tag;
    
    [alertView_ show];
}

- (void)alertView:(UIAlertView *)alertView_ clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView_.tag == EMAILALERTVIEWTAG) {
        if (buttonIndex == 0) {
            [self findUserPassword:self.fieldEmail.text];
        }else{
            self.fieldEmail.text = nil;
          self.emailRegisted.hidden = YES;
            [self.fieldEmail becomeFirstResponder];
        }
    }else if (alertView_.tag == PHONEALERTVIEWTAG){
        if (buttonIndex == 0) {
            [self findUserPassword:self.fieldMobileTF.text];
        }else{
            self.fieldMobileTF.text = nil;
            [self.fieldMobileTF becomeFirstResponder];
        }
    }
}

- (void)findUserPassword:(NSString *)accountInfo{
    NSArray *viewControllers = [self.navigationController viewControllers];
    
    for (UIViewController *viewController in viewControllers) {
        if ([viewController isKindOfClass:[loginViewController class]]) {
            [self.navigationController popToViewController:viewController animated:NO];
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FindUserPassword" object:accountInfo];
}
@end
