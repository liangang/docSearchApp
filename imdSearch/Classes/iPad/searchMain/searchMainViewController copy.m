//
//  searchMainViewController.m
//  imdSearch
//
//  Created by 8fox on 9/27/11.
//  Copyright 2011 i-md.com. All rights reserved.
//

#import "searchMainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest.h"
#import "imdSearcher.h"
#import "JSON.h"
#import "Util.h"
#import "advancedQueryItemsCell.h"
#import "advancedYearItemsCell.h"
#import "filterTableController.h"
#import "yearTableController.h"

#import "settingViewController.h"

#import "lanSelectViewController.h"
#import "searchHistory.h"

#import "catalogSelectViewController.h"
#import "sortSelectViewController.h"
#import "shareSelectViewController.h"

#import "imdSearchAppDelegate.h"

@implementation searchMainViewController

@synthesize sideActionsView,listSearchView,listFavView,listDownloadView,resultAreaView,detailView;
@synthesize advanedView,searchResultList,searchedResult,resultReadingStatus;

@synthesize titleLeftView,titleActionsView,searchbarView,searchListView,searchResultView,searchResultCoverView;
@synthesize detailTitle,detailaffiliations,detailJournalAndDate,detailAuthors,detailAbstractText,detailKeyword,AbstractTextScrollView;

@synthesize loadingIndicator,loadingLabel,errorLabel;
@synthesize advSearchList,favList,downList,langSelButton;
@synthesize sideActionSearchButton,sideActionFavoriteButton,sideActionDownloadedButton,sideActionSettingsButton,sideActionHelpButton;
@synthesize backButton,favoriteSaveButton,searchTitle;
@synthesize currentKeybordHolder;
@synthesize selectedDotFav,selectedDotSearch,selectedDotDownload;
@synthesize mainLoginViewController,downloadArrays,fullTextDownloader,switchButton,pdfView,prePdfView,nextPdfView,pageNo,startCover;
@synthesize favArrays,favEditButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        
        
        
        
    }
    return self;
}

- (void)dealloc
{
    
    self.searchResultList =nil;
    self.sideActionsView =nil;
    self.listSearchView =nil;
    self.resultAreaView =nil;
    
    self.listFavView =nil;
    self.listDownloadView =nil;
    
    self.advanedView =nil;
    
    self.detailJournalAndDate =nil;
    self.detailTitle =nil;
    self.detailAuthors =nil;
    self.detailaffiliations =nil;
    self.detailAbstractText =nil;
    self.detailKeyword =nil;
    
    self.AbstractTextScrollView =nil;
    
    self.titleLeftView =nil;
    self.titleActionsView =nil;
    
    self.searchbarView =nil;
    self.searchListView =nil;
    self.searchResultView =nil;
    self.searchResultCoverView =nil;
    
    self.loadingIndicator =nil;
    self.loadingLabel =nil;
    
    self.searchedResult =nil;
    self.resultReadingStatus =nil;
    
    self.advSearchList =nil;
    self.favList =nil;
    self.downList =nil;
    
    self.langSelButton =nil;
    
    
    self.sideActionSearchButton =nil;
    self.sideActionFavoriteButton =nil;
    self.sideActionDownloadedButton =nil;
    self.sideActionSettingsButton =nil;
    self.sideActionHelpButton =nil;
    
    self.backButton =nil;
    self.favoriteSaveButton =nil;
    self.searchTitle =nil;
    
    self.currentKeybordHolder =nil;
    
    self.selectedDotSearch =nil;
    self.selectedDotFav =nil;
    self.selectedDotDownload =nil;
    self.mainLoginViewController =nil;
    
    self.downloadArrays =nil;
    self.fullTextDownloader =nil;
    
    self.detailView =nil;
    self.pdfView =nil;
    self.switchButton =nil;
    self.pageNo =nil;
    self.startCover =nil;
    
    self.favArrays =nil;

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
    
    inFullText = NO;
    self.pageNo.hidden =YES;
    [searchHistory clearHistory];
    
    searchResultList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.searchListView.frame.size.width, self.searchListView.frame.size.height) style:UITableViewStylePlain];
    [searchResultList setDelegate:self];
    [searchResultList setDataSource:self];
    [searchResultList setBackgroundColor:[UIColor clearColor]];
    //searchResultList.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.searchListView.frame.size.width, 1)];
    //[searchResultList setSeparatorColor:[UIColor darkGrayColor]];
    
    [self.searchListView addSubview:searchResultList];
    
    //swipes
    UISwipeGestureRecognizer *swipeGesture = nil;
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(advSearchHandleAllSwipes:)];
    
	swipeGesture.cancelsTouchesInView = NO; 
    swipeGesture.delaysTouchesEnded = NO; 
    swipeGesture.delegate = self;
	swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
	[searchResultList addGestureRecognizer:swipeGesture]; 
    [swipeGesture release];
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(advSearchHandleAllSwipes:)];
    
	swipeGesture.cancelsTouchesInView = NO; 
    swipeGesture.delaysTouchesEnded = NO; 
    swipeGesture.delegate = self;
	swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.advSearchList addGestureRecognizer:swipeGesture]; 
    [swipeGesture release]; 
    
    
    searchBar = [[mySearchBar alloc] initWithFrame:CGRectMake(2,6,self.searchbarView
                                                              .frame.size.width,self.searchbarView.frame.size.height)];
   
    
    
    //remove mysearch bg;
    UIView* segment = [searchBar.subviews objectAtIndex:0];
    [segment removeFromSuperview];
    searchBar.delegate = self;
    searchBar.placeholder = @"文献搜索";
    
    [self.searchbarView addSubview:searchBar];
    
    
    
    self.langSelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.langSelButton.frame = CGRectMake(7, 15, 46, 28);
    self.langSelButton.backgroundColor = [UIColor clearColor];
    
    
    if(currentSearchLanguage == SEARCH_MODE_CN)   
    { 
        
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-cn-normal"] forState:UIControlStateNormal];
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-cn-highlight.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-en-normal"] forState:UIControlStateNormal];
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-en-highlight.png"] forState:UIControlStateHighlighted]; 
    }   
    
    //[self.langSelButton addTarget:self action:@selector(changeLanguage:) forControlEvents:UIControlEventTouchDown];
    
    [self.langSelButton addTarget:self action:@selector(popLanguageSelection:) forControlEvents:UIControlEventTouchDown];
    [self.searchbarView addSubview:langSelButton];
    
    self.searchResultCoverView.hidden = NO;
    
    //self.sideActionsView.layer.borderColor = [UIColor blueColor].CGColor;
    //self.sideActionsView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.sideActionsView.bounds].CGPath;
    
    //shadows and borders
    
    //sideActionView
    self.sideActionsView.layer.cornerRadius = 2;
    
    //self.sideActionsView.layer.borderColor = [UIColor blackColor].CGColor;
    //self.sideActionsView.layer.borderWidth = 1;
    
    self.sideActionsView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.sideActionsView.layer.shadowOpacity = 1.0;
    self.sideActionsView.layer.shadowRadius = 5.0;
    self.sideActionsView.layer.shadowOffset = CGSizeMake(0, 4);

    //listSearchView
    self.listSearchView.layer.cornerRadius = 2;
    
    //self.listSearchView.layer.borderColor = [UIColor blackColor].CGColor;
    //self.listSearchView.layer.borderWidth = 0.3;
    
    self.listSearchView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.listSearchView.layer.shadowOpacity = 1.0;
    self.listSearchView.layer.shadowRadius = 5.0;
    self.listSearchView.layer.shadowOffset = CGSizeMake(0, 4);
    
    
    
    //title view
    self.titleLeftView.layer.cornerRadius = 2;
    
    //self.titleLeftView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    //self.titleLeftView.layer.borderWidth = 0.3;
    
    self.titleLeftView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.titleLeftView.layer.shadowOpacity = 1.0;
    self.titleLeftView.layer.shadowRadius = 3.0;
    self.titleLeftView.layer.shadowOffset = CGSizeMake(0, -1);
    

    self.titleActionsView.layer.cornerRadius = 2;
    
    //self.titleActionsView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    //self.titleActionsView.layer.borderWidth = 0.3;
    
    self.titleActionsView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.titleActionsView.layer.shadowOpacity = 1.0;
    self.titleActionsView.layer.shadowRadius = 3.0;
    self.titleActionsView.layer.shadowOffset = CGSizeMake(0, -1);

    
    //self.searchbarView.layer.borderWidth = 1;
    //self.searchbarView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    //self.searchbarView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    //self.searchbarView.layer.shadowOpacity = 1.0;
    //self.searchbarView.layer.shadowRadius = 3.0;
    //self.searchbarView.layer.shadowOffset = CGSizeMake(0, -1);
    
    
    
    
    //remove extra lines of adv table
    UIView *footer =
    [[UIView alloc] initWithFrame:CGRectZero];
    self.advSearchList.tableFooterView = footer;
    [footer release];
    
    
    
    displayState = DISPLAY_STATE_FRONTPAGE;
    self.backButton.hidden = YES;
    self.favoriteSaveButton.hidden = YES;
    self.searchTitle.text =@"文 献 搜 索"; 
    
    displayMax = 20;
    
    
    refreshWay = REFRESHWAY_INCREASEWAY;
    newSearchStart = YES;
    
    currentSearchLanguage = SEARCH_MODE_CN;
    [[NSUserDefaults standardUserDefaults] setInteger:currentSearchLanguage forKey:@"searchLan"];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
    
    currentPage =1;
    fetchingPage =1;
    
    
    currentActionSelected = SIDEACTION_SEARCH;
    [self refreshSideActionButtons];
    
    advancedQueryItemCount =1;
    advancedQueryItemCountMax =5;
    
    filterItemData = [self readPListBundleFile:@"searchFilters"];
    
    filterNames = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
    filterValues = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
    filterOperations = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
    
    for(int i =0; i<advancedQueryItemCountMax ;i++)
    {
        if(currentSearchLanguage == SEARCH_MODE_CN)
        {
            NSArray* TextCN = [filterItemData objectForKey:@"CN_TEXT"];
            [filterNames addObject:[TextCN objectAtIndex:0]];
        }
        else
        {
            NSArray* TextEN = [filterItemData objectForKey:@"EN_TEXT"];
            [filterNames addObject:[TextEN objectAtIndex:0]];
        }   
        
        [filterValues addObject:@""];
        [filterOperations addObject:[NSNumber numberWithInt:OPERATION_AND]];
    }

    
    advViewAnimating = NO;
    newAdvSearch = YES;
    coreJournalOn =NO;
    
    minYear = @"";
    maxYear = @"";
    sortMethod =@"5";
    
    
    yearTableController *content = [[yearTableController alloc] initWithNibName:@"yearTableController" bundle:nil];
    
    yearPopoverController = [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    
    yearPopoverController.popoverContentSize = CGSizeMake(320., 480.);
    yearPopoverController.delegate = self;
    [content release];
    
    currentDetailsFontSizeOffset = FONT_OFFSET_ZERO;
    
    //no poller for this 
    //poller =[[msgPoller alloc] init];
    //poller.delegate = self;
    //[poller fetchToken];
    
    //[searchHistory saveSearchHistory:@"单片复方"];
    //[searchHistory saveSearchHistory:@"高血压"];
    //[searchHistory saveSearchHistory:@"曲莱"];
    //[searchHistory saveSearchHistory:@"密固达"];
    //[searchHistory saveSearchHistory:@"Exforge"];
    //[searchHistory saveSearchHistory:@"代文 高血压"];
    
    downloadArrays = [[NSUserDefaults standardUserDefaults] objectForKey:@"downloadArrays"];
    
    if(downloadArrays == nil)
    {
        downloadArrays =[[NSMutableArray alloc] initWithCapacity:20];
    }   
    
    
    self.detailView.scrollsToTop = NO;
	self.detailView.directionalLockEnabled = YES;
	self.detailView.showsVerticalScrollIndicator = NO;
	self.detailView.showsHorizontalScrollIndicator = NO;
	self.detailView.contentMode = UIViewContentModeRedraw;
	self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.detailView.minimumZoomScale = 0.5f;
    self.detailView.maximumZoomScale = 3.0f;
	self.detailView.contentSize = self.detailView.bounds.size;
	self.detailView.backgroundColor = [UIColor clearColor];
	self.detailView.delegate = self;
    
    
    //gesture recognition
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneTouch:)];
	tapGesture.cancelsTouchesInView = NO; 
    tapGesture.delaysTouchesEnded = NO; 
    tapGesture.delegate = self;
	tapGesture.numberOfTouchesRequired = 1; 
    tapGesture.numberOfTapsRequired = 2; // One finger double tap
	[self.detailView addGestureRecognizer:tapGesture]; 
    [tapGesture release];
    
    UITapGestureRecognizer* tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneTouch:)];
	tapGesture2.cancelsTouchesInView = NO; 
    tapGesture2.delaysTouchesEnded = NO; 
    tapGesture2.delegate = self;
	tapGesture2.numberOfTouchesRequired = 1; 
    tapGesture2.numberOfTapsRequired = 1; // One finger double tap
	[self.detailView addGestureRecognizer:tapGesture2]; 
    [tapGesture2 release];
    
    
    //self.startCover.hidden = YES;
    
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
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - swipe gesture
-(void)advSearchHandleAllSwipes:(UISwipeGestureRecognizer *)recognizer
{
    if( advViewAnimating) return;
	
    if (recognizer.direction & UISwipeGestureRecognizerDirectionRight)
    {
        [self advViewShow];
    }
    
    if (recognizer.direction & UISwipeGestureRecognizerDirectionLeft)
    {
        [self advViewHide];        
    }

        
}        

