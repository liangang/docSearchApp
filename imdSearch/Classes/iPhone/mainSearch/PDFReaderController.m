#import "ReaderConstants.h"
#import "PDFReaderController.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
#import "IPhoneHeader.h"
#import "imdSearchAppDelegate_iPhone.h"
#import "MyDataBaseSql.h"
#import "MyDatabase.h"
#import "Util.h"
#import "ImdAppBehavior.h"
#import "DocArticleController.h"
#import "InviteRegisterViewController.h"

@implementation PDFReaderController

#pragma mark Constants

#define PAGING_VIEWS 3

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark Properties

@synthesize delegate;

@synthesize filePath, localInfo, tmpFilePath;
@synthesize scrollView;
@synthesize alertView;
@synthesize httpRequest = _httpRequest;
@synthesize readerInited;
@synthesize emailActive, mobileActive;
@synthesize titleImgView;
@synthesize isChangeButton;
@synthesize currentId;
@synthesize delegated;
@synthesize saveToLocal;
#pragma mark Support methods

- (void)updateScrollViewContentSize
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	NSInteger count = [document.pageCount integerValue];
    
	if (count > PAGING_VIEWS) count = PAGING_VIEWS; // Limit
    
	CGFloat contentHeight = theScrollView.bounds.size.height;
    
	CGFloat contentWidth = (theScrollView.bounds.size.width * count);
    
	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[self updateScrollViewContentSize]; // Update the content size
    
	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set
    
	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(id key, id object, BOOL *stop)
     {
         ReaderContentView *contentView = object; [pageSet addIndex:contentView.tag];
     }
     ];
    
	__block CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
    
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
    
	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)updateToolbarBookmarkIcon
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	NSInteger page = [document.pageNumber integerValue];
    
	BOOL bookmarked = [document.bookmarks containsIndex:page];
    
	[mainToolbar setBookmarkState:bookmarked]; // Update
}

- (void)showDocumentPage:(NSInteger)page
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
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
        
		CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
        
		for (NSInteger number = minValue; number <= maxValue; number++)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key
            
			ReaderContentView *contentView = [contentViews objectForKey:key];
            
			if (contentView == nil) // Create a brand new document content view
			{
				NSURL *fileURL = document.fileURL; NSString *phrase = document.password; // Document properties
                
				contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:number password:phrase];
                
				[theScrollView addSubview:contentView]; [contentViews setObject:contentView forKey:key];
                
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
        
		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
		{
			theScrollView.contentOffset = contentOffset; // Update content offset
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
        
        totalPage = [document.pageCount integerValue];
        [ImdAppBehavior readingLog:[Util getUsername] MACAddr:[Util getMacAddress] title:self.currentId currentPage:currentPage totalPage:totalPage];
	}
}

- (void)showDocument:(id)object
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[self updateScrollViewContentSize]; // Set content size
    
	[self showDocumentPage:[document.pageNumber integerValue]]; // Show
    
	document.lastOpen = [NSDate date]; // Update last opened date
    
	isVisible = YES; // iOS present modal bodge
}

#pragma mark UIViewController methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"文献全文";
        localInfo = [[NSMutableDictionary alloc] init];
        
        alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
        
        imdSearchAppDelegate_iPhone* app = (imdSearchAppDelegate_iPhone*) [[UIApplication sharedApplication] delegate];
        app.delegate = self;
        self.readerInited = NO;
    }
    return self;
}

