//
//  askFullTextViewController.m
//  imdSearch
//
//  Created by 立纲 吴 on 12/19/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "askFullTextViewController.h"

@implementation askFullTextViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIBarButtonItem *aButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"索取文献" style:UIBarButtonItemStyleBordered target:self action:@selector(askForPDF:)];
        
        self.navigationItem.leftBarButtonItem =aButtonItem;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)askForPDF:(id)sender
{
    if(delegate && [delegate respondsToSelector:@selector(askForPDF:)])
    {
		[delegate performSelector:@selector(askForPDF:) withObject:nil];
    }
}

@end
