//
//  settingViewController.h
//  imdSearch
//
//  Created by 8fox on 10/21/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"
#import "SearchContentMainViewController.h"

#import "EnumType.h"

@protocol SearchContentShowDelegate;

@interface settingViewController : UIViewController <UITableViewDelegate,UITableViewDelegate,UIAlertViewDelegate>
{
  IBOutlet UIButton* closeButton;
  id delegate;
  UITableView* settingList; 
  IBOutlet UITableView* settingTableList;
  NSString* lastVersion;
  NSString* locationVersion;
  NSString* trackViewUrl;
  ASIHTTPRequest *httprequest;
  BOOL openNotification;
  UISwitch *switchView;
  UISwitch* netSwitch;
}

-(IBAction)closeIt:(id)sender;
-(void)login:(id)sender;
-(void)logout:(id)sender;
-(void)downOptionChanged:(id)sender;
-(void)toDetail:(int)tag;
-(void)logoutWarning;
- (void)logoutAccount;

@property (nonatomic,retain) IBOutlet UIButton* closeButton;
@property (nonatomic, assign) id<SearchContentShowDelegate>   mainDelegate;
@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) UITableView* settingList;
@property (nonatomic,retain) UITableView* settingTableList;
@property (nonatomic,retain) NSString* lastVersion;
@property (nonatomic,retain) NSString* locationVersion;
@property (nonatomic,retain) NSString* trackViewUrl;
@property (nonatomic,retain) ASIHTTPRequest *httprequest;
@property (nonatomic,assign) BOOL openNotification;
@end
