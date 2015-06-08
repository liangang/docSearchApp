//
//  loginViewController.m
//  imdSearch
//
//  Created by 8fox on 10/21/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "loginViewController.h"

#import "imdSearchAppDelegate.h"
#import "NetStatusChecker.h"

#import "RegisterCategoryViewController.h"
#import "FindPWDAccountInfoPadViewController.h"

#import "ImdAppBehavior.h"
#import "Util.h"
#import "Strings.h"
#import "TKAlertCenter.h"

#define ALERTVIEWTAG1 2013110101
#define ALERTVIEWTAG2 2013110102
#define ALERTVIEWTAG3 2013110103

@interface loginViewController(){
    BOOL isBtnPress;
}
@property (assign, nonatomic) BOOL isInputAccount;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation loginViewController

@synthesize delegate;
@synthesize userName,password;
@synthesize loadingCoverView,loadingIndicator,hintLabel,retryButton;

//to fix can not resign keyboard in modal view
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isBtnPress = FALSE;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.password.secureTextEntry = YES;
    self.indicator.hidden = YES;
    self.indicator.hidesWhenStopped = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginInfoDeal:) name:USERLOGININFO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findUserPasswordShow:) name:@"FindUserPassword" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyUserMobileDeal) name:@"" object:nil];
    
    [self.loginBtn setImage:[[UIImage imageNamed:@"login_login_default"] stretchableImageWithLeftCapWidth:80 topCapHeight:22] forState:UIControlStateNormal];
    [self.loginBtn setImage:[[UIImage imageNamed:@"login_login_press"] stretchableImageWithLeftCapWidth:80 topCapHeight:22] forState:UIControlStateHighlighted];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self setIndicator:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


-(IBAction)closeIt:(id)sender
{
    isBtnPress = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)registerNew:(id)sender
{
    isBtnPress = YES;
    [ImdAppBehavior registerBegin];
    RegisterCategoryViewController* rcvc = [[RegisterCategoryViewController alloc] initWithNibName:@"RegisterCategoryViewController" bundle:nil];
  rcvc.type = RegisterSelect;
    rcvc.delegate = self.delegate;
    [self.navigationController pushViewController:rcvc animated:YES];
}

-(IBAction)forgotPass:(id)sender
{
    isBtnPress = YES;
    self.password.text = nil;
    
    FindPWDAccountInfoPadViewController *viewController = [[FindPWDAccountInfoPadViewController alloc] init];
    viewController.type = ViewTypeFindPWD;
    viewController.userAccount = self.userName.text;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)connectServer
{
    if([NetStatusChecker isNetworkAvailbe]){
        [self performSelector:@selector(prepareAuth) withObject:nil afterDelay:1.0f];
    }else{
       [[TKAlertCenter defaultCenter] postAlertWithMessage:@"无法连接到互联网，请查看设置"];
    }
}


-(void)prepareAuth
{
    NSLog(@"prepareAuth");
    imdSearchAppDelegate* appDelegate =(imdSearchAppDelegate*) [[UIApplication sharedApplication] delegate];
    [appDelegate loadSecurity];
}

-(IBAction)retryConnect
{
    [loadingIndicator startAnimating];
    hintLabel.text =@"正在加载,请稍候...";
    retryButton.hidden = YES;
    [self connectServer];
}

-(void)connectionServerFinished
{
    NSLog(@"server connected done");
    
    [self indicatorActivity:FALSE];
}

- (void)loginWithUseName:(NSNotification *)notification{
    NSString *accountName = [notification object];
    self.userName.text = accountName;
    self.password.text = nil;
    [self.password becomeFirstResponder];
}

- (void)findUserPasswordShow:(NSNotification *)notification{
    [self.password setText:nil];
    NSString *accountInfo  = [notification object];
    FindPWDAccountInfoPadViewController *viewController = [[FindPWDAccountInfoPadViewController alloc] init];
    viewController.type = ViewTypeFindPWD;
    viewController.userAccount =accountInfo;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)userLoginInfoDeal:(NSNotification *)notification{
    NSString *result = [notification object];
    [self.indicator stopAnimating];
    
    if ([result isEqualToString:@"AccountNotExist"]) {
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"帐号不存在" message:[NSString stringWithFormat:@"未在系统中找到%@帐号，请输入正确帐号或注册新帐号。",self.userName.text] delegate:self cancelButtonTitle:@"注册新帐号" otherButtonTitles:@"重新输入帐号", nil];
        [alertView1 setTag:ALERTVIEWTAG1];
        [alertView1 show];
        
    }else if ([result isEqualToString:@"WrongPassword"]){
        UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"密码错误" message:@"请输入正确密码。忘记密码，请选择“找回密码”。" delegate:self cancelButtonTitle:@"找回密码" otherButtonTitles:@"重新输入密码", nil];
        [alertView2 setTag:ALERTVIEWTAG2];
        [alertView2 show];
    }else {
        UIAlertView *alertView3 = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"请输入注册用的手机或邮箱" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView3 setTag:ALERTVIEWTAG3];
        [alertView3 show];
    }
}

