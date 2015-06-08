//
//  LoginActiveController.m
//  imdSearch
//
//  Created by Huajie Wu on 12-3-28.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "LoginActiveController.h"
#import "IPhoneHeader.h"
#import "imdSearchAppDelegate_iPhone.h"
#import "LoginMobileActive.h"
#import "LoginEmailActive.h"
#import "ImdAppBehavior.h"
#import "Util.h"
@interface LoginActiveController (startToUse)

- (void)startUse:(id)sender;
- (void)dismissview:(id)sender;
- (void)setBarButtonItems;
@end



@implementation LoginActiveController
@synthesize emailActiveBtn = _emailActive, mobileActiveBtn = _mobileActive;

@synthesize isEmailActive, isMobileActive, fromRegister;

@synthesize mobileActiveArrowBtn = _mobileActiveArrowBtn, emailActiveArrowBtn = _emailActiveArrowBtn;
@synthesize hintViewFromRegister = _hintViewFromRegister, hintViewNotFromRegister = _hintViewNotFromRegister;

@synthesize delegate;
@synthesize emailLable;
- (void) dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = ACTIVE_ACCOUNT;
        [self.navigationItem setBackBarButtonItem:nil];
        isEmailActive = NO;
        isMobileActive = NO;
        fromRegister = YES;
    }
    return self;
}

- (void)setBarButtonItems
{
    if (!self.fromRegister) {
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:TEXT_CANCEL style:UIBarButtonItemStylePlain target:self action:@selector(dismissview:)];
        [self.navigationItem setRightBarButtonItem:nil];
        [self.navigationItem setLeftBarButtonItem:cancel];
    } else {
        UIBarButtonItem* go = [[UIBarButtonItem alloc] initWithTitle:REGISTER_START_USE style:UIBarButtonItemStylePlain target:self action:@selector(startUse:)];
        [self.navigationItem setRightBarButtonItem:go];
        [self.navigationItem setLeftBarButtonItem:nil];
        [self behavior:REGISTER_START_USE];
    }
}

- (void)dismissview:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)startUse:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    [appDelegate.myTabBarController setSelectedIndex:0];
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
    // Do any additional setup after loading the view from its nib.
    [self behavior:@"viewDidLoad"];
    
    [self.mobileActiveBtn setTitle:ACTIVE_ACTIVED forState:UIControlStateDisabled];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"getUserInfo" forKey:@"key"];
    
    _hintViewFromRegister = [TableViewFormatUtil initActiveHintView:ACTIVE_ACCOUNT_LABEL lines:3];
    [self.view addSubview:_hintViewFromRegister];
    _hintViewNotFromRegister = [TableViewFormatUtil initActiveHintView:ACTIVE_EMAIL_LABEL lines:2];
    [self.view addSubview:_hintViewNotFromRegister];
    [self emailModelHiddenWithFlag:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBarButtonItems];
    [UrlRequest send:[ImdUrlPath getUserInfo] delegate:self];
    self.emailActiveBtn.enabled = !self.isEmailActive;
    self.mobileActiveBtn.enabled = !self.isMobileActive;
    
    
    self.hintViewFromRegister.hidden = NO;
    self.hintViewNotFromRegister.hidden = YES;
    if (self.isEmailActive && !self.isMobileActive) {
        [self mobileActive:nil];
    } else if (!self.isEmailActive && self.isMobileActive) {
        self.hintViewFromRegister.hidden = YES;
        self.hintViewNotFromRegister.hidden = NO;
    }
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

-(IBAction)mobileActive:(id)sender
{
    LoginMobileActive* mobileActive = [[LoginMobileActive alloc] init];
    [self.navigationController pushViewController:mobileActive animated:YES];
    [self behavior:@"mobileActive"];
    mobileActive.isLevel1 = YES;
    mobileActive.parent = self;
    if (mobileN.length > 0) {
        //string转化为array
        //[self.mobileTF release];
        NSMutableArray *textArray = [[NSMutableArray alloc]init];
        
        for(int i = 0;i < [mobileN length];i++)
        {
            NSRange range = NSMakeRange(i, 1);
            if(i == 3 || i == 7)
            {
                [textArray addObject:@"-"];
            }
            [textArray addObject:[mobileN substringWithRange:range]];
            
        }
        //array转化回textString
        NSString *textOutputs = [[NSString alloc]init];
        for(int i = 0;i < [textArray count];i++)
        {
            textOutputs = [textOutputs stringByAppendingFormat:@"%@",[textArray objectAtIndex:i]];
        }
        
        mobileActive.mobileTF.text = textOutputs;
    }
    [mobileActive updateButton];
}

-(IBAction)emailActive:(id)sender
{
    [self behavior:@"emailActive"];
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:@"sendActiveEmail" forKey:@"type"];
    
    [UrlRequest sendWithTokenWithUserInfo:[ImdUrlPath emailActiveUrl] userInfo:userInfo delegate:self];
    self.view.hidden = NO;
}

#pragma mark Asy Request
-(void)requestFinished:(ASIHTTPRequest *)request
{
    self.view.hidden = NO;
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    NSDictionary *info = [request userInfo];
    NSString* rType = [info objectForKey:@"key"];
    if ([rType isEqualToString:@"getUserInfo"]) {
        NSLog(@"resultsJson===%@",resultsJson);
        if (resultsJson) {
            mobileN = [[resultsJson objectForKey:@"info"] objectForKey:@"mobile"];
            emailN = [[resultsJson objectForKey:@"info"] objectForKey:@"email"];
            if (mobileN.length > 0) {
                [self.mobileActiveBtn setTitle:mobileN forState:0];
            } else {
                [self.mobileActiveBtn setTitle:@"通过手机激活" forState:0];
            }
            if (emailN.length > 0) {
                [self emailModelHiddenWithFlag:NO];
                [self.emailActiveBtn setTitle:emailN forState:0];
            }else {
                [self emailModelHiddenWithFlag:YES];
            }
        }
        
    }else {
        if ([[resultsJson objectForKey:@"status"] isEqualToString:@"true"]) {
            LoginEmailActive* email = [[LoginEmailActive alloc] init];
            email.fromRegister = self.fromRegister;
            [self.navigationController pushViewController:email animated:YES];
        } else {
            UIAlertView* alert = [[ UIAlertView alloc] initWithTitle:ACTIVE_EMAIL message:[resultsJson objectForKey:@"message"] delegate:self cancelButtonTitle:TEXT_CONFIRM otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    self.view.hidden = NO;
    NSLog(@"request failed %@",[request responseString]);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:TEXT_CONFIRM otherButtonTitles:nil];
    [alert show];
}

- (void)behavior:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:REGISTER_SUCCESS paramJson:json];
}

- (void)emailModelHiddenWithFlag:(BOOL)isHidden{
    self.emailLable.hidden = isHidden;
    self.emailActiveArrowBtn.hidden = isHidden;
    self.emailActiveBtn.hidden = isHidden;
    self.emilBackgroundView.hidden = isHidden;
}

@end
