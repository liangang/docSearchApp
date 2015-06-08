//
//  SearchResults.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-21.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "SearchResults.h"
#import "DocArticleController.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "Strings.h"
#import "TableViewFormatUtil.h"
#import "Util.h"
#import "ImageViews.h"
#import "IPhoneHeader.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "imdSearchAppDelegate_iPhone.h"
#import "MyDatabase.h"

@implementation SearchResults

@synthesize resultsArray;
@synthesize queryStr;
@synthesize pageNo, pageSize, sort, source;
@synthesize count, lastRequestCount;
@synthesize indicator, alertView;
@synthesize tableView = _tableView;
@synthesize noResultsView;
@synthesize httpRequest = _httpRequest;
@synthesize sortPicker = _sortPicker;
@synthesize pickerViewArray = _pickerViewArray;
@synthesize pickerSortArray = _pickerSortArray;
@synthesize sortAS = _sortAS;
@synthesize pickerSelected = _pickerSelected;



-(void) dealloc
{
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.pageNo = 1;
        self.pageSize = 20;
        self.sort = 5;
        self.lastRequestCount = 0;
        
        alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
        [TableViewFormatUtil backBarButtonItemInfoModify:self.navigationItem];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SEARCH_SORT_DEFAULT style:UIBarButtonItemStylePlain target:self action:@selector(sortSearch:)];
       
        self.pickerSelected = 0;
    }
    return self;
}


// returns the number of 'columns' to display.
#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}


#pragma mark -
#pragma mark UIPickerViewDataSource
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    label.text = [self.pickerViewArray objectAtIndex:row];
    label.font = [UIFont fontWithName:FONT_BOLD size:FONT_4];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerViewArray count];
}

-(void) sortSearch:(id)sender
{
    //[self.sortAS showFromTabBar:self.tabBarController.tabBar];
  
  
  if (IOS8) {
    CGFloat pickerViewYposition = self.view.frame.size.height - self.pickerView.frame.size.height;
    [UIView animateWithDuration:0.5f
                     animations:^{
                       [self.pickerView setFrame:CGRectMake(self.pickerView.frame.origin.x,
                                                            pickerViewYposition,
                                                            self.pickerView.frame.size.width,
                                                            self.pickerView.frame.size.height)];
                     }
                     completion:nil];
  }else
  {
    [self.sortAS showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    [self.sortAS setBounds:CGRectMake(0, 0, 320, 480)];
  }
}
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  NSLog(@"wwwwwww");
}

- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
                                   screenRect.origin.y + screenRect.size.height - size.height,
                                   size.width,
                                   size.height);
	return pickerRect;
}

-(void) updateSortPicker:(NSInteger)selected
{
    [self.sortPicker selectRow:selected inComponent:0 animated:NO];
    
    //Update right bar button.
    [TableViewFormatUtil setCustomBarButtonTitle:self.navigationItem.rightBarButtonItem title:[self.pickerViewArray objectAtIndex:selected]];
}

-(void)doSortSearch:(UIPickerView*) sortPicker
{
    self.pickerSelected = [self.sortPicker selectedRowInComponent:0];
    NSInteger sortInt = [[self.pickerSortArray objectAtIndex:self.pickerSelected] integerValue];
    [ImdAppBehavior sortLog:[Util getUsername] MACAddr:[Util getMacAddress] sortName:[self.pickerViewArray objectAtIndex:self.pickerSelected]];
  
  [self cancelSortSearch:sortPicker];
  
    
    //Only if sort changed.
    if (self.sort != sortInt) {
        self.sort = sortInt;
        self.pageNo = 1;
        NSString* url = [ImdUrlPath docSearchUrl:self.queryStr src:self.source pageNo:self.pageNo pageSize:self.pageSize sort:sortInt];
      
      self.navigationItem.rightBarButtonItem.title = [self.pickerViewArray objectAtIndex:self.pickerSelected];
        //[TableViewFormatUtil setCustomBarButtonTitle:self.navigationItem.rightBarButtonItem title:[self.pickerViewArray objectAtIndex:self.pickerSelected]];
        if (self.httpRequest != nil) {
            [self.httpRequest clearDelegatesAndCancel];
        }
        self.httpRequest = [UrlRequest send:url delegate:self];
        self.view.hidden = YES;
    }
}

