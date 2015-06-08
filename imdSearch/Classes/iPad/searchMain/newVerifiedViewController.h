//
//  newVerifiedViewController.h
//  imdSearch
//
//  Created by  侯建政 on 12/5/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "registerDetailsViewController.h"
#import "sendEmailsViewController.h"
@interface newVerifiedViewController : UIViewController<UITextFieldDelegate,UIPopoverControllerDelegate>
{
    UIPopoverController *educationLevelPopoverController;
    UIPopoverController *enterYearPopoverController;
}
@property (nonatomic,assign) int selectId;
@property (nonatomic,retain) NSArray *arrayDoctoInfocList;
@property (nonatomic,retain) NSArray *arrayStudentInfocList;
@property (nonatomic,copy) NSString *restHospital;
@property (nonatomic,copy) NSString *hospitalId;
@property (nonatomic,retain) UILabel *fieldHospital;
@property (nonatomic,retain) UILabel *lableDepartment;
@property (nonatomic,retain) UILabel *lablePosition;
@property (nonatomic,retain) UITextField *lableStudentName;
@property (nonatomic,retain) UITextField *lableStudentSchool;
@property (nonatomic,retain) UITextField *lableStudentProfessional;
@property (nonatomic,retain) UILabel *lableStudentNumber;
@property (nonatomic,retain) UILabel *lableStudentStart;
@property (nonatomic,retain) UILabel *lableStudentEnd;
@property (nonatomic,retain) UILabel *lableStudentDegree;
@property (nonatomic,retain) IBOutlet UISegmentedControl *segment;
@property (nonatomic,retain) IBOutlet UITableView *myTable;
@property (nonatomic,retain) UILabel *lable;
@property (nonatomic,retain) registerDetailsViewController *detail;
@property (nonatomic,copy) NSString *whatButton;
@property (nonatomic,copy) NSString *hospitalDataType;
@property (nonatomic,copy) NSString *departmentKey;
@property (nonatomic,retain) UIButton *button;
@property (nonatomic,retain) UIAlertView *alert;
@property (nonatomic,assign) BOOL isSelectHospital;
@property (nonatomic,retain) IBOutlet UIView *retLoadView;
@property (nonatomic,retain) sendEmailsViewController *verForStudent;

- (IBAction)selectSegment:(id)sender;
-(IBAction)backButtonTapped:(id)sender;
@end