#pragma mark - talbe delegate & datasource

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
 { 
     if (tableView == self.searchResultList) 
     {  
      if(indexPath.row == loadingRow -1)
      {
         NSLog(@"refresh at this %d row",loadingRow);
         
         if(currentPage+1<=totalPages)
         {
        
            [self performSelector:@selector(loadingNextBlock:) withObject:nil afterDelay:1.0f]; 
             // fetchingPage = currentPage +1;
             // [imdSearcher simpleSearch:searchBar.text Page:fetchingPage Lan:SEARCH_MODE_CN Delegate:self];
         }
      }
     }
 
 }




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{   
    
    
    if (tableView == self.searchResultList) 
    {
        
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		UIView* bgView = [[[UIView alloc] init] autorelease];
		[bgView setBackgroundColor:[UIColor colorWithWhite:2 alpha:0.2]];
		[cell setSelectedBackgroundView:bgView];
    }
    
    // Configure the cell...
    
    if(displayState == DISPLAY_STATE_RESULTS)
    {
        //[[cell subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
        for (UIView *view in [cell subviews]) {
            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIActivityIndicatorView class]] || [view isKindOfClass:[UIImageView class]])
            [view removeFromSuperview];
        }
        
        
        NSArray* results =[self.searchedResult objectForKey:@"results"];
        NSDictionary* result;
        
        if(results == (id)[NSNull null]  || [results count] ==0)
        {
            cell.textLabel.text = @"没有数据。";
            return  cell;
        }
        else
        {

            
            int rowNo = indexPath.row;
            if(rowNo == loadingRow-1 )
            {
                
                UILabel* loading = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 200, 40)];
                loading.text = @"正在读取...";
                loading.backgroundColor = [UIColor clearColor];
                [cell addSubview:loading];
                [loading release];
                
                UIActivityIndicatorView* loadingSign = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [loadingSign startAnimating];
               
               
                loadingSign.center = CGPointMake(20, 40);
                loadingSign.hidesWhenStopped = NO;
                
                [cell addSubview:loadingSign];
                [loadingSign release];
                
                return cell;
            }
            
            result =[results objectAtIndex:rowNo];
                       
             NSString* rawTitleString = [result objectForKey:@"title"];
             NSString* titleString = [Util replaceEM:rawTitleString LeftMark:@"" RightMark:@""]; 

            CGSize sizeTitle = [titleString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0] constrainedToSize:CGSizeMake(316, 60) lineBreakMode:UILineBreakModeWordWrap];
                                
            UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,8,sizeTitle.width,sizeTitle.height)];
                    
             titleLabel.text = titleString;
             titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
             titleLabel.numberOfLines = 0;
             titleLabel.lineBreakMode = UILineBreakModeWordWrap;
             titleLabel.backgroundColor = [UIColor clearColor]; 
            
             [cell addSubview:titleLabel];
             [titleLabel release];
            
             NSArray* authors =[result objectForKey:@"author"];
             NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
            
             for(int i =0; i<[authors count];i++) 
             {
                if(![s isEqualToString:@""]) 
                    [s appendString:@" ,"];
                
                NSString* aStr = [authors objectAtIndex:i];
                aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];     
                [s appendString:aStr];
             }   
        
            UILabel* authorLable = [[UILabel alloc] initWithFrame:CGRectMake(16,82,316,48)];
            
            authorLable.text = s;
            authorLable.font = [UIFont fontWithName:@"Helvetica" size:14.0];
            
            authorLable.numberOfLines = 0; 
            authorLable.backgroundColor = [UIColor clearColor];   
            [cell addSubview:authorLable];
            [authorLable release];    
            [s release];   
            
            s = [[NSMutableString alloc] initWithFormat:@""];
            
            NSString* journal =[result objectForKey:@"journal"];
            
            if(journal == (id)[NSNull null] || journal.length == 0 )
            { 
                [s appendString:@""];
            }
            else
            {
                journal = [Util replaceEM:journal LeftMark:@"" RightMark:@""];     
                [s appendString:journal];
            }
            
            if(![s isEqualToString:@""]) [s appendString:@" ,"];
            
            NSString* publishDate =[result objectForKey:@"pubDate"];
            if(publishDate == (id)[NSNull null] || publishDate.length == 0 )
            { 
                [s appendString:@""];
            }
            else
            {
                publishDate = [Util replaceEM:publishDate LeftMark:@"" RightMark:@""];     
                
                [s appendString:publishDate];
            }
            
            UILabel* journalAndDateLabel= [[UILabel alloc] initWithFrame:CGRectMake(16,122,316, 48)];
            
            journalAndDateLabel.text = s;
            journalAndDateLabel.numberOfLines = 0;  
            //journalAndDateLabel.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];    
            journalAndDateLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0] ; 
            journalAndDateLabel.backgroundColor = [UIColor clearColor];    
            
            [cell addSubview:journalAndDateLabel];
            [journalAndDateLabel release];
        
            [s release];
              
             cell.textLabel.text=@"";
            
        }
        if(currentDisplayingRow == indexPath.row)
        {
        
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-results-selected-document"]] autorelease];
            
             [self.resultReadingStatus replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        }
        else
        {
            cell.backgroundView = nil;
            
            BOOL readFlag = [[resultReadingStatus objectAtIndex:indexPath.row] boolValue];
            
            if(!readFlag)
            {
                UIImageView* dotImage  =[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-results-unread-dot"]]autorelease];
                dotImage.frame = CGRectMake(4, 15,9, 9);
                
                [cell addSubview:dotImage];
            
            
            }   
            
            
        }    
        
        
        
        
        return  cell;
    
    }
    else if(displayState == DISPLAY_STATE_SUGGESTION)
    {
        
        for (UIView *view in [cell subviews]) {
            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIActivityIndicatorView class]] || [view isKindOfClass:[UIImageView class]])
                [view removeFromSuperview];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [suggestionArrays objectAtIndex:indexPath.row]];
        
        cell.backgroundColor = [UIColor clearColor];
        
       
        if(indexPath.row != currentSelectedSuggestion)
        {
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-autoSugesstion-double-splitLIne"]] autorelease];
        }
        else
        {
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-autoSugesstion-selected-item"]] autorelease];
        
        }    
        
        [cell.textLabel setHighlightedTextColor:[UIColor blackColor]];

        return cell;
    }
    else if(displayState == DISPLAY_STATE_FRONTPAGE)
    {
        
        for (UIView *view in [cell subviews]) {
            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIActivityIndicatorView class]] || [view isKindOfClass:[UIImageView class]])
                [view removeFromSuperview];
        }
        
        if(indexPath.section == 0)
        {
            
            int count =[searchHistory getHistoryCount];
            if(count ==0)
            {
               cell.textLabel.text = @"无检索历史";
               cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }   
            else
            {
                int p = (MAX_HISTORY+[searchHistory getAvailbleHistoryPos]-1-indexPath.row)%MAX_HISTORY;
                
                
                cell.textLabel.text =[searchHistory getSavedSearchHistory:p];
            }    
            
            
        } 
        else if(indexPath.section == 1)
        {
            cell.textLabel.text = @"请先登录";        
        }    
    
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
         [cell.textLabel setHighlightedTextColor:[UIColor blackColor]]; 
    }    
    else
    {
        
        for (UIView *view in [cell subviews]) {
            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIActivityIndicatorView class]] || [view isKindOfClass:[UIImageView class]])
                [view removeFromSuperview];
        }

        
        cell.textLabel.text = [NSString stringWithFormat:@"item %d", indexPath.row +1];
    }
        
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.textLabel setHighlightedTextColor:[UIColor blackColor]];
    
    
    return cell;
    }
    else if(tableView == self.advSearchList)
    {
       
        
        
        if(indexPath.section == 0)
        {  
            static NSString *QueryItemTableIdentifier = @"advancedQueryItem";
            
            advancedQueryItemsCell *cell = (advancedQueryItemsCell*)[tableView dequeueReusableCellWithIdentifier: QueryItemTableIdentifier];
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"advancedTableCell" owner:self options:nil];
            
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[advancedQueryItemsCell class]]) {
                    cell = (advancedQueryItemsCell*)oneObject;
                }
            if (cell == nil)
            { cell = [[[advancedQueryItemsCell alloc]
                       initWithStyle:UITableViewCellStyleDefault reuseIdentifier:QueryItemTableIdentifier] autorelease];
            }
                
            cell.conditionText.text = [filterValues objectAtIndex:indexPath.row];
            
            
            
            cell.conditionText.delegate = self;
            
            NSString* s =[filterNames objectAtIndex:indexPath.row];
            NSLog(@"s= %@",s);
            
            [cell.filterButton setTitle:[filterNames objectAtIndex:indexPath.row] forState:UIControlStateNormal];
            
            
            cell.selectedOperation=[[filterOperations objectAtIndex:indexPath.row] intValue];
            
            [cell displayOperations];
            
            
            cell.delegate = self;
            cell.tag = indexPath.row;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                   
            return cell;
        }
        
        if(indexPath.section == 1)
        {
            
            static NSString *advCellIdentifier = @"advCellAddFields";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:advCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:advCellIdentifier] autorelease];
               
            }
            
            for (UIView *view in [cell subviews]) {
                if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]])
                    [view removeFromSuperview];
            }

            
            
            UIButton* addButton =[UIButton buttonWithType:UIButtonTypeCustom];
            [addButton setImage:[UIImage imageNamed:@"btn-addField-normal"] forState:UIControlStateNormal];
            [addButton setImage:[UIImage imageNamed:@"btn-addField-highlight"] forState:UIControlStateHighlighted];
            
            [addButton addTarget:self action:@selector(addQueryItem:) forControlEvents:UIControlEventTouchUpInside];
            

            
            addButton.frame = CGRectMake(20, 7, 36, 36);  
            [cell addSubview:addButton];
            
            UILabel* addDisc =[[UILabel alloc] initWithFrame:CGRectMake(80, 7, 200, 36)];
            addDisc.text = @"添加检索字段";
            addDisc.backgroundColor = [UIColor clearColor];
            
            [cell addSubview:addDisc];
            [addDisc release];
            
            
            
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        
        } 
        
        if(indexPath.section == 2)
        {
            
            static NSString *QueryItemTableIdentifier = @"advancedYearSel";
            
            advancedYearItemsCell *cell = (advancedYearItemsCell*)[tableView dequeueReusableCellWithIdentifier: QueryItemTableIdentifier];
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"advancedTableCell" owner:self options:nil];
            
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[advancedYearItemsCell class]]) {
                    cell = (advancedYearItemsCell*)oneObject;
                }
            if (cell == nil)
            { cell = [[[advancedYearItemsCell alloc]
                       initWithStyle:UITableViewCellStyleDefault reuseIdentifier:QueryItemTableIdentifier] autorelease];
            }
            
            [cell.maxYear  setTitle:maxYear forState:UIControlStateNormal];
            [cell.minYear  setTitle:minYear forState:UIControlStateNormal];
            
            cell.delegate =self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        
        } 
        
        if(indexPath.section == 3)
        {
            static NSString *caCellIdentifier = @"coreCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:caCellIdentifier];
            if (cell == nil) 
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:caCellIdentifier] autorelease];
            }
            
            for (UIView *view in [cell subviews]) {
                if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UISwitch class]])
                    [view removeFromSuperview];
            }

                     
            UISwitch* caSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 150, 30)];
            [caSwitch setOn:coreJournalOn];
            [cell addSubview:caSwitch];
            
            [caSwitch release];
            
            UILabel* lblDocTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 120, 32)];
            
            lblDocTitle.text = @"核心期刊";
            lblDocTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
            
            
            lblDocTitle.backgroundColor = [UIColor clearColor];
            [cell addSubview:lblDocTitle];
            
            [lblDocTitle release];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;                                
        } 
        
        if(indexPath.section == 4)
        {
            static NSString *advCellIdentifier = @"advCellSearchButton";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:advCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:advCellIdentifier] autorelease];
                
            }
            
            for (UIView *view in [cell subviews]) {
                if([view isKindOfClass:[UIButton class]])
                    [view removeFromSuperview];
            }

            
            UIButton* searchButton =[UIButton buttonWithType:UIButtonTypeCustom];
            [searchButton setImage:[UIImage imageNamed:@"btn-advance-search-normal"] forState:UIControlStateNormal];
            [searchButton setImage:[UIImage imageNamed:@"btn-advance-search-highlight"] forState:UIControlStateHighlighted];
            
            searchButton.frame =CGRectMake(10, 10, 309, 39);
            
            //cell.textLabel.text =@"adv";
            
             [searchButton addTarget:self action:@selector(advSearchButtonTapped:) forControlEvents:UIControlEventTouchDown];
            
            
            [cell addSubview:searchButton];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        
        }    
        
        
        static NSString *advCellIdentifier = @"advCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:advCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:advCellIdentifier] autorelease];
            UIView* bgView = [[[UIView alloc] init] autorelease];
            [bgView setBackgroundColor:[UIColor colorWithWhite:2 alpha:0.2]];
            [cell setSelectedBackgroundView:bgView];
        }

        cell.textLabel.text =@"adv";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }   
    
    
        
    
    else if(tableView == self.downList)
    {
        static NSString *CellIdentifier = @"deeCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
        }
        
        
        NSDictionary* result =[self.downloadArrays objectAtIndex:indexPath.row];
        
        NSString* rawTitleString = [result objectForKey:@"title"];
        NSString* titleString = [Util replaceEM:rawTitleString LeftMark:@"" RightMark:@""]; 
        
        CGSize sizeTitle = [titleString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0] constrainedToSize:CGSizeMake(316, 60) lineBreakMode:UILineBreakModeWordWrap];
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,8,sizeTitle.width,sizeTitle.height)];
        
        titleLabel.text = titleString;
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        titleLabel.backgroundColor = [UIColor clearColor]; 
        
        [cell addSubview:titleLabel];
        [titleLabel release];
        
        NSArray* authors =[result objectForKey:@"author"];
        NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
        
        for(int i =0; i<[authors count];i++) 
        {
            if(![s isEqualToString:@""]) 
                [s appendString:@" ,"];
            
            NSString* aStr = [authors objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];     
            [s appendString:aStr];
        }   
        
        UILabel* authorLable = [[UILabel alloc] initWithFrame:CGRectMake(16,82,316,48)];
        
        authorLable.text = s;
        authorLable.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        
        authorLable.numberOfLines = 0; 
        authorLable.backgroundColor = [UIColor clearColor];   
        [cell addSubview:authorLable];
        [authorLable release];    
        [s release];   
        
        s = [[NSMutableString alloc] initWithFormat:@""];
        
        NSString* journal =[result objectForKey:@"journal"];
        
        if(journal == (id)[NSNull null] || journal.length == 0 )
        { 
            [s appendString:@""];
        }
        else
        {
            journal = [Util replaceEM:journal LeftMark:@"" RightMark:@""];     
            [s appendString:journal];
        }
        
        if(![s isEqualToString:@""]) [s appendString:@" ,"];
        
        NSString* publishDate =[result objectForKey:@"pubDate"];
        if(publishDate == (id)[NSNull null] || publishDate.length == 0 )
        { 
            [s appendString:@""];
        }
        else
        {
            publishDate = [Util replaceEM:publishDate LeftMark:@"" RightMark:@""];     
            
            [s appendString:publishDate];
        }
        
        UILabel* journalAndDateLabel= [[UILabel alloc] initWithFrame:CGRectMake(16,122,316, 48)];
        
        journalAndDateLabel.text = s;
        journalAndDateLabel.numberOfLines = 0;  
        //journalAndDateLabel.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];    
        journalAndDateLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0] ; 
        journalAndDateLabel.backgroundColor = [UIColor clearColor];    
        
        [cell addSubview:journalAndDateLabel];
        [journalAndDateLabel release];
        
        [s release];
        
        cell.textLabel.text=@"";
        

    if(currentDisplayingRow == indexPath.row)
    {
        
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-results-selected-document"]] autorelease];
        
        //[self.resultReadingStatus replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
    }
    else
    {
        cell.backgroundView = nil;
        
        /*BOOL readFlag = [[resultReadingStatus objectAtIndex:indexPath.row] boolValue];
        
        if(!readFlag)
        {
            UIImageView* dotImage  =[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-results-unread-dot"]]autorelease];
            dotImage.frame = CGRectMake(4, 15,9, 9);
            
            [cell addSubview:dotImage];
            
            
        } */  
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }    
        
    return cell;
    
    }  
    
    else if(tableView == self.favList)
    {

    
        static NSString *CellIdentifier = @"favCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
        }
        
        
        NSDictionary* result =[self.favArrays objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [result objectForKey:@"title"];
        
       /* NSString* rawTitleString = [result objectForKey:@"title"];
        NSString* titleString = [Util replaceEM:rawTitleString LeftMark:@"" RightMark:@""]; 
        
        CGSize sizeTitle = [titleString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0] constrainedToSize:CGSizeMake(316, 60) lineBreakMode:UILineBreakModeWordWrap];
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,8,sizeTitle.width,sizeTitle.height)];
        
        titleLabel.text = titleString;
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        titleLabel.backgroundColor = [UIColor clearColor]; 
        
        [cell addSubview:titleLabel];
        [titleLabel release];
        
        NSArray* authors =[result objectForKey:@"author"];
        NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
        
        for(int i =0; i<[authors count];i++) 
        {
            if(![s isEqualToString:@""]) 
                [s appendString:@" ,"];
            
            NSString* aStr = [authors objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];     
            [s appendString:aStr];
        }   
        
        UILabel* authorLable = [[UILabel alloc] initWithFrame:CGRectMake(16,82,316,48)];
        
        authorLable.text = s;
        authorLable.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        
        authorLable.numberOfLines = 0; 
        authorLable.backgroundColor = [UIColor clearColor];   
        [cell addSubview:authorLable];
        [authorLable release];  */  
        return cell;
    
    }
    
    static NSString *CellIdentifier = @"defaultCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //UIView* bgView = [[[UIView alloc] init] autorelease];
        //[bgView setBackgroundColor:[UIColor colorWithWhite:2 alpha:0.2]];
        //[cell setSelectedBackgroundView:bgView];
    }
    cell.textLabel.text =@"defatult";
    
    return cell;


}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchResultList) 
    { 
    
    if(displayState == DISPLAY_STATE_FRONTPAGE)
      return 2;
    else
      return 1;
    }
    else if(tableView == self.advSearchList)
        return 5;  
    else
        return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (tableView == self.searchResultList) 
    { 
    
    if(displayState == DISPLAY_STATE_FRONTPAGE)
        return 50;
    else if(displayState == DISPLAY_STATE_RESULTS)
    {
        if(indexPath.row == loadingRow-1)
            return 88;
            
        return 162;
    } 
    else if(displayState == DISPLAY_STATE_SUGGESTION)
        return 46;
    else
        return 50;
    }
    if(tableView == self.advSearchList)
    {
        if(indexPath.section == 0)return 100;
        
        return 50;
    }  
    
    if(tableView == self.downList)
    {
        
        
        return 162;
    } 
    
    if(tableView == self.favList)
    {
        
        
        return 162;
    }  
       return 0;   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchResultList) 
    { 
       if(displayState == DISPLAY_STATE_FRONTPAGE)
      {
        
        if(section == 0)
        {
            int count =[searchHistory getHistoryCount]; 
            if(count ==0) return 1;
            return count;
        }
        else if(section == 1)
        {
           return 1;
        }    
        else
        {
           return 5; 
        }    
      }
      else if(displayState == DISPLAY_STATE_RESULTS)
     {
      
        NSLog(@"total pages %d",totalPages);
      
       if(totalPages == currentPage || isSinglePage)
         return displayCount;
       else
         return displayCount +1;
      }   
      else if(displayState == DISPLAY_STATE_SUGGESTION)
      {
         return suggestionCount;
      }
    return 0;
    }
    else if(tableView == self.advSearchList)
    {
      if(section ==0)
          return advancedQueryItemCount; 
          
      return 1;
        
    
    
    
    } 
    else if(tableView == self.downList)
    {
        NSLog(@"d %d",[self.downloadArrays count]);
        return [self.downloadArrays count];
    }    
    else if(tableView == self.favList)
    {
        NSLog(@"f %d",[self.favArrays count]);
        return [self.favArrays count];
    }    

    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchResultList) 
    {
      if(displayState == DISPLAY_STATE_FRONTPAGE)
      {    
        UIView* header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 24)] autorelease];
    
        header.backgroundColor = [UIColor whiteColor];
        header.layer.borderColor = [UIColor lightGrayColor].CGColor;
        header.layer.borderWidth = 1;
    
      /*UILabel* l = [[[UILabel alloc] initWithFrame:CGRectMake(12, 0, 212, 24)] autorelease];
      l.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
      l.textAlignment = UITextAlignmentCenter;
    
      if(section == 0)
      {
         l.text =@"检 索 历 史";
      }
      else if(section == 1)
      {
         l.text =@"保 存 的 检 索";
      }    
      else
      {
         l.text =@"热 点 检 索";
      }    
    
      [l sizeToFit];
      l.adjustsFontSizeToFitWidth = YES;
      l.textColor = [UIColor grayColor];
    
      l.backgroundColor = [UIColor clearColor];
      header.backgroundColor = [UIColor lightGrayColor];
      [header addSubview:l];
      [l release];*/
          
        if(section == 0)
        {
          UIImageView* bgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-searchHistory-bar"]];
          [header addSubview:bgView];
          [bgView release];
      
        } 
        else if(section ==1)
        {
          UIImageView* bgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-savedSearch-bar"]];
          [header addSubview:bgView];
          [bgView release];
      
        }
        else
        {
          UIImageView* bgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-topSearch-bar"]];
          [header addSubview:bgView];
          [bgView release];
      
        }    
        
        return header;
      }
      else if(displayState == DISPLAY_STATE_RESULTS)
      {
        UIView* header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 40)] autorelease];
        UIImageView* bgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-middleTitleBar"]];
        [header addSubview:bgView];
        [bgView release];
        
        //header.backgroundColor = [UIColor whiteColor];
        
        header.layer.borderColor = [UIColor lightGrayColor].CGColor;
        header.layer.borderWidth = 1;
        
        UIButton* btLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        btLeft.frame = CGRectMake(5, 0, 80, 40);
        //[bt setTitle:@"默认排序" forState:UIControlStateNormal];
        
        
        [btLeft setImage:[UIImage imageNamed:@"btn-search-results-default-sort-normal"] forState:UIControlStateNormal];
        
        [btLeft setImage:[UIImage imageNamed:@"btn-search-results-default-sort-highligh"] forState:UIControlStateHighlighted|UIControlStateSelected];
        [btLeft addTarget:self action:@selector(sortPressed:) forControlEvents:UIControlEventTouchDown];

        [header addSubview:btLeft];
        
        UIButton* btRight = [UIButton buttonWithType:UIButtonTypeCustom];
        btRight.frame = CGRectMake(265, 0, 80, 40);
        //[bt setTitle:@"默认排序" forState:UIControlStateNormal];
        
        
        [btRight setImage:[UIImage imageNamed:@"btn-sarch-results-all-normal"] forState:UIControlStateNormal];
        
        [btRight setImage:[UIImage imageNamed:@"btn-sarch-results-all-highlight"] forState:UIControlStateHighlighted|UIControlStateSelected];
         
        [btRight addTarget:self action:@selector(catalogPressed:) forControlEvents:UIControlEventTouchDown];
        
        [header addSubview:btRight]; 
        
        
        
        UILabel* labelCounts = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,348, 40)];
        labelCounts.textAlignment = UITextAlignmentCenter;
        labelCounts.text = [NSString stringWithFormat:@"约%d篇文献",resultsCount];
        labelCounts.backgroundColor = [UIColor clearColor];
        [header addSubview:labelCounts];
        [labelCounts release];
        
        
        
        return header;
      }
      else if(displayState == DISPLAY_STATE_SUGGESTION)
      {
        UIView* header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 39)] autorelease];
        UIImageView* bgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img-search-autoSugesstion-display-tips"]];
        [header addSubview:bgView];
        [bgView release];

    
        return header; 
      }
    }    
    else
    {
    
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchResultList) 
    {
      if(displayState == DISPLAY_STATE_FRONTPAGE)
        return 24;
    
      if(displayState == DISPLAY_STATE_SUGGESTION)
        return 39;
    
      return 40;
    }
    return 0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchResultList) 
    {
      if(displayState == DISPLAY_STATE_SUGGESTION)
      {
         currentSelectedSuggestion = indexPath.row;
         [self.searchResultList reloadData];
         searchBar.text = [suggestionArrays objectAtIndex:indexPath.row];
         
          //search it
          NSString *searchString = [searchBar text];
          [self finishSearchWithString:searchString];
         
      }
      else if(displayState == DISPLAY_STATE_RESULTS)
      {    
        if(currentDisplayingRow != indexPath.row)
        {
          if(indexPath.row == loadingRow-1)
          {return;}
          
          currentDisplayingRow = indexPath.row; 
        
          [self.resultReadingStatus replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
          
          [self.searchResultList reloadData];  
          [self displayDetails];
        }  
      }
      else if(displayState == DISPLAY_STATE_FRONTPAGE)
      {
          hasLogged = NO;
          
          if(indexPath.section ==0)
          {
              int count =[searchHistory getHistoryCount];
              if(count ==0)return;
              
              UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];  
             
              searchBar.text =cell.textLabel.text;
              
              //search it
              NSString *searchString = [searchBar text];
              [self finishSearchWithString:searchString];
          
          }    
          else if(!hasLogged && indexPath.section == 1)
          {
              [self presentLoginWindow:nil];
          }    
      
      
      }    
        
    }
    
    if(tableView == self.favList)
    {
      //todo: display the selected fav 
    }    
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"delete commited");
        
        //docsearch/removefav/:id/
        NSDictionary* item =[self.favArrays objectAtIndex:indexPath.row];
        
        NSString* eId =[item objectForKey:@"externalId"];
        
        
        NSString* removeFavURL =[NSString stringWithFormat:@"http://%@/docsearch/removefav/%@",SEARCH_SERVER,eId];
        
        NSLog(@"url = %@",removeFavURL);
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:removeFavURL]];
        
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        
        
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
        NSLog(@"token =%@",token);
        //[request addRequestHeader:@"Cookie" value:token];*/
        
        //Create a cookie
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:YES];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        
        
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
        [userInfo setObject:@"removeFav" forKey:@"requestType"];
        [request setUserInfo:userInfo];
        [userInfo release];
        
        
        request.timeOutSeconds = 60*10;
        request.delegate = self;
        [request startAsynchronous];
        
        [cookie release];
        [properties release];

        
        
        
        
    
    }    

}
#pragma mark - textfield delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.currentKeybordHolder  = nil;

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.currentKeybordHolder  = textField;
    return YES;

}



