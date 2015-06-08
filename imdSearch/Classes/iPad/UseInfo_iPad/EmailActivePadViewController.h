//
//  EmailActivePadViewController.h
//  imdSearch
//
//  Created by xiangzhang on 10/28/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"

@interface EmailActivePadViewController : UIViewController<ASIHTTPRequestDelegate,UIAlertViewDelegate>

@property (copy, nonatomic) NSString *originEmailInfo;
@property (assign, nonatomic) BOOL isActive;

@property (retain, nonatomic) IBOutlet UITextField *emailInfo;
@property (retain, nonatomic) IBOutlet UIImageView *textBgImg;
@property (retain, nonatomic) IBOutlet UIButton *sendActiveEmailBtn;

- (IBAction)sendActiveEmail:(id)sender;

@end
