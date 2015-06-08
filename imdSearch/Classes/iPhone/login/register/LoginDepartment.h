//
//  LoginDepartment.h
//  imdSearch
//
//  Created by Huajie Wu on 12-2-7.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@interface LoginDepartment : UIViewController <ASIHTTPRequestDelegate,UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* departmentList;
    IBOutlet UIScrollView* scrollView;
    UIAlertView* alertView;
    NSString* currentKey;
    NSString* currentCn;
    UIButton* selectedBtn;
    ASIHTTPRequest* _httpRequest;
}
@property (nonatomic, retain) ASIHTTPRequest* httpRequest;


@property (nonatomic,assign) id delegate;
@property (nonatomic,retain) UIScrollView* scrollView;
@property (nonatomic,retain) UIAlertView* alertView;
@property (nonatomic,retain) NSMutableArray* departmentList;
@property (nonatomic,retain) NSString* currentKey;
@property (nonatomic,retain) NSString* currentCn;
@property (nonatomic,retain) UIButton* selectedBtn;

@property (strong, nonatomic) IBOutlet UITableView *departTableView;

-(void) popBack;

-(void) selectDepartment;

-(void) showDepartments;
-(void) requestDepartment;

@end
