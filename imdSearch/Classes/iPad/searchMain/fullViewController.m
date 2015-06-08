//
//  fullViewController.m
//  imdSearch
//
//  Created by 8fox on 11/3/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "fullViewController.h"
#import "SearchContentMainViewController.h"
#import "ReaderThumbCache.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "imdiPadDatabase.h"
#import "UrlRequest.h"
#define PAGING_VIEWS 3
#define TAP_AREA_SIZE 48.0f
#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

@implementation fullViewController

@synthesize pdfAreaView,pdfContentView;
@synthesize leftPagePad,rightPagePad;
@synthesize pageTitle,currentPdfName,viewDelegate,saveButton,titleView,currentPdfTitle;
@synthesize loadingView;
@synthesize readerInited;
@synthesize exterid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPdfAreaWayThree];
    [self loadPdfWay3:self.currentPdfName];
    
    if (![self initReader:self.currentPdfName]) {
        [self clearCaches:self.currentPdfName];
    }
    
    self.titleView.layer.cornerRadius = 2;
    self.titleView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.titleView.layer.shadowOpacity = 1.0;
    self.titleView.layer.shadowRadius = 2.0;
    self.titleView.layer.shadowOffset = CGSizeMake(0, 1);
    
    if ([document.pageCount intValue] == 0) {
        saveButton.hidden = YES;
    }else {
        saveButton.hidden = NO;
    }
    
    [self haveSaved];
    [ImdAppBehavior readingLog:[Util getUsername] MACAddr:[Util getMacAddress] title:self.currentPdfTitle currentPage:[document.pageNumber intValue] totalPage:[document.pageCount intValue]];
    
    mainPagebar.backgroundColor = NavigationColor;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.pdfAreaView =nil;
    self.pageTitle =nil;
    
    self.leftPagePad =nil;
    self.rightPagePad =nil;
    self.titleView =nil;
    
    self.pdfContentView =nil;
    self.loadingView =nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    NSLog(@"===========>>>>>>>> shouldAutorotateToInterfaceOrientation ");
	return YES;
}

- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0)
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0)
{
    return UIInterfaceOrientationMaskAll;
}

-(void)hideLoading
{
    self.loadingView.hidden =YES;
}

#pragma mark - UISCrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  self.pdfContentView;
}

#pragma mark - back action

-(IBAction)back:(id)sender
{
    
    [ImdAppBehavior readOverLog:[Util getUsername] MACAddr:[Util getMacAddress] title:self.currentPdfTitle currentPage:[document.pageNumber intValue] totalPage:[document.pageCount intValue]];
    [self popBack];
}


#pragma mark - save action

-(IBAction)saveThis:(id)sender
{
    [ImdAppBehavior saveDocLog:[Util getUsername] MACAddr:[Util getMacAddress] title:self.currentPdfTitle pageName:PAGE_FULL];
    NSLog(@"save %@",self.viewDelegate);
    //    if ([self.loadingView isHidden])
    {
        imdSearchAppDelegate_iPad *appDelegate = (imdSearchAppDelegate_iPad *)[[UIApplication sharedApplication] delegate];
        SearchContentMainViewController* vc = appDelegate.mainController;
        
        if (appDelegate && [appDelegate respondsToSelector:@selector(saveDocInfo:)])
        {
            [appDelegate performSelector:@selector(saveDocInfo:) withObject:self];
        }
        
        NSString* path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:self.currentPdfName];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.currentPdfName];
        
        NSError* error = [[NSError alloc] init];
        if (![[NSFileManager defaultManager] copyItemAtPath:path toPath:filePath error:&error])
        {
            NSLog(@"Copy from %@ to %@ error: %@", path, filePath, [error localizedFailureReason]);
        }
        NSLog(@"Copy from %@ to %@", path, filePath);
        
        [vc detailsDownFullText:nil];
        self.saveButton.enabled = false;
    }
}

-(void)haveSaved
{
    NSString* userString = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
    
    if ([imdiPadDatabase isSelectId:self.exterid userName:userString]) {
        saveButton.enabled = false;
    } else {
        saveButton.enabled = true;
    }
}

//---------------------- new pdf ----------------------------

