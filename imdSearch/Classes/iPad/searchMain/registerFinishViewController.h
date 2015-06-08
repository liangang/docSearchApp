//
//  registerFinishViewController.h
//  imdSearch
//
//  Created by 立纲 吴 on 1/11/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface registerFinishViewController : UIViewController<UITextFieldDelegate>
{
    id delegate;
    
    BOOL registerSuccess;
}

@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) IBOutlet UITextField* fieldDepartment;
@property (nonatomic,retain) IBOutlet UITextField* fieldTitle;
@property (nonatomic,retain) IBOutlet UITextField* fieldHospital;

@property (nonatomic,retain) IBOutlet UIButton* leftButton;
@property (nonatomic,retain) IBOutlet UIButton* rightButton;
@property (nonatomic,retain) IBOutlet UIView* successView;
@property (nonatomic,retain) IBOutlet UIView* registerView;

@property (nonatomic,retain) IBOutlet UILabel* titleLabel;
@property (nonatomic,retain) IBOutlet UILabel* remarkRegister;
@property (nonatomic,retain) IBOutlet UILabel* remarkWord;
@property (nonatomic,copy) NSString *hospitalId;
@property (nonatomic,assign) BOOL isSelectHospital;
@property (strong, nonatomic) IBOutlet UIView *contentView;

-(void)displayRegisterSuccess;

-(IBAction)backButtonTapped:(id)sender;
-(IBAction)submitButtonTapped:(id)sender;

-(void)alertWithMsg:(NSString*)text;

-(IBAction)chooseDepartment:(id)sender;
-(IBAction)chooseTitle:(id)sender;
-(IBAction)chooseHospital:(id)sender;

@end
