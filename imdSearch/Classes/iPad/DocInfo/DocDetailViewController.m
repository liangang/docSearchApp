//
//  DocDetailViewController.m
//  imdSearch
//
//  Created by xiangzhang on 4/14/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "DocDetailViewController.h"

#import "ASIHTTPRequest.h"
#import "NMCustomLabel.h"
#import "NetStatusChecker.h"

#import "imdSearcher.h"
#import "Util.h"
#import "url.h"
#import "Url_iPad.h"
#import "UrlRequest.h"
#import "ImdAppBehavior.h"
#import "JSON.h"
#import "myDatabaseOption.h"

#import "imdSearchAppDelegate.h"

#import "TKAlertCenter.h"
#import "searchMainUtils.h"
#import "downloader.h"
#import "Strings.h"
#import "PadText.h"
#import "PDFViewTiled.h"

#import "MBProgressHUD.h"
#import "EnumType.h"
#import "ImdUrlPath.h"
#import "MyDataBaseSql.h"

#define DEFAULT_LINE_SPACE 8.0f
#define DETAIL_JOURNAL_DEFAULT_SIZE 16.0f
#define DETAIL_AFFILIATIONS_DEFAULT_SIZE 16.0f
#define DETAIL_AUTHORS_DEFAULT_SIZE 16.0f

#define FONT_OFFSET_ZERO 0
#define FONT_OFFSET_MINUS -5
#define FONT_OFFSET_PLUS 5

#define HTTP_REQUEST_SEARCH_DETAIL @"searchDetail"

/**
 *  请求的tag
 */
#define RequestGetDetailTag     2014052104
#define RequestCheckUserStatus  2014052105
#define RequestAddFavDoc        2014052201
#define RequestRemoveFavDoc     2014052202
#define RequestDownLoadFile     2014052203
#define RequestAskPDFFile       2014052204
#define RequestAskStatus        2014052205
#define RequestJumpAskStatus    2014052206

/**
 *  alertView的tag标志
 */
#define TagWithInactive     2014052303
#define TagWithAskSuccess   2014052304
#define TagWithUnverify     2014052305
#define TagWIthUpperLimit   2014052306
#define TagWithShowLogin    2014052307

@interface DocDetailViewController ()<ASIHTTPRequestDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>{
    int currentDetailsFontSizeOffset;
    BOOL isFavDetail;
    BOOL isAskFor;
}

@property (nonatomic, strong) ASIHTTPRequest *detailInfoRequest;        //文献详情的ASI
@property (nonatomic, strong) ASIHTTPRequest *favInfoRequest;           //文献收藏的ASI
@property (nonatomic, strong) downloader *downLoadDetailRequest;        //文献下载的ASI

@property (nonatomic, strong) NSString *jumpExternalId;                 //要跳转的externalId

//@property (strong, nonatomic) NSDictionary *docDetailInfo;

- (void)displayDetails:(NSDictionary *)docInfo;                     //根据文献的信息显示文献详情
@end

@implementation DocDetailViewController
@synthesize isrecord;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentDetailsFontSizeOffset = FONT_OFFSET_ZERO;
        isFavDetail = NO;
        self.meunSoruce = MeunSoruceSearch;
        isAskFor = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.docInfoDic) {
        [self displayDetails:self.docInfoDic];
        self.externelId = [self.docInfoDic objectForKey:@"externalId"];
    }else{
        [self showDetail:self.externelId];
    }
  BOOL userLogin =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
  if (self.externelId.length > 0 && userLogin) {
    if ([myDatabaseOption isFav:self.externelId]) {
      [self favDocBtnChangeByisFav:YES];
      isFavDetail = YES;
    }
  }
    //gesture recognition
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchEvent:)];
	tapGesture.cancelsTouchesInView = NO;
    tapGesture.delaysTouchesEnded = NO;
    tapGesture.delegate = self;
	tapGesture.numberOfTouchesRequired = 1;
    tapGesture.numberOfTapsRequired = 2; // One finger double tap
    
	[self.contentScrollView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer* tapGesture2 = tapGesture;
    tapGesture2.numberOfTapsRequired = 1; // One finger double tap
	[self.contentScrollView addGestureRecognizer:tapGesture2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    /**
     *  清楚ASI的代理
     */
    [self.detailInfoRequest clearDelegatesAndCancel];
    [self.favInfoRequest clearDelegatesAndCancel];
    [self.downLoadDetailRequest clearDelegatesAndCancel];
}

- (void)handleTouchEvent:(UITapGestureRecognizer *)recognizer{
    NSInteger  number = recognizer.numberOfTapsRequired;
    
    if (2 == number) {
        [self.contentScrollView setZoomScale:1.0f animated:YES];
    }
}

/**
 *  减少字体显示
 */
- (IBAction)downSizeTextClick:(id)sender {
    if( currentDetailsFontSizeOffset == FONT_OFFSET_ZERO)
        currentDetailsFontSizeOffset = FONT_OFFSET_MINUS;
    else if(currentDetailsFontSizeOffset == FONT_OFFSET_PLUS)
        currentDetailsFontSizeOffset = FONT_OFFSET_ZERO;
    
    [self displayDetails:self.docInfoDic];

}
/**
 *    FONT +
 */
- (IBAction)largeSizeTextClick:(id)sender {
    if( currentDetailsFontSizeOffset == FONT_OFFSET_ZERO)
        currentDetailsFontSizeOffset = FONT_OFFSET_PLUS;
    else if(currentDetailsFontSizeOffset == FONT_OFFSET_MINUS)
        currentDetailsFontSizeOffset = FONT_OFFSET_ZERO;
    
     [self displayDetails:self.docInfoDic];
}


- (IBAction)favDocBtnClick:(id)sender {
  if (self.externelId.length == 0 || self.externelId == nil) {
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"ID为空无法收藏"];
    return;
  }
    if (isFavDetail) {
        [self removeFav:self.externelId];
    }else{
        [self addFav:self.externelId];
    }
}

/**
 *  下载文献
 */
- (IBAction)downloadDocClick:(id)sender {
    self.downloadDocBtn.enabled = NO;
    BOOL userLogin =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    if((!userLogin) || (!appDelegate.auth.imdToken.length > 0))
    {
        [self showAlertViewWithTitle:@"帐号登录" message:@"查看全文需登录帐号，请登录！" tag:TagWithShowLogin canceButtonlTitle:@"确认" otherButtonTitle:nil];
        return;
    }
  if (self.documentType != ListTypeLocation) {
    if (![NetStatusChecker isNetworkAvailbe]) {
      [[TKAlertCenter defaultCenter] postAlertWithMessage:@"无法连接到互联网，请查看设置"];
      self.downloadDocBtn.enabled = YES;
      return;
    }
  }
//    先查看本地是否有文献，在到网上下载文献
    NSString* eId =[self.docInfoDic objectForKey:@"externalId"];
  if (eId.length == 0 || eId == nil) {
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"ID为空无法下载"];
    return;
  }
    NSString* fileId =[Util md5:eId];
    NSString* fileName = [NSString stringWithFormat:@"%@.pdf",fileId];
    NSString *filePath = [searchMainUtils filePathInDocuments:fileName];
    
    NSString* title =[self.docInfoDic objectForKey:@"title"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if([self loadPDFTest:fileName]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showPDFWithexternalId:fileName:pdfTitle:)]) {
                [self.delegate showPDFWithexternalId:eId fileName:fileName pdfTitle:title];
            }
          self.downloadDocBtn.enabled = YES;
            return;
        } else {
            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                NSLog(@"del failed %@",error);
                
                [self downLoadDetailWithDetail:self.docInfoDic];
                return;
            }
        }
    }else{
        [self downLoadDetailWithDetail:self.docInfoDic];
    }
}

