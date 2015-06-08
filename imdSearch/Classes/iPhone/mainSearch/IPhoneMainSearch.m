
//
//  IPhoneMainSearch.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-11.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "IPhoneMainSearch.h"
#import "Strings.h"
#import "UrlRequest.h"

#import "ImdUrlPath.h"
#import "imdSearchAppDelegate.h"
#import "TableViewFormatUtil.h"
#import "ImageViews.h"

#import "CompatibilityUtil.h"
#import "IPhoneHeader.h"
#import "MyDataBaseSql.h"
#import "MyDatabase.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>
#import "imdSearchAppDelegate_iPhone.h"

@implementation IPhoneMainSearch

@synthesize isFirstTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isFirstTime = YES;
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
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    
    //Set search scope.
    NSArray* scope = @[SEARCH_MODE_CN_TEXT,SEARCH_MODE_EN_TEXT];
    
    self.searchDisplayController.searchBar.scopeButtonTitles = scope;
    self.searchDisplayController.searchBar.layer.shadowOpacity = 0.4;
    self.searchDisplayController.searchBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.searchDisplayController.searchBar.layer.shadowColor = [UIColor clearColor].CGColor;
    self.searchDisplayController.searchBar.layer.shadowRadius = 2;
    
    _suggestions = [[NSMutableArray alloc] init];
    _resultsList = [[SearchResults alloc] init];
    [TableViewFormatUtil backBarButtonItemInfoModify:self.navigationItem];
    
    if (IOS7) {
        CGRect searbarRect = self.searchDisplayController.searchBar.frame;
        searbarRect.origin.y += 20;
        self.searchDisplayController.searchBar.frame = searbarRect;
        
        CGRect tableRect = self.historyTable.frame;
        tableRect.origin.y += 20;
        tableRect.size.height -= 20;
        self.historyTable.frame = tableRect;
    }else
    {
      CGRect tableRect = self.historyTable.frame;
      tableRect.origin.y -= 20;
      self.historyTable.frame = tableRect;
    }
  
    [self updateViewStyle];
    [self historyDataDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)dealloc {
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)historyDataDisplay{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    tempArray = [NSMutableArray arrayWithArray: [defaults arrayForKey:QUERY_HISTORY_LIST]];
    if ([tempArray count]) {
        for (int i = 0, sum = [tempArray count]; i< sum; i++) {
            if ([defaults objectForKey:SAVED_USER]) {
                [MyDataBaseSql insertMyHistory:[tempArray objectAtIndex:i] userid:[defaults objectForKey:SAVED_USER]];
            }
        }
    }
    
    if ([UserManager userName]) {
        self.queryHistory = [MyDatabase readHistoryData:[defaults objectForKey:SAVED_USER]];
    }else {
        self.queryHistory = [MyDatabase readHistoryData:GUEST_USER];
    }
    
    [self.resultsList.resultsArray removeAllObjects];
    [self.resultsList.tableView reloadData];
    
    if (self.queryHistory.count == 0) {
        [self setHistoryTableHidden:YES];
    } else {
        [self setHistoryTableHidden:NO];
        
        [self.historyTable reloadData];
    }
}

- (void)updateViewStyle{
    self.title = DOCSEARCH_CN;
    _alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
    
    if (IOS7) {
         self.searchDisplayController.searchBar.showsScopeBar = YES;
        self.searchDisplayController.searchBar.layer.shadowColor = RGBCOLOR(249, 249, 249).CGColor;
        [self.searchDisplayController.searchResultsTableView setOpaque:NO];
    } else {
        self.navigationController.view.backgroundColor = [UIColor whiteColor];
        UIImageView* imageContentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_BG_CONTENTSBACKGROUDN]];
        [self.searchDisplayController.searchResultsTableView setBackgroundView:imageContentView];
        self.searchDisplayController.searchBar.layer.shadowColor = [UIColor blackColor].CGColor;
        [self.searchDisplayController.searchResultsTableView setOpaque:NO];
    }
    
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_wenxian"]];
    self.imageView.center = self.view.center;
    [self.view addSubview:self.imageView];
    [self.view sendSubviewToBack:self.imageView];
    [self.view setOpaque:YES];
    
    [self.searchDisplayController.searchResultsTableView addSubview:self.indicator];
}

#pragma mark iOS 7
- (void) viewDidLayoutSubviews {
    if (IOS7) {
//        [self showStatusbar];
    }
}

#pragma mark start and login
- (void)willStartLogin
{
}

