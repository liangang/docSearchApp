//
//  FindPWDAccountInfoViewController.m
//  imdSearch
//
//  Created by xiangzhang on 9/24/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import "FindPWDAccountInfoViewController.h"

#import "TableViewFormatUtil.h"
#import "Strings.h"
#import "ImageViews.h"
#import "ImdUrlPath.h"
#import "VerifyCheckViewController.h"
#import "NSObject+SBJSON.h"
#import "UrlRequest.h"

#define UIALERTVIEWTAG   2013103101

@interface FindPWDAccountInfoViewController (){
    ASIHTTPRequest *request;
}

@end

@implementation FindPWDAccountInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:LOGIN_NEXTSTEP style:UIBarButtonItemStylePlain target:self action:@selector(clickVerifyInfoBtn:)]];
        self.type = ViewTypeFindPWD;
        self.activeType = AccountActived;
        self.isActive = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [TableViewFormatUtil setShadow:self.navigationController.navigationBar];
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height - 50)];
    if (self.type == ViewTypeFindPWD) {
        self.navigationItem.title = @"忘记密码";
        self.inputInfoTitle.text = @"请输入注册用的手机/邮箱";
    }else{
        self.navigationItem.title = @"激活手机";
        self.inputInfoTitle.text = @"请输入手机号码";
    }
    
    if (self.userAccount != nil) {
        self.accountInfolabel.text = self.userAccount;
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:noErr animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)viewDidUnload {
    [self setAccountInfolabel:nil];
    [self setVerifyInfoBtn:nil];
    [self setMainScrollView:nil];
    [self setTextBgImg:nil];
    [self setInputInfoTitle:nil];
    [super viewDidUnload];
}

#pragma mark --

-(IBAction)dismissView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickVerifyInfoBtn:(id)sender {
    NSString *accountInfo = self.accountInfolabel.text;
    if ([accountInfo rangeOfString:@"@"].location == NSNotFound) {  //手机判断
        if (![self isValidateMobile:accountInfo]) {
            [self showAlertViewWithTitle:@"提醒" andMessage:@"您输入的手机号码错误，请输入正确的手机号码。"];
            return;
        }
        
        if ([accountInfo isEqualToString:self.userAccount] && self.isActive) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"您输入的手机号码已被使用，请输入新的手机号码。" delegate:self cancelButtonTitle:@"输入新手机号码" otherButtonTitles:@"取消", nil];
            alertView.tag = 2014052907;
            [alertView show];
            return ;
        }
        
        request = [UrlRequest checkMobile:[ImdUrlPath checkMobileUrl:self.accountInfolabel.text] delegate:self];
        request.didFinishSelector = @selector(checkMobileInfoRequestFinished:);

    }else{              //邮箱判断
        if (![self isValidateEmail:accountInfo]) {
            [self showAlertViewWithTitle:@"提醒" andMessage:@"您输入的电子邮箱错误，请输入正确的电子邮箱。"];
            return;
        }
        
#define CHECK_TYPE @"checktype"
#define CHECK_EMAL @"checkemail"
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:CHECK_EMAL forKey:CHECK_TYPE];
        
        request = [UrlRequest sendWithTokenWithUserInfo:[ImdUrlPath checkEmailUrl:self.accountInfolabel.text] userInfo:userInfo delegate:self];
        request.didFinishSelector = @selector(checkEmailRequestFinish:);
    }
    
}


#pragma mark - ASIHTTPRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request_{
    NSString *responseStr = [request_ responseString];
    switch (self.type) {
        case ViewTypeFindPWD:
            {
                if ([responseStr isEqualToString:@"true"]) {
                    if (request_.tag == 1) {
                        //跳转
                        VerifyCheckViewController *viewController = [[VerifyCheckViewController alloc] init];
                        viewController.moblieNumber = self.accountInfolabel.text;
                        viewController.typeOfFunction = ViewTypeFindPWD;
                        [self.navigationController pushViewController:viewController animated:YES];
                        
                    }else if(request_.tag == 2){
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"邮件已发送" message: [NSString stringWithFormat:@"请尽快登录%@查收邮件，找回密码。",self.accountInfolabel.text] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        alertView.tag = 2;
                        [alertView show];
                    }
                    
                }else{
                    [self showAlertViewWithTitle:@"提醒" andMessage:@"验证码发送错误，请重试！"];
                }

            }
            break;
        case ViewTypeModifyMobile:
        {
             NSDictionary *dic = [UrlRequest getJsonValue:request];
            BOOL validInfo = [[dic objectForKey:@"validEmailOrMobile"] boolValue];
            if (validInfo){
                VerifyCheckViewController *viewController = [[VerifyCheckViewController alloc] init];
                viewController.typeOfFunction = ViewTypeModifyMobile;
                viewController.moblieNumber = self.accountInfolabel.text;
                [self.navigationController pushViewController:viewController animated:YES];
            }else{
                [self showAlertViewWithTitle:@"错误提示" andMessage:@"验证码发送失败，请重试！"];
            }
        }
    }
    
        
}

