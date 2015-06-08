//
//  DocCardInfoPadViewController.h
//  imdSearch
//
//  Created by xiangzhang on 10/28/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"

@interface DocCardInfoPadViewController : UIViewController<ASIHTTPRequestDelegate,UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *docCardBgImg;
@property (retain, nonatomic) IBOutlet UITextField *docCardInfo;

@end
