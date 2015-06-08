//
//  LoginNewUserStep2.m
//  imdSearch
//
//  Created by Huajie Wu on 11-12-12.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "LoginNewUserStep2.h"
#import "TableViewFormatUtil.h"
#import "Strings.h"
#import "ImageViews.h"
#import "LoginNewUserStep2.h"
#import "IPhoneHeader.h"
#import "LoginDepartment.h"
#import "imdSearchAppDelegate.h"
#import "imdSearchAppDelegate_iPhone.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "LoginNewUserController.h"

@implementation LoginNewUserStep2
@synthesize indicator, alertView;
@synthesize registerData;
@synthesize departmentBtn, departmentD, titleBtn, titleD, hospitalTF,majorButton;
@synthesize hospitalLbl;

@synthesize dpCtr, titleCtr;
@synthesize httpRequest = _httpRequest;

@synthesize doctorContainer = _doctorContainer;
@synthesize studentContainer = _studentContainer;

@synthesize schoolTF = _schoolTF, majorTF = _majorTF, degreeTF = _degreeTF, studentIdTF = _studentIdTF, admissionYearTF = _admissionYearTF, isDoctor = _isDoctor;
@synthesize pickerViewArray = _pickerViewArray;
@synthesize pickerSortArray = _pickerSortArray;
@synthesize pickerSelected = _pickerSelected;
@synthesize sortAS = _sortAS;
@synthesize StarttimeArray,EndtimeArray;
@synthesize hospital,hospitalId;
@synthesize hospitalButton;
@synthesize pro;
@synthesize startLable,endLable;
-(void) dealloc
{
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = LOGIN_PERSONALINFO;
        
        // Custom initialization
        UIBarButtonItem *doRegisterBtn = [[UIBarButtonItem alloc] initWithTitle:LOGIN_REGISTER style:UIBarButtonItemStylePlain target:self action:@selector(doRegister:)];
        [self.navigationItem setRightBarButtonItem:doRegisterBtn];
        
        alertView = [[UIAlertView alloc] initWithTitle:REGISTER_MESSAGE message:REGISTER_SUCCESS delegate:self cancelButtonTitle:REGISTER_CANCEL otherButtonTitles:nil];
        
        registerData = [[NSMutableDictionary alloc] init];
        
        dpCtr = [[LoginDepartment alloc] init];
        dpCtr.delegate = self;
        titleCtr = [[LoginTitleController alloc] init];
        pro = [[ProvinceViewController alloc]init];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void) popBack
{
    if (self.isDoctor) {
        [self behaviorDoctor:@"backButtonTapped"];
    }else {
        [self behaviorStudent:@"backButtonTapped"];
    }
    
    NSArray *array=self.navigationController.viewControllers;
	LoginNewUserController *root=[array objectAtIndex:[array count]-2];
	root.backtoFrist = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.startLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 37)];
    self.startLable.backgroundColor = [UIColor clearColor];
    [StarttimeButton addSubview:self.startLable];
    self.endLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 37)];
    self.endLable.backgroundColor = [UIColor clearColor];
    [EndtimeButton addSubview:self.endLable];
    
    [TableViewFormatUtil setBorder:self.doctorContainer Color:[UIColor lightGrayColor]];
    [TableViewFormatUtil setBorder:self.studentContainer Color:[UIColor lightGrayColor]];
    
    if (self.isDoctor) {
        [self behaviorDoctor:@"viewDidLoad"];
    }else {
        [self behaviorStudent:@"viewDidLoad"];
    }
    [self createSortPicker];
    // [self createTimePicker];
    
    [self.contentSrcollView setContentSize:self.contentSrcollView.frame.size];
}