- (void)loadDocument:(ReaderDocument *)object
{
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

- (void)viewDidLoad
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif
    
	[super viewDidLoad];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    [TableViewFormatUtil setShadow:self.navigationController.navigationBar];
    CGRect viewRect = self.view.bounds; // View controller's view bounds
    self.isChangeButton = NO;
    theScrollView = [[UIScrollView alloc] initWithFrame:viewRect]; // All
    checkPhoneOrEmail = NO;
    theScrollView.scrollsToTop = NO;
    theScrollView.pagingEnabled = YES;
    theScrollView.delaysContentTouches = NO;
    theScrollView.showsVerticalScrollIndicator = NO;
    theScrollView.showsHorizontalScrollIndicator = NO;
    theScrollView.contentMode = UIViewContentModeRedraw;
    theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    theScrollView.backgroundColor = [UIColor clearColor];
    theScrollView.userInteractionEnabled = YES;
    theScrollView.autoresizesSubviews = NO;
    theScrollView.delegate = self;
    
    [self.view addSubview:theScrollView];
    //NSAssert(!(document == nil), @"ReaderDocument == nil");
    
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
    
    UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
    
    UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
    
    [singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail
    
    [self.view addGestureRecognizer:singleTapOne];
    [self.view addGestureRecognizer:doubleTapOne];
    [self.view addGestureRecognizer:doubleTapTwo];
    
    contentViews = [NSMutableDictionary new];
    lastHideTime = [NSDate new];
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending)
    {
        [self createTitleBar];
    }else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LOAD_SAVE_LOCAL style:UIBarButtonItemStylePlain target:self action:@selector(saveLocal:)];
    }
	assert(self.splitViewController == nil); // Not supported (sorry
    if (self.tmpFilePath.length > 0) {
        if (![self initReader:self.tmpFilePath]) {
            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:self.tmpFilePath error:&error]) {
                //TODO: Handle/Log error
                NSLog(@"del failed %@",error);
            }
            
        }
    }
}
- (void) createTitleBar
{
    self.titleImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
//    [self.titleImgView setImage:[UIImage imageNamed:IMG_BG_NAVGATIONBAR]];
    [self.titleImgView setBackgroundColor:[UIColor redColor]];
    button = [UIButton buttonWithType:1];
    button.frame = CGRectMake(0, 0, 320, 40);
    [button setBackgroundImage:[UIImage imageNamed:IMG_BG_NAVGATIONBAR] forState:0];
    [button setTitle:@"文献全文" forState:0];
    button.titleLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:18];
    [button setTitleColor:[UIColor whiteColor] forState:0];
    button.userInteractionEnabled = NO;
    backButton = [TableViewFormatUtil customButton:IMG_BTN_BACK_2WORDS_NORMAL title:BACK_CN location:65 target:self action:@selector(popBack)];
    saveToLocal = [TableViewFormatUtil customButton:IMG_BTN_5WORDS_NORMAL title:LOAD_SAVE_LOCAL location:button.frame.size.width target:self action:@selector(saveLocal:)];
    self.titleImgView.userInteractionEnabled = YES;
    [self.titleImgView addSubview:button];
    [self.titleImgView addSubview:backButton];
    [self.titleImgView addSubview:saveToLocal];
    
    [self.view addSubview:self.titleImgView];
    //[titleImgView release];
}
-(void)changeButtonOrientation
{
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending)
    {
        
        if (self.isChangeButton) {
            self.titleImgView.frame = CGRectMake(0, 0, 480, 40);
            button.frame = CGRectMake(0, 0, 480, 40);
            saveToLocal.frame = CGRectMake(380 , 5 , 95, 30);
        }else {
            self.titleImgView.frame = CGRectMake(0, 0, 320, 40);
            button.frame = CGRectMake(0, 0, 320, 40);
            saveToLocal.frame = CGRectMake(220,5 , 95, 30);
        }
        [self setRightBarButtons:NO];
    }
}

