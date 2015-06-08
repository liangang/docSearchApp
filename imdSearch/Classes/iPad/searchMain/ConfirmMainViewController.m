//
//  ConfirmMainViewController.m
//  imdSearch
//
//  Created by ding zhihong on 12-4-24.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "ConfirmMainViewController.h"
#import "phoneActivationViewController.h"
#import "EmailActivationViewController.h"
#import "SaveKey.h"
#import "PadText.h"
#import "Url_iPad.h"
#import "ASIFormDataRequest.h"
#import "imdSearchAppDelegate.h"
@interface ConfirmMainViewController ()

@end

@implementation ConfirmMainViewController

@synthesize info, mobileConfirmed, mobileConfirmButton;
@synthesize emailConfirmed, emailConfirmButton;

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
    NSString* mobileState = [[NSUserDefaults standardUserDefaults] objectForKey:SaveMobileConfirmState];
    NSString* emailState = [[NSUserDefaults standardUserDefaults] objectForKey:SaveEmailConfirmState];
    NSString* email = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
    NSString* mobile = [[NSUserDefaults standardUserDefaults] objectForKey:SaveUserMobile];
    
    if (mobileState != nil && [mobileState isEqualToString:@"true"]) {
        NSLog(@"mobileState is true");
        mobileConfirmed.hidden = NO;
        mobileConfirmButton.enabled = false;
    } else {
        NSLog(@"mobileState is false");
        mobileConfirmed.hidden = YES;
        mobileConfirmButton.enabled = true;
    }
    
    if (emailState != nil && [emailState isEqualToString:@"true"]) {
        NSLog(@"emailState is true");
        emailConfirmed.hidden = NO;
        emailConfirmButton.enabled = false;
    } else {
        NSLog(@"emailState is false");
        emailConfirmed.hidden = YES;
        emailConfirmButton.enabled = true;
    }
    
    if ([emailConfirmed isHidden] && [mobileConfirmed isHidden]) {
        
        [info setText:DOWNLOAD_DOC_MAXVALUE_BOTH_NEED_CONFIRM];
        
    } else if ([emailConfirmed isHidden] && ![mobileConfirmed isHidden]){
        
        [info setText:[NSString stringWithFormat:DOWNLOAD_DOC_MAXVALUE_EMAIL_NEED_CONFIRM, email]];
        
    } else if (![emailConfirmed isHidden] && [mobileConfirmed isHidden]){
        
        [info setText:DOWNLOAD_DOC_MAXVALUE_MOBILE_NEED_CONFIRM];
        
    } else {
        [info setText:@"这是bug"];
    }
    
    [emailConfirmButton setTitle:email forState:UIControlStateNormal];
    [mobileConfirmButton setTitle:mobile forState:UIControlStateNormal];
    [emailConfirmButton.titleLabel sizeToFit];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.info = nil;
    self.mobileConfirmButton = nil;
    self.mobileConfirmed = nil;
    self.emailConfirmButton = nil;
    self.emailConfirmed = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)mobileConfirmTapped:(id)sender
{
    phoneActivationViewController* phoneActivationPage = [[phoneActivationViewController alloc] initWithNibName:@"phoneActivationViewController" bundle:nil];
    
    [self.navigationController pushViewController:phoneActivationPage animated:YES];
}

-(IBAction)emailConfirmTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[[emailConfirmButton titleLabel] text] forKey:SaveUserEmail];
    EmailActivationViewController* eavc = [[EmailActivationViewController alloc] initWithNibName:@"EmailActivationViewController" bundle:nil];
    eavc.httpRequest = [self sendEmail:eavc];
    [self.navigationController pushViewController:eavc animated:YES];
}

-(ASIHTTPRequest *)sendEmail:(UIViewController *)vc
{
    NSString* theUrl = [NSString stringWithFormat:@"http://%@/user/sendActiveEmail", CONFIRM_SERVER];
    
    NSLog(@"url =%@",theUrl);
    
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:theUrl]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    
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
    [userInfo setObject:@"generateCode" forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    request.delegate =vc;
    [request startAsynchronous];
    
    return request;
}

-(IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
