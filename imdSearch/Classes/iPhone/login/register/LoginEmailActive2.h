//
//  LoginEmailActive2.h
//  imdSearch
//
//  Created by Huajie Wu on 12-4-19.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@interface LoginEmailActive2 : UIViewController <UIActionSheetDelegate, ASIHTTPRequestDelegate>
{
  UIButton* _emailActive;
  UIButton* _phoneCall;
}

@property (nonatomic, retain) IBOutlet UIButton* emailActive;
@property (nonatomic, retain) IBOutlet UIButton* phoneCall;
@property (nonatomic, retain) IBOutlet UIImageView *img;
-(IBAction)doEmailActive:(id)sender;
-(IBAction)doCall:(id)sender;
- (void)popBack:(id)sender;

@end
