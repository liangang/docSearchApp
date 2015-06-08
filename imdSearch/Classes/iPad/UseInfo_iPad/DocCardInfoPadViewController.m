//
//  DocCardInfoPadViewController.m
//  imdSearch
//
//  Created by xiangzhang on 10/28/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import "DocCardInfoPadViewController.h"

#import "ImageViews.h"
#import "Strings.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "NSObject+SBJSON.h"

@interface DocCardInfoPadViewController (){
    ASIHTTPRequest *docRequest;
}

@end

@implementation DocCardInfoPadViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.docCardBgImg.image = [[UIImage imageNamed:@"img-typin-sigle-default"] stretchableImageWithLeftCapWidth:100 topCapHeight:20];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)viewDidUnload {
    [self setDocCardBgImg:nil];
    [self setDocCardInfo:nil];
    [super viewDidUnload];
}

#pragma mark -
- (IBAction)dismissView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextBtnClick:(id)sender{
    [self.view endEditing:YES];
    //请求修改文献卡信息
    NSString *docNum = self.docCardInfo.text;
    if (docNum == nil || [docNum isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"睿医提醒" message:@"请输入正确的文献卡邀请码。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        docRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath verifyDocCardNum]]];
        [UrlRequest setPadToken:docRequest];
        NSDictionary *json = @{@"device" : @"IPhone" , @"code" : docNum};
        [docRequest appendPostData:[[json JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
        docRequest.delegate = self;
        [docRequest startAsynchronous];
    }
    
}

#pragma mark - ASIHTTPRequest Delegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *dic = [UrlRequest getJsonValue:request];
    NSLog(@"dic is %@",dic);
    
    BOOL success = [[dic objectForKey:@"success"] boolValue];
    
    if (success) {
        long long dateTimes = [[dic objectForKey:@"expireDate"] longLongValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateTimes];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY年MM月dd日"];
        NSString *expireDate = [formatter stringFromDate:date];
        [self showAlertViewWithTitle:@"文献卡绑定成功" message:[NSString stringWithFormat:@"您将免费享有为期一年的医学文献VIP服务，有效期至%@。",expireDate]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bindDocCardSuccess" object:nil userInfo:@{@"cardNum" : self.docCardInfo.text, @"expireDate" : [NSNumber numberWithLongLong:dateTimes]}];
    }else{
        NSArray *allkeys = [dic allKeys];
        
        if ([allkeys containsObject:@"vcardNotExist"]) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文献卡不存在" message:@"您输入的文献卡邀请码不存在，请输入正确的邀请码。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新输入", nil];
            [alertView show];
            
        }else if ([allkeys containsObject:@"vcardUsed"]) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文献卡已被绑定" message:@"您输入的文献卡邀请码已被使用，请输入其他邀请码。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新输入", nil];
            [alertView show];
            
        }else if ([allkeys containsObject:@"tooManyTries"]){
            [self showAlertViewWithTitle:@"请稍后再绑定" message:@"对不起，文献卡绑定操作已连续失败3次，请一个小时后再试。"];
        }
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    [self showAlertViewWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        self.docCardInfo.text = @"";
        [self.docCardInfo becomeFirstResponder];
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    return YES;
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}


@end
