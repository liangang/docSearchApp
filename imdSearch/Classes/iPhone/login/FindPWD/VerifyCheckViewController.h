//
//  VerifyCheckViewController.h
//  imdSearch
//
//  Created by xiangzhang on 9/24/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FindPWDAccountInfoViewController.h"

@protocol ASIHTTPRequestDelegate ;

@interface VerifyCheckViewController : UIViewController<UITextFieldDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate>{
    NSInteger remainSeconds;
    NSTimer *remainTimer;
}

@property (assign, nonatomic) ViewType typeOfFunction;
@property (copy, nonatomic) NSString *moblieNumber;
@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UITextField *verifyInfo;
@property (retain, nonatomic) IBOutlet UIButton *verifyRegainBtn;
@property (retain, nonatomic) IBOutlet UIImageView *textBgImg;
@property (retain, nonatomic) IBOutlet UILabel *hasLeaveTimes;

- (IBAction)clickVerifyRegainBtn:(id)sender;

@end