- (void)requestFailed:(ASIHTTPRequest *)requests{
  if ([requests.error code] == ASIRequestTimedOutErrorType) {
    [self showAlertViewWithTitle:HINT_TEXT andMessage:REQUEST_TIMEOUT_MESSAGE];
  }else
  {
    [self showAlertViewWithTitle:@"睿医" andMessage:@"网络出错-­‐请检查网络设置"];
  }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (alertView.tag == 2013102401 || alertView.tag == UIALERTVIEWTAG){
        if (buttonIndex == 0) {
            self.accountInfolabel.text = nil;
            [self.accountInfolabel becomeFirstResponder];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if(alertView.tag == 2014052907 && buttonIndex == 0){
        self.accountInfolabel.text = nil;
        [self.accountInfolabel becomeFirstResponder];
    }
}

#pragma mark - 
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self  clickVerifyInfoBtn:nil];
    return YES;
}

- (void)checkEmailRequestFinish:(ASIHTTPRequest *)request_{
   BOOL checkemail = [[request responseString] boolValue];
    if (!checkemail) {
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath findPasswordByEmail]]];
        [UrlRequest setToken:request];
        NSDictionary *json = @{@"device" : @"IPhone" , @"email" : self.accountInfolabel.text};
        [request appendPostData:[[json JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
        request.tag = 2;
        request.delegate = self;
        [request startAsynchronous];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您输入的帐号不存在，请输入正确的手机/邮箱。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:@"取消", nil];
        alertView.tag = UIALERTVIEWTAG;
        [alertView show];
    }
}

- (void)checkMobileInfoRequestFinished:(ASIHTTPRequest *)request_{
     BOOL checked = [[request_ responseString] boolValue];

    if (self.type == ViewTypeFindPWD) {
        if (!checked) {
            request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath findPasswordByMobil]]];
            [UrlRequest setToken:request];
            NSDictionary *json = @{@"device" : @"IPhone", @"mobile":self.accountInfolabel.text};
            [request appendPostData:[[json JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]] ;
            request.tag = 1;
            request.delegate = self;
            [request startAsynchronous];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您输入的帐号不存在，请输入正确的手机/邮箱。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:@"取消", nil];
            alertView.tag = UIALERTVIEWTAG;
            [alertView show];
        }
      
    }else{
         NSString *loginNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
        
        BOOL isOrigin = [self.accountInfolabel.text isEqualToString:loginNumber];
      if (!isOrigin) {
        isOrigin = [self.accountInfolabel.text isEqualToString:self.userAccount];
      }
        if (isOrigin && self.activeType == AccountUnActived) {
            request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath mobileActiveInfo:self.accountInfolabel.text]]];
            [request setRequestMethod:@"POST"];
            request.tag = 1;
            request.delegate = self;
            [request startAsynchronous];
            return;
        }
        
        if ((!checked && !isOrigin)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"手机号码已被使用" message:@"您输入的手机号码已被使用，请输入新手机号码。" delegate:self cancelButtonTitle:@"输入新手机号" otherButtonTitles:@"取消", nil];
            alertView.tag = 2013102401;
            [alertView show];
        }else{
            request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath mobileActiveInfo:self.accountInfolabel.text]]];
            [request setRequestMethod:@"POST"];
            request.tag = 1;
            request.delegate = self;
            [request startAsynchronous];
        }
    }

}

#pragma mark - function for base
/*邮箱验证 MODIFIED BY HELENSONG*/
-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/*手机号码验证 MODIFIED BY HELENSONG*/
-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
@end
