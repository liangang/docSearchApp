//
//  MyDocmentListPadViewController.m
//  imdSearch
//
//  Created by xiangzhang on 4/15/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "MyDocmentListPadViewController.h"

#import "ASIHTTPRequest.h"
#import "ImdAppBehavior.h"
#import "MyDatabase.h"
#import "ImdUrlPath.h"
#import "UrlRequest.h"
#import "Util.h"
#import "DatabaseManager.h"
#import "MyDataBaseSql.h"
#import "Strings.h"
#import "UserManager.h"
#import "MyDocmentPadCell.h"
#import "searchMainUtils.h"

#import "myDatabaseOption.h"
#import "Url_iPad.h"
#import "RefreshView.h"

#define defaultLimit 15

@interface MyDocmentListPadViewController ()<ASIHTTPRequestDelegate>

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *footerBtn;
@property (nonatomic, assign) BOOL isMore;
@property (nonatomic, assign) BOOL isFirstGet;
@property (nonatomic, strong) NSIndexPath *indexPostion;
@property (nonatomic, strong) RefreshView *refreshView;
@end

@implementation MyDocmentListPadViewController
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
//  if (self.refreshControl == nil) {
//    self.refreshControl = [[UIRefreshControl alloc] init];
//  }
//    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
//    self.refreshControl.tintColor = NavigationColor;
//    [self.refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
//    
//    /************************自定义查看更多属性设置****************************/
  
  NSArray *nils = [[NSBundle mainBundle] loadNibNamed:@"RefreshView" owner:self options:nil];
  self.refreshView = [nils objectAtIndex:0];
  [refreshView setupWithOwner:self.tableView delegate:self];
  
     [self footerViewInit];
  
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
  self.tableView.tableFooterView = nil;
  self.currentDisplayingRow = -1;
    if ([self.dataArr count] <= 0) {
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

#pragma mark - initUserData
/**
 *  根据listType的值来显示不同的信息
 */
- (void)dataSourceInitWithType{
    if (self.listType == ListTypeRecord) {
        [self showRecordListInfo];
    }else if (self.listType == ListTypeCollection){
        [self showCollectionListInfo];
    }else if (self.listType == ListTypeLocation){
        [self showLocationListInfo];
    }
}

/**
 *  加载更多的事件处理
 *
 *  @param sender sender
 */
- (IBAction)addMoreDataToTable:(id)sender{
    self.isMore = TRUE;
    self.footerBtn.selected = YES;
    if (self.listType == ListTypeRecord) {
        [self getRecordInfoRequest:self.docType startIndex:[self.dataArr count]];
    }else if (self.listType == ListTypeCollection){
        [self getcollectionInfoRequest:self.docType start:[self.dataArr count]];
    }
}


#pragma mark - get diff data by List Type
/**
 *  显示记录信息，先获取本地的信息显示，在到服务器请求新数据显示
 */
- (void)showRecordListInfo{
    [ImdAppBehavior localDocLog:[Util getUsername] MACAddr:[Util getMacAddress] title:@"showRecord"];
    
    //数据库中获取数据显示，在获取网络数据 数据库需修改
    if ([self.dataArr count] == 0 && self.isFirstGet) {
        [self.dataArr addObjectsFromArray:[DatabaseManager getRecordFromDatabaseWithUserId:[Util getUsername]]];
        
        [self reloadTableViewData];
    }
    
    [self getRecordInfoRequest:self.docType startIndex:0];
}

/**
 *  显示收藏的文献信息
 */
- (void)showCollectionListInfo{
    [self getcollectionInfoRequest:self.docType start:0];
}

/**
 *  显示本地文献信息
 */
- (void)showLocationListInfo{
    [self getLocationInfoWithType:self.docType];
}

#pragma mark - data source get From server or location
/**
 *  获取查看过文献的记录信息
 *
 *  @param type  文献的类型，包括全部文献，英文文献，中文文献
 *  @param start 从第几个开始
 */
- (void)getRecordInfoRequest:(DocType)type startIndex:(NSInteger)start{
    self.isFirstGet = FALSE;
    [self clearRequestDelegate];
    
    NSString *url = [ImdUrlPath getDocListRecordUrl:type start:start limit:defaultLimit];
    self.listRequest = [UrlRequest sendWithPadToken:url delegate:self];
}

/**
 *  获取收藏的文献信息
 *
 *  @param type  文献的类型，包括全部文献，英文文献，中文文献
 *  @param start 从第几个开始
 */
- (void)getcollectionInfoRequest:(DocType)type start:(NSInteger)start{
    self.isFirstGet = FALSE;
    [self clearRequestDelegate];
    self.listRequest = [UrlRequest sendWithPadToken:[ImdUrlPath getFavListUrl:type start:start limit:defaultLimit] delegate:self];
    self.listRequest.didFinishSelector = @selector(requestCollectionFinish:);
}

/**
 *  移除收藏信息请求收藏信息
 *
 *  @param externalId 移除信息的externalId
 */
- (void)collectionItemRemove:(NSString *)externalId{
    [MyDatabase cleanFav:@"MySearchTable" ismgr:IMD_Mydoc externalId:externalId userid:[UserManager userName]];
    NSString *url = [ImdUrlPath docRemoveFavsUrl:externalId];

    [self clearRequestDelegate];
    self.listRequest = [UrlRequest sendWithPadToken:url delegate:nil];
}

/**
 *  获取本地文件列表数据
 *
 *  @param type 获取的类型，暂不可用
 */
- (void)getLocationInfoWithType:(DocType)type{
    [ImdAppBehavior localDocLog:[Util getUsername] MACAddr:[Util getMacAddress] title:@"showLocation"];
    
    self.dataArr = [myDatabaseOption getSavedDoc];
    [self reloadTableViewData];
    
    [self.refreshView stopLoading];
}

/**
 *  移除数据库中的下载记录信息
 *
 *  @param eId 需要移除的externalId
 */
- (void)remvoeFromDownloadArraysWith:(NSString*)eId {
    if (eId) {
        [myDatabaseOption removeSavedDoc:eId];
    }
}

- (void)locationItemRemoveByFileName:(NSString *)fileName{
    NSString * filepath = [searchMainUtils filePathInDocuments:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
        NSLog(@"pdf删除成功");
    }
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MyDocmentPadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    DocInfoRecord *record = [self.dataArr objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"MyDocmentPadCell" owner:self options:nil] ;
        for (id object in nibs) {
            if ([object isKindOfClass:[MyDocmentPadCell class]]) {
                cell = [(MyDocmentPadCell *) object initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
        }
    }
    
    
    cell.listType = self.listType;      //显示的cell类型
    if (self.listType == ListTypeLocation) {
        NSDictionary *resultsItem = [self.dataArr objectAtIndex:indexPath.row];
        [cell setCellInfoWithLocationInfo:resultsItem];
    }else{
        [cell setCellInfoWithDocInfo:record];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if(self.currentDisplayingRow != indexPath.row)
  {
    if (self.listType == ListTypeRecord || self.listType == ListTypeCollection) {
      DocInfoRecord *record = [self.dataArr objectAtIndex:indexPath.row];
      record.isRead = TRUE;
      
      NSString *recorder = record.type;
      
      if (![MyDatabase isSelectId:record.externalId ismgr:IMD_Mydoc]) {
        if (self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(showDocDetailWithExternalIdFromDocument:listType:isRecod:)]) {
          [self.mainDelegate showDocDetailWithExternalIdFromDocument:record.externalId listType:self.listType isRecod:recorder];
        }
        
      }else {
        NSDictionary *dic = [MyDatabase readDocData:IMD_Mydoc externalId:record.externalId];
        if (self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(showDocDetailInfoFromDocument:listType:isRecod:)]) {
          [self.mainDelegate showDocDetailInfoFromDocument:dic listType:self.listType isRecod:recorder];
        }
      }
        //update数据库信息
      [DatabaseManager updataRecordReadStatus:YES externalId:record.externalId withUserId:record.userid];
    }else if (self.listType == ListTypeLocation){
        //        本地文献查看特殊处理
      NSDictionary *dic = [self.dataArr objectAtIndex:indexPath.row];
      
      if (self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(showDocDetailInfoFromDocument:listType:isRecod:)]) {
        [self.mainDelegate showDocDetailInfoFromDocument:dic listType:self.listType isRecod:NO];
      }
    }
  }
  self.currentDisplayingRow = indexPath.row;
    // Push the view controller.
  
    
    [self reloadTableViewData];
    
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    
    // 是否有删除功能，有的话加上处理，返回YES，无的话不处理返回NO；
    if (self.listType == ListTypeRecord) {
        return NO;
    }
    return YES;
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
//          TODO::  远程删除记录信息
            
            [self.dataArr removeObject:recored];
            [DatabaseManager deleteRecordInfo:recored];
        }else if(self.listType == ListTypeCollection){
            DocInfoRecord *recored = [self.dataArr objectAtIndex:indexPath.row];
            [self collectionItemRemove:recored.externalId];
            [self.dataArr removeObject:recored];
        }else if (self.listType == ListTypeLocation){
            NSDictionary *valueDic = [self.dataArr objectAtIndex:indexPath.row];
            
            NSString *externalId = [valueDic objectForKey:DOC_EXTERNALID];
            NSString *fileId =[Util md5:externalId];
            NSString *fileName = [NSString stringWithFormat:@"%@.pdf",fileId];
            NSString *filePath = [searchMainUtils filePathInDocuments:fileName];
            
            NSError *error;
            if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                NSLog(@"del failed %@", error);
            }
            
            if (![myDatabaseOption isSavedDocWithAnother:externalId]) {
                [self locationItemRemoveByFileName:fileName];
            }
            [self remvoeFromDownloadArraysWith:externalId];
            
            [self.dataArr removeObject:valueDic];
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


