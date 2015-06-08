//
//  AdvSearchViewController.m
//  imdSearch
//
//  Created by  侯建政 on 9/13/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "AdvSearchViewController.h"
#import "advancedYearItemsCell.h"
#import "advancedQueryItemsCell.h"
#import "imdSearcher.h"
#import "filterTableController.h"
#import "yearTableController.h"
#import "NetStatusChecker.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "JSON.h"
#import "TKAlertCenter.h"

@interface AdvSearchViewController ()

@end

@implementation AdvSearchViewController
@synthesize httpRequestSearchAdvanceSearch;
@synthesize filterItemData;
@synthesize delegate;
@synthesize currentKeybordHolder;
@synthesize newSearchStart;
@synthesize currentPage;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UISwipeGestureRecognizer *swipeGesture = nil;
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(advSearchHandleAllSwipes:)];
    
	swipeGesture.cancelsTouchesInView = NO;
    swipeGesture.delaysTouchesEnded = NO;
    swipeGesture.delegate = self;
	swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.tableView addGestureRecognizer:swipeGesture];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 348, 50)];
    self.tableView.tableFooterView =footer;
    self.filterItemData = [NSMutableDictionary dictionaryWithDictionary:[self readPListBundleFile:@"searchFilters"]];
    filterNames = [[NSMutableArray alloc] init];
    filterValues = [[NSMutableArray alloc] init];
    filterOperations = [[NSMutableArray alloc] init];
    advancedQueryItemCount = 1;
    advancedQueryItemCountMax = 4;
    
    for(int i =0; i<advancedQueryItemCountMax ;i++)
    {
        if(currentSearchLanguage == SEARCH_MODE_CN)
        {
            NSArray* TextCN = [self.filterItemData objectForKey:@"CN_TEXT"];
            [filterNames addObject:[TextCN objectAtIndex:0]];
        }
        else
        {
            NSArray* TextEN = [self.filterItemData objectForKey:@"EN_TEXT"];
            [filterNames addObject:[TextEN objectAtIndex:0]];
        }
        
        [filterValues addObject:@""];
        [filterOperations addObject:[NSNumber numberWithInt:OPERATION_AND]];
    }
    
    coreJournalOn =NO;
    sciOn = NO;
    reviewsOn = NO;
    minYear = @"";
    maxYear = @"";
    sortMethod =@"5";
    
    yearTableController *content = [[yearTableController alloc] initWithNibName:@"yearTableController" bundle:nil];
    
    yearPopoverController = [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    
    yearPopoverController.popoverContentSize = CGSizeMake(320., 480.);
    yearPopoverController.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

#pragma mark - talbe delegate & datasource
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"langSetCell";
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
          UISegmentedControl *segLanguage = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"中文文献",@"英文文献",nil]];
          segLanguage.segmentedControlStyle = UISegmentedControlStylePlain;
          segLanguage.selectedSegmentIndex = currentSearchLanguage;
          segLanguage.tintColor = APPDefaultColor;
          
          segLanguage.frame =CGRectMake(20,7, 300, 30);
          if (!(IOS7)) {
            segLanguage.layer.borderColor = APPDefaultColor.CGColor;
            segLanguage.layer.borderWidth = 1.0f;
            segLanguage.layer.cornerRadius = 4.0f;
            segLanguage.layer.masksToBounds = YES;
          }
          
          [segLanguage addTarget:self action:@selector(advChangeLanguage:) forControlEvents:UIControlEventValueChanged];
          
          cell.accessoryView = segLanguage;
          
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
//        for (UIView *view in [cell subviews]) {
//            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UISegmentedControl class]])
//                [view removeFromSuperview];
//        }
      
