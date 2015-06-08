//
//  InviteRegisterPadViewController.h
//  imdSearch
//
//  Created by xiangzhang on 1/3/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteRegisterPadViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *infoTableView;

- (IBAction)dismissView:(id)sender;
- (IBAction)inviteFriendClick:(id)sender;
@end
