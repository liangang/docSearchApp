//
//  UserBaseInfoViewController.m
//  imdSearch
//
//  Created by xiangzhang on 9/24/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import "UserBaseInfoViewController.h"

#import "TableViewFormatUtil.h"
#import "ImageViews.h"
#import "Strings.h"
#import "myUrl.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "NSObject+SBJSON.h"

#import "LoginDepartment.h"
#import "LoginTitleController.h"
#import "ProvinceViewController.h"
#import "FindPWDAccountInfoViewController.h"
#import "DocCardInfoViewController.h"
#import "EmailActiveViewController.h"
#import "LoginSelectController.h"

#define SAVEUSERINFOTAG     2013092901
#define EMIALACTIVETAG      2013102401
#define MOBILEACTIVETAG     2013102402
#define DOCBINDTAG          2013101003
#define USEINFOSAVETAG      2013100801
#define USEINFOSAVESUCCESSTAG   2013100802

typedef enum {
    PickerTypeDegree = 0,
    PickerTypeStartTime,
    PickerTypeEndTime,
    PickerTypeUseType
}PickerType;

@interface UserBaseInfoViewController (){
    UIPickerView *majorPickView;
    PickerType pickerType;
    NSString *currentChangeKey;
    ASIHTTPRequest *request;
    ASIHTTPRequest *dailyRequest;
    BOOL isActiveEmail;
    BOOL isActiveMobile;
    BOOL isSave;
    BOOL studentVerify;
    BOOL doctorVerify;
}

@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic, retain) LoginDepartment *departmentViewController;
@property (nonatomic, retain) LoginTitleController *titleViewController;
@property (nonatomic, strong) LoginSelectController *selectUserTypeVC;

@property (nonatomic, retain) UIActionSheet *sortAS;
@property (nonatomic, assign) NSInteger pickerSelected;
@property (nonatomic, retain) NSMutableArray *starttimeArray;
@property (nonatomic, retain) NSMutableArray *endtimeArray;
@property (nonatomic, retain) NSMutableArray *pickerViewArray;
@property (nonatomic, retain) NSMutableArray *userTypeArray;
@property (nonatomic, strong) UIView *pickerView;
@end

@implementation UserBaseInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveUserInfo:)];
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_return"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissview:)];
        self.navigationItem.title = @"个人中心";
        isActiveMobile = FALSE;
        isActiveEmail = FALSE;
        isSave = FALSE;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.segmentSelect.selectedSegmentIndex = 0;
    [self selectSegmentClick:self.segmentSelect];
    
    [self.mainScrollView setContentSize:self.mainScrollView.frame.size];
    
    _departmentViewController = [[LoginDepartment alloc] init];
    _departmentViewController.delegate = self;
    
    _titleViewController = [[LoginTitleController alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.modifyInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mobilePhoneActive:) name:@"mobileNumberActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindDocCardSuccess:) name:@"bindDocCardSuccess" object:nil];
    
    [self getUserInfoWithRequest];
    [self getDailyLimitRequest];
    
    [self createSortPicker];
    
    self.baseEmailInfo.adjustsFontSizeToFitWidth = YES;
    self.baseEmailInfo.minimumFontSize = 10;
    
    [self setShadow:self.baseInfoView];
    [self setShadow:self.baseSegmentView];
    [self setShadow:self.educationBaseView];
    [self setShadow:self.professionBaseView];
    
    BOOL isIOS7 = IOS7;
    if (!isIOS7) {
        self.segmentSelect.layer.borderColor = APPDefaultColor.CGColor;
        self.segmentSelect.layer.borderWidth = 1.0f;
        self.segmentSelect.layer.cornerRadius = 4.0f;
        self.segmentSelect.layer.masksToBounds = YES;
    }
}

- (void) setShadow:(UIView *)view
{
    view.layer.shadowOpacity = 0.4;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowRadius = 1;
}

- (void)getUserInfoWithRequest{
     [UrlRequest send:[ImdUrlPath getUserInfo] delegate:self];
}

- (void)getDailyLimitRequest{
    NSURL *url = [NSURL URLWithString:[ImdUrlPath getDailylimit]];
    dailyRequest = [ASIHTTPRequest requestWithURL:url];
    [UrlRequest setToken:dailyRequest];
    dailyRequest.delegate = self;
    [dailyRequest setDidFinishSelector:@selector(dailylimitRequestFinish:)];
    [dailyRequest startAsynchronous];
}

