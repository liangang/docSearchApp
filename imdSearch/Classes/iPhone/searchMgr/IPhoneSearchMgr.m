//
//  IPhoneSearchMgrController.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-28.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "IPhoneSearchMgr.h"
#import "Strings.h"
#import "TableViewFormatUtil.h"
#import "DocArticleController.h"
#import "ImdUrlPath.h"
#import "UrlRequest.h"
#import "TableViewFormatUtil.h"
#import "ImageViews.h"
#import "IPhoneHeader.h"
#import "MyDatabase.h"
#import "publicMySearch.h"
#import "MyDataBaseSql.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "UserManager.h"


@implementation IPhoneSearchMgr

@synthesize downloadArray, requestArray;
@synthesize alertView, indicator, isDownloadShown, segCtr;
@synthesize tableView;
@synthesize noResultsView;
@synthesize mgrDownload, mgrRequest;
@synthesize httpRequest;
@synthesize noResultsImageView;
@synthesize selectValue;
@synthesize dicresultsJson;
@synthesize waitrequestArray;
@synthesize isWaitRequest;
@synthesize refreshView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = SEARCHMGR_CN;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:EDIT_CN style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditDone)];
        
        alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
        isDownloadShown = YES;
        
        mgrDownload = [[NSMutableDictionary alloc] init];
        mgrRequest = [[NSMutableDictionary alloc] init];
        
        if (IOS7) {
            segCtr = [[UISegmentedControl alloc] initWithItems:@[@"已保存",@"索取中",@"已索取"]];
            [segCtr setWidth:58.0 forSegmentAtIndex:0];
            [segCtr setWidth:56.0 forSegmentAtIndex:1];
            [segCtr setWidth:58.0 forSegmentAtIndex:2];
//            segCtr.tintColor = [UIColor redColor];
        }else{
            segCtr = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:IMG_SAVED_PRESS], [UIImage imageNamed:IMG_REQUESTING_NORMAL], [UIImage imageNamed:IMG_REQUESTED_NORMAL], nil]];
            
            segCtr.segmentedControlStyle = UISegmentedControlStyleBar;
            segCtr.tintColor = [UIColor clearColor];
            
            segCtr.selectedSegmentIndex = 0;
            [segCtr setWidth:58.0 forSegmentAtIndex:0];
            [segCtr setWidth:56.0 forSegmentAtIndex:1];
            [segCtr setWidth:58.0 forSegmentAtIndex:2];
        }
        
        [segCtr addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = segCtr;
        
        self.navigationItem.title = @"我的文献";
        self.dicresultsJson = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void) popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showNotInTabBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BACK_CN style:UIBarButtonItemStylePlain target:self action:@selector(popBack)];
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

-(void) dealloc
{
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [TableViewFormatUtil setTableViewBackGround:self.tableView image:IMG_BG_CONTENTSBACKGROUDN];
//    [TableViewFormatUtil setShadow:self.navigationController.navigationBar];
    [self addRefreshView];
    self.refreshView.hidden = YES;
}

-(void)addRefreshView
{
    // 添加RefreshView到tableView
    NSArray *nils = [[NSBundle mainBundle]loadNibNamed:@"RefreshView" owner:self options:nil];
    self.refreshView = [nils objectAtIndex:0];
    [refreshView setupWithOwner:self.tableView delegate:self];
}

-(void)showDownload
{
    [ImdAppBehavior localDocLog:[Util getUsername] MACAddr:[Util getMacAddress] title:@"showDownload"];
    if (!IOS7) {
        [self.segCtr setImage:[UIImage imageNamed:IMG_SAVED_PRESS] forSegmentAtIndex:0];
        [self.segCtr setImage:[UIImage imageNamed:IMG_REQUESTING_NORMAL] forSegmentAtIndex:1];
        [self.segCtr setImage:[UIImage imageNamed:IMG_REQUESTED_NORMAL] forSegmentAtIndex:2];
    }
    
    self.segCtr.selectedSegmentIndex = 0;
    self.isDownloadShown = YES;
    
    [self showView];
    [self.tableView reloadData];
}

