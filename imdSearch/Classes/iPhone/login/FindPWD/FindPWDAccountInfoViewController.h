//
//  FindPWDAccountInfoViewController.h
//  imdSearch
//
//  Created by xiangzhang on 9/24/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"
typedef enum {
    ViewTypeFindPWD,
    ViewTypeModifyMobile,
}ViewType;

typedef NS_ENUM(NSInteger, AccountActive) {
    AccountActived,
    AccountUnActived
};

@interface FindPWDAccountInfoViewController : UIViewController<ASIHTTPRequestDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (assign, nonatomic) BOOL isActive;
@property (copy, nonatomic) NSString *userAccount;
@property (assign, nonatomic) ViewType type;
@property (assign, nonatomic) AccountActive activeType;
@property (retain, nonatomic) IBOutlet UILabel *inputInfoTitle;
@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UITextField *accountInfolabel;
@property (retain, nonatomic) IBOutlet UIButton *verifyInfoBtn;
@property (retain, nonatomic) IBOutlet UIImageView *textBgImg;

- (IBAction)clickVerifyInfoBtn:(id)sender;
@end
