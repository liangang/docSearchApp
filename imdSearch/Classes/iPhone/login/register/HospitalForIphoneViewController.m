//
//  HospitalForIphoneViewController.m
//  imdSearch
//
//  Created by  侯建政 on 11/16/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "HospitalForIphoneViewController.h"
#import "JSON.h"
#import "Strings.h"
#import "ImageViews.h"
#import "TableViewFormatUtil.h"
#import "LoginNewUserStep2.h"

#import "UserBaseInfoViewController.h"
#import "UserInfoViewController.h"

@interface HospitalForIphoneViewController ()

@end

@implementation HospitalForIphoneViewController
@synthesize mytable,httpRequest;
@synthesize dataForHospital,hospitalArray,hospitalIdArray;
@synthesize area;
@synthesize reset;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [TableViewFormatUtil setContentBackGround:self.view image:IMG_BG_SIGNIN];
        
    }
    return self;
}
- (void)popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)requestFinished:(ASIHTTPRequest*)request
{
    NSString* responseString =[request responseString];
    NSLog(@"request finished %@",responseString);
    NSMutableArray* info;
    if (responseString == (id)[NSNull null] || responseString.length == 0 )
    {
        info =nil;
    }
    else
    {
        info =[responseString JSONValue];
    }
    if(info != nil)
    {
        dataForHospital = [info copy];
        [dataForHospital objectForKey:@"data"];
        for (int i=0; i<[[dataForHospital objectForKey:@"data"] count]; i++) {
            [hospitalArray addObject:[[[dataForHospital objectForKey:@"data"] objectAtIndex:i] objectForKey:@"hospital"]];
            [hospitalIdArray addObject:[[[dataForHospital objectForKey:@"data"] objectAtIndex:i] objectForKey:@"id"]];
        }
        [mytable reloadData];
    }
}


-(void)requestFailed:(ASIHTTPRequest*)request
{
    NSLog(@"request failed");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
  if ([request.error code] == ASIRequestTimedOutErrorType) {
    alert.message = REQUEST_TIMEOUT_MESSAGE;
    alert.title = HINT_TEXT;
  }
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    hospitalArray = [[NSMutableArray alloc]init];
    hospitalIdArray = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated
{
    self.title = area;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [hospitalArray count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    //文本层
    if ([hospitalArray count]) {
        cell.textLabel.text = [hospitalArray objectAtIndex:row];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    NSArray *array=self.navigationController.viewControllers;
    
    if ([self.reset isEqualToString:@"RESET"]) {
        for (UIViewController *viewController in array) {
            
            if ([viewController isKindOfClass:[UserBaseInfoViewController class]]) {
                UserBaseInfoViewController *user = (UserBaseInfoViewController *)viewController;
                if ([hospitalArray count]) {
                    [user.hospitalLabel setText:[hospitalArray objectAtIndex:row]];
                    user.hospitalInfoId = [hospitalIdArray objectAtIndex:row];
                    user.isSystemHospital = YES;
                }
                
                [self.navigationController popToViewController:viewController animated:YES];
                break;
            }
            else if ([viewController isKindOfClass:[UserInfoViewController class]]){
                UserInfoViewController *user = (UserInfoViewController *)viewController;
                if ([hospitalArray count]) {
                    [user.lableHospital setText:[hospitalArray objectAtIndex:row]];
                    user.hospitalId = [hospitalIdArray objectAtIndex:row];
                    user.isSelectHospital = YES;
                }
                
                [self.navigationController popToViewController:viewController animated:YES];
                
                break;
            }
        }
    }else{
        LoginNewUserStep2 *root=[array objectAtIndex:[array count]-5];
        if ([hospitalArray count]) {
            [root.hospitalButton setTitle:[hospitalArray objectAtIndex:row] forState:UIControlStateNormal];
        }
        
        if ([hospitalIdArray count]) {
            root.hospitalId = [hospitalIdArray objectAtIndex:row];
        }
        [self.navigationController popToViewController:root animated:YES];
    }
}
@end
