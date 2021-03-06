//
//  VerifyCheckViewController.m
//  imdSearch
//
//  Created by xiangzhang on 9/24/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import "VerifyCheckViewController.h"

#import "TableViewFormatUtil.h"
#import "Strings.h"
#import "ImageViews.h"
#import "ModifyPWDViewController.h"
#import "UserBaseInfoViewController.h"
#import "IPhoneSettingsController.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "NSObject+SBJSON.h"

#define UIALERTVIEWTAG1     2013101001
#define UIALERTVIEWTAG2     2013101002

@interface VerifyCheckViewController ()

@end

@implementation VerifyCheckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIBarButtonItem *nextBtn = [[UIBarButtonItem alloc] initWithTitle:LOGIN_NEXTSTEP style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnClick:)]; 
        [self.navigationItem setRightBarButtonItem:nextBtn];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height - 50)];
    
    if (self.typeOfFunction == ViewTypeFindPWD) {
        self.navigationItem.title = @"忘记密码";
    }else{
        self.navigationItem.title = @"激活手机";
    }
    
    [self.verifyRegainBtn setBackgroundImage:[[UIImage imageNamed:IMG_BTN_SAVE] stretchableImageWithLeftCapWidth:30 topCapHeight:20] forState:UIControlStateNormal];
    
    remainSeconds = ACTIVE_MOBILE_CODE_TIMER;
    remainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(remainTimer:) userInfo:nil repeats:YES];
    [self.hasLeaveTimes setText:[NSString stringWithFormat:@"验证码在%d秒内有效",remainSeconds]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)viewDidUnload {
    [self setVerifyInfo:nil];
    [self setVerifyRegainBtn:nil];
    [self setMainScrollView:nil];
    [self setTextBgImg:nil];
    [self setHasLeaveTimes:nil];
    [super viewDidUnload];
}

#pragma mark - button Event deal
- (IBAction)dismissView:(id)sender{

    [self popToBaseUserViewController];
}

- (IBAction)nextBtnClick:(id)sender{
    //判断验证码是否正确
    [self.view endEditing:YES];
        //发送请求，获取验证是否完成信息
    
    if (self.typeOfFunction == ViewTypeFindPWD) {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath checkActivationCode]]];
        NSDictionary *modifyPWD = @{@"mobile" : self.moblieNumber, @"activationCode" : self.verifyInfo.text};
        [request appendPostData:[[modifyPWD JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
        request.delegate = self;
        [request startAsynchronous];
    }else{
        NSString *urlStr = [ImdUrlPath mobileActiveCheck];
        
        ASIHTTPRequest *request =  [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
        NSDictionary *info = @{@"mobile":self.moblieNumber,@"code":self.verifyInfo.text};
        [request appendPostData:[[info JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
        [UrlRequest setToken:request];
        [request setDelegate:self];
        [request startAsynchronous];
    }
}

- (IBAction)clickVerifyRegainBtn:(id)sender {
    //发送获取验证码的请求，成果后同时使按钮变得不可点击，倒计时开始
    remainSeconds = ACTIVE_MOBILE_CODE_TIMER;
    
    //TODO::
    remainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(remainTimer:) userInfo:nil repeats:YES];
}

- (void)remainTimer:(NSTimer *)timer
{
    [self.verifyRegainBtn setTitle:[NSString stringWithFormat:@"%d", --remainSeconds] forState:UIControlStateDisabled] ;
//    [self.hasLeaveTimes setText:[NSString stringWithFormat:@"验证码在%d秒内有效",--remainSeconds]];
    NSString *content = [NSString stringWithFormat:@"验证码在%d秒内有效",--remainSeconds];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:content];
    NSRange range1 = [content rangeOfString:@"在"];
    NSRange range2 = [content rangeOfString:@"秒"];
    NSInteger *length = range2.location - range1.location - range1.length;
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(range1.location + range1.length, length)];
    self.hasLeaveTimes.attributedText = str;
    
    
    if (remainSeconds <= 0) {
        [remainTimer invalidate];
        self.verifyRegainBtn.enabled = YES;
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    self.textBgImg.image = [UIImage imageNamed:@"img-typin-sigle-active"];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    self.textBgImg.image = [UIImage imageNamed:@"img-typin-sigle-default"];
    
    return YES;
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *success = request.responseString;
    if (self.typeOfFunction == ViewTypeFindPWD) {
        if ([success isEqualToString:@"true"]) {
            ModifyPWDViewController *viewController = [[ModifyPWDViewController alloc] init];
            viewController.mobileNumber = self.moblieNumber;
            viewController.activeCode = self.verifyInfo.text;
            [self.navigationController pushViewController:viewController animated:YES];
        }else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"验证码错误" message:@"您输入的验证码错误或已过期，请输入正确验证码，或重新获取验证码。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:@"重新获取",nil];
            alert.tag = UIALERTVIEWTAG2;
            [alert show];
        }

    }else{
    
        if ([success isEqualToString:@"true"]) {
          NSArray *viewControllers_ = [self.navigationController viewControllers];
          for (UIViewController *viewController in viewControllers_) {
            if ([viewController isMemberOfClass:[UserBaseInfoViewController class]]) {
              UserBaseInfoViewController *baseUseInfo = (UserBaseInfoViewController *)viewController;
              [baseUseInfo.originInfo setObject:[NSNumber numberWithBool:Ture] forKey:@"mobileVerified"];
            }
          }
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"手机号码激活完成，请重新登陆帐号！" message:nil delegate:self cancelButtonTitle:TEXT_CONFIRM otherButtonTitles:nil];
            alert.tag = UIALERTVIEWTAG1;
            [alert show];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"验证码错误" message:@"您输入的验证码错误或已过期，请输入正确验证码，或重新获取验证码。" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:@"重新获取",nil];
            alert.tag = UIALERTVIEWTAG2;
            [alert show];
        }

    }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
  if ([request.error code] == ASIRequestTimedOutErrorType) {
    alert.message = REQUEST_TIMEOUT_MESSAGE;
    alert.title = HINT_TEXT;
  }
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == UIALERTVIEWTAG1) {
        [self useActiveFinish];
    }else if (alertView.tag == UIALERTVIEWTAG2){
        if (buttonIndex == 0) {
            [self.verifyInfo setText:nil];
            [self.verifyInfo becomeFirstResponder];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)useActiveFinish{
    NSArray *viewControllers_ = [self.navigationController viewControllers];
    for (UIViewController *viewController in viewControllers_) {
        if ([viewController isMemberOfClass:[IPhoneSettingsController class]]) {
            IPhoneSettingsController *baseUseInfo = (IPhoneSettingsController *)viewController;
            [baseUseInfo logout:nil];
            [baseUseInfo loginAccount:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyMobileSuccess" object:nil];
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
    
//    [[NSUserDefaults standardUserDefaults] setObject:self.moblieNumber forKey:@"savedUser"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    //TODO::修改用户信息中的手机信息
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"mobileNumberActive" object:self.moblieNumber];
}

- (void)popToBaseUserViewController{
    if (self.typeOfFunction == ViewTypeFindPWD) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        NSArray *viewControllers_ = [self.navigationController viewControllers];
        for (UIViewController *viewController in viewControllers_) {
            if ([viewController isMemberOfClass:[UserBaseInfoViewController class]]) {
                UserBaseInfoViewController *baseUseInfo = (UserBaseInfoViewController *)viewController;
                [baseUseInfo userMobileActiveSuccess];
                
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
    }
}
@end
