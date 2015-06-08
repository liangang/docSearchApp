//
//  LoginController.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-24.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "LoginController.h"
#import "imdSearchAppDelegate.h"
#import "imdSearchAppDelegate_iPhone.h"
#import "Strings.h"
#import "LoginSelectController.h"
#import "IPhoneHeader.h"
#import "LoginActiveController.h"
#import "MyDataBaseSql.h"
#import "FindPWDAccountInfoViewController.h"

#define ALERTVIEWTAG1 2013102201
#define ALERTVIEWTAG2 2013102202
#define ALERTVIEWTAG3 2013102203

@interface LoginController (){
    BOOL keyboardIsShow;
}

@property (assign, nonatomic) BOOL isInputAccount;
@property (strong, nonatomic) UITextField *currentField;

@end

@implementation LoginController;

@synthesize registerBtn, forgotPasswordBtn, userText, userPassword;
@synthesize alertView;
@synthesize delegate;
@synthesize sourceCtr;
@synthesize scrollView = _scrollView;
@synthesize indicator = _indicator;
@synthesize viewC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        alertView = [[UIAlertView alloc]initWithTitle:LOGIN_ALERT_TITLE message:LOGIN_ALERT_MESSAGE delegate:self cancelButtonTitle:LOGIN_ALERT_CANCEL otherButtonTitles:nil];
        
        self.isInputAccount = FALSE;
        keyboardIsShow = FALSE;
        self.navigationController.navigationBar.hidden = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) dealloc{}

#pragma mark - IBAction
-(IBAction)login:(id)sender
{
    [self.view endEditing:YES];
    
    if  ([self.userText.text isEqualToString:@""]) {
        [self.userText becomeFirstResponder];
        return;
    }
    
    if  ([self.userPassword.text isEqualToString:@""]) {
        [self.userPassword becomeFirstResponder];
        return;
    }
    
    if (![Strings validEmail:self.userText.text] && ![Strings phoneNumberJudge:self.userText.text]) {
        [alertView setMessage:REGISTER_EMAIL_FORMAT];
        [alertView show];
        [self.userText becomeFirstResponder];
        return;
    }
    
    //temp code,login anyway
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    NSString *name = [self.userText.text lowercaseString];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"savedUser"];
    [[NSUserDefaults standardUserDefaults] setObject:self.userPassword.text forKey:@"savedPass"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [appDelegate.myAuth doLogin:self fromRegister:NO];
    
    [self.indicator startAnimating];
}

-(IBAction)closeView:(id)sender
{
    self.userPassword.text = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)registerNew:(id)sender
{
    LoginSelectController* newUser = [[LoginSelectController alloc] initWithNibName:@"LoginSelectController" bundle:nil];
    newUser.type = RegisterSelect;
    [self.navigationController pushViewController:newUser animated:YES];
}

-(IBAction)forgotPassword:(id)sender{
    self.userPassword.text = nil;
    
    FindPWDAccountInfoViewController *viewController = [[FindPWDAccountInfoViewController alloc] init];
    viewController.type = ViewTypeFindPWD;
    viewController.userAccount = self.isInputAccount ? self.userText.text : @"";
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    userPassword.secureTextEntry = YES;
    userPassword.delegate = self;
    [TableViewFormatUtil setNavigationBar:self.navigationController normal:@"" highlight:@"" barBg:@""];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginInfoDeal:) name:USERLOGININFO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findUserPasswordShow:) name:@"FindUserPassword" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearUserInfoDeal:) name:@"modifyMobileSuccess" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [TableViewFormatUtil backBarButtonItemInfoModify:self.navigationItem];
    
    //键盘弹起的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:self.view.window];
    //键盘隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    UITapGestureRecognizer *singleOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddKeyboard:)];
    singleOne.numberOfTouchesRequired = 1;    //触摸点个数，另作：[singleOne setNumberOfTouchesRequired:1];
    singleOne.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:singleOne];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.currentField = textField;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.userText && self.userText.text && ![self.userText.text isEqualToString:@""]) {
        if (![Strings validEmail:self.userText.text] && ![Strings phoneNumberJudge:self.userText.text]) {
            UIAlertView *alertView3 = [[UIAlertView alloc] initWithTitle:LOGIN_ALERT_TITLE message:REGISTER_EMAIL_FORMAT delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView3 setTag:ALERTVIEWTAG3];
            [alertView3 show];
            return;
        }
    }
    
    self.currentField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == userText) {
        [self.userPassword becomeFirstResponder];
    }else if (textField == userPassword){
        [self login:nil];
    }
    
    return YES;
}

#pragma mark - hidd keyborad 
- (void)hiddKeyboard:(UITapGestureRecognizer *)sender{
    [self.view endEditing:YES];
}