- (BOOL) initReader:(NSString*)pdfFileName
{
    if (self.readerInited == YES)
        return YES;
    else {
        @try{
            ReaderDocument *pdfDoc = [ReaderDocument withDocumentFilePath:pdfFileName password:nil];
            if (pdfDoc != nil) {
                [self loadDocument:pdfDoc];
                CGRect viewRect = self.view.bounds; // View controller's view bounds
                
                CGRect pagebarRect = viewRect;
                pagebarRect.size.height = PAGEBAR_HEIGHT;
                pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);
                
                mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // At bottom
                
                mainPagebar.delegate = self;
                
                [self.view addSubview:mainPagebar];
                
                if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time
                {
                    [self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
                }
                self.readerInited = YES;
            } else {
                NSLog(@"Bad pdf");
                saveToLocal.hidden = YES;
                return NO;
            }
        } @catch(NSException* ex) {
            NSLog(@"Bad pdf: %@", ex.reason);
            return NO;
        }
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif
  	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif
    
	[super viewDidAppear:animated];
    
#if (READER_DISABLE_IDLE == TRUE) // Option
    
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    
#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif
    
	[super viewWillDisappear:animated];
    
	lastAppearSize = self.view.bounds.size; // Track view size
    
#if (READER_DISABLE_IDLE == TRUE) // Option
    
	[UIApplication sharedApplication].idleTimerDisabled = NO;
    
#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif
   [self updateScrollViewContentViews]; 
	[super viewDidDisappear:animated];
    if (checkPhoneOrEmail) {
        imdSearchAppDelegate_iPhone* app = (imdSearchAppDelegate_iPhone*) [[UIApplication sharedApplication] delegate];
        
        [app showAccoutActiveView:self.delegated title:@"" emailActive:self.emailActive mobileActive:self.mobileActive fromRegister:NO];
    }
    checkPhoneOrEmail = NO;
}

- (void)viewDidUnload
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	mainToolbar = nil;
    mainPagebar = nil;
    
	theScrollView = nil; contentViews = nil;
    
	lastHideTime = nil; lastAppearSize = CGSizeZero; currentPage = 0;
    
	[super viewDidUnload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), toInterfaceOrientation);
#endif
    
	if (isVisible == NO) return; // iOS present modal bodge
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), interfaceOrientation);
#endif
    if (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight) {
        self.isChangeButton = YES;
    }
    [self changeButtonOrientation];
	if (isVisible == NO) return; // iOS present modal bodge
    
	[self updateScrollViewContentViews]; // Update content views
    
	lastAppearSize = CGSizeZero; // Reset view size tracking
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
#ifdef DEBUGX
	NSLog(@"%s %@ (%d to %d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), fromInterfaceOrientation, self.interfaceOrientation);
#endif
    self.isChangeButton = NO;
}

- (void)didReceiveMemoryWarning
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	mainToolbar = nil;
    mainPagebar = nil;
    
	theScrollView = nil;
    contentViews = nil;
    
    lastHideTime = nil;
    document = nil;
    titleImgView = nil;
    
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)myScrollView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	__block NSInteger page = 0;
    
	CGFloat contentOffsetX = myScrollView.contentOffset.x;
    
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
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[self showDocumentPage:theScrollView.tag]; // Show page
    
	theScrollView.tag = 0; // Clear page number tag
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;
    
	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum
        
		if ((maxPage > minPage) && (page != minPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;
            
			contentOffset.x -= theScrollView.bounds.size.width; // -= 1
            
			[theScrollView setContentOffset:contentOffset animated:YES];
            
			theScrollView.tag = (page - 1); // Decrement page number
		}
	}
}

