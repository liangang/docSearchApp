//
//  HospitaiAddressViewController.h
//  imdSearch
//
//  Created by  侯建政 on 11/15/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "registerDetailsViewController.h"

@interface HospitaiAddressViewController : registerDetailsViewController

@property (nonatomic,copy)  NSString *province;
@property (nonatomic,copy)  NSString *city;
@property (nonatomic,copy)  NSString *area;
@property (nonatomic,copy)  NSString *temp;
@property (nonatomic,copy)  NSMutableArray *hospitalArray;
@property (nonatomic,copy)  NSMutableArray *hospitalIdArray;
@property (nonatomic,copy)  NSMutableDictionary *dataForHospital;
@end
