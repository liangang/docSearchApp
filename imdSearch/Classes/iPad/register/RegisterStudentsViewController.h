//
//  RegisterStudentsViewController.h
//  imdSearch
//
//  Created by ding zhihong on 12-4-6.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterStudentsViewController : UIViewController<UIPopoverControllerDelegate,UITextFieldDelegate>
{
    id delegate;
    
    IBOutlet UITextField* graduateYear;
    IBOutlet UIButton* startTime;
    IBOutlet UIButton* endTime;
    UIPopoverController *educationLevelPopoverController;
    UIPopoverController *enterYearPopoverController;
    NSString* whatButton;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UITextField* onReadingSchool;
@property (nonatomic, retain) UITextField* enterSchoolYear;
@property (nonatomic, retain) UITextField* onReadingEducationLevel;
@property (nonatomic, retain) UITextField* onReadingPrefession;
@property (nonatomic, retain) UITextField* studentNumber;
@property (nonatomic, retain) UIButton* submit;
@property (nonatomic, retain) UIAlertView *alertV;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)enterSchoolYearButtonTapped:(UIButton *)sender;
- (IBAction)onReadingEducationLevelButtonTapped:(id)sender;
- (IBAction)onSubmitRegisterStudentsButtonTapped:(id)sender;

-(void)educationLevelSet:(NSString *) eduLevel;

@end
