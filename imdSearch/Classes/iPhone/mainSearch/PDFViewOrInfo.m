//
//  PDFViewOrInfo.m
//  imdSearch
//
//  Created by Huajie Wu on 11-12-3.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "PDFViewOrInfo.h"
#import "ASIHTTPRequest.h"
#import "Strings.h"
#import <QuartzCore/QuartzCore.h>
#import "IPhoneHeader.h"
#import "InviteRegisterViewController.h"

#define ZOOM_STEP 1.5
#define MAXVALUUETAG 2014011301

@interface PDFViewOrInfo (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation PDFViewOrInfo
@synthesize filePath, thePDFView, localInfo, tmpFilePath;
@synthesize scrollView;
@synthesize alertView;
@synthesize maxAlertView;
@synthesize httpRequest = _httpRequest;

#define ZOOM_AMOUNT 0.25f
#define NO_ZOOM_SCALE 1.0f
#define MINIMUM_ZOOM_SCALE 1.0f
#define MAXIMUM_ZOOM_SCALE 5.0f

#define NAV_AREA_SIZE 48.0f


-(void) dealloc
{
  if (_httpRequest != nil) {
    [_httpRequest clearDelegatesAndCancel];
  } 
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    localInfo = [[NSMutableDictionary alloc] init];
    
    alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
    maxAlertView = [[UIAlertView alloc] initWithTitle:REQUEST_DOC message:REQUEST_DOC_MAXVALUE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:REQUEST_FAILED_CANCEL,nil];
    maxAlertView.delegate = self;
      
    thePDFView = [[PDFViewTiled alloc] initWithFrame:CGRectMake(0, 0, 320, 450)];
    thePDFView.autoresizingMask = UIViewAutoresizingNone;
    [TableViewFormatUtil setContentBackGround:self.view image:IMG_BG_CONTENTSBACKGROUDN];
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(BOOL) isSavedLocal
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray* downloadList = [NSMutableArray arrayWithArray:[defaults arrayForKey:FULLTEXT_DOWNLOAD_LIST]];
  BOOL ret = NO;
  for (NSDictionary* item in downloadList) {
    NSString* externalId = [[item objectForKey:LOCAL_RESULT] objectForKey:DOC_EXTERNALID];
    NSString* currentId = [[self.localInfo objectForKey:LOCAL_RESULT] objectForKey:DOC_EXTERNALID];
    
    if ([currentId isEqualToString:externalId]) {
      ret = YES;
      break;
    }
  }
  return ret;
}

-(void) saveLocal:(id) sender
{
  NSError* error = nil;
  if (![[NSFileManager defaultManager] copyItemAtPath:self.tmpFilePath toPath:self.filePath error:&error])
    NSLog(@"Copy from %@ to %@ error: %@", self.tmpFilePath, self.filePath, [error localizedFailureReason]);
  NSLog(@"Copy from %@ to %@.", self.tmpFilePath, self.filePath);
  
  [self.localInfo setObject:[self filePath] forKey:LOCAL_PDF_PATH];
  
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSArray* array = [defaults arrayForKey:FULLTEXT_DOWNLOAD_LIST];
  NSMutableArray* mutableArray = [NSMutableArray arrayWithArray:array];
  [mutableArray addObject:self.localInfo];
  [defaults setObject:mutableArray forKey:FULLTEXT_DOWNLOAD_LIST];
  [defaults synchronize];
  
  [[TKAlertCenter defaultCenter] postAlertWithMessage:LOAD_SAVE_SUCCESS];
  
  [self setRightBarButtons:NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //Add Gesture.
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	//singleTap.numberOfTouchesRequired = 1; singleTap.numberOfTapsRequired = 1; //singleTap.delegate = self;
	[self.view addGestureRecognizer:singleTap];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark request
-(void)requestFailed:(ASIHTTPRequest *)request
{
  [self.alertView setTitle:REQUEST_FAILED_TITLE];
  [self.alertView setMessage:REQUEST_FAILED_MESSAGE];
  NSLog(@"request failed %@",[request responseString]);
  NSLog(@"error %@", [request error]);
  
  [self.alertView show];
  [self popBack];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self.alertView setTitle:REQUEST_DOC];
    self.view.hidden = NO;
    NSString* s =[request responseString];
    if (s != nil) {
        //self.PDFErrorLabel.hidden = NO;
        NSLog(@"s= %@",s);
        if ([s isEqualToString:@"FAIL"]) {
            UIAlertView *alertD = [[UIAlertView alloc]initWithTitle:DOWNLOAD_DOC message:DOWNLOAD_DOC_FAILEDS delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"睿医帮助",nil];
            alertD.tag = 8;
            [alertD show];
        } else if ([s isEqualToString:@"QUEUE"]) {
            [self.alertView setMessage:DOWNLOAD_DOC_QUEUE];
            [alertView show];
        } else if ([s isEqualToString:@"MAXVALUE"]) {
            NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
            [userInfo setObject:REQUEST_TYPE_USER forKey:REQUEST_TYPE];
            
            if (self.httpRequest != nil)
                [self.httpRequest clearDelegatesAndCancel];
            self.httpRequest = [UrlRequest sendWithTokenWithUserInfo:[ImdUrlPath userActiveUrl] userInfo:userInfo delegate:self];
        }
    } else {
        NSLog(@"loading pdf: %@", self.tmpFilePath);
        
        if(![self loadPDF:self.tmpFilePath]) {
            NSString* response =[NSString stringWithContentsOfFile:self.tmpFilePath encoding:NSUTF8StringEncoding error:NULL];
            
            NSLog(@"response %@",response);
            if ([response isEqualToString:@"FAIL"])
            {
                UIAlertView *alertD = [[UIAlertView alloc]initWithTitle:DOWNLOAD_DOC message:DOWNLOAD_DOC_FAILEDS delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"睿医帮助",nil];
                alertD.tag = 8;
                [alertD show];
            }else if ([response isEqualToString:@"QUEUE"]){
                [self.alertView setMessage:DOWNLOAD_DOC_QUEUE];
            }else if ([response isEqualToString:@"MAXVALUE"]){
                UIAlertView *maxValueAlertView = [[UIAlertView alloc] initWithTitle:DOWLOAD_UPPERNUM message:DOWNLOAD_DOC_MAXVALUE delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"邀请", nil];
                maxValueAlertView.tag = MAXVALUUETAG;
                [maxValueAlertView show];
            } else {
                UIAlertView *alertD = [[UIAlertView alloc]initWithTitle:DOWNLOAD_DOC message:DOWNLOAD_DOC_FAILEDS delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"睿医帮助",nil];
                alertD.tag = 8;
                [alertD show];
            }
            [self.alertView show];
            NSError *error;
            
            if(![[NSFileManager defaultManager] removeItemAtPath:[self tmpFilePath] error:&error]) {
                //TODO: Handle/Log error
                NSLog(@"del failed %@",error);
            }
            return;
        } else {
            /** 
             * Save PDF download info to download manage.
             */
            [self setRightBarButtons:NO];
        }
    }
}

-(BOOL)findInLocal:(NSString*)externelId
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* array = [defaults arrayForKey:FULLTEXT_DOWNLOAD_LIST];
    
    int i = 0;
    for (i = 0; i < [array count]; ++i) {
        NSString* cachedID = [[[array objectAtIndex:i] objectForKey:LOCAL_RESULT] objectForKey:DOC_EXTERNALID];
        if([cachedID isEqualToString:externelId]) {
            self.filePath = [[array objectAtIndex:i] objectForKey:LOCAL_PDF_PATH];
            self.tmpFilePath = self.filePath;
            NSLog(@"This has been found in cache: %@", self.filePath);
            break;
        }
    }
    if (i == [array count]) {
        return NO;
    } else {
        return YES;
    }
}

-(BOOL)findInCache:(NSString*)externelId
{
    NSString* fileP = [UrlRequest getDownloadFilePath:externelId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileP]) {
        self.filePath = fileP;
        self.tmpFilePath = self.filePath;
        return YES;
    }
    return [self findInLocal:externelId];
}

