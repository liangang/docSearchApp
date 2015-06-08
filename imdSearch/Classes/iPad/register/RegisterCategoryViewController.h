//
//  RegisterCategoryViewController.h
//  imdSearch
//
//  Created by ding zhihong on 12-4-5.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FTCoreTextView.h"
typedef enum {
  UNKonw = 0,
  PersonCenter,
  UserInfoCenter,
  RegisterSelect
}Select_UserType;
@interface RegisterCategoryViewController : UIViewController
{
    id delegate;
}

@property (nonatomic,retain) id delegate;
@property (strong, nonatomic) IBOutlet FTCoreTextView *remindInfo;
@property (assign, nonatomic) Select_UserType type;
@property (assign, nonatomic) NSString *userType;
-(IBAction)backButtonTapped:(id)sender;
-(IBAction)doctorsButtonTapped:(id)sender;
-(IBAction)studentsButtonTapped:(id)sender;

@end
