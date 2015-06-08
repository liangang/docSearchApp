    //
    //  LoginMobileActive.h
    //  imdSearch
    //
    //  Created by Huajie Wu on 12-3-28.
    //  Copyright (c) 2012年 i-md.com. All rights reserved.
    //

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "LoginMobileActive2.h"
#import "LoginActiveController.h"

@class LoginMobileActive2;

@interface LoginMobileActive : UIViewController <UITextFieldDelegate, ASIHTTPRequestDelegate, UIScrollViewDelegate>
{
    UIScrollView* _scroll;
    UITextField* _mobileTF;
    UIButton* _activeCode;
    
    UIAlertView* _alertView;
    
    LoginMobileActive2* _activeStep2;
    
    BOOL NumberJudge;
    int pos;
  NSString *textOutput;
}

@property (nonatomic, assign) LoginActiveController* parent;

@property (nonatomic, assign) BOOL isLevel1;

@property (nonatomic, retain) IBOutlet UIScrollView* scroll;
@property (nonatomic, retain) IBOutlet UITextField* mobileTF;
@property (nonatomic, retain) IBOutlet UIButton* activeCode;
@property (nonatomic, retain) UIAlertView* alertView;
@property (nonatomic, retain) LoginMobileActive2* activeStep2;
@property (nonatomic, copy)NSString *textOutput;
- (IBAction)getCode:(id)sender;
- (void) popBack;
- (void) dismissView:(id)sender;
-(void)textDidChange:(id)sender;
- (void)updateTextField;
- (void)updateButton;
@end
