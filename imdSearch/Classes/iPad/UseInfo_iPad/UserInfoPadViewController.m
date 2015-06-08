//
//  UserInfoPadViewController.m
//  imdSearch
//
//  Created by xiangzhang on 10/25/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import "UserInfoPadViewController.h"

#import "ImdUrlPath.h"
#import "Strings.h"
#import "ImageViews.h"
#import "myUrl.h"
#import "UrlRequest.h"
#import "NSObject+SBJSON.h"

#import "imdSearchAppDelegate.h"
#import "registerDetailsViewController.h"
#import "EnterYearViewController.h"
#import "EducationLevelTableViewController.h"

#import "LoginDepartment.h"
#import "LoginTitleController.h"
#import "ProvinceViewController.h"

#import "FindPWDAccountInfoPadViewController.h"
#import "DocCardInfoPadViewController.h"
#import "EmailActivePadViewController.h"
#import "RegisterCategoryViewController.h"

#define SAVEUSERINFOTAG     2013092901
#define EMIALACTIVETAG      2013102401
#define MOBILEACTIVETAG     2013102402
#define DOCBINDTAG          2013101003
#define USEINFOSAVETAG      2013100801
#define USEINFOSAVESUCCESSTAG   2013100802


@interface UserInfoPadViewController (){
    int selectType;
    NSString *changeType;
    
    ASIHTTPRequest *request;
    ASIHTTPRequest *dailyLimitRequest;
    BOOL isActiveEmail;
    BOOL isActiveMobile;
    BOOL isSave;
    BOOL studentVerify;
    BOOL doctorVerify;
}

@property (nonatomic, retain) UITextField *currentTextField;

@property (nonatomic, retain) NSMutableArray *userTypeArray;

@property (nonatomic, strong) RegisterCategoryViewController *selectUserTypeVC;

@end

@implementation UserInfoPadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
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
    [self studentPopover];
    
    self.segmentSelect.selectedSegmentIndex = 0;
    [self selectSegmentClick:self.segmentSelect];
    
    [self.mainScrollView setContentSize:self.mainScrollView.frame.size];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.modifyInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mobilePhoneActive:) name:@"mobileNumberActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindDocCardSuccess:) name:@"bindDocCardSuccess" object:nil];
    
    [self getUserInfoWithRequest];
    [self getDailyLimitInfoRequest];
    
    self.baseEmailInfo.adjustsFontSizeToFitWidth = YES;
    self.baseEmailInfo.minimumFontSize = 10;
    
    if (!(IOS7)) {
        self.segmentSelect.layer.borderColor = APPDefaultColor.CGColor;
        self.segmentSelect.layer.borderWidth = 1.0f;
        self.segmentSelect.layer.cornerRadius = 4.0f;
        self.segmentSelect.layer.masksToBounds = YES;
    }
    
    [self setShadow:self.baseInfoView];
    [self setShadow:self.educationBaseView];
    [self setShadow:self.professionBaseView];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"departmentInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  
  [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"title"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    NSString *temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"title"];
    if (temp.length > 0) {
        self.degreeLabel.text = temp;
        [self.modifyInfo setObject:[Strings getPositionEN:temp] forKey:USERDOCTORTITLE];
    }
    
    NSDictionary *department = [[NSUserDefaults standardUserDefaults] objectForKey:@"departmentInfo"];
    if ([department count]) {
        self.departLabel.text = [department objectForKey:@"cnDepartment"];
        [self.modifyInfo setObject:[department objectForKey:@"key"] forKey:USERDEPARTMENT] ;
        
    }
    
    if (self.isSystemHospital) {
        [self.modifyInfo setObject:self.hospitalInfoId forKey:USERHOSPITAL];
    }
}

- (void) setShadow:(UIView *)view
{
    view.layer.shadowOpacity = 0.4;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowRadius = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self setDailylimitLabel:nil];
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
    
    [UrlRequest setPadToken:request];
    [request appendPostData:[[[self recombinationUserModifyInfo] JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    request.delegate = self;
    request.tag = SAVEUSERINFOTAG;
    [request setDidFinishSelector:@selector(saveUserInfoFinish:)];
    [request startAsynchronous];
}

- (void)getDailyLimitInfoRequest{
    dailyLimitRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[ImdUrlPath getDailylimit]]];
    [UrlRequest setPadToken:dailyLimitRequest];
    dailyLimitRequest.delegate = self;
    [dailyLimitRequest setDidFinishSelector:@selector(getDailylimitRequest:)];
    [dailyLimitRequest startAsynchronous];
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
        
        EmailActivePadViewController *viewContoller = [[EmailActivePadViewController alloc] init];
        viewContoller.originEmailInfo = self.baseEmailInfo.text;
        viewContoller.isActive = YES;
        [self.navigationController pushViewController:viewContoller animated:YES];
        
    }else if (isMobileModify){
        
        FindPWDAccountInfoPadViewController *viewController = [[FindPWDAccountInfoPadViewController alloc] init];
        viewController.type = ViewTypeModifyMobile;
        viewController.userAccount = self.baseUserMobileInfo.text;
        viewController.isActive = YES;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }else if (isDocModify){
        
        DocCardInfoPadViewController *viewController = [[DocCardInfoPadViewController alloc] init];
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
            [self.mainScrollView bringSubviewToFront:self.educationInfoView];
        }
            break;
        default:
            break;
    }

}

