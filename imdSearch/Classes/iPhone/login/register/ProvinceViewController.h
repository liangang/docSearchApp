//
//  ProvinceViewController.h
//  imdSearch
//
//  Created by  侯建政 on 11/15/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
@interface ProvinceViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITableView *mytable;
@property (nonatomic, retain) ASIHTTPRequest       * httpRequest;
@property (nonatomic, retain) NSMutableDictionary  * dataArray;
@property (nonatomic, retain) NSMutableArray       * provincesArray;
@property (nonatomic, retain) NSMutableDictionary  * citiesDic;
@property (nonatomic, retain) NSMutableArray       * initialArray;
@property (nonatomic, retain) UIAlertView          *alertView;
@property (nonatomic, copy)   NSString             *reset;
@end