#pragma mark - find user password
- (void)findUserPasswordShow:(NSNotification *)notification{
    self.userPassword.text = Nil;
    
    NSString *account = [notification object];
    
    FindPWDAccountInfoViewController *viewController = [[FindPWDAccountInfoViewController alloc] init];
    viewController.type = ViewTypeFindPWD;
    viewController.userAccount = account;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)userLoginInfoDeal:(NSNotification *)notification{
    NSString *result = [notification object];
    [self.indicator stopAnimating];
    
    if ([result isEqualToString:@"AccountNotExist"]) {
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"帐号不存在" message:[NSString stringWithFormat:@"未在系统中找到%@帐号，请输入正确帐号或注册新帐号。",self.userText.text] delegate:self cancelButtonTitle:@"注册新帐号" otherButtonTitles:@"重新输入帐号", nil];
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

- (void)clearUserInfoDeal:(NSNotification *)notification{
    [self.userText setText:nil];
    [self.userPassword setText:nil];
}

#pragma mark - ASIHTTPRequest delegate
-(void) userLoginFinished:(BOOL)animated
{
    [self.indicator stopAnimating];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    if ([self.title isEqualToString:MYFAVORITE_CN]) {
        imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
        appDelegate.myTabBarController.selectedIndex = 1;
        UINavigationController* favsNav = [appDelegate.myTabBarController.viewControllers objectAtIndex:1];
        [[favsNav.viewControllers objectAtIndex:0] sync];
        [[favsNav.viewControllers objectAtIndex:0] refresh];
    }
    if ([self.title isEqualToString:SEARCHMGR_CN]){
        imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
        appDelegate.myTabBarController.selectedIndex = 2;
        
    }
    NSMutableArray *mut = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:Alert_Count] ];
    if ([mut count]) {
        BOOL isExitName = NO;
        for (int i = 0; i<[mut count]; i++) {
            if ([[[mut objectAtIndex:i] objectForKey:SAVED_USER] isEqualToString:[UserManager userName]]) {
                isExitName = NO;
                [UIApplication sharedApplication].applicationIconBadgeNumber = [[[mut objectAtIndex:i] objectForKey:Array_ID] count];
                break;
            }else {
                isExitName = YES;
            }
        }
        if (isExitName) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:[UserManager userName] forKey:SAVED_USER];
            NSMutableArray *mut2 = [[NSMutableArray alloc]init];
            [dic setObject:mut2 forKey:Array_ID];
            [mut addObject:dic];
            [[NSUserDefaults standardUserDefaults] setObject:mut forKey:Alert_Count];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else {
        NSMutableArray *mut = [[NSMutableArray alloc]init];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[UserManager userName] forKey:SAVED_USER];
        NSMutableArray *mut2 = [[NSMutableArray alloc]init];
        [dic setObject:mut2 forKey:Array_ID];
        [mut addObject:dic];
        [[NSUserDefaults standardUserDefaults] setObject:mut forKey:Alert_Count];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.userPassword.text = nil;
    NSString *name = [UserManager userName];
    NSString *fNamne = [[NSUserDefaults standardUserDefaults] objectForKey:name];
    if (fNamne.length == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:name];
    }
    
    [self dismissViewControllerAnimated:animated completion:Nil];
}

-(void) userLoginFailed:(UIViewController *)viewController
{
    [self.indicator stopAnimating];
    
    self.viewC = viewController;
}

-(void) requestFailed:(ASIHTTPRequest *)request
{
    [self.indicator stopAnimating];
    
    UIAlertView* networkAlert = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
    [networkAlert show];
}

#pragma mark UIKeyboard Notification target
//键盘弹起后处理scrollView的高度使得textfield可见
-(void)keyboardDidShow:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    CGSize ksize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect textFieldRect = [self.userPassword frame];
    CGFloat changeHeight = ksize.height - (self.view.frame.size.height - textFieldRect.origin.y - textFieldRect.size.height);
    CGFloat change = changeHeight > 0 ? changeHeight : 0;
    
    [UIView animateWithDuration:0 animations:^(){
        [self.scrollView setContentOffset:CGPointMake(0, change)];
    }];
}

//键盘隐藏后处理scrollview的高度，使其还原为本来的高度
-(void)keyboardDidHide:(NSNotification *)notification{
    [UIView animateWithDuration:0 animations:^(){
        [self.scrollView setContentOffset:CGPointZero];
    }];
}

- (void)alertView:(UIAlertView *)alertView_ clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView_.message isEqualToString:@"登录失败请重新登录"]&&buttonIndex == 0) {
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showLoginView:self.viewC title:IMD_CN];
    }
    
    if (alertView_.tag == ALERTVIEWTAG1 && buttonIndex == 0) {
        
        [self registerNew:nil];
        
    }else if((alertView_.tag == ALERTVIEWTAG1 && buttonIndex == 1) || alertView_.tag == ALERTVIEWTAG3){
        self.userText.text = nil;
        self.userPassword.text = nil;
        [self.userText becomeFirstResponder];
        
    }else if (alertView_.tag == ALERTVIEWTAG2 && buttonIndex == 0 ){
        self.isInputAccount = YES;
        [self forgotPassword:nil];
    }else if (alertView_.tag == ALERTVIEWTAG2 && buttonIndex == 1){
        self.userPassword.text = nil;
        [self.userPassword becomeFirstResponder];
    }
}
@end