-(void)showRequesting
{
    [ImdAppBehavior localAskingButtonTappedLog:[Util getUsername] MACAddr:[Util getMacAddress]];
    if (!IOS7) {
        [self.segCtr setImage:[UIImage imageNamed:IMG_SAVED_NORMAL] forSegmentAtIndex:0];
        [self.segCtr setImage:[UIImage imageNamed:IMG_REQUESTING_PRESS] forSegmentAtIndex:1];
        [self.segCtr setImage:[UIImage imageNamed:IMG_REQUESTED_NORMAL] forSegmentAtIndex:2];
    }
   
    self.segCtr.selectedSegmentIndex = 1;
    
    [self.tableView setEditing:NO animated:YES];
    self.isDownloadShown = NO;
    isWaitRequest = YES;
    [self showView];
    isUpdataDetail = NO;
    isGo = YES;
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    
    self.httpRequest = [UrlRequest sendWithToken:[ImdUrlPath docRequestListUrl:NO start:0 limit:10000] delegate:self];
    [self.refreshView startLoading];}


-(void) showView
{
    self.view.hidden = NO;
    if (self.isDownloadShown) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:EDIT_CN style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditDone)];
        if ( self.downloadArray.count > 0) {
            self.noResultsView.hidden = YES;
            self.tableView.hidden = NO;
            //[self.tableView reloadData];
        } else {
            self.noResultsView.hidden = NO;
            self.tableView.hidden = YES;
        }
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        self.noResultsView.hidden = YES;
        self.tableView.hidden = NO;
    }
    switch(self.segCtr.selectedSegmentIndex) {
        case 0:
            [self.noResultsImageView setImage:[UIImage imageNamed:IMG_NO_SAVED_DOCUMENTS]];
            self.noResultsView.hidden = !(self.downloadArray.count == 0);
            self.tableView.hidden = (self.downloadArray.count == 0);
            break;
            
        case 1:
            [self.noResultsImageView setImage:[UIImage imageNamed:IMG_NO_REQUESTING_DOCUMENTS]];
            self.noResultsView.hidden = !(self.waitrequestArray.count == 0);
            self.tableView.hidden = (self.waitrequestArray.count == 0);
            break;
            
        case 2:
            [self.noResultsImageView setImage:[UIImage imageNamed:IMG_NO_REQUESTED_DOCUMENTS]];
            
            self.noResultsView.hidden = !(self.requestArray.count == 0);
            self.tableView.hidden = (self.requestArray.count == 0);
            break;
        default:
            [self.noResultsImageView setImage:[UIImage imageNamed:IMG_NO_SAVED_DOCUMENTS]];
            break;
    }
}


-(void)showRequest
{
    [ImdAppBehavior localAskedButtonTappedLog:[Util getUsername] MACAddr:[Util getMacAddress]];
    if (!IOS7) {
        [self.segCtr setImage:[UIImage imageNamed:IMG_SAVED_NORMAL] forSegmentAtIndex:0];
        [self.segCtr setImage:[UIImage imageNamed:IMG_REQUESTING_NORMAL] forSegmentAtIndex:1];
        [self.segCtr setImage:[UIImage imageNamed:IMG_REQUESTED_PRESS] forSegmentAtIndex:2];
    }
    
    self.segCtr.selectedSegmentIndex = 2;
    
    [self.tableView setEditing:NO animated:YES];
    self.isDownloadShown = NO;
    self.selectValue = Select_Own;
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    tempArray = [MyDatabase readAskData:self.selectValue userid:[UserManager userName]];
    self.requestArray = [[NSMutableArray alloc]init];
    for (int i=0; i < [tempArray count]; i++) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[tempArray objectAtIndex:i] forKey:ASKFOR_SHORTDOCINFO];
        [self.requestArray addObject:dic];
    }
    if (![self.requestArray count]) {
        [self sync];
    }
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    if ([self.requestArray count]) {
        self.noResultsView.hidden = YES;
        self.view.hidden = NO;
    }
}


