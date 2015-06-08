//
//  HospitaiAddressViewController.m
//  imdSearch
//
//  Created by  侯建政 on 11/15/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "HospitaiAddressViewController.h"
#import "Url_iPad.h"
#import "ImageName.h"
#import "JSON.h"
#import "registerFinishViewController.h"

#import "newVerifiedViewController.h"
#import "UserInfoPadViewController.h"

#define DEPART_COLS 2
@interface HospitaiAddressViewController ()

@end

@implementation HospitaiAddressViewController
@synthesize area;
@synthesize province;
@synthesize city,temp;
@synthesize dataForHospital,hospitalArray,hospitalIdArray;
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
    [self getHospitalInfo];
    hospitalArray = [[NSMutableArray alloc]init];
    hospitalIdArray = [[NSMutableArray alloc]init];
}

-(void)displayView
{
    for (UIView *view in [self.detailView subviews])
    {
        [view removeFromSuperview];
    }
    
    self.titleLabel.text = area;
    
    if(hospitalArray ==nil)
    {
        UIActivityIndicatorView* loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        loading.frame =CGRectMake(287, 196, 37, 37);
        [loading startAnimating];
        [self.detailView addSubview:loading];
    } else {
        int count =[hospitalArray count];
        int pageCountMax =(DEPART_COLS)*(DEPART_ROW);
        
        int pages = count/pageCountMax;
        
        if(count % pageCountMax >0)     pages++;
        
        dptView =[[UIScrollView alloc] initWithFrame:self.detailView.bounds];
        dptView.contentSize = CGSizeMake(dptView.frame.size.width*pages, dptView.frame.size.height);
        dptView.pagingEnabled = YES;
        dptView.delegate = self;
        
        int pageCount;
        
        if(currentDepPage == pages-1)
        {
            pageCount = count -pageCountMax*(pages-1);
        } else {
            pageCount = pageCountMax;
        }
        
        int x0 = 20;
        int y0 = 23;
        
        currentDepPage = selectedDepartment/pageCountMax;
        
        for (int i=0;i<count;i++)
        {
            int p = i/pageCountMax;
            int r = (i%pageCountMax)/DEPART_COLS;
            int c = (i%pageCountMax)%DEPART_COLS;
            
            if(i == selectedDepartment)
            {
                UIImageView* imgDep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_KESHI_SELECTED]];
                imgDep.frame = CGRectMake(x0+c*260+p*dptView.frame.size.width, y0+r*65, 250, 40);
                
                [dptView addSubview:imgDep];
                
                UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(x0+c*260+p*dptView.frame.size.width, y0+r*65, 250, 40)];
                [lbl setBackgroundColor:[UIColor clearColor]];
                
                lbl.text =[hospitalArray objectAtIndex:i];
                [lbl setFont:[UIFont systemFontOfSize:12.0]];
                lbl.textAlignment = NSTextAlignmentCenter;
                lbl.textColor =[UIColor whiteColor];
                [dptView addSubview:lbl];
                
            } else {
                UIImageView* imgDep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_KESHI_NORMAL]];
                imgDep.frame = CGRectMake(x0+c*260+p*dptView.frame.size.width, y0+r*65, 250, 40);
                
                [dptView addSubview:imgDep];
                
                UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(x0+c*260+p*dptView.frame.size.width, y0+r*65, 250, 40)];
                
                [lbl setBackgroundColor:[UIColor clearColor]];
                
                lbl.text =[hospitalArray objectAtIndex:i];
                lbl.textAlignment = NSTextAlignmentCenter;
                lbl.textColor = RGBCOLOR(78, 63, 53);
                [lbl setFont:[UIFont systemFontOfSize:12.0]];
                [dptView addSubview:lbl];
            }
            
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(x0+c*260+p*dptView.frame.size.width, y0+r*65, 250, 40);
            [btn addTarget:self action:@selector(selectDepartment:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag =i;
            [dptView addSubview:btn];
        }
        
        [self.detailView addSubview:dptView];
        dptView.contentOffset = CGPointMake(currentDepPage*self.detailView.bounds.size.width, self.detailView.bounds.origin.y);
        dptView.delegate = self;
        dptView.showsHorizontalScrollIndicator = NO;
        
        NSLog(@"show page control:%i,%i", pages, currentDepPage);
        
        GrayPageControl* pc = [[GrayPageControl alloc] initWithFrame: CGRectMake(0, y0 + DEPART_ROW * 65, dptView.frame.size.width, 48 / 2)];
        pc.userInteractionEnabled = NO;
        pc.numberOfPages = pages;
        [pc setCurrentPage:currentDepPage];
        myPageControl = pc;
        [self.detailView addSubview:myPageControl];
    }
}

