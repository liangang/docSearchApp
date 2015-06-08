//
//  AreaViewController.m
//  imdSearch
//
//  Created by  侯建政 on 11/15/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "AreaViewController.h"
#import "Url_iPad.h"
#import "JSON.h"
#import "ImageName.h"
#import "HospitaiAddressViewController.h"
@interface AreaViewController ()

@end

@implementation AreaViewController
@synthesize city;
@synthesize province;
@synthesize areaDic;
@synthesize temp;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)displayView
{
    if ([temp isEqualToString:@"1"]) {
        for (UIView *view in [self.detailView subviews])
        {
            [view removeFromSuperview];
        }
        
        self.titleLabel.text = city;
        
        if(areaDic ==nil)
        {
            UIActivityIndicatorView* loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            loading.frame =CGRectMake(287, 196, 37, 37);
            [loading startAnimating];
            [self.detailView addSubview:loading];
        } else {
            int count =[[areaDic objectForKey:@"data"] count];
            int pageCountMax =(DEPART_COL)*(DEPART_ROW);
            
            int pages = count/pageCountMax;
            
            if(count % pageCountMax >0)        pages++;
            
            dptView = [[UIScrollView alloc] initWithFrame:self.detailView.bounds];
            dptView.contentSize = CGSizeMake(dptView.frame.size.width*pages, dptView.frame.size.height);
            dptView.pagingEnabled = YES;
            dptView.delegate = self;
            
            int pageCount;
            
            if(currentDepPage ==pages-1)
            {
                pageCount =count -pageCountMax*(pages-1);
            } else {
                pageCount =pageCountMax;
            }
            
            int x0 =35;
            int y0 =23;
            
            currentDepPage = selectedDepartment/pageCountMax;
            
            for (int i=0;i<count;i++)
            {
                int p= i/pageCountMax;
                int r= (i%pageCountMax)/DEPART_COL;
                int c= (i%pageCountMax)%DEPART_COL;
                
                if(i == selectedDepartment)
                {
                    UIImageView* imgDep = [[UIImageView alloc] initWithImage: [UIImage imageNamed:IMG_KESHI_SELECTED]];
                    imgDep.frame = CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40);
                    
                    [dptView addSubview:imgDep];
                    
                    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40)];
                    [lbl setBackgroundColor:[UIColor clearColor]];
                    
                    lbl.text =[[areaDic objectForKey:@"data"] objectAtIndex:i];
                    lbl.textAlignment = NSTextAlignmentCenter;
                    lbl.textColor =[UIColor whiteColor];
                    [dptView addSubview:lbl];
                    
                } else {
                    UIImageView* imgDep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_KESHI_NORMAL]];
                    imgDep.frame = CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40);
                    
                    [dptView addSubview:imgDep];
                    
                    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40)];
                    
                    [lbl setBackgroundColor:[UIColor clearColor]];
                    
                    lbl.text =[[areaDic objectForKey:@"data"] objectAtIndex:i];
                    lbl.textAlignment = NSTextAlignmentCenter;
                    lbl.textColor = RGBCOLOR(78, 63, 53);
                    
                    [dptView addSubview:lbl];
                }
                
                
                UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40);
                [btn addTarget:self action:@selector(selectDepartment:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag =i;
                [dptView addSubview:btn];
            }
            
            [self.detailView addSubview:dptView];
            dptView.contentOffset = CGPointMake(currentDepPage*self.detailView.bounds.size.width, self.detailView.bounds.origin.y);
            dptView.delegate = self;
            dptView.showsHorizontalScrollIndicator = NO;
            
            NSLog(@"show page control:%i,%i", pages, currentDepPage);
            
            GrayPageControl* pc = [[GrayPageControl alloc] initWithFrame:CGRectMake(0, y0 + DEPART_ROW * 65, dptView.frame.size.width, 48 / 2)];
            pc.userInteractionEnabled = NO;
            pc.numberOfPages = pages;
            [pc setCurrentPage:currentDepPage];
            myPageControl = pc;
            [self.detailView addSubview:myPageControl];
        }
    } else {
        areaDic = [[NSMutableDictionary alloc]init];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getAREAInfo];
}

-(void)getAREAInfo
{
    loadingView.hidden = NO;
    
    NSString* urlString = [NSString stringWithFormat:@"http://accounts.i-md.com/hospital:areas?province=%@&city=%@&r=1352797562477",[province stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
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
        areaDic = [info copy] ;
        [self displayView];
    }
}


-(void)requestFailed:(ASIHTTPRequest*)request
{
    NSLog(@"%@",self.httpRequest);
    temp = @"1";
    loadingView.hidden = YES;
    NSLog(@"request failed");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}
-(void)selectDepartment:(id)sender
{
    UIButton* btn =(UIButton*)sender;
    selectedDepartment =btn.tag;
    HospitaiAddressViewController* detailTitleVC = [[HospitaiAddressViewController alloc] initWithNibName:@"registerDetailsViewController" bundle:nil];
    detailTitleVC.province = province;
    detailTitleVC.city = city;
    detailTitleVC.area = [[areaDic objectForKey:@"data"] objectAtIndex:selectedDepartment];
    [self.navigationController pushViewController:detailTitleVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
