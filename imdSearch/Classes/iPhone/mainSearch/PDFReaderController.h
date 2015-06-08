//
//  PDFReaderController.h
//  imdSearch
//
//  Created by Huajie Wu on 12-2-23.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ReaderDocument.h"
#import "ReaderContentView.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ThumbsViewController.h"

#import "ASIHTTPRequest.h"

@class PDFReaderController;
@class ReaderMainToolbar;

@protocol PDFReaderControllerDelegate <NSObject>

@optional // Delegate protocols

- (void)dismissPDFReaderController:(PDFReaderController *)viewController;

@end

@interface PDFReaderController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate,
    ReaderMainToolbarDelegate, 
    ReaderMainPagebarDelegate, 
    ReaderContentViewDelegate,
    ThumbsViewControllerDelegate,
    ASIHTTPRequestDelegate>
{
@private // Instance variables
    
	ReaderDocument *document;
	UIScrollView *theScrollView;
	ReaderMainToolbar *mainToolbar;
	ReaderMainPagebar *mainPagebar;
	NSMutableDictionary *contentViews;
	UIPrintInteractionController *printInteraction;
	NSInteger currentPage;
	CGSize lastAppearSize;
	NSDate *lastHideTime;
	BOOL isVisible;
    
@public //PDFViewOrInfo.
    BOOL readerInited;

    NSString* filePath;     //Save to local catogary.
    NSString* tmpFilePath;  //Tmp file for download from network.
    NSMutableDictionary* localInfo;
    IBOutlet UIScrollView* scrollView;
    
    UIAlertView* alertView;
    
    ASIHTTPRequest* _httpRequest;
    
    UIImageView* titleImgView;
    UIButton *button;
    BOOL isChangeButton;
    UIButton* saveToLocal;
    UIButton* backButton;
    NSString* currentId;
    int totalPage;
    BOOL isHidden;
    BOOL checkPhoneOrEmail;
    id delegated;
}

@property (nonatomic, assign, readwrite) id <PDFReaderControllerDelegate> delegate;

- (id)initWithReaderDocument:(ReaderDocument *)object;

- (void)loadDocument:(ReaderDocument *)object;


//PDFViewOrInfo
@property (nonatomic, assign) BOOL emailActive;
@property (nonatomic, assign) BOOL mobileActive;

@property (nonatomic, retain) ASIHTTPRequest* httpRequest;

@property (nonatomic, retain) NSString* filePath;
@property (nonatomic, retain) NSString* tmpFilePath;
@property (nonatomic, retain) NSMutableDictionary* localInfo;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) UIAlertView* alertView;

@property (nonatomic, assign) BOOL readerInited;
@property (nonatomic, retain) UIImageView* titleImgView;
@property (nonatomic, assign) BOOL isChangeButton;
@property (nonatomic, copy) NSString* currentId;
@property (nonatomic, retain) id delegated;
@property (nonatomic, retain) UIButton* saveToLocal;
-(BOOL)loadPDF:(NSString*)pdfFileName;
-(BOOL)findInCache:(NSString*)externelId;
-(BOOL)findInLocal:(NSString*)externelId;
-(void)segmentAction:(id) sender;
-(void)changeButtonOrientation;

- (void)pdfHandleAllSwipes:(UISwipeGestureRecognizer *)recognizer;
- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer;

- (void)nextPage:(UISwipeGestureRecognizerDirection) direct;
- (void)prevPage:(UISwipeGestureRecognizerDirection) direct;

-(void) popBack;
-(void) saveLocal:(id) sender;
-(BOOL) isSavedLocal;

-(void) setRightBarButtons:(BOOL)isOffLine;

-(void) hideNavBar;
-(void) showNavBar;

- (BOOL) initReader:(NSString*)pdfFileName;

- (void) createTitleBar;
- (void) goForAnimation:(NSTimeInterval)duration animationDelay:(NSTimeInterval)delay
          animationView:(UIView *)view alpha:(float)a;
-(void) clearCaches:(NSString *)exid;
@end
