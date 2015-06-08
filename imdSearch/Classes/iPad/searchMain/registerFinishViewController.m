///
//  registerFinishViewController.m
//  imdSearch
//
//  Created by 立纲 吴 on 1/11/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "url.h"
#import "registerFinishViewController.h"
#import "registerDetailsViewController.h"
#import "JSON.h"
#import "PadText.h"
#import "Url_iPad.h"
#import "SaveKey.h"
#import "RegisterSuccessViewController.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "Strings.h"
#import "UrlRequest.h"
#import "imdSearchAppDelegate.h"

@implementation registerFinishViewController

@synthesize delegate;
@synthesize fieldDepartment,fieldTitle,fieldHospital;
@synthesize leftButton,rightButton,titleLabel,successView,registerView;
@synthesize remarkWord,remarkRegister;
@synthesize hospitalId;
@synthesize isSelectHospital;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc
{
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self behavior:@"viewDidLoad"];
    
    [self.fieldDepartment becomeFirstResponder];
    
    registerSuccess =NO;
    
    [self.contentView.layer setBorderWidth:0.5f];
    [self.contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
}

- (void)viewDidUnload
{
    self.fieldTitle =nil;
    self.fieldDepartment =nil;
    self.fieldHospital =nil;
    
    self.successView =nil;
    self.registerView =nil;
    
    self.leftButton =nil;
    self.rightButton =nil;
    self.titleLabel =nil;
    
    self.remarkWord =nil;
    self.remarkRegister =nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    self.fieldTitle.text =  [[NSUserDefaults standardUserDefaults] objectForKey:KEY_REGISTER_TITLE];
    
    NSDictionary* n = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_REGISTER_DEPARTMENT_INFO];
    
    self.fieldDepartment.text = [n objectForKey:KEY_REGISTER_CN_DEPARTMENT];
    
    NSLog(@"[%@] [%@]",self.fieldTitle.text,self.fieldDepartment.text);
    
    if(self.fieldTitle.text ==nil)
        self.fieldTitle.text =@"";
    
    if(self.fieldDepartment.text ==nil)
        self.fieldDepartment.text =@"";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)backButtonTapped:(id)sender
{
    [self behavior:@"backButtonTapped"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)displayRegisterSuccess
{
}

-(IBAction)submitButtonTapped:(id)sender
{
    [self behavior:@"submitButtonTapped"];
    if (registerSuccess)
    {
        // 此时按钮为“开始体验”显示
        if (delegate && [delegate respondsToSelector:@selector(loginNew:)])
        {
            //NSLog(@"registernew");
            [delegate performSelector:@selector(loginNew:) withObject:self];
        }
        
        return;
    }
    
    // 此时按钮为“提交注册”显示
    NSLog(@"checking department");
    
    if([self.fieldDepartment.text isEqualToString:@""])
    {
        NSLog(@"department check failed");
        [self alertWithMsg:INFO_ENTER_YOUR_DEPARTMENT];
        
        return;
    }
    
    
    NSLog(@"checking title");
    if([self.fieldTitle.text isEqualToString:@""])
    {
        NSLog(@"title check failed");
        [self alertWithMsg:INFO_ENTER_YOUR_TITLE];
        
        //[self.fieldTitle becomeFirstResponder];
        return;
    }
    
    NSLog(@"checking hospital");
    if([self.fieldHospital.text isEqualToString:@""])
    {
        NSLog(@"hospital check failed");
        [self alertWithMsg:INFO_ENTER_YOUR_HOSPITAL];
        
        [self.fieldHospital becomeFirstResponder];
        return;
    }
    
    [ImdAppBehavior registerFinished];
    
    NSMutableDictionary* dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tempRegInfo"] mutableCopy];
    
    if(dict!=nil)
    {
        NSDictionary* dic = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_REGISTER_DEPARTMENT_INFO];
        NSString* key = [dic objectForKey:@"key"];
        
        [dict setObject:USERTYPE_DOCTOR forKey:REGISTER_INFO_USERTYPE];
        [dict setObject:key forKey:KEY_REGISTER_DEPARTMENT];
        
        [dict setObject:self.fieldTitle.text forKey:KEY_REGISTER_TITLE];
        [dict setObject:self.hospitalId forKey:KEY_REGISTER_HOSPITAL];
        [dict setObject:@"iPadDocApp" forKey:@"source"];
    } else {
        [dict setObject:@"iPadDocApp" forKey:@"source"];
    }
    
    NSMutableDictionary *updtaRegisterDic = [[NSMutableDictionary alloc]init];
    NSString* theURL = [NSString stringWithFormat:REGISTER_URL, MY_SERVERS];
    [updtaRegisterDic setObject:[dict objectForKey:KEY_PASSWORD] forKey:KEY_PASSWORD];
    [updtaRegisterDic setObject:[Strings getUserInfo:dict] forKey:REGISTER_INFO];
    
    NSLog(@"url =%@",theURL);
    NSLog(@"dict =%@",dict);
    
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:theURL]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    [request setRequestMethod:POST];
    //[request setUserInfo:updtaRegisterDic];
    
    [request appendPostData:[[updtaRegisterDic JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    //[updtaRegisterDic autorelease];
    
    request.delegate =self;
    [request startAsynchronous];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if(textField == self.fieldDepartment)
    {
        [textField resignFirstResponder];
        [self.fieldTitle becomeFirstResponder];
    }
    
    if(textField == self.fieldTitle)
    {
        [textField resignFirstResponder];
        [self.fieldHospital becomeFirstResponder];
    }
    
    
    if(textField == self.fieldHospital)
    {
        [textField resignFirstResponder];
        [self submitButtonTapped:nil];
    }
    
    return YES;
}

-(void)alertWithMsg:(NSString*)text
{
    [self behavior:[NSString stringWithFormat:@"alertWithMsg:%@",text]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:text delegate:nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
    [alert show];
}

-(IBAction)chooseDepartment:(id)sender
{
    registerDetailsViewController* detailTitleVC = [[registerDetailsViewController alloc] initWithNibName:@"registerDetailsViewController" bundle:nil];
    //detailTitleVC.delegate =self.delegate;
    detailTitleVC.detailType = DETAIL_TYPE_DEPARTMENT;
    
    [self.navigationController pushViewController:detailTitleVC animated:YES];
    //NSLog(@"? %d",detailTitleVC.detailType);
    [detailTitleVC displayView];
}

-(IBAction)chooseHospital:(id)sender
{
    registerDetailsViewController* detailTitleVC = [[registerDetailsViewController alloc] initWithNibName:@"registerDetailsViewController" bundle:nil];
    //detailTitleVC.delegate =self.delegate;
    detailTitleVC.detailType = DETAIL_TYPE_HOSPITAL;
    
    [self.navigationController pushViewController:detailTitleVC animated:YES];
    //NSLog(@"? %d",detailTitleVC.detailType);
    [detailTitleVC displayView];
}

-(IBAction)chooseTitle:(id)sender
{
    NSLog(@"title clicked ");
    registerDetailsViewController* detailTitleVC = [[registerDetailsViewController alloc] initWithNibName:@"registerDetailsViewController" bundle:nil];
    //detailTitleVC.delegate =self.delegate;
    
    detailTitleVC.detailType = DETAIL_TYPE_TITLE;
    
    [self.navigationController pushViewController:detailTitleVC animated:YES];
    NSLog(@"? %d",detailTitleVC.detailType);
    [detailTitleVC displayView];
}

-(void)requestFinished:(ASIHTTPRequest*)request
{
    NSLog(@"register ok %@",[request responseString]);
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    BOOL success = [[resultsJson objectForKey:@"success"] boolValue];
    
    if (success) {
        NSMutableDictionary* dict =
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"tempRegInfo"] mutableCopy];
        
        NSString * temp;
        NSString* user;
        temp = [dict objectForKey:REGISTER_INFO_MOBILE];
        if (temp.length > 0) {
            user = [dict objectForKey:REGISTER_INFO_MOBILE];
            temp = nil;
        }
        
        temp = nil;
        temp = [dict objectForKey:REGISTER_INFO_USERNAME];
        if (temp.length > 0 ) {
            user = [dict objectForKey:REGISTER_INFO_USERNAME];
            temp = nil;
        }
        
        NSString* uName = user;
        NSString* uPass =[dict objectForKey:KEY_PASSWORD];
        
        [[NSUserDefaults standardUserDefaults] setObject:uName forKey:SaveKEY_SAVEDUSER];
        //todo not save pass
        [[NSUserDefaults standardUserDefaults] setObject:uPass forKey:SaveKey_SAVEDPASS];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //[self performSelector:@selector(loginIn) withObject:self afterDelay:1.0];
        
        RegisterSuccessViewController* rcvc = [[RegisterSuccessViewController alloc] initWithNibName:@"RegisterSuccessViewController" bundle:nil];
        rcvc.delegate = self.delegate;
        [rcvc loginNewDailog];
        [self.navigationController pushViewController:rcvc animated:YES];
    } else {
        UIAlertView *alertD = [[UIAlertView alloc]initWithTitle:DOWNLOAD_DOC message:DOWNLOAD_DOC_FAILED delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"睿医帮助",nil];
        alertD.tag = 8;
        [alertD show];
    }
}

- (void) loginIn
{
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.auth postAuthInfo:@"register"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)requestFailed:(ASIHTTPRequest*)request
{
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    NSLog(@"requestFailed");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}

- (void)behavior:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:REGISTER_DOCTOR_2 paramJson:json];
}

#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)myAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (myAlertView.tag == 8 && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_IMD_HELP]];
    }
}
@end