- (void)didFinishStart
{
    //IOS 5.0 above.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissCover
{
    // IOS 5.0 above.
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    isFirstTime = NO;
}

#pragma mark internal.
- (void)doSearch:(NSString*) queryString source:(NSString*)source
{
    self.resultsList.queryStr = queryString;
    self.resultsList.source = source;
    self.resultsList.pageNo = 1;
    self.resultsList.count = 0;
    self.resultsList.view.hidden = YES;
    
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    appDelegate.imageView.hidden = YES;
    appDelegate.SearchimageView.hidden = NO;
    appDelegate.FullTextimageView.hidden = YES;
    self.resultsList.sort = 5;
    [self.resultsList updateSortPicker:0];
    
    [self.navigationController pushViewController:self.resultsList animated:YES];
    
    [TableViewFormatUtil setShadow:self.navigationController.navigationBar];
    NSString* url = [ImdUrlPath docSearchUrl:queryString src:source pageNo:1 pageSize:self.resultsList.pageSize sort:5];
    NSLog(@"URL = %@", url);
    
    //TODO(wuhuajie): to be optimized.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:queryString forKey:QUERY_HISTORY_STRING];
    [dic setObject:source forKey:QUERY_HISTORY_SOURCE];
    
    if ([UserManager userName]) {
        [MyDataBaseSql insertMyHistory:dic userid:[defaults objectForKey:SAVED_USER]];
    }else {
        [MyDataBaseSql insertMyHistory:dic userid:GUEST_USER];
    }
    
    self.queryHistory = [MyDatabase readHistoryData:[defaults objectForKey:SAVED_USER]];
    // self.queryHistory = [NSMutableArray arrayWithArray:array];
    
    NSDictionary* node = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:queryString, source, nil] forKeys:[NSArray arrayWithObjects:QUERY_HISTORY_STRING, QUERY_HISTORY_SOURCE, nil]];
    
    NSInteger dupIndex = -1;
    for(NSInteger i = 0; i < self.queryHistory.count; ++i) {
        NSString* querySrc = [NSString stringWithFormat:@"%@-%@", [[self.queryHistory objectAtIndex:i] objectForKey:QUERY_HISTORY_SOURCE ], [[self.queryHistory objectAtIndex:i] objectForKey:QUERY_HISTORY_STRING]];
        NSString* queryNow = [NSString stringWithFormat:@"%@-%@", source, queryString];
        if ([queryNow isEqualToString:querySrc]) {
            dupIndex = i;
            break;
        }
    }
    if (dupIndex >= 0) {
        [self.queryHistory removeObjectAtIndex:dupIndex];
    }
    [self.queryHistory addObject:node];
    
    while (self.queryHistory.count > 20)
        [self.queryHistory removeObjectAtIndex:0];
    
    [self.historyTable reloadData];
    
    if (self.resultsList.httpRequest != nil) {
        [self.resultsList.httpRequest clearDelegatesAndCancel];
    }
    self.resultsList.httpRequest = [UrlRequest send:url delegate:self.resultsList];
    
    [ImdAppBehavior searchJsonLog:[Util getUsername] MACAddr:[Util getMacAddress] SearchJson:queryString];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *source = SEARCH_MODE_C;
    if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0)
        source = SEARCH_MODE_C;
    else
        source = SEARCH_MODE_E;
    
    [self doSearch:searchBar.text source:source];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
}

