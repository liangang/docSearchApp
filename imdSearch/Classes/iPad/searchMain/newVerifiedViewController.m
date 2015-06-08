//
//  newVerifiedViewController.m
//  imdSearch
//
//  Created by  侯建政 on 12/5/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "newVerifiedViewController.h"
#import "registerDetailsViewController.h"
#import "EnterYearViewController.h"
#import "EducationLevelTableViewController.h"
#import "UrlRequest.h"
#import "Strings.h"
#import "ImdUrlPath.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "imdSearchAppDelegate.h"
#import "Util.h"

#define LABLENAME_HIGH 172
#define SELECT_USERINFO_DOCTOR 0
#define SELECT_USERINFO_STUDENT 1

@interface newVerifiedViewController ()

@end

@implementation newVerifiedViewController

@synthesize selectId;
@synthesize arrayDoctoInfocList,arrayStudentInfocList;
@synthesize segment;
@synthesize restHospital,hospitalId;
@synthesize fieldHospital,lableDepartment,lablePosition;
@synthesize myTable;
@synthesize lableStudentName,lableStudentProfessional,lableStudentEnd,lableStudentNumber,lableStudentSchool,lableStudentStart,lableStudentDegree;
@synthesize lable;
@synthesize whatButton;
@synthesize hospitalDataType,departmentKey;
@synthesize button;
@synthesize alert;
@synthesize isSelectHospital;
@synthesize retLoadView;
@synthesize verForStudent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"睿医提示" message:@"您的真实姓名填写不正确" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isSelectHospital = NO;
    selectId = SELECT_USERINFO_DOCTOR;
    self.arrayDoctoInfocList = [[NSArray alloc] initWithObjects:@"真实姓名",@"所在医院",@"所在科室",@"我的职称" ,nil];
    self.arrayStudentInfocList = [[NSArray alloc] initWithObjects:@"真实姓名",@"所在学校",@"所学专业",@"学生证号码",@"在读学位",@"入学时间",@"毕业时间" ,nil];
    
    if (!(IOS7)) {
        self.segment.layer.borderColor = APPDefaultColor.CGColor;
        self.segment.layer.borderWidth = 1.0f;
        self.segment.layer.cornerRadius = 4.0f;
        self.segment.layer.masksToBounds = YES;
    }
    
    // Do any additional setup after loading the view from its nib.
    self.lable = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 500, 80)];
    lable.backgroundColor = [UIColor clearColor];
    lable.text = ACTIVE_DOCTOR;
    lable.textColor = RGBCOLOR(213, 106, 20);
    lable.font = [UIFont systemFontOfSize:16.0];
    lable.numberOfLines = 0;
    [self.myTable addSubview:lable];
    [self loadLaleInfoDoctor];
    [self loadLaleInfoStudent];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"title"];
    NSDictionary *temp = [[NSDictionary alloc]init];
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"departmentInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self studentPopover];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(124, 282, 273, 43);
    [button setTitle:@"重新提交身份信息" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
//    更改提交的button的信息
    [button setBackgroundImage:[UIImage imageNamed:@"btn-verify-info-normal"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn-verify-info-highlight"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(resetUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.myTable addSubview:button];
    [self.view addSubview:retLoadView];
    self.retLoadView.hidden = YES;
    verForStudent = [[sendEmailsViewController alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"title"];
    if (temp.length > 0) {
        self.lablePosition.text = temp;
    }
    
    NSDictionary *department = [[NSUserDefaults standardUserDefaults] objectForKey:@"departmentInfo"];
    if ([department count]) {
        self.lableDepartment.text = [department objectForKey:@"cnDepartment"];
        self.departmentKey = [department objectForKey:@"key"];
    }
    
    if (verForStudent.studentNumber.text.length > 0) {
        self.lableStudentNumber.text = verForStudent.studentNumber.text;
    }
}

- (void)loadLaleInfoDoctor
{
    self.fieldHospital = [[UILabel alloc] initWithFrame:CGRectMake(120, LABLENAME_HIGH-44, 360, 43)];
    self.fieldHospital.backgroundColor = [UIColor clearColor];
    self.fieldHospital.textAlignment = NSTextAlignmentRight;
    self.fieldHospital.font = [UIFont systemFontOfSize:14.0];
    
    self.lableDepartment = [[UILabel alloc] initWithFrame:CGRectMake(120, LABLENAME_HIGH, 360, 43)];
    self.lableDepartment.backgroundColor = [UIColor clearColor];
    self.lableDepartment.textAlignment = NSTextAlignmentRight;
    self.lableDepartment.font = [UIFont systemFontOfSize:14.0];
    
    self.lablePosition = [[UILabel alloc] initWithFrame:CGRectMake(120, LABLENAME_HIGH+44, 360, 43)];
    self.lablePosition.textAlignment = NSTextAlignmentRight;
    self.lablePosition.font = [UIFont systemFontOfSize:14.0];
    self.lablePosition.backgroundColor = [UIColor clearColor];
    [self.myTable addSubview:self.fieldHospital];
    [self.myTable addSubview:self.lableDepartment];
    [self.myTable addSubview:self.lablePosition];
}

- (void)loadLaleInfoStudent
{
    self.lableStudentName = [[UITextField alloc] initWithFrame:CGRectMake(95, 0, 360, 43)];
    self.lableStudentName.placeholder = @"请输入您的中文姓名";
    self.lableStudentName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.lableStudentName.backgroundColor = [UIColor clearColor];
    self.lableStudentName.textAlignment = NSTextAlignmentRight;
    self.lableStudentName.font = [UIFont systemFontOfSize:14.0];
    self.lableStudentName.delegate = self;
    
    self.lableStudentSchool = [[UITextField alloc] initWithFrame:CGRectMake(95, 0, 360, 43)];
    self.lableStudentSchool.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.lableStudentSchool.placeholder = @"请输入您的所在学校";
    self.lableStudentSchool.backgroundColor = [UIColor clearColor];
    self.lableStudentSchool.textAlignment = NSTextAlignmentRight;
    self.lableStudentSchool.font = [UIFont systemFontOfSize:14.0];
    self.lableStudentSchool.delegate = self;
    
    self.lableStudentProfessional = [[UITextField alloc] initWithFrame:CGRectMake(95, 0, 360, 43)];
    self.lableStudentProfessional.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.lableStudentProfessional.placeholder = @"请输入您的所学专业";
    self.lableStudentProfessional.backgroundColor = [UIColor clearColor];
    self.lableStudentProfessional.textAlignment = NSTextAlignmentRight;
    self.lableStudentProfessional.font = [UIFont systemFontOfSize:14.0];
    self.lableStudentProfessional.delegate = self;
    
    self.lableStudentNumber = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 360, 27)];
    self.lableStudentNumber.backgroundColor = [UIColor clearColor];
    self.lableStudentNumber.textAlignment = NSTextAlignmentRight;
    self.lableStudentNumber.font = [UIFont systemFontOfSize:14.0];
    
    
    self.lableStudentDegree = [[UILabel alloc] initWithFrame:CGRectMake(120, LABLENAME_HIGH+88, 360, 43)];
    self.lableStudentDegree.backgroundColor = [UIColor clearColor];
    self.lableStudentDegree.textAlignment = NSTextAlignmentRight;
    self.lableStudentDegree.font = [UIFont systemFontOfSize:14.0];
    
    self.lableStudentStart = [[UILabel alloc] initWithFrame:CGRectMake(120, LABLENAME_HIGH+132, 360, 43)];
    self.lableStudentStart.backgroundColor = [UIColor clearColor];
    self.lableStudentStart.textAlignment = NSTextAlignmentRight;
    self.lableStudentStart.font = [UIFont systemFontOfSize:14.0];
    
    self.lableStudentEnd = [[UILabel alloc] initWithFrame:CGRectMake(120, LABLENAME_HIGH+176, 360, 43)];
    self.lableStudentEnd.backgroundColor = [UIColor clearColor];
    self.lableStudentEnd.textAlignment = NSTextAlignmentRight;
    self.lableStudentEnd.font = [UIFont systemFontOfSize:14.0];
    
    [self.myTable addSubview:self.lableStudentName];
    [self.myTable addSubview:self.lableStudentEnd];
    [self.myTable addSubview:self.lableStudentStart];
    [self.myTable addSubview:self.lableStudentDegree];
    
    lableStudentStart.hidden = YES;
    lableStudentSchool.hidden = YES;
    lableStudentProfessional.hidden = YES;
    lableStudentNumber.hidden = YES;
    lableStudentEnd.hidden = YES;
    lableStudentDegree.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(IBAction)selectSegment:(id)sender
{
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [self selectDoctorInfo];
            break;
        case 1:
            [self selectStudentInfo];
            break;
        default:
            break;
    }
    
    [myTable reloadData];
}

- (void)selectDoctorInfo
{
    self.selectId = SELECT_USERINFO_DOCTOR;
    button.frame = CGRectMake(124, 282, 273, 43);
    lable.text = ACTIVE_DOCTOR;
    
    lableStudentStart.hidden = YES;
    lableStudentSchool.hidden = YES;
    lableStudentProfessional.hidden = YES;
    lableStudentNumber.hidden = YES;
    lableStudentDegree.hidden = YES;
    lableStudentEnd.hidden = YES;
    lablePosition.hidden = NO;
    lableDepartment.hidden = NO;
    fieldHospital.hidden = NO;
}

- (void)selectStudentInfo
{
    button.frame = CGRectMake(124, 414, 273, 43);
    self.selectId = SELECT_USERINFO_STUDENT;
    lable.text = ACTIVE_STUDENT;
    
    lableStudentStart.hidden = NO;
    lableStudentSchool.hidden = NO;
    lableStudentProfessional.hidden = NO;
    lableStudentNumber.hidden = NO;
    lableStudentDegree.hidden = NO;
    lableStudentEnd.hidden = NO;
    lablePosition.hidden = YES;
    lableDepartment.hidden = YES;
    fieldHospital.hidden = YES;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectId == SELECT_USERINFO_DOCTOR)
        return 4;
    if (selectId == SELECT_USERINFO_STUDENT)
        return 7;
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (selectId == SELECT_USERINFO_DOCTOR)
    {
        if (indexPath.row == 0) {
            [cell.contentView addSubview:self.lableStudentName];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = [arrayDoctoInfocList objectAtIndex:indexPath.row];
    } else if(selectId == SELECT_USERINFO_STUDENT) {
        cell.textLabel.text = [arrayStudentInfocList objectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            [cell.contentView addSubview:self.lableStudentName];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (indexPath.row == 1) {
            [cell.contentView addSubview:self.lableStudentSchool];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (indexPath.row == 2) {
            [cell.contentView addSubview:self.lableStudentProfessional];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (indexPath.row == 3) {
            [cell.contentView addSubview:self.lableStudentNumber];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    if (selectId == SELECT_USERINFO_DOCTOR) {
        switch (row) {
            case 0:
                [self.lableStudentName becomeFirstResponder];
                break;
            case 1:
                [self selectHospitalAddress];
                [self.lableStudentName resignFirstResponder];
                break;
            case 2:
                [self.lableStudentName resignFirstResponder];
                [self selectDepartment];
                break;
            case 3:
                [self.lableStudentName resignFirstResponder];
                [self chooseTitle];
                break;
            default:
                break;
        }
    }else if (selectId == SELECT_USERINFO_STUDENT) {
        switch (row) {
            case 0:
                [self.lableStudentName becomeFirstResponder];
                break;
            case 1:
                [self.lableStudentSchool becomeFirstResponder];
                break;
            case 2:
                [self.lableStudentProfessional becomeFirstResponder];
                break;
            case 3:
                verForStudent.number = self.lableStudentNumber.text;
                [self.navigationController pushViewController:verForStudent animated:YES];
                break;
            case 4:
                [self onReadingEducationLevelButtonTapped:nil];
                break;
            case 5:
                [self enterSchoolYearButtonTapped:@"start"];
                break;
            case 6:
                [self enterSchoolYearButtonTapped:@"end"];
                break;
            default:
                break;
        }
    }
}
#pragma mark -clickAction
- (void)selectHospitalAddress
{
    registerDetailsViewController* detailTitleVC1 = [[registerDetailsViewController alloc] initWithNibName:@"registerDetailsViewController" bundle:nil];
    //detailTitleVC.delegate =self.delegate;
    detailTitleVC1.detailType = DETAIL_TYPE_HOSPITAL;
    
    [self.navigationController pushViewController:detailTitleVC1 animated:YES];
    [detailTitleVC1 displayView];
}

-(void)chooseTitle
{
    NSLog(@"title clicked ");
    registerDetailsViewController* detailTitleVC = [[registerDetailsViewController alloc] initWithNibName:@"registerDetailsViewController" bundle:nil];
    
    detailTitleVC.detailType = DETAIL_TYPE_TITLE;
    
    [self.navigationController pushViewController:detailTitleVC animated:YES];
    [detailTitleVC displayView];
}

- (void)selectDepartment
{
    registerDetailsViewController* detailTitleVC = [[registerDetailsViewController alloc] initWithNibName:@"registerDetailsViewController" bundle:nil];
    
    detailTitleVC.detailType = DETAIL_TYPE_DEPARTMENT;
    
    [self.navigationController pushViewController:detailTitleVC animated:YES];
    [detailTitleVC displayView];
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
        whatButton = @"0";
        CGRect frame = CGRectMake(
                                  self.lableStudentStart.frame.origin.x,
                                  self.lableStudentStart.frame.origin.y,
                                  self.lableStudentStart.frame.size.width,
                                  self.lableStudentStart.frame.size.height / 2);
        
        [enterYearPopoverController presentPopoverFromRect:frame inView:self.myTable permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    } else if([str isEqualToString:@"end"]) {
        whatButton = @"1";
        CGRect frame = CGRectMake(
                                  self.lableStudentEnd.frame.origin.x,
                                  self.lableStudentEnd.frame.origin.y,
                                  self.lableStudentEnd.frame.size.width,
                                  self.lableStudentEnd.frame.size.height / 2);
        
        [enterYearPopoverController presentPopoverFromRect:frame inView:self.myTable permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)onReadingEducationLevelButtonTapped:(id)sender
{
    NSLog(@"on Reading Education Level. ");
    //  [self.navigationController pushViewController:elvc animated:YES];
    CGRect frame=CGRectMake(
                            self.lableStudentDegree.frame.origin.x,
                            self.lableStudentDegree.frame.origin.y,
                            self.lableStudentDegree.frame.size.width,
                            self.lableStudentDegree.frame.size.height / 2);
    
    [educationLevelPopoverController presentPopoverFromRect:frame inView:self.myTable permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)enterYearSet:(NSString *)enterYear
{
    if ([whatButton isEqualToString:@"0"]) {
        self.lableStudentStart.text = enterYear;
    } else if([whatButton isEqualToString:@"1"]) {
        self.lableStudentEnd.text = enterYear;
    }
    
    NSString *start = self.lableStudentStart.text;
    NSString *end = self.lableStudentEnd.text;
    
    if (start.length>0 && end.length>0) {
        if ([start intValue] >= [end intValue]) {
            UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您选择的日期不正确" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alerts show];
            
            if ([whatButton isEqualToString:@"0"]) {
                self.lableStudentStart.text = @"";
            }else{
                self.lableStudentEnd.text = @"";
            }
        }
    }
    [enterYearPopoverController dismissPopoverAnimated:YES];
}

- (void)educationLevelSet:(NSString *)eduLevel
{
    self.lableStudentDegree.text = eduLevel;
    [educationLevelPopoverController dismissPopoverAnimated:YES];
}

#pragma mark -anyRequest
-(void)requestFinished:(ASIHTTPRequest*)request
{
    self.view.hidden = NO;
    NSLog(@"%@",[request responseString]);
    NSDictionary* requestInfo =[request userInfo];
    NSString* rType = [requestInfo objectForKey:@"requestType"];
    
    NSDictionary* userInfoDic = [UrlRequest getJsonValue:request];
    
    if ([rType isEqualToString:@"checkVer"]) {
        NSDictionary* infoDic = [userInfoDic objectForKey:@"info"];
        NSString *userType = [infoDic objectForKey:@"userType"];
        NSString *hospitalName = [userInfoDic objectForKey:@"hospitalName"];
        NSDictionary* studentInfo = [infoDic objectForKey:@"studentInfo"];
        NSDictionary* doctorInfoDic = [infoDic objectForKey:@"doctorInfo"];
        NSDictionary* hospitalDic = [doctorInfoDic objectForKey:@"hospital"];
        
        if ([userType isEqualToString:@"Doctor"]) {
            self.segment.selectedSegmentIndex = 0;
            [self selectDoctorInfo];
            [myTable reloadData];
        } else if ([userType isEqualToString:@"Student"]) {
            self.segment.selectedSegmentIndex = 1;
            [self selectStudentInfo];
            [myTable reloadData];
        }
        
        if (hospitalName.length > 0) {
            self.fieldHospital.text = hospitalName;
        }
        
        NSString *realname = [infoDic objectForKey:@"realname"];
        if (realname.length > 0) {
            self.lableStudentName.text = realname;
        }
        
        NSString *hospitalIds = [hospitalDic objectForKey:@"hospitalId"];
        if (hospitalIds.length > 0) {
            self.hospitalId = hospitalIds;
        }
        
        NSString *hospitalDataTypes = [hospitalDic objectForKey:@"hospitalDataType"];
        if (hospitalDataTypes.length > 0) {
            self.hospitalDataType = hospitalDataTypes;
        }
        
        if ([doctorInfoDic objectForKey:@"department"]) {
            self.departmentKey = [doctorInfoDic objectForKey:@"department"];
        }
        
        NSString *department = [Strings getDepartmentString:[doctorInfoDic objectForKey:@"department"]];
        if (department.length > 0) {
            self.lableDepartment.text = department;
        }
        
        NSString *title = [Strings getPosition:[doctorInfoDic objectForKey:@"title"]];
        if (title.length > 0) {
            self.lablePosition.text = title;
        }
        
        NSString *school = [studentInfo objectForKey:@"school"];
        if (school.length > 0) {
            self.lableStudentSchool.text = school;
        }
        
        NSString *major = [studentInfo objectForKey:@"major"];
        if (major.length > 0) {
            self.lableStudentProfessional.text = major;
        }
        
        NSString *degree = [Strings getDegree:[studentInfo objectForKey:@"degree"]];
        if (degree.length > 0) {
            self.lableStudentDegree.text = degree;
        }
        
        NSString *admissionYear = [NSString stringWithFormat:@"%@",[studentInfo objectForKey:@"admissionYear"]];
        if (admissionYear.length > 0 && ![admissionYear isEqualToString:@"(null)"]) {
            self.lableStudentStart.text = admissionYear;
        }
        
        NSString *graduationYear = [NSString stringWithFormat:@"%@",[studentInfo objectForKey:@"graduationYear"]];
        if (graduationYear.length > 0 && ![graduationYear isEqualToString:@"(null)"]) {
            self.lableStudentEnd.text = graduationYear;
        }
        
        NSString *studentId = [studentInfo objectForKey:@"studentId"];
        if (studentId.length > 0) {
            self.lableStudentNumber.text = studentId;
        }
        
    } else if ([rType isEqualToString:@"reset"]) {
        self.retLoadView.hidden = YES;
        if ([userInfoDic objectForKey:@"success"]) {
            NSString *name = [Util getUsername];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:name];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.alert.message = @"身份验证信息已重新提交，我们将在两个工作日内完成验证。";
            [self.alert show];
        } else {
            self.alert.message = @"提交身份失败请稍候再试";
            [self.alert show];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest*)request
{
    NSLog(@"request failed");
    self.retLoadView.hidden = YES;
    self.view.hidden = NO;
    UIAlertView *alertw = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alertw show];
}

-(IBAction)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) resetUserInfo:(id)sender
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *doctorInfoDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *hospitalDic = [[NSMutableDictionary alloc] init];
    if (selectId == SELECT_USERINFO_DOCTOR)
    {
        if (![Strings judgeStringAsc:self.lableStudentName.text] || self.lableStudentName.text.length < 2) {
            self.alert.message = @"请填写中文真实姓名";
            [self.alert show];
            return;
        }else {
            [dic setObject:self.lableStudentName.text forKey:@"realname"];
        }
        
        if (self.fieldHospital.text.length == 0) {
            self.alert.message = @"请选择所在医院";
            [self.alert show];
            return;
        } else {
            
            if (isSelectHospital) {
                [hospitalDic setObject:self.hospitalId forKey:@"hospitalId"];
                [hospitalDic setObject:@"System" forKey:@"hospitalDataType"];
            }else {
                [hospitalDic setObject:self.hospitalId forKey:@"hospitalId"];
                [hospitalDic setObject:self.hospitalDataType forKey:@"hospitalDataType"];
            }
        }
        
        if (self.lableDepartment.text.length == 0) {
            self.alert.message = @"请选择所在科室";
            [self.alert show];
            return;
        }else {
            [doctorInfoDic setObject:self.departmentKey forKey:@"department"];
        }
        
        if (self.lablePosition.text.length == 0) {
            self.alert.message = @"请选择您的职位";
            [self.alert show];
            return;
        } else {
            [doctorInfoDic setObject:[Strings getPositionEN:self.lablePosition.text] forKey:@"title"];
        }
        
        [doctorInfoDic setObject:hospitalDic forKey:@"hospital"];
        [dic setObject:doctorInfoDic forKey:@"doctorInfo"];
    }
    
    if (selectId == SELECT_USERINFO_STUDENT) {
        if (![Strings judgeStringAsc:self.lableStudentName.text]) {
            self.alert.message = @"请填写中文真实姓名";
            [self.alert show];
            return;
        } else {
            [dic setObject:self.lableStudentName.text forKey:@"realname"];
        }
        
        if (self.lableStudentSchool.text.length == 0) {
            self.alert.message = @"请填写您的所在学校";
            [self.alert show];
            return;
        } else {
            [doctorInfoDic setObject:self.lableStudentSchool.text forKey:@"school"];
        }
        
        if (self.lableStudentProfessional.text.length == 0) {
            self.alert.message = @"请填写您的所学专业";
            [self.alert show];
            return;
        } else {
            [doctorInfoDic setObject:self.lableStudentProfessional.text forKey:@"major"];
        }
        
        if (self.lableStudentNumber.text.length == 0) {
            self.alert.message = @"请输入您的学生证号";
            [self.alert show];
            return;
        } else {
            [doctorInfoDic setObject:self.lableStudentNumber.text forKey:@"studentId"];
        }
        
        if (self.lableStudentDegree.text.length == 0) {
            self.alert.message = @"请选择您的在读学位";
            [self.alert show];
            return;
        } else {
            [doctorInfoDic setObject:[Strings getDegreeEN:self.lableStudentDegree.text] forKey:@"degree"];
        }
        
        if (self.lableStudentStart.text.length == 0) {
            self.alert.message = @"请选择您的入学时间";
            [self.alert show];
            return;
        } else {
            NSNumber *startTime = [NSNumber numberWithInt:[self.lableStudentStart.text intValue]];
            [doctorInfoDic setObject:startTime forKey:@"admissionYear"];
        }
        
        if (self.lableStudentEnd.text.length == 0) {
            self.alert.message = @"请选择您的毕业时间";
            [self.alert show];
            return;
        } else {
            NSNumber *endTime = [NSNumber numberWithInt:[self.lableStudentEnd.text intValue]];
            [doctorInfoDic setObject:endTime forKey:@"graduationYear"];
        }
        
        [dic setObject:doctorInfoDic forKey:@"studentInfo"];
    }
    
    self.retLoadView.hidden = NO;
    [self postUserInfo:[ImdUrlPath getUserInfo] userInfoDic:dic];
}

- (void)postUserInfo:(NSString *)url userInfoDic:(NSMutableDictionary *)dic
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [ASIHTTPRequest setSessionCookies:nil];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:YES];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"reset" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    [request setRequestMethod:@"POST"];
    [request appendPostData:[[dic JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    request.timeOutSeconds = 6*10;
    request.delegate = self;
    [request startAsynchronous];
    
}

#pragma mark -UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:@"身份验证信息已重新提交，我们将在两个工作日内完成验证。"]&&buttonIndex == 0) {
        [self backButtonTapped:nil];
    }
}
@end