#pragma mark -
#pragma mark Search bar delegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)aSearchBar
{
    self.currentKeybordHolder  = aSearchBar;
    return  YES;//!isLoading;
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar 
{
    //display suggestions
    
    displayState = DISPLAY_STATE_SUGGESTION;
    [self displayStates];
    
    if(![aSearchBar.text isEqualToString:@""])
         [imdSearcher fetchSuggestion:aSearchBar.text lan:currentSearchLanguage Delegate:self];
    
    //self.searchResultCoverView.hidden = NO;
    //self.searchResultList.frame = CGRectMake(0, 0, self.searchListView.frame.size.width, self.searchListView.frame.size.height);
    //[self.searchResultList reloadData];
    
   
    
    
    
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    
    // If the user finishes editing text in the search bar by, for example tapping away rather than selecting from the recents list, then just dismiss the popover.
    
    NSLog(@"end");
    
    [aSearchBar resignFirstResponder];
    self.currentKeybordHolder  = nil;
    
    displayState = DISPLAY_STATE_FRONTPAGE;
    //self.searchResultCoverView.hidden = NO;
    [self displayStates];
    //[self.searchResultList reloadData];
    
    
    /*
    [recentSearchesPopoverController dismissPopoverAnimated:YES];
    [aSearchBar resignFirstResponder];
    
    //self.suggestionView.hidden = NO;
    self.loadingBgView.hidden = YES;
    [self.loadingActivityIndicator stopAnimating];
    self.lblLoading.hidden = YES;
    self.lblError.hidden = YES;
    //[self reloadRecentSearchKeys];*/
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if([searchText isEqualToString:@""])return;
    
    // When the search string changes, filter the recents list accordingly.
    [imdSearcher fetchSuggestion:searchText lan:currentSearchLanguage Delegate:self];
   
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    
    NSLog(@"search");
    
     [aSearchBar resignFirstResponder];
    self.currentKeybordHolder  = nil;
    
    // When the search button is tapped, add the search term to recents and conduct the search.
    NSString *searchString = [aSearchBar text];
    //[recentSearchesController addToRecentSearches:searchString];
    
    [self finishSearchWithString:searchString];
    
    //self.advancedToolBar.hidden =YES;
    //self.searchResultsTable.hidden=YES;
    
    
}

- (void)finishSearchWithString:(NSString *)searchString {
    
    newSearchStart = YES;
    if(displayState == DISPLAY_STATE_FRONTPAGE || displayState == DISPLAY_STATE_RESULTS || displayState == DISPLAY_STATE_SUGGESTION)
    { 
        [searchHistory saveSearchHistory:searchString];
        [imdSearcher simpleSearch:searchString Page:currentPage Lan:currentSearchLanguage Delegate:self];
    
        searchingType = SEARCHING_TYPE_SIMPLE;
    }
    
    if(displayState == DISPLAY_STATE_ADVSEARCH)
    {
        [self advSearchButtonTapped:nil];
        
        searchingType = SEARCHING_TYPE_ADVANCED;
    }
    
    self.loadingLabel.hidden = NO;
    self.errorLabel.hidden = YES;
    [self.loadingIndicator startAnimating];
    
    
    /*isLoading = YES;
    imdPadAppDelegate* appDelegate = (imdPadAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setIsLoading:YES];*/
}

#pragma mark - ASIHTTPRequest delegate

-(void)requestFinished:(ASIHTTPRequest *)request
{
    
    NSLog(@"request finished"); 
    
    NSDictionary* requestInfo =[request userInfo];
    NSString* rType = [requestInfo objectForKey:@"requestType"];
    
    if([rType isEqualToString:@"search"])
    {
        //NSLog(@"got string %@",rString);
        
        NSData * responseData =[request rawResponseData];
        NSString* responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        // Use when fetching binary data
        //NSLog(@"ok %@",responseString);
        BOOL hasError = NO;
        
        NSDictionary* info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 ) 
        {
            info =nil;
            hasError = YES;
        }
        else
        {
            info =[responseString JSONValue];   
        }
        
        if(info != nil)
        {
            NSLog(@"get result %@",info);
            
            displayState = DISPLAY_STATE_RESULTS;
            
            [self displayStates];
            //self.backButton.hidden = NO;
            //self.favoriteSaveButton.hidden = NO;
            //self.searchTitle.text =@"搜 索 结 果"; 
            
            
            //reload way
            //if( self.searchedResult !=nil)
            //{
            //    [self.searchedResult release];
            //}
            
            //self.searchedResult = info;
            
            if(newSearchStart)
            {
               if(self.searchedResult !=nil)
               {
                  self.searchedResult =nil;
                  self.resultReadingStatus =nil; 
               }
                
               self.searchedResult = info; 
               self.resultReadingStatus = [NSMutableArray arrayWithCapacity:60];
               
               //set new count readingstatus 
               NSArray* results =[info objectForKey:@"results"];
               
                for(int i =0;i<[results count];i++)
                {
                    [self.resultReadingStatus addObject:[NSNumber numberWithBool:NO]];
                }
                
                
            }   
            else
            {
                
              if( self.searchedResult !=nil)
              {
               
                NSArray* results =[info objectForKey:@"results"];
                
                if(results == (id)[NSNull null]  || [results count] ==0)
                {
                    NSLog(@"info error");
                }
                else
                {    
                    
                    int count = [results count];
                    
                    NSMutableArray* oldResults =[[self.searchedResult objectForKey:@"results"] mutableCopy];
                    
                    NSLog(@"old result %d",[oldResults count]); 
                    
                    for(int i=0;i<count;i++)
                    {
                        [oldResults addObject:[results objectAtIndex:i]];
                    }
                    
                    NSLog(@"now result %d",[oldResults count]);  
                    
                    [self.searchedResult setValue:oldResults forKey:@"results"]; 
                    [oldResults release];
                    
                    
                    //set new count readingstatus
                    for(int i =0;i<count;i++)
                    {
                        [self.resultReadingStatus addObject:[NSNumber numberWithBool:NO]];
                    }

                    
                    
                } 
            
              }
              else
                self.searchedResult = info;
            }
            
        
            
            resultsCount = [[self.searchedResult valueForKey:@"resultCount"] intValue];
            
            NSLog(@"result count %d",resultsCount);
            
            NSArray* results =[self.searchedResult objectForKey:@"results"];
            
            
            displayCount = [results count];
            
            self.searchResultCoverView.hidden = YES;
            
            
            
            [self calculatePages];
            
            currentDisplayingRow =0;
            
            [self.searchResultList reloadData];
            [self displayDetails];
            
            NSLog(@"load ok");
            
        }
        else
        {
            hasError = YES;
        }
        
        //[self.advancedViewButton setTitle:@"高级搜索" forState:UIControlStateNormal];
        [responseString release];
        
        self.loadingLabel.hidden = YES;
         self.errorLabel.hidden = YES;
        [self.loadingIndicator stopAnimating];
        
        if(hasError)
        {
            NSLog(@"sth wrong.");
           self.errorLabel.text =@"搜索出错,请稍候重试";
           self.errorLabel.hidden = NO;
            
        }
        
        //[self.loadingActivityIndicator stopAnimating];
        //isLoading = NO;
        //imdPadAppDelegate* appDelegate = (imdPadAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[appDelegate setIsLoading:NO];
        

    
    
    }
    else if([rType isEqualToString:@"suggestion"])
    {
       if(displayState == DISPLAY_STATE_SUGGESTION)
       {
        
           NSString* responseString=[request responseString];
           NSLog(@"ok %@",responseString);
           BOOL hasError = NO;
           
           responseString = [responseString stringByReplacingOccurrencesOfString:@"\'"
                                                                      withString:@"\""];
           
           NSMutableArray* info;
           if (responseString ==(id)[NSNull null] || responseString.length ==0 ) 
           {
               info =nil;
               hasError = YES;
           }
           else
           {
               info =[responseString JSONValue];   
           }
           
           if(hasError)
           {
               NSLog(@"sth wrong with json");
           }    
           else if(info != nil)
           {
               
               if(suggestionArrays != nil)
               {
                   [suggestionArrays release];
               }
               
               suggestionArrays = [info retain];
               
               suggestionCount =[suggestionArrays count];
               currentSelectedSuggestion = -1;
               [self.searchResultList reloadData];
               
           }
          
       }    
      
        
    }
    else if([rType isEqualToString:@"requestPDF"])
    {
        //NSLog(@"downing ");
        
        NSString* s =[request responseString];
        NSLog(@"s= %@",s);
        
        if(s!= nil && [Util isHtml:s])
        {
            //self.PDFErrorLabel.hidden = NO;
            NSLog(@"html or bad response");
            self.loadingLabel.hidden = YES;
            [self.loadingIndicator stopAnimating];
            
            self.errorLabel.text =@"pdf出错,请稍候重试";
            self.errorLabel.hidden = NO;
            //displayState = DISPLAY_STATE_FRONTPAGE;
            //[self displayStates];
            NSString* fileName = [requestInfo objectForKey:@"downloadFile"];

            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:fileName error:&error])
            {
                //TODO: Handle/Log error
                
                NSLog(@"del failed %@",error);
            }
            
            return;
        }
        else
        {
            NSLog(@"loading pdf");
             NSString* fileName = [requestInfo objectForKey:@"downloadFile"];
            
            
            if(![self loadPDF:fileName])
            {
                NSLog(@"load pdf failed");
                self.loadingLabel.hidden = YES;
                [self.loadingIndicator stopAnimating];
                self.errorLabel.text =@"pdf出错,请稍候重试";
                self.errorLabel.hidden = NO;
                
                //displayState = DISPLAY_STATE_FRONTPAGE;
                //[self displayStates];
                
                NSError *error;
                if(![[NSFileManager defaultManager] removeItemAtPath:fileName error:&error])
                {
                    //TODO: Handle/Log error
                    
                   NSLog(@"del failed %@",error);
                }

                
                
                return;
                //self.PDFErrorLabel.hidden = NO;
            }    
        }
        
        self.searchResultCoverView.hidden =YES;
        self.detailView.hidden =NO;
        self.AbstractTextScrollView.hidden =YES;
        
        
        //isLoading = NO;
        //imdPadAppDelegate* appDelegate = (imdPadAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[appDelegate setIsLoading:NO];

    }
    else if([rType isEqualToString:@"addFav"])
    {
    
        NSLog(@"add ok %@",[request responseString]);
        //to do:add notification of the work done.
        
    } 
    else if([rType isEqualToString:@"listFav"])
    {
        NSLog(@"list ok %@",[request responseString]);
        NSString* responseString =[request responseString];
        //NSData * responseData =[request rawResponseData];
        //NSString* responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSLog(@"ok %@",responseString);
        BOOL hasError = NO;
        
        NSDictionary* info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 ) 
        {
            info =nil;
            hasError = YES;
        }
        else
        {
            info =[responseString JSONValue];   
        }
        
        if(info != nil)
        {
            NSLog(@"get result %@",info);
            self.favArrays =nil;
            self.favArrays = [info objectForKey:@"favs"];
            
            NSLog(@"fav array %@",favArrays);
            
            [self.favList reloadData];
            [self.favList setEditing:NO animated:NO];
            [self.favEditButton setTitle:@"编辑" forState:UIControlStateNormal];
            
        }
        else
        {
            hasError = YES;
        }
        
        //[self.advancedViewButton setTitle:@"高级搜索" forState:UIControlStateNormal];
        //[responseString release];
        
        self.loadingLabel.hidden = YES;
        [self.loadingIndicator stopAnimating];
        
        if(hasError)
        {
            NSLog(@"sth wrong.");
            self.errorLabel.text =@"出错了,请稍候重试";
            self.errorLabel.hidden = NO;
        }
        
        //[self.loadingActivityIndicator stopAnimating];
        //isLoading = NO;
        //imdPadAppDelegate* appDelegate = (imdPadAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[appDelegate setIsLoading:NO];

    }    
    else if([rType isEqualToString:@"removeFav"])
    {
        NSLog(@"remove fav %@",[request responseString]);
        
        [self loadFav];
    }    
    
}