//        cell.textLabel.text = @"文献数据库";
//        cell.textLabel.frame = CGRectMake(22, 6, 120, 32);
//        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        return cell;
    }
    
    if(indexPath.section == 1)
    {
        static NSString *QueryItemTableIdentifier = @"advancedQueryItem";
        
        advancedQueryItemsCell *cell = (advancedQueryItemsCell*)[tableView dequeueReusableCellWithIdentifier: QueryItemTableIdentifier];
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"advancedTableCell" owner:self options:nil];
        
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[advancedQueryItemsCell class]]) {
                cell = (advancedQueryItemsCell*)oneObject;
            }
        
        if (cell == nil){
            cell = [[advancedQueryItemsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:QueryItemTableIdentifier];
        }
        
        self.tableView.separatorStyle = NO;
        
        cell.conditionText.text = [filterValues objectAtIndex:indexPath.row];
        
        cell.conditionText.delegate = cell;
        
        //NSString* s =[filterNames objectAtIndex:indexPath.row];
        //NSLog(@"s= %@",s);
        
        [cell.filterButton setTitle:[filterNames objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        
        cell.selectedOperation=[[filterOperations objectAtIndex:indexPath.row] intValue];
        
        [cell displayOperations];
        [cell addTextChange];
        
        cell.delegate = self;
        cell.tag = indexPath.row;
        
        if(indexPath.row == 0)
            cell.minusButton.hidden =YES;
        
        if(indexPath.row == advancedQueryItemCount - 1)
            [cell hideOperations];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if(indexPath.section == 2)
    {
        static NSString *advCellIdentifier = @"advCellAddFields";
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:advCellIdentifier];
      
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:advCellIdentifier];
          UIButton* addButton = [UIButton buttonWithType:UIButtonTypeCustom];
          [addButton setImage:[UIImage imageNamed:@"btn-plus"] forState:UIControlStateNormal];
            //[addButton setImage:[UIImage imageNamed:@"btn-addField-highlight"] forState:UIControlStateHighlighted];
          
          [addButton addTarget:self action:@selector(addQueryItem:) forControlEvents:UIControlEventTouchUpInside];
          addButton.frame = CGRectMake(10, 14, 22, 22);
          [cell addSubview:addButton];
          
          UILabel* addDisc =[[UILabel alloc] initWithFrame:CGRectMake(70, 7, 200, 30)];
          addDisc.text = @"添加检索字段";
          addDisc.textColor = APPDefaultColor;
          addDisc.backgroundColor = [UIColor clearColor];
          
          [cell addSubview:addDisc];
          
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    if(indexPath.section == 3)
    {
        static NSString *QueryItemTableIdentifier = @"advancedYearSel";
        
        advancedYearItemsCell *cell = (advancedYearItemsCell*)[tableView dequeueReusableCellWithIdentifier: QueryItemTableIdentifier];
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"advancedTableCell" owner:self options:nil];
        
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[advancedYearItemsCell class]]) {
                cell = (advancedYearItemsCell*)oneObject;
            }
        
        if (cell == nil) {
            cell = [[advancedYearItemsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:QueryItemTableIdentifier];
        }
        
        [cell.maxYear  setTitle:maxYear forState:UIControlStateNormal];
        [cell.minYear  setTitle:minYear forState:UIControlStateNormal];
        
        cell.delegate =self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    
    if (indexPath.section == 4)
    {
        if (currentSearchLanguage ==SEARCH_MODE_CN)
        {
            static NSString *caCellIdentifier = @"coreCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:caCellIdentifier];
            
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:caCellIdentifier];
              UISwitch* caSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, 7, 150, 30)];
              caSwitch.onTintColor = APPDefaultColor;
              [caSwitch setOn:coreJournalOn];
              [cell addSubview:caSwitch];
              coreJournalSwitch = caSwitch;
              
              UILabel* lblDocTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 120, 32)];
              
              lblDocTitle.text = @"核心期刊";
              lblDocTitle.font = [UIFont fontWithName:@"Palatino-Bold" size:17.0f];
              lblDocTitle.textColor = APPDefaultColor;
              
              lblDocTitle.backgroundColor = [UIColor clearColor];
              [cell addSubview:lblDocTitle];
              
              cell.selectionStyle = UITableViewCellSelectionStyleNone;

            }
            