- (void)incrementPageNumber
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum
        
		if ((maxPage > minPage) && (page != maxPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;
            
			contentOffset.x += theScrollView.bounds.size.width; // += 1
            
			[theScrollView setContentOffset:contentOffset animated:YES];
            
			theScrollView.tag = (page + 1); // Increment page number
		}
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds
        
		CGPoint point = [recognizer locationInView:recognizer.view];
        
		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area
        
		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #
            
			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key
            
			ReaderContentView *targetView = [contentViews objectForKey:key];
            
			id target = [targetView processSingleTap:recognizer]; // Process tap
            
			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					[[UIApplication sharedApplication] openURL:target];
				}
				else // Not a URL, so check for other possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
						NSInteger value = [target integerValue]; // Number
                        
						[self showDocumentPage:value]; // Show the page
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
				if ([lastHideTime timeIntervalSinceNow] < -0.5) // Delay since hide
				{
                    if (mainPagebar.hidden == YES)
					{
                        //[self showNavBar];
                        [mainPagebar showPagebar]; // Show
                        [self goForAnimation:0.25 animationDelay:0.0 animationView:self.titleImgView alpha:1.0];
                    } else {
                        [mainPagebar hidePagebar];
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
- (void) goForAnimation:(NSTimeInterval)duration animationDelay:(NSTimeInterval)delay
          animationView:(UIView *)view alpha:(float)a {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationDelay:delay];
	view.alpha = a;
	[UIView commitAnimations];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
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

#pragma mark ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
	if ((mainToolbar.hidden == NO) || (mainPagebar.hidden == NO))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info
			CGPoint point = [touch locationInView:self.view]; // Touch location
			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);
            
			if (CGRectContainsPoint(areaRect, point) == false) return;
		}
        
        if (![mainPagebar isHidden]) {
            [self goForAnimation:0.25 animationDelay:0.0 animationView:self.titleImgView alpha:0.0];
            [mainPagebar hidePagebar]; // Hide
            lastHideTime = [NSDate new];
        }
        
        //[mainToolbar hideToolbar];
	}
}

#pragma mark ReaderMainToolbarDelegate methods

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
#ifdef DEBUG
    if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ThumbsViewControllerDelegate methods

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[self updateToolbarBookmarkIcon]; // Update bookmark icon
    
    [self dismissViewControllerAnimated:NO completion:nil];     // Dismiss
}

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[self showDocumentPage:page]; // Show the page
}

#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[self showDocumentPage:page]; // Show the page
}

#pragma mark UIApplication notification methods

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
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
    [ImdAppBehavior readOverLog:[Util getUsername] MACAddr:[Util getMacAddress] title:self.currentId currentPage:currentPage totalPage:totalPage];
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSArray *array = self.navigationController.viewControllers;
        DocArticleController *detail = [array objectAtIndex:[array count]-2];
        [self.navigationController popToViewController:detail animated:YES];
        //[self.navigationController popViewControllerAnimated:YES];
    }
}


-(BOOL) isSavedLocal
{
    //    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* downloadList = [MyDatabase readDocData:[[NSUserDefaults standardUserDefaults] objectForKey:SAVED_USER] externalId:self.currentId];
    BOOL ret = NO;
    if ([downloadList count]) {
        ret = YES;
    }
    
    return ret;
}

-(void) saveLocal:(id) sender
{
    if (!self.view.hidden) {
        NSError* error = nil;
        if (![[NSFileManager defaultManager] copyItemAtPath:self.tmpFilePath toPath:self.filePath error:&error])
            NSLog(@"Copy from %@ to %@ error: %@", self.tmpFilePath, self.filePath, [error localizedFailureReason]);
        NSLog(@"Copy from %@ to %@.", self.tmpFilePath, self.filePath);
        NSLog(@"self.localInfo===%@",self.localInfo);
        [self.localInfo setObject:[self filePath] forKey:LOCAL_PDF_PATH];
        
        [ImdAppBehavior doFavoriteLog:[Util getUsername] MACAddr:[Util getMacAddress] title:self.currentId pageName:PAGE_LOCA action:ACT_ADD];
        
        [MyDataBaseSql insertDetail:[self.localInfo objectForKey:LOCAL_RESULT] ismgr:[[NSUserDefaults standardUserDefaults] objectForKey:SAVED_USER] filePath:self.filePath];
        
        [[TKAlertCenter defaultCenter] postAlertWithMessage:LOAD_SAVE_SUCCESS];
        
        [self setRightBarButtons:NO];
    }
}

