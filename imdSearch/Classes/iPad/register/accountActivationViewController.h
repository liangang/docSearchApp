//
//  accountActivationViewController.h
//  imdSearch
//
//  Created by ding zhihong on 12-3-31.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface accountActivationViewController : UIViewController<UIAlertViewDelegate>
{
    BOOL canCountSecond;
}

@property (nonatomic, retain) id delegate;
@property int waitingActionTime;
@property (nonatomic, retain) UILabel* waitingTime;
@property (nonatomic, retain) UITextField* activeNumber;
@property (nonatomic, retain) UIAlertView* timeOver;
@property (nonatomic, retain) UIAlertView* confirmSuccess;
@property (nonatomic, copy) NSString *mobileNumber;
-(IBAction)backButtonTapped:(id)sender;
-(IBAction)activeButtonTapped:(id)sender;

@end