#pragma mark - message tips
- (void)showMsgBarWithInfo:(NSString *)text
{
    [self showMsgBarWithLoading:text];
    [self performSelector:@selector(hideMsgBar) withObject:nil afterDelay:6.0f];
}

-(void)showMsgBarWithLoading:(NSString*)text {
    NSLog(@"showing bar %@",text);
    
    self.msgtipLabel.text = text;
    self.msgLoadingActivity.hidden = NO;
    self.msgtipsImgView.hidden= NO;
  
  if ([text isEqualToString:@"对不起，您申请的文献全文未找到."] || [text isEqualToString:@"您已提交过获取该文献全文的请求，请耐心等待，谢谢！"]) {
    
  }else
    [self.msgLoadingActivity startAnimating];
    
    [UIView animateWithDuration:0.3 animations:^(){
        self.messgaeView.frame = CGRectMake(0, 40, 612, 40);
    }];
}

-(void)hideMsgBar
{
    [self.msgLoadingActivity stopAnimating];
    [UIView animateWithDuration:0.5 animations:^(){
        self.messgaeView.frame = CGRectMake(0, 0, 612, 40);

    }];
}

/**
 *  下载文献PDF，根据中英文不同的下载，中文直接下载，英文发送索取
 *
 *  @param valueInfo 文献详情
 */
- (void)downLoadDetailWithDetail:(NSDictionary *)valueInfo{
    BOOL downWIfiOnly = [[[NSUserDefaults standardUserDefaults] objectForKey:@"downWifiOnly"] boolValue];
    if (downWIfiOnly && ![NetStatusChecker isUsingWifi]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"您设置了只在wifi网络环境下载全文"];
      self.downloadDocBtn.enabled = YES;
      return;
    }
    
    //调出下载全文的提醒页
     [ImdAppBehavior downloadFullText];
    
    NSString* eId =[valueInfo objectForKey:@"externalId"];
    NSString* iId =[valueInfo objectForKey:@"internalId"];
    NSString* title =[valueInfo objectForKey:@"fileTitle"];
    if (title == (id)[NSNull null] || title.length == 0) {
        title = [valueInfo objectForKey:@"title"];
    }
    
    NSString *fileId =[Util md5:eId];
    NSString *fileName = [NSString stringWithFormat:@"%@.pdf",fileId];
    NSString *filePath = [searchMainUtils filePathInDocuments:fileName];
    
    NSString *pmid = [valueInfo objectForKey:@"PMID"];
    int lan = ([pmid isEqualToString:@""] || pmid == nil || [pmid isEqualToString:@"(null)"] || [pmid isEqualToString:@"null"]) ? SEARCH_MODE_CN : SEARCH_MODE_EN;
    if (lan == SEARCH_MODE_CN) {
        [self showMsgBarWithLoading:@"正在为您获取全文..."];
      if (self.meunSoruce != MeunSoruceSearch && self.documentType == ListTypeRecord) {
        [self downloadCNPdfWithExternalId:eId andInternalId:iId title:title filePath:filePath fileName:fileName];
      }else
        [self downloadPdfWithExternalId:eId andInternalId:iId title:title filePath:filePath fileName:fileName];
    }else{
        NSString* status = [valueInfo objectForKey:@"fetchStatus"];
        if (status != nil && ![status isEqualToString:@"SUCCESS"] && ![status isEqualToString:@""]) {
            [self hideMsgBar];
            
            [self showAlertViewWithTitle:@"已发送过索取请求" message:@"请查收您的“注册邮箱”或者关注“本地文献”中“索取中/已索取”文献列表" tag:TagWithAskSuccess canceButtonlTitle:@"我知道了" otherButtonTitle:@"立即查看"];
          self.downloadDocBtn.enabled = YES;
            self.jumpExternalId = eId;
            return;
        }
        
        if (self.meunSoruce == MeunSoruceSearch || self.documentType == ListTypeCollection) {
            [self showMsgBarWithLoading:@"正在检查索取状态"];
            [self requestPDFToLocation];
        }else{
            [self showMsgBarWithLoading:@"正在为您获取全文..."];
            [ImdAppBehavior downloadFullText];
            [self askPdfWIthExternalId:eId internalId:iId disPlayFullText:YES title:title filePath:filePath fileName:fileName];
        }
    }
}

/**
 *  添加收藏
 *
 *  @param fid 收藏的ID
 */
- (void)addFav:(NSString*)fid {
    BOOL userLogin =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
    if (!userLogin) {
        [self showAlertViewWithTitle:@"帐号登录" message:@"收藏文献需登录帐号，请登录！" tag:TagWithShowLogin canceButtonlTitle:@"确定" otherButtonTitle:nil];
        return;
    }
    
    
    if (![NetStatusChecker isNetworkAvailbe]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"无法连接到互联网，请查看设置"];
        return;
    }
    
    NSString *externalId = [self.docInfoDic objectForKey:@"externalId"];
    if (externalId == nil) {
        externalId = [self.docInfoDic objectForKey:@"id"];
    }
    NSString *title = [self.docInfoDic objectForKey:@"title"];
    
    if (title == nil) {
        title =  [self.docInfoDic objectForKey:@"fileTitle"];
    }
    
    if (self.favInfoRequest) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.favInfoRequest clearDelegatesAndCancel];
    }
    self.favInfoRequest = [self addFavoriteDoc:externalId filetitle:title];

}

/**
 *  移除收藏信息
 *
 *  @param fid 移除文献的Id
 */
- (void)removeFav:(NSString*)fid {
    if (![NetStatusChecker isNetworkAvailbe]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"无法连接到互联网，请查看设置"];
        return;
    }
    
    NSString *externalId = [self.docInfoDic objectForKey:@"externalId"];
    if (externalId == nil) {
        externalId = [self.docInfoDic objectForKey:@"id"];
    }
    
    if (self.favInfoRequest) {
        [self.favInfoRequest clearDelegatesAndCancel];
    }
    self.favInfoRequest = [self removeFavoriteDoc:externalId];
}

- (NSString *)getStringReplaceNull:(NSString *)source{
    BOOL nullFlag = (source == (id)[NSNull null] || source.length == 0);
    NSString *target = (nullFlag ? @"" : [Util replaceEM:source LeftMark:@"" RightMark:@""]);
    return target;
}

#pragma mark - network deal
/**
 *  获取文献的详细信息
 *
 *  @param externalId 文献的Id
 */
-(void)showDetail:(NSString *)externalId
{
    if (externalId == nil || [externalId isEqualToString:@""]) {
        return;
    }
    [myDatabaseOption searchDetail:externalId];
  if (self.detailInfoRequest != nil) {
    [self.detailInfoRequest clearDelegatesAndCancel];
    self.detailInfoRequest = nil;
  }
      self.detailInfoRequest = [self getDetailInfo:externalId];
}

