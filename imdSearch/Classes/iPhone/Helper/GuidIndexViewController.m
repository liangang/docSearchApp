//
//  GuidIndexViewController.m
//  imdSearch
//
//  Created by xiangzhang on 5/14/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "GuidIndexViewController.h"

#import "EAIntroPage.h"
#import "EAIntroView.h"

@interface GuidIndexViewController ()<EAIntroDelegate>

@end

@implementation GuidIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self showIntroWithCrossDissolve];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showIntroWithCrossDissolve {
    BOOL isIphone5 = iPhone5;
    EAIntroPage *page1 = [EAIntroPage page];
    page1.titleImage = [UIImage imageNamed:isIphone5 ? @"indexPage5_1" : @"indexPage4_1"];
    page1.imgPositionY = 0;
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.titleImage = [UIImage imageNamed:isIphone5 ? @"indexPage5_2" : @"indexPage4_2"];
    page2.imgPositionY = 0;
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.titleImage = [UIImage imageNamed:isIphone5 ? @"indexPage5_3" : @"indexPage4_3"];
    page3.imgPositionY = 0;
    
//    EAIntroPage *page4 = [EAIntroPage page];
//    page4.titleImage = [UIImage imageNamed:@"img-help-step-04"];
//    page4.imgPositionY = 0;
//    
//    EAIntroPage *page5 = [EAIntroPage page];
//    page5.titleImage = [UIImage imageNamed:@"img-help-step-05"];
//    page5.imgPositionY = 0;
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}

- (void)introDidFinish{
    NSLog(@"Finish");
    [self.view removeFromSuperview];
}

@end
