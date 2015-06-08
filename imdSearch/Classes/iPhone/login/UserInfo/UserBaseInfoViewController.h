//
//  UserBaseInfoViewController.h
//  imdSearch
//
//  Created by xiangzhang on 9/24/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"

#define USERID              @"id"
#define USERTYPE            @"userType"
#define USERNAME            @"username"
#define USERREALNAME        @"realname"
#define USEREMAIL           @"email"
#define USERMOBILE          @"mobile"
#define USERDISPLAYNAME     @"displayName"
#define USEBASEINFORVERIFY  @"baseInfoVerified"
#define USERINFOCONFIRM     @"infoConfirmed"
#define USERINVITATIONCODE  @"invitationCode"       //文献卡code
#define USERADMISSIONYEAR   @"admissionYear"
#define USERGRADUATIONYEAR  @"graduationYear"
#define USERSCHOOL          @"school"
#define USERSTUDENTID       @"studentId"
#define USERDEGREE          @"degree"
#define USERMAJOR           @"major"
#define USERLICESEID        @"licenseId"
#define USERDOCTORTITLE     @"title"
#define USERDEPARTMENT      @"department"

#define USERHOSPITAL        @"hospital"
#define USERHOSPITALNAME    @"hospitalName"

@interface UserBaseInfoViewController : UIViewController<UITextFieldDelegate,ASIHTTPRequestDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

@property (copy, nonatomic) NSString *hospitalInfoId;
@property (assign, nonatomic) BOOL isSystemHospital;

@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentSelect;
@property (retain, nonatomic) IBOutlet UIView *baseInfoView;

@property (nonatomic, retain) NSMutableDictionary *modifyInfo;

@property (strong, nonatomic) IBOutlet UIView *baseSegmentView;
#pragma mark -- User Baseinfo Control
@property (retain, nonatomic) IBOutlet UITextField *baseUserNameInfo;
@property (retain, nonatomic) IBOutlet UIButton *modifyRealNameBtn;
@property (retain, nonatomic) IBOutlet UITextField *baseUserNikeInfo;
@property (retain, nonatomic) IBOutlet UIButton *modifyNikeInfoBtn;
@property (retain, nonatomic) IBOutlet UITextField *baseUserMobileInfo;
@property (retain, nonatomic) IBOutlet UIButton *useTypeVerified;
@property (retain, nonatomic) IBOutlet UILabel *baseUserType;
@property (retain, nonatomic) IBOutlet UIButton *modifyMobileInfoBtn;
@property (retain, nonatomic) IBOutlet UITextField *baseEmailInfo;
@property (retain, nonatomic) IBOutlet UIButton *baseEmailActiveBtn;
@property (retain, nonatomic) IBOutlet UIImageView *baseEmailEnterImg;
@property (retain, nonatomic) IBOutlet UILabel *baseDocCardId;
@property (retain, nonatomic) IBOutlet UILabel *baseDocStopTime;
@property (retain, nonatomic) IBOutlet UILabel *phoneVerifyInfo;
@property (retain, nonatomic) IBOutlet UILabel *emailVerifyInfo;
@property (retain, nonatomic) IBOutlet UILabel *docUpperlimitLable;
@property (strong, nonatomic) IBOutlet UIButton *baseUserTypeBtn;
#pragma mark -- education
@property (retain, nonatomic) IBOutlet UIView *educationInfoView;
@property (retain, nonatomic) IBOutlet UIView *educationBaseView;
@property (retain, nonatomic) IBOutlet UITextField *schollInfo;
@property (retain, nonatomic) IBOutlet UITextField *majorInfo;
@property (retain, nonatomic) IBOutlet UILabel *degreeInfo;
@property (retain, nonatomic) IBOutlet UILabel *enterTimeInfo;
@property (retain, nonatomic) IBOutlet UILabel *leaveTimeInfo;
@property (retain, nonatomic) IBOutlet UITextField *studentCardInfo;


#pragma mark -- profess info
@property (retain, nonatomic) IBOutlet UIView *professionInfoView;
@property (retain, nonatomic) IBOutlet UIView *professionBaseView;
@property (retain, nonatomic) IBOutlet UITextField *doctorLicenseInfo;
@property (retain, nonatomic) IBOutlet UILabel *hospitalLabel;
@property (retain, nonatomic) IBOutlet UILabel *departLabel;
@property (retain, nonatomic) IBOutlet UILabel *degreeLabel;
@property (nonatomic, retain) NSMutableDictionary *originInfo;
- (IBAction)selectSegmentClick:(id)sender;
#pragma mark - user baseinfo event
- (IBAction)clickModifyRealNameBtn:(id)sender;
- (IBAction)clickModifyNikeInfoBtn:(id)sender;
- (IBAction)clickModifyMobileInfoBtn:(id)sender;
- (IBAction)clickIdentitySelectBtn:(id)sender;
- (IBAction)clickEmailActiveBtn:(id)sender;
- (IBAction)clickModifyDocCardId:(id)sender;
- (IBAction)clickEmailInfoBtn:(id)sender;
- (IBAction)clickSelectUserTypeBtn:(id)sender;
#pragma mark - profession event 
- (IBAction)clickhospitalSelectBtn:(id)sender;
- (IBAction)clickDepartSelectBtn:(id)sender;
- (IBAction)clickTitleSelectBtn:(id)sender;
- (IBAction)clickDoctorLiceseInfoBtn:(id)sender;

#pragma mark - educationInfo event
- (IBAction)clickModifySchoolBtn:(id)sender;
- (IBAction)clickModifyMajorInfoBtn:(id)sender;
- (IBAction)clickModifyDegreeBtn:(id)sender;
- (IBAction)clickModifyEnterTimeBtn:(id)sender;
- (IBAction)clickModifyLeaveTimeBtn:(id)sender;
- (IBAction)clickModifyStudentCardBtn:(id)sender;

- (void)userMobileActiveSuccess;
- (void)getUserInfoWithRequest;
- (void)turnToSelectHospital;
@end