- (void)viewWillAppear:(BOOL)animated{
  if (self.selectUserTypeVC.userType.length > 0) {
    self.baseUserTypeBtn.enabled = NO;
    self.baseUserType.text = [Strings getIdentity:self.selectUserTypeVC.userType];
    self.baseUserType.textColor = [UIColor blackColor];
    [self.modifyInfo setObject:[Strings getIdentityEncode:self.baseUserType.text] forKey:USERTYPE];
  }else
  {
    self.baseUserTypeBtn.enabled = YES;
    self.baseUserType.text = SELECT_USER_TYPE;
    self.baseUserType.textColor = [UIColor grayColor];
  }
  
    if (self.departmentViewController.currentCn.length > 0) {
        // 获取department的信息,添加显示
        self.departLabel.text = self.departmentViewController.currentCn;
        [self.modifyInfo setObject:self.departmentViewController.currentKey forKey:USERDEPARTMENT] ;
    }
    
    if (self.titleViewController.titleStr.length > 0) {
        if(![self.degreeLabel.text isEqualToString:self.titleViewController.titleStr]){
            
            self.degreeLabel.text = self.titleViewController.titleStr;
            
            [self.modifyInfo setObject:[Strings getPositionEN:self.degreeLabel.text] forKey:currentChangeKey];
        }
    }
    
    if (self.isSystemHospital) {
        [self.modifyInfo setObject:self.hospitalInfoId forKey:USERHOSPITAL];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [request clearDelegatesAndCancel];
    [dailyRequest clearDelegatesAndCancel];
}

- (void)viewDidUnload {
    [self setMainScrollView:nil];
    [self setSegmentSelect:nil];
    [self setBaseInfoView:nil];
    [self setEducationInfoView:nil];
    [self setProfessionInfoView:nil];
    [self setBaseUserNameInfo:nil];
    [self setBaseUserNikeInfo:nil];
    [self setBaseUserMobileInfo:nil];
    [self setBaseEmailInfo:nil];
    [self setModifyNikeInfoBtn:nil];
    [self setModifyMobileInfoBtn:nil];
    [self setBaseEmailActiveBtn:nil];
    [self setEducationBaseView:nil];
    [self setDoctorLicenseInfo:nil];
    [self setProfessionBaseView:nil];
    [self setSchollInfo:nil];
    [self setMajorInfo:nil];
    [self setDegreeInfo:nil];
    [self setEnterTimeInfo:nil];
    [self setLeaveTimeInfo:nil];
    [self setStudentCardInfo:nil];
    [self setHospitalLabel:nil];
    [self setDepartLabel:nil];
    [self setDegreeLabel:nil];
    [self setBaseDocCardId:nil];
    [self setBaseDocStopTime:nil];
    [self setBaseUserType:nil];
    [self setBaseEmailEnterImg:nil];
    [self setUseTypeVerified:nil];
    [self setPhoneVerifyInfo:nil];
    [self setEmailVerifyInfo:nil];
    [self setModifyRealNameBtn:nil];
    [self setDocUpperlimitLable:nil];
    [super viewDidUnload];
}

- (IBAction)dismissview:(id)sender{
    [self.view endEditing:YES];
    isSave = FALSE;
    
    if ([self.modifyInfo count] > 0) {
        [self saveUserAlertInfo];
    }else{
        [self dismissUseBaseInfoView];
    }
}

- (IBAction)saveUserInfo:(id)sender{
    [self.view endEditing:YES];
    
    isSave = YES;
    
    if ([self.modifyInfo count] <= 0) {
        return;
    }
    
    [self saveUserAlertInfo];
}

- (void)saveUserAlertInfo{
    
    NSArray *keys = [self.modifyInfo allKeys];
    
    BOOL isBaseVerify = [[self.originInfo objectForKey:USEBASEINFORVERIFY] boolValue];
    doctorVerify =  ([keys containsObject:USERREALNAME] || [keys containsObject:USERHOSPITAL] || [keys containsObject:USERDEPARTMENT] || [keys containsObject:USERDOCTORTITLE]);
    studentVerify = ([keys containsObject:USERREALNAME] || [keys containsObject:USERSCHOOL] || [keys containsObject:USERMAJOR] || [keys containsObject:USERDEGREE] || [keys containsObject:USERGRADUATIONYEAR] || [keys containsObject:USERADMISSIONYEAR] || [keys containsObject:USERSTUDENTID]);
    
    if (isSave) {
        [self userSaveAlertViewWithBaseVerify:isBaseVerify studentVerify:studentVerify doctorVerify:doctorVerify];
    }else{
        [self userCancelAlertViewWithBaseVerify:isBaseVerify studentVerify:studentVerify doctorVerify:doctorVerify];
    }
}

- (void)sendSaveUseInfoRequest{
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath saveUserInfo]]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    [UrlRequest setToken:request];
    [request appendPostData:[[[self recombinationUserModifyInfo] JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    request.delegate = self;
    request.tag = SAVEUSERINFOTAG;
    [request setDidFinishSelector:@selector(saveUserInfoFinish:)];
    [request startAsynchronous];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    BOOL isCancelReActive = (buttonIndex == 1 && (alertView.tag == EMIALACTIVETAG || alertView.tag == MOBILEACTIVETAG || alertView.tag == DOCBINDTAG));
    BOOL isEmileModify = (alertView.tag == EMIALACTIVETAG && buttonIndex == 0);
    BOOL isMobileModify = (alertView.tag == MOBILEACTIVETAG && buttonIndex == 0);
    BOOL isDocModify = (alertView.tag == DOCBINDTAG && buttonIndex == 0);
                         
    if ( alertView.tag == USEINFOSAVETAG && buttonIndex == 1) {
        
        [self sendSaveUseInfoRequest];
        
    }else if(alertView.tag == USEINFOSAVETAG && buttonIndex == 0){
        
        if (!isSave) [self dismissUseBaseInfoView];
        
    }else if(alertView.tag == 20131008 || isCancelReActive) {
        
        self.segmentSelect.selectedSegmentIndex = 0;
        [self selectSegmentClick:self.segmentSelect];
        
    }else if (isEmileModify){
        
        EmailActiveViewController *viewContoller = [[EmailActiveViewController alloc] init];
        viewContoller.originEmailInfo = self.baseEmailInfo.text;
        viewContoller.isActive = YES;
        [self.navigationController pushViewController:viewContoller animated:YES];
        
    }else if (isMobileModify){
        
        FindPWDAccountInfoViewController *viewController = [[FindPWDAccountInfoViewController alloc] init];
        viewController.type = ViewTypeModifyMobile;
        viewController.userAccount = self.baseUserMobileInfo.text;
        viewController.isActive = YES;
        viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }else if (isDocModify){
        
        DocCardInfoViewController *viewController = [[DocCardInfoViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
        
    }else if (alertView.tag == USEINFOSAVESUCCESSTAG){
        if (!isSave) {
            [self dismissUseBaseInfoView];
        }
    }
}

#pragma mark - main segment Click
- (IBAction)selectSegmentClick:(id)sender {
    [self.view endEditing:YES];
    
    NSInteger selectIndex = [sender selectedSegmentIndex];
    switch (selectIndex) {
        case 0:
            {
                self.baseInfoView.hidden = NO;
                self.professionInfoView.hidden = YES;
                self.educationInfoView.hidden = YES;
                [self.mainScrollView bringSubviewToFront:self.baseInfoView];
            }
            break;
        case 1:
            {
                self.baseInfoView.hidden = YES;
                self.professionInfoView.hidden = NO;
                self.educationInfoView.hidden = YES;
                [self.mainScrollView bringSubviewToFront:self.professionInfoView];
            }
            break;
        case 2:
            {
                self.baseInfoView.hidden = YES;
                self.professionInfoView.hidden = YES;
                self.educationInfoView.hidden = NO;
              self.educationInfoView.frame = CGRectMake(0, 67, 320, 334);
                [self.mainScrollView bringSubviewToFront:self.educationInfoView];
            }
            break;
        default:
            break;
    }
    
    //使用图片或者使用Button替换segmentControl
}

#pragma mark - baseInfo click
- (IBAction)clickSelectUserTypeBtn:(id)sender
{
  if (self.selectUserTypeVC == nil) {
    self.selectUserTypeVC = [[LoginSelectController alloc] init];
  }
  self.selectUserTypeVC.type = PersonCenter;
  [self.navigationController pushViewController:self.selectUserTypeVC animated:YES];
}
- (IBAction)clickModifyRealNameBtn:(id)sender {
    [self.view endEditing:YES];
    self.baseUserNameInfo.userInteractionEnabled = YES;
    self.currentTextField = self.baseUserNameInfo;
    [self.baseUserNameInfo becomeFirstResponder];
    
    currentChangeKey = USERREALNAME;
}

- (IBAction)clickModifyNikeInfoBtn:(id)sender {
    [self.view endEditing:YES];
    self.baseUserNikeInfo.userInteractionEnabled = YES;
    self.currentTextField = self.baseUserNikeInfo;
    [self.baseUserNikeInfo becomeFirstResponder];
    
    currentChangeKey = USERNAME;
}

- (IBAction)clickModifyMobileInfoBtn:(id)sender {
    [self.view endEditing:YES];

    if (self.baseUserMobileInfo.text != nil && isActiveMobile) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改手机号码" message:@"您是否要修改已激活的手机号码？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认",@"取消", nil];
        alertView.tag = MOBILEACTIVETAG;
        [alertView show];
    }else{
        FindPWDAccountInfoViewController *viewController = [[FindPWDAccountInfoViewController alloc] init];
        viewController.type = ViewTypeModifyMobile;
        viewController.activeType = AccountUnActived;
        viewController.userAccount = self.baseUserMobileInfo.text;
        viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    currentChangeKey = USERMOBILE;
}

- (IBAction)clickIdentitySelectBtn:(id)sender {
    [self.view endEditing:YES];
    pickerType = PickerTypeUseType;
    
    currentChangeKey = USERTYPE;
    [self showSortPicker];
}

- (IBAction)clickEmailActiveBtn:(id)sender {
    if (self.baseEmailInfo.text != nil && isActiveEmail) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改邮箱" message:@"您是否要修改已激活的邮箱？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认",@"取消", nil];
        alertView.tag = EMIALACTIVETAG;
        [alertView show];
    }else{
        EmailActiveViewController *viewContoller = [[EmailActiveViewController alloc] init];
        viewContoller.originEmailInfo = self.baseEmailInfo.text;
        
        [self.navigationController pushViewController:viewContoller animated:YES];
    }
}

- (IBAction)clickModifyDocCardId:(id)sender {
    if (self.baseDocCardId.text && ![self.baseDocCardId.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"绑定新文献卡" message:@"您是否要绑定新的文献卡？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认",@"取消", nil];
        alertView.tag = DOCBINDTAG;
        [alertView show];
    }else{
        //跳转页面
        DocCardInfoViewController *viewController = [[DocCardInfoViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    currentChangeKey = USERINVITATIONCODE;
}

- (IBAction)clickEmailInfoBtn:(id)sender {
    self.baseEmailInfo.userInteractionEnabled = YES;
    self.currentTextField = self.baseEmailInfo;
    [self.baseEmailInfo becomeFirstResponder];
    currentChangeKey = USEREMAIL;
}

#pragma mark - professInfo click
- (IBAction)clickhospitalSelectBtn:(id)sender {
    [self.view endEditing:YES];
    [self turnToSelectHospital];
    currentChangeKey = USERHOSPITAL;
}

- (IBAction)clickDepartSelectBtn:(id)sender {
    [self.view endEditing:YES];
    [self.departmentViewController requestDepartment];
    [self.navigationController pushViewController:self.departmentViewController animated:YES];
    currentChangeKey = USERDEPARTMENT;
}

- (IBAction)clickTitleSelectBtn:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController pushViewController:self.titleViewController animated:YES];
    currentChangeKey = USERDOCTORTITLE;
}

- (IBAction)clickDoctorLiceseInfoBtn:(id)sender {
    [self.view endEditing:YES];
    
    self.doctorLicenseInfo.userInteractionEnabled = YES;
    self.currentTextField = self.doctorLicenseInfo;
    [self.doctorLicenseInfo becomeFirstResponder];
    currentChangeKey = USERLICESEID;
}

#pragma mark - profession info selected 
- (void)turnToSelectHospital
{
    NSString* urlString = [NSString stringWithFormat:@"http://%@/hospital:cities?r=1352797588496",NEW_SERVER];
    ProvinceViewController *pro = [[ProvinceViewController alloc]init];
    pro.reset = @"RESET";
    [UrlRequest sendProvince:urlString delegate:pro];
    [self.navigationController pushViewController:pro animated:YES];
}

#pragma mark - educationInfo  Click
- (IBAction)clickModifySchoolBtn:(id)sender {
    self.schollInfo.userInteractionEnabled = YES;
    self.currentTextField = self.schollInfo;
    [self.schollInfo becomeFirstResponder];
    
    currentChangeKey = USERSCHOOL;
}

- (IBAction)clickModifyMajorInfoBtn:(id)sender {
    self.majorInfo.userInteractionEnabled = YES;
    self.currentTextField = self.majorInfo;
    [self.majorInfo becomeFirstResponder];
    
    currentChangeKey = USERMAJOR;
}

- (IBAction)clickModifyDegreeBtn:(id)sender {
    [self.view endEditing:YES];
    pickerType = PickerTypeDegree;
    [self showSortPicker];
    
    currentChangeKey = USERDEGREE;
}

- (IBAction)clickModifyEnterTimeBtn:(id)sender {
    [self.view endEditing:YES];
    pickerType = PickerTypeStartTime;
    [self showSortPicker];
    
    currentChangeKey = USERADMISSIONYEAR;
}

- (IBAction)clickModifyLeaveTimeBtn:(id)sender {
    [self.view endEditing:YES];
    pickerType = PickerTypeEndTime;
    [self showSortPicker];
    
    currentChangeKey = USERGRADUATIONYEAR;
}

- (IBAction)clickModifyStudentCardBtn:(id)sender {
    [self.view endEditing:YES];
    self.studentCardInfo.userInteractionEnabled = YES;
    self.currentTextField = self.studentCardInfo;
    [self.studentCardInfo becomeFirstResponder];
    
    currentChangeKey = USERSTUDENTID;
}

- (void)userMobileActiveSuccess{
    //[self.originInfo setObject:[NSNumber numberWithBool:Ture] forKey:@"mobileVerified"];
    [self initUserInfo];
}

#pragma mark - user info modify

- (void)mobilePhoneActive:(NSNotification *)notification{
    NSString *mobileNumber = [notification object];
    
    self.baseUserMobileInfo.text = mobileNumber;
    self.phoneVerifyInfo.text = @"已激活";
    
    [self.modifyInfo setObject:mobileNumber forKey:currentChangeKey];
}

- (void)bindDocCardSuccess:(NSNotification *)notification{
    NSDictionary *valueDic = [notification userInfo];
    self.doctorLicenseInfo.text = [valueDic objectForKey:@"cardNum"];
    
    self.baseDocStopTime.text = [NSString stringWithFormat:@"截止于 %@",[self convertExpireTimeToDate:[[valueDic objectForKey:@"expireDate"] longLongValue]]];
}

#pragma mark --keyboard Notification 
-(void)keyboardWillHide:(NSNotification *)notification
{
    [self.mainScrollView setContentOffset:CGPointZero animated:YES];
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    //键盘的大小
    CGSize keyboardRect = [aValue CGRectValue].size;
    
    CGRect rect =[self.currentTextField.superview convertRect:self.currentTextField.frame toView:self.mainScrollView];
    
    CGFloat height = rect.origin.y + rect.size.height + 22;
    
    [self.mainScrollView setContentOffset:CGPointMake(0, (height - keyboardRect.height) > 0 ? (height - keyboardRect.height) : 0) animated:YES]; 
}

#pragma mark - UITextField Delegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    textField.userInteractionEnabled = NO;
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
  if (textField.text.length ==0 | [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
    
  }else
    [self.modifyInfo setObject:textField.text forKey:currentChangeKey];
    
    return YES;
}

#pragma mark - UIPickerView
- (void)showSortPicker{
  if (IOS8) {
    CGFloat pickerViewYposition = self.view.frame.size.height - self.pickerView.frame.size.height;
    [UIView animateWithDuration:0.5f
                     animations:^{
                       [self.pickerView setFrame:CGRectMake(self.pickerView.frame.origin.x,
                                                       pickerViewYposition,
                                                       self.pickerView.frame.size.width,
                                                       self.pickerView.frame.size.height)];
                     }
                     completion:nil];
  }else
  {
    [self.sortAS showInView:self.view];
    [self.sortAS setBounds:CGRectMake(0, 0, 320, 480)];
  }
  
    [majorPickView reloadAllComponents];
}

- (void)createSortPicker{
    self.pickerViewArray = [NSMutableArray arrayWithObjects:
                            SELECT_XUESHI,
                            SELECT_SHUOSHI,
                            SELECT_BOSHI,
                            nil];
    
    self.userTypeArray = [NSMutableArray arrayWithObjects:@"临床医师",@"医学院学生",nil];
    self.StarttimeArray = [[NSMutableArray alloc] initWithCapacity:63-8];
    self.endtimeArray = [[NSMutableArray alloc] initWithCapacity:63];
    NSDateFormatter *nsdf2 = [[NSDateFormatter alloc] init];
    [nsdf2 setDateStyle:NSDateFormatterShortStyle];
    [nsdf2 setDateFormat:@"YYYY"];
    NSString* maxYear = [nsdf2 stringFromDate:[NSDate date]];
    
    for (int i = 0; i < 63-8; i++)
    {
        [self.starttimeArray addObject:[NSString stringWithFormat:@"%i", (maxYear.intValue - i)]];
    }
  for (int i = 0; i < 63; i++)
  {
    [self.endtimeArray addObject:[NSString stringWithFormat:@"%i", (maxYear.intValue+8 - i)]];
  }
    majorPickView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    //  _sortPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin;
    
    [majorPickView setFrame:CGRectMake(0, 40, 320, 216)];
    majorPickView.showsSelectionIndicator = YES;
    
    majorPickView.delegate = self;
    majorPickView.dataSource = self;
  
  if (IOS8) {
    if (!self.pickerView) {
      self.pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 320, 280)];
    } else {
      [self.pickerView setHidden:NO];
    }
    [majorPickView setFrame:CGRectMake(0, 35, majorPickView.frame.size.width, majorPickView.frame.size.height)];
    
    CGFloat pickerViewYpositionHidden = self.view.frame.size.height + self.pickerView.frame.size.height;
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:EDIT_DONE_CN]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = RGBCOLOR(34, 96, 221);
    [closeButton addTarget:self action:@selector(doSortSearch:) forControlEvents:UIControlEventValueChanged];
    [self.pickerView addSubview:closeButton];
    
    UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:TEXT_CANCEL]];
    cancelButton.momentary = YES;
    cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
    cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
    cancelButton.tintColor = [UIColor blackColor];
    [cancelButton addTarget:self action:@selector(cancelSortSearch:) forControlEvents:UIControlEventValueChanged];
    [self.pickerView addSubview:cancelButton];
    
    [self.pickerView setFrame:CGRectMake(self.pickerView.frame.origin.x,
                                         pickerViewYpositionHidden,
                                         self.pickerView.frame.size.width,
                                         self.pickerView.frame.size.height)];
    [self.pickerView setBackgroundColor:[UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:0.99]];
      //[self.pickerView addSubview:controlToolbar];
    [self.pickerView addSubview:majorPickView];
    [majorPickView setHidden:NO];
    [self.view addSubview:self.pickerView];
  }else
  {
    self.sortAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:EDIT_DONE_CN]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = RGBCOLOR(34, 96, 221);
    [closeButton addTarget:self action:@selector(doSortSearch:) forControlEvents:UIControlEventValueChanged];
    [_sortAS addSubview:closeButton];
    
    UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:TEXT_CANCEL]];
    cancelButton.momentary = YES;
    cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
    cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
    cancelButton.tintColor = [UIColor blackColor];
    [cancelButton addTarget:self action:@selector(cancelSortSearch:) forControlEvents:UIControlEventValueChanged];
    [_sortAS addSubview:cancelButton];
    
    [_sortAS addSubview:majorPickView];
    [_sortAS setBounds:CGRectMake(0, 0, 320, 480)];
  }
}

