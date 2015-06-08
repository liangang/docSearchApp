//
//  sortInfoSelectViewController.m
//  imdSearch
//
//  Created by xiangzhang on 5/24/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "sortInfoSelectViewController.h"

@interface sortInfoSelectViewController ()

@end

@implementation sortInfoSelectViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellsort";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 140, 50)];
        title.font = [UIFont fontWithName:@"Palatino-Bold" size:20.0];
        title.tag = 2014052401;
        title.textAlignment = NSTextAlignmentLeft;
        title.backgroundColor = [UIColor clearColor];
        title.textColor =[UIColor blackColor];
        [cell addSubview:title];
        
        UIImageView *mark =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-check"]];
        mark.frame = CGRectMake(120, 16, 16, 16);
        mark.tag = 2014052402;
        [cell addSubview:mark];
    }
    
   
    NSString *item = [self.dataArray objectAtIndex:indexPath.row];
    UILabel *title = (UILabel *)[cell viewWithTag:2014052401];
    title.text = item;
    
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:2014052402];
    if(indexPath.row == self.selectedItem){
        imageView.hidden = NO;
    }else{
        imageView.hidden = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedItem = indexPath.row;
    
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectSortWithPosition:)])
    {
        [self.delegate selectSortWithPosition:indexPath.row];
    }
}

@end