#pragma mark - View lifecycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (!self.view.hidden) {
        return  (interfaceOrientation == UIInterfaceOrientationPortrait ||       interfaceOrientation == UIDeviceOrientationLandscapeRight ||
                 interfaceOrientation == UIDeviceOrientationLandscapeLeft);
    }
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark request
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    self.view.hidden = NO;
    imdSearchAppDelegate_iPhone* app = (imdSearchAppDelegate_iPhone*) [[UIApplication sharedApplication] delegate];
    app.backNavigationBar.hidden = YES;
    saveToLocal.hidden = YES;
    [self.alertView show];
    [self popBack];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    self.view.hidden = NO;
    imdSearchAppDelegate_iPhone* app = (imdSearchAppDelegate_iPhone*) [[UIApplication sharedApplication] delegate];
    app.backNavigationBar.hidden = YES;
    NSString* s =[request responseString];
    saveToLocal.hidden = NO;
    
    if (s != nil) {
        NSLog(@"s= %@",s);
        if ([s isEqualToString:@"FAIL"]) {
            [self.alertView setTitle:DOWNLOAD_DOC];
            [self.alertView setMessage:DOWNLOAD_DOC_FAILEDS];
            [self.alertView show];
        }
        else if ([s isEqualToString:@"QUEUE"]) {
            [self.alertView setTitle:DOWNLOAD_DOC];
            [self.alertView setMessage:DOWNLOAD_DOC_QUEUE];
            [self.alertView show];
        }
        else if ([s isEqualToString:@"MAXVALUE"]) {
            UIAlertView *maxAlertView = [[UIAlertView alloc] initWithTitle:DOWLOAD_UPPERNUM message:DOWNLOAD_DOC_MAXVALUE delegate:self cancelButtonTitle:SET_KNOW otherButtonTitles:SET_INVITE, nil];
            maxAlertView.tag = MAXNUMBERTAG;
            [maxAlertView show];
        }
    }
    else
    {
        NSLog(@"loading pdf: %@", self.tmpFilePath);
        if(![self loadPDF:self.tmpFilePath]) {
            // [self clearCaches:self.currentId];
            NSLog(@"load pdf failed");
            saveToLocal.hidden = YES;
            NSString* response =[NSString stringWithContentsOfFile:self.tmpFilePath encoding:NSUTF8StringEncoding error:NULL];
            
            NSString* status = response;
            if ([status isEqualToString:@"FAIL"]) {
                [self.alertView setTitle:DOWNLOAD_DOC];
                [self.alertView setMessage:DOWNLOAD_DOC_FAILEDS];
                [self.alertView show];
            } else if ([status isEqualToString:@"QUEUE"]) {
                [self.alertView setTitle:DOWNLOAD_DOC];
                [self.alertView setMessage:DOWNLOAD_DOC_QUEUE];
                [self.alertView show];
            } else if ([status isEqualToString:@"MAXVALUE"]) {
                UIAlertView *maxAlertView = [[UIAlertView alloc] initWithTitle:DOWLOAD_UPPERNUM message:DOWNLOAD_DOC_MAXVALUE delegate:self cancelButtonTitle:SET_KNOW otherButtonTitles:SET_INVITE, nil];
                maxAlertView.tag = MAXNUMBERTAG;
                [maxAlertView show];
            }else if ([status isEqualToString:@"INACTIVE"]) {
                checkPhoneOrEmail = YES;
                self.alertView.message = @"您的帐号未通过手机或者邮箱验证，请先进行验证。";
                self.alertView.title = DOWNLOAD_DOC;
                self.alertView.tag = 5;
                [self.alertView show];
            }else if ([status isEqualToString:@"UNVERIFIED"])
            {
                NSString *name = [UserManager userName];
                NSString *isOk = [[NSUserDefaults standardUserDefaults] objectForKey:name];
                if ([isOk isEqualToString:@"0"]) {
                    UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的身份尚未通过实名验证，请先收藏文献。验证后即可免费获取全文。" delegate:self cancelButtonTitle:@"完善帐号信息" otherButtonTitles:nil];
                    alertE.tag = 7;
                    [alertE show];
                } else if([isOk isEqualToString:@"1"]){
                    UIAlertView *alertE = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"您的身份验证已经提交,我们将在两个工作日内完成验证。身份验证通过后即可免费下载全文。您可先收藏此文献。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"重新修改", nil];
                    alertE.tag = 6;
                    [alertE show];
                }
            } else {
                [self.alertView setTitle:LOAD_PDF_FAILED_TITLE];
                [self.alertView setMessage:LOAD_PDF_FAILED_MESSAGE];
                [self.alertView show];
            }
            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:self.tmpFilePath error:&error]) {
                //                TODO: Handle/Log error
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
        self.tmpFilePath = fileP;
        self.filePath = [UrlRequest getSavedFilePath:externelId];
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
//    UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:IMG_PRE_ARTICLE_NORMAL], [UIImage imageNamed:IMG_NEXT_ARTICLE_NORMAL], nil]];
//    
//    segmentedControl.tintColor = [UIColor clearColor];
//    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
//    segmentedControl.frame = CGRectMake(0, 0, 70, 35);
//    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
//    segmentedControl.tintColor = [UIColor clearColor];
//    segmentedControl.momentary = YES;
  
    //    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
  
    if (isOffLine) {
        
    } else if (![self isSavedLocal]) {
      if (self.navigationItem.rightBarButtonItem == nil) {
        self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:LOAD_SAVE_LOCAL style:UIBarButtonItemStylePlain target:self action:@selector(saveLocal:)];
      }
      [self.navigationItem.rightBarButtonItem setTitle:LOAD_SAVE_LOCAL];
      self.navigationItem.rightBarButtonItem.enabled = YES;
        [saveToLocal setTitle:LOAD_SAVE_LOCAL forState:0];
        saveToLocal.userInteractionEnabled = YES;
    } else {
      if (self.navigationItem.rightBarButtonItem == nil) {
        self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:LOAD_LOCAL_SAVED style:UIBarButtonItemStylePlain target:self action:@selector(saveLocal:)];
      }
        self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.navigationItem.rightBarButtonItem setTitle:LOAD_LOCAL_SAVED];
        [saveToLocal setTitle:LOAD_LOCAL_SAVED forState:0];
        saveToLocal.userInteractionEnabled = NO;
    }
}