/**
 *  获取文献的详情信息
 *
 *  @param externelId 文献的唯一ID
 */
-(ASIHTTPRequest *)getDetailInfo:(NSString*)externelId
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString* url = [NSString stringWithFormat:@"http://%@/docsearch/docu/%@/",SEARCH_SERVER, externelId];
    NSLog(@"url =%@",url);
    
    ASIHTTPRequest* request =
    [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    [UrlRequest setPadToken:request];

    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"downAskDetail" forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    
    request.delegate =self;
    [request startAsynchronous];
    request.tag = RequestGetDetailTag;
    
    return request;
}

/**
 *  添加收藏的文件信息
 *
 *  @param externalId 文献的Id
 *  @param title      文献的标题
 *
 *  @return 请求的ASI
 */
- (ASIHTTPRequest *)addFavoriteDoc:(NSString *)externalId filetitle:(NSString *)title{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    title = [Util replaceEM:title LeftMark:@"" RightMark:@""];
    title = [Util URLencode:title stringEncoding:NSUTF8StringEncoding];
    
    NSString *addFav = [NSString stringWithFormat:@"http://%@/docsearch/fav?id=%@&title=%@",SEARCH_SERVER,externalId,title];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:addFav]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [UrlRequest setPadToken:request];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"addFav" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    request.tag = RequestAddFavDoc;
    [request startAsynchronous];
    
    return request;
}

/**
 *  移除收藏信息
 *
 *  @param externalId 文献标识
 *
 *  @return 请求ASI
 */
- (ASIHTTPRequest *)removeFavoriteDoc:(NSString *)externalId{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (externalId == nil) {
        return nil;
    }
    
    NSString* removeFavURL =[NSString stringWithFormat:@"http://%@/docsearch/removefav/%@",SEARCH_SERVER,externalId];
    
    NSLog(@"url = %@",removeFavURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:removeFavURL]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    [UrlRequest setPadToken:request];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"removeFav" forKey:@"requestType"];
    [userInfo setObject:externalId forKey:@"externalId"];
    
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    request.tag = RequestRemoveFavDoc;
    [request startAsynchronous];
    
    return  request;
}

/**
 *  下载中文pdf文献请求
 *
 *  @param eId      文献externalId
 *  @param iId      文献internalId
 *  @param title    文献标题
 *  @param fPath    文献路径
 *  @param fName    文献名
 */
- (void)downloadPdfWithExternalId:(NSString *)eId andInternalId:(NSString *)iId title:(NSString *)title filePath:(NSString *)fPath fileName:(NSString *)fName{
    if (self.downLoadDetailRequest) {
        [self.downLoadDetailRequest clearDelegatesAndCancel];
        self.downLoadDetailRequest = nil;
    }
    
    NSString *fileUrl = [NSString stringWithFormat:@"http://%@/docsearch/download/%@/",PDFPROCESS_SERVER,eId];
    self.downLoadDetailRequest = [downloader requestWithURL:[NSURL URLWithString:fileUrl]];
    
    [self.downLoadDetailRequest addRequestHeader:@"Content-Type" value:@"application/json"];
    [self.downLoadDetailRequest addRequestHeader:@"Accept" value:@"application/json"];
    
    self.downLoadDetailRequest.fileName = fName;
    self.downLoadDetailRequest.filePath = fPath;
    self.downLoadDetailRequest.fileURL = fileUrl;
    self.downLoadDetailRequest.timeOutSeconds = 120;
    self.downLoadDetailRequest.retryingTimes = 0;
    self.downLoadDetailRequest.retryingMaxTimes = 1;
    [self.downLoadDetailRequest setDownloadDestinationPath:fPath];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"requestPDF" forKey:@"requestType"];
    [userInfo setObject:fName forKey:@"downloadFile"];
    [userInfo setObject:title forKey:@"downloadTitle"];
    [userInfo setObject:fPath forKey:@"downloadPath"];
    
    [self.downLoadDetailRequest setUserInfo:userInfo];
    
    [self setDownLoadToken:self.downLoadDetailRequest];
    
    self.downLoadDetailRequest.delegate = self;
    self.downLoadDetailRequest.tag = RequestDownLoadFile;
    [self.downLoadDetailRequest startAsynchronous];
}
- (void)downloadCNPdfWithExternalId:(NSString *)eId andInternalId:(NSString *)iId title:(NSString *)title filePath:(NSString *)fPath fileName:(NSString *)fName{
  if (self.downLoadDetailRequest) {
    [self.downLoadDetailRequest clearDelegatesAndCancel];
    self.downLoadDetailRequest = nil;
  }
  
  NSString *fileUrl = [ImdUrlPath docDownloadCN:eId];//[NSString stringWithFormat:@"http://%@/docsearch/download/%@/",PDFPROCESS_SERVER,eId];
  self.downLoadDetailRequest = [downloader requestWithURL:[NSURL URLWithString:fileUrl]];
  
  [self.downLoadDetailRequest addRequestHeader:@"Content-Type" value:@"application/json"];
  [self.downLoadDetailRequest addRequestHeader:@"Accept" value:@"application/json"];
  
  self.downLoadDetailRequest.fileName = fName;
  self.downLoadDetailRequest.filePath = fPath;
  self.downLoadDetailRequest.fileURL = fileUrl;
  self.downLoadDetailRequest.timeOutSeconds = 120;
  self.downLoadDetailRequest.retryingTimes = 0;
  self.downLoadDetailRequest.retryingMaxTimes = 1;
  [self.downLoadDetailRequest setDownloadDestinationPath:fPath];
  
  NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
  [userInfo setObject:@"requestPDF" forKey:@"requestType"];
  [userInfo setObject:fName forKey:@"downloadFile"];
  [userInfo setObject:title forKey:@"downloadTitle"];
  [userInfo setObject:fPath forKey:@"downloadPath"];
  
  [self.downLoadDetailRequest setUserInfo:userInfo];
  
  [self setDownLoadToken:self.downLoadDetailRequest];
  
  self.downLoadDetailRequest.delegate = self;
  self.downLoadDetailRequest.tag = RequestDownLoadFile;
  [self.downLoadDetailRequest startAsynchronous];
}

/**
 *  英文pdf文献索取请求
 *
 *  @param eId          文献externalId
 *  @param iId          文献internalId
 *  @param isFull       是否是全文
 *  @param title        文献标题
 *  @param filePath     文献路径
 *  @param fileName     文献名
 */
