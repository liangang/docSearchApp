//
//  RegisterStudentsViewController.m
//  imdSearch
//
//  Created by ding zhihong on 12-4-6.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "RegisterStudentsViewController.h"
#import "EnterYearViewController.h"
#import "EducationLevelTableViewController.h"
#import "RegisterSuccessViewController.h"
#import "PadText.h"
#import "ASIFormDataRequest.h"
#import "url.h"
#import "Url_iPad.h"
#import "SaveKey.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "Strings.h"
#import "JSON.h"
#import "UrlRequest.h"
#import "imdSearchAppDelegate.h"
@implementation RegisterStudentsViewController

@synthesize delegate;
@synthesize onReadingSchool, onReadingEducationLevel,studentNumber;
@synthesize enterSchoolYear, onReadingPrefession;
@synthesize submit;
@synthesize alertV;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        alertV = [[UIAlertView alloc]initWithTitle:ALERT_TITLE message:@"" delegate:nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    EducationLevelTableViewController *content = [[EducationLevelTableViewController alloc] initWithNibName:@"EducationLevelTableViewController" bundle:nil];
    
    educationLevelPopoverController = [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate = self;
    
    educationLevelPopoverController.popoverContentSize = CGSizeMake(80, 140);
    educationLevelPopoverController.delegate = self;
    
    EnterYearViewController *eyvc = [[EnterYearViewController alloc]initWithNibName:@"EnterYearViewController" bundle:nil];
    enterYearPopoverController = [[UIPopoverController alloc]initWithContentViewController:eyvc];
    eyvc.delegate = self;
    enterYearPopoverController.popoverContentSize = CGSizeMake(80, 620);
    enterYearPopoverController.delegate = self;
    
    [self behavior:@"viewDidLoad"];
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

- (IBAction)backButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    
    [self behavior:@"backButtonTapped"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"tempRegInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)enterSchoolYearButtonTapped:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    NSLog(@"Enter school year. ");
    [self behavior:@"enterSchoolYearButtonTapped"];
    
    if (sender == startTime) {
        whatButton = @"0";
        CGRect frame = CGRectMake(
                                  enterSchoolYear.frame.origin.x,
                                  enterSchoolYear.frame.origin.y,
                                  enterSchoolYear.frame.size.width,
                                  enterSchoolYear.frame.size.height / 2);
        [enterYearPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if(sender == endTime) {
        whatButton = @"1";
        CGRect frame = CGRectMake(
                                  graduateYear.frame.origin.x,
                                  graduateYear.frame.origin.y,
                                  graduateYear.frame.size.width,
                                  graduateYear.frame.size.height / 2);
        [enterYearPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}

- (IBAction)onReadingEducationLevelButtonTapped:(id)sender
{
    
    [self.view endEditing:YES];
    
    NSLog(@"on Reading Education Level. ");
    [self behavior:@"onReadingEducationLevelButtonTapped"];
    
    CGRect frame=CGRectMake(
                            onReadingEducationLevel.frame.origin.x,
                            onReadingEducationLevel.frame.origin.y,
                            onReadingEducationLevel.frame.size.width,
                            onReadingEducationLevel.frame.size.height / 2);
    
    [educationLevelPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)onSubmitRegisterStudentsButtonTapped:(id)sender
{
    
    [self.view endEditing:YES];
    
    if (self.onReadingSchool.text.length == 0) {
        self.alertV.message = @"请填写您的所在学校";
        [self.alertV show];
        return;
    }
    if (self.onReadingPrefession.text.length == 0) {
        self.alertV.message = @"请填写您的所学专业";
        [self.alertV show];
        return;
    }
    if (self.studentNumber.text.length == 0) {
        self.alertV.message = @"请填写您的学生证号码";
        [self.alertV show];
        return;
    }
    if (self.onReadingEducationLevel.text.length == 0) {
        self.alertV.message = @"请选择您的在读学位";
        [self.alertV show];
        return;
    }
    if (self.enterSchoolYear.text.length == 0) {
        self.alertV.message = @"请选择您的入学时间";
        [self.alertV show];
        return;
    }
    if (graduateYear.text.length == 0) {
        self.alertV.message = @"请选择您的毕业时间";
        [self.alertV show];
        return;
    }
    
    [self behavior:@"onSubmitRegisterStudentsButtonTapped"];
    NSLog(@"on Submit Register students. ");
    NSMutableDictionary* dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tempRegInfo"] mutableCopy];
    
    if(dict!=nil)
    {
        [dict setObject:USERTYPE_STUDENT forKey:REGISTER_INFO_USERTYPE];
        [dict setObject:self.onReadingSchool.text forKey:KEY_REGISTER_SCHOOL];
        [dict setObject:self.enterSchoolYear.text forKey:KEY_REGISTER_ADMISSIONYEAR];
        [dict setObject:self.onReadingPrefession.text forKey:KEY_REGISTER_MAJOR];
        [dict setObject:self.studentNumber.text forKey:KEY_REGISTER_STUDENTID];
        [dict setObject:self.onReadingEducationLevel.text forKey:KEY_REGISTER_DEGREE];
    }
    
    [dict removeObjectForKey:KEY_REGISTER_DEGREE];
    NSArray *pickerSortArray = [NSArray arrayWithObjects:
                                @"Bachelor",
                                @"Master",
                                @"Doctor",
                                nil];
    
    if ([self.onReadingEducationLevel.text isEqualToString:SELECT_XUESHI]) {
        [dict setObject:[pickerSortArray objectAtIndex:0] forKey:REGISTER_INFO_DEGREE];
    } else if ([self.onReadingEducationLevel.text isEqualToString:SELECT_SHUOSHI]) {
        [dict setObject:[pickerSortArray objectAtIndex:1] forKey:REGISTER_INFO_DEGREE];
    } else if ([self.onReadingEducationLevel.text isEqualToString:SELECT_BOSHI]) {
        [dict setObject:[pickerSortArray objectAtIndex:2] forKey:REGISTER_INFO_DEGREE];
    }
    
    NSNumber *Startnumber = [NSNumber numberWithInt:[self.enterSchoolYear.text intValue]];
    NSNumber *Endnumber = [NSNumber numberWithInt:[graduateYear.text intValue]];
    [dict removeObjectForKey:KEY_REGISTER_ADMISSIONYEAR];
    [dict setObject:Startnumber forKey:KEY_REGISTER_ADMISSIONYEAR];
    [dict setObject:Endnumber forKey:REGISTER_INFO_GRADYEAR];
    [dict setObject:@"iPadDocApp" forKey:REGISTER_SOURCE];
    NSMutableDictionary *updtaRegisterDic = [[NSMutableDictionary alloc]init];
    NSString* theURL =[NSString stringWithFormat:REGISTER_URL, MY_SERVERS];
    [updtaRegisterDic setObject:[dict objectForKey:REGISTER_INFO_PASSWORD] forKey:REGISTER_INFO_PASSWORD];
    [updtaRegisterDic setObject:[Strings getUserInfo:dict] forKey:REGISTER_INFO];
    
    NSLog(@"url =%@",theURL);
    NSLog(@"dict =%@",dict);
    
    ASIFormDataRequest* request =
    [ASIFormDataRequest requestWithURL:[NSURL URLWithString:theURL]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    [request setRequestMethod:POST];
    [request appendPostData:[[updtaRegisterDic JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    request.delegate =self;
    [request startAsynchronous];
    
}

- (void)educationLevelSet:(NSString *)eduLevel
{
    [onReadingEducationLevel setText:eduLevel];
    [educationLevelPopoverController dismissPopoverAnimated:YES];
}

- (void)enterYearSet:(NSString *)enterYear
{
    if ([whatButton isEqualToString:@"0"]) {
        [enterSchoolYear setText:enterYear];
    } else if([whatButton isEqualToString:@"1"]) {
        [graduateYear setText:enterYear];
    }
    
    NSString *start = enterSchoolYear.text;
    NSString *end = graduateYear.text;
    if (start.length>0 && end.length>0) {
        if ([start intValue] >= [end intValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您选择的日期不正确" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alert show];
            if ([whatButton isEqualToString:@"0"]) {
                [enterSchoolYear setText:@""];
            }else{
                [graduateYear setText:@""];
            }
        }
        
    }
    [enterYearPopoverController dismissPopoverAnimated:YES];
}

-(void)alertWithMsg:(NSString*)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:text delegate:nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
    [alert show];
}

-(void)requestFinished:(ASIHTTPRequest*)request
{
    NSLog(@"register ok %@",[request responseString]);
    
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    BOOL success = [[resultsJson objectForKey:@"success"] boolValue];
    
    if (success) {
        NSMutableDictionary* dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tempRegInfo"] mutableCopy];
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
        
        // [self performSelector:@selector(loginIn) withObject:self afterDelay:1.0];
        RegisterSuccessViewController* rcvc = [[RegisterSuccessViewController alloc] initWithNibName:@"RegisterSuccessViewController" bundle:nil];
        rcvc.delegate = self.delegate;
        [rcvc loginNewDailog];
        [self.navigationController pushViewController:rcvc animated:YES];
    } else {
        UIAlertView *alertD = [[UIAlertView alloc]initWithTitle:nil message:ERROR_SUBMIT_INFO delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"睿医帮助",nil];
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
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:REGISTER_STUDENT_INFO paramJson:json];
}
#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)myAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (myAlertView.tag == 8 && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_IMD_HELP]];
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.onReadingSchool) {
        [self.onReadingPrefession becomeFirstResponder];
    }else if (textField == self.onReadingPrefession){
        [self.studentNumber becomeFirstResponder];
    }else if (textField == self.studentNumber){
        [self.view endEditing:YES];
    }
    
    return YES;
}
@end