-(void)getHospitalInfo
{
    loadingView.hidden = NO;
    NSString* urlString = [NSString stringWithFormat:@"http://accounts.i-md.com/hospital?province=%@&city=%@&area=%@&r=1352797562717",[province stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[area stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"checking department url = %@",urlString);
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:REQUEST_GET_DEPARTMENT forKey:REQUEST_TYPE];
    [request setUserInfo:userInfo];
    
    request.delegate = self;
    [request startAsynchronous];
}

-(void)requestFinished:(ASIHTTPRequest*)request
{
    temp = @"1";
    loadingView.hidden = YES;
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
        dataForHospital = [info copy];
        [dataForHospital objectForKey:@"data"];
        
        for (int i = 0, sum = [[dataForHospital objectForKey:@"data"] count]; i < sum; i++) {
            [hospitalArray addObject:[[[dataForHospital objectForKey:@"data"] objectAtIndex:i] objectForKey:@"hospital"]];
            [hospitalIdArray addObject:[[[dataForHospital objectForKey:@"data"] objectAtIndex:i] objectForKey:@"id"]];
        }
        
        [self displayView];
    }
}


-(void)requestFailed:(ASIHTTPRequest*)request
{
    temp = @"1";
    NSLog(@"%@",self.httpRequest);
    loadingView.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}

-(void)selectDepartment:(id)sender
{
    UIButton* btn =(UIButton*)sender;
    selectedDepartment =btn.tag;
    // = [hospitalIdArray objectAtIndex:selectedDepartment];
    NSArray *array=self.navigationController.viewControllers;
    //找出数组的倒数第二个对象
    UIViewController *viewController = [array objectAtIndex:[array count]-5];
    
    if ([hospitalArray count]) {
        if ([viewController isKindOfClass:[newVerifiedViewController class]]) {
            
            newVerifiedViewController *root= (newVerifiedViewController *)viewController;
            root.fieldHospital.text = [hospitalArray objectAtIndex:selectedDepartment];
            root.isSelectHospital = YES;
            root.hospitalId = [hospitalIdArray objectAtIndex:selectedDepartment];
            
        }else if ([viewController isKindOfClass:[UserInfoPadViewController class]]){
            
            UserInfoPadViewController *userBaseInfo = (UserInfoPadViewController *)viewController;
            userBaseInfo.hospitalLabel.text = [hospitalArray objectAtIndex:selectedDepartment];
            userBaseInfo.isSystemHospital = YES;
            userBaseInfo.hospitalInfoId = [hospitalIdArray objectAtIndex:selectedDepartment];
            
        }else if ([viewController isKindOfClass:[registerFinishViewController class]]){
            
            registerFinishViewController *finishViewController = (registerFinishViewController *)viewController;
            finishViewController.fieldHospital.text = [hospitalArray objectAtIndex:selectedDepartment];
            finishViewController.isSelectHospital = YES;
            finishViewController.hospitalId = [hospitalIdArray objectAtIndex:selectedDepartment];
            
        }
        
    }
    
    [self.navigationController popToViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
