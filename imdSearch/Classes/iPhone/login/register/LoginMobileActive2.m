//
//  LoginMobileActive2.m
//  imdSearch
//
//  Created by Huajie Wu on 12-3-30.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "LoginMobileActive2.h"
#import "IPhoneHeader.h"
#import "imdSearchAppDelegate_iPhone.h"

@implementation LoginMobileActive2

@synthesize codeTF = _codeTF;
@synthesize activeAccount = _activeAccount;
@synthesize scroll = _scroll;
@synthesize alertView = _alertView;
@synthesize isParentLevel1;
@synthesize timerLabel = _timerLabel, hintLabel = _hintLabel;
@synthesize myTimer = _myTimer;
@synthesize parent;
@synthesize mobileNumber;

-(void) dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _alertView = [[UIAlertView alloc]initWithTitle:IMD_DOC message:ACTIVE_MOBILE delegate:self cancelButtonTitle:ALERT_CONFIRM otherButtonTitles:nil];
        
    }
    return self;
}

-(void) popBack
{
    [self.myTimer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (IBAction)submitActiveAccount:(id)sender
{
    if (self.codeTF.text.length == 0) {
        [self.codeTF becomeFirstResponder];
        return;
    }
    self.activeAccount.enabled = NO;
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    
    [data setObject:self.codeTF.text forKey:@"code"];
    [data setObject:mobileNumber forKey:@"mobile"];
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:@"activeCode" forKey:@"type"];
    
    [UrlRequest sendPostWithUserInfo:[ImdUrlPath mobileActiveUrl] data:data userInfo:userInfo delegate:self];
    
    //[self.myTimer invalidate];
    [self.codeTF resignFirstResponder];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submitActiveAccount:self.activeAccount];
    return YES;
}

#pragma mark Asy Request

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    
    if ([[resultsJson objectForKey:@"status"] isEqualToString:@"true"]) {
        [self.myTimer invalidate];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];
        NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
        imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
        if ([Strings validEmail:user]) {
            
        }else
        {
            [appDelegate.myAuth doLogin:self fromRegister:YES];
        }
        
        NSLog(@"mobile%@",mobileNumber);
        [[NSUserDefaults standardUserDefaults] setObject:mobileNumber forKey:@"savedUser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [appDelegate.myTabBarController setSelectedIndex:0];
        
        if ([self.parent.parent.delegate respondsToSelector:@selector(MobileActiveSuccess:)])
            [self.parent.parent.delegate MobileActiveSuccess:self.parent.parent];
        
        [[TKAlertCenter defaultCenter] postAlertWithMessage:ACTIVE_CODE_SUCCESS];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"验证码错误" message:@"您输入的验证码错误或已过期，请重新输入验证码，或重新获取验证码。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:@"重新获取", nil];
        alertView.tag = 20131111;
        [alertView show];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    self.alertView.title = REQUEST_FAILED_TITLE;
    self.alertView.message = REQUEST_FAILED_MESSAGE;
    [self.alertView show];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [TableViewFormatUtil setContentBackGround:self.view image:IMG_BG_SIGNIN];
    
    [self.activeAccount setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_NORMAL] forState:UIControlStateNormal];
    [self.activeAccount setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_DISABLE] forState:UIControlStateDisabled];
    [self.activeAccount setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_HIGHLIGHT] forState:UIControlStateSelected];
    [self.activeAccount setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_HIGHLIGHT] forState:UIControlStateHighlighted];
    
    [self.activeAccount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.activeAccount setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.activeAccount setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.activeAccount setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [self.activeAccount setTitle:ACTIVE_SUBMIT_CODE forState:UIControlStateNormal];
    [self.activeAccount setTitle:ACTIVE_SUBMIT_CODE forState:UIControlStateDisabled];
    [self.activeAccount setTitle:ACTIVE_SUBMIT_CODE forState:UIControlStateSelected];
    [self.activeAccount setTitle:ACTIVE_SUBMIT_CODE forState:UIControlStateHighlighted];
    
    self.activeAccount.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self.codeTF becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.codeTF setText:nil];
    _startSeconds = ACTIVE_MOBILE_CODE_TIMER;
    self.timerLabel.text = [NSString stringWithFormat:@"%d", _startSeconds];
    
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    
    if (self.isParentLevel1) {
        self.title = ACTIVE_MOBIlE_TITLE;
    } else {
        self.title = ACTIVE_FAST_MOBIlE_TITLE;
    }
}

-(void)textDidChange:(id)sender
{
    if ([self.codeTF.text length]>6) {
        NSString *subStr = [self.codeTF.text substringToIndex:6];
        NSLog(@"substring is :%@",subStr);
        self.codeTF.text = subStr;
        [self.codeTF reloadInputViews];
    }
    
    if (self.codeTF.text.length  < 6 )
        self.activeAccount.enabled = NO;
    else{
        self.activeAccount.enabled = YES;
    }
}

- (void) countDown:(NSTimer *) timer
{
    self.timerLabel.text = [NSString stringWithFormat:@"%d", --_startSeconds];
    
    if (_startSeconds <= 0) {
        [self.myTimer invalidate];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:ACTIVE_SUBMIT_CODE message:ACTIVE_CODE_EXPIRED delegate:self cancelButtonTitle: TEXT_CONFIRM otherButtonTitles: nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView != self.alertView && buttonIndex == 0) {
        if ([alertView.message isEqualToString:ACTIVE_CODE_EXPIRED])
            [self popBack];
        else {
            [self.codeTF setText:nil];
            self.activeAccount.enabled = NO;
            [self.codeTF becomeFirstResponder];
        }
    } if (alertView == self.alertView) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:ACTIVE_CODE_SUCCESS];
    }else if (alertView.tag == 20131111){
        if (buttonIndex == 0) {
            self.codeTF.text = nil;
            [self.codeTF becomeFirstResponder];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.codeTF.text.length < 1)
        self.activeAccount.enabled = NO;
    else
        self.activeAccount.enabled = YES;
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.activeAccount.enabled = NO;
    return YES;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