- (void)viewDidUnload
{
    if (self.isDoctor) {
        [self behaviorDoctor:@"viewDidUnload"];
    }else {
        [self behaviorStudent:@"viewDidUnload"];
    }
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.departmentBtn setTitle:dpCtr.currentCn forState:UIControlStateNormal];
    [self.titleBtn setTitle:titleCtr.titleStr forState:UIControlStateNormal];
    if (self.isDoctor) {
        self.doctorContainer.hidden = NO;
        self.studentContainer.hidden = YES;
    } else {
        self.doctorContainer.hidden = YES;
        self.studentContainer.hidden = NO;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark action
-(IBAction) doRegister:(id)sender
{
    [self.majorTF resignFirstResponder];
    [self.schoolTF resignFirstResponder];
    NSMutableDictionary *updtaRegisterDic = [[NSMutableDictionary alloc]init];
    [updtaRegisterDic removeAllObjects];
    if (self.isDoctor && dpCtr.currentKey.length == 0) {
        [self selectDepartment:nil];
        return;
    }
    else if (self.isDoctor && titleCtr.titleStr.length == 0) {
        [self selectTitle:nil];
        return;
    }
    else if (self.isDoctor && hospitalButton.titleLabel.text.length == 0) {
        hospitalLbl.textColor = [TableViewFormatUtil getNotInputedColor];
        [hospitalTF becomeFirstResponder];
        return;
    }
    
    if (self.isDoctor) {
        hospitalLbl.textColor = [TableViewFormatUtil getInputedColor];
        [registerData removeObjectForKey:REGISTER_INFO_USERTYPE];
        [registerData setObject:USERTYPE_DOCTOR forKey:REGISTER_INFO_USERTYPE];
        [registerData setObject:dpCtr.currentKey forKey:REGISTER_INFO_DEPARTMENT];
        [registerData setObject:titleCtr.titleStr forKey:REGISTER_INFO_TITLE];
        [registerData setObject:hospitalId forKey:REGISTER_INFO_hospitalId];
        [registerData setObject:@"iPhoneDocApp" forKey:REGISTER_SOURCE];
        [updtaRegisterDic setObject:[registerData objectForKey:REGISTER_INFO_PASSWORD] forKey:REGISTER_INFO_PASSWORD];
        [updtaRegisterDic setObject:[Strings getUserInfo:registerData] forKey:REGISTER_INFO];
        [registerData removeObjectForKey:REGISTER_INFO_SCHOOL];
        [registerData removeObjectForKey:REGISTER_INFO_ADMISSIONYEAR];
        [registerData removeObjectForKey:REGISTER_INFO_MAJOR];
        [registerData removeObjectForKey:REGISTER_INFO_DEGREE];
        [registerData removeObjectForKey:REGISTER_INFO_STUDENTID];
    } else {
        NSLog(@"%@",StarttimeButton.titleLabel.text);
        NSLog(@"%@",EndtimeButton.titleLabel.text);
        if (self.schoolTF.text.length == 0) {
            [self.schoolTF becomeFirstResponder];
            return;
        } else if (self.majorTF.text.length == 0) {
            [self.majorTF becomeFirstResponder];
            return;
        }else if (self.studentIdTF.text.length == 0) {
            [self.studentIdTF becomeFirstResponder];
            return;
        }else if (majorButton.titleLabel.text.length == 0) {
            [self.majorTF resignFirstResponder];
            [self.schoolTF resignFirstResponder];
            [self.studentIdTF resignFirstResponder];
            timeOrmajor = @"1";
          [self showSortPicker];
            return;
        } else if (self.startLable.text.length == 0) {
            [self.majorTF resignFirstResponder];
            [self.schoolTF resignFirstResponder];
            [self.studentIdTF resignFirstResponder];
            timeOrmajor = @"2";
            [self showSortPicker];
            return;
        }else if (self.endLable.text.length == 0) {
            [self.majorTF resignFirstResponder];
            [self.schoolTF resignFirstResponder];
            [self.studentIdTF resignFirstResponder];
            timeOrmajor = @"3";
            [self showSortPicker];
            return;
        }
        
        NSNumber *Startnumber = [NSNumber numberWithInt:[self.startLable.text intValue]];
        NSNumber *Endnumber = [NSNumber numberWithInt:[self.endLable.text intValue]];
        [updtaRegisterDic setObject:[registerData objectForKey:REGISTER_INFO_PASSWORD] forKey:REGISTER_INFO_PASSWORD];
        
        [registerData setObject:USERTYPE_STUDENT forKey:REGISTER_INFO_USERTYPE];
        [registerData setObject:self.schoolTF.text forKey:REGISTER_INFO_SCHOOL];
        [registerData setObject:Startnumber forKey:REGISTER_INFO_ADMISSIONYEAR];
        [registerData setObject:self.studentIdTF.text forKey:REGISTER_INFO_STUDENTID];
        
        self.pickerSortArray = [NSArray arrayWithObjects:@"Bachelor", @"Master", @"Doctor", nil];
        if ([majorButton.titleLabel.text isEqualToString:SELECT_XUESHI]) {
            [registerData setObject:[self.pickerSortArray objectAtIndex:0] forKey:REGISTER_INFO_DEGREE];
        }else if ([majorButton.titleLabel.text isEqualToString:SELECT_SHUOSHI]) {
            [registerData setObject:[self.pickerSortArray objectAtIndex:1] forKey:REGISTER_INFO_DEGREE];
        }else if ([majorButton.titleLabel.text isEqualToString:SELECT_BOSHI]) {
            [registerData setObject:[self.pickerSortArray objectAtIndex:2] forKey:REGISTER_INFO_DEGREE];
        }
        
        [registerData setObject:Endnumber forKey:REGISTER_INFO_GRADYEAR];
        [registerData setObject:self.majorTF.text forKey:REGISTER_INFO_MAJOR];
        [registerData setObject:@"iPhoneDocApp" forKey:REGISTER_SOURCE];
        //[registerData setObject:self.studentIdTF.text forKey:REGISTER_INFO_STUDENTID];
        
        [registerData removeObjectForKey:REGISTER_INFO_DEPARTMENT];
        [registerData removeObjectForKey:REGISTER_INFO_TITLE];
        [registerData removeObjectForKey:REGISTER_INFO_HOSPITAL];
        
        [updtaRegisterDic setObject:[Strings getUserInfo:registerData] forKey:REGISTER_INFO];
    }
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    NSLog(@"%@", [updtaRegisterDic description]);
    self.httpRequest = [UrlRequest sendPost:[ImdUrlPath registerUrl] data:updtaRegisterDic delegate:self];
    
    if (self.isDoctor) {
        [self behaviorDoctor:@"Doctor submitButtonTapped"];
    }else {
        [self behaviorStudent:@"Student submitButtonTapped"];
    }
    
    [self.indicator startAnimating];
}

#pragma mark Asy Request

-(void)requestFinished:(ASIHTTPRequest *)request
{
    
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    
    NSLog(@"json: %@", [request responseString]);
    //Check if results is nil.
    if (resultsJson == nil) {
        NSLog(@"Nil Results");
        [alertView setMessage:REGISTER_FAIL];
        [alertView setTitle:REGISTER_MESSAGE];
        [alertView show];
        return;
    } else {
        //Set Results Count.
        NSDictionary* codeJson = [UrlRequest getJsonValue:request];
        NSNumber* code = [codeJson objectForKey:@"success"];
        
        if ([code intValue] == 1) {
            [ImdAppBehavior registerFinished];
            NSString * temp;
            NSString* user;
            temp = [registerData objectForKey:REGISTER_INFO_MOBILE];
            if (temp.length > 0) {
                user = [registerData objectForKey:REGISTER_INFO_MOBILE];
                temp = nil;
            }
            temp = nil;
            temp = [registerData objectForKey:REGISTER_INFO_USERNAME];
            if (temp.length > 0 ) {
                user = [registerData objectForKey:REGISTER_INFO_USERNAME];
                temp = nil;
            }
            NSString* pwd = [registerData objectForKey:REGISTER_INFO_PASSWORD];
            [user lowercaseString];
            [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"savedUser"];
            [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:@"savedPass"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSelector:@selector(loginIn) withObject:self afterDelay:1.0];
            
            
        } else {
            [alertView setMessage:@"注册失败"];
            [alertView setTitle:REGISTER_MESSAGE];
            [alertView show];
        }
    }
}
-(void)loginIn
{
    [self performSelector:@selector(stopLoading) withObject:self afterDelay:1.0];
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    [appDelegate.myAuth doLogin:self fromRegister:YES];
}
- (void)stopLoading
{
    [self.indicator stopAnimating];
}
-(void) userLoginFinished:(BOOL)animated
{
    imdSearchAppDelegate_iPhone* app = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    [app showAccoutActiveView:app.loginController.sourceCtr title:@"asdf" emailActive:NO mobileActive:NO fromRegister:YES];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    [self.indicator stopAnimating];
    [alertView setMessage:REGISTER_FAIL];
    [alertView setTitle:REQUEST_FAILED_TITLE];
    [alertView show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == hospitalTF || textField == self.degreeTF)
        [self doRegister:nil];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == hospitalTF && hospitalTF.text.length > 0)
        hospitalLbl.textColor = [TableViewFormatUtil getInputedColor];
}

