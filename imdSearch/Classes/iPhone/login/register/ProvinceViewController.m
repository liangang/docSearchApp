//
//  ProvinceViewController.m
//  imdSearch
//
//  Created by  侯建政 on 11/15/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "ProvinceViewController.h"
#import "UrlRequest.h"
#import "JSON.h"
#import "TableViewFormatUtil.h"
#import "Strings.h"
#import "ImageViews.h"
#import "ForCityViewController.h"
@interface ProvinceViewController ()

@end

@implementation ProvinceViewController
@synthesize dataArray,provincesArray,citiesDic,initialArray;
@synthesize alertView,mytable,httpRequest;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我所在的医院";
        
        //      [TableViewFormatUtil setContentBackGround:self.view image:IMG_BG_SIGNIN];
        
        // Custom initialization
//        self.navigationItem.leftBarButtonItem = [TableViewFormatUtil customBarButton:IMG_BTN_BACK_2WORDS_NORMAL title:@"返回" target:self action:@selector(popBack)];
        
        alertView = [[UIAlertView alloc] initWithTitle:REGISTER_MESSAGE message:REGISTER_SUCCESS delegate:self cancelButtonTitle:REGISTER_CANCEL otherButtonTitles:nil];
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
    provincesArray = [[NSMutableArray alloc] init];
    citiesDic = [[NSMutableDictionary alloc] init];
    initialArray = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [provincesArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"按省份选择城市(按音序排列)";
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
    if ([provincesArray count]) {
        cell.textLabel.text = [provincesArray objectAtIndex:row];
    }
    if ([citiesDic count]) {
        if ([[citiesDic objectForKey:[provincesArray objectAtIndex:row]] count]==1)
        {
            if ([[provincesArray objectAtIndex:row]isEqualToString:@"西藏"]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    ForCityViewController *city = [[ForCityViewController alloc]init];
    city.province = [provincesArray objectAtIndex:row];
    if (self.reset.length >0) {
        city.reset = self.reset;
    }
    city.cityDic = [citiesDic objectForKey:[provincesArray objectAtIndex:row]];
    [self.navigationController pushViewController:city animated:YES];
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
        dataArray =[info copy];
        NSLog(@"%d",[[dataArray objectForKey:@"data"] count]) ;
        for (int i=0; i<[[dataArray objectForKey:@"data"] count]; i++) {
            NSMutableArray *Aprovinces = [[[[dataArray objectForKey:@"data"] objectAtIndex:i] objectForKey:@"provinces"] copy];
            for (int j=0; j<[Aprovinces count]; j++) {
                [provincesArray addObject:[[Aprovinces objectAtIndex:j] objectForKey:@"province"]];
                [citiesDic setObject:[[Aprovinces objectAtIndex:j] objectForKey:@"cities"] forKey:[[Aprovinces objectAtIndex:j] objectForKey:@"province"]];
            }
            [initialArray addObject:[[[dataArray objectForKey:@"data"] objectAtIndex:i] objectForKey:@"initial"]];
        }
        NSLog(@"check1..%@",provincesArray);
        NSLog(@"check2..%@",citiesDic);
        NSLog(@"check3..%@",initialArray);
        [self.mytable reloadData];
    }
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alertw = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
  if ([request.error code] == ASIRequestTimedOutErrorType) {
    alertw.message = REQUEST_TIMEOUT_MESSAGE;
    alertw.title = HINT_TEXT;
  }
    [alertw show];
}

- (void) dealloc
{
    if (self.httpRequest) {
        [self.httpRequest clearDelegatesAndCancel];
    }
}

@end
