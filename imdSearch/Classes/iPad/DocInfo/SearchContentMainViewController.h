//
//  SearchContentMainViewController.h
//  imdSearch
//
//  Created by xiangzhang on 4/15/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EnumType.h"

#import "settingViewController.h"
#import "loginViewController.h"



@protocol SearchContentShowDelegate <NSObject>
- (void)copyDocDetailInfo:(NSDictionary *)dic;
- (void)settingViewShowInMainWithType:(SettingItems)item;
- (void)backToMainView;

- (void)showDocDetailInfo:(NSDictionary *)dic;
- (void)showDocDetailWithExternalId:(NSString *)eId;
- (void)removeDocDetailInfo;

- (void)showDocDetailInfoFromDocument:(NSDictionary *)dic listType:(ListType )type isRecod:(NSString *)isrecord;

- (void)showDocDetailWithExternalIdFromDocument:(NSString *)eId listType:(ListType )type isRecod:(NSString *)isrecord;

- (void)showPDFWithexternalId:(NSString *)eId fileName:(NSString *)fileName pdfTitle:(NSString *)fileTitle;
- (void)presentViewWithType:(PresentType)type;
- (void)showMyDocumentWithListType:(ListType)type;
@end

@interface SearchContentMainViewController : UIViewController<SearchContentShowDelegate>

@property (strong, nonatomic) loginViewController *loginViewController;

@property (strong, nonatomic) IBOutlet UIView *menuActionView;
@property (strong, nonatomic) IBOutlet UIImageView *menuBackgroundImg;
@property (strong, nonatomic) IBOutlet UIButton *searchBtn;
@property (strong, nonatomic) IBOutlet UIButton *myDocMenuBtn;
@property (strong, nonatomic) IBOutlet UIButton *settingBtn;
@property (strong, nonatomic) IBOutlet UIButton *helpInfoBtn;

@property (strong, nonatomic) IBOutlet UIView *mainCoverView;

@property (strong, nonatomic) IBOutlet UIScrollView *slideInfoView;
@property (strong, nonatomic) IBOutlet UIScrollView *contentInfoView;


- (IBAction)searchBtnClick:(id)sender;
- (IBAction)myDocMenuBtnClick:(id)sender;
- (IBAction)settingBtnClick:(id)sender;
- (IBAction)helpInfoBtnClick:(id)sender;

-(IBAction)detailsDownFullText:(id)sender;

#pragma mark - appdelegate method

- (IBAction)presentLoginViewController:(id)sender;
-(void)presentForgetPassWindow:(id)sender;
- (void)startReady ;

- (void)registerNew:(id)sender __attribute__((deprecated("no user in current ")));

- (void)checkNewAskfor __attribute__((deprecated("no user in current ")));

- (void)loginNew:(id)sender __attribute__((deprecated("no user in current ")));
@end
