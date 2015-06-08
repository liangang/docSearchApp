//
//  PDFViewOrInfo.h
//  imdSearch
//
//  Created by Huajie Wu on 11-12-3.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "PDFViewTiled.h"
#import "ASIHTTPRequest.h"
#import "ReaderViewController.h"

@interface PDFViewOrInfo : UIViewController <ReaderViewControllerDelegate,ASIHTTPRequestDelegate, UIAlertViewDelegate>
{
  NSString* filePath;     //Save to local catogary.
  NSString* tmpFilePath;  //Tmp file for download from network.
  NSMutableDictionary* localInfo;
  PDFViewTiled* thePDFView;
  IBOutlet UIScrollView* scrollView;
  
  UIAlertView* alertView;
  UIAlertView* maxAlertView;
  ASIHTTPRequest* _httpRequest;

@private // Instance variables
}

@property (nonatomic, retain) ASIHTTPRequest* httpRequest;

@property (nonatomic, retain) NSString* filePath;
@property (nonatomic, retain) NSString* tmpFilePath;
@property (nonatomic, retain) NSMutableDictionary* localInfo;
@property (nonatomic, retain) PDFViewTiled* thePDFView;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) UIAlertView* alertView;
@property (nonatomic, retain) UIAlertView* maxAlertView;

-(BOOL)loadPDF:(NSString*)pdfFileName;
-(BOOL)findInCache:(NSString*)externelId;
-(BOOL)findInLocal:(NSString*)externelId;
-(void)segmentAction:(id) sender;


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

- (void)createPdf:(NSString*)pdfFile;

@end
