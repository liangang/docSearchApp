//
//  EmailActivationViewController.m
//  imdSearch
//
//  Created by ding zhihong on 12-4-24.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "EmailActivationViewController.h"
#import "EmailReactivationViewController.h"
#import "PadText.h"
#import "SaveKey.h"
#import "UrlRequest.h"
@interface EmailActivationViewController ()

@end

@implementation EmailActivationViewController

@synthesize userEmail;
@synthesize httpRequest;
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
    NSString* email =
    [[NSUserDefaults standardUserDefaults] objectForKey:SaveUserEmail];
    if (email != nil && ![email isEqualToString:@""]) {
        [userEmail setText:email];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.userEmail = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)noEmailButtonTapped:(id)sender
{
    EmailReactivationViewController* ervc = [[EmailReactivationViewController alloc] initWithNibName:@"EmailReactivationViewController" bundle:nil];
    
    [self.navigationController pushViewController:
     ervc animated:YES];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:IMD_LABEL message:ERROR_SUBMIT_INFO delegate:nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
    [alert show];
}

@end
