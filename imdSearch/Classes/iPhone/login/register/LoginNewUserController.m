//
//  LoginNewUserController.m
//  imdSearch
//
//  Created by Huajie Wu on 11-12-12.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "LoginNewUserController.h"
#import "TableViewFormatUtil.h"
#import "Strings.h"
#import "ImageViews.h"
#import "LoginNewUserStep2.h"
#import "IPhoneHeader.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "LoginController.h"

#define CHECK_TYPE @"checktype"
#define CHECK_EMAL @"checkemail"
#define CHECK_NICKNAME @"checknickname"
#define CHECK_MOBILE @"checkmobile"

#define PHONEALERTVIEWTAG   2013110101
#define EMAILALERTVIEWTAG   2013110102

@interface LoginNewUserController(){
    BOOL isNext;
    UITextField *currentField;
}
@property (strong, nonatomic) IBOutlet UIView *contentView;
@end

@implementation LoginNewUserController

@synthesize inputEmail, inputPassword, inputRealName;
@synthesize emailLbl, realNameLbl, pwdLbl;
@synthesize step2;
@synthesize userType = _userType;
@synthesize httpRequest = _httpRequest;
@synthesize emailChecked,mobileChecked;
@synthesize backtoFrist;
@synthesize phoneLable,inputPhoneNumber;