-(BOOL)loadPDF:(NSString*)pdfFileName
{
    //    NSURL* fileURL = [NSURL fileURLWithPath:pdfFileName];
    BOOL ret = YES;
    ret = [self initReader:pdfFileName];
    lastHideTime = [NSDate new];
    
    if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false) {
        NSLog(@"Update now");
        if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false) {
            [self updateScrollViewContentViews]; // Update content views
        }
        lastAppearSize = CGSizeZero; // Reset view size tracking
    }
    [mainPagebar showPagebar];
    return ret;
}


-(void) hideNavBar
{
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.navigationController.navigationBar.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         self.navigationController.navigationBarHidden = YES;
                     }
     ];
}

-(void) showNavBar
{
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         self.navigationController.navigationBarHidden = NO;
                         self.navigationController.navigationBar.alpha = 1.0f;
                     }
                     completion:NULL
     ];
}

-(BOOL)findCache:(NSString*)externelId
{
    NSString* fileP = [UrlRequest getDownloadFilePath:externelId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileP]) {
        return YES;
    }
    return NO;
}
- (void)alertView:(UIAlertView *)alertViews clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertViews.tag == 5 && buttonIndex == 0) {
        [self popBack];
    }
    if (alertViews.tag == 7 && buttonIndex == 0) {
        [self popBack];
    }
    if (alertViews.tag == MAXNUMBERTAG && buttonIndex == 1) {
        InviteRegisterViewController *viewController = [[InviteRegisterViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
@end