-(void)initPdfAreaWayThree
{
    NSLog(@"%s", __FUNCTION__);
    //    [self initPdfAreaWayTwo];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    //    CGRect viewRect = self.view.bounds; // View controller's view bounds
    self.pdfAreaView.scrollsToTop = NO;
    self.pdfAreaView.pagingEnabled = YES;
    self.pdfAreaView.delaysContentTouches = NO;
    self.pdfAreaView.showsVerticalScrollIndicator = NO;
    self.pdfAreaView.showsHorizontalScrollIndicator = NO;
    self.pdfAreaView.contentMode = UIViewContentModeRedraw;
    self.pdfAreaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.pdfAreaView.backgroundColor = [UIColor clearColor];
    self.pdfAreaView.userInteractionEnabled = YES;
    self.pdfAreaView.autoresizesSubviews = NO;
    self.pdfAreaView.delegate = self;
    
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapOne.numberOfTouchesRequired = 1;
    singleTapOne.numberOfTapsRequired = 1;
    singleTapOne.delegate = self;
    
    UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapOne.numberOfTouchesRequired = 1;
    doubleTapOne.numberOfTapsRequired = 2;
    doubleTapOne.delegate = self;
    
    UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapTwo.numberOfTouchesRequired = 2;
    doubleTapTwo.numberOfTapsRequired = 2;
    doubleTapTwo.delegate = self;
    
    [singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail
    
    [self.pdfAreaView addGestureRecognizer:singleTapOne];
    [self.pdfAreaView addGestureRecognizer:doubleTapOne];
    [self.pdfAreaView addGestureRecognizer:doubleTapTwo];
    
    contentViews = [NSMutableDictionary new];
    lastHideTime = [NSDate new];
    
	assert(self.splitViewController == nil); // Not supported (sorry)
}
- (BOOL)loadPdf:(NSString *)filePath
{
  BOOL state = NO;
  
	if (filePath != nil) // Must have a file path
	{
		const char *path = [filePath fileSystemRepresentation];
    
		int fd = open(path, O_RDONLY); // Open the file
    
		if (fd > 0) // We have a valid file descriptor
		{
			const char sig[1024]; // File signature buffer
      
			ssize_t len = read(fd, (void *)&sig, sizeof(sig));
      
			state = (strnstr(sig, "%PDF", len) != NULL);
      
			close(fd); // Close the file
		}
	}
  
	return state;
}
-(BOOL)loadPdfWay3:(NSString*)pdfname
{
    NSLog(@"%s", __FUNCTION__);
    //    NSURL* fileURL = [NSURL fileURLWithPath:pdfFileName];
    BOOL ret = YES;
    NSString* path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:pdfname];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* filePath = [documentsDirectory stringByAppendingPathComponent:pdfname];
        
        NSError* error = [[NSError alloc] init];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            if (![[NSFileManager defaultManager] copyItemAtPath:filePath toPath:path error:&error])
            {
                NSLog(@"Copy from %@ to %@ error: %@", filePath, path, [error localizedFailureReason]);
            }
            NSLog(@"Copy from %@ to %@", filePath, path);
        }
    }
    NSString* pdfFileName = path;
    
    ret = [self initReader:pdfFileName];
    
    NSString* titleString = [Util replaceEM:currentPdfTitle LeftMark:@"" RightMark:@""];
    self.pageTitle.text =titleString;
    
    NSLog(@"set lastHideTime");
    lastHideTime = [NSDate new];  // lastHideTime stamp
    NSLog(@"Check in last Appear Size");
    if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false) {
        NSLog(@"Update now");
        if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false) {
            NSLog(@"go to updateScrollViewContentViews");
            [self updateScrollViewContentViews]; // Update content views
        }
        NSLog(@"set lastAppearSize as CGSizeZero");
        lastAppearSize = CGSizeZero; // Reset view size tracking
    }
    NSLog(@"show Pagebar");
    [mainPagebar showPagebar];
    
    [self performSelector:@selector(hideLoading) withObject:nil afterDelay:0.5f];
    return ret;
}

- (BOOL) initReader:(NSString*)pdfFileName
{
    NSLog(@"%s %@", __FUNCTION__, pdfFileName);
    if (self.readerInited == YES)
        return YES;
    else {
        
        ReaderDocument *pdfDoc = [ReaderDocument withDocumentFilePath:pdfFileName password:nil];
        if (pdfDoc != nil) {
            NSLog(@"[self loadDocument:pdfDoc];");
            [self loadDocument:pdfDoc];
            CGRect viewRect = self.view.bounds; // View controller's view bounds
            
            CGRect pagebarRect = viewRect;
            pagebarRect.size.height = PAGEBAR_HEIGHT;
            pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);
            NSLog(@"mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // At bottom");
            mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // At bottom
            
            mainPagebar.delegate = self;
            NSLog(@"[self.view addSubview:mainPagebar];");
            [self.view addSubview:mainPagebar];
            NSLog(@"if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time");
            if (CGSizeEqualToSize(self.pdfAreaView.contentSize, CGSizeZero)) // First time
            {
                NSLog(@"[self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];");
                [self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
            }
            NSLog(@"self.readerInited = YES;");
            self.readerInited = YES;
        } else {
            NSLog(@"Bad pdf");
            return NO;
        }
    }
    return YES;
}


