//
//  ForCityViewController.h
//  imdSearch
//
//  Created by  侯建政 on 11/16/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
@interface ForCityViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITableView *mytable;
@property (nonatomic, retain) ASIHTTPRequest* httpRequest;
@property (nonatomic, retain) NSMutableArray* cityDic;
@property (nonatomic, assign) NSString *province;
@property (nonatomic, copy) NSString *reset;
@end

