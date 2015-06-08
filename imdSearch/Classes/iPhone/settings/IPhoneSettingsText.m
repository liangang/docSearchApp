//
//  IPhoneSettingsText.m
//  imdSearch
//
//  Created by Huajie Wu on 12-1-10.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "IPhoneSettingsText.h"
#import "Strings.h"
#import "TableViewFormatUtil.h"
#import "ImageViews.h"

#import "FTCoreTextView.h"


@implementation IPhoneSettingsText

@synthesize scrollView, type, label;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [TableViewFormatUtil setContentBackGround:self.view image:IMG_BG_CONTENTSBACKGROUDN];
        
        label = [[UILabel alloc]init];
    }
    return self;
}

-(void) dealloc
{
}

-(void) popBack:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (iPhone5) {
        self.scrollView.frame = CGRectMake(0, 0, 320, 455);
    }

//    NSInteger yOffSet = 10;
//    label.lineBreakMode = NSLineBreakByWordWrapping;
//    label.textAlignment = NSTextAlignmentLeft;
//    label.textColor = [TableViewFormatUtil getFontColor1];
//    label.backgroundColor = [UIColor clearColor];
//    
//    label.numberOfLines = 0;
//    
//    if ([type isEqualToString:SETTINGS_ABOUTUS]) {
//        self.title = SETTINGS_ABOUTUS;
//        label.text = SETTINGS_ABOUTUS_TEXT;
//    } else {
//        self.title = SETTINGS_AGREEMENT;
//        label.text = SETTINGS_AGREEMENT_TEXT;
//    }
//    
//    NSInteger width = scrollView.frame.size.width - 16;
//    yOffSet = [TableViewFormatUtil layoutLabelByStringWithLeft:label text:label.text y:yOffSet  contentWidth:width marginLeft:8];
//    
//    [scrollView addSubview:label];
//    
//    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, yOffSet)];
    
    FTCoreTextView *textView = [[FTCoreTextView alloc] init];
    
    NSMutableArray *styles = [[NSMutableArray alloc] initWithCapacity:0];
    FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
	defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
	defaultStyle.font = [UIFont systemFontOfSize:17];
    defaultStyle.color = RGBCOLOR(64, 64, 64);
	defaultStyle.textAlignment = FTCoreTextAlignementLeft;
	[styles addObject:defaultStyle];
    
    FTCoreTextStyle *orangeStyle = [defaultStyle copy];
	[orangeStyle setName:@"orange"];
    [orangeStyle setColor:RGBCOLOR(248, 90, 59)];
    [orangeStyle setFont:[UIFont boldSystemFontOfSize:17]];
	[styles addObject:orangeStyle];

    [textView addStyles:styles];
    textView.frame = CGRectMake(10, 10, 300, 44);
    if ([type isEqualToString:SETTINGS_ABOUTUS]) {
        self.title = SETTINGS_ABOUTUS;
        textView.text = SETTINGS_ABOUTUS_TEXT;
    }else{
        self.title = SETTINGS_AGREEMENT;
        textView.text = SETTINGS_AGREEMENT_TEXT;
    }
    
    [textView fitToSuggestedHeight];
    
    [scrollView addSubview:textView];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, textView.frame.size.height + 30)];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

@end
