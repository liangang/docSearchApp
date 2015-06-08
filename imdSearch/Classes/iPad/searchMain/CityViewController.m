//
//  CityViewController.m
//  imdSearch
//
//  Created by  侯建政 on 11/15/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "CityViewController.h"
#import "ImageName.h"
#import "AreaViewController.h"
@interface CityViewController ()

@end

@implementation CityViewController
@synthesize city;
@synthesize cityDic;

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
    
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    
    [self displayView];
    loadingView.hidden = YES;
}

-(void)displayView
{
    for (UIView *view in [self.detailView subviews])
    {
        [view removeFromSuperview];
    }
    
    self.titleLabel.text = city;
    
    if(cityDic ==nil)
    {
        UIActivityIndicatorView* loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        loading.frame =CGRectMake(287, 196, 37, 37);
        [loading startAnimating];
        [self.detailView addSubview:loading];
    } else {
        int count =[[cityDic objectForKey:city] count];
        int pageCountMax =(DEPART_COL)*(DEPART_ROW);
        
        int pages = count/pageCountMax;
        
        if(count % pageCountMax >0)     pages++;
        
        dptView =[[UIScrollView alloc] initWithFrame:self.detailView.bounds];
        dptView.contentSize = CGSizeMake(dptView.frame.size.width*pages, dptView.frame.size.height);
        dptView.pagingEnabled =YES;
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
        
        for (int i=0; i<count; i++)
        {
            int p= i/pageCountMax;
            int r= (i%pageCountMax)/DEPART_COL;
            int c= (i%pageCountMax)%DEPART_COL;
            
            if(i == selectedDepartment)
            {
                UIImageView* imgDep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_KESHI_SELECTED]];
                imgDep.frame = CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40);
                
                [dptView addSubview:imgDep];
                
                UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40)];
                [lbl setBackgroundColor:[UIColor clearColor]];
                
                lbl.text =[[cityDic objectForKey:city] objectAtIndex:i];
                lbl.textAlignment = NSTextAlignmentCenter;
                lbl.textColor =[UIColor whiteColor];
                [dptView addSubview:lbl];
                
            } else {
                UIImageView* imgDep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_KESHI_NORMAL]];
                imgDep.frame = CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40);
                
                [dptView addSubview:imgDep];
                
                UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40)];
                
                [lbl setBackgroundColor:[UIColor clearColor]];
                NSLog(@"%@",[cityDic objectForKey:city]);
                lbl.text =[[cityDic objectForKey:city] objectAtIndex:i];
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
        
        GrayPageControl* pc = [[GrayPageControl alloc] initWithFrame:
                               CGRectMake(0, y0 + DEPART_ROW * 65, dptView.frame.size.width, 48 / 2)];
        pc.userInteractionEnabled = NO;
        pc.numberOfPages = pages;
        [pc setCurrentPage:currentDepPage];
        myPageControl = pc;
        [self.detailView addSubview:myPageControl];
    }
}

-(void)selectDepartment:(id)sender
{
    UIButton* btn =(UIButton*)sender;
    selectedDepartment =btn.tag;
    AreaViewController* detailTitleVC = [[AreaViewController alloc] initWithNibName:@"registerDetailsViewController" bundle:nil];
    detailTitleVC.province = city;
    detailTitleVC.city = [[cityDic objectForKey:city] objectAtIndex:selectedDepartment];
    [self.navigationController pushViewController:detailTitleVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