//            for (UIView *view in [cell subviews]) {
//                if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UISwitch class]])
//                    [view removeFromSuperview];
//            }
          
            return cell;
        } else {
            static NSString *caCellIdentifier = @"sciCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:caCellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:caCellIdentifier];
              UISwitch* caSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, 8, 150, 30)];
              [caSwitch setOn:sciOn];
              [cell addSubview:caSwitch];
              sciSwitch = caSwitch;
              
              UILabel* lblDocTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 120, 32)];
              
              lblDocTitle.text = @"SCI";
              lblDocTitle.font = [UIFont fontWithName:@"Palatino-Bold" size:17.0f];
              
              
              lblDocTitle.backgroundColor = [UIColor clearColor];
              [cell addSubview:lblDocTitle];
              
              cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
          
            return cell;
        }
    }
    
    if (indexPath.section == 5 && currentSearchLanguage == SEARCH_MODE_EN) {
        static NSString *caCellIdentifier = @"reviewsCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:caCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:caCellIdentifier];
          UISwitch* caSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, 8, 150, 30)];
          [caSwitch setOn:reviewsOn];
          [cell addSubview:caSwitch];
          reviewsSwitch = caSwitch;
          
          UILabel* lblDocTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 120, 32)];
          
          lblDocTitle.text = @"综述";
          lblDocTitle.font = [UIFont fontWithName:@"Palatino-Bold" size:17.0f];
          
          lblDocTitle.backgroundColor = [UIColor clearColor];
          [cell addSubview:lblDocTitle];
          
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
//        for (UIView *view in [cell subviews]) {
//            if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UISwitch class]])
//                [view removeFromSuperview];
//        }
      
        
      
        return cell;
    }
    
    if((indexPath.section == 5 && currentSearchLanguage ==SEARCH_MODE_CN)||(indexPath.section == 6 && currentSearchLanguage ==SEARCH_MODE_EN))
    {
        static NSString *advCellIdentifier = @"advCellSearchButton";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:advCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:advCellIdentifier];
          UIButton* searchButton =[UIButton buttonWithType:UIButtonTypeCustom];
          [searchButton setTitle:@"开始检索" forState:UIControlStateNormal];
          [searchButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
          
          searchButton.frame = CGRectMake(20, 5, 300, 34);
          
            //cell.textLabel.text =@"adv";
          
          [searchButton addTarget:self action:@selector(newAdvSearch:) forControlEvents:UIControlEventTouchDown];
          
          [cell addSubview:searchButton];
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
//        for (UIView *view in [cell subviews]) {
//            if([view isKindOfClass:[UIButton class]])
//                [view removeFromSuperview];
//        }
        return cell;
    }
    
    static NSString *advCellIdentifier = @"advCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:advCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:advCellIdentifier];
        UIView *bgView = [[UIView alloc] init];
        [bgView setBackgroundColor:[UIColor colorWithWhite:2 alpha:0.2]];
        [cell setSelectedBackgroundView:bgView];
    }
    
    cell.textLabel.text =@"adv";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tableView)
    {
        if(currentSearchLanguage ==SEARCH_MODE_CN)
            return 6;
        else
            return 7;
    }
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section ==1)
    {
        NSLog(@"a count =%d",advancedQueryItemCount);
        
        return advancedQueryItemCount;
    }
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 384, 1)];
    v.backgroundColor = RGBACOLOR(200, 200, 200, 0.8);
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)  return 80;
    
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSDictionary*)readPListBundleFile:(NSString*)fileName
{
	NSString *plistPath;
	plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	
	NSMutableDictionary* temp = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
	if (!temp) {
		NSLog(@"Error reading plist of %@",fileName);
	}
	
	return temp;
}