#pragma mark UIPickerViewDataSource
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    if (pickerType == PickerTypeDegree) {
        label.text = [self.pickerViewArray objectAtIndex:row];
    }else if(pickerType == PickerTypeUseType){
        label.text = [self.userTypeArray objectAtIndex:row];
    }else if(pickerType == PickerTypeStartTime){
        label.text = [self.starttimeArray objectAtIndex:row];
    }else if(pickerType == PickerTypeEndTime){
      label.text = [self.endtimeArray objectAtIndex:row];
    }
  
    label.font = [UIFont fontWithName:FONT_BOLD size:FONT_4];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSMutableArray *tempArray;
    if (pickerType == PickerTypeDegree) {
        tempArray = self.pickerViewArray;
    } else if(pickerType == PickerTypeUseType){
        tempArray = self.userTypeArray;
    } else if(pickerType == PickerTypeStartTime){
      tempArray = self.starttimeArray ;
    }else if(pickerType == PickerTypeEndTime){
      tempArray = self.endtimeArray;
    }
    return [tempArray count];
}

-(void)doSortSearch:(UIPickerView*) sortPicker
{
    self.pickerSelected = [majorPickView selectedRowInComponent:0];
    
    if (pickerType == PickerTypeDegree) {
        self.degreeInfo.text = [self.pickerViewArray objectAtIndex:self.pickerSelected];
        [self cancelSortSearch:nil];
        [self.modifyInfo setObject:[Strings getDegreeEN:self.degreeInfo.text] forKey:currentChangeKey];
        
        return;
        
    } else if(pickerType == PickerTypeUseType){
        self.baseUserType.text = [self.userTypeArray objectAtIndex:self.pickerSelected];
        
        [self cancelSortSearch:nil];
        [self.modifyInfo setObject:[Strings getIdentityEncode:self.baseUserType.text] forKey:currentChangeKey];
    }else if(pickerType == PickerTypeStartTime) {
        self.enterTimeInfo.text = [self.starttimeArray objectAtIndex:self.pickerSelected];
        
        [self.modifyInfo setObject:[NSNumber numberWithInteger:[self.enterTimeInfo.text integerValue]] forKey:currentChangeKey];
        
    } else if(pickerType == PickerTypeEndTime) {
        self.leaveTimeInfo.text = [self.endtimeArray objectAtIndex:self.pickerSelected];
        
        [self.modifyInfo setObject:[NSNumber numberWithInteger:[self.leaveTimeInfo.text integerValue]] forKey:currentChangeKey];
        
    }
    
    NSString * start = self.enterTimeInfo.text;
    NSString * end = self.leaveTimeInfo.text;
    
    if (![start isEqualToString:@""] && ![end isEqualToString:@""]) {
        if ([start intValue] >= [end intValue]) {
            UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您选择的日期不正确" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alerts show];
            
            if (pickerType == PickerTypeStartTime) {
                self.enterTimeInfo.text = [[self.originInfo objectForKey:USERADMISSIONYEAR] stringValue];
                [self.modifyInfo removeObjectForKey:USERADMISSIONYEAR];
            }else{
                self.leaveTimeInfo.text = [[self.originInfo objectForKey:USERGRADUATIONYEAR] stringValue];
                [self.modifyInfo removeObjectForKey:USERGRADUATIONYEAR];
            }
        }
    }
    
    [self cancelSortSearch:nil];
}

