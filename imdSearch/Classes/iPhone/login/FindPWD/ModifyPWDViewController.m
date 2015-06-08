//
//  ModifyPWDViewController.m
//  imdSearch
//
//  Created by xiangzhang on 9/24/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import "ModifyPWDViewController.h"

#import "TableViewFormatUtil.h"
#import "ImageViews.h"
#import "Strings.h"
#import "ImdUrlPath.h"
#import "UrlRequest.h"
#import "NSObject+SBJSON.h"
#import "LoginController.h"
#import "FindPWDAccountInfoViewController.h"

@interface ModifyPWDViewController ()

@end

@implementation ModifyPWDViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        UIBarButtonItem *savePassword = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(savePassword:)];
        [self.navigationItem setRightBarButtonItem:savePassword];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {}

- (void)viewDidUnload {
    [self setPasswordInfo:nil];
    [self setRepasswordInfo:nil];
    [self setMainScrollView:nil];
    [self setPasswordInfoBgImg:nil];
    [self setRePasswordInfoBgImg:nil];
    [super viewDidUnload];
}

#pragma mark - button Event deal
- (IBAction)dismissView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)savePassword:(id)sender{
    NSString *password = self.passwordInfo.text;
    NSString *rePassword = self.repasswordInfo.text;
    if (![password isEqualToString:rePassword]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"密码错误" message:@"两次输入的密码不一致，请重新输入" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        self.repasswordInfo.text = nil;
        
        return;
    }
    
    //发送修改密码的信息
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath resetUsePassword]]];
    [UrlRequest setToken:request];
    NSDictionary *modifyPWD = @{@"mobile" : self.mobileNumber, @"password" : self.passwordInfo.text, @"enActivationCode" : self.activeCode};
    [request appendPostData:[[modifyPWD JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    request.delegate = self;
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *responseStr = [request responseString];
    NSLog(@"request response code %d",request.responseStatusCode);
    
    if ([responseStr isEqualToString:@"true"]) {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"密码重置完成" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alerView.tag = 0;
        [alerView show];
        

    }else{
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"修改密码错误，请重试" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alerView.tag = 1;
        [alerView show];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
  
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSArray *viewControllerArr = [self.navigationController viewControllers];
    
    if (alertView.tag == 0) {
        for (UIViewController *viewController in viewControllerArr) {
            if ([viewController isKindOfClass:[LoginController class]]) {
                [self.navigationController popToViewController:viewController animated:YES];
            }
        } 
    }else if(alertView.tag == 1){
        for (UIViewController *viewController in viewControllerArr) {
            if ([viewController isKindOfClass:[FindPWDAccountInfoViewController class]]) {
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
    }
}

#pragma mark - UITextField Background Image change
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self changeTextFieldBg:textField isActive:YES];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self changeTextFieldBg:textField isActive:NO];
    
    return YES;
}

- (void)changeTextFieldBg:(UITextField *)textField isActive:(BOOL)isActive{
//    NSString *imgName = isActive ? @"img-typin-sigle-active" : @"img-typin-sigle-default";
//    if (textField == self.passwordInfo) {
//        self.passwordInfoBgImg.image = [UIImage imageNamed:imgName];;
//    }else if (textField == self.repasswordInfo){
//        self.rePasswordInfoBgImg.image = [UIImage imageNamed:imgName];;
//    }
}
@end
