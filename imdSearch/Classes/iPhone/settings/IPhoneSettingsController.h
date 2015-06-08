//
//  IPhoneSettingsController.h
//  imdSearch
//
//  Created by Huajie Wu on 11-12-2.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "EnumType.h"

@interface IPhoneSettingsController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate, ASIHTTPRequestDelegate>
{
    UIActionSheet* exitOut;
}

@property (nonatomic, assign) BOOL downloadOnWiFiOnly;
@property (nonatomic, assign) BOOL openNotification;
@property (nonatomic, assign) BOOL isLatest;
@property (nonatomic, assign) BOOL isLogin;

@property (nonatomic, retain) NSString* latestVersion;
@property (nonatomic, retain) UIAlertView* cacheAlertView;
@property (nonatomic, strong) NSMutableArray *dataArr;

- (void) switchChanged:(id)sender;
- (void) logout:(id)sender;
- (void) updateAccountCell:(UITableViewCell*) cell;
- (void) UIActionSheetResponder;
- (void) exitLoginUser;
- (IBAction)loginAccount:(id)sender;
@end
