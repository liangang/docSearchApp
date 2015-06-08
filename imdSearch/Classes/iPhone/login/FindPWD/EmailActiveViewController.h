//
//  EmailActiveViewController.h
//  imdSearch
//
//  Created by xiangzhang on 9/26/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"

@interface EmailActiveViewController : UIViewController<ASIHTTPRequestDelegate,UIAlertViewDelegate>

@property (assign, nonatomic) BOOL isActive;
@property (copy, nonatomic) NSString *originEmailInfo;
@property (retain, nonatomic) IBOutlet UITextField *emailInfo;

@property (retain, nonatomic) IBOutlet UIImageView *textBgImg;

@property (retain, nonatomic) IBOutlet UIButton *sendActiveEmailBtn;
- (IBAction)sendActiveEmail:(id)sender;
@end
