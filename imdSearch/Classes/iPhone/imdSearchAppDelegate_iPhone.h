//
//  imdSearchAppDelegate_iPhone.h
//  imdSearch
//
//  Created by 8fox on 9/9/11.
//  Copyright 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imdSearchAppDelegate.h"
#import "IPhoneMainSearch.h"
#import "IPhoneSettingsController.h"
#import "IPhoneMySearchController.h"
#import "IPhoneSearchMgr.h"
#import "UserAuth.h"
#import "LoginActiveController.h"
#import "IPhoneHelper.h"
#import "GuidIndexViewController.h"
#import "PDFReaderController.h"
#import "MyDocumentViewController.h"

#import "WXApi.h"
#import "WeiboApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#define IMD_DEBUG

@interface imdSearchAppDelegate_iPhone : imdSearchAppDelegate <UITabBarControllerDelegate,UIApplicationDelegate>
{
  PDFReaderController *pdfView;
  BOOL downloadOnWiFiOnly;
  BOOL firstLogined;
  UIAlertView *alert;
}

@property (nonatomic,retain) UITabBarController* myTabBarController;

@property (nonatomic,retain) IPhoneHelper *helper;      //引导页面
@property (nonatomic, strong) GuidIndexViewController *indexViewController;
@property (nonatomic,retain) IPhoneMainSearch *mainSearch;
@property (nonatomic,retain) IPhoneMySearchController *mySearch;
@property (nonatomic,retain) IPhoneSearchMgr *searchMgr;
@property (nonatomic,retain) MyDocumentViewController *myViewController;

@property (nonatomic,retain) LoginController *loginController;
@property (nonatomic,retain) LoginActiveController *accountActive;
@property (nonatomic,retain) UINavigationController *loginNav;
@property (nonatomic,retain) UINavigationController *accountActiveNav;
@property (nonatomic,retain) UIAlertView *alertView;
@property (nonatomic,retain) IPhoneSettingsController *settings;

@property (nonatomic,retain) IBOutlet UIView *rootView;
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) IBOutlet UIImageView *SearchimageView;
@property (nonatomic,retain) IBOutlet UIImageView *FullTextimageView;
@property (nonatomic,retain) IBOutlet UINavigationBar *backNavigationBar;
@property (nonatomic,retain) IBOutlet UINavigationItem *backPdf;
@property (nonatomic,assign) BOOL isCreated;

@property (nonatomic,retain) UserAuth *myAuth;
@property (nonatomic, retain) ASIHTTPRequest *httpRequest;
@property (nonatomic,copy) NSString *responseString;
@property (nonatomic,retain) UIAlertView *alertView1;
@property (nonatomic,copy) NSString *appStoreVersion;
@property (nonatomic,retain) id delegate;

@property (nonatomic,retain) NSString *urlApp;
-(void) showLoginView:controller title:(NSString*) title;
-(void) showAccoutActiveView:(UIViewController*)controller title:(NSString*) title emailActive:(BOOL)emailActive mobileActive:(BOOL)mobileActive fromRegister:(BOOL)fromRegister;

-(void) logout;
-(void) versionChecked:(NSString*)latest forceUpdate:(BOOL)forceUpdate;

-(void) showHelp;
-(void) backToPdf;
-(void) requestTokenFailed;
@end