-(BOOL)loadPDF:(NSString*)pdfFileName
{
    NSURL* fileURL;// = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ipcbook.pdf" ofType:nil]];
    //NSString* pdfFileName =@"result.pdf";
    NSString* filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:pdfFileName];
    
    fileURL =[NSURL fileURLWithPath:filePath];
    
    self.pdfView =nil;
    
    for (UIView *view in [detailView subviews]) {
        if([view isKindOfClass:[PDFViewTiled class]])
            [view removeFromSuperview];
    }

    
    PDFViewTiled* thePDFView;
    @try
    {
        thePDFView = [[PDFViewTiled alloc] initWithURL:fileURL page:0 password:nil frame:[self.detailView bounds]];
    }
    @catch(NSException* ex)
    {  
        //[thePDFView release];
        NSLog(@"Bad pdf");
        return NO;
    } 
    
    
    //frame:self.rightView.bounds];
    
    self.pdfView =thePDFView;
    //pdfView = thePDFView;
    pdfView.hidden = NO;
    
    [self.detailView addSubview:pdfView];
    [self.detailView setZoomScale:1.0f animated:NO];
    [thePDFView release];
    
    pdfValue =1;
    self.pageNo.hidden = NO;
    self.pageNo.text =[NSString stringWithFormat:@"%d/%d",pdfValue,self.pdfView.pageCount];
    //self.detailView.hidden = NO;
    //self.pdfSlider.maximumValue = self.pdfView.pageCount;    
    //self.pdfSlider.hidden = NO;
    
    
    //self.prePageButton.hidden = NO;
    //self.nextPageButton.hidden = NO;
    
    //swipes
    UISwipeGestureRecognizer *swipeGesture = nil;
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pdfHandleAllSwipes:)];
    
	swipeGesture.cancelsTouchesInView = NO; 
    swipeGesture.delaysTouchesEnded = NO; 
    swipeGesture.delegate = self;
	swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft; // ++page
	[self.detailView addGestureRecognizer:swipeGesture]; 
    [swipeGesture release];
    
	
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pdfHandleAllSwipes:)];
    
	swipeGesture.cancelsTouchesInView = NO; 
    swipeGesture.delaysTouchesEnded = NO; 
    swipeGesture.delegate = self;
	swipeGesture.direction = UISwipeGestureRecognizerDirectionRight; // --page
	[self.detailView addGestureRecognizer:swipeGesture]; 
    [swipeGesture release];
    
    return YES;
    
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{

    NSLog(@"request failed %@",[request responseString]);
   
    //to do if suggestion ,return
    NSDictionary* requestInfo =[request userInfo];
    NSString* rType = [requestInfo objectForKey:@"requestType"];
    
    if([rType isEqualToString:@"suggestion"])return;
    
    //if is normal search
    self.loadingLabel.hidden = YES;
    [self.loadingIndicator stopAnimating];
    self.errorLabel.text =@"出错了,请稍候重试";
    self.errorLabel.hidden = NO;
    
    
    //displayState = DISPLAY_STATE_FRONTPAGE;
    //[self displayStates];
    
    
    
    
    
}

