//
//  lanSelectViewController.h
//  imdSearch
//
//  Created by 8fox on 10/21/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface lanSelectViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
}

@property (nonatomic,retain) id delegate;
@property (readwrite) int selectedItem;
@end
