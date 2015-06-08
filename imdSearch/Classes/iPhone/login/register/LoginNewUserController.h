//
//  LoginNewUserController.h
//  imdSearch
//
//  Created by Huajie Wu on 11-12-12.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginNewUserStep2.h"
#import "ASIHTTPRequest.h"

@interface LoginNewUserController : UIViewController <UITextFieldDelegate, ASIHTTPRequestDelegate,UIAlertViewDelegate>
{
    IBOutlet UITextField* inputEmail;
    IBOutlet UILabel* emailLbl;
    IBOutlet UITextField* inputPassword;
    IBOutlet UILabel* pwdLbl;
    IBOutlet UITextField* inputRealName;
    IBOutlet UILabel* realNameLbl;
    IBOutlet UILabel* phoneLable;
    IBOutlet UITextField* inputPhoneNumber;

    NSString* _userType;
    UIAlertView* alertView;
    LoginNewUserStep2* step2;
    ASIHTTPRequest* _httpRequest;
    BOOL backtoFrist;
    BOOL kill;
}

@property (nonatomic, assign) BOOL emailChecked;
@property (nonatomic, assign) BOOL mobileChecked;
@property (nonatomic, retain) ASIHTTPRequest* httpRequest;

@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, retain) IBOutlet UITextField* inputEmail;
@property (nonatomic, retain) IBOutlet UITextField* inputPassword;
@property (nonatomic, retain) IBOutlet UITextField* inputRealName;
@property (nonatomic, retain) IBOutlet UITextField* inputPhoneNumber;

@property (nonatomic, retain) IBOutlet UILabel* emailLbl;
@property (nonatomic, retain) IBOutlet UILabel* pwdLbl;
@property (nonatomic, retain) IBOutlet UILabel* realNameLbl;
@property (nonatomic, retain) IBOutlet UILabel* phoneLable;

@property (nonatomic, retain) NSString* userType;

@property (nonatomic, retain) LoginNewUserStep2* step2;
@property (nonatomic, assign) BOOL backtoFrist;
-(IBAction)nextStep:(id)sender;

-(void) popBack;
- (void)behavior:(NSString *)status;
@end
