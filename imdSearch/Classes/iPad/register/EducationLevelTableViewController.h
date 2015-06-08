//
//  EducationLevelTableViewController.h
//  imdSearch
//
//  Created by ding zhihong on 12-4-18.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EducationLevelTableViewController : UIViewController<UITableViewDelegate>
{
    NSMutableArray* levelData;
    id delegate;
}

@property (nonatomic,retain) id delegate;

@end
