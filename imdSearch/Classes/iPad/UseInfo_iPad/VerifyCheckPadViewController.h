//
//  VerifyCheckPadViewController.h
//  imdSearch
//
//  Created by xiangzhang on 10/28/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FindPWDAccountInfoPadViewController.h"

@protocol ASIHTTPRequestDelegate ;

@interface VerifyCheckPadViewController : UIViewController<UITextFieldDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate>{
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
@property (retain, nonatomic) IBOutlet UILabel *viewTitle;

- (IBAction)clickVerifyRegainBtn:(id)sender;

@end
