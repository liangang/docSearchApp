//
//  phoneActivationViewController.h
//  imdSearch
//
//  Created by ding zhihong on 12-3-31.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface phoneActivationViewController : UIViewController
{
    IBOutlet UITextField* phoneNumber;
    IBOutlet UIButton* sendVerifyCode;
    BOOL checkMobile;
    BOOL checkMobile2;
    NSString *mobile;
}

@property (nonatomic, retain) UITextField* phoneNumber;
@property (nonatomic, retain) UIButton* sendVerifyCode;
@property (nonatomic, copy) NSString *mobile;

@property (nonatomic, copy) NSString *originMobile;
@property (nonatomic, assign) BOOL isActive;

- (IBAction)activeButtonTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;
- (void)textDidChange:(id)sender;

@end
