//
//  IPhoneHelper.h
//  imdSearch
//
//  Created by Huajie Wu on 12-2-27.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPhoneHelper : UIViewController <UIScrollViewDelegate>{
    UIPageControl *pageControl;
    UIScrollView *scrollView;
    NSMutableArray *pages;
    unsigned int pageNo;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *pages;

- (IBAction)changePage:(id)sender;

- (void)loadScrollViewWithPage:(int)page;

@end