-(void) dealloc
{
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = LOGIN_NEWUSER;
        isNext = FALSE;
        
        // Custom initialization
        UIBarButtonItem* nextStepBtn = [TableViewFormatUtil customBackBarButton:LOGIN_NEXTSTEP color:APPDefaultColor target:self action:@selector(nextStep:)];
        
        [self.navigationItem setRightBarButtonItem:nextStepBtn];
        
        alertView = [[UIAlertView alloc] initWithTitle:REGISTER_TITLE message:REGISTER_EMAIL_FORMAT delegate:self cancelButtonTitle:ALERT_CONFIRM otherButtonTitles:nil];
        
        step2 = [[LoginNewUserStep2 alloc] initWithNibName:@"LoginNewUserStep2" bundle:nil];
        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) popBack
{
    isNext = TRUE;
    [self behavior:@"backButtonTapped"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self behavior:@"viewDidLoad"];
    [super viewDidLoad];
    self.backtoFrist = NO;
    kill = NO;
    self.inputPassword.secureTextEntry = YES;
    self.inputPhoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.mainScrollView setContentSize:self.mainScrollView.frame.size];
    
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.emailChecked = NO;
    kill = NO;
    self.inputPassword.text = @"";
    if (self.backtoFrist) {
        [self textFieldDidEndEditing:self.inputEmail];
    }
    
    [TableViewFormatUtil setBorder:self.contentView Color:[UIColor lightGrayColor]];
    [TableViewFormatUtil backBarButtonItemInfoModify:self.navigationItem];
}
- (void)viewDidUnload
{
    [self behavior:@"viewDidUnload"];
    [self setMainScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark action
-(IBAction)nextStep:(id)sender
{
    isNext = TRUE;
    NSLog(@"%d",self.inputPhoneNumber.text.length);
    NSLog(@"%d",self.inputPassword.text.length);
    [inputEmail resignFirstResponder];
    [inputPhoneNumber resignFirstResponder];
    if (self.inputPhoneNumber.text.length == 0) {
        [alertView setMessage:@"手机号码为必填项，请输入正确手机号码。"];
        [alertView show];
        [inputPhoneNumber becomeFirstResponder];
        
        return;
    }
    if (self.inputPhoneNumber.text.length > 0){
        if (![Strings phoneNumberJudge:self.inputPhoneNumber.text]) {
            [inputPhoneNumber becomeFirstResponder];
            [alertView setMessage:@"您输入的手机号码错误，请输入正确的手机号码。"];
            [alertView show];
            return;
        }
    }
    if (self.inputEmail.text.length > 0) {
        if (![Strings validEmail:self.inputEmail.text]) {
            [inputEmail becomeFirstResponder];
            [alertView show];
            return;
        }
    }
    if (self.inputPassword.text.length < 6 || self.inputPassword.text.length > 40) {
        [inputPassword becomeFirstResponder];
        [alertView setMessage:REGISTER_PWD_LENGTH];
        [alertView show];
        return;
    }
    if (![Strings judgeStringAsc:self.inputRealName.text] || self.inputRealName.text.length <2) {
        [alertView setMessage:@"请填写您的中文姓名"];
        [alertView show];
        [inputRealName becomeFirstResponder];
        return;
    }
    
    pwdLbl.textColor = [TableViewFormatUtil getInputedColor];
    realNameLbl.textColor = [TableViewFormatUtil getInputedColor];
    
    //    LoginNewUserStep2* newUserStep2 = [[LoginNewUserStep2 alloc] initWithNibName:@"LoginNewUserStep2" bundle:nil];
    if (self.inputPhoneNumber.text.length > 0) {
        [step2.registerData setObject:inputPhoneNumber.text forKey:REGISTER_INFO_MOBILE];
    }
    if (self.inputEmail.text.length > 0) {
        [step2.registerData setObject:inputEmail.text forKey:REGISTER_INFO_USERNAME];
    }
    [step2.registerData setObject:inputPassword.text forKey:REGISTER_INFO_PASSWORD];
    [step2.registerData setObject:inputRealName.text forKey:REGISTER_INFO_REALNAME];
    [step2.registerData setObject:self.userType forKey:REGISTER_INFO_USERTYPE];
    
    step2.isDoctor = [self.userType isEqualToString:REGISTER_USERTYPE_DOCTOR];
    if (self.inputPhoneNumber.text.length > 0 && self.inputEmail.text.length > 0) {
        if (self.emailChecked && self.mobileChecked) {
            kill = YES;
            [self.navigationController pushViewController:step2 animated:YES];
        }
    }else if (self.inputPhoneNumber.text.length > 0 && self.inputEmail.text.length == 0) {
        if(self.mobileChecked)
        {
            kill = YES;
            [self.navigationController pushViewController:step2 animated:YES];
        }
    }else if (self.inputPhoneNumber.text.length == 0 && self.inputEmail.text.length > 0)
    {
        if(self.emailChecked)
        {
            kill = YES;
            [self.navigationController pushViewController:step2 animated:YES];
        }
    }
    [self behavior:@"nextButtonTapped"];
}

#pragma mark --keyboard Notification
-(void)keyboardWillHide:(NSNotification *)notification
{
    [self.mainScrollView setContentOffset:CGPointZero animated:YES];
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    //键盘的大小
    CGSize keyboardRect = [aValue CGRectValue].size;
    
    CGRect rect = [self.contentView convertRect:currentField.frame toView:self.view];
    
    CGFloat height = self.mainScrollView.frame.size.height - (rect.origin.y + rect.size.height + 10);
    
    [self.mainScrollView setContentOffset:CGPointMake(0, (height - keyboardRect.height) > 0 ? 0  : (keyboardRect.height - height)) animated:YES];
}

#pragma mark - UItextfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    currentField = textField;
    return  YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField == inputEmail)
        [inputPassword becomeFirstResponder];
    else if (textField == inputPassword)
        [inputRealName becomeFirstResponder];
    else if (textField == inputRealName)
        [self nextStep:nil];
    else if (textField == inputPhoneNumber)
        [inputPhoneNumber becomeFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (kill || isNext) {
        isNext = FALSE;
        return;
    }
    
    if (textField == inputPhoneNumber) {
        
        if (![Strings phoneNumberJudge:self.inputPhoneNumber.text]) {
            
            [self.inputPhoneNumber setText:nil];
            
            NSString *messagge = [inputPhoneNumber.text isEqualToString:@""] ? @"手机号码为必填项，请输入正确手机号码。" : @"您输入的手机号码错误，请输入正确的手机号码。";
            UIAlertView *alertView_ = [[UIAlertView alloc] initWithTitle:nil message:messagge delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alertView_ show];
            
            [self performSelector:@selector(textFIeldBecomFirestResponder:) withObject:self.inputPhoneNumber afterDelay:0.5];
            
            return;
        }
        
        if (inputPhoneNumber.text.length > 0 && [Strings phoneNumberJudge:inputPhoneNumber.text]) {
            
            NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setObject:CHECK_EMAL forKey:CHECK_TYPE];
            if (self.httpRequest != nil) {
                [self.httpRequest clearDelegatesAndCancel];
            }
            self.httpRequest = [UrlRequest checkMobile:[ImdUrlPath checkMobileUrl:inputPhoneNumber.text] delegate:self];
            self.mobileChecked = NO;
        }
    }
    else if (textField == inputEmail && ![inputEmail.text isEqualToString:@""]) {
        if (kill) {
            return;
        }
        
        if (![Strings validEmail:self.inputEmail.text]) {
            UIAlertView *alertView_ = [[UIAlertView alloc] initWithTitle:nil message:@"您输入的电子邮箱错误，请输入正确的电子邮箱。" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alertView_ show];
            
            [self.inputEmail setText:nil];
            
            [self performSelector:@selector(textFIeldBecomFirestResponder:) withObject:self.inputEmail afterDelay:0.5];
            
            return;
        }
        
        if (inputEmail.text.length > 0 && [Strings validEmail:inputEmail.text]) {
            
            NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setObject:CHECK_EMAL forKey:CHECK_TYPE];
            if (self.httpRequest != nil) {
                [self.httpRequest clearDelegatesAndCancel];
            }
            self.httpRequest = [UrlRequest sendWithTokenWithUserInfo:[ImdUrlPath checkEmailUrl:inputEmail.text] userInfo:userInfo delegate:self];
            self.emailChecked = NO;
        }
    }
}

