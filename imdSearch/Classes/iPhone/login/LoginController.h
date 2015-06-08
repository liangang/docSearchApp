//
//  LoginController.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-24.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@interface LoginController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
    IBOutlet UIButton* registerBtn;
    IBOutlet UIButton* forgotPasswordBtn;
    IBOutlet UITextField* userText;
    IBOutlet UITextField* userPassword;
    id delegate;
    UIAlertView* alertView;
    
    IBOutlet UIScrollView* _scrollView;
    
    UIActivityIndicatorView* _indicator;
    id viewC;
}

@property (nonatomic, retain) UIViewController* sourceCtr;
@property (nonatomic, retain) IBOutlet UIButton* registerBtn;
@property (nonatomic, retain) IBOutlet UIButton* forgotPasswordBtn;
@property (nonatomic, retain) IBOutlet UITextField* userText;
@property (nonatomic, retain) IBOutlet UITextField* userPassword;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* indicator;


@property (nonatomic, retain) UIAlertView* alertView;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) id viewC;
-(IBAction)login:(id)sender;
-(IBAction)registerNew:(id)sender;
-(IBAction)closeView:(id)sender;

-(IBAction)forgotPassword:(id)sender;

-(void) userLoginFinished:(BOOL)animated;
-(void) userLoginFailed:(UIViewController *)viewController;

@end
