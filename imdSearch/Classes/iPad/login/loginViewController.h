//
//  loginViewController.h
//  imdSearch
//
//  Created by 8fox on 10/21/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface loginViewController : UIViewController<UITextFieldDelegate>
{
    id delegate;
}

@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) IBOutlet UITextField* userName;
@property (nonatomic,retain) IBOutlet UITextField* password;

@property (nonatomic,retain) UIActivityIndicatorView* loadingIndicator;
@property (nonatomic,retain) UILabel* hintLabel;
@property (nonatomic,retain) UIButton* retryButton;
@property (nonatomic,retain) UIView* loadingCoverView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (IBAction)closeIt:(id)sender;
- (IBAction)registerNew:(id)sender;
- (IBAction)forgotPass:(id)sender;

//-(void)connectServerFailed;
- (void)connectionServerFinished;
- (void)connectServer;
- (void)prepareAuth;
- (IBAction)retryConnect;
- (void)loginSuccessfully;
- (void)loginFailWarning;
- (void)loginOKAlert;
- (void)registerloginFailWarning;

@end
