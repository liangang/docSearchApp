//
//  InviteRegisterViewController.h
//  imdSearch
//
//  Created by xiangzhang on 12/30/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteRegisterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)inviteReigisterBtn:(id)sender;
@end
