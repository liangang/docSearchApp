//
//  IPhoneHelper.m
//  imdSearch
//
//  Created by Huajie Wu on 12-2-27.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "IPhoneHelper.h"
#import "ImageViews.h"
#import "Strings.h"
@implementation IPhoneHelper
@synthesize pages, scrollView, pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //init
        NSArray *indexImages5 = @[IMG_HELP_STEP_iPhone5_01,IMG_HELP_STEP_iPhone5_02,IMG_HELP_STEP_iPhone5_03];
        NSArray *indexImages = @[IMG_HELP_STEP_O1,IMG_HELP_STEP_O2,IMG_HELP_STEP_O3];
        
        pageNo = [indexImages5 count];
        if (iPhone5) {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 578)];
        } else {
            scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        }
        scrollView.pagingEnabled = YES;
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * pageNo, scrollView.frame.size.height);
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.delegate = self;
        
        pages = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < pageNo; i++) {
            UIImageView *help;
            if (iPhone5) {
                help = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[indexImages5 objectAtIndex:i]]];
            }else{
                help = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[indexImages objectAtIndex:i]]];
            }
            
            [help setFrame:CGRectMake(scrollView.frame.size.width * i, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
            [scrollView addSubview:help];
        }
        
        pageControl = [[UIPageControl alloc] init];
        
        [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchDragOutside];
        pageControl.hidden = YES;
        [self.view addSubview:scrollView];
        [self.view addSubview:pageControl];
    }
    return self;
}

- (void) dealloc
{
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollView.frame.size.width;
    
    int x = scrollView.contentOffset.x - pageWidth * (pageNo - 1);
    int start = 0;
    int finish = pageWidth / 4;
    CGFloat percent = 4 * x / pageWidth;
    if ( x > start && x < finish) {
        self.view.alpha = 1 - percent;
    }
    if ( x >= finish) {
        NSLog(@"x = %d", x);
        [self.view removeFromSuperview];
    }
}

- (IBAction)changePage:(id)sender
{
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
    
    [scrollView scrollRectToVisible:frame animated:YES];
}

- (void)loadScrollViewWithPage:(int)page{
    
}
@end