//
//  settingDetailViewController.m
//  imdSearch
//
//  Created by 立纲 吴 on 12/25/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "settingDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "url.h"
#import "ASIFormDataRequest.h"
#import "PadText.h"
#import "Url_iPad.h"
#import "imdSearchAppDelegate.h"

#import "ImdAppBehavior.h"
#import "Util.h"

#define LEFT_SIDE 20
#define TOP_SIDE 60
#define WIDTH 500
#define HEIGHT 540

@implementation settingDetailViewController

@synthesize detailType,backButton,titleLabel,feedbackView,contactInfo;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)dealloc
{
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.backButton =nil;
    self.titleLabel =nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [self displayDetail];
}

-(void)displayDetail
{
    if(detailType == DETAIL_TYPE_ABOUT_US)
    {
        titleLabel.text = SETTING_ABOUT_US_LABEL;
        
        UIScrollView* scroll = [[UIScrollView alloc] initWithFrame: CGRectMake(LEFT_SIDE, TOP_SIDE, WIDTH, HEIGHT)];
        scroll.backgroundColor = [UIColor clearColor];
        [self.view addSubview:scroll];
        
        NSString* content = SETTING_ABOUT_US_CONTENT;
        
        CGSize sizeContent = [content sizeWithFont: [UIFont systemFontOfSize:17.0] constrainedToSize: CGSizeMake(WIDTH, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel* contentLabel = [[UILabel alloc] initWithFrame: CGRectMake(0,0,sizeContent.width,sizeContent.height)];
        
        contentLabel.text = content;
        contentLabel.font = [UIFont systemFontOfSize:17.0];
        contentLabel.numberOfLines = 0;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        contentLabel.backgroundColor = [UIColor clearColor];
        
        [scroll addSubview:contentLabel];
        scroll.contentSize =sizeContent;
    }
    
    if(detailType == DETAIL_TYPE_POLOCY) {
        titleLabel.text = SETTING_RESPONSIBLE_LABEL;
        UIScrollView* scroll = [[UIScrollView alloc] initWithFrame: CGRectMake(LEFT_SIDE, TOP_SIDE, WIDTH, HEIGHT)];
        scroll.backgroundColor =[UIColor clearColor];
        scroll.showsVerticalScrollIndicator = NO;
        [self.view addSubview:scroll];
        
        NSString* content = SETTING_RESPONSIBLE_CONTENT;
        
        CGSize sizeContent = [content sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:CGSizeMake(WIDTH, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel* contentLabel = [[UILabel alloc] initWithFrame: CGRectMake(0,0,sizeContent.width,sizeContent.height)];
        
        contentLabel.text = content;
        contentLabel.font = [UIFont systemFontOfSize:17.0];
        contentLabel.numberOfLines = 0;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        contentLabel.backgroundColor = [UIColor clearColor];
        
        [scroll addSubview:contentLabel];
        scroll.contentSize =sizeContent;
    }
    
    if(detailType == DETAIL_TYPE_FEEDBACK) {
        titleLabel.text = SETTING_FEEDBACK_LABEL;
        
        UILabel* aLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_SIDE, 54, 140, 50)];
        aLabel.text = FEEDBACK_CONTENT_LABEL;
        [self.view addSubview:aLabel];
        aLabel.backgroundColor =[UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 84 + 20 - 4, 540, 137)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        
        self.feedbackView = [[UIPlaceHolderTextView alloc] initWithFrame: CGRectMake(LEFT_SIDE+8, 84+20+8-4, WIDTH-16, 137-16)];
        self.feedbackView.backgroundColor =[UIColor clearColor];
        self.feedbackView.font =[UIFont systemFontOfSize:19.0f];
        
        self.feedbackView.placeholder = FEEDBACK_HINT_INFO;
        [self.view addSubview:self.feedbackView];
        
        UILabel* bLabel = [[UILabel alloc] initWithFrame: CGRectMake(LEFT_SIDE, 240, 140, 50)];
        bLabel.text = FEEDBACK_CONTACT_LABEL;
        [self.view addSubview:bLabel];
        bLabel.backgroundColor =[UIColor clearColor];
        
        UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(0, 300 - 16, 540, 46)];
        contactView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:contactView];
        
        self.contactInfo = [[UITextField alloc] initWithFrame: CGRectMake(LEFT_SIDE+8, 300+8-16, WIDTH-16, 46-16)];
        
        self.contactInfo.placeholder = FEEDBACK_CONTACT_HINT_INFO;
        self.contactInfo.font =[UIFont systemFontOfSize:19.0f];
        [self.view addSubview:self.contactInfo];
        
        UIButton* btnSubmit =[UIButton buttonWithType:UIButtonTypeCustom];
        [btnSubmit setTitle:SUBMIT_LABEL forState:UIControlStateNormal];
        [btnSubmit setTitleColor:APPDefaultColor forState:UIControlStateNormal];
        btnSubmit.titleLabel.font = [UIFont fontWithName:@"Palatino" size:15.0];
        
        [btnSubmit addTarget:self action:@selector(submitFeedback) forControlEvents:UIControlEventTouchUpInside];
        
        btnSubmit.frame = CGRectMake(540 - 8 - 58, 8, 58, 29);
        [self.view addSubview:btnSubmit];
    }
}

-(IBAction)back:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)requestFinished:(ASIHTTPRequest*)request
{
    NSLog(@"feedback ok %@",[request responseString]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"反馈建议成功提交" message: @"非常感谢您对睿医文献的理解和支持！" delegate:self cancelButtonTitle: @"确认" otherButtonTitles:nil];
    [alert show];
}

-(void)requestFailed:(ASIHTTPRequest*)request
{
    NSLog(@"feedback failde");
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:IMD_LABEL message: FEEDBACK_SUBMIT_FAILED_INFO delegate:nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0) {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}
-(void)submitFeedback
{
    if([self.feedbackView.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:IMD_LABEL message:FEEDBACK_CONTENT_NULL_INFO delegate:nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    NSString* appURL = [NSString stringWithFormat:FEEDBACK_URL, SEARCH_SERVER];
    NSLog(@"appURL %@",appURL);
    
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:appURL]];
    
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    [request setRequestMethod:POST];
    
    [request setPostValue:self.feedbackView.text forKey:FEEDBACK_KEY_CONTENT];
    [request setPostValue:self.contactInfo.text forKey:FEEDBACK_KEY_CONTACT];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* locationVersion = [infoDict objectForKey:@"CFBundleVersion"];
    [request setPostValue:[NSString stringWithFormat:@"iPad-%@",locationVersion] forKey:USER_AGENT];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:TOKEN_FORMAT, appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    if (token != nil && ![token isEqualToString:@""]) {
        [request addRequestHeader:@"Cookie" value:token];
    }
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:IMD_TOKEN forKey:NSHTTPCookieName];
    [properties setValue:
    [NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:FEEDBACK_PATH];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:REQUEST_FEEDBACK forKey:REQUEST_TYPE];
    [request setUserInfo:userInfo];
    
    request.delegate = self;
    [request startAsynchronous];
}

@end
