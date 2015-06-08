//
//  LoginEmailActive.h
//  imdSearch
//
//  Created by Huajie Wu on 12-4-19.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginEmailActive2.h"

@interface LoginEmailActive : UIViewController
{
  UIButton* _emailActiveBtn;
  UIButton* _emailActiveGoBtn;
  
  UIView* _hintActiveView;
  UIView* _hintValidateView;
  UILabel* _userLabel;
}

@property (nonatomic, retain) IBOutlet UIView* hintValidateView;
@property (nonatomic, retain) IBOutlet UIView* hintActiveView;
@property (nonatomic, retain) IBOutlet UILabel* userLabel;

@property (nonatomic, retain) IBOutlet UIButton* emailActiveBtn;
@property (nonatomic, retain) IBOutlet UIButton* emailActiveGoBtn;

@property (nonatomic, assign) BOOL isLevel1;
@property (nonatomic, assign) BOOL fromRegister;

-(IBAction)emailActiveView:(id)sender;
- (void)popBack:(id)sender;
@end
