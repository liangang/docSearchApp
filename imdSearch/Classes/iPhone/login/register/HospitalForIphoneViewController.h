//
//  HospitalForIphoneViewController.h
//  imdSearch
//
//  Created by  侯建政 on 11/16/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
@interface HospitalForIphoneViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITableView *mytable;
@property (nonatomic, retain) ASIHTTPRequest* httpRequest;
@property (nonatomic,retain)NSMutableArray *hospitalArray;
@property (nonatomic,retain)NSMutableArray *hospitalIdArray;
@property (nonatomic,retain)NSMutableDictionary *dataForHospital;
@property (nonatomic,copy) NSString *area;
@property (nonatomic, copy) NSString *reset;
@end
