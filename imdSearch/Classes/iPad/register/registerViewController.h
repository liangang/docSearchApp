//
//  registerViewController.h
//  imdSearch
//
//  Created by 立纲 吴 on 1/11/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface registerViewController : UIViewController<UITextFieldDelegate>
{
    BOOL mailChecked;
    BOOL mobileChecked;
}
@property (nonatomic,retain) id delegate;

@property (nonatomic,retain) IBOutlet UITextField* fieldEmail;
@property (nonatomic,retain) IBOutlet UITextField* fieldUserName;
@property (nonatomic,retain) IBOutlet UITextField* fieldPass;
@property (nonatomic,retain) IBOutlet UITextField* fieldPassConfirm;
@property (nonatomic,retain) IBOutlet UITextField* fieldNickName;
@property (nonatomic,retain) IBOutlet UITextField* fieldMobileTF;
@property (nonatomic,retain) IBOutlet UILabel* emailRegisted;
@property (nonatomic,retain) IBOutlet UIButton* nextButton;
@property (nonatomic,retain) IBOutlet UIButton* readPorotol;
@property (nonatomic,retain) IBOutlet UILabel* mobileRegisted;
@property (strong, nonatomic) IBOutlet UIView *content;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)nextButtonTapped:(id)sender;
- (IBAction)textFieldEditDidEnd:(id)sender;
- (IBAction)serviceProtocolButtonTapped:(id)sender;
- (IBAction)readPorotolTapped:(id)sender;
- (IBAction)fieldEmailTapped:(id)sender;
- (IBAction)fieldMobileTapped:(id)sender;
- (void)alertWithMsg:(NSString*)text;

- (void)checkMail;
@end
