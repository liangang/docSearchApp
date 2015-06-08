//
//  fullViewController.h
//  imdSearch
//
//  Created by 8fox on 11/3/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PDFViewTiled.h"
//#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "imdSearchAppDelegate_iPad.h"

#import <MessageUI/MessageUI.h>
#import "ReaderDocument.h"
#import "ReaderContentView.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ThumbsViewController.h"

@class ReaderMainToolbar;

@interface fullViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate,
ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate, ThumbsViewControllerDelegate>
{
    //  id delegate;
    IBOutlet  UIScrollView* pdfAreaView;
    UIView* pdfContentView;
    
    //    PDFViewTiled* pdfView;
    //    PDFViewTiled* prePdfView;
    //    PDFViewTiled* nextPdfView;
    
    int pdfValue;
    
    
    IBOutlet UILabel* pageTitle;
    
    
    float pdfWidth;
    float pdfHeight;
    
    
    IBOutlet UIView* leftPagePad;
    IBOutlet UIView* rightPagePad;
    
    
    NSString* currentPdfName;
    NSString* currentPdfTitle;
    NSString* exterid;
    BOOL pageBarHidden;
    
    id viewDelegate;
    
    IBOutlet UIButton* saveButton;
    IBOutlet UIView* titleView;
    
    IBOutlet UIView* loadingView;
    
    
    //--------
    ReaderDocument *document;
    NSMutableDictionary *contentViews;
    NSDate *lastHideTime;
    ReaderMainToolbar *mainToolbar;
	ReaderMainPagebar *mainPagebar;
    
    UIPrintInteractionController *printInteraction;
    
    NSInteger currentPage;
    CGSize lastAppearSize;
    
    BOOL isVisible;
    
@public
    BOOL readerInited;
    
}


@property (nonatomic,retain) UIScrollView* pdfAreaView;
//@property (nonatomic,retain) PDFViewTiled* pdfView;
//@property (nonatomic,retain) PDFViewTiled* prePdfView;
//@property (nonatomic,retain) PDFViewTiled* nextPdfView;
//@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) UIView* pdfContentView;
@property (nonatomic,retain) IBOutlet UILabel* pageTitle;
@property (nonatomic,retain) IBOutlet UIView* leftPagePad;
@property (nonatomic,retain) IBOutlet UIView* rightPagePad;
@property (nonatomic,retain) NSString* currentPdfName;
@property (nonatomic,retain) NSString* currentPdfTitle;
@property (nonatomic,retain) NSString* exterid;
@property (nonatomic,retain) id viewDelegate;
@property (nonatomic,retain) IBOutlet UIButton* saveButton;
@property (nonatomic,retain) IBOutlet UIView* titleView;
@property (nonatomic,retain) IBOutlet UIView* loadingView;
@property (nonatomic, assign) BOOL readerInited;

-(void)initPdfArea;
-(BOOL)loadPdf:(NSString*)filePath;

-(void)initPdfAreaWayTwo;
-(BOOL)loadPdfWay2:(NSString*)pdfname;

-(void)initPdfAreaWayThree;
-(BOOL)loadPdfWay3:(NSString*)pdfname;

-(IBAction)back:(id)sender;
//-(IBAction)nextPage:(id)sender;
-(IBAction)prePage:(id)sender;
-(IBAction)saveThis:(id)sender;
-(void)hideLoading;
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
- (BOOL) initReader:(NSString*)pdfFileName;

- (void)pdfHandleAllSwipes:(UISwipeGestureRecognizer *)recognizer;
- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer;

- (void)nextPage:(UISwipeGestureRecognizerDirection) direct;
- (void)prevPage:(UISwipeGestureRecognizerDirection) direct;
@end
