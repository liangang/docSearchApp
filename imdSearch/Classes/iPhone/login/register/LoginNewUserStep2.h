//
//  LoginNewUserStep2.h
//  imdSearch
//
//  Created by Huajie Wu on 11-12-12.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "LoginDepartment.h"
#import "LoginTitleController.h"
#import "ProvinceViewController.h"
@interface LoginNewUserStep2 : UIViewController <ASIHTTPRequestDelegate, UITextFieldDelegate,UIPickerViewDelegate,
UIPickerViewDataSource,UIActionSheetDelegate>
{
    IBOutlet UIActivityIndicatorView* indicator;
    UIAlertView* alertView;
    
    NSMutableDictionary* registerData;

  //For Doctor
  BOOL _isDoctor;
  UIView* _doctorContainer;
  IBOutlet UIButton* departmentBtn;
  IBOutlet UIButton* departmentD;
  IBOutlet UIButton* titleBtn;
  IBOutlet UIButton* titleD;
  IBOutlet UITextField* hospitalTF;    
  IBOutlet UILabel* hospitalLbl;
  IBOutlet UIButton *majorButton;
  IBOutlet UIButton *StarttimeButton;
  IBOutlet UIButton *EndtimeButton;
  UILabel *startLable;
  UILabel *endLable;
  //For Student
  UIView* _studentContainer;
  UITextField* _schoolTF;
  UITextField* _admissionYearTF;
  UITextField* _majorTF;
  UITextField* _degreeTF;
  UITextField* _studentIdTF;
  //End.

  LoginDepartment* dpCtr;
  LoginTitleController* titleCtr;
  ASIHTTPRequest* _httpRequest;
  
  UIPickerView *majorPickView;
  UIActionSheet* _sortAS;
  NSMutableArray *_pickerViewArray;
  NSArray *_pickerSortArray;
  NSInteger _pickerSelected;
  NSMutableArray *StarttimeArray;
  NSArray *EndtimeArray;
  NSString *timeOrmajor;
  NSString *hospital;
  NSString *hospitalId;
  ProvinceViewController* pro;
}
@property (nonatomic, retain) ASIHTTPRequest* httpRequest;


@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* indicator;
@property (nonatomic,retain) UIAlertView* alertView;
@property (nonatomic,retain) NSMutableDictionary* registerData;

//For Doctor
@property (nonatomic,assign) BOOL isDoctor;
@property (nonatomic,retain) IBOutlet UIView* doctorContainer;
@property (nonatomic,retain) IBOutlet UIButton* departmentBtn;
@property (nonatomic,retain) IBOutlet UIButton* departmentD;
@property (nonatomic,retain) IBOutlet UIButton* titleBtn;
@property (nonatomic,retain) IBOutlet UIButton* titleD;
@property (nonatomic,retain) IBOutlet UITextField* hospitalTF;
@property (nonatomic,retain) IBOutlet UILabel* hospitalLbl;

//For Student
@property (nonatomic,retain) IBOutlet UIView* studentContainer;
@property (nonatomic,retain) IBOutlet UITextField* schoolTF;
@property (nonatomic,retain) IBOutlet UITextField* admissionYearTF;
@property (nonatomic,retain) IBOutlet UITextField* majorTF;
@property (nonatomic,retain) IBOutlet UITextField* degreeTF;
@property (nonatomic,retain) IBOutlet UITextField* studentIdTF;
@property (nonatomic,retain) IBOutlet UIButton *majorButton;
@property (nonatomic,retain) IBOutlet UIButton *hospitalButton;
@property (nonatomic,retain) LoginDepartment* dpCtr;
@property (nonatomic,retain) LoginTitleController* titleCtr;
@property (nonatomic,retain) ProvinceViewController* pro;
@property (nonatomic,retain) NSMutableArray *pickerViewArray;
@property (nonatomic,retain) NSArray *pickerSortArray;
@property (nonatomic,assign) NSInteger pickerSelected;
@property (nonatomic,retain) UIActionSheet *sortAS;
@property (nonatomic,retain) NSMutableArray *StarttimeArray;
@property (nonatomic,retain) NSArray *EndtimeArray;
@property (nonatomic,retain) NSString *hospital;
@property (nonatomic,retain) NSString *hospitalId;
@property (nonatomic,retain) UILabel *startLable;
@property (nonatomic,retain) UILabel *endLable;
@property (strong, nonatomic) IBOutlet UIScrollView *contentSrcollView;

@property (strong, nonatomic) UIView *pickerView;
-(IBAction) doRegister:(id)sender;

-(IBAction) selectDepartment:(id)sender;
-(IBAction) selectTitle:(id)sender;
-(IBAction) selectXuewei:(UIButton *)button;
-(IBAction) selectHospital:(UIButton *)button;
-(void) userLoginFinished:(BOOL)animated;


-(void) popBack;
- (void)behaviorStudent:(NSString *)status;
- (void)behaviorDoctor:(NSString *)status;
@end