- (void)modifyUserMobileDeal{
    self.userName.text = NULL;
    self.password.text = NULL;
}

-(void)loginFailWarning
{
    [self indicatorActivity:FALSE];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"用户名或者密码错误，请重新登录。" delegate:nil cancelButtonTitle:@"放弃" otherButtonTitles:nil];
    alert.tag = 1;
    [alert show];
}

-(void)registerloginFailWarning
{
    [self indicatorActivity:FALSE];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"注册成功，服务器忙，请重新登录。" delegate:self cancelButtonTitle:@"重新登录" otherButtonTitles:nil];
    alert.tag = 100;
    [alert show];
}

-(void)loginOKAlert
{
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"您已登录成功。"];
}

-(void)loginOutAlert
{
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"您已退出成功。"];
}

-(IBAction)loginButtonTapped
{
    NSLog(@"login tapped");

    if([self.userName.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"请输入电子邮箱" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        alert.tag =2;
        [alert show];
        return;
    }
    
    if ([self.password.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"请输入密码" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        alert.tag =2;
        [alert show];
        return;
    }
    
    //[self.userName resignFirstResponder];
    [self.password resignFirstResponder];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *name = [self.userName.text lowercaseString];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"savedUser"];
    //todo not save pass
    [[NSUserDefaults standardUserDefaults] setObject:self.password.text forKey:@"savedPass"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [appDelegate.auth postDeviceInfo];
    
    //    self.loadingCoverView.hidden =NO;
    [self indicatorActivity:TRUE];
}

-(void)loginSuccessfully
{
    NSLog(@"loginSuccessfully");
    NSString *name = [Util getUsername];
    NSString *fNamne = [[NSUserDefaults standardUserDefaults] objectForKey:name];
    
    if (fNamne.length == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:name];
    }
    NSString* dailog = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginNewDailog"];
    if (dailog == nil || ![dailog isEqualToString:@"TRUE"]){
        NSLog(@"hidden");
        [self indicatorActivity:FALSE];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [self loginOKAlert];
        
        if (delegate && [delegate respondsToSelector:@selector(loginSuccessProcess:)])
        {
            [delegate performSelector:@selector(loginSuccessProcess:) withObject:self];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginNewDailog"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex == 0) {
        if (delegate && [delegate respondsToSelector:@selector(login:)]) {
            [delegate performSelector:@selector(login:) withObject:self];
        }
    } if (alertView.tag == ALERTVIEWTAG1 && buttonIndex == 0) {
        [self registerNew:nil];
    }else if((alertView.tag == ALERTVIEWTAG1 && buttonIndex == 1) || alertView.tag == ALERTVIEWTAG3){
        self.userName.text = nil;
        self.password.text = nil;
        [self.userName becomeFirstResponder];
    }else if (alertView.tag == ALERTVIEWTAG2 && buttonIndex == 0 ){
        self.isInputAccount = YES;
        [self forgotPass:nil];
    }else if (alertView.tag == ALERTVIEWTAG2 && buttonIndex == 1){
        self.password.text = nil;
        [self.password becomeFirstResponder];
    }
}

#pragma mark - UITextFieldView Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (isBtnPress) {
        isBtnPress = FALSE;
        return;
    }
    
    if (textField == self.userName && self.userName.text.length > 0) {
        if (![Strings validEmail:self.userName.text] && ![Strings phoneNumberJudge:self.userName.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:REGISTER_EMAIL_FORMAT delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
            [alert show];
            
            [self.userName setText:nil];
            [self.password setText:nil];
            [self performSelector:@selector(textFieldBecomeFirstResponder:) withObject:self.userName afterDelay:0.5];
            return;
        }
    }
}

- (void)textFieldBecomeFirstResponder:(UITextField *)textField{
    [textField becomeFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.userName) {
        [self performSelector:@selector(textFieldBecomeFirstResponder:) withObject:self.password afterDelay:0.5];
    }else if (textField == self.password){
        [self.view endEditing:YES];
        [self loginButtonTapped];
    }
    
    return YES;
}

- (void)indicatorActivity:(BOOL)isStart{
    if (isStart) {
        self.indicator.hidden = NO;
        [self.indicator startAnimating];
    }else{
        self.indicator.hidden = YES;
        [self.indicator stopAnimating];
    }
}

@end