-(void)cancelSortSearch:(UIPickerView*) sortPicker
{
  if (IOS8) {
    CGFloat pickerViewYpositionHidden = self.view.frame.size.height + self.pickerView.frame.size.height;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                       [self.pickerView setFrame:CGRectMake(self.pickerView.frame.origin.x,
                                                            pickerViewYpositionHidden,
                                                            self.pickerView.frame.size.width,
                                                            self.pickerView.frame.size.height)];
                     }
                     completion:nil];
  }else
    [self.sortAS dismissWithClickedButtonIndex:0 animated:YES];
  [self updateSortPicker:0];
}


-(void) createSortPicker
{
    self.pickerViewArray = [NSArray arrayWithObjects:
                            SEARCH_SORT_DEFAULT,
                            SEARCH_SORT_DATE,
                            SEARCH_SORT_JOURNALS,
                            nil];
    self.pickerSortArray = [NSArray arrayWithObjects:
                            @"5",
                            @"1",
                            @"3",
                            nil];
    
    
    _sortPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    
    [_sortPicker setFrame:CGRectMake(0, 40, 320, 216)];
    _sortPicker.showsSelectionIndicator = YES;
    
    _sortPicker.delegate = self;
    _sortPicker.dataSource = self;
  
  if (IOS8) {
    if (!self.pickerView) {
      self.pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 320, 280)];
    } else {
      [self.pickerView setHidden:NO];
    }
    [_sortPicker setFrame:CGRectMake(0, 35, _sortPicker.frame.size.width, _sortPicker.frame.size.height)];
    
    CGFloat pickerViewYpositionHidden = self.view.frame.size.height + self.pickerView.frame.size.height;
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:EDIT_DONE_CN]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = RGBCOLOR(34, 96, 221);
    [closeButton addTarget:self action:@selector(doSortSearch:) forControlEvents:UIControlEventValueChanged];
    [self.pickerView addSubview:closeButton];
    
    UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:TEXT_CANCEL]];
    cancelButton.momentary = YES;
    cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
    cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
    cancelButton.tintColor = [UIColor blackColor];
    [cancelButton addTarget:self action:@selector(cancelSortSearch:) forControlEvents:UIControlEventValueChanged];
    [self.pickerView addSubview:cancelButton];
    
    [self.pickerView setFrame:CGRectMake(self.pickerView.frame.origin.x,
                                         pickerViewYpositionHidden,
                                         self.pickerView.frame.size.width,
                                         self.pickerView.frame.size.height)];
    [self.pickerView setBackgroundColor:[UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:0.99]];
      //[self.pickerView addSubview:controlToolbar];
    [self.pickerView addSubview:_sortPicker];
    [_sortPicker setHidden:NO];
    [self.view addSubview:self.pickerView];
  }else
  {
    self.sortAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:EDIT_DONE_CN]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = RGBCOLOR(34, 96, 221);
    [closeButton addTarget:self action:@selector(doSortSearch:) forControlEvents:UIControlEventValueChanged];
    [_sortAS addSubview:closeButton];
    
    UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:TEXT_CANCEL]];
    cancelButton.momentary = YES;
    cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
    cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
    cancelButton.tintColor = [UIColor blackColor];
    [cancelButton addTarget:self action:@selector(cancelSortSearch:) forControlEvents:UIControlEventValueChanged];
    [_sortAS addSubview:cancelButton];
    
    [_sortAS addSubview:_sortPicker];
    [_sortAS setBounds:CGRectMake(0, 0, 320, 480)];
  }