#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	if (self.pdfAreaView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum
        
		if ((maxPage > minPage) && (page != minPage))
		{
			CGPoint contentOffset = self.pdfAreaView.contentOffset;
            
			contentOffset.x -= self.pdfAreaView.bounds.size.width; // -= 1
            
			[self.pdfAreaView setContentOffset:contentOffset animated:YES];
            
			self.pdfAreaView.tag = (page - 1); // Decrement page number
		}
	}
}

- (void)incrementPageNumber
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	if (self.pdfAreaView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum
        
		if ((maxPage > minPage) && (page != maxPage))
		{
			CGPoint contentOffset = self.pdfAreaView.contentOffset;
            
			contentOffset.x += self.pdfAreaView.bounds.size.width; // += 1
            
			[self.pdfAreaView setContentOffset:contentOffset animated:YES];
            
			self.pdfAreaView.tag = (page + 1); // Increment page number
		}
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // #ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), toInterfaceOrientation);
    //#endif
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft |toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        titleView.frame = CGRectMake(0, 0, 1024, 40);
        pageTitle.frame = CGRectMake(200, 0, 624, 40);
    }
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait|
        toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        titleView.frame = CGRectMake(0, 0, 768, 40);
        pageTitle.frame = CGRectMake(85, 0, 574, 40);
    }
    
	if (isVisible == NO) return; // iOS present modal bodge
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    //#ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), interfaceOrientation);
    //#endif
    
	if (isVisible == NO) return; // iOS present modal bodge
    
	[self updateScrollViewContentViews]; // Update content views
    
	lastAppearSize = CGSizeZero; // Reset view size tracking
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	__block NSInteger page = 0;
    
	CGFloat contentOffsetX = scrollView.contentOffset.x;
    
	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(id key, id object, BOOL *stop)
     {
         ReaderContentView *contentView = object;
         
         if (contentView.frame.origin.x == contentOffsetX)
         {
             page = contentView.tag; *stop = YES;
         }
     }
     ];
    
	if (page != 0) [self showDocumentPage:page]; // Show the page
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	[self showDocumentPage:self.pdfAreaView.tag]; // Show page
    
	self.pdfAreaView.tag = 0; // Clear page number tag
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;
    
	return NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
        NSLog(@"recognizer.state == UIGestureRecognizerStateRecognized");
		CGRect viewRect = recognizer.view.bounds; // View bounds
        
		CGPoint point = [recognizer locationInView:recognizer.view];
        
		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area
        
		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
            NSLog(@"Single tap is inside the area");
			NSInteger page = [document.pageNumber integerValue]; // Current page #
            
			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key
            
			ReaderContentView *targetView = [contentViews objectForKey:key];
            
			id target = [targetView processSingleTap:recognizer]; // Process tap
            
			if (target != nil) // Handle the returned target object
			{
                NSLog(@"Handle the returned target object");
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
                    NSLog(@"Open a URL");
					[[UIApplication sharedApplication] openURL:target];
				}
				else // Not a URL, so check for other possible object type
				{
                    NSLog(@"Not a URL, so check for other possible object type");
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
                        NSLog(@"Goto page");
						NSInteger value = [target integerValue]; // Number
                        
						[self showDocumentPage:value]; // Show the page
					} else {
                        NSLog(@"do nothing");
                    }
				}
			}
			else // Nothing active tapped in the target content view
			{
                NSLog(@"Nothing active tapped in the target content view");
				if ([lastHideTime timeIntervalSinceNow] < -0.5) // Delay since hide
				{
                    NSLog(@"Delay since hide");
                    //					if ((mainToolbar.hidden == YES) || (mainPagebar.hidden == YES))
                    //					{
                    //						[mainToolbar showToolbar];
                    //                        [mainPagebar showPagebar]; // Show
                    //					}
                    //					if (mainPagebar.hidden == YES)
                    if ([mainPagebar isHidden])
					{
                        NSLog(@"show page bar");
                        //[self showNavBar];
                        [mainPagebar showPagebar]; // Show
					} else {
                        NSLog(@"hide page bar");
                        [mainPagebar hidePagebar]; // hide
                        lastHideTime = [NSDate new];
                    }
                    
				}
			}
            
			return;
		}
        
		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}
        
		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;
        
		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds
        
		CGPoint point = [recognizer locationInView:recognizer.view];
        
		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE);
        
		if (CGRectContainsPoint(zoomArea, point)) // Double tap is in the zoom area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #
            
			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key
            
			ReaderContentView *targetView = [contentViews objectForKey:key];
            
			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom ++
				{
					[targetView zoomIncrement]; break;
				}
                    
				case 2: // Two finger double tap: zoom --
				{
					[targetView zoomDecrement]; break;
				}
			}
            
			return;
		}
        
		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}
        
		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;
        
		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)showDocumentPage:(NSInteger)page
{
    // #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	if (page != currentPage) // Only if different
	{
		NSInteger minValue; NSInteger maxValue;
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1;
        
		if ((page < minPage) || (page > maxPage)) return;
        
		if (maxPage <= PAGING_VIEWS) // Few pages
		{
			minValue = minPage;
			maxValue = maxPage;
		}
		else // Handle more pages
		{
			minValue = (page - 1);
			maxValue = (page + 1);
            
			if (minValue < minPage)
            {minValue++; maxValue++;}
			else
				if (maxValue > maxPage)
                {minValue--; maxValue--;}
		}
        
		NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];
        
		NSMutableDictionary *unusedViews = [contentViews mutableCopy];
        
		CGRect viewRect = CGRectZero; viewRect.size = self.pdfAreaView.bounds.size;
        
		for (NSInteger number = minValue; number <= maxValue; number++)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key
            
			ReaderContentView *contentView = [contentViews objectForKey:key];
            
			if (contentView == nil) // Create a brand new document content view
			{
				NSURL *fileURL = document.fileURL; NSString *phrase = document.password; // Document properties
                
				contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:number password:phrase];
                
				[self.pdfAreaView addSubview:contentView]; [contentViews setObject:contentView forKey:key];
                
				contentView.message = self; [newPageSet addIndex:number];
			}
			else // Reposition the existing content view
			{
				contentView.frame = viewRect; [contentView zoomReset];
                
				[unusedViews removeObjectForKey:key];
			}
            
			viewRect.origin.x += viewRect.size.width;
		}
        
		[unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
         ^(id key, id object, BOOL *stop)
         {
             [contentViews removeObjectForKey:key];
             
             ReaderContentView *contentView = object;
             
             [contentView removeFromSuperview];
         }
         ];
        
		unusedViews = nil; // Release unused views
        
		CGFloat viewWidthX1 = viewRect.size.width;
		CGFloat viewWidthX2 = (viewWidthX1 * 2.0f);
        
		CGPoint contentOffset = CGPointZero;
        
		if (maxPage >= PAGING_VIEWS)
		{
			if (page == maxPage)
				contentOffset.x = viewWidthX2;
			else
				if (page != minPage)
					contentOffset.x = viewWidthX1;
		}
		else
			if (page == (PAGING_VIEWS - 1))
				contentOffset.x = viewWidthX1;
        
		if (CGPointEqualToPoint(self.pdfAreaView.contentOffset, contentOffset) == false)
		{
			self.pdfAreaView.contentOffset = contentOffset; // Update content offset
		}
        
		if ([document.pageNumber integerValue] != page) // Only if different
		{
			document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
		}
        
		NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid;
        
		if ([newPageSet containsIndex:page] == YES) // Preview visible page first
		{
			NSNumber *key = [NSNumber numberWithInteger:page]; // # key
            
			ReaderContentView *targetView = [contentViews objectForKey:key];
            
			[targetView showPageThumb:fileURL page:page password:phrase guid:guid];
            
			[newPageSet removeIndex:page]; // Remove visible page from set
		}
        
		[newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
         ^(NSUInteger number, BOOL *stop)
         {
             NSNumber *key = [NSNumber numberWithInteger:number]; // # key
             
             ReaderContentView *targetView = [contentViews objectForKey:key];
             
             [targetView showPageThumb:fileURL page:number password:phrase guid:guid];
         }
         ];
        
		newPageSet = nil; // Release new page set
        
		[mainPagebar updatePagebar]; // Update the pagebar display
        
		[self updateToolbarBookmarkIcon]; // Update bookmark
        
		currentPage = page; // Track current page number
	}
}

