//
//  MyDocListViewController.m
//  imdSearch
//
//  Created by xiangzhang on 3/25/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "MyDocListViewController.h"
#import "DocInfoRecord.h"
#import "MyDocListCell.h"
#import "Strings.h"
#import "DocArticleController.h"
#import "ASIHTTPRequest.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "MyDataBaseSql.h"
#import "MyDatabase.h"
#import "UserManager.h"
#import "TableViewFormatUtil.h"

#import "ImdUrlPath.h"
#import "UrlRequest.h"
#import "imdSearchAppDelegate_iPhone.h"
#import "DatabaseManager.h"
#import "RefreshView.h"

#define defaultLimit 15

@interface MyDocListViewController ()<ASIHTTPRequestDelegate>

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *footerBtn;
@property (nonatomic, assign) BOOL isMore;
@property (nonatomic, assign) BOOL isFirstGet;
@property (nonatomic, strong) RefreshView *refreshView;
@end

@implementation MyDocListViewController
@synthesize refreshView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _listType = ListTypeRecord;
        _isFirstGet = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isMore = FALSE;
 
    self.dataArr = [[NSMutableArray alloc] init];
    
//    /************************内置刷新常用性设置****************************/
//    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
//    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
//    refresh.tintColor = NavigationColor;
//    [refresh addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
//    self.refreshControl = refresh;
//    
//     /************************自定义查看更多属性设置****************************/
  NSArray *nils = [[NSBundle mainBundle] loadNibNamed:@"RefreshView" owner:self options:nil];
  self.refreshView = [nils objectAtIndex:0];
  [refreshView setupWithOwner:self.tableView delegate:self];
  
    [self footerViewInit];
    
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([self.dataArr count] <=0) {
        [self refresh];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
  // 开始，可以触发自己定义的开始方法
- (void)startLoading {
  [refreshView startLoading];
  
}
  // 刷新
- (void)refresh {
  [self startLoading];
  [self pullToRefresh];
}
#pragma mark - RefreshViewDelegate
- (void)refreshViewDidCallBack {
  [self refresh];
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

#pragma mark- UItableView pull to refresh
//下拉刷新
-(void) pullToRefresh
{
    self.isMore = FALSE;
    [self dataSourceInitWithType];
}

#pragma mark - init UITableView FooterView
- (void)footerViewInit{
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.footerView.backgroundColor = NavigationColor;
    
    self.footerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.footerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.footerBtn setTitle:@"加载更多...." forState:UIControlStateNormal];
    [self.footerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.footerBtn setTitle:@"正在加载...." forState:UIControlStateSelected];
    [self.footerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    self.footerBtn.frame = CGRectMake(0, 0, 200, 44);
    [self.footerBtn addTarget:self action:@selector(addMoreDataToTable:) forControlEvents:UIControlEventTouchUpInside];
    self.footerBtn.center = self.footerView.center;
    [self.footerView addSubview:self.footerBtn];
}

- (IBAction)addMoreDataToTable:(id)sender{
    self.isMore = TRUE;
    self.footerBtn.selected = YES;
    if (self.listType == ListTypeRecord) {
        [self getRecordInfoRequest:self.docType startIndex:[self.dataArr count] limit:defaultLimit];
    }else if (self.listType == ListTypeCollection){
        [self getcollectionInfoRequest:self.docType start:[self.dataArr count]];
    }
}

#pragma mark - initUserData
- (void)dataSourceInitWithType{
    if (self.listType == ListTypeRecord) {
        [self showRecordListInfo];
    }else if (self.listType == ListTypeCollection){
        [self showCollectionListInfo];
    }else if (self.listType == ListTypeLocation){
        [self showLocationListInfo];
    }
}

- (void)reloadTableViewData{
    [self.tableView reloadData];
    
    self.footerBtn.selected = NO;
    if ([self.dataArr count] % defaultLimit == 0 && [self.dataArr count] != 0) {
        self.tableView.tableFooterView = self.footerView;
    }else{
        self.tableView.tableFooterView = nil;
    }
    
    if ([self.listDelegate respondsToSelector:@selector(tableViewReload)]) {
        [self.listDelegate tableViewReload];
    }
}

#pragma mark - get diff data by List Type
- (void)showRecordListInfo{
    [ImdAppBehavior localDocLog:[Util getUsername] MACAddr:[Util getMacAddress] title:@"showRecord"];
    
    //数据库中获取数据显示，在获取网络数据
    if ([self.dataArr count] <= 0 && self.isFirstGet) {
        [self.dataArr addObjectsFromArray:[DatabaseManager getRecordFromDatabaseWithUserId:[Util getUsername]]];
        [self reloadTableViewData];
    }
    [self getRecordInfoRequest:self.docType startIndex:0 limit:defaultLimit];
}

- (void)showCollectionListInfo{
    [self getcollectionInfoRequest:self.docType start:0];
}

- (void)showLocationListInfo{
    [self getLocationInfoWithType:self.docType];
}

/**
 *  获取请求过的文献记录的
 *
 *  @param type 获取的类型
 */
- (void)getRecordInfoRequest:(DocType)type startIndex:(NSInteger)start limit:(NSInteger)lt{
    self.isFirstGet = NO;
    [self clearRequestDelegate];
    
    NSString *url = [ImdUrlPath getDocListRecordUrl:type start:start limit:lt];
    self.listRequest = [UrlRequest sendWithToken:url delegate:self];
}

- (void)clearRequestDelegate{
    if (self.listRequest) {
        [self.listRequest clearDelegatesAndCancel];
    }
}

/**
 *  移除获取记录中的Item
 *
 *  @param externalId 移除Item的Id
 */
- (void)recodItemRemove:(NSString *)externalId{
    
}

/**
 *  获取个人收藏的文献信息
 *
 *  @param type 获取的类型
 */
- (void)getcollectionInfoRequest:(DocType)type start:(NSInteger)start{
    self.isFirstGet = FALSE;
    [self clearRequestDelegate];
    self.listRequest = [UrlRequest sendWithToken:[ImdUrlPath getFavListUrl:type start:start limit:defaultLimit] delegate:self];
    self.listRequest.didFinishSelector = @selector(requestCollectionFinish:);
}

/**
 *  移除个人收藏的文献记录
 *
 *  @param externalId 文献记录的ID
 */
- (void)collectionItemRemove:(NSString *)externalId{
    [MyDatabase cleanFav:@"MySearchTable" ismgr:IMD_Mydoc externalId:externalId userid:[UserManager userName]];
    NSString *url = [ImdUrlPath docRemoveFavsUrl:externalId];
    
    [self clearRequestDelegate];
  NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
  [userInfo setObject:REQUEST_TYPE_REMOVE_FAV forKey:REQUEST_TYPE];
    self.listRequest = [UrlRequest sendWithTokenWithUserInfo:url userInfo:userInfo delegate:self];
}

/**
 *  获取本地文件列表数据
 *
 *  @param type 获取的类型，暂不可用
 */
- (void)getLocationInfoWithType:(DocType)type{
    [ImdAppBehavior localDocLog:[Util getUsername] MACAddr:[Util getMacAddress] title:@"showLocation"];
    
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    mutArray = [[NSUserDefaults standardUserDefaults] objectForKey:FULLTEXT_DOWNLOAD_LIST];
    if ([mutArray count]) {
        for (int i = 0; i < [mutArray count]; i++) {
            [MyDataBaseSql insertDetail:[[mutArray objectAtIndex:i] objectForKey:LOCAL_RESULT] ismgr:[UserManager userName] filePath:[[mutArray objectAtIndex:i] objectForKey:LOCAL_PDF_PATH]];
        }
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:FULLTEXT_DOWNLOAD_LIST];
        [defaults synchronize];
    }
    
    self.dataArr = [MyDatabase readDocData:[UserManager userName]];
    
    [self reloadTableViewData];
    [self.refreshView stopLoading];
}

- (void)locationItemRemove:(NSDictionary *)valueDic{
    NSString *fullPath = [valueDic objectForKey:FULLPATH];
    if([[NSFileManager defaultManager] fileExistsAtPath:fullPath]){
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        NSLog(@"pdf删除成功");
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MyDocListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    DocInfoRecord *record = [self.dataArr objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"MyDocListCell" owner:self options:nil] ;
        for (id object in nibs) {
            if ([object isKindOfClass:[MyDocListCell class]]) {
                cell = [(MyDocListCell *) object initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
        }
    }
    
    if (self.listType == ListTypeLocation) {
        NSDictionary *resultsItem = [[self.dataArr objectAtIndex:indexPath.row] objectForKey:LOCAL_RESULT];
        cell.listType = self.listType;
        [cell setCellInfoWithLocationInfo:resultsItem];
    }else{
        cell.listType = self.listType;
        [cell setCellInfoWithDocInfo:record];
    }
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
   imdSearchAppDelegate_iPhone *delegate = (imdSearchAppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navController = (UINavigationController *)[delegate.myTabBarController selectedViewController];
    DocArticleController *viewController = [[DocArticleController alloc] initWithNibName:@"DocArticleController" bundle:nil];
    viewController.hidesBottomBarWhenPushed = YES;
    
    // Push the view controller.
    if (self.listType == ListTypeRecord || self.listType == ListTypeCollection) {
        DocInfoRecord *record = [self.dataArr objectAtIndex:indexPath.row];
      viewController.externalId = record.externalId;
        record.isRead = TRUE;
      
        if (![MyDatabase isSelectId:record.externalId ismgr:IMD_Mydoc]) {
            NSString* url = [ImdUrlPath docArticleUserOpUrl:record.externalId];
            viewController.httpRequest = [UrlRequest sendWithToken:url delegate:viewController];
        }else {
            viewController.resultsJson = [MyDatabase readDocData:IMD_Mydoc externalId:record.externalId];
        }
        //update数据库信息
        [DatabaseManager updataRecordReadStatus:YES externalId:record.externalId withUserId:record.userid];
    }else if (self.listType == ListTypeLocation){
        NSDictionary *dic = [self.dataArr objectAtIndex:indexPath.row];
         viewController.externalId = [[dic objectForKey:@"result"] objectForKey:DOC_EXTERNALID];
      if (![MyDatabase isSelectId:viewController.externalId ismgr:IMD_Mydoc]) {
        NSString* url = [ImdUrlPath docArticleUserOpUrl:viewController.externalId];
        viewController.httpRequest = [UrlRequest sendWithToken:url delegate:viewController];
      }else {
        viewController.resultsJson = [MyDatabase readDocData:IMD_Mydoc externalId:viewController.externalId];
      }
//        //update数据库信息
//      [DatabaseManager updataRecordReadStatus:YES externalId:viewController.externalId withUserId:[UserManager userName]];
    }
  viewController.listType = self.listType;
  if (self.listType == ListTypeRecord) {
    viewController.isMydocumentCN = YES;
  }else
  viewController.isMydocumentCN = NO;
    [navController pushViewController:viewController animated:YES];
    
    [self reloadTableViewData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
  if (self.listType != ListTypeRecord) {
     return YES;
  }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.listType) {
        case ListTypeCollection:
            return  REMOVE_FAVORITES;
            break;
            
        default:
            return DELETE_TEXT;
            break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if (self.listType == ListTypeRecord) {
            DocInfoRecord *recored = [self.dataArr objectAtIndex:indexPath.row];
            
            [self.dataArr removeObject:recored];
            [DatabaseManager deleteRecordInfo:recored];
        }else if(self.listType == ListTypeCollection){
            DocInfoRecord *recored = [self.dataArr objectAtIndex:indexPath.row];
            [self collectionItemRemove:recored.externalId];
            [self.dataArr removeObject:recored];
        }else if (self.listType == ListTypeLocation){
            NSDictionary *valueDic = [self.dataArr objectAtIndex:indexPath.row];
            [self locationItemRemove:valueDic];
            
            NSString *externalId = [[valueDic objectForKey:LOCAL_RESULT]objectForKey:DOC_EXTERNALID];
            [MyDatabase cleanLocalTable:externalId userid:[UserManager userName]];
            [self.dataArr removeObject:valueDic];
        }
        
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark- ASIHTTPrequest Delegate
- (void)requestCollectionFinish:(ASIHTTPRequest *)request{
  
    
    NSLog(@"request info %@",request.responseString);
    NSDictionary *jsonInfo = [UrlRequest getJsonValue:request];
  int collectionCount = [[jsonInfo objectForKey:@"count"] intValue];
    if (self.isMore) {
       NSArray *subArr = [self parseJsonData:jsonInfo parseType:ListTypeCollection];
      [self.dataArr addObjectsFromArray:subArr];
      NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[subArr count]];
      for (int index = 0; index < [subArr count]; ++index){
        NSIndexPath* newPath = [NSIndexPath indexPathForRow:[self.dataArr indexOfObject:[subArr objectAtIndex:index]] inSection:0];
        [insertIndexPaths addObject:newPath];
      }
      
      [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    }else{
        self.dataArr = [NSMutableArray arrayWithArray:[self parseJsonData:jsonInfo parseType:ListTypeCollection]];
      [self reloadTableViewData];
      [self.refreshView stopLoading];
    }
  self.footerBtn.selected = NO;
  if (collectionCount > self.dataArr.count) {
    self.footerView.hidden = NO;
  }else
  self.footerView.hidden = YES;
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    //
    
    NSLog(@"request info %@",request.responseString);
  NSDictionary *userinfo = [request userInfo];
  if ([[userinfo objectForKey:REQUEST_TYPE] isEqualToString:REQUEST_TYPE_REMOVE_FAV]) {
    
  }else
  {
    NSDictionary *jsonInfo = [UrlRequest getJsonValue:request];
    int collectionCount = [[jsonInfo objectForKey:@"count"] intValue];
    NSArray *subArr = [self parseJsonData:jsonInfo parseType:ListTypeRecord];
    if (self.isMore) {
        if ([subArr count] == 0) {
            return;
        }
      [self.dataArr addObjectsFromArray:subArr];
      NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[subArr count]];
      for (int index = 0; index < [subArr count]; ++index){
        NSIndexPath* newPath = [NSIndexPath indexPathForRow:[self.dataArr indexOfObject:[subArr objectAtIndex:index]] inSection:0];
        [insertIndexPaths addObject:newPath];
      }
      
      [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    }else{
        self.dataArr = [NSMutableArray arrayWithArray:subArr];
        [self reloadTableViewData];
      [self.refreshView stopLoading];
    }
    
    self.footerBtn.selected = NO;
    if (collectionCount > self.dataArr.count) {
      self.footerView.hidden = NO;
    }else
      self.footerView.hidden = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DocInfoRecord *record in subArr) {
            [DatabaseManager insertToDataBaseWithRecord:record];
        }
    });
  }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    [self.refreshView stopLoading];
    self.footerBtn.selected = NO;
    NSLog(@"request info %@",request.responseString);
}

- (NSArray *)parseJsonData:(NSDictionary *)valueInfo parseType:(ListType)type{
    NSMutableArray *retArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *docList = [valueInfo objectForKey:@"docs"];
    
    for (int i = 0, sum = [docList count]; i < sum; i++) {
        NSDictionary *valueDic = [docList objectAtIndex:i];
        NSDictionary *docDic = [valueDic objectForKey:@"docDetails"];
        DocInfoRecord *record = [[DocInfoRecord alloc] init];
        record.userid = [valueDic objectForKey:@"userid"];
        
        if ([[valueDic objectForKey:@"cat"] isEqualToString:@"cn"]) {
            record.type = [valueDic objectForKey:@"downloadStatus"];
        }else{
            record.type = [valueDic objectForKey:@"requestStatus"];
        }
        
        record.externalId = [docDic objectForKey:@"id"];
        NSArray *authorArr = [docDic objectForKey:@"author"];
        record.author = [authorArr componentsJoinedByString:@"::"];
        record.title = [docDic objectForKey:@"title"];
        int pubD = [[docDic objectForKey:@"pubdate"] intValue];
        record.pubDate = [NSString stringWithFormat:@"%d",pubD];
        record.pagination = [docDic objectForKey:@"pagination"];
        record.issue = [docDic objectForKey:@"issue"];
        record.journal = [docDic objectForKey:@"journal"];
        record.volume = [docDic objectForKey:@"volume"];
        record.isRead = NO;
        
        [retArr addObject:record];
    }
    return retArr;
}
@end