-(void)valueChange:(id) sender
{
    switch([sender selectedSegmentIndex]) {
        case 0:
            self.selectValue = Select_Save;
            [self showDownload];
            self.refreshView.hidden = YES;
            break;
        case 1:
            if (![UserManager userName]) {
                self.tableView.hidden = YES;
            }else {
                self.selectValue = Select_Wait;
                self.isDownloadShown = NO;
                self.isWaitRequest = YES;
                self.refreshView.hidden = NO;
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                tempArray = [MyDatabase readAskData:self.selectValue userid:[UserManager userName]];
                self.waitrequestArray = [[NSMutableArray alloc]init];
                for (int i=0; i < [tempArray count]; i++) {
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                    [dic setObject:[tempArray objectAtIndex:i] forKey:ASKFOR_SHORTDOCINFO];
                    [self.waitrequestArray addObject:dic];
                }
                [self.tableView reloadData];
                self.tableView.hidden = NO;
                [self showView];
                [self showRequesting];
                
            }
            break;
        case 2:
            if (![UserManager userName]) {
                self.tableView.hidden = YES;
            }else {
                self.selectValue = Select_Own;
                self.isWaitRequest = NO;
                self.refreshView.hidden = NO;
                [self showRequest];
                self.navigationItem.rightBarButtonItem = nil;
            }
            break;
        default:
            break;
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
    
    if (iPhone5) {
        self.noResultsImageView.frame = CGRectMake(0, 60, 320, 350);
    }
    
    self.downloadArray = nil;
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    mutArray = [[NSUserDefaults standardUserDefaults]objectForKey:FULLTEXT_DOWNLOAD_LIST];
    if ([mutArray count]) {
        for (int i = 0; i < [mutArray count]; i++) {
            [MyDataBaseSql insertDetail:[[mutArray objectAtIndex:i] objectForKey:LOCAL_RESULT] ismgr:[UserManager userName] filePath:[[mutArray objectAtIndex:i] objectForKey:LOCAL_PDF_PATH]];
        }
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:FULLTEXT_DOWNLOAD_LIST];
        [defaults synchronize];
    }
    self.downloadArray = [MyDatabase readDocData:[UserManager userName]];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    tempArray = [MyDatabase readAskData:self.selectValue userid:[UserManager userName]];
    self.waitrequestArray = [[NSMutableArray alloc]init];
    for (int i=0; i < [tempArray count]; i++) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[tempArray objectAtIndex:i] forKey:ASKFOR_SHORTDOCINFO];
        [self.waitrequestArray addObject:dic];
    }
    if ([self.selectValue isEqualToString:Select_Own]) {
        if (![self.requestArray count]) {
            [self sync];
        }
    }
    [self.tableView reloadData];
    [self showView];
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
    if (!self.isDownloadShown ){
        if (self.isWaitRequest) {
            return self.waitrequestArray.count;
        }else {
            return self.requestArray.count;
        }
        
    }else {
        return self.downloadArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"searchMgrItem";
    NSDictionary* resultsItem = nil;
    
    NSString* readed = nil;
    if (!self.isDownloadShown) {
        if (self.isWaitRequest) {
            resultsItem = [[self.waitrequestArray objectAtIndex:indexPath.row] objectForKey:ASKFOR_SHORTDOCINFO];
        }else {
            resultsItem = [[self.requestArray objectAtIndex:indexPath.row] objectForKey:ASKFOR_SHORTDOCINFO];
        }
        readed = [self.mgrRequest objectForKey:[resultsItem objectForKey:DOC_EXTERNALID]];
        if (readed == nil) {
            readed = [self.mgrRequest objectForKey:[resultsItem objectForKey:DOC_ID]];
        }
    }
    else {
        resultsItem = [[self.downloadArray objectAtIndex:indexPath.row] objectForKey:LOCAL_RESULT];
        
        readed = [self.mgrDownload objectForKey:[resultsItem objectForKey:DOC_EXTERNALID]];
    }
    
    return [TableViewFormatUtil formatCell:tableView CellIdentifier:CellIdentifier data:resultsItem unreadSign:![readed isEqualToString:DOC_READED]];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (self.isDownloadShown)
        return YES;
    else
        return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if ([self.downloadArray count]) {
            NSString *externalId = [[[self.downloadArray objectAtIndex:indexPath.row] objectForKey:LOCAL_RESULT]objectForKey:DOC_EXTERNALID];
            [MyDatabase cleanLocalTable:externalId userid:[UserManager userName]];
        }
        [self removeItem:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self showView];
        [self.tableView reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)removeItem:(NSUInteger)index
{
    NSString *fullPath = [[self.downloadArray objectAtIndex:index]objectForKey:FULLPATH];
    if([[NSFileManager defaultManager] fileExistsAtPath:fullPath]){
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        NSLog(@"pdf删除成功");
    }
    if (self.isDownloadShown) {
        [self.downloadArray removeObjectAtIndex:index];
    } else {
        [requestArray removeObjectAtIndex:index];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableViews didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocArticleController* docArticleController = [[DocArticleController alloc] initWithNibName:@"DocArticleController" bundle:nil];
    
    docArticleController.hidesBottomBarWhenPushed = YES;
    
    
    if (!self.isDownloadShown) {
        docArticleController.source = SEARCH_MODE_E;
        docArticleController.isAskFor = YES;
        
        if (self.segCtr.selectedSegmentIndex == 1) {
            docArticleController.isAskFor = NO;
            docArticleController.requestDocInfo.isRequesting = YES;
            docArticleController.requestDocInfo.isFetched = NO;
            docArticleController.isrequestWaiting = YES;
        }
        if (self.isWaitRequest) {
            docArticleController.externalId = [[[self.waitrequestArray objectAtIndex:indexPath.row] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:DOC_ID] ;
        }else {
            docArticleController.externalId = [[[self.requestArray objectAtIndex:indexPath.row] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:DOC_ID] ;
            if (docArticleController.externalId !=nil) {
                [self changeIconCount:docArticleController.externalId];
            }
        }
        if (docArticleController.externalId == nil) {
            if (self.isWaitRequest) {
                docArticleController.externalId = [[[self.waitrequestArray objectAtIndex:indexPath.row] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:@"externalId"] ;
            }else {
                docArticleController.externalId = [[[self.requestArray objectAtIndex:indexPath.row] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:@"externalId"] ;
                [self changeIconCount:docArticleController.externalId];
            }
        }
        [self.mgrRequest setObject:DOC_READED forKey:docArticleController.externalId];
        
        if (![MyDatabase isSelectId:docArticleController.externalId ismgr:IMD_Mydoc]) {
            NSString* url = [ImdUrlPath docArticleUserOpUrl:docArticleController.externalId];
            docArticleController.httpRequest = [UrlRequest sendWithToken:url delegate:docArticleController];
        }else {
            docArticleController.resultsJson = [MyDatabase readDocData:IMD_Mydoc externalId:docArticleController.externalId];
        }
        docArticleController.view.hidden = NO;
        
        [self.navigationController pushViewController:docArticleController animated:YES];
    }
    else {
        docArticleController.externalId = [[[self.downloadArray objectAtIndex:indexPath.row] objectForKey:LOCAL_RESULT] objectForKey:DOC_EXTERNALID];
        
        [self.navigationController pushViewController:docArticleController animated:YES];
        docArticleController.isOffline = YES;
        docArticleController.source = SEARCH_MODE_C;
        docArticleController.externalId = [[[self.downloadArray objectAtIndex:indexPath.row] objectForKey:LOCAL_RESULT] objectForKey:DOC_EXTERNALID];
        
        [mgrDownload setObject:DOC_READED forKey:docArticleController.externalId];
        
        docArticleController.pdfReader.filePath = [[self.downloadArray objectAtIndex:indexPath.row] objectForKey:LOCAL_PDF_PATH];
        [docArticleController layoutDocArticle:[[self.downloadArray objectAtIndex:indexPath.row] objectForKey:LOCAL_RESULT]];
        
    }
    // [self.navigationController pushViewController:docArticleController animated:YES];
    
    //Remove unread sign.
    UITableViewCell* cell = [tableViews cellForRowAtIndexPath:indexPath];
    [cell.imageView setImage:nil];
    [tableViews deselectRowAtIndexPath:indexPath animated:NO];
}

-(void) changeIconCount:(NSString *)externalId
{
    NSMutableArray *mut = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:Alert_Count]];
    for (int i=0; i<[mut count]; i++) {
        NSMutableArray *mut2 = [NSMutableArray arrayWithArray:[[mut objectAtIndex:i] objectForKey:Array_ID]];
        if ([[[mut objectAtIndex:i] objectForKey:SAVED_USER] isEqualToString:[UserManager userName]]) {
            for (int j=0; j < [mut2 count]; j++) {
                if ([[mut2 objectAtIndex:j] isEqualToString:externalId]) {
                    [mut2 removeObjectAtIndex:j];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[mut objectAtIndex:i]];
                    [dic setObject:mut2 forKey:Array_ID];
                    [mut replaceObjectAtIndex:i withObject:dic];
                    break;
                }
            }
            [UIApplication sharedApplication].applicationIconBadgeNumber = [mut2 count];
        }
        [[NSUserDefaults standardUserDefaults] setObject:mut forKey:Alert_Count];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DELETE_TEXT;
}


#pragma mark Asy Request
-(NSMutableArray*) requestArrayInit:(NSMutableArray*)request download:(NSArray*)download
{
    NSMutableArray* returnArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary* liveItem in request) {
        NSString* currentId = [[liveItem objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:DOC_ID];
        BOOL isSaved = NO;
        for (NSDictionary* item in download) {
            NSString* externalId = [[item objectForKey:LOCAL_RESULT] objectForKey:DOC_EXTERNALID];
            
            if ([currentId isEqualToString:externalId]) {
                isSaved = YES;
                break;
            }
        }
        if (!isSaved)
            [returnArray addObject:liveItem];
    }
    return returnArray;
}

-(void)sync
{
    isGo = NO;
    isUpdataDetail = NO;
    if (self.httpRequest != nil) {
        [self.httpRequest clearDelegatesAndCancel];
    }
    self.httpRequest = [UrlRequest sendWithToken:[ImdUrlPath docRequestListUrl:YES start:0 limit:10000] delegate:self];
    
}

-(void)updataDeatil
{
    if (self.isWaitRequest) {
        NSMutableArray *mutArray = [[NSMutableArray alloc]init];
        //  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        for (int i =0 ; i < [self.waitrequestArray count]; i++) {
            NSString* externelId = [[[self.waitrequestArray objectAtIndex:i] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:DOC_ID];
            [mutArray addObject:externelId];
        }
        NSString* url = [ImdUrlPath docArticleArrayexternelId];
        self.httpRequest = [UrlRequest send:url mutArray:mutArray delegate:self];
        isUpdataDetail = YES;
    }else {
        NSMutableArray *mutArray = [[NSMutableArray alloc]init] ;
        //  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        for (int i =0 ; i < [self.requestArray count]; i++) {
            NSString* externelId = [[[self.requestArray objectAtIndex:i] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:DOC_ID];
            if (externelId ==nil) {
                [self.refreshView stopLoading];
            }else {
                [mutArray addObject:externelId];
            }
            
        }
        
        NSString* url = [ImdUrlPath docArticleArrayexternelId];
        self.httpRequest = [UrlRequest send:url mutArray:mutArray delegate:self];
        isUpdataDetail = YES;
        
        //[mutArray release];
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"requestFinished %@",request.responseString);
    self.tableView.hidden = NO;
    NSDictionary* resultsJson = [UrlRequest getJsonValue:request];
    if (isUpdataDetail) {
        for (int i=0; i < [[resultsJson objectForKey:ABSTRACT_RESULTS] count]; i++) {
            self.dicresultsJson = nil;
            self.dicresultsJson = [[resultsJson objectForKey:ABSTRACT_RESULTS] objectAtIndex:i];
            [MyDataBaseSql insertDetail:self.dicresultsJson ismgr:IMD_Mydoc filePath:@"NO Value !"];
        }
        [self.refreshView stopLoading];
        // self.refreshView.hidden = YES;
    }else {
        NSMutableArray* rArray = [NSMutableArray arrayWithArray:[resultsJson objectForKey:ASKFOR_DEMAND]];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray* downloadList = [NSMutableArray arrayWithArray:[defaults arrayForKey:FULLTEXT_DOWNLOAD_LIST]];
        if (isGo) {
            self.waitrequestArray = [self requestArrayInit:rArray download:downloadList];
            if ([self.waitrequestArray count]) {
                [MyDatabase cleanMySearchTable:IMD_Mywaitting userid:[UserManager userName]];
                [self addWhichValue:IMD_Mywaitting];
            }
        }else {
            self.requestArray = [self requestArrayInit:rArray download:downloadList];
            if ([self.requestArray count]) {
                [MyDatabase cleanMySearchTable:IMD_Myorder userid:[UserManager userName]];
                [self addWhichValue:IMD_Myorder];
                
            }
        }
        [self updataDeatil];
    }
    
    [self showView];
    [self.tableView reloadData];
    
}

-(void)addWhichValue:(NSString *)ismgr
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    tempArray = nil ;
    if (isWaitRequest) {
        tempArray = self.waitrequestArray;
    }else {
        tempArray = self.requestArray;
    }
    for (int i=0; i<[tempArray count]; i++) {
        publicMySearch *valueSearch = [[publicMySearch alloc]init];
        NSArray *array = [[[tempArray objectAtIndex:i] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:@"author"];
        if ([array count]) {
            valueSearch.author = [array objectAtIndex:0];
            for (int i=1; i<[array count]; i++) {
                valueSearch.author = [NSString stringWithFormat:@"%@::%@",valueSearch.author,[array objectAtIndex:i]];
            }
        }
        
        valueSearch.externalId = [[[tempArray objectAtIndex:i] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:@"id"];
        valueSearch.issue = [[[tempArray objectAtIndex:i] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:@"issue"];
        valueSearch.journal = [[[tempArray objectAtIndex:i] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:@"journal"];
        valueSearch.pagination = [[[tempArray objectAtIndex:i] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:@"pagination"];
        valueSearch.pubDate = [[[tempArray objectAtIndex:i] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:@"pubDate"];
        valueSearch.title = [[[tempArray objectAtIndex:i] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:@"title"];
        
        valueSearch.userid = [UserManager userName];
        valueSearch.volume = [[[tempArray objectAtIndex:i] objectForKey:ASKFOR_SHORTDOCINFO] objectForKey:@"volume"];
        if (![valueSearch.externalId isEqualToString:@"(null)"]) {
            if (valueSearch.userid == nil) {
                
                valueSearch.userid = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_USER];
            }
            [MyDatabase insertMySearchValue:valueSearch.author externalId:valueSearch.externalId issue:valueSearch.issue journal:valueSearch.journal pagination:valueSearch.pagination pubDate:valueSearch.pubDate  title:valueSearch.title userid:valueSearch.userid ismgr:ismgr volume:valueSearch.volume];
            
        }else {
            [tempArray removeObjectAtIndex:i];
            self.waitrequestArray = nil;
            self.waitrequestArray = tempArray;
        }
    }
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    tempArray = [MyDatabase readAskData:self.selectValue userid:[UserManager userName]];
    if (isWaitRequest) {
        self.waitrequestArray = [[NSMutableArray alloc]init];
        for (int i=0; i < [tempArray count]; i++) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:[tempArray objectAtIndex:i] forKey:ASKFOR_SHORTDOCINFO];
            [self.waitrequestArray addObject:dic];
            
        }
        
    }else {
        self.requestArray = [[NSMutableArray alloc]init];
        for (int i=0; i < [tempArray count]; i++) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:[tempArray objectAtIndex:i] forKey:ASKFOR_SHORTDOCINFO];
            [self.requestArray addObject:dic];
            
        }
        
    }
    
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    [self.alertView show];
    [self.refreshView stopLoading];
    if ([self.requestArray count] || [self.waitrequestArray count]) {
        self.noResultsView.hidden = YES;
        self.view.hidden = NO;
    }
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
    self.refreshView.hidden = YES;
    if ([selectValue isEqualToString:Select_Own]) {
        self.refreshView.hidden = NO;
        [self refresh];
        [self sync];
    }
    
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

@end