- (void)askPdfWIthExternalId:(NSString *)eId internalId:(NSString *)iId disPlayFullText:(BOOL)isFull title:(NSString *)title filePath:(NSString *)filePath fileName:(NSString *)fileName{
    if (self.downLoadDetailRequest) {
        [self.downLoadDetailRequest clearDelegatesAndCancel];
        self.downLoadDetailRequest = nil;
    }
    
    NSString *fileUrl = [NSString stringWithFormat:@"http://%@/docsearch/askforpdf/%@",PDFPROCESS_SERVER,eId];
    
    self.downLoadDetailRequest = [downloader requestWithURL:[NSURL URLWithString:fileUrl]];
    
    [self.downLoadDetailRequest addRequestHeader:@"Content-Type" value:@"application/json"];
    [self.downLoadDetailRequest addRequestHeader:@"Accept" value:@"application/json"];
    
    self.downLoadDetailRequest.fileName = fileName;
    self.downLoadDetailRequest.filePath = filePath;
    self.downLoadDetailRequest.fileURL = fileUrl;
    self.downLoadDetailRequest.timeOutSeconds = 120;
    self.downLoadDetailRequest.retryingTimes = 0;
    self.downLoadDetailRequest.retryingMaxTimes = 1;
    [self.downLoadDetailRequest setDownloadDestinationPath:filePath];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"askPDF" forKey:@"requestType"];
    [userInfo setObject:fileName forKey:@"downloadFile"];
    [userInfo setObject:title forKey:@"downloadTitle"];
    [userInfo setObject:filePath forKey:@"downloadPath"];
    
    [userInfo setObject:eId forKey:@"externalId"];
    [userInfo setObject:title forKey:@"fileTitle"];
    [userInfo setObject:filePath forKey:@"filePath"];
    [userInfo setObject:[NSNumber numberWithBool:isFull] forKey:@"fullTextOption"];
    
    [self.downLoadDetailRequest setUserInfo:userInfo];
    
    [self setDownLoadToken:self.downLoadDetailRequest];
    
    self.downLoadDetailRequest.delegate = self;
    self.downLoadDetailRequest.tag = RequestAskPDFFile;
    [self.downLoadDetailRequest startAsynchronous];
}

/**
 *  检查用户的状态信息
 */
- (void) checkUserConfirmInfo
{
    NSString* theUrl = [NSString stringWithFormat:@"http://%@/user/active", CONFIRM_SERVER];
    
    NSLog(@"url =%@",theUrl);
    
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:theUrl]];
    [request addRequestHeader:CONTENT_TYPE value:TYPE_JSON];
    [request addRequestHeader:ACCEPT value:TYPE_JSON];
    [UrlRequest setPadToken:request];
    
    NSMutableDictionary* userInfo =
    [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:HTTP_REQUEST_SEARCH_DETAIL forKey:REQUEST_TYPE];
    NSLog(@"userInfo");
    
    [request setUserInfo:userInfo];
    request.delegate =self;
    request.tag = RequestCheckUserStatus;
    [request startAsynchronous];
}

/**
 *  获取文献，PDF
 */
-(void)requestPDFToLocation{
    [ImdAppBehavior askforFullText];
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"无法连接到互联网，请查看设置"];
        return;
    }
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString* externalId = [NSString stringWithFormat:@"%@", [self.docInfoDic objectForKey:@"externalId"]];
    
    NSString* rawtitle = [NSString stringWithFormat:@"%@", [self.docInfoDic  objectForKey:@"title"]];
    NSString *r1 = [rawtitle stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
    NSString *r2 = [r1 stringByReplacingOccurrencesOfString:@"</em>" withString:@""];
    NSString* title =[Util URLencode:r2 stringEncoding:NSUTF8StringEncoding];

    NSString *deviceNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceNumber"];
    NSString* askURL =[NSString stringWithFormat:@"http://%@/docsearch/askfor?id=%@&title=%@&devices=%@",SEARCH_SERVER,externalId,title,[Util URLencode:deviceNumber stringEncoding:NSUTF8StringEncoding]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:askURL]];
    NSLog(@"ask url =%@",askURL);
    
    [UrlRequest setPadToken:request];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"askFullText" forKey:@"requestType"];
    [userInfo setObject:externalId forKey:@"askingId"];
    [userInfo setObject:rawtitle forKey:@"askingTitle"];
    [userInfo setObject:self.docInfoDic  forKey:@"item"];
    
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    request.tag = RequestAskStatus;
    [request startAsynchronous];
    
    [self showMsgBarWithLoading:@"正在为您获取全文..."];
}

/**
 *
 *
 *  @param externalId 文献的id
 *
 *  @return
 */