#pragma mark Support methods

- (void)updateScrollViewContentSize
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	NSInteger count = [document.pageCount integerValue];
    
	if (count > PAGING_VIEWS) count = PAGING_VIEWS; // Limit
    
	CGFloat contentHeight = self.pdfAreaView.bounds.size.height;
    
	CGFloat contentWidth = (self.pdfAreaView.bounds.size.width * count);
    
	self.pdfAreaView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	[self updateScrollViewContentSize]; // Update the content size
    
	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set
    
	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(id key, id object, BOOL *stop)
     {
         ReaderContentView *contentView = object; [pageSet addIndex:contentView.tag];
     }
     ];
    
	__block CGRect viewRect = CGRectZero; viewRect.size = self.pdfAreaView.bounds.size;
    
	__block CGPoint contentOffset = CGPointZero; NSInteger page = [document.pageNumber integerValue];
    
	[pageSet enumerateIndexesUsingBlock: // Enumerate page number set
     ^(NSUInteger number, BOOL *stop)
     {
         NSNumber *key = [NSNumber numberWithInteger:number]; // # key
         
         ReaderContentView *contentView = [contentViews objectForKey:key];
         
         contentView.frame = viewRect; if (page == number) contentOffset = viewRect.origin;
         
         viewRect.origin.x += viewRect.size.width; // Next view frame position
     }
     ];
    
	if (CGPointEqualToPoint(self.pdfAreaView.contentOffset, contentOffset) == false)
	{
		self.pdfAreaView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)loadDocument:(ReaderDocument *)object
{
    NSLog(@"%s", __FUNCTION__);
	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];
        
        [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];
        
        [object updateProperties];
        document = object; // Retain the supplied ReaderDocument object for our use
        
        [ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
	}
}