-(void)advChangeLanguage:(id)sender
{
    UISegmentedControl* sw =(UISegmentedControl*)sender;
    if(sw.selectedSegmentIndex == SEARCH_MODE_CN)
    {
        [self changeLanguageTo:@"CN"];
    }
    else
    {
        [self changeLanguageTo:@"EN"];
    }
    
}

-(void)changeLanguageTo:(NSString*)lanStr
{
    if([lanStr isEqualToString:@"CN"])
    {
        currentSearchLanguage = SEARCH_MODE_CN;
    } else {
        currentSearchLanguage = SEARCH_MODE_EN;
    }
    
    [filterNames removeAllObjects];
    [filterItemData removeAllObjects];
    self.filterItemData = [NSMutableDictionary dictionaryWithDictionary:[self readPListBundleFile:@"searchFilters"]];
    
    for(int i =0; i<advancedQueryItemCountMax ;i++) {
        if(currentSearchLanguage == SEARCH_MODE_CN)
        {
            NSArray* TextCN = [self.filterItemData objectForKey:@"CN_TEXT"];
            [filterNames addObject:[TextCN objectAtIndex:0]];
        }
        else
        {
            NSArray* TextEN = [self.filterItemData objectForKey:@"EN_TEXT"];
            [filterNames addObject:[TextEN objectAtIndex:0]];
        }
    }
    
    [self.tableView reloadData];
}