-(BOOL)loadRequestStatusWithExternalId:(NSString *)externalId {
    if (externalId == nil || [externalId isEqualToString:@""]) {
        return false;
    }
    
    if(![NetStatusChecker isNetworkAvailbe])
    {
        return false;
    }
    
    NSString* askURL =[NSString stringWithFormat:@"http://%@/docsearch/askforstatus",SEARCH_SERVER];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:askURL]];
    
    NSLog(@"ask url =%@",askURL);
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    request.requestMethod =@"POST";
    
    NSMutableArray* askforId=[[NSMutableArray alloc] initWithCapacity:20];
    
    [askforId addObject:externalId];
    
    [request appendPostData:[[askforId JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [UrlRequest setPadToken:request];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"jumpAskCheckStatus" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = self;
    request.tag = RequestJumpAskStatus;
  
    [request startAsynchronous];
    
    return true;
}
-(ASIHTTPRequest*)getUserInfo:(NSString *)url delegate:(id)dlgt
{
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
  
  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  [UrlRequest setPadToken:request];
  
  NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
  [userInfo setObject:@"checkVer" forKey:@"requestType"];
  [request setUserInfo:userInfo];
  
  request.timeOutSeconds = 2*10;
  request.delegate = dlgt;
  [request setDidFinishSelector:@selector(getUserInfoFinish:)];
  [request startAsynchronous];
  
  return request;
}
-(void)getUserInfoFinish:(ASIHTTPRequest *)request
{
  NSDictionary* requestInfo =[request userInfo];
  NSString* rType = [requestInfo objectForKey:@"requestType"];
  
  NSDictionary* userInfoDic = [UrlRequest getJsonValue:request];
  
  if ([rType isEqualToString:@"checkVer"]) {
    NSDictionary* infoDic = [userInfoDic objectForKey:@"info"];
    NSString *userType = [infoDic objectForKey:@"userType"];
    if ([userType isEqualToString:@"Doctor"] | [userType isEqualToString:@"Student"]) {
      if (self.delegate && [self.delegate respondsToSelector:@selector(presentViewWithType:)]) {
                     [self.delegate presentViewWithType:PresentTypeVerifiedView];
                  }
    }else{
      if (self.delegate && [self.delegate respondsToSelector:@selector(presentViewWithType:)]) {
        [self.delegate presentViewWithType:PresentUserTypeView];
      }
    }
}
}
#pragma mark - ASIHTTRequest Deleaget
- (void)requestFinished:(ASIHTTPRequest *)request{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSString *responseStr = request.responseString;
    NSDictionary *requestInfo = [request userInfo];
    NSLog(@"response string %@",responseStr);
    
    NSDictionary* info;
    if (responseStr == (id)[NSNull null] || responseStr.length == 0) {
        info = nil;
    } else {
        info = [responseStr JSONValue];
    }
    
    if (request.tag == RequestGetDetailTag) {
        self.docInfoDic = [info objectForKey:@"article"];
        [MyDataBaseSql insertDetail:[NSMutableDictionary dictionaryWithDictionary:self.docInfoDic] ismgr:@"1" filePath:nil];
        isFavDetail = [[info objectForKey:@"isFav"] boolValue];
        [self favDocBtnChangeByisFav:isFavDetail];
        [self displayDetails:self.docInfoDic];
      if (self.delegate && [self.delegate respondsToSelector:@selector(copyDocDetailInfo:)]) {
        [self.delegate copyDocDetailInfo:self.docInfoDic];
      }
    }else if (request.tag == RequestAddFavDoc){
        isFavDetail = YES;
        //TODO::重新刷新收藏的文件信息, 用通知
        [self searchAddFav:self.docInfoDic];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已添加到收藏夹！"];
        [self favDocBtnChangeByisFav:isFavDetail];
        
    }else if (request.tag == RequestRemoveFavDoc){
        isFavDetail = NO;
        [myDatabaseOption removeFav:self.externelId];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"已从收藏夹移除！"];
        [self favDocBtnChangeByisFav:isFavDetail];
        
    }else if (request.tag == RequestDownLoadFile){
      self.downloadDocBtn.enabled = YES;
        if(responseStr && [Util isHtml:responseStr]) {
            [self showMsgBarWithInfo:@"文件出错，请稍后重试"];
            
            NSString* filePath = [requestInfo objectForKey:@"downloadPath"];
            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
            {
                NSLog(@"del failed %@",error);
            }
        }else{
            NSString* fileName = [requestInfo objectForKey:@"downloadFile"];
            NSString* fileTitle = [requestInfo objectForKey:@"downloadTitle"];
            NSString* filePath =[requestInfo objectForKey:@"downloadPath"];
            
            BOOL pdfFailed =NO;
            NSString *response = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
            
            if ([response isEqualToString:@"MAXVALUE"]) {
                [self showMaxValueAlert];
                
                return;
            }else if([response isEqualToString:@"FAIL"]){
                [self showMsgBarWithInfo:@"对不起，您申请的文献全文未找到."];
                pdfFailed =YES;
                
            }else if ([response isEqualToString:@"QUEUE"]){
                [self showMsgBarWithInfo:DOWNLOAD_DOC_QUEUE];
                
            }else if ([response isEqualToString:@"INACTIVE"]){
                [self showInactiveAlert];
                
                pdfFailed =YES;
            }else if ([response isEqualToString:@"UNVERIFIED"]){
                [self showUnverifiedAlert];
                
                pdfFailed =YES;
            }else{
                NSLog(@"res =%@",response);
                if(response ==nil)
                    pdfFailed =NO;
                else {
                    pdfFailed =YES;
                }
            }
            
            if (pdfFailed) {
                NSError *error = nil;
                if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                    NSLog(@"del failed %@",error);
                }
            }else{
                [self hideMsgBar];
                if (self.delegate && [self.delegate respondsToSelector:@selector(showPDFWithexternalId:fileName:pdfTitle:)]) {
                    [self.delegate showPDFWithexternalId:self.externelId fileName:fileName pdfTitle:fileTitle];
                }
            }
        }
    }else if (request.tag == RequestAskPDFFile){
        NSMutableArray *askArr = [myDatabaseOption getAsked];
      self.downloadDocBtn.enabled = YES;
        if (responseStr && [Util isHtml:responseStr]) {
            
            int sum = [askArr count];
            
            NSString* eId =[requestInfo objectForKey:@"externalId"];
            
            for(int i = 0;i < sum;i++)
            {
                NSDictionary* dict = [askArr objectAtIndex:i];
                NSDictionary* item = [dict objectForKey:@"shortDocInfo"];
                NSString* enterelId = [item objectForKey:@"id"];
                
                if([eId isEqualToString:enterelId]) {
                    [self addToDownloadArraysWith:[self.docInfoDic objectForKey:@"article"]];
                    break;
                }
            }
            
            [self showMsgBarWithInfo:@"下载等待中，请稍后重试"];
            
            NSString* filePath =[requestInfo objectForKey:@"downloadPath"];
            NSError *error;
            if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
            {
                NSLog(@"del failed %@",error);
            }
            
            return;
        }else{
            NSString* fileName = [requestInfo objectForKey:@"downloadFile"];
            NSString* fileTitle = [requestInfo objectForKey:@"downloadTitle"];
            NSString* filePath = [requestInfo objectForKey:@"downloadPath"];
            
            NSLog(@"fileName %@",fileName);
            NSLog(@"fileTitle %@",fileTitle);
            NSLog(@"filePath %@",filePath);
            
            //for debug white screen
            BOOL pdfFailed =NO;
            
            NSString* response =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
            
            NSLog(@"got response %@",response);
            
            if([response isEqualToString:@"MAXVALUE"])
            {
                isAskFor = false;
                [self checkUserConfirmInfo];
                pdfFailed =YES;
            } else if([response isEqualToString:@"FAIL"]) {
              if ([self.isrecord isEqualToString:@"WAITING"]) {
                [self showMsgBarWithInfo:@"您已提交过获取该文献全文的请求，请耐心等待，谢谢！"];
              }else
                [self showMsgBarWithInfo:@"对不起，您申请的文献全文未找到."];
                pdfFailed =YES;
            } else {
                NSLog(@"res =%@",response);
                pdfFailed = response ? YES : NO;
            }
            
            if(pdfFailed) {
                NSError *error;
                if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                    NSLog(@"del failed %@",error);
                }
            } else {
                NSLog(@"load pdf ok");
                
                int count = [askArr count];
                NSString *eId = [requestInfo objectForKey:@"externalId"];
                
                for(int i = 0; i < count; i++) {
                    NSDictionary *m = [askArr objectAtIndex:i];
                    NSDictionary *item = [m objectForKey:@"shortDocInfo"];
                    
                    if([eId isEqualToString:[item objectForKey:@"id"]])
                    {
                        [self addToDownloadArraysWith:[self.docInfoDic objectForKey:@"article"]];
                        
                        break;
                    }
                }
                
                //本地文献刷新, 用通知
//                [self.downList reloadData];
                
                BOOL fullTextDisplay =[[requestInfo objectForKey:@"fullTextOption"] boolValue];
                
                if(fullTextDisplay)
                {
                    [self hideMsgBar];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(showPDFWithexternalId:fileName:pdfTitle:)]) {
                        [self.delegate showPDFWithexternalId:eId fileName:fileName pdfTitle:fileTitle];
                    }

                }
            }

        }
        
    }else if (request.tag == RequestAskStatus){
      self.downloadDocBtn.enabled = YES;
        if([responseStr isEqualToString:@"SUCCESS"]){
            [self showAskSuccess:requestInfo];
            
        }else if([responseStr isEqualToString:@"MAXVALUE"]){
            [self showMaxValueAlert];
        }else if ([responseStr isEqualToString:@"INACTIVE"]){
            [self showInactiveAlert];
        }else if ([responseStr isEqualToString:@"UNVERIFIED"]){
            [self showUnverifiedAlert];
        }else{
            //error
            [self showMsgBarWithInfo:ASKFOR_DOC_FAILED];
            //[self enabledSwitchButton];
            
        }
        // DZH
    }else if (request.tag == RequestJumpAskStatus){
        if (info) {
            NSArray *arr = [info objectForKey:@"statusList"];
            NSDictionary *dic = [arr objectAtIndex:0];
            NSString *status = [dic objectForKey:@"status"];
            
            if ([status isEqualToString:@"FAIL"]) {
                //跳转到我的文献记录中
                [self showMsgBarWithInfo:@"对不起，您申请的文献全文未找到."];
            }else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(showMyDocumentWithListType:)]) {
                    [self.delegate showMyDocumentWithListType:ListTypeRecord];
                }
            }
        }else{
            [self showMsgBarWithInfo:@"索取状态出错，请稍后重试。"];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"网络出错-­‐请检查网络设置"];
  self.downloadDocBtn.enabled = YES;
    if (request.tag == RequestGetDetailTag) {
        [self.view removeFromSuperview];
    }
}

