//
//  RegisterSuccessViewController.m
//  imdSearch
//
//  Created by ding zhihong on 12-3-31.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "RegisterSuccessViewController.h"
#import "SaveKey.h"
#import "phoneActivationViewController.h"
#import "EmailActivationViewController.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "ASIHTTPRequest.h"
#import "imdSearchAppDelegate.h"
#import "ASIFormDataRequest.h"
#import "Url_iPad.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "JSON.h"
@interface RegisterSuccessViewController ()
@property (strong, nonatomic) IBOutlet UIView *mailBackgroundView;

@end

@implementation RegisterSuccessViewController

@synthesize delegate;
@synthesize message, mailButton;
@synthesize mobileButton,mailLable,imgmailA;
@synthesize loadImageView;
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
    [self behavior:@"viewDidLoad"];
    // Do any additional setup after loading the view from its nib.
    NSString* msg = [[NSUserDefaults standardUserDefaults] objectForKey:
                     SaveTempMessage];
    NSLog(@"msg:%@", msg);
    [message setText:msg];
    
    loadImageView.hidden = NO;
    [self performSelector:@selector(requestGetInfo) withObject:self afterDelay:1.0];
}

-(void)requestGetInfo
{
    [self postUserInfo:[ImdUrlPath getUserInfo] userInfoDic:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)phoneActiveButtonTapped:(id)sender
{
    [self behavior:@"phoneActiveButtonTapped"];
    NSLog(@"touch phone Active Button");
    //[self loginNewDailog];
    
    phoneActivationViewController* phoneActivationPage = [[phoneActivationViewController alloc] initWithNibName:@"phoneActivationViewController" bundle:nil];
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
        
        phoneActivationPage.originMobile = textOutputs;
        phoneActivationPage.isActive = YES;
    }
    
    [self.navigationController pushViewController:phoneActivationPage animated:YES];
}

-(void)loginNewDailog
{
    [[NSUserDefaults standardUserDefaults] setValue:@"TRUE" forKey:@"loginNewDailog"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  [appDelegate.auth postAuthInfo:@"register"];
}

-(IBAction)mailActiveButtonTapped:(id)sender
{
    [self behavior:@"mailActiveButtonTapped"];
    NSLog(@"touch mail Active Button");
    
    [[NSUserDefaults standardUserDefaults] setObject:[[mailButton titleLabel] text] forKey:SaveUserEmail];
    EmailActivationViewController* eavc = [[EmailActivationViewController alloc] initWithNibName:@"EmailActivationViewController" bundle:nil];
    eavc.httpRequest = [self sendEmail:eavc];
    [self.navigationController pushViewController:eavc animated:YES];
}

-(ASIHTTPRequest *)sendEmail:(UIViewController *)vc
{
    NSString* theUrl = [NSString stringWithFormat:
                        @"http://%@/user/sendActiveEmail", CONFIRM_SERVER];
    
    NSLog(@"url =%@",theUrl);
    
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:theUrl]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    //Create a cookie
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
    
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"generateCode" forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    
    request.delegate =vc;
    [request startAsynchronous];
    return request;
}

-(IBAction)closeButtonTapped:(id)sender
{
    [self behavior:@"closeButtonTapped"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)behavior:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:REGISTER_SUCCESS paramJson:json];
}

#pragma mark Asy Request
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    NSDictionary *info = [request userInfo];
    NSString* rType = [info objectForKey:@"key"];
    if ([rType isEqualToString:@"getUserInfo"]) {
        loadImageView.hidden = YES;
        NSLog(@"resultsJson===%@",resultsJson);
        if (resultsJson) {
            mobileN = [[resultsJson objectForKey:@"info"] objectForKey:@"mobile"];
            emailN = [[resultsJson objectForKey:@"info"] objectForKey:@"email"];
            if (mobileN.length > 0) {
                [self.mobileButton setTitle:mobileN forState:0];
                [[NSUserDefaults standardUserDefaults] setObject:mobileN forKey:SaveUserMobile];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (emailN.length > 0) {
                self.mailLable.hidden = NO;
                self.mailButton.hidden = NO;
                self.imgmailA.hidden = NO;
                self.mailBackgroundView.hidden = NO;
                [self.mailButton setTitle:emailN forState:0];
            }else
            {
                self.imgmailA.hidden = YES;
                self.mailLable.hidden = YES;
                self.mailButton.hidden = YES;
                self.mailBackgroundView.hidden = YES;
            }
        }
        
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    self.loadImageView.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
    NSLog(@"fail............");
}

- (void)postUserInfo:(NSString *)url userInfoDic:(NSMutableDictionary *)dic
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    NSDictionary* userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:@"getUserInfo",@"key" ,nil];
    [request setUserInfo:userInfo];
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString* token = appDelegate.auth.imdToken;
    
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSLog(@"Token %@", token);
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    request.delegate = self;
    [request startAsynchronous];
}
@end
