//
//  LoginEmailActive2.m
//  imdSearch
//
//  Created by Huajie Wu on 12-4-19.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "LoginEmailActive2.h"
#import "IPhoneHeader.h"

@implementation LoginEmailActive2

@synthesize phoneCall = _phoneCall, emailActive = _emailActive;
@synthesize img;
- (void) dealloc
{}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = TEXT_HELP;
    }
    return self;
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
    
    self.navigationItem.backBarButtonItem = nil;
    // Do any additional setup after loading the view from its nib.
    [self.emailActive setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_NORMAL] forState:UIControlStateNormal];
    [self.emailActive setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_DISABLE] forState:UIControlStateDisabled];
    [self.emailActive setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_HIGHLIGHT] forState:UIControlStateSelected];
    [self.emailActive setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_HIGHLIGHT] forState:UIControlStateHighlighted];
    
    [self.emailActive setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.emailActive setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.emailActive setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.emailActive setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [self.emailActive setTitle:ACTIVE_RESEND_EMAIL forState:UIControlStateNormal];
    [self.emailActive setTitle:ACTIVE_RESEND_EMAIL forState:UIControlStateDisabled];
    [self.emailActive setTitle:ACTIVE_RESEND_EMAIL forState:UIControlStateSelected];
    [self.emailActive setTitle:ACTIVE_RESEND_EMAIL forState:UIControlStateHighlighted];
    if (iPhone5) {
        [img setImage:[UIImage imageNamed:@"img-help-info-568h"]];
        img.frame = CGRectMake(0, 0, 320, 506);
    }
}
- (void)popBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

-(IBAction)doEmailActive:(id)sender
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:@"sendActiveEmail" forKey:@"type"];
    
    [UrlRequest sendWithTokenWithUserInfo:[ImdUrlPath emailActiveUrl] userInfo:userInfo delegate:self];
}

-(IBAction)doCall:(id)sender
{
    NSString* title = [NSString stringWithFormat:@"%@ %@", SETTINGS_CALL_TITLE, IMD_PNONE];
    UIActionSheet* as = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:SETTINGS_CALL_CANCEL destructiveButtonTitle:SETTINGS_CALL_CALL otherButtonTitles: nil];
    [as showInView:self.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString* tel = [NSString stringWithFormat:@"tel:%@", IMD_PNONE];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
    }
}


#pragma mark Asy Request
-(void)requestFinished:(ASIHTTPRequest *)request
{
    self.view.hidden = NO;
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    if ([[resultsJson objectForKey:@"status"] isEqualToString:@"true"]) {
        UIAlertView* alert = [[ UIAlertView alloc] initWithTitle:ACTIVE_EMAIL message:[resultsJson objectForKey:@"message"] delegate:self cancelButtonTitle:TEXT_CONFIRM otherButtonTitles:nil];
        [alert show];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];
    } else {
        UIAlertView* alert = [[ UIAlertView alloc] initWithTitle:ACTIVE_EMAIL message:[resultsJson objectForKey:@"message"] delegate:self cancelButtonTitle:TEXT_CONFIRM otherButtonTitles:nil];
        [alert show];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:TEXT_CONFIRM otherButtonTitles:nil];
    [alert show];
}

@end
