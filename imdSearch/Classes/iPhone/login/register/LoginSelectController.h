//
//  LoginSelectController.h
//  imdSearch
//
//  Created by Huajie Wu on 12-3-28.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginNewUserController.h"
#import "FTCoreTextView.h"
typedef enum {
  UNKown = 0,
  PersonCenter,
  UserInfoCenter,
  RegisterSelect
}Select_UserType;
@interface LoginSelectController : UIViewController<UIAlertViewDelegate>
{
  UIButton* _doctor;
  UIButton* _student;

  LoginNewUserController* _loginCtr;
}

@property (nonatomic, retain) IBOutlet UIButton* doctor;
@property (nonatomic, retain) IBOutlet UIButton* student;
@property (strong, nonatomic) IBOutlet FTCoreTextView *selectRemind;
@property (assign, nonatomic) NSString *userType;

@property (nonatomic, retain) LoginNewUserController* loginCtr;
@property (assign, nonatomic) Select_UserType type;

-(IBAction)selectUserType:(id)sender;
- (void)behavior:(NSString *)status;
@end
