//
//  IPhoneMySearchController.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-22.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "IPhoneMySearchController.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "Strings.h"
#import "UrlRequest.h"
#import "DocArticleController.h"
#import "ImdUrlPath.h"
#import "UserManager.h"
#import "imdSearchAppDelegate.h"
#import "TableViewFormatUtil.h"
#import "ImageViews.h"
#import "IPhoneHeader.h"
#import "publicMySearch.h"
#import "MyDatabase.h"
#import "publicDoc.h"
#import "MyDataBaseSql.h"

@implementation IPhoneMySearchController

@synthesize favs;
@synthesize indicator, alertView;
@synthesize tableView = _tableView;
@synthesize noResultsView;
@synthesize httpRequest;
@synthesize mgrFavs;
@synthesize selectIndex;
@synthesize dicresultsJson;
@synthesize text,aaffiliation,author,category,citation,keywords,machineCategory,reference;
@synthesize refreshView;
@synthesize noResultsImageView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = MYFAVORITE_CN;
        UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithTitle:EDIT_CN style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditDone)];
        self.navigationItem.rightBarButtonItem = editBtn;
        
        [self.navigationController.navigationBar setTintColor:[UIColor clearColor]];
        alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
        
        self.tableView.hidden = YES;
        self.noResultsView.hidden = YES;
        mgrFavs = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)toggleEditDone
{
    
    if (self.tableView.isEditing) {
        [self.tableView setEditing:NO animated:YES];
        [TableViewFormatUtil setCustomBarButtonTitle:self.navigationItem.rightBarButtonItem title:EDIT_CN];
    } else {
        [self.tableView setEditing:YES animated:YES];
        [TableViewFormatUtil setCustomBarButtonTitle:self.navigationItem.rightBarButtonItem title:EDIT_DONE_CN];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.view.hidden = NO;
    self.tableView.hidden = NO;
    self.noResultsView.hidden = YES;
    
    [TableViewFormatUtil setShadow:self.navigationController.navigationBar];
    
    isUpdataDetail = NO;
    
    // 添加RefreshView到tableView
    NSArray *nils = [[NSBundle mainBundle]loadNibNamed:@"RefreshView" owner:self options:nil];
    self.refreshView = [nils objectAtIndex:0];
    [refreshView setupWithOwner:self.tableView delegate:self];
    if ([UserManager userName]) {
        [self sync];
        // 初始刷新
        [self refresh];
    }
    
    [super viewDidLoad];
}
// 开始，可以触发自己定义的开始方法
- (void)startLoading {
    [refreshView startLoading];
    
}
// 刷新
- (void)refresh {
    [self startLoading];
}
#pragma mark - RefreshViewDelegate
- (void)refreshViewDidCallBack {
    [self refresh];
    [self sync];
}
#pragma mark - UIScrollView
// 刚拖动的时候
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [refreshView scrollViewWillBeginDragging:scrollView];
}
// 拖动过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [refreshView scrollViewDidScroll:scrollView];
}
// 拖动结束后
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [refreshView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [TableViewFormatUtil setTableViewBackGround:self.tableView image:IMG_BG_CONTENTSBACKGROUDN];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (iPhone5) {
        noResultsImageView.frame = CGRectMake(0, 60, 320, 350);
    }
    self.favs = [MyDatabase readMgrData:IMD_Mydoc userid:[[NSUserDefaults standardUserDefaults]objectForKey:SAVED_USER]];
    [self.tableView reloadData];
    if (![self.favs count]) {
        self.noResultsView.hidden = NO;
        self.tableView.hidden = YES;
    }else {
        self.noResultsView.hidden = YES;
        self.tableView.hidden = NO;
    }
    if (!self.noResultsView.hidden) {
        [self sync];
    }
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
        return self.favs.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"favItem";
    
    NSDictionary* resultsItem = [self.favs objectAtIndex:indexPath.row];
    
    NSString* readed = [self.mgrFavs objectForKey:[resultsItem objectForKey:DOC_EXTERNALID]];
    
    return [TableViewFormatUtil formatCell:self.tableView CellIdentifier:cellIdentifier data:resultsItem unreadSign:![readed isEqualToString:DOC_READED]];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self removeFavs:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ( self.favs.count > 0) {
            self.noResultsView.hidden = YES;
            self.tableView.hidden = NO;
        } else {
            self.noResultsView.hidden = NO;
            self.tableView.hidden = YES;
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.imageView.image = nil;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    DocArticleController* docArticleController = [[DocArticleController alloc] initWithNibName:@"DocArticleController" bundle:nil];
    
    docArticleController.hidesBottomBarWhenPushed = YES;
    docArticleController.isFav = true;
    docArticleController.goSelect = indexPath.row;
    
    NSString* externelId = [[self.favs objectAtIndex:indexPath.row] objectForKey:DOC_EXTERNALID];
    
    [self.mgrFavs setObject:DOC_READED forKey:externelId];
    
    docArticleController.externalId = externelId;
    
    if (![MyDatabase isSelectId:externelId ismgr:IMD_Mydoc]) {
        NSString* url = [ImdUrlPath docArticleUserOpUrl:externelId];
        docArticleController.httpRequest = [UrlRequest sendWithToken:url delegate:docArticleController];
    }else {
        docArticleController.resultsJson = [MyDatabase readDocData:IMD_Mydoc externalId:docArticleController.externalId];
        
    }
    
    [self.navigationController pushViewController:docArticleController animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    // Pass the selected object to the new view controller.
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return REMOVE_FAVORITES;
}

-(void)requestDetail
{
    
    NSMutableDictionary* updataDetail = [[NSMutableDictionary alloc] init];
    [updataDetail setObject:Select_Updata forKey:isUpdata];
    NSMutableArray *mutArray = [[NSMutableArray alloc]init];
    //  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (int i =0 ; i < [self.favs count]; i++) {
        NSString* externelId = [[self.favs objectAtIndex:i] objectForKey:DOC_EXTERNALID];
        [mutArray addObject:externelId];
    }
    NSString* url = [ImdUrlPath docArticleArrayexternelId];
    self.httpRequest = [UrlRequest send:url mutArray:mutArray delegate:self];
    
    isUpdataDetail = YES;
    
    // [pool release];
}


#pragma mark Asy Request
-(void)sync
{
    
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    self.httpRequest = [UrlRequest sendWithToken:[ImdUrlPath docFavsUrl] delegate:self];
    
    isUpdataDetail = NO;
    
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%d",[request responseStatusCode]);
    NSLog(@"%@",[request responseString]);
    
    self.view.hidden = NO;
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    
    //Check if results is nil.
    if (resultsJson == nil) {
        NSLog(@"Nil Results");
        self.favs = nil;
        
        self.favs = [MyDatabase readMgrData:IMD_Mydoc userid:[[NSUserDefaults standardUserDefaults]objectForKey:SAVED_USER]];
        [self.tableView reloadData];
        return;
    } else {
        //Set Results Count.
        if (isUpdataDetail) {
            for (int i=0; i < [[resultsJson objectForKey:ABSTRACT_RESULTS] count]; i++) {
                
                self.dicresultsJson = nil;
                self.dicresultsJson = [[resultsJson objectForKey:ABSTRACT_RESULTS] objectAtIndex:i];
                
                [MyDataBaseSql insertDetail:self.dicresultsJson ismgr:IMD_Mydoc filePath:@"NO Value !"];
            }
            [self.refreshView stopLoading];
        }else {
            self.favs = [resultsJson objectForKey:ARTICLE_FAVS];
            if ([MyDatabase connDatabase]) {
                
                [MyDatabase cleanMySearchTable:IMD_Mydoc userid:[UserManager userName]];
            }
            
            for (int i=[self.favs count]; i > 0; i--) {
                [MyDataBaseSql insertMySearch:[self.favs objectAtIndex:i-1] ismgr:IMD_Mydoc];
                
                if ( self.favs.count > 0) {
                    self.noResultsView.hidden = YES;
                    self.tableView.hidden = NO;
                    [self.tableView reloadData];
                } else {
                    self.noResultsView.hidden = NO;
                    self.tableView.hidden = YES;
                }
                
            }
            [self requestDetail];
        }
        
    }
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    
    NSLog(@"request failed %@",[request responseString]);
    // self.favs = nil;
    self.favs = [MyDatabase readMgrData:IMD_Mydoc userid:[[NSUserDefaults standardUserDefaults]objectForKey:SAVED_USER]];
    self.view.hidden = NO;
    self.tableView.hidden = NO;
    self.noResultsView.hidden = YES;
    [self.tableView reloadData];
    [self.alertView show];
    [refreshView stopLoading];
}

-(void) removeFavs:(NSUInteger)index
{
    NSDictionary* resultsItem = [self.favs objectAtIndex:index];
    [MyDatabase cleanFav:@"MySearchTable" ismgr:IMD_Mydoc externalId:[resultsItem objectForKey:DOC_EXTERNALID] userid:[UserManager userName]];
    NSString* url = [ImdUrlPath docRemoveFavsUrl:[resultsItem objectForKey:DOC_EXTERNALID]];
    
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    self.httpRequest = [UrlRequest sendWithToken:url delegate:nil];
    
    [self.favs removeObjectAtIndex:index];
}
@end