//    _sortAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//    
//    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:EDIT_DONE_CN]];
//    closeButton.momentary = YES;
//    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
//    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
//    closeButton.tintColor = RGBCOLOR(34, 96, 221);
//    [closeButton addTarget:self action:@selector(doSortSearch:) forControlEvents:UIControlEventValueChanged];
//    [_sortAS addSubview:closeButton];
//    
//    UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:TEXT_CANCEL]];
//    cancelButton.momentary = YES;
//    cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
//    cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
//    cancelButton.tintColor = [UIColor blackColor];
//    [cancelButton addTarget:self action:@selector(cancelSortSearch:) forControlEvents:UIControlEventValueChanged];
//    [_sortAS addSubview:cancelButton];
//    
//    [self.sortAS addSubview:self.sortPicker];
//    [self.sortAS setBounds:CGRectMake(0, 0, 320, 480)];
}


-(void) popBack:(id) sender
{
    self.tableView.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
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
    self.resultsArray = nil;
    
    [TableViewFormatUtil setTableViewBackGround:self.tableView image:IMG_BG_CONTENTSBACKGROUDN];
    [self createSortPicker];
    if (IOS7) {
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 54);
    }
    
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
    imdSearchAppDelegate_iPhone *appDelegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    appDelegate.imageView.hidden = YES;
    appDelegate.SearchimageView.hidden = NO;
    appDelegate.FullTextimageView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    //self.sortPicker.hidden = YES;
    //self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.view.hidden = YES;
  
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.view.hidden = NO;
  if (self.navigationController.viewControllers.count < 2) {
    [self.navigationItem.rightBarButtonItem setTitle:SEARCH_SORT_DEFAULT];
  }
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
    if (tableView == self.tableView) {
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
    
    if (indexPath.row == [self.resultsArray count]) {
        if (self.lastRequestCount >= 20) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadMore"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadMore"];
                
                UIButton* loadMoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 13, 299, 35)];
                [loadMoreBtn setBackgroundColor:RGBCOLOR(249, 60, 3)];
                [loadMoreBtn setTitle:@"加载更多文献" forState:UIControlStateNormal];
                loadMoreBtn.layer.masksToBounds = YES;
                loadMoreBtn.layer.cornerRadius = 5;
                loadMoreBtn.layer.borderColor = [UIColor clearColor].CGColor;
//                [loadMoreBtn setBackgroundImage:[UIImage imageNamed:IMG_BTN_LOADMORE_NORMAL] forState:UIControlStateNormal];
//                [loadMoreBtn setBackgroundImage:[UIImage imageNamed:IMG_BTN_LOADMORE_HIGHLIGHT] forState:UIControlStateHighlighted];
//                [loadMoreBtn setBackgroundImage:[UIImage imageNamed:IMG_BTN_LOADMORE_HIGHLIGHT] forState:UIControlStateSelected];
                [cell setOpaque:NO];
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell addSubview:loadMoreBtn];
                [cell sendSubviewToBack:loadMoreBtn];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIActivityIndicatorView* indicatorMore = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                indicatorMore.hidesWhenStopped = YES;
                [indicatorMore setFrame:CGRectMake(90, 20, indicatorMore.frame.size.width, indicatorMore.frame.size.height)];
                [cell.contentView addSubview:indicatorMore];
            }
            for(UIView* v in cell.contentView.subviews) {
                if ([v isKindOfClass:[UIActivityIndicatorView class]]) {
                    [(UIActivityIndicatorView*)v stopAnimating];
                }
            }
            return cell;
        } else {
            UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"resultsEnd"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    } else {
        NSDictionary* resultsItem = [self.resultsArray objectAtIndex:indexPath.row];
        NSString* readed = [resultsItem objectForKey:DOC_READ_SIGN];
        UITableViewCell* cell = [TableViewFormatUtil formatCell:tableView CellIdentifier:CellIdentifier data:resultsItem unreadSign:![readed isEqualToString:DOC_READED]];
        return cell;
    }
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.lastRequestCount >= 20 && indexPath.row == [self.resultsArray count])
        return 61;
    else
        return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.resultsArray count]) {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        
        for(UIView* v in cell.contentView.subviews) {
            if ([v isKindOfClass:[UIActivityIndicatorView class]]) {
                [(UIActivityIndicatorView*)v startAnimating];
            }
        }
        
        NSString* url = [ImdUrlPath docSearchUrl:self.queryStr src:self.source pageNo:++self.pageNo pageSize:self.pageSize sort:self.sort];
        NSLog(@"load more %@", url);
        
        if (self.httpRequest != nil) {
            [self.httpRequest clearDelegatesAndCancel];
        }
        self.httpRequest = [UrlRequest send:url delegate:self];
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    } else {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = nil;
        
        DocArticleController* docArticleController = [[DocArticleController alloc] initWithNibName:@"DocArticleController" bundle:nil];
        
        docArticleController.hidesBottomBarWhenPushed = YES;
        
        
        NSMutableDictionary* resultsItem = [resultsArray objectAtIndex:indexPath.row];
        [resultsItem setObject:DOC_READED forKey:DOC_READ_SIGN];
        
        NSString* externelId = [[resultsArray objectAtIndex:indexPath.row] objectForKey:DOC_EXTERNALID];
        
        docArticleController.source = self.source;
        docArticleController.externalId = externelId;
        docArticleController.isSearchList = NO;
        NSString* url = [ImdUrlPath docArticleUserOpUrl:externelId];
      if (![MyDatabase isSelectId:externelId ismgr:IMD_Mydoc]) {
        docArticleController.httpRequest = [UrlRequest sendWithToken:url delegate:docArticleController];
      }else {
        docArticleController.view.hidden = YES;
        docArticleController.scrollView.hidden = YES;
        docArticleController.resultsJson = [MyDatabase readDocData:IMD_Mydoc externalId:docArticleController.externalId];
      }

        //docArticleController.httpRequest = [UrlRequest sendWithToken:url delegate:docArticleController];
      
        [self.navigationController pushViewController:docArticleController animated:YES];
      
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}


