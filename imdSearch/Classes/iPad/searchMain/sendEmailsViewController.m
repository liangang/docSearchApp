//
//  sendEmailsViewController.m
//  imdSearch
//
//  Created by  侯建政 on 12/7/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "sendEmailsViewController.h"

@interface sendEmailsViewController ()

@end

@implementation sendEmailsViewController
@synthesize titleText;
@synthesize studentNumber;
@synthesize studentMessage,studentMail;
@synthesize myTable;
@synthesize number;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.studentNumber = [[UITextField alloc] initWithFrame:CGRectMake(2, 10, 400, 27)];
    self.studentNumber.text = self.number;
    self.studentNumber.backgroundColor = [UIColor clearColor];
    self.studentNumber.textAlignment = NSTextAlignmentLeft;
    self.studentNumber.font = [UIFont systemFontOfSize:18.0];
    self.studentNumber.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
    self.studentMessage = [UIButton buttonWithType:0];
    self.studentMessage.frame = CGRectMake(15, 45, 510, 100);
    [self.studentMessage setTitle:@"为验证核实您的学生身份，请将「学生证照片或扫描件」发送至" forState:0];
    self.studentMessage.titleLabel.font = [UIFont systemFontOfSize:18.0];
    self.studentMessage.titleLabel.numberOfLines = 0;
    [self.studentMessage setTitleColor:[UIColor darkGrayColor] forState:0];
    [self.studentMessage addTarget:self action:@selector(turnToMail) forControlEvents:UIControlEventTouchUpInside];
    
    self.studentMail = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 540, 35)] ;
    self.studentMail.text = @"verify@i-md.com";
    
    self.studentMail.font = [UIFont systemFontOfSize:18.0];
    self.studentMail.textColor = [UIColor blueColor];
    self.studentMail.textAlignment = NSTextAlignmentCenter;
    self.studentMail.backgroundColor = [UIColor clearColor];
    [self.studentMessage addSubview:self.studentMail];
    [self.myTable addSubview:self.studentMessage];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
    }
    [cell.contentView addSubview:self.studentNumber];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (IBAction)dismissview:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)turnToMail
{
    [self.studentNumber resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.studentNumber becomeFirstResponder];
}
@end
