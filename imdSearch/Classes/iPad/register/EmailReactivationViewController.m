//
//  EmailReactivationViewController.m
//  imdSearch
//
//  Created by ding zhihong on 12-4-24.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "EmailReactivationViewController.h"
#import "ASIFormDataRequest.h"
#import "imdSearchAppDelegate.h"
#import "UrlRequest.h"
#import "url.h"
#import "Url_iPad.h"
#import "PadText.h"
#import "SaveKey.h"

#import "ImdAppBehavior.h"
#import "Util.h"

@interface EmailReactivationViewController ()

@end

@implementation EmailReactivationViewController

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)closeButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)reSendEmailTapped:(id)sender
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
    
    request.delegate =self;
    [request startAsynchronous];
    NSLog(@"startAsynchronous");
    
}

#pragma mark Asy Request
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"response:%@", [request responseString]);
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    
    if ([[resultsJson objectForKey:@"status"] isEqualToString:@"true"]) {
        NSString* message = [resultsJson objectForKey:@"message"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:IMD_LABEL message:message delegate:self cancelButtonTitle:CMD_OK otherButtonTitles:nil];
        [alert show];
    } else {
        NSString* message = [resultsJson objectForKey:@"message"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:IMD_LABEL message:message delegate:nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
        [alert show];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:IMD_LABEL message:ERROR_SUBMIT_INFO delegate:nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
