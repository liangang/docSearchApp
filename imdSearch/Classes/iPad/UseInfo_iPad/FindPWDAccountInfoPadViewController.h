//
//  FindPWDAccountInfoPadViewController.h
//  imdSearch
//
//  Created by xiangzhang on 10/28/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FindPWDAccountInfoViewController.h"
#import "ASIHTTPRequest.h"

@interface FindPWDAccountInfoPadViewController : UIViewController<ASIHTTPRequestDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (copy, nonatomic) NSString *userAccount;
@property (assign, nonatomic) BOOL isActive;
@property (assign, nonatomic) ViewType type;
@property (retain, nonatomic) IBOutlet UILabel *inputInfoTitle;
@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UITextField *accountInfolabel;
@property (retain, nonatomic) IBOutlet UIButton *verifyInfoBtn;
@property (retain, nonatomic) IBOutlet UIImageView *textBgImg;
@property (retain, nonatomic) IBOutlet UILabel *viewTitle;

- (IBAction)clickVerifyInfoBtn:(id)sender;
@end
