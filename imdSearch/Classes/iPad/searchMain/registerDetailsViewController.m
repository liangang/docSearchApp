//
//  registerDetailsViewController.m
//  imdSearch
//
//  Created by 立纲 吴 on 1/11/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "registerDetailsViewController.h"
#import "url.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "PadText.h"
#import "ImageName.h"
#import "Url_iPad.h"
#import "GrayPageControl.h"

#import "ImdAppBehavior.h"
#import "Util.h"
#import "CityViewController.h"

#define CHIEF_DOCTORS @"主任医师"
#define DEPUTY_CHIEF_DOCTORS @"副主任医师"
#define ATTENDING_DOCTORS @"主治医师"
#define DOCTORS_OR_HEALERS @"医师/医士"

@implementation registerDetailsViewController

@synthesize delegate,detailType,titleLabel,detailView,pageControl;
@synthesize loadingView;
@synthesize httpRequest;
@synthesize areaUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)dealloc
{
    self.pageControl =nil;
    self.titleLabel =nil;
    self.detailView =nil;
    myPageControl = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    selectedTitle =-1;
    selectedDepartment =-1;
    detailArray =nil;
    
    
    currentDepPage =0;
    loadingView.hidden = YES;
    if(detailType == DETAIL_TYPE_DEPARTMENT)
    {
        [self getDepartmentInfo];
    } else if(detailType == DETAIL_TYPE_HOSPITAL) {
        provincesArray = [[NSMutableArray alloc] init];
        citiesDic = [[NSMutableDictionary alloc] init];
        initialArray = [[NSMutableArray alloc] init];
        [self getHospitalInfo];
    }else if (detailType == DETAIL_TYPE_TITLE){
        [self displayView];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.titleLabel =nil;
    self.detailView =nil;
    self.pageControl =nil;
    myPageControl = nil;
    loadingView = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(IBAction)confrimButtonTapped:(id)sender
{
    if(detailType == DETAIL_TYPE_DEPARTMENT)
    {
        if(selectedDepartment ==-1)
        {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:
             ALERT_DEPARTMENT_NIL delegate:
             nil cancelButtonTitle:CMD_OK otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    if(detailType == DETAIL_TYPE_TITLE)
    {
        if(selectedTitle ==-1)
        {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:
             ALERT_TITLE_NIL delegate:nil cancelButtonTitle:
             CMD_OK otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)displayView
{
    NSLog(@"display type %d",detailType);
    
    for (UIView *view in [self.detailView subviews])
    {
        [view removeFromSuperview];
    }
    
    if(detailType == DETAIL_TYPE_DEPARTMENT)
    {
        self.titleLabel.text = SELECT_DEPARTMENT_DAILOG_TITLE;
        
        if(detailArray ==nil)
        {
            UIActivityIndicatorView* loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            loading.frame =CGRectMake(287, 196, 37, 37);
            [loading startAnimating];
            [self.detailView addSubview:loading];
        } else {
            int count =[detailArray count];
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
            
            int head =0;
            int x0 =35;
            int y0 =23;
            
            currentDepPage =selectedDepartment/pageCountMax;
            
            for (int i=0;i<count;i++)
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
                    
                    NSDictionary* dic = [detailArray objectAtIndex:head+i];
                    lbl.text = [dic objectForKey:KEY_REGISTER_CN_DEPARTMENT];
                    lbl.textAlignment = NSTextAlignmentCenter;
                    lbl.textColor = [UIColor whiteColor];
                    [dptView addSubview:lbl];
                } else {
                    UIImageView* imgDep = [[UIImageView alloc] initWithImage: [UIImage imageNamed:IMG_KESHI_NORMAL]];
                    imgDep.frame = CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40);
                    
                    [dptView addSubview:imgDep];
                    
                    UILabel* lbl = [[UILabel alloc] initWithFrame: CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40)];
                    
                    [lbl setBackgroundColor:[UIColor clearColor]];
                    NSDictionary* dic =[detailArray objectAtIndex:head+i];
                    lbl.text =[dic objectForKey:KEY_REGISTER_CN_DEPARTMENT];
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
        
    } else if(detailType == DETAIL_TYPE_TITLE) {
        
        self.titleLabel.text = SELECT_DEPARTMENT_DAILOG_TITLE;
        
        for(int i=0;i<4;i++)
        {
            UIImage* img;
            if(i== 0)
            {
                img =[UIImage imageNamed:IMG_TEXTFIELD_TOP];
                UIImageView* u1=[[UIImageView alloc] initWithImage:img];
                
                u1.frame =CGRectMake(32, 100-50, 470, 44);
                [self.detailView addSubview:u1];
                
            } else if(i ==3) {
                img =[UIImage imageNamed:IMG_TEXTFIELD_BOTTOM];
                
                UIImageView* u1=[[UIImageView alloc] initWithImage:img];
                
                u1.frame =CGRectMake(32, 100+44+2*44+1-50, 470, 44);
                [self.detailView addSubview:u1];
                
                
            } else {
                img =[UIImage imageNamed:IMG_TEXTFIELD_MIDDLE];
                
                UIImageView* u1=[[UIImageView alloc] initWithImage:img];
                
                u1.frame =CGRectMake(32, 100+44+(i-1)*44-50, 470, 46);
                [self.detailView addSubview:u1];
            }
        }
        
        detailArray =[[NSMutableArray alloc] initWithCapacity:5];
        [detailArray addObject:CHIEF_DOCTORS];
        [detailArray addObject:DEPUTY_CHIEF_DOCTORS];
        [detailArray addObject:ATTENDING_DOCTORS];
        [detailArray addObject:DOCTORS_OR_HEALERS];
        
        int yoff=0;
        for(int i=0;i<4;i++)
        {
            UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(32, 100+yoff-50, 470, 42)];
            
            lbl.text =[detailArray objectAtIndex:i];
            lbl.backgroundColor =[UIColor clearColor];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            lbl.textColor = RGBCOLOR(78, 63, 53);
            
            [self.detailView addSubview:lbl];
            
            UIButton* btn =[UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame =CGRectMake(32, 100+yoff-50, 470, 42);
            [btn addTarget:self action:@selector(selectTitle:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag =i;
            [self.detailView addSubview:btn];
            
            if(i == selectedTitle)
            {
                UIImageView* u1=[[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_CHECK]];
                
                u1.frame =CGRectMake(200, 100+14+yoff-50, 16, 16);
                [self.detailView addSubview:u1];
            }
            
            yoff+=44;
            if(i ==0)yoff+=3;
        }
    }else if (detailType == DETAIL_TYPE_HOSPITAL) {
        self.titleLabel.text = SELECT_DEPARTMENT_DAILOG_PROVICE;
        
        if(provincesArray ==nil)
        {
            UIActivityIndicatorView* loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            loading.frame =CGRectMake(287, 196, 37, 37);
            [loading startAnimating];
            [self.detailView addSubview:loading];
        } else {
            int count =[provincesArray count];
            int pageCountMax =(DEPART_COL)*(DEPART_ROW);
            
            int pages = count/pageCountMax;
            
            if(count % pageCountMax >0)     pages++;
            
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
            
            currentDepPage =selectedDepartment/pageCountMax;
            
            for (int i=0;i<count;i++)
            {
                int p= i/pageCountMax;
                int r= (i%pageCountMax)/DEPART_COL;
                int c= (i%pageCountMax)%DEPART_COL;
                
                if(i == selectedDepartment) {
                    UIImageView* imgDep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_KESHI_SELECTED]];
                    imgDep.frame = CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40);
                    
                    [dptView addSubview:imgDep];
                    
                    UILabel* lbl =
                    [[UILabel alloc] initWithFrame:CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40)];
                    [lbl setBackgroundColor:[UIColor clearColor]];
                    
                    lbl.text =[provincesArray objectAtIndex:i];
                    lbl.textAlignment = NSTextAlignmentCenter;
                    lbl.textColor =[UIColor whiteColor];
                    [dptView addSubview:lbl];
                    
                } else {
                    UIImageView* imgDep = [[UIImageView alloc] initWithImage: [UIImage imageNamed:IMG_KESHI_NORMAL]];
                    imgDep.frame = CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40);
                    
                    [dptView addSubview:imgDep];
                    
                    UILabel* lbl = [[UILabel alloc] initWithFrame: CGRectMake(x0+c*175+p*dptView.frame.size.width, y0+r*65, 132, 40)];
                    
                    [lbl setBackgroundColor:[UIColor clearColor]];
                    
                    lbl.text =[provincesArray objectAtIndex:i];
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
    }
}

-(void)selectTitle:(id)sender
{
    UIButton* btn =(UIButton*)sender;
    
    selectedTitle =btn.tag;
    
    [[NSUserDefaults standardUserDefaults] setObject:[detailArray objectAtIndex:selectedTitle] forKey:KEY_REGISTER_TITLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self displayView];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)selectDepartment:(id)sender
{
    UIButton* btn =(UIButton*)sender;
    
    selectedDepartment =btn.tag;
    
    if (detailType == DETAIL_TYPE_DEPARTMENT) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[detailArray objectAtIndex:selectedDepartment] forKey:KEY_REGISTER_DEPARTMENT_INFO];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self displayView];
        NSLog(@"%@",[detailArray objectAtIndex:selectedDepartment]);
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if (detailType == DETAIL_TYPE_HOSPITAL) {
        CityViewController* detailTitleVC = [[CityViewController alloc] initWithNibName:@"registerDetailsViewController" bundle:nil];
        detailTitleVC.city = [provincesArray objectAtIndex:selectedDepartment];
        detailTitleVC.cityDic = [citiesDic copy];
        [self.navigationController pushViewController:detailTitleVC animated:YES];
    }
}


#pragma mark - table delegate
- (NSInteger)tableView:(UITableView *)aTableView  numberOfRowsInSection:(NSInteger)section
{
    if(detailType == DETAIL_TYPE_DEPARTMENT)
        return 45;
    else
        return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath:%@", indexPath);
    return nil;
}

-(void)getHospitalInfo
{
    loadingView.hidden = NO;
    NSString* urlString = URL_FOR_PROVINCE;
    NSLog(@"checking department url = %@",urlString);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:REQUEST_GET_DEPARTMENT forKey:REQUEST_TYPE];
    [request setUserInfo:userInfo];
    
    request.delegate = self;
    [request startAsynchronous];
}

-(void)getDepartmentInfo
{
    loadingView.hidden = NO;
    NSString* urlString = [NSString stringWithFormat:DEPARTMENT_URL,SEARCH_SERVER];
    
    NSLog(@"checking department url = %@",urlString);
    self.httpRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.httpRequest addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [self.httpRequest addRequestHeader:ACCEPT value:TYPE_JSON];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:REQUEST_GET_DEPARTMENT forKey:REQUEST_TYPE];
    [self.httpRequest setUserInfo:userInfo];
    
    self.httpRequest.delegate = self;
    [self.httpRequest startAsynchronous];
}

-(void)requestFinished:(ASIHTTPRequest*)request
{
    if (detailType == DETAIL_TYPE_DEPARTMENT) {
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
            detailArray =[info copy];
            
            [self displayView];
        }
        
    }else if(detailType == DETAIL_TYPE_HOSPITAL) {
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
            NSLog(@"check1..%@, check2..%@, check3..%@",provincesArray, citiesDic,initialArray);
            [self displayView];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest*)request
{
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    loadingView.hidden = YES;
    NSLog(@"%@",[request responseString]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"睿医" message:@"网络出错-­‐请检查网络设置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"scrollViewDidEndDragging:%i", page);
    [myPageControl setCurrentPage:page];
}

@end
