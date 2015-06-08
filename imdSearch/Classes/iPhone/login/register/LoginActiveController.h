//
//  LoginActiveController.h
//  imdSearch
//
//  Created by Huajie Wu on 12-3-28.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h" 


@class LoginActiveController;

@protocol LoginActiveDelegate <NSObject>
@optional
- (void)MobileActiveSuccess:(LoginActiveController *)controller;
- (void)MobileActiveFail:(LoginActiveController *)controller;

@optional
- (void)EmailActiveSuccess:(LoginActiveController *)controller;
- (void)EmailActiveFail:(LoginActiveController *)controller;
@end


@interface LoginActiveController : UIViewController <ASIHTTPRequestDelegate>
{
  id<LoginActiveDelegate> _delegate;

  UIButton* _mobileActive;
  UIButton* _emailActive;
  
  UIButton* _mobileActiveArrowBtn;
  UIButton* _emailActiveArrowBtn;
  
  UIView* _hintViewFromRegister;
  UIView* _hintViewNotFromRegister;
  NSString *mobileN;
  NSString *emailN;
}

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) UIView* hintViewFromRegister;
@property (nonatomic, retain) UIView* hintViewNotFromRegister;


@property (nonatomic, assign) BOOL isMobileActive;
@property (nonatomic, assign) BOOL isEmailActive;
@property (nonatomic, assign) BOOL fromRegister;

@property (strong, nonatomic) IBOutlet UIView *mobileBackgroundView;

@property (strong, nonatomic) IBOutlet UIView *emilBackgroundView;
@property (nonatomic, retain) IBOutlet UIButton* mobileActiveBtn;
@property (nonatomic, retain) IBOutlet UIButton* emailActiveBtn;

@property (nonatomic, retain) IBOutlet UIButton* mobileActiveArrowBtn;
@property (nonatomic, retain) IBOutlet UIButton* emailActiveArrowBtn;
@property (nonatomic, retain) IBOutlet UILabel* emailLable;
-(IBAction)mobileActive:(id)sender;
-(IBAction)emailActive:(id)sender;

@end