#pragma mark - display functions

-(void)displayDetails
{
   //currentDisplayingRow
    NSArray* results =[self.searchedResult objectForKey:@"results"];
    
    if(results == (id)[NSNull null]  || [results count] ==0)
    {
        NSLog(@"no results");
        
        self.detailAbstractText.text =@"";
        self.detailJournalAndDate.text =@"";
        self.detailAuthors.text =@"";
        self.detailaffiliations.text =@"";
        self.detailTitle.text =@"";
        self.detailKeyword.text =@"";
        self.searchResultCoverView.hidden = NO;
              
        return;
    }
    
    self.searchResultCoverView.hidden = YES;
    self.detailView.hidden =YES;
    self.AbstractTextScrollView.hidden =NO;
    
    if (currentSearchLanguage == SEARCH_MODE_CN) 
        self.switchButton.hidden = NO;
    else
        self.switchButton.hidden = YES;
    
    
    if(inFullText)
    {    
        inFullText =NO;
        self.pageNo.hidden = YES;
        //[self.switchButton setTitle:@"全文" forState:UIControlStateNormal];
        [self.switchButton setImage:[UIImage imageNamed:@"btn-fulltext.png"] forState:UIControlStateNormal];
        //[self displayDetails];
        NSLog(@"back to normal text");
        
    }

    
    NSDictionary* result =[results objectAtIndex:currentDisplayingRow];
    
    
    float yOffset =10;
    float xOffset =26;
    
    UIColor* lightFullTextColor = [UIColor colorWithRed:124/255.0f green:110/255.0f blue:96/255.0f alpha:1.0f];
    UIColor* titleColor = [UIColor colorWithRed:77/255.0f green:55/255.0f blue:38/255.0f alpha:1.0f];
    UIColor* abstractTextColor = [UIColor colorWithRed:120/255.0f green:106/255.0f blue:91/255.0f alpha:1.0f];
    
    //journal and date
    NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
    

    NSString* journal =[result objectForKey:@"journal"];
    if(journal == (id)[NSNull null] || journal.length == 0 )
    { 
        [s appendString:@""];
    }
    else
    {
        journal = [Util replaceEM:journal LeftMark:@"" RightMark:@""];     
        
        [s appendString:journal];
    }
    
    if(![s isEqualToString:@""]) [s appendString:@" ,"];
    
    NSString* publishDate =[result objectForKey:@"pubDate"];
    if(publishDate == (id)[NSNull null] || publishDate.length == 0 )
    { 
        [s appendString:@""];
    }
    else
    {
        publishDate = [Util replaceEM:publishDate LeftMark:@"" RightMark:@""];     
        [s appendString:publishDate];
    }

    self.detailJournalAndDate.text = s;
    self.detailJournalAndDate.textColor = lightFullTextColor;
    
    self.detailJournalAndDate.font =[UIFont fontWithName:@"Helvetica" size:17.0 + currentDetailsFontSizeOffset];
    self.detailJournalAndDate.lineBreakMode =UILineBreakModeWordWrap;
    self.detailJournalAndDate.numberOfLines = 0;
    
    
    CGSize sizeJournalAndDate= [s sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0 +currentDetailsFontSizeOffset] constrainedToSize:CGSizeMake(558, 4000) lineBreakMode:UILineBreakModeWordWrap];
    [s release];
    detailJournalAndDate.frame = CGRectMake(xOffset, yOffset, sizeJournalAndDate.width, sizeJournalAndDate.height);
    
    yOffset =yOffset + sizeJournalAndDate.height+10;
    
    
    //title    
    NSString* title = [result objectForKey:@"title"];
    if(title == (id)[NSNull null] || title.length == 0 )
        title =@"";
    else
        title = [Util replaceEM:title LeftMark:@"" RightMark:@""];     
    
    self.detailTitle.text =title;
    self.detailTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:20.0 +currentDetailsFontSizeOffset];
    self.detailTitle.lineBreakMode =UILineBreakModeWordWrap;
    self.detailTitle.numberOfLines = 0;
    
    CGSize sizeTitle = [title sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0 +currentDetailsFontSizeOffset] constrainedToSize:CGSizeMake(558, 4000) lineBreakMode:UILineBreakModeWordWrap];
    self.detailTitle.textColor = titleColor;
    
    detailTitle.frame = CGRectMake(xOffset, yOffset, sizeTitle.width, sizeTitle.height);
    
    
    yOffset = yOffset + sizeTitle.height +20;
    
    
    //authors
    NSArray* authors =[result objectForKey:@"author"];
    NSMutableString* authorString = [[NSMutableString alloc] initWithFormat:@""];
    
    for(int i =0; i<[authors count];i++) 
    {
        if(![authorString isEqualToString:@""]) 
            [authorString appendString:@" ,"];
        NSString* aStr = [authors objectAtIndex:i];        
        aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];     
        [authorString appendString:aStr];
    }   
    
    self.detailAuthors.text = authorString;
    self.detailAuthors.textColor = lightFullTextColor;
    
    self.detailAuthors.font =[UIFont fontWithName:@"Helvetica" size:17.0 +currentDetailsFontSizeOffset];
    self.detailAuthors.lineBreakMode =UILineBreakModeWordWrap;
    self.detailAuthors.numberOfLines = 0;
    
   
    CGSize sizeAuthor = [authorString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0+currentDetailsFontSizeOffset] constrainedToSize:CGSizeMake(558, 4000) lineBreakMode:UILineBreakModeWordWrap];
    
     detailAuthors.frame = CGRectMake(xOffset, yOffset, sizeAuthor.width, sizeAuthor.height);
    [authorString release];
    yOffset = yOffset + sizeAuthor.height +10;
    
    
    //affliation
    
    NSArray* affiliations =[result objectForKey:@"affiliation"];
    NSMutableString* affiliationString = [[NSMutableString alloc] initWithFormat:@""];
    
    if(affiliations == (id)[NSNull null] || [affiliations count] == 0)
    {
        
    }
    else    
    {
        for(int i =0; i<[affiliations count];i++) 
        {
            if(![affiliationString isEqualToString:@""]) 
                [affiliationString appendString:@" ,"];
            
            NSString* aStr = [affiliations objectAtIndex:i];        
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];     
            [affiliationString appendString:aStr];  
            
        }   
    }
    
    self.detailaffiliations.text = affiliationString;
    self.detailaffiliations.textColor = lightFullTextColor;
    
    self.detailaffiliations.font =[UIFont fontWithName:@"Helvetica" size:17.0+currentDetailsFontSizeOffset];
    self.detailaffiliations.lineBreakMode =UILineBreakModeWordWrap;
    self.detailaffiliations.numberOfLines = 0;
    
    
    CGSize sizeAffiliation = [affiliationString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0+currentDetailsFontSizeOffset] constrainedToSize:CGSizeMake(558, 4000) lineBreakMode:UILineBreakModeWordWrap];
    
   
    detailaffiliations.frame = CGRectMake(xOffset, yOffset, sizeAffiliation.width, sizeAffiliation.height);
    
    [affiliationString release];
    yOffset = yOffset + sizeAffiliation.height +40;

    
    
    //abstract Text
    
    NSDictionary* abstractTextDic = [result objectForKey:@"abstractText"];
    NSArray* textArray =[abstractTextDic objectForKey:@"text"];
    NSMutableString* abstractText =[NSMutableString stringWithString:@"Abstract "];
    
    if(textArray == (id)[NSNull null] || [textArray count] == 0)
    {
        NSLog(@"no ab text");
    }
    else    
    {
        for(int i =0; i<[textArray count];i++) 
        {
            if(![abstractText isEqualToString:@"Abstract "]) 
                [abstractText appendString:@" ,"];
            
            NSString* aStr = [textArray objectAtIndex:i];        
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""]; 
            [abstractText appendString:aStr];
        }   
    }
    
    
    self.detailAbstractText.text = abstractText;
    self.detailAbstractText.textColor = abstractTextColor;
    
    self.detailAbstractText.font =[UIFont fontWithName:@"Helvetica" size:17.0+currentDetailsFontSizeOffset];
    self.detailAbstractText.lineBreakMode =UILineBreakModeWordWrap;
    self.detailAbstractText.numberOfLines = 0;
    
    CGSize sizeAbstractText = [abstractText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0+currentDetailsFontSizeOffset] constrainedToSize:CGSizeMake(558, 6000) lineBreakMode:UILineBreakModeWordWrap];
     self.detailAbstractText.frame = CGRectMake(xOffset, yOffset ,sizeAbstractText.width, sizeAbstractText.height);
    
     yOffset = yOffset + sizeAbstractText.height +10;   
    
    
    //keywords
    NSArray* keywords =[result objectForKey:@"keywords"];
    //NSString* keywordMark = @"Keyword ";
    //NSMutableString* keywordsString = [[NSMutableString alloc] initWithFormat:@"        "];
    NSMutableString* keywordsString = [[NSMutableString alloc] initWithFormat:@"Keyword "];

    if(keywords == (id)[NSNull null] || [keywords count] == 0)
    {
        
    }
    else    
    {
        for(int i =0; i<[keywords count];i++) 
        {
            if(![keywordsString isEqualToString:@"Keyword "]) 
                [keywordsString appendString:@" ,"];
            
            NSString* aStr = [keywords objectAtIndex:i];        
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];     
            [keywordsString appendString:aStr];  
            
        }   
    }
    
    self.detailKeyword.text = keywordsString;
    self.detailKeyword.textColor = lightFullTextColor;
    
    self.detailKeyword.font =[UIFont fontWithName:@"Helvetica" size:17.0+currentDetailsFontSizeOffset];
    self.detailKeyword.lineBreakMode =UILineBreakModeWordWrap;
    self.detailKeyword.numberOfLines = 0;
    
    
    CGSize sizeKeywords = [keywordsString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0+currentDetailsFontSizeOffset] constrainedToSize:CGSizeMake(558, 4000) lineBreakMode:UILineBreakModeWordWrap];
    
    
    detailKeyword.frame = CGRectMake(xOffset, yOffset, sizeKeywords.width, sizeKeywords.height);
    
    [keywordsString release];
    yOffset = yOffset + sizeKeywords.height +10;
    
    self.AbstractTextScrollView.contentSize = CGSizeMake(558, yOffset+sizeKeywords.height);
    

}


- (void)calculatePages
{
    currentPage = fetchingPage;
    
    if(resultsCount % displayMax == 0)
    {
        totalPages = resultsCount/displayMax;
    }
    else
    {
        totalPages = resultsCount/displayMax+1;
    }
    
    
    isSinglePage = (totalPages == 1);
    
    NSArray* results =[self.searchedResult objectForKey:@"results"];
    
    if(results == (id)[NSNull null]  || [results count] ==0)
    {
        NSLog(@"error");  
    }
    else
    { 
        loadingRow = [results count]+1;
    }
    

}

-(void)loadingNextBlock:(id)sender
{

    fetchingPage = currentPage +1;
    newSearchStart = NO;
    if(searchingType == SEARCHING_TYPE_ADVANCED)
    {
        [self advSearchButtonTapped:nil];
    
    } 
    else
    {
      [imdSearcher simpleSearch:searchBar.text Page:fetchingPage Lan:currentSearchLanguage Delegate:self];
    }

}

