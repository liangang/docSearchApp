//
//  UserInfoViewController.h
//  imdSearch
//
//  Created by  侯建政 on 11/29/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginDepartment.h"
#import "LoginTitleController.h"
#import "RealNameViewController.h"

@protocol DocArticleControlDelegate;
@interface UserInfoViewController : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate>
{
  UIPickerView *majorPickView;
  UIActionSheet* _sortAS;
  int temp;
}
@property (nonatomic,retain) NSArray *arrayDoctoInfocList;
@property (nonatomic,retain) NSArray *arrayStudentInfocList;
@property (nonatomic,copy) NSString *restHospital;
@property (nonatomic,copy) NSString *hospitalId;
@property (nonatomic,retain) UILabel *lableHospital;
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
@property (nonatomic,assign) int selectId;
@property (nonatomic,retain) UILabel *lable;
@property (nonatomic,retain) UIButton *button;
@property (nonatomic,retain) LoginDepartment* dpCtr;
@property (nonatomic,retain) LoginTitleController* titleCtr;
@property (nonatomic,retain) RealNameViewController* NameCtr;
@property (nonatomic,retain) UIAlertView *alert;
@property (nonatomic,retain) NSMutableArray *StarttimeArray;
@property (nonatomic,retain) UIActionSheet *sortAS;
@property (nonatomic,assign) NSInteger pickerSelected;
@property (nonatomic, retain) ASIHTTPRequest* httpRequest;
@property (nonatomic,retain) NSMutableArray *pickerViewArray;
@property (nonatomic,copy) NSString* departmentKey;
@property (nonatomic,copy) NSString* titleKey;
@property (nonatomic,retain) IBOutlet UIView *myLoadView;
@property (nonatomic,assign) BOOL isSelectHospital;
@property (nonatomic,copy) NSString *hospitalDataType;
@property (nonatomic, assign) id<DocArticleControlDelegate> delegate;
- (IBAction)selectSegment:(id)sender;
- (void) resetUserInfo:(id)sender;
@end