-(void)addToDownloadArraysWith:(NSDictionary*)result {
    NSString* eId =[result objectForKey:@"externalId"];
    
    NSLog(@"eid %@",eId);
    NSArray *downloadArr = [myDatabaseOption getSavedDoc];
    
    int sum = [downloadArr count];
    BOOL inList = NO;
    
    for(int i = 0; i < sum; i++)
    {
        NSDictionary* m =[downloadArr objectAtIndex:i];
        if([eId isEqualToString:[m objectForKey:@"externalId"]])
        {
            inList =YES;
            break;
        }
        
    }
    
    NSLog(@"inList ok");
    
    if(!inList)
    {
        [myDatabaseOption savedDoc:result];
    }
}

#pragma  mark - UIAlertView show
- (void)showMaxValueAlert{
    [self hideMsgBar];
    [self showAlertViewWithTitle:DOWLOAD_UPPERNUM message:DOWNLOAD_DOC_MAXVALUE_NOTHING tag:TagWIthUpperLimit canceButtonlTitle:SET_KNOW otherButtonTitle:SET_INVITE];

}

- (void)showAskSuccess:(NSDictionary *)requestInfo{
    [self hideMsgBar];
    
//    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
//  if ([Strings phoneNumberJudge:email]) {
//    [self showAlertViewWithTitle:@"请求发送成功" message:@"文献全文将在两个工作日内发送到您的“本地文献”，请注意查看“已索取“" tag:TagWithAskSuccess canceButtonlTitle:@"我知道了" otherButtonTitle:@"立即查看"];
//  } else {

    NSString* externalId =[requestInfo objectForKey:@"askingId"];
    
    self.jumpExternalId = externalId;
    
           NSString *content = @"我们将在两个工作日内通知您全文获取的结果，请注意查看“获取记录”。";
        [self showAlertViewWithTitle:@"请求发送成功" message:content tag:TagWithAskSuccess canceButtonlTitle:@"我知道了" otherButtonTitle:@"立即查看"];
}

- (void)showInactiveAlert{
    [self hideMsgBar];
    [self showAlertViewWithTitle:@"提示信息" message:@"您的帐号尚未激活，暂无法获取文献全文，请先激活手机或邮箱。" tag:TagWithInactive canceButtonlTitle:@"我知道了" otherButtonTitle:@"前去激活"];
}

- (void)showUnverifiedAlert{
    NSString *name = [Util getUsername];
    NSString *isOk = [[NSUserDefaults standardUserDefaults] objectForKey:name];
    [self hideMsgBar];
    if ([isOk isEqualToString:@"0"]) {
        [self showAlertViewWithTitle:@"提示信息" message:@"您的身份尚未通过实名验证，请先收藏文献。验证后即可免费获取全文。"  tag:TagWithUnverify canceButtonlTitle:@"我知道了" otherButtonTitle:@"完善帐号信息"];
    } else if([isOk isEqualToString:@"1"]) {
        [self showAlertViewWithTitle:@"提示信息" message:@"您的身份验证已经提交,我们将在两个工作日内完成验证。身份验证通过后即可免费获取全文。您可先收藏此文献。" tag:TagWithUnverify canceButtonlTitle:@"我知道了" otherButtonTitle:@"重新修改"];
    }
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message tag:(NSInteger)tag canceButtonlTitle:(NSString *)cancel otherButtonTitle:(NSString *)other{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:other, nil];
    alertView.tag = tag;
    
    [alertView show];
}

#pragma mark - UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TagWithAskSuccess && buttonIndex == 1) {
        [self loadRequestStatusWithExternalId:self.jumpExternalId];
    }else if (alertView.tag == TagWithInactive && buttonIndex == 1){
        if (self.delegate && [self.delegate respondsToSelector:@selector(presentViewWithType:)]) {
            [self.delegate presentViewWithType:PresentTypeRegisterSuccessView];
        }
    }else if (alertView.tag == TagWithUnverify&& buttonIndex == 1){
      [self getUserInfo:[ImdUrlPath getUserInfo] delegate:self];
//        if (self.delegate && [self.delegate respondsToSelector:@selector(presentViewWithType:)]) {
//            [self.delegate presentViewWithType:PresentTypeVerifiedView];
//        }
    }else if (alertView.tag == TagWIthUpperLimit && buttonIndex == 1){
        if (self.delegate && [self.delegate respondsToSelector:@selector(presentViewWithType:)]) {
            [self.delegate presentViewWithType:PresentTypeInviteFriendView];
        }
    }else if (alertView.tag == TagWithShowLogin){
        if (self.delegate && [self.delegate respondsToSelector:@selector(presentViewWithType:)]) {
            [self.delegate presentViewWithType:PresentTypeLoginView];
          self.downloadDocBtn.enabled = YES;
        }
    }
}

#pragma mark - add fav press
-(void)searchAddFav:(NSDictionary *)infoDic
{
    if (infoDic == nil) {
        return;
    }
    NSString *eId = [infoDic objectForKey:KEY_DOC_EXTERNALID];
    NSArray* authArray = [infoDic objectForKey:KEY_DOC_AUTHOR];
    NSString *author = [Util arrayToString:authArray sep:SEPARATING];
    NSString *issue = [infoDic objectForKey:KEY_DOC_ISSUE];
    NSString *journal = [infoDic objectForKey:KEY_DOC_JOURNAL];
    NSString *pagination = [infoDic objectForKey:KEY_DOC_PAGINATION];
    NSString *pubDate = [infoDic objectForKey:KEY_DOC_PUB_DATE];
    NSString *title = [infoDic objectForKey:KEY_DOC_TITLE];
    NSString *volume = [infoDic objectForKey:KEY_DOC_VOLUME];
    [myDatabaseOption addFav:eId author:author issue:issue journal:journal pubDate:pubDate title:title volume:volume pagination:pagination];
}