-(IBAction) selectDepartment:(id)sender
{
    [self.dpCtr requestDepartment];
    [self.navigationController pushViewController:self.dpCtr animated:YES];
    [self behaviorDoctor:@"selectDepartment"];
}

-(IBAction) selectTitle:(id)sender
{
    [self.navigationController pushViewController:self.titleCtr animated:YES];
}
- (void)behaviorStudent:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:REGISTER_STUDENT_INFO paramJson:json];
}
- (void)behaviorDoctor:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:REGISTER_DOCTOR_2 paramJson:json];
}
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

-(void) createSortPicker
{
    self.pickerViewArray = [NSMutableArray arrayWithObjects:
                            SELECT_XUESHI,
                            SELECT_SHUOSHI,
                            SELECT_BOSHI,
                            nil];
    self.StarttimeArray =[[NSMutableArray alloc] initWithCapacity:62];
    NSDateFormatter *nsdf2 = [[NSDateFormatter alloc] init];
    [nsdf2 setDateStyle:NSDateFormatterShortStyle];
    [nsdf2 setDateFormat:@"YYYY"];
    NSString* maxYear = [nsdf2 stringFromDate:[NSDate date]];
    for (int i = 0; i < 61; i++)
    {
        [self.StarttimeArray addObject:[NSString stringWithFormat:@"%i", (maxYear.intValue+8 - i) ]];
    }
    NSLog(@"%@",self.StarttimeArray);
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
    //[self.sortAS showInView:self.view];
}
#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

