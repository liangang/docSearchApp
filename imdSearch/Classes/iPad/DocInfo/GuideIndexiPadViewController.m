//
//  GuideIndexiPadViewController.m
//  imdSearch
//
//  Created by xiangzhang on 4/16/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "GuideIndexiPadViewController.h"

#import "EAIntroPage.h"
#import "EAIntroView.h"

@interface GuideIndexiPadViewController ()<EAIntroDelegate>

@end

@implementation GuideIndexiPadViewController

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
    EAIntroPage *page1 = [EAIntroPage page];
    page1.titleImage = [UIImage imageNamed:@"indexPageP_1"];
    page1.imgPositionY = 0;
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.titleImage = [UIImage imageNamed:@"indexPageP_2"];
    page2.imgPositionY = 0;
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.titleImage = [UIImage imageNamed:@"indexPageP_3"];
    page3.imgPositionY = 0;
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.titleImage = [UIImage imageNamed:@"indexPageP_4"];
    page4.imgPositionY = 0;
    
    EAIntroPage *page5 = [EAIntroPage page];
    page5.titleImage = [UIImage imageNamed:@"indexPageP_5"];
    page5.imgPositionY = 0;
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3,page4,page5]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}

- (void)introDidFinish{
    NSLog(@"Finish");
    [self.view removeFromSuperview];
}
@end