#pragma mark Asy Request
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%d",[request responseStatusCode]);
    NSLog(@"%@",[request responseString]);
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    
    //Check if results is nil.
    if (resultsJson == nil) {
        NSLog(@"Nil Results");
        return;
    } else {
        //Set Results Count.
        if (self.pageNo == 1) {
            count = [[resultsJson objectForKey:DOC_RESULT_COUNT] intValue];
            NSLog(@"count = %d, resultsArray = %d", count, self.resultsArray.count);
            
            UIView* titleView = [[UIView alloc] initWithFrame:CGRectNull];
            [TableViewFormatUtil layoutTitleView:titleView query:self.queryStr resultsNo:[Strings getResultNoText:count]];
            self.navigationItem.titleView = titleView;
            
            [self.resultsArray removeAllObjects];
            self.resultsArray = nil;
            [self.tableView reloadData];
            
            self.resultsArray = [NSMutableArray arrayWithArray:[resultsJson objectForKey:DOC_RESULT_LIST]];
            
            NSLog(@"after,count = %d, resultsArray = %d", count, self.resultsArray.count);
            self.lastRequestCount = self.resultsArray.count;
            if (self.resultsArray.count > 0) {
                self.noResultsView.hidden = YES;
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            } else {
                self.noResultsView.hidden = NO;
                self.tableView.hidden = YES;
            }
        } else {
            NSMutableArray* moreResultsArray = [resultsJson objectForKey:DOC_RESULT_LIST];
            self.lastRequestCount = moreResultsArray.count;
            NSLog(@"load more,count = %d, resultsArray = %d", self.count, moreResultsArray.count);
            
            [self performSelectorOnMainThread:@selector(loadMore:) withObject:moreResultsArray waitUntilDone:NO];
            
        }
    }
    self.view.hidden = NO;
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
  if ([request.error code] == ASIRequestTimedOutErrorType) {
    self.alertView.message = REQUEST_TIMEOUT_MESSAGE;
    self.alertView.title = HINT_TEXT;
  }
    self.view.hidden = NO;
    self.tableView.hidden = YES;
    self.noResultsView.hidden = NO;
    [self.alertView show];
}

-(void) popBack{
    
}

-(void) loadMore:(NSMutableArray *)data
{
    [ImdAppBehavior sortLog:[Util getUsername] MACAddr:[Util getMacAddress] sortName:@"点击显示更多文献"];
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
@end