#pragma mark- ASIHTTPrequest Delegate
/**
 *  收藏请求的服务器返回
 *
 *  @param request 请求的ASI
 */
- (void)requestCollectionFinish:(ASIHTTPRequest *)request{
  
    
    NSLog(@"request info %@",request.responseString);
    NSDictionary *jsonInfo = [UrlRequest getJsonValue:request];
  int collectionCount = [[jsonInfo objectForKey:@"count"] intValue];
  if ([[jsonInfo objectForKey:@"count"] intValue] == 0) {
    [self.refreshView stopLoading];
    return;
  }
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
        //self.indexPostion = [NSIndexPath indexPathForRow:0 inSection:0];
        
        self.dataArr = [NSMutableArray arrayWithArray:[self parseJsonData:jsonInfo parseType:ListTypeCollection]];
      [self reloadTableViewData];
      [self.refreshView stopLoading];

    }
  [self addFavToDatabase:[jsonInfo objectForKey:@"docs"]];
  if (collectionCount > self.dataArr.count) {
    self.tableView.tableFooterView = self.footerView;
    self.footerView.hidden = NO;
  }else
  {
    self.footerView.hidden = YES;
  self.tableView.tableFooterView = nil;
  }
}

/**
 *  获取记录的服务器请求
 *
 *  @param request 请求的ASI
 */
