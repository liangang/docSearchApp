//
//  AreaForIphoneViewController.h
//  imdSearch
//
//  Created by  侯建政 on 11/16/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
@interface AreaForIphoneViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITableView *mytable;
@property (nonatomic, retain) ASIHTTPRequest* httpRequest;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, retain) NSMutableDictionary *areaDic;
@property (nonatomic, copy) NSString *reset;
@end