- (void)showDocument:(id)object
{
    // #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	[self updateScrollViewContentSize]; // Set content size
    NSLog(@"[self showDocumentPage:[document.pageNumber integerValue]];");
	[self showDocumentPage:[document.pageNumber integerValue]]; // Show
    NSLog(@"document.lastOpen = [NSDate date];");
	document.lastOpen = [NSDate date]; // Update last opened date
    NSLog(@"isVisible = YES;");
	isVisible = YES; // iOS present modal bodge
    NSLog(@"showDocument END");
}

#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    [ImdAppBehavior readingLog:[Util getUsername] MACAddr:[Util getMacAddress] title:self.currentPdfTitle currentPage:page totalPage:[document.pageCount intValue]];
	[self showDocumentPage:page]; // Show the page
}

- (void)updateToolbarBookmarkIcon
{
    // #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	NSInteger page = [document.pageNumber integerValue];
    
	BOOL bookmarked = [document.bookmarks containsIndex:page];
    
	[mainToolbar setBookmarkState:bookmarked]; // Update
}

#pragma mark ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
	if ((mainToolbar.hidden == NO) || (mainPagebar.hidden == NO))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info
			CGPoint point = [touch locationInView:self.view]; // Touch location
			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);
            
			if (CGRectContainsPoint(areaRect, point) == false) return;
		}
        
		//[mainToolbar hideToolbar];
        if (![mainPagebar isHidden]) {
            [mainPagebar hidePagebar]; // Hide
            lastHideTime = [NSDate new];
        }
	}
}

-(void)segmentAction:(id) sender
{
    NSLog(@"%s", __FUNCTION__);
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

#pragma mark ReaderMainToolbarDelegate methods

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
#ifdef DEBUG
    if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ThumbsViewControllerDelegate methods
- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	[self updateToolbarBookmarkIcon]; // Update bookmark icon
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
    //#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    //#endif
    
	[self showDocumentPage:page]; // Show the page
}

- (void)applicationWill:(NSNotification *)notification
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[document saveReaderDocument]; // Save any ReaderDocument object changes
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

//From PDFViewInfo
-(void) popBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) saveLocal:(id) sender
{
}

-(void) clearCaches:(NSString *)exid
{
    NSError *error = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if ([self findCache:nil]) {
        NSString* filePaths = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:self.currentPdfName];
        BOOL success = [fm removeItemAtPath:filePaths error:&error];
        if (!success || error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        NSLog(@"remove support file : %@", filePaths);
    }
}

-(BOOL)findCache:(NSString *)externelId
{
    NSString* fileP = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:self.currentPdfName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileP]) {
        return YES;
    }
    return NO;
}
@end
