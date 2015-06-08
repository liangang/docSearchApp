//
//  phoneActivationViewController.m
//  imdSearch
//
//  Created by ding zhihong on 12-3-31.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "phoneActivationViewController.h"
#import "accountActivationViewController.h"
#import "ASIFormDataRequest.h"
#import "Url_iPad.h"
#import "url.h"
#import "Util.h"
#import "UrlRequest.h"
#import "PadText.h"
#import "imdSearchAppDelegate.h"
#import "NSObject+SBJSON.h"

#import "ImdAppBehavior.h"
#import "Util.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
@implementation phoneActivationViewController

@synthesize sendVerifyCode;
@synthesize phoneNumber;
@synthesize mobile;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isActive = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    sendVerifyCode.enabled = false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    sendVerifyCode = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.phoneNumber.text = self.originMobile;
    self.sendVerifyCode.enabled = self.isActive;
}

- (IBAction)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)activeButtonTapped:(id)sender
{
    NSString *textOutput = [self.phoneNumber.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    BOOL numberJudge = [Util phoneNumberJudge:textOutput];
    if (numberJudge) {
        self.mobile = textOutput;
        [self checkMobileActivity];
    } else {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入正确的手机号码" delegate:nil cancelButtonTitle:@"重新输入" otherButtonTitles:nil];
        
        [alert show];
    }
    return;
}

-(void)textDidChange:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self updateTextField];
    [self isButtonClick];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}
-(void)isButtonClick
{
    if ([self.phoneNumber.text length]>13) {
        NSString *subStr = [self.phoneNumber.text substringToIndex:13];
        NSLog(@"substring is :%@",subStr);
        self.phoneNumber.text = subStr;
        [self.phoneNumber reloadInputViews];
    }
    
    if (self.phoneNumber.text.length  < 13 )
        self.sendVerifyCode.enabled = NO;
    else{
        self.sendVerifyCode.enabled = YES;
    }
    
}

- (void)updateTextField
{
    //去掉string中的“－”
    NSString *outputString = [self.phoneNumber.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    //string转化为array
    //[self.mobileTF release];
    NSMutableArray *textArray = [[NSMutableArray alloc]init];
    
    for(int i = 0;i < [outputString length];i++)
    {
        NSRange range = NSMakeRange(i, 1);
        if(i == 3 || i == 7)
        {
            [textArray addObject:@"-"];
        }
        [textArray addObject:[outputString substringWithRange:range]];
        
    }
    //array转化回textString
    NSString *textOutput = [[NSString alloc]init];
    for(int i = 0;i < [textArray count];i++)
    {
        textOutput = [textOutput stringByAppendingFormat:[textArray objectAtIndex:i]];
    }
    self.phoneNumber.text = textOutput;
}

#pragma mark - Button Action
- (void)checkMobileActivity
{
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setObject:
     [NSString stringWithFormat:@"%@", self.mobile] forKey:
     KEY_CONFIRM_MOBILE];
    
    NSString* theUrl = [NSString stringWithFormat:
                        @"http://%@/validate/mobile/requestsms", CONFIRM_SERVER];
    
    NSLog(@"url =%@",theUrl);
    NSLog(@"dict =%@",data);
    
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:theUrl]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    [request setRequestMethod:POST];
    
    [request setPostValue:[data objectForKey:KEY_CONFIRM_MOBILE] forKey:@"mobile"];
    
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
        accountActivationViewController* aavc = [[accountActivationViewController alloc] initWithNibName:@"accountActivationViewController" bundle:nil];
        aavc.mobileNumber = self.mobile;
        [self.navigationController pushViewController:
         aavc animated:YES];
    } else if([[resultsJson objectForKey:@"status"] isEqualToString:@"false"]) {
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

@end
