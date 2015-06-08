//
//  registerDetailsViewController.h
//  imdSearch
//
//  Created by 立纲 吴 on 1/11/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrayPageControl.h"
#import "ASIHTTPRequest.h"
#define DETAIL_TYPE_DEPARTMENT 0
#define DETAIL_TYPE_TITLE 1
#define DETAIL_TYPE_HOSPITAL 2
#define DETAIL_TYPE_AREA 3

#define DEPART_COL 3
#define DEPART_ROW 4


@interface registerDetailsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>
{
    
    id delegate;
    
    IBOutlet UILabel* titleLabel;
    
    UIScrollView* dptView;
    UITableView* detailTable;
    
    IBOutlet UIPageControl* pageControl;
    
    int detailType;
    NSMutableArray* detailArray;
    NSMutableDictionary* dataArray;
    NSMutableArray* provincesArray;
    NSMutableDictionary* citiesDic;
    NSMutableArray* initialArray;
    //NSMutableDictionary*
    int selectedTitle;
    int selectedDepartment;
    int currentDepPage;
    
    GrayPageControl* myPageControl;
    
    IBOutlet UIView* loadingView;
    ASIHTTPRequest *httpRequest;
    NSString *areaUrl;
}

@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) IBOutlet UILabel* titleLabel;

@property (readwrite,assign) int detailType;
@property (readwrite,assign) IBOutlet UIView* detailView;

@property (nonatomic,retain) IBOutlet UIPageControl* pageControl;

@property (nonatomic,retain) IBOutlet UIView* loadingView;
@property (nonatomic,retain) ASIHTTPRequest *httpRequest;

@property (readwrite,copy) NSString *areaUrl;
-(IBAction)backButtonTapped:(id)sender;
-(IBAction)confrimButtonTapped:(id)sender;
-(void)getDepartmentInfo;

-(void)displayView;
-(void)selectTitle:(id)sender;
@end

