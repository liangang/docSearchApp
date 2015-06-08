//
//  EnterYearViewController.h
//  imdSearch
//
//  Created by ding zhihong on 12-4-16.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterStudentsViewController.h"

@interface EnterYearViewController : UIViewController<UITableViewDelegate>
{
    NSMutableArray* yearData;
    id delegate;
}

@property (nonatomic,retain) id delegate;

@end