#pragma mark -
#pragma mark UIPickerViewDataSource
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    if ([timeOrmajor isEqualToString:@"1"]) {
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

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSMutableArray *tempArray;
    if ([timeOrmajor isEqualToString:@"1"]) {
        tempArray = self.pickerViewArray;
    }else
    {
        tempArray = self.StarttimeArray;
    }
    return [tempArray count];
}

-(IBAction) selectXuewei:(UIButton *)button
{
    [self.majorTF resignFirstResponder];
    [self.schoolTF resignFirstResponder];
    [self.studentIdTF resignFirstResponder];
    if (button == self.majorButton) {
        timeOrmajor = @"1";
    }else if(button == StarttimeButton) {
        timeOrmajor = @"2";
    }else if(button == EndtimeButton) {
        timeOrmajor = @"3";
    }
    
  [self showSortPicker];
}

-(void)doSortSearch:(UIPickerView*) sortPicker
{
    self.pickerSelected = [majorPickView selectedRowInComponent:0];
    
    if ([timeOrmajor isEqualToString:@"1"]) {
        [self.majorButton setTitle:[self.pickerViewArray objectAtIndex:self.pickerSelected] forState:UIControlStateNormal];
    }else if([timeOrmajor isEqualToString:@"2"]) {
        self.startLable.text = [self.StarttimeArray objectAtIndex:self.pickerSelected];
    } else if([timeOrmajor isEqualToString:@"3"]) {
        self.endLable.text =[self.StarttimeArray objectAtIndex:self.pickerSelected];
    }
    
    if (self.startLable.text.length > 0 && self.endLable.text.length > 0) {
        if ([self.startLable.text intValue] >= [self.endLable.text intValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您选择的日期不正确" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alert show];
            if ([timeOrmajor isEqualToString:@"2"]) {
                self.startLable.text = @"";
                NSLog(@"%@",StarttimeButton.titleLabel.text);
            }else if([timeOrmajor isEqualToString:@"3"]) {
                self.endLable.text = @"";
                NSLog(@"%@",self.endLable.text);
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

-(IBAction) selectHospital:(UIButton *)button
{
    NSString* urlString = [NSString stringWithFormat:@"http://%@/hospital:cities?r=1352797588496",NEW_SERVER ];
    [UrlRequest sendProvince:urlString delegate:self.pro];
    [self.navigationController pushViewController:self.pro animated:YES];
}

- (void)alertView:(UIAlertView *)alertViews clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertViews.title isEqualToString:@"登录成功"]&&buttonIndex == 0) {
        imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
        appDelegate.myTabBarController.selectedIndex = 0;
    }
}
@end
