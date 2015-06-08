//
//  filterTableController.m
//  imdPad
//
//  Created by 8fox on 6/14/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import "filterTableController.h"
#import "imdSearcher.h"

@implementation filterTableController
@synthesize delegate;
@synthesize searchLanguage;
@synthesize tag,filterString;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
    
    NSDictionary* searchData = [self readPListBundleFile:@"searchFilters"];
    
    
    filterDataCN = [[searchData objectForKey:@"CN_TEXT"] mutableCopy];
        
    filterDataEN = [[searchData objectForKey:@"EN_TEXT"] mutableCopy];
    
    /*filterDataEN = [[NSMutableArray alloc] initWithObjects:
                   @"All Fields",@"Affiliation",@"Author",@"Book",@"Corporate Author",@"Create Date",@"EN/RN Number",@"Editor",@"Enterz Date",@"Filter",@"First Author",@"Full Author Name",@"Full Investigator Name",@"Grant Number",@"ISBN",@"Investigator",@"Issue",@"Journal",@"Language",@"Last Author",@"Location ID",@"MeSH Date",@"MeSH Major Topic",@"MeSH Subheading",@"MeSH Terms",@"Pagination",@"Pharmacological Action",@"Publication Date",@"Publication Type",@"Publisher",@"Secondary Source ID",@"Supplementary Concept",@"Text Word",@"Title",@"Title/Abstract",@"Transliterated",@"Volumn",nil];*/
    
    //NSLog(@"en %d",[filterDataEN count]);
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(searchLanguage == SEARCH_MODE_CN) return [filterDataCN count];
    
    return [filterDataEN count];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if(searchLanguage == SEARCH_MODE_CN) 
      cell.textLabel.text = [filterDataCN objectAtIndex:indexPath.row];    
    else
      cell.textLabel.text = [filterDataEN objectAtIndex:indexPath.row];    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"table sel");
    
    if (delegate && [delegate respondsToSelector:@selector(filterSelected:)]) 
    {
        
        if(searchLanguage == SEARCH_MODE_CN)
            self.filterString = [filterDataCN objectAtIndex:indexPath.row];
        else
            self.filterString = [filterDataEN objectAtIndex:indexPath.row];
        
        
		[delegate performSelector:@selector(filterSelected:) withObject:self];
    }   
    
            
    
}

#pragma mark - loadPlist


- (NSDictionary*)readPListBundleFile:(NSString*)fileName
{
	NSString *plistPath;
	plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	
	NSMutableDictionary* temp =[[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] autorelease];
    
    
	
	if (!temp) {
		NSLog(@"Error reading plist of %@",fileName);
	}
	
	return temp;
	
}



@end