-(void) updateSortPicker:(NSInteger)selected
{
    self.pickerSelected = 0;
    [majorPickView selectRow:selected inComponent:0 animated:NO];
}

-(void)cancelSortSearch:(UIPickerView*) sortPicker
{
  if (IOS8) {
    CGFloat pickerViewYpositionHidden = self.view.frame.size.height + self.pickerView.frame.size.height;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                       [self.pickerView setFrame:CGRectMake(self.pickerView.frame.origin.x,
                                                       pickerViewYpositionHidden,
                                                       self.pickerView.frame.size.width,
                                                       self.pickerView.frame.size.height)];
                     }
                     completion:nil];
  }else
    [self.sortAS dismissWithClickedButtonIndex:0 animated:YES];
    [self updateSortPicker:0];
}

#pragma mark -anyRequest
- (void)dailylimitRequestFinish:(ASIHTTPRequest *)request_{
     NSLog(@"info : %@",[request_ responseString]);
    NSDictionary *limitInfo = [UrlRequest getJsonValue:request_];
    
    NSInteger num = [[limitInfo objectForKey:@"limit"] intValue];
    NSString *limitStr = nil;
    if (num >= 500){
        limitStr = @"VIP";
    }else{
        limitStr = [NSString stringWithFormat:@"%d篇/天",num];
    }
    
    [self.docUpperlimitLable setText:limitStr];
}

