//
//  RealNameViewController.h
//  imdSearch
//
//  Created by  侯建政 on 11/30/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RealNameViewController : UIViewController
@property (nonatomic,copy) NSString* titleText;
@property (nonatomic,retain) UITextField *studentNumber;
@property (nonatomic,retain) UIButton *studentMessage;
@property (nonatomic,retain) UILabel *studentMail;
@property (nonatomic,retain) IBOutlet UITableView *myTable;
@property (nonatomic,copy) NSString *number;
@end
