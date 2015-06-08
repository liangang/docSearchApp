//
//  FulltextAlert.m
//  imdSearch
//
//  Created by Huajie Wu on 12-3-30.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "FulltextAlert.h"

@implementation FulltextAlert

@synthesize label1 = _label1, label2 = _label2, submit = _submit, icon = _icon;

- (void) dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    [self.view setFrame:CGRectMake(0, 0, 320, 60)];
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

 // Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
  [self.icon setFrame:CGRectMake(10, 10, 20, 20)];
  [self.label1 setFrame:CGRectMake(10, 10, 20, 20)];
  [self.label2 setFrame:CGRectMake(10, 10, 20, 20)];
  [self.submit setFrame:CGRectMake(10, 10, 20, 20)];

  [self.view addSubview:self.icon];
  [self.view addSubview:self.label1];
  [self.view addSubview:self.label2];
  [self.view addSubview:self.submit];
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

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