- (void)favDocBtnChangeByisFav:(BOOL)isFav{
    NSString *imageName = isFav ? @"fav_remove" : @"fav_add";
    
    [self.favDocBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)setDownLoadToken:(ASIHTTPRequest *)request{
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    
    //Create a cookie
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:appDelegate.auth.imdToken forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        
        [properties setValue:[NSString stringWithFormat:@".%@",CONFIRM_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/download"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
        NSString *curVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *systemVer =  [[UIDevice currentDevice] systemVersion];
        [request setUserAgent:[NSString stringWithFormat:@"imd-ios-iPad(version:%@,systemversion:%@)",curVer,systemVer]];
    }

}

#pragma mark - PDF is full Test
-(BOOL)loadPDFTest:(NSString*)pdfFileName
{
    NSURL *fileURL;
    NSString *filePath = [searchMainUtils filePathInCache:pdfFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        filePath = [searchMainUtils filePathInDocuments:pdfFileName];
    }
    
    fileURL = [NSURL fileURLWithPath:filePath];
    PDFViewTiled* thePDFView;
    
    @try
    {
        thePDFView = [[PDFViewTiled alloc] initWithURL:fileURL page:1 password:nil frame:[self.view bounds]];
    } @catch(NSException* ex) {
        NSLog(@"Bad pdf");
        NSString* response =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        
        NSLog(@"response from pdf test [%@]",response);
        
        if([response isEqualToString:@"FAIL"]) {
            [self showMsgBarWithInfo:@"对不起，您申请的文献全文未找到."];
        } else if([response isEqualToString:@"MAXVALUE"]) {
            //                [self showToUpperLimitAlert];
        } else {
            [self showMsgBarWithInfo:@"下载未完成，请稍后重试"];
        }
        
        NSError *error;
        if(![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
            NSLog(@"del failed %@",error);
        } else {
            NSLog(@"del ok");
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Display Document detail
- (void)displayDetails:(NSDictionary *)docInfo{
    NSArray *subviews = [self.contentScrollView subviews];
    
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }
    
    NSString *PMID = [docInfo objectForKey:@"PMID"];
    int lanInResult = 0;
    if (PMID == nil || PMID.length == 0) {
        lanInResult = SEARCH_MODE_CN;
    }else{
        lanInResult = SEARCH_MODE_EN;
    }
    
    float yOffset = 10;
    float xOffset = 27;
    
    /**
     *  文献信息显示的颜色
     */
    UIColor *jourTextColor =    RGBCOLOR(212, 73, 48);
    UIColor *lightFullTextColor = RGBCOLOR(0, 0, 0);
    UIColor *titleColor = RGBCOLOR(0, 0, 0);
    UIColor *abstractTextColor = RGBCOLOR(0, 0, 0);
    
    //journal and date
    NSMutableString *s = [[NSMutableString alloc] initWithFormat:@""];
    
    NSString *journal =[docInfo objectForKey:@"journal"];
    [s appendString:[self getStringReplaceNull:journal]];
    
    if(![s isEqualToString:@""]) [s appendString:@" ,"];
    
    NSString *publishDate =[docInfo objectForKey:@"pubDate"];
    [s appendString:[self getStringReplaceNull:publishDate]];
    
    NSString *volume = [docInfo objectForKey:@"volume"];
    [s appendFormat:@";%@",[self getStringReplaceNull:volume]];
    
    NSString* issue = [docInfo objectForKey:@"issue"];
    [s appendFormat:@"(%@)", [self getStringReplaceNull:issue]];
    
    NSString* pagination = [docInfo objectForKey:@"pagination"];
    [s appendFormat:@":%@", [self getStringReplaceNull:pagination]];
    
    NMCustomLabel *journalLabel = [[NMCustomLabel alloc] init];
    journalLabel.text = s;
    journalLabel.font = [UIFont fontWithName:@"Palatino" size:DETAIL_JOURNAL_DEFAULT_SIZE + currentDetailsFontSizeOffset];
    journalLabel.textColor = jourTextColor;
    journalLabel.backgroundColor = [UIColor clearColor];
    journalLabel.lineHeight = DETAIL_JOURNAL_DEFAULT_SIZE + currentDetailsFontSizeOffset + DEFAULT_LINE_SPACE;
    journalLabel.frame = CGRectMake(xOffset, yOffset, 558, 4000);
    [journalLabel sizeToFit];
    
    yOffset = yOffset + journalLabel.frame.size.height + 5;
    [self.contentScrollView addSubview:journalLabel];
    
    //标题上分割线
    UIImageView *detailLine1 = [[UIImageView alloc] init];
    [detailLine1 setImage:[UIImage imageNamed:@"img-abstract-title-seperate-line"]];
    detailLine1.frame = CGRectMake(xOffset, yOffset, 558, 2);
    [self.contentScrollView addSubview:detailLine1];
    
    yOffset =yOffset + detailLine1.frame.size.height + 14;
    
    //title
    NSString *title = [docInfo objectForKey:@"title"];
    title = [self getStringReplaceNull:title];
    
    NMCustomLabel *titleLabel = [[NMCustomLabel alloc] init];
    titleLabel.text = title;
    titleLabel.font =[UIFont fontWithName:@"Palatino-Bold" size:30.0 + currentDetailsFontSizeOffset];
    //  myDetailTitle.kern = 1; // 设成0.8 会造成缺少最后几个字符的情况。
    titleLabel.lineHeight = 30.0 +currentDetailsFontSizeOffset + 2;
    titleLabel.textColor = titleColor;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.frame = CGRectMake(xOffset, yOffset, 558, 4000);
    [titleLabel sizeToFit];
    [self.contentScrollView addSubview:titleLabel];
    
    yOffset = yOffset + titleLabel.frame.size.height + 14;
    
    // 标题下分割线
    UIImageView *detailLine2 = [[UIImageView alloc] init];
    [detailLine2 setImage:[UIImage imageNamed:@"img-abstract-title-seperate-line"]];
    detailLine2.frame = CGRectMake(xOffset, yOffset, 558, 2);
    [self.contentScrollView addSubview:detailLine2];
    
    yOffset = yOffset + detailLine2.frame.size.height + 5;
    
    //authors
    NSArray *authors = [docInfo objectForKey:@"author"];
    NSMutableString *authorString = [[NSMutableString alloc] initWithFormat:@""];
    
    for(int i =0; i<[authors count];i++) {
        if(![authorString isEqualToString:@""])
            [authorString appendString:@" ,"];
        NSString* aStr = [authors objectAtIndex:i];
        aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
        [authorString appendString:aStr];
    }
    
    NMCustomLabel *authorsLabel = [[NMCustomLabel alloc] init];
    authorsLabel.text = authorString;
    authorsLabel.textColor = lightFullTextColor;
    authorsLabel.backgroundColor = [UIColor clearColor];
    authorsLabel.font = [UIFont fontWithName:@"Palatino" size:DETAIL_AUTHORS_DEFAULT_SIZE + currentDetailsFontSizeOffset];
    authorsLabel.frame = CGRectMake(xOffset, yOffset, 558, 4000);
    authorsLabel.lineHeight = DETAIL_AUTHORS_DEFAULT_SIZE + currentDetailsFontSizeOffset + DEFAULT_LINE_SPACE;
    [authorsLabel sizeToFit];
    [self.contentScrollView addSubview:authorsLabel];
    
    yOffset = yOffset + authorsLabel.frame.size.height + 6;
    
    
    //affliation
    NSArray* affiliations =[docInfo objectForKey:@"affiliation"];
    NSMutableString* affiliationString = [[NSMutableString alloc] initWithFormat:@""];
    
    if(affiliations == (id)[NSNull null] || [affiliations count] == 0) {
        
    } else {
        for(int i =0; i<[affiliations count];i++) {
            if(![affiliationString isEqualToString:@""])
                [affiliationString appendString:@" ,"];
            
            NSString* aStr = [affiliations objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            [affiliationString appendString:aStr];
        }
    }
    
    NMCustomLabel *affiliationsLabel = [[NMCustomLabel alloc] init];
    affiliationsLabel.text = affiliationString;
    affiliationsLabel.textColor = lightFullTextColor;
    affiliationsLabel.backgroundColor = [UIColor clearColor];
    affiliationsLabel.font = [UIFont fontWithName:@"Palatino" size:DETAIL_AFFILIATIONS_DEFAULT_SIZE + currentDetailsFontSizeOffset];
    affiliationsLabel.lineHeight = DETAIL_AFFILIATIONS_DEFAULT_SIZE + currentDetailsFontSizeOffset + DEFAULT_LINE_SPACE;
    affiliationsLabel.frame = CGRectMake(xOffset, yOffset, 558, 4000);
    [affiliationsLabel sizeToFit];
    
    [self.contentScrollView addSubview:affiliationsLabel];
    
    yOffset = yOffset + affiliationsLabel.frame.size.height + 40;
    
    NSDictionary* abstractTextDic = [docInfo objectForKey:@"abstractText"];
    NSArray* textArray =[abstractTextDic objectForKey:ABSTRACT_TEXT];
    NSArray* backgroundArray = [abstractTextDic objectForKey:ABSTRACT_BACKGROUND];
    NSArray* objectiveArray = [abstractTextDic objectForKey:ABSTRACT_OBJECTIVE];
    NSArray* mathodsArray = [abstractTextDic objectForKey:ABSTRACT_METHODS];
    NSArray* resultsArray = [abstractTextDic objectForKey:ABSTRACT_RESULTS];
    NSArray* conclusionsArray = [abstractTextDic objectForKey:ABSTRACT_CONCLUSIONS];
    NSArray* copyrightsArray = [abstractTextDic objectForKey:ABSTRACT_COPYRIGHTS];
    NSMutableString* abstractText =[NSMutableString stringWithString:@""];
    
    if (textArray != (id)[NSNull null] && [textArray count] > 0) {
        
        for(int i = 0, sum = [textArray count]; i < sum; i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""]) {
                [abstractText appendString:@" ,"];
            }
            
            NSString* aStr =[textArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (backgroundArray != (id)[NSNull null] && [backgroundArray count] > 0) {
        for(int i =0; i<[backgroundArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString *aStr =[backgroundArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (objectiveArray != (id)[NSNull null] && [objectiveArray count] > 0) {
        for(int i =0; i<[objectiveArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[objectiveArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (mathodsArray != (id)[NSNull null] && [mathodsArray count] > 0) {
        NSLog(@"mathodsArray============ %@",mathodsArray);
        for(int i =0; i<[mathodsArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[mathodsArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (resultsArray != (id)[NSNull null] && [resultsArray count] > 0) {
        NSLog(@"resultsArray============ %@",resultsArray);
        for(int i =0; i<[resultsArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[resultsArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (conclusionsArray != (id)[NSNull null] && [conclusionsArray count] > 0) {
        NSLog(@"conclusionsArray============ %@",conclusionsArray);
        for(int i =0; i<[conclusionsArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[conclusionsArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    if (![abstractText isEqualToString:@""]) {
        [abstractText appendString:@"\n"];
    }
    
    if (copyrightsArray != (id)[NSNull null] && [copyrightsArray count] > 0) {
        NSLog(@"copyrightsArray============ %@",copyrightsArray);
        for(int i =0; i<[copyrightsArray count];i++)
        {
            if(i == 0) {
                [abstractText appendString:@"    "];
            } else if(![abstractText isEqualToString:@""])
                [abstractText appendString:@" ,"];
            
            NSString* aStr =[copyrightsArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [abstractText appendString:aStr];
        }
    }
    
    UIImageView *abstractImgView = [[UIImageView alloc] init];
    UIImage *abstractImg;
    
    if(lanInResult == SEARCH_MODE_CN){
        //      abstractWord =@"摘要";
        abstractImg = [UIImage imageNamed:@"img-tag-abstract-cn"];
    } else {
        //      abstractWord =@"Abstract";
        abstractImg = [UIImage imageNamed:@"img-tag-abstract-en"];
    }
    
    [abstractImgView setImage:abstractImg];
    abstractImgView.frame = CGRectMake(xOffset, yOffset, 74, 21);
    abstractImgView.hidden = NO;
    yOffset = yOffset + abstractImgView.frame.size.height + 5;
    [self.contentScrollView addSubview:abstractImgView];
    
    NMCustomLabel *detailAbstractTextCustom = [[NMCustomLabel alloc] init];
    detailAbstractTextCustom.text = abstractText;
    detailAbstractTextCustom.textColor = abstractTextColor;
    detailAbstractTextCustom.backgroundColor = [UIColor clearColor];
    detailAbstractTextCustom.font =
    [UIFont fontWithName:@"Palatino" size:18.0+currentDetailsFontSizeOffset];
    detailAbstractTextCustom.lineHeight = 18 + currentDetailsFontSizeOffset + 8;
    detailAbstractTextCustom.frame = CGRectMake(xOffset, yOffset, 558, 6000);
    [detailAbstractTextCustom sizeToFit];
    
    yOffset = yOffset + detailAbstractTextCustom.frame.size.height + 40;
    
    [self.contentScrollView addSubview:detailAbstractTextCustom];
    
    //keywords
    NSArray* keywords =[docInfo objectForKey:@"keywords"];
    NSMutableString* keywordsString = [[NSMutableString alloc] initWithFormat:@""];
    
    BOOL hasKeywords = YES;
    
    if(keywords == (id)[NSNull null] || [keywords count] == 0) {
        hasKeywords =NO;
    } else {
        for(int i =0; i<[keywords count];i++)
        {
            if(![keywordsString isEqualToString:@""])
                [keywordsString appendString:@" ,"];
            
            NSString* aStr = [keywords objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            [keywordsString appendString:aStr];
            
        }
    }
    
    UIImageView *keywordImg = [[UIImageView alloc] init];
    UIImage* keyImg;
    if (lanInResult == SEARCH_MODE_CN) {
        keyImg = [UIImage imageNamed:@"img-tag-keywords-cn"];
    } else {
        keyImg = [UIImage imageNamed:@"img-tag-keywords-en"];
    }
    [keywordImg setImage:keyImg];
    keywordImg.frame = CGRectMake(xOffset, yOffset ,74, 21);
    keywordImg.hidden = NO;
    [self.contentScrollView addSubview:keywordImg];
    
    yOffset = yOffset + keywordImg.frame.size.height + 5;
    
    NMCustomLabel *keywordLabel = [[NMCustomLabel alloc] init];
    
    keywordLabel.text = keywordsString;
    keywordLabel.textColor = lightFullTextColor;
    keywordLabel.backgroundColor = [UIColor clearColor];
    keywordLabel.font =[UIFont fontWithName:@"Palatino" size:18.0+currentDetailsFontSizeOffset];
    keywordLabel.lineHeight = 17 + currentDetailsFontSizeOffset + 8;
    keywordLabel.frame = CGRectMake(xOffset, yOffset, 558, 4000);
    [keywordLabel sizeToFit];
    
    yOffset = yOffset + keywordLabel.frame.size.height +40;
    
    [self.contentScrollView addSubview:keywordLabel];
    
    self.contentScrollView.contentSize = CGSizeMake(558, yOffset);
}

@end