- (void)textFIeldBecomFirestResponder:(UITextField *)field{
    isNext = TRUE;
    [field becomeFirstResponder];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    
    NSLog(@"%@",[request responseString]);
    NSDictionary* userInfo =[request userInfo];
    NSString* checkType =[userInfo objectForKey:CHECK_TYPE];
    
    if ([checkType isEqualToString:CHECK_EMAL]) {
        BOOL checkemail;
        checkemail = [[request responseString] boolValue];
        if (checkemail) {
            self.emailChecked = YES;
        } else {
            [self showAccountHasUsedWithTag:EMAILALERTVIEWTAG];
            return;
        }
    } else if ([checkType isEqualToString:CHECK_NICKNAME]) {
        if ([[resultsJson objectForKey:RETINFO_STATUS] isEqualToString:@"true"]) {
            
        } else {
            [alertView setMessage:[resultsJson objectForKey:RETINFO_MESSAGE]];
            [alertView setTitle:REGISTER_TITLE];
            [alertView show];
        }
    }else if ([checkType isEqualToString:@"getMobile"]) {
        self.mobileChecked = [[request responseString] boolValue];
        if (self.mobileChecked) {
        } else {
            [self showAccountHasUsedWithTag:PHONEALERTVIEWTAG];
            return;
        }
    }
    
    if (inputPassword.text.length > 6) {
        if (self.emailChecked && [Strings judgeStringAsc:inputRealName.text] | self.mobileChecked && [Strings judgeStringAsc:inputRealName.text]) {
            kill = YES;
            [self.navigationController pushViewController:step2 animated:YES];
            BOOL checkemail;
            checkemail = [[request responseString] boolValue];
            if (checkemail) {
                self.emailChecked = YES;
            } else {
                
                [self showAccountHasUsedWithTag:EMAILALERTVIEWTAG];
                
                return;
            }
        }else if ([checkType isEqualToString:@"getMobile"]) {
            self.mobileChecked = [[request responseString] boolValue];
            if (self.mobileChecked) {
                
            } else {
                [self showAccountHasUsedWithTag:PHONEALERTVIEWTAG];
                return;
            }
        } else if ([checkType isEqualToString:CHECK_NICKNAME]) {
            if ([[resultsJson objectForKey:RETINFO_STATUS] isEqualToString:@"true"]) {
                
            } else {
                [alertView setMessage:[resultsJson objectForKey:RETINFO_MESSAGE]];
                [alertView setTitle:REGISTER_TITLE];
                [alertView show];
            }
        }
        
        if (inputPassword.text.length > 6) {
            if (self.emailChecked && [Strings judgeStringAsc:inputRealName.text] | self.mobileChecked && [Strings judgeStringAsc:inputRealName.text]) {
                kill = YES;
                [self.navigationController pushViewController:step2 animated:YES];
            }
        }
    }
    
}


-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    [alertView setMessage:REQUEST_FAILED_MESSAGE];
    [alertView setTitle:REQUEST_FAILED_TITLE];
    [alertView show];
}

- (void)behavior:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:REGISTER_DOCTOR_1 paramJson:json];
}

- (void)showAccountHasUsedWithTag:(int)tag{
    NSString *account = nil;
    if (tag == EMAILALERTVIEWTAG) {
        account = self.inputEmail.text;
    }else if (tag == PHONEALERTVIEWTAG){
        account = self.inputPhoneNumber.text;
    }
    
    UIAlertView *alertView_ = [[UIAlertView alloc] initWithTitle:@"手机/邮箱已注册" message:[NSString stringWithFormat:@"对不起，%@已被注册。请输入新的手机/邮箱。要使用本帐号，请选择“找回密码”。",account] delegate:self cancelButtonTitle:@"找回密码" otherButtonTitles:@"重新输入", nil];
    alertView_.tag = tag;
    
    [alertView_ show];
}

- (void)alertView:(UIAlertView *)alertView_ clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView_.tag == EMAILALERTVIEWTAG) {
        if (buttonIndex == 0) {
            [self findUserPassword:self.inputEmail.text];
        }else{
            self.inputEmail.text = nil;
            [self.inputEmail becomeFirstResponder];
        }
    }else if (alertView_.tag == PHONEALERTVIEWTAG){
        if (buttonIndex == 0) {
            [self findUserPassword:self.inputPhoneNumber.text];
        }else{
            self.inputPhoneNumber.text = nil;
            [self.inputPhoneNumber becomeFirstResponder];
        }
    }
}

- (void)findUserPassword:(NSString *)accountInfo{
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (UIViewController *viewController in viewControllers) {
        if ([viewController isKindOfClass:[LoginController class]]) {
            [self.navigationController popToViewController:viewController animated:NO];
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FindUserPassword" object:accountInfo];
}
@end
