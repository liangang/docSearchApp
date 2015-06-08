//
//  sortInfoSelectViewController.h
//  imdSearch
//
//  Created by xiangzhang on 5/24/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyDocumentPadViewController.h"

/**
 *  pop出信息的页面选择，根据给定的datatarray的信息来显示信息，选中后根据delegate来进行后续处理
 *
 */
@interface sortInfoSelectViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) id<sortSelectDelegate> delegate;

@property (assign, nonatomic) NSInteger selectedItem;
@end
