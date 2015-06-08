//
//  ForCityViewController.m
//  imdSearch
//
//  Created by  侯建政 on 11/16/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "ForCityViewController.h"
#import "JSON.h"
#import "TableViewFormatUtil.h"
#import "Strings.h"
#import "ImageViews.h"
#import "AreaForIphoneViewController.h"
#import "UrlRequest.h"
@interface ForCityViewController ()

@end

@implementation ForCityViewController

@synthesize cityDic,province,mytable,httpRequest,reset;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        [TableViewFormatUtil setContentBackGround:self.view image:IMG_BG_SIGNIN];
        
        // Custom initialization
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = province;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cityDic count];
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
    if ([cityDic count]) {
        cell.textLabel.text = [cityDic objectAtIndex:row];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    AreaForIphoneViewController *area = [[AreaForIphoneViewController alloc]init];
    NSString* urlString = [NSString stringWithFormat:@"http://accounts.i-md.com/hospital:areas?province=%@&city=%@&r=1352797562477",[self.province stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[cityDic objectAtIndex:row] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
    area.httpRequest = [UrlRequest sendProvince:urlString delegate:area];
    if (self.reset.length >0) {
        area.reset = self.reset;
    }
    area.province = province;
    area.city = [cityDic objectAtIndex:row];
    [self.navigationController pushViewController:area animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