-(void)requestFinished:(ASIHTTPRequest*)request_
{
    NSLog(@"%@",[request_ responseString]);
    NSDictionary* userInfo = [UrlRequest getJsonValue:request_];
    if ([userInfo count] > 1) {
        NSMutableDictionary *infoDic = [userInfo objectForKey:@"info"];
        [infoDic setObject:[userInfo objectForKey:USERHOSPITALNAME] forKey:USERHOSPITALNAME];
        NSDictionary *hospitalInfo = [infoDic objectForKey:USERHOSPITAL];
        NSDictionary *studentInfo = [infoDic objectForKey:@"studentInfo"];
        NSDictionary *doctorInfo  = [infoDic objectForKey:@"doctorInfo"];
        NSDictionary *userVerifyInfo  = [infoDic objectForKey:@"userVerifyInfo"];
        
        [infoDic removeObjectsForKeys:@[@"studentInfo",@"doctorInfo",@"userVerifyInfo"]];
        
        for (NSString *key in [studentInfo allKeys]) {
            [infoDic setObject:[studentInfo objectForKey:key] forKey:key];
        }
        
        for (NSString *key in [doctorInfo allKeys]) {
            [infoDic setObject:[doctorInfo objectForKey:key] forKey:key];
        }
        
        for (NSString *key in [userVerifyInfo allKeys]) {
            [infoDic setObject:[userVerifyInfo objectForKey:key] forKey:key];
        }
        
        for (NSString *key in [hospitalInfo allKeys]) {
            [infoDic setObject:[hospitalInfo objectForKey:key] forKey:key];
        }
        
        self.originInfo = infoDic;
        [self initUserInfo];
    }
}

