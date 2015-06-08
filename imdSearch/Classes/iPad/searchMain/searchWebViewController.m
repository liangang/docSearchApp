//
//  searchWebViewController.m
//  imdSearch
//
//  Created by 立纲 吴 on 12/14/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "searchWebViewController.h"

@implementation searchWebViewController
@synthesize webview;

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
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.webview =nil;
}

#pragma mark - View lifecycle

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
    self.webview =nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


-(IBAction)CloseThis:(id)sender
{
    [self.view removeFromSuperview];
}

-(void)loadURL:(NSString *)u
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:u]];
    [webview loadRequest:urlRequest];
    //webview.delegate = self;
    
    
}

@end
