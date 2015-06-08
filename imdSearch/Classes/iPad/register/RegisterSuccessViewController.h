//
//  RegisterSuccessViewController.h
//  imdSearch
//
//  Created by ding zhihong on 12-3-31.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterSuccessViewController : UIViewController
{
    NSString *mobileN;
    NSString *emailN;
}

@property (nonatomic,retain) id delegate;
@property (nonatomic, retain) UILabel* message;
@property (nonatomic, retain) UIButton* mailButton;
@property (nonatomic, retain) IBOutlet UIButton* mobileButton;
@property (nonatomic, retain) IBOutlet UILabel* mailLable;
@property (nonatomic,retain)IBOutlet UIImageView *imgmailA;
@property (nonatomic,retain) IBOutlet UIView *loadImageView;

- (IBAction)phoneActiveButtonTapped:(id)sender;
- (IBAction)mailActiveButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (void)postUserInfo:(NSString *)url userInfoDic:(NSMutableDictionary *)dic;
- (void)loginNewDailog;

@end