- (void)saveUserInfoFinish:(ASIHTTPRequest *)request_{
   NSDictionary *saveInfo = [UrlRequest getJsonValue:request_];

    BOOL isVerify = [[self.originInfo objectForKey:USEBASEINFORVERIFY] boolValue];      //是否为已验证用户
    
    if ([[saveInfo objectForKey:@"success"] boolValue]) {
        [self userRequestFinishAlertViewWithBaseVerify:isVerify studentVerify:studentVerify doctorVerify:doctorVerify];
        
        if (studentVerify || doctorVerify) {
            [self.useTypeVerified setTitle:@"未实名验证" forState:UIControlStateNormal];
        }
        
        //重置用户的原始信息，保证二次修改时的初始信息正确
        [self.modifyInfo removeAllObjects];
    }else{
        
        [self showAlertView:nil contentInfo:@"帐号信息保存失败，请稍后重试"];
    }
}

-(void)requestFailed:(ASIHTTPRequest*)requests
{
    NSLog(@"request failed");
  if ([requests.error code] == ASIRequestTimedOutErrorType) {
    [self showAlertView:HINT_TEXT contentInfo:REQUEST_TIMEOUT_MESSAGE];
  }else
    [self showAlertView:@"睿医" contentInfo:@"网络出错-­‐请检查网络设置"];
}