- (void)requestFinished:(ASIHTTPRequest *)request{
  
    self.footerBtn.titleLabel.text = @"加载更多...";
    NSLog(@"request info %@",request.responseString);
    NSDictionary *jsonInfo = [UrlRequest getJsonValue:request];
  int collectionCount = [[jsonInfo objectForKey:@"count"] intValue];
  if (collectionCount == 0) {
    [self.refreshView stopLoading];
    return;
  }
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
    
  if (collectionCount > self.dataArr.count) {
    self.tableView.tableFooterView = self.footerView;
    self.footerView.hidden = NO;
  }else
  {
    self.footerView.hidden = YES;
    self.tableView.tableFooterView = nil;
  }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (DocInfoRecord *record in subArr) {
            [DatabaseManager insertToDataBaseWithRecord:record];
        }
    });
  
}

- (void)requestFailed:(ASIHTTPRequest *)request{
  
    self.footerBtn.titleLabel.text = @"加载更多...";
    NSLog(@"request info %@",request.responseString);
    [self reloadTableViewData];
    [self.refreshView stopLoading];
}

#pragma mark - UItableView and request need method
- (void)clearRequestDelegate{
    if (self.listRequest) {
        [self.listRequest clearDelegatesAndCancel];
    }
}

/**
 *  刷新UITableView的数据， 并且根据得到的数据源信息来决定是否显示footerView，以及需要在控制页的处理
 */
