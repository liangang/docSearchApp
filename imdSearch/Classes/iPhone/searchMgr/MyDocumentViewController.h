//
//  MyDocumentViewController.h
//  imdSearch
//
//  Created by xiangzhang on 3/18/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDocListViewController.h"

@interface MyDocumentViewController : UIViewController<MyDocListDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *docSegmentd;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) MyDocListViewController *recordListViewController;
@property (strong, nonatomic) MyDocListViewController *colllectionListViewController;

- (IBAction)segValueChanged:(id)sender;
@end
