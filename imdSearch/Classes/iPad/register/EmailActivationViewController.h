//
//  EmailActivationViewController.h
//  imdSearch
//
//  Created by ding zhihong on 12-4-24.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
@interface EmailActivationViewController : UIViewController
{
}

@property (nonatomic,retain) IBOutlet UILabel* userEmail;
@property (nonatomic,retain) ASIHTTPRequest *httpRequest;

-(IBAction)backButtonTapped:(id)sender;
-(IBAction)noEmailButtonTapped:(id)sender;

@end
