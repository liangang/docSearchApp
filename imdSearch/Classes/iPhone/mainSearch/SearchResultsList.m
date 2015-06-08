//
//  SearchResultsList.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-21.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "SearchResultsList.h"
#import "DocArticleController.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "Strings.h"
#import "TableViewFormatUtil.h"
#import "Util.h"
#import "ImageViews.h"
#import "IPhoneHeader.h"

@implementation SearchResultsList

@synthesize resultsArray;
@synthesize queryStr;
@synthesize pageNo, pageSize, sort, source;
@synthesize count, lastRequestCount;
@synthesize indicator, alertView;
@synthesize httpRequest = _httpRequest;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.pageNo = 1;
        self.pageSize = 20;
        self.sort = 5;
        self.lastRequestCount = 0;
        
        alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];

        [TableViewFormatUtil setTableViewBackGround:self.tableView image:IMG_BG_CONTENTSBACKGROUDN];
        
    }
    return self;
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

-(void) dealloc
{
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.resultsArray = nil;
    
//    UIBarButtonItem* filterResultsBtn = [[UIBarButtonItem alloc] initWithTitle:FILTER_RESULTS_CN style:UIBarButtonItemStylePlain target:self action:@selector(filterResults:)];
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
    self.navigationController.navigationBarHidden = NO;
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
    if (tableView == self.view) {
        if (self.lastRequestCount >= 20 && [self.resultsArray count] < self.count)
            return [self.resultsArray count] + 1;
        else
            return [self.resultsArray count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"docSearchResultItem";
    
    if (self.lastRequestCount >= 20 && indexPath.row == [self.resultsArray count]) {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadMore"];
        
        UIButton* loadMoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 13, 299, 35)];
        [loadMoreBtn setBackgroundColor:RGBCOLOR(249, 60, 3)];
        [loadMoreBtn setTitle:@"加载更多文献" forState:UIControlStateNormal];
        loadMoreBtn.layer.masksToBounds = YES;
        loadMoreBtn.layer.cornerRadius = 5;
        loadMoreBtn.layer.borderColor = [UIColor clearColor].CGColor;
//        [loadMoreBtn setBackgroundImage:[UIImage imageNamed:IMG_BTN_LOADMORE_NORMAL] forState:UIControlStateNormal];
//        [loadMoreBtn setBackgroundImage:[UIImage imageNamed:IMG_BTN_LOADMORE_HIGHLIGHT] forState:UIControlStateHighlighted];
//        [loadMoreBtn setBackgroundImage:[UIImage imageNamed:IMG_BTN_LOADMORE_HIGHLIGHT] forState:UIControlStateSelected];
        
        [cell setOpaque:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:loadMoreBtn];
        [cell sendSubviewToBack:loadMoreBtn];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        NSDictionary* resultsItem = [self.resultsArray objectAtIndex:indexPath.row];
        NSString* readed = [resultsItem objectForKey:DOC_READ_SIGN];
        return [TableViewFormatUtil formatCell:tableView CellIdentifier:CellIdentifier data:resultsItem unreadSign:![readed isEqualToString:DOC_READED]];
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.resultsArray count])
        return 52;
    else
        return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.resultsArray count]) {
        NSString* url = [ImdUrlPath docSearchUrl:self.queryStr src:self.source pageNo:++self.pageNo pageSize:self.pageSize sort:self.sort];
        NSLog(@"load more %@", url);
        //[self.indicator startAnimating];
        if (self.httpRequest != nil) {
            [self.httpRequest clearDelegatesAndCancel];
        }
        self.httpRequest = [UrlRequest send:url delegate:self];
    } else {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = nil;
        
        DocArticleController* docArticleController = [[DocArticleController alloc] initWithNibName:@"DocArticleController" bundle:nil];
        
        docArticleController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:docArticleController animated:YES];
        
        NSMutableDictionary* resultsItem = [resultsArray objectAtIndex:indexPath.row];
        [resultsItem setObject:DOC_READED forKey:DOC_READ_SIGN];
        
        NSString* externelId = [[resultsArray objectAtIndex:indexPath.row] objectForKey:DOC_EXTERNALID];
        
        docArticleController.source = self.source;
        docArticleController.externalId = externelId;
        NSString* url = [ImdUrlPath docArticleUserOpUrl:externelId];
        docArticleController.httpRequest = [UrlRequest sendWithToken:url delegate:docArticleController];
        docArticleController.view.hidden = YES;
        // docArticleController.scrollView.hidden = YES;
        // Navigation logic may go here. Create and push another view controller.
        
        // Pass the selected object to the new view controller.
    }
}


#pragma mark Asy Request

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    
    self.tableView.hidden = NO;
    
    //Check if results is nil.
    if (resultsJson == nil) {
        NSLog(@"Nil Results");
        return;
    } else {
        //Set Results Count.
        if (self.pageNo == 1) {
            //NSLog(@"%d", [resultsJson objectForKey:DOC_RESULT_COUNT]);
            count = [[resultsJson objectForKey:DOC_RESULT_COUNT] intValue];
            NSLog(@"count = %d, resultsArray = %d", count, self.resultsArray.count);
            UIView* titleView = [[UIView alloc] initWithFrame:CGRectNull];
            [TableViewFormatUtil layoutTitleView:titleView query:self.queryStr resultsNo:[Strings getResultNoText:count]];
            self.navigationItem.titleView = titleView;
            
            self.resultsArray = nil;
            self.resultsArray = [NSMutableArray arrayWithArray:[resultsJson objectForKey:DOC_RESULT_LIST]];
            NSLog(@"after,count = %d, resultsArray = %d", count, self.resultsArray.count);
            
            self.lastRequestCount = self.resultsArray.count;
            [self.tableView reloadData];
        } else {
            NSMutableArray* moreResultsArray = [resultsJson objectForKey:DOC_RESULT_LIST];
            self.lastRequestCount = moreResultsArray.count;
            NSLog(@"load more,count = %d, resultsArray = %d", self.count, moreResultsArray.count);
            
            [self performSelectorOnMainThread:@selector(loadMore:) withObject:moreResultsArray waitUntilDone:NO];
            
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    
    self.tableView.hidden = NO;
    [self.alertView show];
}

-(void) loadMore:(NSMutableArray *)data
{
    for (int i = 0; i < [data count]; i++) {
        [self.resultsArray addObject:[data objectAtIndex:i]];
    }
    
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[data count]];
    for (int index = 0; index < [data count]; ++index){
        NSIndexPath* newPath = [NSIndexPath indexPathForRow:[self.resultsArray indexOfObject:[data objectAtIndex:index]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
}

-(void) popBack{
}
@end