- (void)getUserInfoWithRequest{
  [self getUserInfo:[ImdUrlPath getUserInfo] delegate:self];
}

#pragma mark - baseInfo click
- (IBAction)clickSelectUserTypeBtn:(id)sender
{
  if (self.selectUserTypeVC == nil) {
    self.selectUserTypeVC = [[RegisterCategoryViewController alloc] init];
  }
  self.selectUserTypeVC.type = PersonCenter;
  [self.navigationController pushViewController:self.selectUserTypeVC animated:YES];
}
- (IBAction)clickModifyRealNameBtn:(id)sender {
    [self.view endEditing:YES];
    self.baseUserNameInfo.userInteractionEnabled = YES;
    self.currentTextField = self.baseUserNameInfo;
    [self.baseUserNameInfo becomeFirstResponder];
    
    changeType = USERREALNAME;
}

- (IBAction)clickModifyNikeInfoBtn:(id)sender {
    [self.view endEditing:YES];
    self.baseUserNikeInfo.userInteractionEnabled = YES;
    self.currentTextField = self.baseUserNikeInfo;
    [self.baseUserNikeInfo becomeFirstResponder];
    
    changeType = USERNAME;
}

- (IBAction)clickModifyMobileInfoBtn:(id)sender {
    [self.view endEditing:YES];
    
    if (self.baseUserMobileInfo.text != nil && isActiveMobile) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改手机号码" message:@"您是否要修改已激活的手机号码？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认",@"取消", nil];
        alertView.tag = MOBILEACTIVETAG;
        [alertView show];
    }else{
        FindPWDAccountInfoPadViewController *viewController = [[FindPWDAccountInfoPadViewController alloc] init];
        viewController.type = ViewTypeModifyMobile;
        viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        viewController.userAccount = self.baseUserMobileInfo.text;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    [self.view endEditing:YES];
    changeType = USERMOBILE;
}

- (IBAction)clickIdentitySelectBtn:(id)sender{

}

- (IBAction)clickEmailActiveBtn:(id)sender {
     [self.view endEditing:YES];
    
    if (self.baseEmailInfo.text != nil && isActiveEmail) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改邮箱" message:@"您是否要修改已激活的邮箱？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认",@"取消", nil];
        alertView.tag = EMIALACTIVETAG;
        [alertView show];
    }else{
        EmailActivePadViewController *viewContoller = [[EmailActivePadViewController alloc] init];
        viewContoller.originEmailInfo = self.baseEmailInfo.text;
        [self.navigationController pushViewController:viewContoller animated:YES];
    }
}