-(void)filterButtonTapped:(id)sender
{
    
    NSLog(@"filter tapped");
    
    filterTableController *content = [[filterTableController alloc] initWithNibName:@"filterTableController" bundle:nil];
    content.searchLanguage = currentSearchLanguage;
    
    filterPopoverController = [[UIPopoverController alloc] initWithContentViewController:content];
    content.delegate =self;
    content.tag =[sender tag];
    
    
	filterPopoverController.popoverContentSize = CGSizeMake(300., 300.);
	filterPopoverController.delegate = self;
    
    advancedQueryItemsCell* t =(advancedQueryItemsCell*)sender;
    
    CGRect frame=CGRectMake(t.frame.origin.x + t.filterButton.frame.origin.x, t.frame.origin.y + t.filterButton.frame.origin.y, t.filterButton.frame.size.width, t.filterButton.frame.size.height);
    
    // Present the popover from the button that was tapped in the detail view.
	[filterPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (void)filterSelected:(id)sender
{
    filterTableController* filterController =(filterTableController*)sender;
    
    [filterNames replaceObjectAtIndex:filterController.tag withObject:filterController.filterString];
    
    //NSLog(@"tag %d",filterController.tag);
    NSLog(@"filterString %@",filterController.filterString);
    //NSLog(@"%@",filterNames);
    
    [filterPopoverController dismissPopoverAnimated:YES];
    [self.tableView reloadData];
    
}

-(void) addQueryItem:(id)sender
{
    advancedQueryItemCount ++;
    if(advancedQueryItemCount >advancedQueryItemCountMax)
    {
        advancedQueryItemCount =advancedQueryItemCountMax;
        return;
    }
    
    [self.tableView reloadData];
}

-(void) remvoeQueryItem:(id)sender
{
    if(advancedQueryItemCount ==1)return;
    
    advancedQueryItemsCell* cell =(advancedQueryItemsCell*)sender;
    
    int index =cell.tag;
    
    if(index < advancedQueryItemCount -1)
    {
        for(int i=index;i<advancedQueryItemCount-1;i++)
        {
            NSString* n =[filterNames objectAtIndex:i+1];
            NSString* v =[filterValues objectAtIndex:i+1];
            NSString* o =[filterOperations objectAtIndex:i+1];
            
            
            [filterNames replaceObjectAtIndex:i withObject:n];
            [filterValues replaceObjectAtIndex:i withObject:v];
            [filterOperations replaceObjectAtIndex:i withObject:o];
            
        }
    }
    advancedQueryItemCount--;
    
    [self.tableView reloadData];
}

-(void)minYearButtonTapped:(id)sender
{
    advancedYearItemsCell* t =(advancedYearItemsCell*)sender;
    
    NSLog(@"x = %f",t.frame.origin.x + t.minYear.frame.origin.x);
    NSLog(@"y = %f",t.frame.origin.y + t.minYear.frame.origin.y);
    
    CGRect frame=CGRectMake(t.frame.origin.x + t.minYear.frame.origin.x, t.frame.origin.y + t.minYear.frame.origin.y, t.minYear.frame.size.width, t.minYear.frame.size.height);
    
    popedYearButton = 0;
    
    [yearPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


-(void)maxYearButtonTapped:(id)sender
{
    advancedYearItemsCell* t =(advancedYearItemsCell*)sender;
    
    NSLog(@"x = %f",t.frame.origin.x + t.maxYear.frame.origin.x);
    NSLog(@"y = %f",t.frame.origin.y + t.maxYear.frame.origin.y);
    
    CGRect frame=CGRectMake(t.frame.origin.x + t.maxYear.frame.origin.x, t.frame.origin.y + t.maxYear.frame.origin.y, t.maxYear.frame.size.width, t.maxYear.frame.size.height);
    
    popedYearButton = 1;
    
    [yearPopoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)selectedYear:(id)sender
{
    NSString* y =(NSString*)sender;
    if([y isEqualToString:@"无限制"])
    {
        minYear =@"";
        maxYear =@"";
    } else {
        if(popedYearButton == 0)
            minYear =y;
        else
            maxYear =y;
        
    }
    
    [self.tableView reloadData];
    [yearPopoverController dismissPopoverAnimated:YES];
}

-(void)textValueInputed:(id)sender
{
    NSLog(@"text value inputed");
    
    advancedQueryItemsCell* t =(advancedQueryItemsCell*)sender;
    
    [filterValues replaceObjectAtIndex:t.tag withObject:t.conditionText.text];
    //t.conditionText.text = @"";
    NSLog(@"%@",filterValues);
}

-(void)newAdvSearch:(id)sender
{
    searchingType = SEARCHING_TYPE_ADVANCED;
    newSearchStart =YES;
    //  isAdvViewShow = false;
    [self advSearch:sender status:@"newAdvSearch" sort:nil];
    [self.currentKeybordHolder resignFirstResponder];
}

//adv request sort
-(void)advSearch:(id)sender status:(NSString *)status sort:(NSString*)sort
{
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        [self netWorksWarning];
        return;
    }
    if ([sort length]) {
        sortMethod = sort;
    }
    NSString* v0 =[filterValues objectAtIndex:0];
    NSString* f0 =[filterNames objectAtIndex:0];
    
    
    if(currentSearchLanguage == SEARCH_MODE_EN)
    {
        //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
        self.filterItemData = [NSMutableDictionary dictionaryWithDictionary:[self readPListBundleFile:@"searchFilters"]];
        NSDictionary * filtersCN = [[NSDictionary alloc] initWithObjects:[filterItemData objectForKey:@"EN_KEY"] forKeys:[filterItemData objectForKey:@"EN_TEXT"]];
        f0 =[filtersCN objectForKey:f0];
        NSLog(@"f0= %@",f0);
        
    } else {
        //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
        self.filterItemData = [NSMutableDictionary dictionaryWithDictionary:[self readPListBundleFile:@"searchFilters"]];
        NSDictionary * filtersCN = [[NSDictionary alloc] initWithObjects:[filterItemData objectForKey:@"CN_KEY"] forKeys:[filterItemData objectForKey:@"CN_TEXT"]];
        f0 =[filtersCN objectForKey:f0];
        NSLog(@"f0= %@",f0);
    }
    
    NSString* startField=[imdSearcher getSearcherStartFieldItem:v0 Filter:f0];
    NSLog(@"startField %@",startField);
    
    NSMutableString *s = [[NSMutableString alloc] initWithFormat:@""];
    
    if(advancedQueryItemCount >0)
    {
        for (int i=1; i<advancedQueryItemCount; i++)
        {
            NSString* v =[filterValues objectAtIndex:i];
            NSString* f =[filterNames objectAtIndex:i];
            
            
            //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
            if(currentSearchLanguage == SEARCH_MODE_EN)
            {
                //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
                self.filterItemData = [NSMutableDictionary dictionaryWithDictionary:[self readPListBundleFile:@"searchFilters"]];
                NSDictionary * filtersEN = [[NSDictionary alloc] initWithObjects:[filterItemData objectForKey:@"EN_KEY"] forKeys:[filterItemData objectForKey:@"EN_TEXT"]];
                f =[filtersEN objectForKey:f];
                //NSLog(@"f0= %@",f);
                
            } else {
                
                //NSDictionary* filterData = [self readPListBundleFile:@"searchFilters"];
                self.filterItemData = [NSMutableDictionary dictionaryWithDictionary:[self readPListBundleFile:@"searchFilters"]];
                NSDictionary * filtersCN = [[NSDictionary alloc] initWithObjects:[filterItemData objectForKey:@"CN_KEY"] forKeys:[filterItemData objectForKey:@"CN_TEXT"]];
                f =[filtersCN objectForKey:f];
                //NSLog(@"f0= %@",f);
                
            }
            
            
            int oValue =[[filterOperations objectAtIndex:i-1] intValue];
            
            NSString* o =@"";
            if(oValue == OPERATION_AND) {
                o =@"AND";
            } else if(oValue == OPERATION_OR) {
                o =@"Or";
            } else if(oValue == OPERATION_NOT) {
                o =@"Not";
            }
            
            
            NSLog(@"i=%d",i);
            NSString* qs=[imdSearcher getSearcherQueryItem:v Filter:f Operation:o];
            NSLog(@"qs=%@",qs);
            
            if(![qs isEqualToString:@""]) {
                if(![s isEqualToString:@""])
                    [s appendString:@","];
                
                [s appendString:qs] ;
            }
        }
    }
    
    NSLog(@"items %@",s);
    coreJournalOn  = coreJournalSwitch.on;
    sciOn = sciSwitch.on;
    reviewsOn = reviewsSwitch.on;
    
    if(newSearchStart)
        fetchingPage =1;
    else
        fetchingPage = currentPage+1;
    
    NSString* json = [NSString stringWithFormat:@"{\"type\":\"advance search\",\"lan\":%i,\"queryItems\":%@,\"page\":%i,\"minYear\":\"%@\",\"maxYear\":\"%@\",\"sort\":\"%@\",\"coreJournal\":\"%@\",\"sci\":\"%@\",\"reviews\":\"%@\"}", currentSearchLanguage, s, fetchingPage, minYear, maxYear, sortMethod, (coreJournalOn?@"Y":@"N"), (sciOn?@"Y":@"N"), (reviewsOn?@"Y":@"N")];
    
    if ([status isEqualToString:@"loadingNextBlock"]) {
        [ImdAppBehavior nextPageLog:[Util getUsername] MACAddr:[Util getMacAddress] SearchJson:json];
    } else if ([status isEqualToString:@"changeSort"]) {
        [ImdAppBehavior sortLog:[Util getUsername] MACAddr:[Util getMacAddress] sortName:json];
    } else if ([status isEqualToString:@"changeLanguageTo"]) {
        [ImdAppBehavior searchJsonLog:[Util getUsername] MACAddr:[Util getMacAddress] SearchJson:json];
    } else if ([status isEqualToString:@"newAdvSearch"]) {
        [ImdAppBehavior searchJsonLog:[Util getUsername] MACAddr:[Util getMacAddress] SearchJson:json];
    }
    
    if (currentSearchLanguage == SEARCH_MODE_CN) {
        self.httpRequestSearchAdvanceSearch = [self searchAdvanceSearchForCN:startField QueryItems:s Option:@"" Page:fetchingPage Lan:SEARCH_MODE_CN minYear:minYear maxYear:maxYear sort:sortMethod coreJournal:coreJournalOn Delegate:self];
    } else {
        self.httpRequestSearchAdvanceSearch = [self searchAdvanceSearchForEN:startField QueryItems:s Option:@"" Page:fetchingPage Lan:SEARCH_MODE_EN minYear:minYear maxYear:maxYear sort:sortMethod sci:sciOn reviews:reviewsOn Delegate:self];
    }
    
    [currentKeybordHolder resignFirstResponder];
    
}

#pragma mark HttpRequest
-(ASIHTTPRequest*)searchAdvanceSearchForCN:(NSString*)startField QueryItems:(NSString*)items Option:(NSString*)optionList Page:(int)page Lan:(int)LanMode minYear:(NSString*)miny maxYear:(NSString*)maxy sort:(NSString*)sort coreJournal:(BOOL)isCoreJournal Delegate:(id)d{
    if (self.httpRequestSearchAdvanceSearch != nil) {
        [self.httpRequestSearchAdvanceSearch cancel];
    }
    
    return [imdSearcher advacedSearch:startField QueryItems:items Option:optionList Page:page Lan:LanMode minYear:miny maxYear:maxy sort:sort coreJournal:isCoreJournal Delegate:d];
}

-(ASIHTTPRequest*)searchAdvanceSearchForEN:(NSString*)startField QueryItems:(NSString *)items Option:(NSString *)optionList Page:(int)page Lan:(int)LanMode minYear:(NSString *)miny maxYear:(NSString *)maxy sort:(NSString *)sort sci:(BOOL)isSci reviews:(BOOL)isReviews Delegate:(id)d{
    if (self.httpRequestSearchAdvanceSearch != nil) {
        [self.httpRequestSearchAdvanceSearch cancel];
    }
    return [imdSearcher advacedSearch:startField QueryItems:items Option:optionList Page:page Lan:LanMode minYear:miny maxYear:maxy sort:sort sci:isSci reviews:isReviews Delegate:d];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    
    NSDictionary* requestInfo =[request userInfo];
    NSLog(@".....%@",requestInfo);
    [self SendAdvValue:request];
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"isCanceled = %d", (int)[request isCancelled]);
}

-(void)SendAdvValue:(ASIHTTPRequest *)request{
    NSLog(@"fix changed");
    if (delegate && [delegate respondsToSelector:@selector(SendAdvValue:)])
    {
		[delegate performSelector:@selector(SendAdvValue:) withObject:request];
    }
    
}

#pragma mark - alertview warning
-(void)netWorksWarning{
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"无法连接到互联网，请查看设置"];
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

-(void)addKeyboardHolder:(id)sender{
    self.currentKeybordHolder  = sender;
}

-(void)removeKeyboardHolder:(id)sender{
    self.currentKeybordHolder  = nil;
}

-(void)tableViewReload{
    maxYear = @"";
    minYear = @"";
    for (int i=0 ; i<[filterValues count]; i++) {
        if (![[filterValues objectAtIndex:i] isEqualToString:@""]) {
            [filterValues replaceObjectAtIndex:i withObject:@""];
        }
    }
    
    for (int i=0 ; i<[filterNames count]; i++) {
        if (![[filterNames objectAtIndex:i] isEqualToString:@""]) {
            if (![[filterNames objectAtIndex:i] isEqualToString:@"标题"] ) {
                [filterNames replaceObjectAtIndex:i withObject:@"标题"];
            }
        }
    }
    
    advancedQueryItemCount = 1;
    currentSearchLanguage = 0;
    coreJournalOn =NO;
    sciOn = NO;
    reviewsOn = NO;
    [self.tableView reloadData];
}

//move adv
-(void)advSearchHandleAllSwipes:(UISwipeGestureRecognizer *)recognizer
{
    if (delegate && [delegate respondsToSelector:@selector(advSearchHandleAllSwipes:)]){
		[delegate performSelector:@selector(advSearchHandleAllSwipes:) withObject:recognizer];
    }
}
@end