-(void)segmentAction:(id) sender
{
    switch([sender selectedSegmentIndex]) {
        case 0:
            [self prevPage:UISwipeGestureRecognizerDirectionRight];
            break;
        case 1: 
            [self nextPage:UISwipeGestureRecognizerDirectionLeft]; 
            break;
        default: 
            break;
    }
}

-(void) setRightBarButtons:(BOOL)isOffLine
{
    UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:IMG_PRE_ARTICLE_NORMAL], [UIImage imageNamed:IMG_NEXT_ARTICLE_NORMAL], nil]];

    segmentedControl.tintColor = [UIColor clearColor];
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 70, 35);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segmentedControl.tintColor = [UIColor clearColor];
    segmentedControl.momentary = YES;
    
    if (isOffLine) {
        //self.navigationItem.rightBarButtonItem = segmentBarItem;
        ;
    } else if (![self isSavedLocal]) {
        UIBarButtonItem* saveToLocal =  [[UIBarButtonItem alloc] initWithTitle:LOAD_SAVE_LOCAL style:UIBarButtonItemStylePlain target:self action:@selector(saveLocal:)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:saveToLocal, nil];
        
    } else {
        UIBarButtonItem* savedLocal = [[UIBarButtonItem alloc] initWithTitle:LOAD_LOCAL_SAVED style:UIBarButtonItemStylePlain target:self action:nil];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:savedLocal, nil];
    }
}



-(BOOL)loadPDF:(NSString*)pdfFileName
{
//    NSURL* fileURL = [NSURL fileURLWithPath:pdfFileName];
    @try {
        [self createPdf:pdfFileName];
//        [self.thePDFView changeFileURL:fileURL page:0 password:nil];
//        self.navigationItem.title = [NSString stringWithFormat:@"%d / %d", self.thePDFView.currentPage, self.thePDFView.pageCount];
    } @catch(NSException* ex) { 
        NSLog(@"Bad pdf");
        return NO;
    }
    
//    self.thePDFView.hidden = NO;
//    [self.scrollView addSubview:thePDFView];
//    [self.scrollView setZoomScale:1.0f animated:NO];
//    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, thePDFView.frame.size.height)];

    return YES;
}
- (void)createPdf:(NSString*)pdfFile
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:pdfFile password:phrase];
    
	if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
	{
		ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
        
		[self.navigationController pushViewController:readerViewController animated:YES];
        
#else // present in a modal view controller
        
		readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:readerViewController animated:YES completion:nil];
        
#endif // DEMO_VIEW_CONTROLLER_PUSH
	}
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
    
	[self.navigationController popViewControllerAnimated:YES];
    
#else // dismiss the modal view controller
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
#endif // DEMO_VIEW_CONTROLLER_PUSH
}

#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)myAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (myAlertView.tag == 8 && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_IMD_HELP]];
    }else if(myAlertView.tag == MAXVALUUETAG && buttonIndex == 1){
        InviteRegisterViewController *viewController = [[InviteRegisterViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


@end