- (void)reloadTableViewData{
    [self.tableView reloadData];
//    if (self.indexPostion) {
//        [self.tableView scrollToRowAtIndexPath:self.indexPostion atScrollPosition:UITableViewScrollPositionNone animated:YES];
//    }
  
    
    self.footerBtn.selected = NO;
    if ([self.dataArr count] % defaultLimit == 0 && [self.dataArr count] != 0) {
      if (self.listType != ListTypeLocation) {
        self.tableView.tableFooterView = self.footerView;
      }else
        self.tableView.tableFooterView = nil;
    }else{
        self.tableView.tableFooterView = nil;
    }
    
    if ([self.listDelegate respondsToSelector:@selector(reloadtableView)]) {
        [self.listDelegate reloadtableView];
    }
}

#pragma mark - init UITableView FooterView
/**
 *  对UITableView的footerView进行设置
 */
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

/**
 *  解析从服务器端请求得到的数据，
 *
 *  @param valueInfo 服务器端返回的json字符串
 *  @param type      需要解析的类型，数据格式相同，暂无影响
 *
 *  @return 解析出的model数组
 */
- (NSArray *)parseJsonData:(NSDictionary *)valueInfo parseType:(ListType)type{
    NSMutableArray *retArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *docList = [valueInfo objectForKey:@"docs"];
    
    for (int i = 0, sum = [docList count]; i < sum; i++) {
        NSDictionary *valueDic = [docList objectAtIndex:i];
        NSDictionary *docDic = [valueDic objectForKey:@"docDetails"];
        DocInfoRecord *record = [[DocInfoRecord alloc] init];
        record.externalId = [docDic objectForKey:@"id"];
        record.userid = [valueDic objectForKey:@"userid"];
        
        if ([[valueDic objectForKey:@"cat"] isEqualToString:@"cn"]) {
            record.type = [valueDic objectForKey:@"downloadStatus"];
        }else{
            record.type = [valueDic objectForKey:@"requestStatus"];
        }
        
        NSArray *authorArr = [docDic objectForKey:@"author"];
        record.author = [authorArr componentsJoinedByString:@"::"];
        record.title = [docDic objectForKey:@"title"];
        record.pagination = [docDic objectForKey:@"pagination"];
        int pubD = [[docDic objectForKey:@"pubdate"] intValue];
        record.pubDate = [NSString stringWithFormat:@"%d",pubD];
        record.issue = [docDic objectForKey:@"issue"];
        record.journal = [docDic objectForKey:@"journal"];
        record.volume = [docDic objectForKey:@"volume"];
        record.isRead = NO;
        
        [retArr addObject:record];
    }
    return retArr;
}
- (void)addFavToDatabase:(NSArray *)arrayFav
{
  for (NSDictionary *infoDic in arrayFav) {
    if (infoDic == nil) {
      return;
    }
    NSString *eId = [[infoDic objectForKey:@"docDetails"] objectForKey:@"id"];
    NSArray* authArray = [[infoDic objectForKey:@"docDetails"] objectForKey:KEY_DOC_AUTHOR];
    NSString *author = [Util arrayToString:authArray sep:SEPARATING];
    NSString *issue = [[infoDic objectForKey:@"docDetails"] objectForKey:KEY_DOC_ISSUE];
    NSString *journal = [[infoDic objectForKey:@"docDetails"] objectForKey:KEY_DOC_JOURNAL];
    NSString *pagination = [[infoDic objectForKey:@"docDetails"] objectForKey:KEY_DOC_PAGINATION];
    NSString *pubDate = [[infoDic objectForKey:@"docDetails"] objectForKey:KEY_DOC_PUB_DATE];
    NSString *title = [[infoDic objectForKey:@"docDetails"] objectForKey:KEY_DOC_TITLE];
    NSString *volume = [[infoDic objectForKey:@"docDetails"] objectForKey:KEY_DOC_VOLUME];
    [myDatabaseOption addFav:eId author:author issue:issue journal:journal pubDate:pubDate title:title volume:volume pagination:pagination];
  }
}
@end