- (void)initUserInfo{
    self.baseUserNameInfo.text = [self.originInfo objectForKey:USERREALNAME];
    self.baseUserNikeInfo.text = [self.originInfo objectForKey:USERNAME];
    self.baseUserMobileInfo.text = [self.originInfo objectForKey:USERMOBILE];
    self.baseEmailInfo.text = [self.originInfo objectForKey:USEREMAIL];
    self.baseDocCardId.text = [self.originInfo objectForKey:USERINVITATIONCODE];
    self.baseUserType.text = [Strings getIdentity:[self.originInfo objectForKey:USERTYPE]];
  if (![self.baseUserType.text isEqualToString:SELECT_USER_TYPE]) {
    self.baseUserTypeBtn.enabled = NO;
    self.baseUserType.textColor = [UIColor blackColor];
  }
  if (self.baseUserType.text.length == 0) {
    self.baseUserTypeBtn.enabled = YES;
    self.baseUserType.text = SELECT_USER_TYPE;
    self.baseUserType.textColor = [UIColor grayColor];
  }
    self.hospitalLabel.text = [self.originInfo objectForKey:USERHOSPITALNAME];
    self.departLabel.text = [Strings getDepartmentString:[self.originInfo objectForKey:USERDEPARTMENT]];
    self.degreeLabel.text = [Strings getPosition:[self.originInfo objectForKey:USERDOCTORTITLE]];
    self.doctorLicenseInfo.text = [self.originInfo objectForKey:USERLICESEID];
    
    long long time = [[self.originInfo objectForKey:@"invitationCodeExpireTime"] longLongValue];
    if (time > 0) {
        NSString *timeStr = [self convertExpireTimeToDate:[[self.originInfo objectForKey:@"invitationCodeExpireTime"] longLongValue]];
        self.baseDocStopTime.text = [NSString stringWithFormat:@"有效期至 %@",timeStr];
    }else{
        self.baseDocStopTime.text = @"未绑定";
    }
  
    self.schollInfo.text = [self.originInfo objectForKey:USERSCHOOL];
    self.majorInfo.text = [self.originInfo objectForKey:USERMAJOR];
    self.degreeInfo.text = [Strings getDegree:[self.originInfo objectForKey:USERDEGREE]];
    
    if ([self.originInfo objectForKey:USERADMISSIONYEAR]) {
        self.enterTimeInfo.text = [NSString stringWithFormat:@"%@",[self.originInfo objectForKey:USERADMISSIONYEAR]] ;
    }
    
    if ([self.originInfo objectForKey:USERGRADUATIONYEAR]) {
        self.leaveTimeInfo.text = [NSString stringWithFormat:@"%@",[self.originInfo objectForKey:USERGRADUATIONYEAR]];
    }
    
    if ([self.originInfo objectForKey:USERSTUDENTID]) {
        self.studentCardInfo.text = [NSString stringWithFormat:@"%@",[self.originInfo objectForKey:USERSTUDENTID]];
    }
    
    isActiveEmail = [[self.originInfo objectForKey:@"emailVerified"] boolValue];
    isActiveMobile = [[self.originInfo objectForKey:@"mobileVerified"] boolValue];
    if (self.baseEmailInfo.text && ![self.baseEmailInfo.text isEqualToString:@""]) {
        self.emailVerifyInfo.hidden = NO;
        self.emailVerifyInfo.text = isActiveEmail ? @"已激活" : @"未激活";
    }else{
        self.emailVerifyInfo.text = @"添加";
    }
    
    if (self.baseUserMobileInfo.text && ![self.baseUserMobileInfo.text isEqualToString:@""]) {
        self.phoneVerifyInfo.hidden = NO;
        self.phoneVerifyInfo.text = isActiveMobile ? @"已激活" : @"未激活";
    }else{
        self.phoneVerifyInfo.text = @"添加";
    }
    
    BOOL isBaseVerify = [[self.originInfo objectForKey:USEBASEINFORVERIFY] boolValue];
    if (isBaseVerify) {
        self.modifyRealNameBtn.hidden = YES;
        [self.useTypeVerified setTitle:@"实名验证" forState:UIControlStateNormal];
    }else{
        self.modifyRealNameBtn.hidden = NO;
        [self.useTypeVerified setTitle:@"未实名验证" forState:UIControlStateNormal];
    }
}

- (NSDictionary *)recombinationUserModifyInfo{
    NSMutableDictionary *sendDic = [NSMutableDictionary dictionaryWithDictionary:self.modifyInfo];
    NSMutableDictionary *doctorDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableDictionary *studentDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableDictionary *hospitalDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableSet *doctorSet = [NSMutableSet setWithArray:@[USERDEPARTMENT,USERDOCTORTITLE,USERLICESEID]];
    
    NSMutableSet *studentSet = [NSMutableSet setWithArray: @[USERSCHOOL,USERMAJOR,USERDEGREE,USERADMISSIONYEAR,USERGRADUATIONYEAR,USERSTUDENTID]];
    
    NSArray *keys = [self.modifyInfo allKeys];
    
    NSSet *allSet = [NSSet setWithArray:keys];
    
    [doctorSet intersectSet:allSet];
    for (NSString *key in doctorSet) {
        [doctorDic setObject:[sendDic objectForKey:key] forKey:key];
        [sendDic removeObjectForKey:key];
    }
    
    if (self.isSystemHospital) {
        [hospitalDic setObject:self.hospitalInfoId forKey:@"hospitalId"];
        [hospitalDic setObject:@"System" forKey:@"hospitalDataType"];
        [doctorDic setObject:hospitalDic forKey:@"hospital"];
    }
    [sendDic setObject:doctorDic forKey:@"doctorInfo"];
    
    [studentSet intersectSet:allSet];
    for (NSString *key in studentSet) {
        [studentDic setObject:[sendDic objectForKey:key] forKey:key];
        [sendDic removeObjectForKey:key];
    }
    
    [sendDic setObject:studentDic forKey:@"studentInfo"];
    
    return sendDic;
}

