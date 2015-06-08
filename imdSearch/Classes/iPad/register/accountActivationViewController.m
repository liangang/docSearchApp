//
//  accountActivationViewController.m
//  imdSearch
//
//  Created by ding zhihong on 12-3-31.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "accountActivationViewController.h"
#import "imdSearchAppDelegate.h"
#import "url.h"
#import "ASIFormDataRequest.h"
#import "PadText.h"
#import "Url_iPad.h"
#import "UrlRequest.h"

#import "ImdAppBehavior.h"
#import "Util.h"
#import "Strings.h"

@interface accountActivationViewController ()

@end

@implementation accountActivationViewController

@synthesize delegate;
@synthesize waitingActionTime;
@synthesize waitingTime, activeNumber;
@synthesize timeOver, confirmSuccess;
@synthesize mobileNumber;

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
    waitingActionTime = 360;
    canCountSecond = true;
    [self showWaitingTime];
    timeOver = [[UIAlertView alloc] initWithTitle:IMD_LABEL message:@"验证码失效, 请重新获取" delegate:self cancelButtonTitle:CMD_OK otherButtonTitles:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (confirmSuccess != nil) {
        confirmSuccess = nil;
    }
    if (timeOver != nil) {
        timeOver = nil;
    }
    canCountSecond = false;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)checkWaitingTime
{
    NSLog(@"Waiting:%i", waitingActionTime);
    if (waitingActionTime > 0) {
        waitingActionTime--;
        [self showWaitingTime];
    } else if(waitingActionTime == 0){
        NSLog(@"waitingActionTime = 0;");
        [timeOver show];
    }
}

- (void)showWaitingTime
{
    if (canCountSecond) {
        [waitingTime setText:[NSString stringWithFormat:@"%i", waitingActionTime]];
        [self performSelector:@selector(checkWaitingTime) withObject:nil afterDelay:1];
    }
}

- (IBAction)backButtonTapped:(id)sender
{
    canCountSecond = false;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)activeButtonTapped:(id)sender
{
    NSLog(@"activeButtonTapped");
    if (self.activeNumber.text.length == 0) {
        [self.activeNumber becomeFirstResponder];
        return;
    }
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setObject:[NSString stringWithFormat:@"%@", self.activeNumber.text] forKey:@"code"];
    
    NSString* theUrl = [NSString stringWithFormat:@"http://%@/validate/mobile/active", CONFIRM_SERVER];
    NSLog(@"url =%@",theUrl);
    NSLog(@"dict =%@",data);
    
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:theUrl]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    [request setRequestMethod:POST];
    
    [request setPostValue:[data objectForKey:@"code"] forKey:@"code"];
    [request setPostValue:self.mobileNumber forKey:@"mobile"];
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    //Create a cookie
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",CONFIRM_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"activeCode" forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    
    request.delegate =self;
    [request startAsynchronous];
    NSLog(@"startAsynchronous");
}

#pragma mark Asy Request
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"response:%@", [request responseString]);
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    
    //  if ([[resultsJson objectForKey:@"status"] isEqualToString:@"'success"]) {
    if ([[resultsJson objectForKey:@"status"] isEqualToString:@"true"]) {
        NSString* message = [resultsJson objectForKey:@"message"];
        NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
        if ([Strings validEmail:user]) {
            
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:@"TRUE" forKey:@"loginNewDailog"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [delegate performSelector:@selector(loginNew:) withObject:self];
        }
        confirmSuccess = [[UIAlertView alloc] initWithTitle:IMD_LABEL message:message delegate:self cancelButtonTitle:CMD_OK otherButtonTitles:nil];
        [confirmSuccess show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"验证码错误" message:@"您输入的验证码错误或已过期，请重新输入验证码，或重新获取验证码。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:@"重新获取", nil];
        alertView.tag = 20131111;
        [alertView show];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:IMD_LABEL message: ERROR_SUBMIT_INFO delegate:nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == confirmSuccess) {
        canCountSecond = false;
        [self dismissViewControllerAnimated:YES completion:NO];
    } else if(alertView == timeOver) {
        canCountSecond = false;
        [self.navigationController popViewControllerAnimated:YES];
    }else if (alertView.tag == 20131111){
        if (buttonIndex == 0) {
            self.activeNumber.text = nil;
            [self.activeNumber becomeFirstResponder];
        }else{
            canCountSecond = false;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}

@end