- (IBAction)clickModifyDocCardId:(id)sender {
     [self.view endEditing:YES];
    
    if (self.baseDocCardId.text && ![self.baseDocCardId.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"绑定新文献卡" message:@"您是否要绑定新的文献卡？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认",@"取消", nil];
        alertView.tag = DOCBINDTAG;
        [alertView show];
    }else{
        //跳转页面
        DocCardInfoPadViewController *viewController = [[DocCardInfoPadViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    changeType = USERINVITATIONCODE;
}

- (IBAction)clickEmailInfoBtn:(id)sender {
    [self.view endEditing:YES];
    
    self.baseEmailInfo.userInteractionEnabled = YES;
    self.currentTextField = self.baseEmailInfo;
    [self.baseEmailInfo becomeFirstResponder];
    changeType = USEREMAIL;
}

#pragma mark - professInfo click
- (IBAction)clickhospitalSelectBtn:(id)sender {
    [self turnToSelectHospital];
    changeType = USERHOSPITAL;
}

- (IBAction)clickDepartSelectBtn:(id)sender{
    [self.view endEditing:YES];
    registerDetailsViewController* detailTitleVC = [[registerDetailsViewController alloc] initWithNibName: @"registerDetailsViewController" bundle:nil];
    
    detailTitleVC.detailType = DETAIL_TYPE_DEPARTMENT;
    
    [self.navigationController pushViewController:detailTitleVC animated:YES];
    [detailTitleVC displayView];
}

- (IBAction)clickTitleSelectBtn:(id)sender{
    [self.view endEditing:YES];
    registerDetailsViewController* detailTitleVC = [[registerDetailsViewController alloc] initWithNibName: @"registerDetailsViewController" bundle:nil];
    detailTitleVC.detailType = DETAIL_TYPE_TITLE;
    
    [self.navigationController pushViewController:detailTitleVC animated:YES];
    
    [detailTitleVC displayView];
}

- (IBAction)clickDoctorLiceseInfoBtn:(id)sender {
    self.doctorLicenseInfo.userInteractionEnabled = YES;
    self.currentTextField = self.doctorLicenseInfo;
    [self.doctorLicenseInfo becomeFirstResponder];
    changeType = USERLICESEID;
}

- (void)turnToSelectHospital{
    registerDetailsViewController* detailTitleVC1 = [[registerDetailsViewController alloc] initWithNibName:@"registerDetailsViewController" bundle:nil];
    //detailTitleVC.delegate =self.delegate;
    detailTitleVC1.detailType = DETAIL_TYPE_HOSPITAL;
    
    [self.navigationController pushViewController:detailTitleVC1 animated:YES];
    [detailTitleVC1 displayView];
}

#pragma mark - educationInfo  Click
- (IBAction)clickModifySchoolBtn:(id)sender {
    self.schollInfo.userInteractionEnabled = YES;
    self.currentTextField = self.schollInfo;
    [self.schollInfo becomeFirstResponder];
    
    changeType = USERSCHOOL;
}

- (IBAction)clickModifyMajorInfoBtn:(id)sender {
    [self.view endEditing:YES];
    self.majorInfo.userInteractionEnabled = YES;
    self.currentTextField = self.majorInfo;
    [self.majorInfo becomeFirstResponder];
    
    changeType = USERMAJOR;
}

- (IBAction)clickModifyEnterTimeBtn:(id)sender{
    [self.view endEditing:YES];
    changeType = USERADMISSIONYEAR;
    
    [self enterSchoolYearButtonTapped:@"start"];
}

- (IBAction)clickModifyLeaveTimeBtn:(id)sender{
    [self.view endEditing:YES];
    changeType = USERGRADUATIONYEAR;
    
    [self enterSchoolYearButtonTapped:@"end"];
}

- (IBAction)clickModifyDegreeBtn:(id)sender{
    [self.view endEditing:YES];
    changeType = USERDEGREE;
    
    [self onReadingEducationLevelButtonTapped:nil];
}

- (IBAction)clickModifyStudentCardBtn:(id)sender {
    [self.view endEditing:YES];
    self.studentCardInfo.userInteractionEnabled = YES;
    self.currentTextField = self.studentCardInfo;
    [self.studentCardInfo becomeFirstResponder];
    
    changeType = USERSTUDENTID;
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
    
    [self.modifyInfo setObject:mobileNumber forKey:changeType];
}

- (void)bindDocCardSuccess:(NSNotification *)notification{
    NSDictionary *valueDic = [notification userInfo];
    self.doctorLicenseInfo.text = [valueDic objectForKey:@"cardNum"];
    
    self.baseDocStopTime.text = [NSString stringWithFormat:@"截止于 %@",[self convertExpireTimeToDate:[[valueDic objectForKey:@"expireDate"] longLongValue]]];
}


#pragma mark - PopoverController
-(void)studentPopover
{
    EducationLevelTableViewController *content = [[EducationLevelTableViewController alloc] initWithNibName:@"EducationLevelTableViewController" bundle:nil];
    
    educationLevelPopoverController = [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate = self;
    
    educationLevelPopoverController.popoverContentSize = CGSizeMake(80, 140);
    educationLevelPopoverController.delegate = self;
    
    EnterYearViewController *eyvc = [[EnterYearViewController alloc]initWithNibName:@"EnterYearViewController" bundle:nil];
    enterYearPopoverController = [[UIPopoverController alloc]initWithContentViewController:eyvc];
    eyvc.delegate = self;
    enterYearPopoverController.popoverContentSize = CGSizeMake(80, 620);
    enterYearPopoverController.delegate = self;
}

- (void)enterSchoolYearButtonTapped:(NSString *)str
{
    NSLog(@"Enter school year. ");
    if ([str isEqualToString:@"start"]) {
        selectType = 0;
        CGRect frame = CGRectMake(self.enterTimeInfo.frame.origin.x+150,
                                  self.enterTimeInfo.frame.origin.y+45,
                                  self.enterTimeInfo.frame.size.width,
                                  self.enterTimeInfo.frame.size.height / 2);
        
        [enterYearPopoverController presentPopoverFromRect:frame inView:self.educationInfoView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if([str isEqualToString:@"end"]){
        selectType = 1;
        CGRect frame = CGRectMake(self.leaveTimeInfo.frame.origin.x+150,
                                  self.leaveTimeInfo.frame.origin.y+45,
                                  self.leaveTimeInfo.frame.size.width,
                                  self.leaveTimeInfo.frame.size.height / 2);
        
        [enterYearPopoverController presentPopoverFromRect:frame inView:self.educationInfoView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)onReadingEducationLevelButtonTapped:(id)sender
{
    NSLog(@"on Reading Education Level. ");
    //  [self.navigationController pushViewController:elvc animated:YES];
    CGRect frame=CGRectMake(
                            self.degreeInfo.frame.origin.x+150,
                            self.degreeInfo.frame.origin.y+45,
                            self.degreeInfo.frame.size.width,
                            self.degreeInfo.frame.size.height / 2);
    
    [educationLevelPopoverController presentPopoverFromRect:frame inView:self.educationInfoView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)enterYearSet:(NSString *)enterYear
{
    if (selectType == 0) {
        self.enterTimeInfo.text = enterYear;
    }else if(selectType == 1){
        self.leaveTimeInfo.text = enterYear;
    }
    
    NSString *start = self.enterTimeInfo.text;
    NSString *end = self.leaveTimeInfo.text;
    
    if (start.length > 0 && end.length > 0) {
        if ([start intValue] >= [end intValue]) {
            UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您选择的日期不正确" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alerts show];
            
            if (selectType == 0) {
                self.enterTimeInfo.text = @"";
            }else{
                self.leaveTimeInfo.text = @"";
            }
            
            [enterYearPopoverController dismissPopoverAnimated:YES];
        }
    }
    
    [self.modifyInfo setObject:[NSNumber numberWithInteger:[enterYear integerValue]] forKey:changeType];
    [enterYearPopoverController dismissPopoverAnimated:YES];
}

- (void)educationLevelSet:(NSString *)eduLevel
{
    self.degreeInfo.text = eduLevel;
    [self.modifyInfo setObject:[Strings getDegreeEN:eduLevel] forKey:changeType];
    [educationLevelPopoverController dismissPopoverAnimated:YES];
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
    
    CGRect rect;
    if (self.segmentSelect.selectedSegmentIndex == 0) {
        rect = [self.currentTextField.superview convertRect:self.currentTextField.frame toView:self.mainScrollView];
    }else{
         rect = [self.currentTextField.superview.superview convertRect:self.currentTextField.frame toView:self.mainScrollView];
    }
    
    CGFloat height = rect.origin.y + rect.size.height + 42;
    
    [self.mainScrollView setContentOffset:CGPointMake(0, (height - keyboardRect.width) > 0 ? (height - keyboardRect.width) : 0) animated:YES];
    NSLog(@"%@",self.mainScrollView);
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
    [self.modifyInfo setObject:textField.text forKey:changeType];
    
    return YES;
}

#pragma mark -
-(ASIHTTPRequest*)getUserInfo:(NSString *)url delegate:(id)dlgt
{
    ASIHTTPRequest *request_ = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request_ addRequestHeader:@"Content-Type" value:@"application/json"];
    [request_ addRequestHeader:@"Accept" value:@"application/json"];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request_ setUseCookiePersistence:YES];
    [request_ setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"checkVer" forKey:@"requestType"];
    [request_ setUserInfo:userInfo];
    
    
    request_.timeOutSeconds = 6*10;
    request_.delegate = dlgt;
    [request_ startAsynchronous];
    
    return request_;
}

#pragma mark -anyRequest
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
        
        [self.modifyInfo removeAllObjects];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"title"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
         [self showAlertView:nil contentInfo:@"帐号信息保存失败，请稍后重试"];
    }
}

- (void)getDailylimitRequest:(ASIHTTPRequest *)request_{
    NSString *responsInfo = [request_ responseString];
    NSLog(@"%@",responsInfo);
    NSDictionary *jsonInfo = [UrlRequest getJsonValue:request_];
    
    NSInteger num = [[jsonInfo objectForKey:@"limit"] intValue];
    NSString *limitStr = nil;
    if (num >= 500){
        limitStr = @"VIP";
    }else{
        limitStr = [NSString stringWithFormat:@"%d篇/天",num];
    }
    
    [self.dailylimitLabel setText:limitStr];
}

-(void)requestFailed:(ASIHTTPRequest*)request
{
    NSLog(@"request failed");
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
        self.baseRealNameBtn.hidden = YES;
        [self.useTypeVerified setTitle:@"实名验证" forState:UIControlStateNormal];
    }else{
        self.baseRealNameBtn.hidden = NO;
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
    }else{
        //present
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)getNonNilString:(NSString *)userString{
    return userString == nil ? @"" : userString;
}

- (NSString *)convertExpireTimeToDate:(long long)expireTimes{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:expireTimes];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
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
      UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"帐号信息修改确认" message:@"您的帐号信息已修改，是否保存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
      alerView.tag = USEINFOSAVETAG;
      [alerView show];
    }
}
@end
