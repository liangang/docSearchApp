//
//  shareSelectViewController.h
//  imdSearch
//
//  Created by 8fox on 10/26/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface shareSelectViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
}

@property (nonatomic,retain) id delegate;
@property (readwrite) int selectedItem;


@end
