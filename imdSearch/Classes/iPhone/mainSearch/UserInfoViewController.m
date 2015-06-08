//
//  UserInfoViewController.m
//  imdSearch
//
//  Created by  侯建政 on 11/29/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "UserInfoViewController.h"
#import "TableViewFormatUtil.h"
#import "ImageViews.h"
#import "Strings.h"
#import "myUrl.h"
#import "ProvinceViewController.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "UserManager.h"
#import "DocArticleController.h"
#define LABLENAME_HIGH 150
#define SELECT_USERINFO_DOCTOR 0
#define SELECT_USERINFO_STUDENT 1
@interface UserInfoViewController ()

@end

@implementation UserInfoViewController
@synthesize arrayDoctoInfocList,arrayStudentInfocList;
@synthesize restHospital,hospitalId;
@synthesize lableHospital,lableDepartment,lablePosition,lable;
@synthesize segment;
@synthesize selectId;
@synthesize myTable;
@synthesize button;
@synthesize lableStudentName,lableStudentProfessional,lableStudentEnd,lableStudentNumber,lableStudentSchool,lableStudentStart,lableStudentDegree;
@synthesize dpCtr,titleCtr,NameCtr;
@synthesize alert;
@synthesize StarttimeArray;
@synthesize sortAS = _sortAS;
@synthesize pickerSelected;
@synthesize httpRequest;
@synthesize pickerViewArray;
@synthesize departmentKey,titleKey;
@synthesize myLoadView;
@synthesize isSelectHospital;
@synthesize hospitalDataType;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = ACTIVE_USERINFO;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissview:)];
        self.selectId = SELECT_USERINFO_DOCTOR;
        self.alert = [[UIAlertView alloc] initWithTitle:@"睿医提示" message:@"您的真实姓名填写不正确" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        // Custom initialization
    }
    return self;
}
- (void)dismissview:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isSelectHospital = NO;
    dpCtr = [[LoginDepartment alloc] init];
    dpCtr.delegate = self;
    titleCtr = [[LoginTitleController alloc] init];
    NameCtr = [[RealNameViewController alloc] init];
    segment.frame = CGRectMake(6, 8, 308, 29);
    [self.view addSubview:segment];
    
    UIView *remind = [[UIView alloc] initWithFrame:CGRectMake(15, 45, 300, 100)];
    remind.backgroundColor = RGBCOLOR(248, 248, 248);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bulb"]];
    imageView.frame = CGRectMake(10, 20, 26, 27);
    [remind addSubview:imageView];
    
    lable = [[UILabel alloc]initWithFrame:CGRectMake(36, 0, 260, 100)];
    lable.backgroundColor = [UIColor clearColor];
    lable.text = ACTIVE_DOCTOR;
    lable.textColor = RGBCOLOR(180, 180, 180);
    lable.font = [UIFont systemFontOfSize:15.0];
    lable.numberOfLines = 0;
    [remind addSubview:lable];
    
    [self.view addSubview:remind];
    
    UIButton *buttonTitle = [UIButton buttonWithType:0];
    buttonTitle.frame = CGRectMake(0, 40, 320, 90);
    buttonTitle.backgroundColor = [UIColor clearColor];
    [buttonTitle addTarget:self action:@selector(cancelLableName) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonTitle];
    arrayDoctoInfocList = [[NSArray alloc]initWithObjects:@"真实姓名",@"所在医院",@"所在科室",@"我的职称" ,nil];
    arrayStudentInfocList = [[NSArray alloc]initWithObjects:@"真实姓名",@"所在学校",@"所学专业",@"学生证号码",@"在读学位",@"入学时间",@"毕业时间" ,nil];
    [self loadLaleInfoDoctor];
    [self loadLaleInfoStudent];
    // Do any additional setup after loading the view from its nib.
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(23, LABLENAME_HIGH+200, 273, 43);
    [button setTitle:@"重新提交身份信息" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    [button setBackgroundColor:RGBCOLOR(249, 60, 3)];
    [button addTarget:self action:@selector(resetUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self createSortPicker];
    [self.view addSubview:self.myLoadView];
}
- (void)loadLaleInfoDoctor
{
    self.lableHospital = [[UILabel alloc] initWithFrame:CGRectMake(88, LABLENAME_HIGH+44, 196, 43)];
    self.lableHospital.backgroundColor = [UIColor clearColor];
    self.lableHospital.textAlignment = NSTextAlignmentRight;
    self.lableHospital.font = [UIFont systemFontOfSize:14.0];
    
    self.lableDepartment = [[UILabel alloc] initWithFrame:CGRectMake(88, LABLENAME_HIGH+88, 196, 43)];
    self.lableDepartment.backgroundColor = [UIColor clearColor];
    self.lableDepartment.textAlignment = NSTextAlignmentRight;
    self.lableDepartment.font = [UIFont systemFontOfSize:14.0];
    
    self.lablePosition = [[UILabel alloc] initWithFrame:CGRectMake(88, LABLENAME_HIGH+132, 196, 43)];
    self.lablePosition.textAlignment = NSTextAlignmentRight;
    self.lablePosition.font = [UIFont systemFontOfSize:14.0];
    self.lablePosition.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.lableHospital];
    [self.view addSubview:self.lableDepartment];
    [self.view addSubview:self.lablePosition];
}
- (void)loadLaleInfoStudent
{
    self.lableStudentName = [[UITextField alloc] initWithFrame:CGRectMake(81, 0, 196, 43)];
    self.lableStudentName.placeholder = @"请输入您的中文姓名";
    self.lableStudentName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.lableStudentName.backgroundColor = [UIColor clearColor];
    self.lableStudentName.textAlignment = NSTextAlignmentRight;
    self.lableStudentName.font = [UIFont systemFontOfSize:14.0];
    self.lableStudentName.returnKeyType = UIReturnKeyNext;
    self.lableStudentName.delegate = self;
    
    self.lableStudentSchool = [[UITextField alloc] initWithFrame:CGRectMake(81, 0, 196, 43)];
    self.lableStudentSchool.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.lableStudentSchool.placeholder = @"请输入您的所在学校";
    self.lableStudentSchool.backgroundColor = [UIColor clearColor];
    self.lableStudentSchool.textAlignment = NSTextAlignmentRight;
    self.lableStudentSchool.font = [UIFont systemFontOfSize:14.0];
    self.lableStudentSchool.returnKeyType = UIReturnKeyNext;
    self.lableStudentSchool.delegate = self;
    
    self.lableStudentProfessional = [[UITextField alloc] initWithFrame:CGRectMake(81, 0, 196, 43)];
    self.lableStudentProfessional.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.lableStudentProfessional.placeholder = @"请输入您的所学专业";
    self.lableStudentProfessional.backgroundColor = [UIColor clearColor];
    self.lableStudentProfessional.textAlignment = NSTextAlignmentRight;
    self.lableStudentProfessional.font = [UIFont systemFontOfSize:14.0];
    self.lableStudentProfessional.returnKeyType = UIReturnKeyNext;
    self.lableStudentProfessional.delegate = self;
    
    self.lableStudentNumber = [[UILabel alloc] initWithFrame:CGRectMake(88, LABLENAME_HIGH+132, 196, 43)];
    self.lableStudentNumber.backgroundColor = [UIColor clearColor];
    self.lableStudentNumber.textAlignment = NSTextAlignmentRight;
    self.lableStudentNumber.font = [UIFont systemFontOfSize:14.0];
    
    self.lableStudentDegree = [[UILabel alloc] initWithFrame:CGRectMake(88, LABLENAME_HIGH+176, 196, 43)];
    self.lableStudentDegree.backgroundColor = [UIColor clearColor];
    self.lableStudentDegree.textAlignment = NSTextAlignmentRight;
    self.lableStudentDegree.font = [UIFont systemFontOfSize:14.0];
    
    self.lableStudentStart = [[UILabel alloc] initWithFrame:CGRectMake(88, LABLENAME_HIGH+220, 196, 43)];
    self.lableStudentStart.backgroundColor = [UIColor clearColor];
    self.lableStudentStart.textAlignment = NSTextAlignmentRight;
    self.lableStudentStart.font = [UIFont systemFontOfSize:14.0];
    
    self.lableStudentEnd = [[UILabel alloc] initWithFrame:CGRectMake(88, LABLENAME_HIGH+264, 196, 43)];
    self.lableStudentEnd.backgroundColor = [UIColor clearColor];
    self.lableStudentEnd.textAlignment = NSTextAlignmentRight;
    self.lableStudentEnd.font = [UIFont systemFontOfSize:14.0];
    
    [self.view addSubview:self.lableStudentNumber];
    [self.view addSubview:self.lableStudentEnd];
    [self.view addSubview:self.lableStudentStart];
    [self.view addSubview:self.lableStudentDegree];
    lableStudentStart.hidden = YES;
    lableStudentSchool.hidden = YES;
    lableStudentProfessional.hidden = YES;
    lableStudentNumber.hidden = YES;
    lableStudentEnd.hidden = YES;
    lableStudentDegree.hidden = YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    if (dpCtr.currentCn.length > 0) {
        self.lableDepartment.text = dpCtr.currentCn;
        self.departmentKey = dpCtr.currentKey;
    }
    if (titleCtr.titleStr.length > 0) {
        self.lablePosition.text = titleCtr.titleStr;
    }
    if (NameCtr.studentNumber.text.length > 0) {
        self.lableStudentNumber.text = NameCtr.studentNumber.text;
    }
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
    lable.text = ACTIVE_DOCTOR;
    button.frame = CGRectMake(23, LABLENAME_HIGH+200, 273, 43);
    
    lableStudentStart.hidden = YES;
    lableStudentSchool.hidden = YES;
    lableStudentProfessional.hidden = YES;
    lableStudentNumber.hidden = YES;
    lableStudentDegree.hidden = YES;
    lableStudentEnd.hidden = YES;
    lablePosition.hidden = NO;
    lableDepartment.hidden = NO;
    lableHospital.hidden = NO;
}
- (void)selectStudentInfo
{
    self.selectId = SELECT_USERINFO_STUDENT;
    lable.text = ACTIVE_STUDENT;
    button.frame = CGRectMake(23, LABLENAME_HIGH+332, 273, 43);
    
    lableStudentStart.hidden = NO;
    lableStudentSchool.hidden = NO;
    lableStudentProfessional.hidden = NO;
    lableStudentNumber.hidden = NO;
    lableStudentDegree.hidden = NO;
    lableStudentEnd.hidden = NO;
    lablePosition.hidden = YES;
    lableDepartment.hidden = YES;
    lableHospital.hidden = YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)cancelLableName
{
    if (selectId == SELECT_USERINFO_STUDENT) {
        [self.lableStudentName resignFirstResponder];
        [self.lableStudentProfessional resignFirstResponder];
        [self.lableStudentSchool resignFirstResponder];
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
        [self.myTable scrollToRowAtIndexPath:scrollIndexPath
                            atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    [self.lableStudentName resignFirstResponder];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 105;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 110;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier: CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (selectId == SELECT_USERINFO_DOCTOR)
    {
        if (indexPath.row == 0) {
            [cell.contentView addSubview:self.lableStudentName];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = [arrayDoctoInfocList objectAtIndex:indexPath.row];
    }else if(selectId == SELECT_USERINFO_STUDENT)
    {
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
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    if (row > 0) {
        [self.lableStudentName resignFirstResponder];
    }
    if (selectId == SELECT_USERINFO_DOCTOR) {
        switch (row) {
                //      case 0:
                //        self.NameCtr.titleText = @"真实姓名";
                //        [self.navigationController pushViewController:self.NameCtr animated:YES];
                //        break;
            case 1:
                [self turnToPro];
                break;
            case 2:
                [self selectDepartment:nil];
                break;
            case 3:
                [self.navigationController pushViewController:self.titleCtr animated:YES];
                break;
            default:
                break;
        }
    }else if (selectId == SELECT_USERINFO_STUDENT)
    {
        switch (row) {
            case 3:
                [self.lableStudentProfessional resignFirstResponder];
                [self.lableStudentSchool resignFirstResponder];
                self.NameCtr.titleText = @"学生证号码";
                if (self.lableStudentNumber.text.length > 0) {
                    self.NameCtr.number = self.lableStudentNumber.text;
                }
                [self.navigationController pushViewController:self.NameCtr animated:YES];
                break;
            case 4:
                [self.lableStudentProfessional resignFirstResponder];
                [self.lableStudentSchool resignFirstResponder];
                temp = 4;
                [self.sortAS showInView:self.view];
                [self.sortAS setBounds:CGRectMake(0, 0, 320, 480)];
                [majorPickView reloadAllComponents];
                break;
            case 5:
                [self.lableStudentProfessional resignFirstResponder];
                [self.lableStudentSchool resignFirstResponder];
                temp = 5;
                [self.sortAS showInView:self.view];
                [self.sortAS setBounds:CGRectMake(0, 0, 320, 480)];
                [majorPickView reloadAllComponents];
                break;
            case 6:
                [self.lableStudentProfessional resignFirstResponder];
                [self.lableStudentSchool resignFirstResponder];
                temp = 6;
                [self.sortAS showInView:self.view];
                [self.sortAS setBounds:CGRectMake(0, 0, 320, 480)];
                [majorPickView reloadAllComponents];
                break;
            default:
                break;
        }
    }
}
- (void)turnToPro
{
    NSString* urlString = [NSString stringWithFormat:@"http://%@/hospital:cities?r=1352797588496",NEW_SERVER ];
    ProvinceViewController *pro = [[ProvinceViewController alloc]init];
    pro.reset = @"RESET";
    [UrlRequest sendProvince:urlString delegate:pro];
    [self.navigationController pushViewController:pro animated:YES];
}
-(void) selectDepartment:(id)sender
{
    [self.dpCtr requestDepartment];
    [self.navigationController pushViewController:self.dpCtr animated:YES];
}

- (void) resetUserInfo:(id)sender
{
    self.myLoadView.hidden = NO;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *doctorInfoDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *hospitalDic = [[NSMutableDictionary alloc] init];
    if (selectId == SELECT_USERINFO_DOCTOR)
    {
        if (![Strings judgeStringAsc:self.lableStudentName.text] || self.lableStudentName.text.length < 2) {
            self.alert.message = @"请填写中文真实姓名";
            [self.alert show];
            return;
        }else
        {
            [dic setObject:self.lableStudentName.text forKey:@"realname"];
        }
        if (self.lableHospital.text.length == 0) {
            self.alert.message = @"请选择所在医院";
            [self.alert show];
            return;
        }else
        {
            
            if (isSelectHospital) {
                [hospitalDic setObject:self.hospitalId forKey:@"hospitalId"];
                [hospitalDic setObject:@"System" forKey:@"hospitalDataType"];
            }else
            {
                [hospitalDic setObject:self.hospitalId forKey:@"hospitalId"];
                [hospitalDic setObject:self.hospitalDataType forKey:@"hospitalDataType"];
            }
        }
        if (self.lableDepartment.text.length == 0) {
            self.alert.message = @"请选择所在科室";
            [self.alert show];
            return;
        }else
        {
            [doctorInfoDic setObject:self.departmentKey forKey:@"department"];
        }
        if (self.lablePosition.text.length == 0) {
            self.alert.message = @"请选择您的职位";
            [self.alert show];
            return;
        }else
        {
            [doctorInfoDic setObject:[Strings getPositionEN:self.lablePosition.text] forKey:@"title"];
        }
        [doctorInfoDic setObject:hospitalDic forKey:@"hospital"];
        [dic setObject:doctorInfoDic forKey:@"doctorInfo"];
    }
    if (selectId == SELECT_USERINFO_STUDENT)
    {
        if (![Strings judgeStringAsc:self.lableStudentName.text]) {
            self.alert.message = @"请填写中文真实姓名";
            [self.alert show];
            return;
        }else
        {
            [dic setObject:self.lableStudentName.text forKey:@"realname"];
        }
        if (self.lableStudentSchool.text.length == 0) {
            self.alert.message = @"请填写您的所在学校";
            [self.alert show];
            return;
        }else
        {
            [doctorInfoDic setObject:self.lableStudentSchool.text forKey:@"school"];
        }
        if (self.lableStudentProfessional.text.length == 0) {
            self.alert.message = @"请填写您的所学专业";
            [self.alert show];
            return;
        }else
        {
            [doctorInfoDic setObject:self.lableStudentProfessional.text forKey:@"major"];
        }
        if (self.lableStudentNumber.text.length == 0) {
            self.alert.message = @"请输入您的学生证号";
            [self.alert show];
            return;
        }else
        {
            [doctorInfoDic setObject:self.lableStudentNumber.text forKey:@"studentId"];
        }
        if (self.lableStudentDegree.text.length == 0) {
            self.alert.message = @"请选择您的在读学位";
            [self.alert show];
            return;
        }else
        {
            [doctorInfoDic setObject:[Strings getDegreeEN:self.lableStudentDegree.text] forKey:@"degree"];
        }
        if (self.lableStudentStart.text.length == 0) {
            self.alert.message = @"请选择您的入学时间";
            [self.alert show];
            return;
        }else
        {
            NSNumber *startTime = [NSNumber numberWithInt:[self.lableStudentStart.text intValue]];
            [doctorInfoDic setObject:startTime forKey:@"admissionYear"];
        }
        if (self.lableStudentEnd.text.length == 0) {
            self.alert.message = @"请选择您的毕业时间";
            [self.alert show];
            return;
        }else
        {
            NSNumber *endTime = [NSNumber numberWithInt:[self.lableStudentEnd.text intValue]];
            [doctorInfoDic setObject:endTime forKey:@"graduationYear"];
        }
        [dic setObject:doctorInfoDic forKey:@"studentInfo"];
    }
    [UrlRequest sendPost:[ImdUrlPath getUserInfo] data:dic delegate:self];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    NSLog(@"111111");
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (selectId == SELECT_USERINFO_STUDENT) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
        if (textField == self.lableStudentName) {
            [self.myTable scrollToRowAtIndexPath:scrollIndexPath
                                atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        if (textField == self.lableStudentSchool) {
            [self.myTable scrollToRowAtIndexPath:scrollIndexPath
                                atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        if (textField == self.lableStudentProfessional) {
            [self.myTable scrollToRowAtIndexPath:scrollIndexPath
                                atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (selectId == SELECT_USERINFO_DOCTOR) {
        if (textField == self.lableStudentName) {
            [self.lableStudentName resignFirstResponder];
            [self turnToPro];
        }
    }else
    {
        if (textField == self.lableStudentName) {
            [self.lableStudentSchool becomeFirstResponder];
        }
        if (textField == self.lableStudentSchool) {
            [self.lableStudentProfessional becomeFirstResponder];
        }
        if (textField == self.lableStudentProfessional) {
            [self.lableStudentProfessional resignFirstResponder];
            self.NameCtr.titleText = @"学生证号码";
            if (self.lableStudentNumber.text.length > 0) {
                self.NameCtr.number = self.lableStudentNumber.text;
            }
            [self.navigationController pushViewController:self.NameCtr animated:YES];
        }
    }
    return YES;
}

#pragma mark - UIPickerView
-(void) createSortPicker
{
    self.pickerViewArray = [NSMutableArray arrayWithObjects:
                            SELECT_XUESHI,
                            SELECT_SHUOSHI,
                            SELECT_BOSHI,
                            nil];
    self.StarttimeArray =[[NSMutableArray alloc] initWithCapacity:61];
    NSDateFormatter *nsdf2 = [[NSDateFormatter alloc] init];
    [nsdf2 setDateStyle:NSDateFormatterShortStyle];
    [nsdf2 setDateFormat:@"YYYY"];
    NSString* maxYear = [nsdf2 stringFromDate:[NSDate date]];
    for (int i = 0; i < 61; i++)
    {
        [self.StarttimeArray addObject:[NSString stringWithFormat:@"%i", (maxYear.intValue+8 - i) ]];
    }
    majorPickView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    //  _sortPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin;
    
    [majorPickView setFrame:CGRectMake(0, 40, 320, 216)];
    majorPickView.showsSelectionIndicator = YES;
    
    majorPickView.delegate = self;
    majorPickView.dataSource = self;
    
    _sortAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
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
    //[self.sortAS showInView:self.view];
}

#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}


#pragma mark -
#pragma mark UIPickerViewDataSource
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    if (temp == 4) {
        label.text = [self.pickerViewArray objectAtIndex:row];
    }else{
        label.text = [self.StarttimeArray objectAtIndex:row];
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
    if (temp == 4) {
        tempArray = self.pickerViewArray;
    }else
    {
        tempArray = self.StarttimeArray;
    }
    return [tempArray count];
}

-(void)doSortSearch:(UIPickerView*) sortPicker
{
    self.pickerSelected = [majorPickView selectedRowInComponent:0];
    //
    //  NSString *mSelect = [self.pickerSortArray objectAtIndex:self.pickerSelected] ;
    if (temp == 4) {
        self.lableStudentDegree.text = [self.pickerViewArray objectAtIndex:self.pickerSelected];
        self.lableStudentStart.textAlignment = NSTextAlignmentRight;
    }
    else if(temp == 5)
    {
        self.lableStudentStart.text = [self.StarttimeArray objectAtIndex:self.pickerSelected];
        self.lableStudentStart.textAlignment = NSTextAlignmentRight;
    }else if(temp == 6)
    {
        self.lableStudentEnd.text = [self.StarttimeArray objectAtIndex:self.pickerSelected];
        self.lableStudentEnd.textAlignment = NSTextAlignmentRight;
    }
    NSString * start = self.lableStudentStart.text;
    NSString * end = self.lableStudentEnd.text;
    
    if (start && end) {
        if ([start intValue] >= [end intValue]) {
            UIAlertView *alerts = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您选择的日期不正确" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alerts show];
            if (temp == 4) {
                self.lableStudentStart.text = @"";
            }else{
                self.lableStudentEnd.text = @"";
            }
        }
        
    }
    [self cancelSortSearch:nil];
    //NSLog(@"mSelect..%@",mSelect);
}
-(void) updateSortPicker:(NSInteger)selected
{
    self.pickerSelected = 0;
    [majorPickView selectRow:selected inComponent:0 animated:NO];
}
-(void)cancelSortSearch:(UIPickerView*) sortPicker
{
    [self.sortAS dismissWithClickedButtonIndex:0 animated:YES];
    [self updateSortPicker:0];
}
#pragma mark -anyRequest
-(void)requestFinished:(ASIHTTPRequest*)request
{
    self.view.hidden = NO;
    self.myLoadView.hidden = YES;
    NSLog(@"%@",[request responseString]);
    NSDictionary* userInfoDic = [UrlRequest getJsonValue:request];
    if ([userInfoDic count] > 1) {
        
        NSDictionary* infoDic = [userInfoDic objectForKey:@"info"];
        NSString *userType = [infoDic objectForKey:@"userType"];
        NSString *hospitalName = [userInfoDic objectForKey:@"hospitalName"];
        NSDictionary* studentInfo = [infoDic objectForKey:@"studentInfo"];
        NSDictionary* doctorInfoDic = [infoDic objectForKey:@"doctorInfo"];
        NSDictionary* hospitalDic = [doctorInfoDic objectForKey:@"hospital"];
        if ([userType isEqualToString:@"Doctor"]) {
          if ([self.delegate respondsToSelector:@selector(showUserInfoVC:)]) {
            [self.delegate showUserInfoVC:YES];
          }
            self.segment.selectedSegmentIndex = 0;
            [self selectDoctorInfo];
            [myTable reloadData];
        }else if ([userType isEqualToString:@"Student"])
        {
          if ([self.delegate respondsToSelector:@selector(showUserInfoVC:)]) {
            [self.delegate showUserInfoVC:YES];
          }
            self.segment.selectedSegmentIndex = 1;
            [self selectStudentInfo];
            [myTable reloadData];
        }else
        {
          if ([self.delegate respondsToSelector:@selector(showUserInfoVC:)]) {
            [self.delegate showUserInfoVC:NO];
            return;
          }
        }
        if (hospitalName.length > 0) {
            self.lableHospital.text = hospitalName;
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
    }
    else
    {
        if ([userInfoDic objectForKey:@"success"]) {
            NSString *name = [UserManager userName];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:name];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.alert.message = @"身份验证信息已重新提交，我们将在两个工作日内完成验证。";
            [self.alert show];
        }else
        {
            self.alert.message = @"提交身份失败请稍候再试";
            [self.alert show];
        }
    }
}
-(void)requestFailed:(ASIHTTPRequest*)request
{
    NSLog(@"request failed");
    UIAlertView *alertw = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
  if ([request.error code] == ASIRequestTimedOutErrorType) {
    alertw.message = REQUEST_TIMEOUT_MESSAGE;
    alertw.title = HINT_TEXT;
  }
    [alertw show];
}

#pragma mark -UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.myLoadView.hidden = YES;
    if ([alertView.message isEqualToString:@"身份验证信息已重新提交，我们将在两个工作日内完成验证。"] && buttonIndex == 0) {
        [self dismissview:nil];
    }
}
@end