- (void)showAlertView:(NSString *)title contentInfo:(NSString *)content{
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    alerView.tag = 20131008;
    [alerView show];
}

- (void)dismissUseBaseInfoView{
    int n = [self.navigationController.childViewControllers count];
    if (n>1)
    {
        //push
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        //present
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)getNonNilString:(NSString *)userString{
    return userString == nil ? @"" : userString;
}

- (NSString *)convertExpireTimeToDate:(long long)expireTimes{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:expireTimes];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY.MM.dd"];
    
    return [formatter stringFromDate:date];
}

- (void)userSaveAlertViewWithBaseVerify:(BOOL)baseVerify_ studentVerify:(BOOL)studentVerify_ doctorVerify:(BOOL)doctorVerify_{
    if ([[self.originInfo objectForKey:USERTYPE] isEqualToString:USERTYPE_STUDENT]) {
        
        if (baseVerify_ && studentVerify_) {
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"帐号信息修改确认" message:@"请您确认修改个人帐号信息。帐号信息修改后，我们将再次对您进行身份验证。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alerView.tag = USEINFOSAVETAG;
            [alerView show];
        }else{
            [self sendSaveUseInfoRequest];
        }
        
    }else if ([[self.originInfo objectForKey:USERTYPE] isEqualToString:USERTYPE_DOCTOR]) {
        
        if (baseVerify_ && doctorVerify_) {
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"帐号信息修改确认" message:@"请您确认要修改个人帐号信息。帐号信息修改后，我们将再次对您进行身份验证。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alerView.tag = USEINFOSAVETAG;
            [alerView show];
        }else{
            [self sendSaveUseInfoRequest];
        }
    }else
    {
      UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"帐号信息修改确认" message:@"您的帐号信息已修改，是否保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
      alerView.tag = USEINFOSAVETAG;
      [alerView show];
    }
}

- (void)userRequestFinishAlertViewWithBaseVerify:(BOOL)baseVerify_ studentVerify:(BOOL)studentVerify_ doctorVerify:(BOOL)doctorVerify_{
    if ([[self.originInfo objectForKey:USERTYPE] isEqualToString:USERTYPE_STUDENT]) {
        if (baseVerify_ && studentVerify_) {
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"信息修改成功" message:@"帐号信息修改成功，请将学生证等身份证件完整扫描后发送到verify@i-md.com" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alerView.tag = USEINFOSAVESUCCESSTAG;
            [alerView show];
        }else{
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil message:@"帐号信息修改成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alerView.tag = USEINFOSAVESUCCESSTAG;
            [alerView show];
        }

    }else if ([[self.originInfo objectForKey:USERTYPE] isEqualToString:USERTYPE_DOCTOR]) {
        
        if (doctorVerify_) {
            if (baseVerify_) {
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"信息修改成功" message:@"帐号信息修改成功，我们将在两个工作日内完成您的身份验证。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alerView.tag = USEINFOSAVESUCCESSTAG;
                [alerView show];
            }else{
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"信息修改成功" message:@"您的帐号信息修改成功，我们将在两个工作日内完成对您的身份验证。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alerView.tag = USEINFOSAVESUCCESSTAG;
                [alerView show];
            }
        }else{
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil message:@"帐号信息修改成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alerView.tag = USEINFOSAVESUCCESSTAG;
            [alerView show];
        }
    }else{
      UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil message:@"帐号信息修改成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
      alerView.tag = USEINFOSAVESUCCESSTAG;
      [alerView show];
    }
}

- (void)userCancelAlertViewWithBaseVerify:(BOOL)baseVerify_ studentVerify:(BOOL)studentVerify_ doctorVerify:(BOOL)doctorVerify_{
    
    if ([[self.originInfo objectForKey:USERTYPE] isEqualToString:USERTYPE_STUDENT]) {
        if (baseVerify_ && studentVerify_) {
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"信息修改未保存" message:@"您的帐号信息已修改，是否保存？保存后，我们将再次对您进行身份验证。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alerView.tag = USEINFOSAVETAG;
            [alerView show];
        }else{
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"信息修改未保存" message:@"您的帐号信息已修改，是否保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
            alerView.tag = USEINFOSAVETAG;
            [alerView show];
        }
        
    }else if ([[self.originInfo objectForKey:USERTYPE] isEqualToString:USERTYPE_DOCTOR]) {
        
        if (baseVerify_ && doctorVerify) {
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"信息修改未保存" message:@"您的帐号信息已修改，是否保存？保存后，我们将再次对您进行身份验证。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
                alerView.tag = USEINFOSAVETAG;
                [alerView show];
        }else{
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"信息修改未保存" message:@"您的帐号信息已修改，是否保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
            alerView.tag = USEINFOSAVETAG;
            [alerView show];
        }
        
    }else
    {
      UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"信息修改未保存" message:@"您的帐号信息已修改，是否保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
      alerView.tag = USEINFOSAVETAG;
      [alerView show];
    }
}
@end
