//
//  LoginMobileActive.m
//  imdSearch
//
//  Created by Huajie Wu on 12-3-28.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "LoginMobileActive.h"
#import "IPhoneHeader.h"
#import "imdSearchAppDelegate_iPhone.h"
#import "TKAlertCenter.h"


@implementation LoginMobileActive

@synthesize scroll = _scroll;
@synthesize mobileTF = _mobileTF, activeCode = _activeCode;
@synthesize alertView = _alertView;
@synthesize activeStep2 = _activeStep2;
@synthesize isLevel1;
@synthesize parent;
@synthesize textOutput;
- (void)dealloc
{}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _alertView = [[UIAlertView alloc]initWithTitle:IMD_DOC message:ACTIVE_MOBILE delegate:self cancelButtonTitle:ALERT_CONFIRM otherButtonTitles:nil];
        
        _activeStep2 = [[LoginMobileActive2 alloc] init];
        _activeStep2.parent = self;
        self.isLevel1 = NO;
    }
    return self;
}

-(void) popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Button Action
- (IBAction)getCode:(id)sender
{
    self.activeCode.enabled = NO;
    self.textOutput = [self.mobileTF.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    BOOL numberJudge = [Strings phoneNumberJudge:textOutput];
    if (numberJudge) {
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        
        [data setObject:self.textOutput forKey:@"mobile"];
        
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:@"generateCode" forKey:@"type"];
        
        [UrlRequest sendPostWithUserInfo:[ImdUrlPath mobileActiveCodeUrl] data:data userInfo:userInfo delegate:self];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入正确的手机号码" delegate:nil cancelButtonTitle:@"重新输入" otherButtonTitles:nil];
        
        [alert show];
    }
    
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
    if ([self.mobileTF.text length]>13) {
        NSString *subStr = [self.mobileTF.text substringToIndex:13];
        NSLog(@"substring is :%@",subStr);
        self.mobileTF.text = subStr;
        [self.mobileTF reloadInputViews];
    }
    
    if (self.mobileTF.text.length  < 13 )
        self.activeCode.enabled = NO;
    else{
        self.activeCode.enabled = YES;
    }
    
}

- (void)updateTextField
{
    NSString *deviceType = [UIDevice currentDevice].localizedModel;
    NSLog(@"type: %@", deviceType);
    if (![deviceType isEqualToString:@"iPod touch"]) {
        //读取光标位置
        UITextRange *selectedRange = [self.mobileTF selectedTextRange];
        pos = [self.mobileTF offsetFromPosition:self.mobileTF.endOfDocument toPosition:selectedRange.start];
    }
    //去掉string中的“－”
    NSString *outputString = [self.mobileTF.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
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
    NSString *textOutputs = [[NSString alloc]init];
    for(int i = 0;i < [textArray count];i++)
    {
        textOutputs = [textOutputs stringByAppendingFormat:@"%@",[textArray objectAtIndex:i]];
    }
    self.mobileTF.text = textOutputs;
    if (![deviceType isEqualToString:@"iPod touch"]) {
        //改回光标位置
        UITextPosition *newPos = [self.mobileTF positionFromPosition:self.mobileTF.endOfDocument offset:pos];
        self.mobileTF.selectedTextRange = [self.mobileTF textRangeFromPosition:newPos toPosition:newPos];
    }
    
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self getCode:self.activeCode];
    return YES;
}

#pragma mark Asy Request
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    NSLog(@"%@",[request responseString]);
    self.activeStep2.isParentLevel1 = self.isLevel1;
    if ([[resultsJson objectForKey:@"status"] isEqualToString:@"true"]) {
        self.activeStep2.mobileNumber = textOutput;
        [self.navigationController pushViewController:self.activeStep2 animated:YES];
    } else if([[resultsJson objectForKey:@"status"] isEqualToString:@"false"]){
        
        self.alertView.message = [resultsJson objectForKey:@"message"];
        [self.alertView show];
    }
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
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
    
    [self.activeCode setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_NORMAL] forState:UIControlStateNormal];
    [self.activeCode setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_DISABLE] forState:UIControlStateDisabled];
    [self.activeCode setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_HIGHLIGHT] forState:UIControlStateSelected];
    [self.activeCode setBackgroundImage:[UIImage imageNamed:BTN_GET_CODE_HIGHLIGHT] forState:UIControlStateHighlighted];
    
    [self.activeCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.activeCode setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.activeCode setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.activeCode setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [self.activeCode setTitle:ACTIVE_GET_CODE forState:UIControlStateNormal];
    [self.activeCode setTitle:ACTIVE_GET_CODE forState:UIControlStateDisabled];
    [self.activeCode setTitle:ACTIVE_GET_CODE forState:UIControlStateSelected];
    [self.activeCode setTitle:ACTIVE_GET_CODE forState:UIControlStateHighlighted];
    
    self.activeCode.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.scroll.frame.size.height)];
}
- (void)updateButton
{
    if (self.mobileTF.text.length == 13) {
        self.activeCode.enabled = YES;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isLevel1) {
        UIView* hint = [TableViewFormatUtil initActiveHintView:ACTIVE_ACCOUNT_MOBLE_LABEL lines:2];
        [self.view addSubview:hint];
        
        self.title = ACTIVE_MOBIlE_TITLE;
    } else {
        UIView* hint2 = [TableViewFormatUtil initActiveHintView:ACTIVE_ACCOUNT_MOBLE_LABEL lines:2];
        [self.view addSubview:hint2];
        
        self.title = ACTIVE_FAST_MOBIlE_TITLE;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mobileTF becomeFirstResponder];
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
