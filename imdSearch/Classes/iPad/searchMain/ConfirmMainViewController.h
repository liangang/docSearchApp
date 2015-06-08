//
//  ConfirmMainViewController.h
//  imdSearch
//
//  Created by ding zhihong on 12-4-24.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmMainViewController : UIViewController
{
}

@property (nonatomic,retain) UILabel* info;
@property (nonatomic,retain) UIButton* emailConfirmButton;
@property (nonatomic,retain) UIButton* mobileConfirmButton;
@property (nonatomic,retain) UILabel* emailConfirmed;
@property (nonatomic,retain) UILabel* mobileConfirmed;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)mobileConfirmTapped:(id)sender;
- (IBAction)emailConfirmTapped:(id)sender;
@end
