//
//  ModifyPWDViewController.h
//  imdSearch
//
//  Created by xiangzhang on 9/24/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"

@interface ModifyPWDViewController : UIViewController<ASIHTTPRequestDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (copy , nonatomic) NSString  *activeCode;
@property (copy , nonatomic) NSString  *mobileNumber;
@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UITextField *passwordInfo;
@property (retain, nonatomic) IBOutlet UITextField *repasswordInfo;
@property (retain, nonatomic) IBOutlet UIImageView *passwordInfoBgImg;
@property (retain, nonatomic) IBOutlet UIImageView *rePasswordInfoBgImg;
@end
