//
//  shareSelectViewController.m
//  imdSearch
//
//  Created by 8fox on 10/26/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "shareSelectViewController.h"

@implementation shareSelectViewController
@synthesize delegate,selectedItem;

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellsort";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString* text;
    // Configure the cell...
    if(indexPath.row == 0)
    {
        text = @"电子邮件";
    } else if(indexPath.row ==1) {
        text = @"复制链接";
    } else {
        text = @"新浪微博";
    }
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
    lbl.font = [UIFont fontWithName:@"Palatino-Bold" size:20.0];
    lbl.text = text;
    lbl.textAlignment = NSTextAlignmentCenter;
    
    if(indexPath.row == selectedItem)
        lbl.textColor = [UIColor blueColor];
    else
        lbl.textColor = [UIColor blackColor];
    
    
    [cell addSubview:lbl];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(delegate && [delegate respondsToSelector:@selector(shareSelected:)])
    {
		[delegate performSelector:@selector(shareSelected:) withObject:self];
    }
}


@end