#pragma mark UITableView data source and delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.suggestions.count;
    } else if (tableView == self.historyTable && self.queryHistory.count > 0) {
        return self.queryHistory.count + 1;
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"suggestItem"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"suggestItem"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.suggestions objectAtIndex:indexPath.row]];
        cell.textLabel.textColor = [TableViewFormatUtil getFontColor2];
        cell.textLabel.font = [UIFont fontWithName:FONT_TYPE size:FONT_3];
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.opaque = NO;
        cell.textLabel.backgroundColor = [UIColor clearColor];
    } else if (tableView == self.historyTable) {
        if (indexPath.row >= self.queryHistory.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"clearHistoryItem"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearHistoryItem"];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            cell.textLabel.text = CLEAR_HISTORY_TEXT;
            cell.textLabel.font = [UIFont fontWithName:FONT_BOLD size:FONT_3];
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.textColor = [TableViewFormatUtil getFontColor1];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.opaque = NO;
            cell.textLabel.backgroundColor = [UIColor clearColor];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"suggestItem"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"suggestItem"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            NSInteger i = self.queryHistory.count - indexPath.row - 1;
            NSString* query = [[self.queryHistory objectAtIndex:i] objectForKey:QUERY_HISTORY_STRING];
            NSString* source = [[self.queryHistory objectAtIndex:i] objectForKey:QUERY_HISTORY_SOURCE ];
            NSString* sourceStr = nil;
            
            if ([source isEqualToString:SEARCH_MODE_C])
                sourceStr = SEARCH_QUERY_CN_TEXT;
            else
                sourceStr = SEARCH_QUERY_EN_TEXT;
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", sourceStr, query];
            cell.textLabel.textColor = [TableViewFormatUtil getFontColor2];
            cell.textLabel.font = [UIFont fontWithName:FONT_TYPE size:FONT_3];
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.opaque = NO;
            cell.textLabel.backgroundColor = [UIColor clearColor];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.searchDisplayController.searchBar resignFirstResponder];
    
    NSString *queryStr = nil;
    NSString *source = SEARCH_MODE_C;
    
    if(tableView == self.historyTable) {
        if (indexPath.row >= self.queryHistory.count) {
            [self clearHistory];
        } else {
            NSInteger i = self.queryHistory.count - indexPath.row - 1;
            queryStr = [[self.queryHistory objectAtIndex:i] objectForKey:QUERY_HISTORY_STRING];
            source = [[self.queryHistory objectAtIndex:i] objectForKey:QUERY_HISTORY_SOURCE ];
            [self doSearch:queryStr source:source];
        }
    } else {
        queryStr = [[cell textLabel] text];
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0)
            source = SEARCH_MODE_C;
        else
            source = SEARCH_MODE_E;
        [self doSearch:queryStr source:source];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (tableView == self.historyTable) {
        if (indexPath.row != self.queryHistory.count)
            return YES;
        else
            return NO;
    } else
        return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if (tableView == self.historyTable) {
            [self.queryHistory removeObjectAtIndex:(self.queryHistory.count - indexPath.row - 1)];
            NSArray* array = [NSArray arrayWithObject:indexPath];
            if (self.queryHistory.count == 0) {
                NSIndexPath* more = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                array = [NSArray arrayWithObjects:indexPath, more,nil];
                
                [self clearHistory];
            }
            [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView reloadData];
            
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView && self.suggestions.count > 0) {
        NSString *listItem = [self.suggestions objectAtIndex:indexPath.row];
        if ([listItem isEqualToString:@""]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView
        && self.suggestions.count > 0) {
        NSString *listItem = [self.suggestions objectAtIndex:indexPath.row];
        if ([listItem isEqualToString:@""]) {
            return nil;
        }
    }
    return indexPath;
}

#pragma mark UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSString* source = nil;
    
    if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0)
        source = SEARCH_MODE_C;
    else
        source = SEARCH_MODE_E;
    
    NSString *url = [ImdUrlPath docSuggestUrl:searchString src:source max:10];
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    self.httpRequest = [UrlRequest send:url delegate:self];
    [self.indicator startAnimating];
    
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return YES;
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self setHistoryTableHidden:YES];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    if (self.queryHistory.count > 0)
        [self setHistoryTableHidden:NO];
}

#pragma mark - statusbar show
- (void)showStatusbar{
    CGRect viewBounds = self.view.bounds;
    CGFloat topBarOffset = self.topLayoutGuide.length;
    viewBounds.origin.y = topBarOffset * -1;
    self.view.bounds = viewBounds;
}

#pragma mark Asy Request
-(void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
    
    [self.suggestions removeAllObjects];
    NSMutableArray* info;
    if (responseString != (id)[NSNull null] && responseString.length > 0 ) {
        info = [responseString JSONValue];
        if (info != nil)
            [self.suggestions setArray:info];
        else
            [self.suggestions addObject:@""]; //to avoid to show "No Results"
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
    self.searchDisplayController.searchResultsTableView.hidden = NO;
    [self.indicator stopAnimating];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    [self.indicator stopAnimating];
    self.searchDisplayController.searchResultsTableView.hidden = NO;
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

-(void)clearHistory
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [self.queryHistory removeAllObjects];
    if ([defaults objectForKey:SAVED_USER] == nil ) {
        [MyDatabase cleanHistoryTable:@"guest"];
    } else {
        [MyDatabase cleanHistoryTable:[defaults objectForKey:SAVED_USER]];
    }
    
    NSLog(@"%@",[defaults objectForKey:SAVED_USER]);
    [defaults setObject:self.queryHistory forKey:QUERY_HISTORY_LIST];
    [defaults synchronize];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.historyTable cache:NO];
    
    [self setHistoryTableHidden:YES];
    
    [UIView commitAnimations];
}

- (void)setHistoryTableHidden:(BOOL)ishidden{
    self.historyTable.hidden = ishidden;
    self.imageView.hidden = !ishidden;
}
@end
