//
//  AreaForIphoneViewController.m
//  imdSearch
//
//  Created by  侯建政 on 11/16/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "AreaForIphoneViewController.h"
#import "JSON.h"
#import "Strings.h"
#import "ImageViews.h"
#import "TableViewFormatUtil.h"
#import "HospitalForIphoneViewController.h"
#import "UrlRequest.h"
@interface AreaForIphoneViewController ()

@end

@implementation AreaForIphoneViewController
@synthesize province,city,area;
@synthesize httpRequest,mytable;
@synthesize areaDic;
@synthesize reset;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [TableViewFormatUtil setContentBackGround:self.view image:IMG_BG_SIGNIN];
        
        // Custom initialization
    }
    return self;
}

- (void)popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated
{
    self.title = city;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Asy Request

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSString* responseString =[request responseString];
    NSLog(@"request finished %@",responseString);
    NSMutableArray* info;
    if (responseString == (id)[NSNull null] || responseString.length == 0 )
    {
        info =nil;
    } else {
        info =[responseString JSONValue];
    }
    
    if(info != nil)
    {
        areaDic = [info copy] ;
        [self.mytable reloadData];
    }}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alertw = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
  if ([request.error code] == ASIRequestTimedOutErrorType) {
    alertw.message = REQUEST_TIMEOUT_MESSAGE;
    alertw.title = HINT_TEXT;
  }
    [alertw show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[areaDic objectForKey:@"data"] count];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier: CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    //文本层
    if ([[areaDic objectForKey:@"data"] count]) {
        cell.textLabel.text = [[areaDic objectForKey:@"data"] objectAtIndex:row];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    area = [[areaDic objectForKey:@"data"]objectAtIndex:row];
    HospitalForIphoneViewController *hospital = [[HospitalForIphoneViewController alloc]init];
    NSString* urlString = [NSString stringWithFormat:@"http://accounts.i-md.com/hospital?province=%@&city=%@&area=%@&r=1352797562717",[province stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[area stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    hospital.httpRequest = [UrlRequest sendProvince:urlString delegate:hospital];
    
    if (self.reset.length >0) {
        hospital.reset = self.reset;
    }
    hospital.area = area;
    [self.navigationController pushViewController:hospital animated:YES];
}
@end