#pragma mark - change search language
-(void)popLanguageSelection:(UIButton*)sender
{

    NSLog(@"filter tapped");
    
    if(languagePopoverController!=nil)
    {
        [languagePopoverController release];   
    }
    
    
    lanSelectViewController *content = [[lanSelectViewController alloc] initWithNibName:@"lanSelectViewController" bundle:nil];
    //content.searchLanguage = currentSearchLanguage;
    
    languagePopoverController= [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    //content.tag =[sender tag];
    
    
	languagePopoverController.popoverContentSize = CGSizeMake(280., 100.);
	languagePopoverController.delegate = self;
    
    UIButton* t =(UIButton*)sender;
    
    CGRect frame=CGRectMake(t.frame.origin.x + 72, t.frame.origin.y + 40, t.frame.size.width, t.frame.size.height);
    
    // Present the popover from the button that was tapped in the detail view.
	[languagePopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [content release];


}

-(void)changeLanguage:(UIButton*)sender
{
    
    //NSLog(@"changing mode"); 
    [languagePopoverController dismissPopoverAnimated:YES];
    
    lanSelectViewController* c = (lanSelectViewController*)sender; 
    
   if(c.selectedItem == SEARCH_MODE_CN) 
    {  
        currentSearchLanguage = SEARCH_MODE_CN; 
    }
    else
    {  
        currentSearchLanguage = SEARCH_MODE_EN;
    }
    
    if(currentSearchLanguage == SEARCH_MODE_CN)   
    { 
        
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-cn-normal"] forState:UIControlStateNormal];
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-cn-highlight.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-en-normal"] forState:UIControlStateNormal];
        [self.langSelButton setImage:[UIImage imageNamed:@"btn-language-en-highlight.png"] forState:UIControlStateHighlighted]; 
        
    }   

    //if(displayState == DISPLAY_STATE_ADVSEARCH)
    {
        [filterNames release];
        [filterValues release];
        [filterOperations release];
        
        
        filterNames = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
        filterValues = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
        filterOperations = [[NSMutableArray alloc] initWithCapacity:advancedQueryItemCountMax];
        
        filterItemData = [self readPListBundleFile:@"searchFilters"];
        
        for(int i =0; i<advancedQueryItemCountMax ;i++)
        {
            if(currentSearchLanguage == SEARCH_MODE_CN)
            {
                NSArray* TextCN = [filterItemData objectForKey:@"CN_TEXT"];
                [filterNames addObject:[TextCN objectAtIndex:0]];
            }
            else
            {
                NSArray* TextEN = [filterItemData objectForKey:@"EN_TEXT"];
                [filterNames addObject:[TextEN objectAtIndex:0]];
            }   
            
            [filterValues addObject:@""];
            [filterOperations addObject:[NSNumber numberWithInt:OPERATION_AND]];
        }

        [self displayStates];
    }
    
    //save mode
    [[NSUserDefaults standardUserDefaults] setInteger:currentSearchLanguage forKey:@"searchLan"];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
}    


#pragma mark - change catalog
-(void)changeCatalog:(id)sender
{
    [catalogPopoverController dismissPopoverAnimated:YES];
    NSLog(@"catalog change");
}


#pragma mark - change sort
-(void)changeSort:(id)sender
{
    [sortPopoverController dismissPopoverAnimated:YES];    
    NSLog(@"sort change");
}


#pragma mark - refresh sideActions
- (void)refreshSideActionButtons
{
    selectedDotSearch.hidden = !(currentActionSelected == SIDEACTION_SEARCH);  
    selectedDotFav.hidden = !(currentActionSelected == SIDEACTION_FAVORITE);
    selectedDotDownload.hidden = !(currentActionSelected == SIDEACTION_DOWNLOADED);  
    
  if(currentActionSelected == SIDEACTION_SEARCH)
  {
      [self.sideActionSearchButton setImage:[UIImage imageNamed:@"icon-search-selected"] forState:UIControlStateNormal];  
  }
  else
  {
      [self.sideActionSearchButton setImage:[UIImage imageNamed:@"icon-search-normal"] forState:UIControlStateNormal]; 
  
  }  
    
  if(currentActionSelected == SIDEACTION_FAVORITE)
  {
       [self.sideActionFavoriteButton setImage:[UIImage imageNamed:@"icon-favoritesFolder-selected"] forState:UIControlStateNormal];  
  }
  else
  {
       [self.sideActionFavoriteButton setImage:[UIImage imageNamed:@"icon-favoritesFolder-normal"] forState:UIControlStateNormal]; 
        
  }      
    
    
  if(currentActionSelected == SIDEACTION_DOWNLOADED)
  {
        [self.sideActionDownloadedButton setImage:[UIImage imageNamed:@"icon-downloadFolder-selected"] forState:UIControlStateNormal];  
   }
   else
   {
        [self.sideActionDownloadedButton setImage:[UIImage imageNamed:@"icon-downloadFolder-normal"] forState:UIControlStateNormal]; 
        
    }    
    
    
    if(currentActionSelected == SIDEACTION_SETTINGS)
    {
        [self.sideActionSettingsButton setImage:[UIImage imageNamed:@"icon-setting-selected"] forState:UIControlStateNormal];  
    }
    else
    {
        [self.sideActionSettingsButton setImage:[UIImage imageNamed:@"icon-setting-normal"] forState:UIControlStateNormal]; 
        
    }       
    
    if(currentActionSelected == SIDEACTION_HELP)
    {
        [self.sideActionHelpButton setImage:[UIImage imageNamed:@"icon-help-selected"] forState:UIControlStateNormal];  
    }
    else
    {
        [self.sideActionHelpButton setImage:[UIImage imageNamed:@"icon-help-normal"] forState:UIControlStateNormal]; 
        
    }      


}

#pragma mark - pressed sideActions
- (IBAction)sideActionPressed:(id)sender
{
    NSLog(@"side action pressed");
    
    UIButton* button =(UIButton*)sender;
    if(button == self.sideActionSearchButton)
    {
        currentActionSelected = SIDEACTION_SEARCH;
        displayState = DISPLAY_STATE_FRONTPAGE;
    }
    else if(button == self.sideActionFavoriteButton)
    {
        currentActionSelected = SIDEACTION_FAVORITE;
        displayState = DISPLAY_STATE_FAVORATE;
        [self loadFav];
    }
    else if(button == self.sideActionDownloadedButton)
    {
        currentActionSelected = SIDEACTION_DOWNLOADED;
        displayState = DISPLAY_STATE_DOWNLOADED;
        [self.downList reloadData];   
    }
    else if(button == self.sideActionSettingsButton)
    {
        currentActionSelected = SIDEACTION_SETTINGS;
        [self presentSettingWindow];
    }
    else if(button == self.sideActionHelpButton)
    {
        currentActionSelected = SIDEACTION_HELP;
    }
    
    
    [self refreshSideActionButtons];
    [self displayStates];

}



#pragma mark - result head buttons

- (void)sortPressed:(id)sender
{
  //popover
    
    if(sortPopoverController!=nil)
    {
        [sortPopoverController release];   
    }
    
    
    sortSelectViewController *content = [[sortSelectViewController alloc] initWithNibName:@"sortSelectViewController" bundle:nil];
    //content.searchLanguage = currentSearchLanguage;
    
    sortPopoverController= [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    //content.tag =[sender tag];
    
	sortPopoverController.popoverContentSize = CGSizeMake(280., 150.);
	sortPopoverController.delegate = self;
    
    UIButton* t =(UIButton*)sender;
    
    
    CGRect frame=CGRectMake(t.frame.origin.x + 72, t.frame.origin.y+90, t.frame.size.width, t.frame.size.height);
    
    
    // Present the popover from the button that was tapped in the detail view.
	[sortPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [content release];

}


- (void)catalogPressed:(id)sender
{
    //popover
        
    NSLog(@"catalog tapped");
    
    if(catalogPopoverController!=nil)
    {
        [catalogPopoverController release];   
    }
    

    catalogSelectViewController *content = [[catalogSelectViewController alloc] initWithNibName:@"catalogSelectViewController" bundle:nil];
    //content.searchLanguage = currentSearchLanguage;
    
    catalogPopoverController= [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    //content.tag =[sender tag];
    
	catalogPopoverController.popoverContentSize = CGSizeMake(280., 100.);
	catalogPopoverController.delegate = self;
    
    UIButton* t =(UIButton*)sender;
    
    
    CGRect frame=CGRectMake(t.frame.origin.x + 72, t.frame.origin.y+90, t.frame.size.width, t.frame.size.height);
    
    
    // Present the popover from the button that was tapped in the detail view.
	[catalogPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [content release];

}
 
#pragma mark - title buttons
-(IBAction)backPressed:(id)sender
{
   /* displayState = DISPLAY_STATE_FRONTPAGE;
    self.backButton.hidden = YES;
    self.favoriteSaveButton.hidden = YES;
    self.searchTitle.text =@"文 献 搜 索"; 
    self.searchResultCoverView.hidden = NO;
    [self.searchResultList reloadData];*/
    
   if(displayState == DISPLAY_STATE_RESULTS)
       displayState = DISPLAY_STATE_FRONTPAGE;
   else if(displayState == DISPLAY_STATE_ADVSEARCH)
   {
      [self advViewHide]; 
      displayState = lastDisplayState;
   }
    
   [self displayStates];

}


-(IBAction)favSavePressed:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Informaion"
                                                        message:@"search saved" delegate:self 
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


-(void) addQueryItem:(id)sender
{
    advancedQueryItemCount ++;
    if(advancedQueryItemCount >advancedQueryItemCountMax)
    {    
        advancedQueryItemCount =advancedQueryItemCountMax;
        return;
    }
    
    [self.advSearchList reloadData];    
}



#pragma mark - move show/hide complete function
-(void)advViewShow
{
    NSLog(@"let adv search out");
    
    //do not show at suggestion state
    if(displayState == DISPLAY_STATE_SUGGESTION) return;
    
    //if(self.advanedView == nil)
    //    self.advanedView =[[UIView alloc] initWithFrame:CGRectMake(-100, 0, 200, 748)];
    //self.advanedView.backgroundColor = [UIColor blueColor];
    
    self.advanedView.frame = CGRectMake(-348, 90, 348, 658);
    
    
    [UIView beginAnimations:@"move show" context:nil];
    [UIView setAnimationDuration:0.5f];
    self.advanedView.frame = CGRectMake(0, 90, 348, 658);
    [UIView setAnimationDidStopSelector:
     @selector(movingShowCompleted)];
    [UIView setAnimationDelegate: self];
    [UIView commitAnimations];
    
    
    //bad for not respond to interaction
    /*CABasicAnimation *moveRight;
     moveRight			= [CABasicAnimation animationWithKeyPath:@"position.x"];
     moveRight.toValue	= [NSNumber numberWithFloat:174];
     moveRight.duration	= 0.5;
     moveRight.removedOnCompletion = NO;
     moveRight.fillMode	= kCAFillModeForwards;
     [[self.advanedView layer] addAnimation:moveRight forKey:@"moveRight"];*/
    
    self.advanedView.hidden =NO;
    [self.advanedView setUserInteractionEnabled:YES];
    
    advViewAnimating =YES;

}


-(void)advViewHide
{

    NSLog(@"let adv search hide");
    
    self.advanedView.frame = CGRectMake(0, 90, 348, 658);
    
    
    [UIView beginAnimations:@"move hide" context:nil];
    [UIView setAnimationDuration:0.5f];
    self.advanedView.frame = CGRectMake(-348, 90, 348, 658);
    [UIView setAnimationDidStopSelector:
     @selector(movingHideCompleted)];
    [UIView setAnimationDelegate: self];
    [UIView commitAnimations];
    
    //self.advanedView.hidden = YES;
    
    //bad for not respond to interaction
    /*CABasicAnimation *moveLeft;
     moveLeft			= [CABasicAnimation animationWithKeyPath:@"position.x"];
     moveLeft.toValue	= [NSNumber numberWithFloat:-174];
     moveLeft.duration	= 0.5;
     moveLeft.removedOnCompletion = NO;
     moveLeft.fillMode	= kCAFillModeForwards;
     [[self.advanedView layer] addAnimation:moveLeft forKey:@"moveLeft"];*/
    
    advViewAnimating =YES;

}


-(void)movingShowCompleted
{
    NSLog(@"show completed");
    advViewAnimating =NO;
    
    
    lastDisplayState = displayState;
    displayState = DISPLAY_STATE_ADVSEARCH;
    
    [self displayStates]; 
    
    
    //advancedQueryItemCount =1;
    newAdvSearch = YES;

}

-(void)movingHideCompleted
{
    NSLog(@"hide completed");
    advViewAnimating =NO;

    displayState = lastDisplayState;
    [self displayStates];
    
    advancedQueryItemCount =1;
    newAdvSearch = YES;

    [self.advSearchList reloadData];  
}


#pragma mark - display state
-(void)displayStates
{
   if(displayState == DISPLAY_STATE_ADVSEARCH)
   {
       self.searchTitle.text = @"高 级 搜 索";
       self.backButton.hidden = NO;
       self.favoriteSaveButton.hidden = YES;
       self.searchResultCoverView.hidden = NO;
       self.searchResultList.frame = CGRectMake(0, 0, self.searchListView.frame.size.width, self.searchListView.frame.size.height);
       [self.advSearchList reloadData];  
       
       self.listFavView.hidden =YES;
       self.listDownloadView.hidden =YES;
       self.listSearchView.hidden =NO;
   }
 
    if(displayState == DISPLAY_STATE_FRONTPAGE)
    {
        self.backButton.hidden = YES;
        self.favoriteSaveButton.hidden = YES;
        self.searchTitle.text =@"文 献 搜 索"; 
        //self.searchResultCoverView.hidden = NO;
        self.searchResultList.frame = CGRectMake(0, 0, self.searchListView.frame.size.width, self.searchListView.frame.size.height);
        [self.searchResultList reloadData];
        
        self.listFavView.hidden =YES;
        self.listDownloadView.hidden =YES;
        self.listSearchView.hidden =NO;
    }
    
    if(displayState == DISPLAY_STATE_SEARCHING)
    {
    
    
    
    
    }
    
    if(displayState == DISPLAY_STATE_RESULTS)
    {
        self.backButton.hidden = NO;
        self.favoriteSaveButton.hidden = NO;
        self.searchTitle.text =@"搜 索 结 果"; 
        self.searchResultCoverView.hidden = YES;
        
        self.advanedView.hidden = YES;
        self.searchResultList.frame = CGRectMake(0, 0, self.searchListView.frame.size.width, self.searchListView.frame.size.height);
        
        self.listFavView.hidden =YES;
        self.listDownloadView.hidden =YES;
        self.listSearchView.hidden =NO;
        
        //if(searchingType == SEARCHING_TYPE_ADVANCED)
        //{
        //    lastDisplayState = DISPLAY_STATE_RESULTS;
        //    [self advViewHide];
        //}   
    }
    
    if(displayState == DISPLAY_STATE_SUGGESTION)
    {   
        self.backButton.hidden = YES;
        self.favoriteSaveButton.hidden = YES;
        self.searchTitle.text =@"文 献 搜 索"; 
        self.searchResultList.frame = CGRectMake(0, 0, self.searchListView.frame.size.width, 300);
        //self.searchResultCoverView.hidden = NO;
        [self.searchResultList reloadData];
        
        //self.listFavView.hidden =YES;
        //self.listDownloadView.hidden =YES;
        //self.listSearchView.hidden =NO;
    
    }    
    
    if(displayState == DISPLAY_STATE_FAVORATE)
    {
        self.listFavView.hidden =NO;
        self.listDownloadView.hidden =YES;
        self.listSearchView.hidden =YES;
        [self.favList reloadData];
        
        self.searchResultCoverView.hidden = NO;
    }
    
    if(displayState == DISPLAY_STATE_DOWNLOADED)
    {
        self.listFavView.hidden =YES;
        self.listDownloadView.hidden =NO;
        self.listSearchView.hidden =YES;
        [self.downList reloadData];
        
        self.searchResultCoverView.hidden = NO;
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




-(void)filterButtonTapped:(id)sender
{
    
    NSLog(@"filter tapped");
    
    if(filterPopoverController!=nil)
    {
        [filterPopoverController release];   
    }
    
    
    filterTableController *content = [[filterTableController alloc] initWithNibName:@"filterTableController" bundle:nil];
    content.searchLanguage = currentSearchLanguage;
    
    filterPopoverController = [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    content.tag =[sender tag];
    
    
	filterPopoverController.popoverContentSize = CGSizeMake(300., 300.);
	filterPopoverController.delegate = self;
    
    advancedQueryItemsCell* t =(advancedQueryItemsCell*)sender;
    
    
    CGRect frame=CGRectMake(t.frame.origin.x + t.filterButton.frame.origin.x+70, t.frame.origin.y + t.filterButton.frame.origin.y+88, t.filterButton.frame.size.width, t.filterButton.frame.size.height);
    
    
    // Present the popover from the button that was tapped in the detail view.
	[filterPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [content release];
}

#pragma mark - adv delegate method

- (void)filterSelected:(id)sender
{   
    filterTableController* filterController =(filterTableController*)sender;
                                    
    //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
    
    //NSDictionary * filtersCN = [[[NSDictionary alloc] initWithObjects:[filterItemData objectForKey:@"CN_KEY"] forKeys:[filterItemData objectForKey:@"CN_TEXT"]] autorelease];
    
    //NSDictionary * filtersEN = [[[NSDictionary alloc] initWithObjects:[filterItemData objectForKey:@"CN_KEY"] forKeys:[filterItemData objectForKey:@"CN_TEXT"]] autorelease];
    
    
    //NSString* filterString =[filtersCN objectForKey:filterController.filterString];
        
    [filterNames replaceObjectAtIndex:filterController.tag withObject:filterController.filterString];
    
    
    //NSLog(@"tag %d",filterController.tag);
    NSLog(@"filterString %@",filterController.filterString);
    //NSLog(@"%@",filterNames);
    
    
    [filterPopoverController dismissPopoverAnimated:YES];
    [self.advSearchList reloadData];

}


-(void)selectedOperation:(id)sender
{
    advancedQueryItemsCell* cell = (advancedQueryItemsCell*)sender;
    
    if(cell.selectedOperation == OPERATION_AND)
        [filterOperations replaceObjectAtIndex:cell.tag withObject:[NSNumber numberWithInt:OPERATION_AND]]; 
    else if(cell.selectedOperation == OPERATION_OR)
        [filterOperations replaceObjectAtIndex:cell.tag withObject:[NSNumber numberWithInt:OPERATION_OR]];
    else    
        [filterOperations replaceObjectAtIndex:cell.tag withObject:[NSNumber numberWithInt:OPERATION_NOT]];
        
    //NSLog(@"%@",filterOperations);
}

-(void)textValueInputed:(id)sender
{
    advancedQueryItemsCell* t =(advancedQueryItemsCell*)sender;
    
    [filterValues replaceObjectAtIndex:t.tag withObject:t.conditionText.text]; 
    
    //NSLog(@"%@",filterValues);
    
}


-(void)minYearButtonTapped:(id)sender
{
    advancedYearItemsCell* t =(advancedYearItemsCell*)sender;
    
    NSLog(@"x = %f",t.frame.origin.x + t.minYear.frame.origin.x);
    NSLog(@"y = %f",t.frame.origin.y + t.minYear.frame.origin.y);
    
    CGRect frame=CGRectMake(t.frame.origin.x + t.minYear.frame.origin.x+70, t.frame.origin.y + t.minYear.frame.origin.y+44+44, t.minYear.frame.size.width, t.minYear.frame.size.height); 
    
    popedYearButton = 0;
    
    [yearPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}


-(void)maxYearButtonTapped:(id)sender
{
    advancedYearItemsCell* t =(advancedYearItemsCell*)sender;
    
    NSLog(@"x = %f",t.frame.origin.x + t.maxYear.frame.origin.x);
    NSLog(@"y = %f",t.frame.origin.y + t.maxYear.frame.origin.y);
    
    CGRect frame=CGRectMake(t.frame.origin.x + t.maxYear.frame.origin.x+70, t.frame.origin.y + t.maxYear.frame.origin.y+44+44, t.maxYear.frame.size.width, t.maxYear.frame.size.height); 
    
    popedYearButton = 1;
    
    [yearPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}


-(void)selectedYear:(id)sender
{
    NSString* y =(NSString*)sender;
    if(popedYearButton == 0)
        minYear =y;
    else
        maxYear =y;
    
    [self.advSearchList reloadData];
    [yearPopoverController dismissPopoverAnimated:YES];
        
}

-(void)advSearchButtonTapped:(id)sender
{
    
    NSString* v0 =[filterValues objectAtIndex:0];
    NSString* f0 =[filterNames objectAtIndex:0];
    
    
    if(currentSearchLanguage == SEARCH_MODE_EN)
    {
        //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
         filterItemData = [self readPListBundleFile:@"searchFilters"];
        NSDictionary * filtersCN = [[[NSDictionary alloc] initWithObjects:[filterItemData objectForKey:@"EN_KEY"] forKeys:[filterItemData objectForKey:@"EN_TEXT"]] autorelease];
        f0 =[filtersCN objectForKey:f0];
        NSLog(@"f0= %@",f0);

    }
    else
    {
    
        //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
         filterItemData = [self readPListBundleFile:@"searchFilters"];
        NSDictionary * filtersCN = [[[NSDictionary alloc] initWithObjects:[filterItemData objectForKey:@"CN_KEY"] forKeys:[filterItemData objectForKey:@"CN_TEXT"]] autorelease];
        f0 =[filtersCN objectForKey:f0];
        NSLog(@"f0= %@",f0);

    }
    
    NSString* startField=[imdSearcher getSearcherStartFieldItem:v0 Filter:f0];
    NSLog(@"startField %@",startField);
    
    NSMutableString* s = [[[NSMutableString alloc] initWithFormat:@""] autorelease];
    
    if(advancedQueryItemCount >0)
    {
        for (int i=0; i<advancedQueryItemCount; i++) 
        {
            NSString* v =[filterValues objectAtIndex:i];
            NSString* f =[filterNames objectAtIndex:i];
            
            
            //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
            if(currentSearchLanguage == SEARCH_MODE_EN)
            {
                //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
                 filterItemData = [self readPListBundleFile:@"searchFilters"];
                NSDictionary * filtersCN = [[[NSDictionary alloc] initWithObjects:[filterItemData objectForKey:@"EN_KEY"] forKeys:[filterItemData objectForKey:@"EN_TEXT"]] autorelease];
                f =[filtersCN objectForKey:f];
                NSLog(@"f0= %@",f);
                
            }
            else
            {
                
                //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
                 filterItemData = [self readPListBundleFile:@"searchFilters"];
                NSDictionary * filtersCN = [[[NSDictionary alloc] initWithObjects:[filterItemData objectForKey:@"CN_KEY"] forKeys:[filterItemData objectForKey:@"CN_TEXT"]] autorelease];
                f =[filtersCN objectForKey:f];
                NSLog(@"f0= %@",f);
                
            }
            
            
            int oValue =[[filterOperations objectAtIndex:i] intValue];
            
            NSString* o =@"";
            if(oValue == OPERATION_AND)
            {
               o =@"AND";
            }   
            else if(oValue == OPERATION_OR)
            {
                o =@"Or";
            }   
            else if(oValue == OPERATION_NOT)
            {
                o =@"Not";
            }   
            
            
            NSLog(@"i=%d",i);
            NSString* qs=[imdSearcher getSearcherQueryItem:v Filter:f Operation:o];
            NSLog(@"qs=%@",qs);
            
            if(![qs isEqualToString:@""])
            {   
                if(![s isEqualToString:@""])
                    [s appendString:@","];
                
                [s appendString:qs] ;
            }   
        }
    }
    
    
    NSLog(@"items %@",s);
    BOOL isCoreJournal = NO;
    if (currentSearchLanguage == SEARCH_MODE_CN && coreJournalOn)
    {
        isCoreJournal = YES;
        
        NSLog(@"is core journal");
    }
    
    
    if(newSearchStart) 
        fetchingPage =1;
    else
        fetchingPage = currentPage+1;
        
    [imdSearcher advacedSearch:startField QueryItems:s Option:@"" Page:fetchingPage Lan:currentSearchLanguage minYear:minYear maxYear:maxYear sort:sortMethod coreJournal:isCoreJournal Delegate:self];
    
    
    [self.currentKeybordHolder resignFirstResponder];
    
   
}
#pragma mark - setting delegate

- (void)closeSetting:(id)sender
{

    [self dismissModalViewControllerAnimated:YES]; 
    currentActionSelected = SIDEACTION_SEARCH;
    displayState = DISPLAY_STATE_FRONTPAGE;
    
    [self refreshSideActionButtons];
    [self displayStates];
    

}



-(void)presentSettingWindow
{

    settingViewController* m=[[settingViewController alloc] initWithNibName:@"settingViewController" bundle:nil];
    
    m.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:m animated:YES];
    
    m.view.superview.frame = CGRectMake(512-305, 384-200,611, 480);//it's important to do this after 
    m.delegate =self;
    [m release];
    
}

#pragma mark - login delegate
- (void)closeLogin:(id)sender
{

  [self dismissModalViewControllerAnimated:YES];

}

-(void)presentLoginWindow:(id)sender
{
    
    loginViewController* m=[[loginViewController alloc] initWithNibName:@"loginViewController" bundle:nil];
    
    m.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:m animated:YES];
    
    m.view.superview.frame = CGRectMake(512-305, 384-200,611, 480);//it's important to do this after 
    m.delegate =self;
    self.mainLoginViewController =m;
    [m release];
    
}

- (void)login:(id)sender
{
    [self closeSetting:nil];
    
    [self performSelector:@selector(presentLoginWindow:) withObject:nil afterDelay:0.8f];
    

  
}

#pragma mark - result details actions
-(IBAction)detailsFontZoomOut:(id)sender
{
   if(inFullText)
   {
       [self pdfZoomOut];
       return;
   }    
       
    
   //FONT -
   if( currentDetailsFontSizeOffset == FONT_OFFSET_ZERO)
       currentDetailsFontSizeOffset = FONT_OFFSET_MINUS;
   else if(currentDetailsFontSizeOffset == FONT_OFFSET_PLUS)
       currentDetailsFontSizeOffset = FONT_OFFSET_ZERO;
    
    [self displayDetails]; 
    
}

-(IBAction)detailsFontZoomIn:(id)sender
{
    if(inFullText)
    {
        [self pdfZoomIn];
        return;
    }    
    
   //FONT +
    if( currentDetailsFontSizeOffset == FONT_OFFSET_ZERO)
        currentDetailsFontSizeOffset = FONT_OFFSET_PLUS;
    else if(currentDetailsFontSizeOffset == FONT_OFFSET_MINUS)
        currentDetailsFontSizeOffset = FONT_OFFSET_ZERO;
    
   [self displayDetails]; 
}



-(IBAction)detailsAddFav:(id)sender
{

  //todo: check if logined in
    
  //docsearch/fav/:id/:title/  
   
    NSArray* results =[self.searchedResult objectForKey:@"results"];
    
    if(results == (id)[NSNull null]  || [results count] ==0)
    {
        NSLog(@"no results");
        return;
    }
    
    //NSLog(@"results = %@",results);
    
    NSDictionary* result =[results objectAtIndex:currentDisplayingRow];
    NSString* eId =[result objectForKey:@"externalId"];
    NSString* title = [result objectForKey:@"title"];
    title = [Util replaceEM:title LeftMark:@"" RightMark:@""]; 
    title =[Util URLencode:title stringEncoding:NSUTF8StringEncoding];
    
    NSString* addFavURL =[NSString stringWithFormat:@"http://%@/docsearch/fav/%@/%@",SEARCH_SERVER,eId,title];
    
    NSLog(@"url = %@",addFavURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:addFavURL]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
     
     NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
     NSLog(@"token =%@",token);
     //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:YES];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"addFav" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    [userInfo release];
    
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    
    [cookie release];
    [properties release];

}



-(IBAction)detailsDownFullText:(id)sender
{
    NSLog(@"add to list");
    
    NSArray* results =[self.searchedResult objectForKey:@"results"];
    
    if(results == (id)[NSNull null]  || [results count] ==0)
    {
        NSLog(@"no results");
        return;
    }
    
     NSLog(@"results = %@",results);

    NSDictionary* result =[results objectAtIndex:currentDisplayingRow];
    NSString* eId =[result objectForKey:@"externalId"];
    
    NSLog(@"eid %@",eId);
    
    NSMutableDictionary* a = [[NSMutableDictionary alloc] initWithCapacity:5];
    [a setObject:[result objectForKey:@"title"] forKey:@"title"];
    [a setObject:[result objectForKey:@"author"] forKey:@"author"];
    [a setObject:[result objectForKey:@"pubDate"] forKey:@"pubDate"];
    [a setObject:[result objectForKey:@"journal"] forKey:@"journal"];    
    [a setObject:eId forKey:@"externalId"];
    
     NSLog(@"a ok");
    
    int c= [self.downloadArrays count];
    BOOL inList = NO;
    
    for(int i =0;i<c;i++)
    {
        NSDictionary* m =[self.downloadArrays objectAtIndex:i];
        if([eId isEqualToString:[m objectForKey:@"externalId"]])
        {
            inList =YES;
            break; 
        }   
    
    }
    
    NSLog(@"inList ok");
    
    if(!inList)
    {    
      [self.downloadArrays addObject:a];
    
      [[NSUserDefaults standardUserDefaults] setObject:self.downloadArrays forKey:@"downlaodArrays"];
      [[NSUserDefaults standardUserDefaults] synchronize];
    }  
    [a release];
    
    NSLog(@"%@",self.downloadArrays);
}

-(IBAction)fulltextButtonTapped
{
    if(inFullText)
    {    
        inFullText =NO;
        self.pageNo.hidden = YES;
        //[self.switchButton setTitle:@"全文" forState:UIControlStateNormal];
        [self.switchButton setImage:[UIImage imageNamed:@"btn-fulltext.png"] forState:UIControlStateNormal];
        
        [self displayDetails];
        NSLog(@"back to normal text");
        return;
    }
    
    inFullText = YES;
    self.pageNo.hidden =NO;
    
    //[self.switchButton setTitle:@"摘要" forState:UIControlStateNormal];
    [self.switchButton setImage:[UIImage imageNamed:@"btn-abstract.png"] forState:UIControlStateNormal];
    

    
    if (currentSearchLanguage == SEARCH_MODE_CN) 
    {
        
        NSLog(@"cn fulltext");
       
        NSArray* results =[self.searchedResult objectForKey:@"results"];
        NSDictionary* result =[results objectAtIndex:currentDisplayingRow];
        
        NSString* textId = [NSString stringWithFormat:@"%@",
        [result objectForKey:@"externalId"]];
        
        //textId = @"result.pdf";
        
         //check file exist;
        
        NSString *filePath =
		[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:textId];
        NSLog(@"filePath %@",filePath);
        
        //check if local file exitst, if exist just display it 
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
         {
            NSLog(@"found local file %@",[filePath lastPathComponent]);
        
             
                 
            if(![self loadPDF:[filePath lastPathComponent]])
            {
               NSLog(@"load pdf failed");
                     
               self.loadingLabel.hidden = YES;
               [self.loadingIndicator stopAnimating];
               self.errorLabel.text =@"pdf出错,请稍侯重试";
                self.errorLabel.hidden =NO; 
                //displayState = DISPLAY_STATE_FRONTPAGE;
               // [self displayStates];
                
                
                // dont del for now
                /*
                NSError *error;
                if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
                {
                    //TODO: Handle/Log error
                    
                    NSLog(@"del failed %@",error);
                }*/

                return;
                     //self.PDFErrorLabel.hidden = NO;
             }
             
             self.searchResultCoverView.hidden =YES;
             self.detailView.hidden =NO;
             self.AbstractTextScrollView.hidden =YES; 
             
             
             
            return;
         }   
        

        
        
        self.searchResultCoverView.hidden =NO;
        self.loadingLabel.hidden = NO;
        [self.loadingIndicator startAnimating];
        self.errorLabel.hidden =YES;
        
        
       
        
        
        NSString* fileURL = [NSString stringWithFormat:@"http://%@/docsearch/download/%@/",PDFPROCESS_SERVER,textId];  
        
        NSLog(@"url a = %@",fileURL);
        self.fullTextDownloader = nil;
        
        self.fullTextDownloader = [downloader requestWithURL:[NSURL URLWithString:fileURL]];
        //self.fullTextDownloader.fileName = @"result.pdf";
        self.fullTextDownloader.fileName =[NSString stringWithFormat:@"%@", 
        textId];
        
        self.fullTextDownloader.fileURL = fileURL;
        
        self.fullTextDownloader.filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:self.fullTextDownloader.fileName];
        
        self.fullTextDownloader.timeOutSeconds = 120;
        
        //self.fullTextDownloader.downloadType = MEETING_SLIDERS;
        self.fullTextDownloader.retryingTimes = 0;
        self.fullTextDownloader.retryingMaxTimes = 1;
        
        [self.fullTextDownloader setDownloadDestinationPath:self.fullTextDownloader.filePath];
        
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];  
        [userInfo setObject:@"requestPDF" forKey:@"requestType"];
        [userInfo setObject:self.fullTextDownloader.fileName forKey:@"downloadFile"];
        
        [self.fullTextDownloader setUserInfo:userInfo];
        [userInfo release];  
        
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
        NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
        NSLog(@"token =%@",token);
        //[request addRequestHeader:@"Cookie" value:token];
        
        //Create a cookie
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/download"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [self.fullTextDownloader setUseCookiePersistence:NO];
        [self.fullTextDownloader setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        [self.fullTextDownloader setUserAgent:@"imd-ios"];
        
        
        self.fullTextDownloader.delegate = self;
        [self.fullTextDownloader startAsynchronous];
        [cookie release];         
        [properties release];
        
        //isLoading = YES;
        //[appDelegate setIsLoading:YES];
    }
    else
    {   
        self.switchButton.hidden = YES;
       /* NSLog(@"en fulltext");
        
        NSArray* results =[self.searchedResult objectForKey:@"results"];
        NSDictionary* result =[results objectAtIndex:currentRow];
        
        NSString* doi = [result objectForKey:@"DOI"];
        NSString* pmc = [result objectForKey:@"PMCID"];
        
        NSString* textId = [result objectForKey:@"externalId"];
        
        NSString *urlAddress;
        BOOL hasWebLink = NO;
        
        if(doi != nil)
        {
            urlAddress = [NSString stringWithFormat:@"http://dx.doi.org/%@",doi];
            hasWebLink = YES;
            NSLog(@"DOI");
        }
        else if(pmc != nil)
        {
            urlAddress = [NSString stringWithFormat:@"http://www.ncbi.nlm.nih.gov/pmc/articles/%@",pmc];
            hasWebLink = YES;
            NSLog(@"PMC");
            
        }    
        
        if(hasWebLink)
        { 
            self.fullTextWebView.hidden = NO;
            self.fullTextAskView.hidden = YES;
            
            self.prePageButton.hidden = YES;
            self.nextPageButton.hidden = YES;
            
            //Create a URL object.
            NSURL *url = [NSURL URLWithString:urlAddress];
            //URL Requst Object
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            //Load the request in the UIWebView.
            [self.fullTextWebView loadRequest:requestObj];
        }
        else
        {
            //ask for 
            self.fullTextWebView.hidden = YES;
            self.fullTextAskView.hidden = NO;
            
            self.prePageButton.hidden = YES;
            self.nextPageButton.hidden = YES;
            
            NSLog(@"ask %@",textId);
            
            
            [self askForFullText];
            
            
            
            
            
        }*/    
    }    
    
}

-(IBAction)detailsShare:(id)sender
{
    
    if(sharePopoverController!=nil)
    {
        [sharePopoverController release];   
    }
    
    
    shareSelectViewController *content = [[shareSelectViewController alloc] initWithNibName:@"shareSelectViewController" bundle:nil];
    //content.searchLanguage = currentSearchLanguage;
    
    sharePopoverController= [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    //content.tag =[sender tag];
    
	sharePopoverController.popoverContentSize = CGSizeMake(280., 150.);
	sharePopoverController.delegate = self;
    
    UIButton* t =(UIButton*)sender;
    
    
    CGRect frame=CGRectMake(t.frame.origin.x +420, t.frame.origin.y, t.frame.size.width, t.frame.size.height);
    
    
    // Present the popover from the button that was tapped in the detail view.
	[sharePopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [content release];
    


}

#pragma mark - share function

- (void)shareSelected:(id)sender
{
    [sharePopoverController dismissPopoverAnimated:YES];
    
    NSLog(@"share selected");


}

#pragma mark - polling functions
- (IBAction)backToCallingApp:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"NovartisDemo:meeting"];  
    [[UIApplication sharedApplication] openURL:url];
}


-(void)registerOK:(id)sender
{
    //[poller startPolling];

}

#pragma mark - page controls
-(IBAction) nextPage
{
    
    if(pdfValue == self.pdfView.pageCount) return;
    
    pdfValue++;
    if(pdfValue>=self.pdfView.pageCount)
    {
        pdfValue=self.pdfView.pageCount;
    }
    
    //NSLog(@"next page will be %f",self.pdfSlider.value);
    
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    
    animation.type = kCATransitionPush;//kCATransitionMoveIn;
    animation.subtype = kCATransitionFromRight;
    
    
    [self.pdfView.layer addAnimation:animation forKey:@"animationLeft"];         
    
    [self.pdfView gotoPage:pdfValue];
    
    self.pageNo.text =[NSString stringWithFormat:@"%d/%d",pdfValue,self.pdfView.pageCount];
}




-(IBAction) prePage
{
    
    if(pdfValue == 1) return;
    
    pdfValue--;
    if(pdfValue<=1)
    {    
        pdfValue=1;
    }   
    
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    
    animation.type = kCATransitionPush;//kCATransitionMoveIn;
    animation.subtype = kCATransitionFromLeft;
    
    
    [self.pdfView.layer addAnimation:animation forKey:@"animationRight"];         
    
    [self.pdfView gotoPage:pdfValue];
    
    self.pageNo.text =[NSString stringWithFormat:@"%d/%d",pdfValue,self.pdfView.pageCount];
    
}


- (void)pdfHandleAllSwipes:(UISwipeGestureRecognizer *)recognizer
{
	
    if (recognizer.direction & UISwipeGestureRecognizerDirectionLeft)
    {
		NSLog(@"left");
        
        [self nextPage];         
        return;
    }
    
    if (recognizer.direction & UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@"right");
        
        [self prePage];
        return;
		
	}
}

#pragma mark - zoom
-(IBAction)pdfZoomOut
{
    
    CGFloat zoomScale = self.detailView.zoomScale;
    zoomScale -=0.2f;
    [self.detailView setZoomScale:zoomScale animated:YES];
    
}

-(IBAction)pdfZoomIn
{
    CGFloat zoomScale = self.detailView.zoomScale;
    zoomScale +=0.2f;
    [self.detailView setZoomScale:zoomScale animated:YES];
    
}

#pragma mark - UIScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  self.pdfView;
}


-(void)handleOneTouch:(UITapGestureRecognizer *)recognizer
{
    
    NSLog(@"handle one touch called");
 	NSInteger numberOfTaps = recognizer.numberOfTapsRequired;
    
    if(2 == numberOfTaps)
    {
        [self.detailView setZoomScale:1.0f animated:YES];
        
    }
    
}

- (void)startReady
{
   self.startCover.hidden = YES;

}

- (void)loadFav
{
    //docsearch/favs/?
    
    NSString* listFavURL =[NSString stringWithFormat:@"http://%@/docsearch/favs",SEARCH_SERVER];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:listFavURL]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
    
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:YES];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"listFav" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    [userInfo release];
    
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    [request startAsynchronous];
    
    [cookie release];
    [properties release];

}


- (IBAction)EditButtonTapped
{
    if([self.favList isEditing])
    {
        [self.favList setEditing:NO animated:YES];
        [self.favEditButton setTitle:@"编辑" forState:UIControlStateNormal];
    
    }    
    else
    {
        [self.favList setEditing:YES animated:YES];
        [self.favEditButton setTitle:@"返回" forState:UIControlStateNormal];
    }
  





}

@end
