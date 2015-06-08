//
//  sortSelectViewController.m
//  imdSearch
//
//  Created by 8fox on 10/21/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "sortSelectViewController.h"

@implementation sortSelectViewController
@synthesize selectedItem,delegate;

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
    
    for (UIView *view in [cell subviews]) {
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIImageView class]])
            [view removeFromSuperview];
    }
    
    NSString* text;
    // Configure the cell...
    if(indexPath.row == 0)
    {
        text = @"相关排序";
    } else if(indexPath.row ==1) {
        text = @"时间排序";
    } else {
        text = @"期刊排序";
    }
    
    //NSLog(@"selected %d",selectedItem);
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 140, 50)];
    lbl.font = [UIFont fontWithName:@"Palatino-Bold" size:20.0];
    lbl.text = text;
    lbl.textAlignment = NSTextAlignmentLeft;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor =[UIColor blackColor];
    
    [cell addSubview:lbl];
    
    if(indexPath.row == selectedItem)
    {
        UIImageView* mark =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-check"]];
        mark.frame =CGRectMake(120, 16, 16, 16);
        [cell addSubview:mark];
    }
    
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
    selectedItem = indexPath.row;
    
    if(delegate && [delegate respondsToSelector:@selector(changeSort:)])
    {
		[delegate performSelector:@selector(changeSort:) withObject:self];
    }
}

@end


