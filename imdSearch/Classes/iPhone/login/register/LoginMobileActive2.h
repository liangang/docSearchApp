//
//  LoginMobileActive2.h
//  imdSearch
//
//  Created by Huajie Wu on 12-3-30.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "LoginMobileActive.h"

@class LoginMobileActive;

@interface LoginMobileActive2 : UIViewController <UITextFieldDelegate, ASIHTTPRequestDelegate, UIScrollViewDelegate, UIAlertViewDelegate>
{
  UIScrollView* _scroll;
  
  UITextField* _codeTF;
  UIButton* _activeAccount;

  UIAlertView* _alertView;
  
  UILabel* _hintLabel;
  UILabel* _timerLabel;
  
  NSTimer* _myTimer;
  NSInteger _startSeconds;
  NSString *mobileNumber;
}

@property (nonatomic, assign) LoginMobileActive* parent;


@property (nonatomic, retain) NSTimer* myTimer;

@property (nonatomic, retain) IBOutlet UILabel* hintLabel;
@property (nonatomic, retain) IBOutlet UILabel* timerLabel;

@property (nonatomic, assign) BOOL isParentLevel1;
@property (nonatomic, retain) IBOutlet UIScrollView* scroll;
@property (nonatomic, retain) IBOutlet UITextField* codeTF;
@property (nonatomic, retain) IBOutlet UIButton* activeAccount;
@property (nonatomic, retain) UIAlertView* alertView;
@property (nonatomic, copy) NSString *mobileNumber;
- (IBAction)submitActiveAccount:(id)sender;


-(void) popBack;

- (void) countDown:(NSTimer *) timer;

@end
