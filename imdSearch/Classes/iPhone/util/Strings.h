//
//  Strings.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-14.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IMD_CN @"睿医网"
#define IMD_DOC @"睿医文献"
#define IMD_WEBSITE @"www.i-md.com"
#define IMD_PNONE @"400-061-9169"


#define REVIEW_APPSTORE @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=492028918&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"

#define URL_IMD_HELP @"http://www.i-md.com/help"
#define URL_APPSTORE @"itms-apps://itunes.apple.com/us/app/rui-yi-wen-xian/id492028918?l=zh&ls=1&mt=8"

#define URL_APPLOOKUP @"http://itunes.apple.com/lookup?id=492028918&country=cn"
#define URL_UPGRADE @"http://api.i-md.com/versioncheck"
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone3GS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] currentMode].size) : NO)
//Account Active
#define ACTIVE_ACCOUNT @"帐号激活"
#define ACTIVE_USERINFO @"身份验证信息"
#define ACTIVE_MOBILE @"激活"
#define ACTIVE_SUCCESS @"现在可以免费下载文献全文"
#define REQUEST_TIMEOUT_MESSAGE @"检索超时，请稍后重试"
#define REQUEST_TIMEOUT_TITLE @"请求超时"

#define ACTIVE_ACCOUNT_LABEL @"您的帐号尚未激活，暂无法免费获取文献全文，请先激活手机或邮箱。激活手机可即时体验3篇文献全文。"
#define ACTIVE_ACCOUNT_MOBLE_LABEL @"手机激活后即完成帐号激活，并可体验全文获取。"
#define ACTIVE_ACCOUNT_EMAIL_LABEL @"激活邮件已发往您的注册邮箱，请及时查收并激活帐号"
#define ACTIVE_ACCOUNT_NO_EMAIL_LABEL @"没有收到验证邮件？"
#define ACTIVE_DOCTOR @"您的“临床医师”身份尚未通过实名验证，暂无法免费获取全文。请如实完善如下信息，并将医师执业证书/工作证/胸牌等证件完整扫描/拍照后发送到 verify@i-md.com。"
#define ACTIVE_STUDENT @"您的“医学院校在校学生”身份尚未通过实名验证，暂无法免费获取全文。请如实完善如下信息，并将学生证等身份证件完整扫描/拍照后发送到 verify@i-md.com。"

#define ACTIVE_MOBILE_LABEL @"激活帐号后即可免费下载全文, 并可保存全文, 方便在没有网络的环境下阅读全文"
#define ACTIVE_EMAIL_LABEL @"激活帐号后即可免费下载全文, 并可保存全文, 方便在没有网络的环境下阅读全文"
#define ACTIVE_MOBIlE_TITLE @"手机激活"
#define ACTIVE_FAST_MOBIlE_TITLE @"手机激活"
#define ACTIVE_USE_MOBIlE_ACTIVED @"你的手机已验证"
#define ACTIVE_ACTIVED @"已验证"
#define ACTIVE_GET_CODE @"获取验证码"
#define ACTIVE_SUBMIT_CODE @"激活帐号"
#define ACTIVE_MOBILE_CODE_TIMER 360
#define ACTIVE_CODE_EXPIRED @"验证码失效, 请重新获取"
#define ACTIVE_CODE_SUCCESS @"手机验证成功"
#define ACTIVE_EMAIL @"验证邮件"
#define ACTIVE_RESEND_EMAIL @"重发激活邮件"
#define ACTIVE_EMAIL_TITLE @"邮箱激活"
#define SELECT_USER_TYPE @"请选择您的身份类型"
//END


#define USERTYPE_DOCTOR @"Doctor"
#define USERTYPE_STUDENT @"Student"

#define DOCSEARCH_CN @"文献检索"
#define MYFAVORITE_CN @"我的收藏"
#define SEARCHMGR_CN @"本地文献"
#define SETTINGS_CN @"设置"
#define SEARCH_TEXT_CN @"  检索"
#define SEARCH_RESULTS_CN @"检索结果"

#define SEARCH_SORT @"排序"
#define SEARCH_SORT_DEFAULT @"相关排序"
#define SEARCH_SORT_DATE @"时间排序"
#define SEARCH_SORT_JOURNALS @"期刊排序"

#define SELECT_XUESHI @"学士"
#define SELECT_SHUOSHI @"硕士"
#define SELECT_BOSHI @"博士"

#define FILTER_RESULTS_CN @"筛选"
#define BACK_CN @"  返回"
#define EDIT_CN @"编辑"
#define EDIT_DONE_CN @"完成"

#define AUTHOR_CN @"作者: "

#define SAVED_USER @"savedUser"
#define GUEST_USER @"guest"
#define APP_VERSION @"appVersion"

#define TEXT_CANCEL @"取消"
#define TEXT_CONFIRM @"确定"
#define TEXT_HELP @"邮箱激活"

//Login process
#define LOGIN_TITLE  @"帐号登录"
#define LOGIN_CANCEL @"取消"
#define LOGIN_SUBMIT @"登录"
#define LOGIN_SELECT_USERTYPE @"请先选择您的身份"
#define LOGIN_NEWUSER @"新用户注册"
#define LOGIN_NEXTSTEP @"下一步"
#define LOGIN_BACKSTEP @"上一步"
#define LOGIN_PERSONALINFO @"个人信息"
#define LOGIN_REGISTER @"注册"

//Logout
#define LOGOUT_MESSAGE @"退出帐户后, 相关数据将被清除"
#define LOGOUT_CANCEL @"放弃"
#define LOGOUT_CONFIRM @"退出登录"
#define LOGOUT_WARN @"退出后不会删除任何历史数据，下次登录该帐号后数据依然存在"
//Register process
#define REGISTER_TITLE @"注册"
#define REGISTER_MESSAGE @"注册"
#define REGISTER_SUCCESS_MESSAGE @"恭喜您成功注册睿医,请查看邮箱激活"

#define REGISTER_CANCEL ALERT_CONFIRM
#define REGISTER_SUCCESS @"注册成功"
#define REGISTER_FAIL @"注册失败"
#define REGISTER_EMAIL_UNAVAILABLE @"Email地址不可用"
#define REGISTER_RET_CODE @"success"
#define REGISTER_RET_MSG RETINFO_MESSAGE


#define RETINFO_STATUS @"status"
#define RETINFO_MESSAGE @"message"
#define RETINFO_STATUS_WAIT @"WAITING"
#define RETINFO_STATUS_SUCC @"SUCCESS"

#define USERLOGININFO   @"userLoginInfo"

#define REGISTER_INFO_USERNAME @"username"
#define REGISTER_INFO_PASSWORD @"password"
#define REGISTER_INFO_REALNAME @"realname"
#define REGISTER_INFO_DEPARTMENT @"department"
#define REGISTER_INFO_TITLE @"title"
#define REGISTER_INFO_HOSPITAL @"hospital"
#define REGISTER_INFO_USERTYPE @"userType"
#define REGISTER_INFO @"userInfo"
#define REGISTER_SOURCE @"source"
#define REGISTER_INFO_EMAIL @"email"
#define REGISTER_INFO_MOBILE @"mobile"
#define REGISTER_INFO_DISPLAYNAME @"displayName"
#define REGISTER_INFO_DoctorInfo @"doctorInfo"
#define REGISTER_INFO_LicenseId @"licenseId"

#define REGISTER_INFO_Title @"title"
#define REGISTER_INFO_HospitalRef @"hospital"
#define REGISTER_INFO_hospitalId @"hospitalId"
#define REGISTER_INFO_hospitalDataType @"hospitalDataType"
#define REGISTER_INFO_studentInfo @"studentInfo"
#define REGISTER_INFO_teacher @"teacher"
#define REGISTER_INFO_UserVerifyInfo @"userVerifyInfo"
#define REGISTER_INFO_emailVerified @"emailVerified"
#define REGISTER_INFO_mobileVerified @"mobileVerified"
#define REGISTER_INFO_licenseIdVerified @"licenseIdVerified"
#define REGISTER_INFO_basicInfoVerified @"basicInfoVerified"

#define REGISTER_INFO_SCHOOL @"school"
#define REGISTER_INFO_ADMISSIONYEAR @"admissionYear"
#define REGISTER_INFO_MAJOR @"major"
#define REGISTER_INFO_DEGREE @"degree"
#define REGISTER_INFO_STUDENTID @"studentId"
#define REGISTER_INFO_GRADYEAR @"graduationYear"

#define REGISTER_USERTYPE_DOCTOR @"Doctor"
#define REGISTER_USERTYPE_STUDENT @"Student"

#define REGISTER_EMAIL_FORMAT @"请输入正确的手机号或者Email"
#define REGISTER_PWD_LENGTH @"请确保密码长度在6~40个字符之间"

#define REGISTER_START_USE @"暂不激活"

#define DEPARTMENT_CN  @"cnDepartment"
#define DEPARTMENT_EN  @"enDepartment"
#define DEPARTMENT_KEY  @"key"
#define DEPARTMENT_SELECT @"选择科室"
#define TITLE_SELECT @"选择职称"

#define ALERT_CONFIRM @"确认"

#define DELETE_TEXT @"删除"
#define HINT_TEXT @"睿医提示"
#define CONFIRM_TEXT @"确认"

//Favorites

#define FAVORITES_DOC @"文献收藏"
#define FAVORITES_SUCCESS @"已添加到收藏夹"
#define FAVORITES_FAILED @"收藏失败"
#define FAVORITES_REMOVED @"已取消收藏"
#define REMOVE_FAVORITES @"取消收藏"
#define RET_TRUE @"true"
#define FULLPATH @"localPdfPath"
//Login alert
#define LOGIN_ALERT_TITLE  @"登录失败"
#define LOGIN_ALERT_MESSAGE @"请尝试重新登录"
#define LOGIN_ALERT_CANCEL ALERT_CONFIRM

#define REQUEST_FAILED_TITLE  @"网络出错"
#define REQUEST_FAILED_MESSAGE @"请检查网络设置"
#define REQUEST_FAILED_CANCEL ALERT_CONFIRM
#define SET_SET @"设置"
#define SET_KNOW @"知道了"
#define SET_INVITE  @"马上邀请"

//Upgata
#define UP_TITLE @"版本更新提示"
#define UP_MESSAGE @"您现在使用的睿医文献版本过低，为了获得更好的产品体验，建议您更新版本。"

#define REQUEST_DOC @"请求发送成功"
#define REQUEST_DOC_SUCCESS_TITLE @"请求发送成功"
#define REQUEST_FREE_DOC @"全文免费索取"
//#define REQUEST_DOC_SUCCESS @"请求发送成功, 文献将在两个工作日内发到您的注册邮箱,请注意查收"

#define REQUEST_DOC_SUCCESS @"我们将在两个工作日内通知您全文获取的结果，请注意查看“获取记录”。"
//#define REQUEST_DOC_SUCCESSED(email) @"请求发送成功, 文献将在两个工作日内发到您的注册邮箱"#email@",请注意查收"
#define IKNOW_TEXT @"我知道了"
#define CHECKNOW_TEXT @"立即查看"


#define REQUEST_DOC_DID @"我们将在两个工作日内告知全文获取的结果，请注意查看“获取记录”。"
#define REQUEST_DOC_DID_AGAIN @"您已提交过获取该文献全文的请求，请耐心等待，谢谢！"
#define REQUEST_DOC_ISREQUESTING @"您的文献正在索取中"
#define REQUEST_DOC_FAILED @"对不起，您申请的文献全文未找到。"
#define REQUEST_DOC_MAXVALUE @"您已经达到今天最大索取篇数"
#define REQUEST_DOC_CONFIRM @"确定"

#define DOWNLOAD_DOC @"文献下载"
#define DOWLOAD_UPPERNUM @"全文获取超限"
#define DOWNLOAD_FREE_DOC @"全文免费下载"
#define DOWNLOAD_DOC_SUCCESS @"文献下载成功, 显示就是bug"
#define DOWNLOAD_DOC_FAILEDS @"对不起，您申请的文献全文未找到。"
#define DOWNLOAD_DOC_MAXVALUE @"您已达到每日全文获取上限，请改日再来！邀请好友注册睿医，可提高全文获取额度哦。"
#define DOWNLOAD_DOC_QUEUE @"文献准备中，请稍候重试"
#define DOWNLOAD_DOC_CONFIRM @"确定"
#define MAXNUMBERTAG 2014011301

#define DOWNLOAD_WIFI_ONLY @"您设置了只在wifi网络环境下载全文，您可进入「设置」页面，开启3G/2G模式下载全文"

//PDF Load Error
#define LOAD_PDF_FAILED_TITLE @"服务暂时不可用"
#define LOAD_PDF_FAILED_MESSAGE @"请稍后再试。"
#define LOAD_PDF_FAILED_CANCEL @"确定"
#define LOAD_SAVE_LOCAL @"保存到本地"
#define LOAD_LOCAL_SAVED @"已保存在本地"
#define LOAD_SAVE_SUCCESS @"保存成功!"



#define SEARCH_MODE_C @"cn"
#define SEARCH_MODE_E @"en"

#define SEARCH_QUERY_CN_TEXT @"中文"
#define SEARCH_QUERY_EN_TEXT @"英文"

#define SEARCH_MODE_CN_TEXT @"中文文献"
#define SEARCH_MODE_EN_TEXT @"英文文献"

#define DOC_ARTICLE_TEXT @"文献详情"
//data structure document.thrift
#define DOC_TITLE @"title"
#define DOC_ABSTRCTTEXT @"abstractText"

#define ABSTRACT_TEXT @"text"
#define ABSTRACT_BACKGROUND @"background"
#define ABSTRACT_OBJECTIVE @"objective"
#define ABSTRACT_METHODS @"methods"
#define ABSTRACT_RESULTS @"results"
#define ABSTRACT_CONCLUSIONS @"conclusions"
#define ABSTRACT_COPYRIGHTS @"copyrights"

#define DOC_KEYWORDS @"keywords"
#define DOC_JOURNAL @"journal"
#define DOC_VOLUME @"volume"
#define DOC_ISSUE @"issue"
#define DOC_PUBDATE @"pubDate"
#define DOC_AUTHOR @"author"
#define DOC_AFFILIATION @"affiliation"
#define DOC_GRANT @"grant"
#define DOC_ISSN @"ISSN"
#define DOC_PAGINATION @"pagination"

#define DOC_REFERENCECOUNT @"referenceCount"
#define DOC_REFERENCE @"reference"

#define DOC_PMID @"PMID"
#define DOC_WFID @"WFID"
#define DOC_WPID @"WPID"
#define DOC_CKID @"CKID"
#define DOC_PMCID @"PMCID"
#define DOC_DOI @"DOI"

#define DOC_EXTERNALID @"externalId"
#define DOC_ID @"id"  //TODO:(wuhuajie) replace by externalId

//data structure in search.thrift
#define DOC_RESULT_LIST @"results"
#define DOC_RESULT_COUNT @"resultCount"

#define DOC_READ_SIGN @"readSign"
#define DOC_READED @"YES"

//article_operation.thrifs
#define ARTICLE_FAVS @"favs"
#define ARTICLE_USERID @"userid"
#define ARTICLE_EXTERNALID DOC_EXTERNALID
#define ARTICLE_TITLE DOC_TITLE

//article with user op
#define ARTICLE_USER_OP @"article"
#define ARTICLE_USER_ISFAV @"isFav"
#define ARTICLE_USER_ISLOGIN @"isLogin"
#define ARTICLE_USER_EMAILACTIVE @"emailActive"
#define ARTICLE_USER_MOBILEACTIVE @"mobileActive"
#define ARTICLE_USER_DOWNLOADSTATUS @"downloadStatus"
#define ARTICLE_USER_FETCHSTATUS @"fetchStatus"

//Article keyword.
#define ARTICLE_ABSTRACT_CN @" 文献摘要"
#define ARTICLE_KEYWORD_CN @" 关键词"
#define ARTICLE_ABSTRACT @" Abstract"
#define ARTICLE_KEYWORD @" Keyword"



#define USERAGENT @"IPhone"

//User-Agent
#define IOS_USER_AGENT @"imd-ios-iphone(version:%@,systemversion:%@)"
#define IOS_USER_AGENT_IPAD @"imd-ios-iPad(version:%@,systemversion:%@)"

//FullText fetch info
#define LOCAL_PDF_PATH @"localPdfPath"
#define LOCAL_RESULT @"result"

#define FULLTEXT_DOWNLOAD_LIST @"fulltextDownloadList"

#define FULLTEXT_REQUEST_LIST @"fulltextRequestList"

#define QUERY_HISTORY_LIST @"queryHistoryList"
#define QUERY_HISTORY_STRING @"queryStr"
#define QUERY_HISTORY_SOURCE @"querySrc"
#define CLEAR_HISTORY_TEXT @"清除检索历史 ..."

//Request AJAX
#define REQUEST_TYPE @"requestType"
#define REQUEST_TYPE_DO_FAV @"doFav"
#define REQUEST_TYPE_REMOVE_FAV @"removeFav"
#define REQUEST_TYPE_DOWNLOADDOC @"downloadDoc"
#define REQUEST_TYPE_REQUESTDOC @"requestDoc"
#define REQUEST_TYPE_USER @"userActive"
#define REQUEST_TYPE_STATUS @"statusList"
//Settings
#define SETTINGS_ABOUTUS @"关于我们"
#define SETTINGS_ABOUTUS_TEXT @"上海睿医信息科技有限公司创立于2011年，致力于综合运用互联网以及移动互联网领域的创新科技搭建专业医生的服务平台， 为医生提供专业的、即时的以及个性化的医学信息服务。i-MD医生专业服务平台服务的主要对象是中国执业医师， 并兼顾未取得执业证书的住院医师及医学院校在读学生。目前，平台正在进行开发的产品和服务包括：\n\n <orange>    1. 文献服务：</orange>\n    平台通过整合国内外主要医学文献数据库，免费向各位医师开放在线阅读和下载服务，也为部分医师提供代检代查服务。\n\n <orange>    2. 一对一/多对多在线视频互动学术会议服务：</orange>\n    包括医药学术会议、产品说明会、学术研讨会/讨论会等，实现异地实时一对多、多对多多媒体互动会议。\n\n<orange>    3. 专业资讯：</orange>\n    包括医药行业动态及卫生政策信息、国内外医学科研进展和临床动态、药品信息，诊疗指南、临床病例等。\n\n未来公司将不断完善平台，开发更多先进的电子医学信息系统，包括医学培训系统，在线医疗援助中心，以及医师法律援助中心等，对中国的医疗体系的电子信息化做出贡献。"


#define SETTINGS_AGREEMENT @"免责声明"
#define SETTINGS_AGREEMENT_TEXT @"    欢迎使用上海睿医信息科技有限公司文献APP（以下简称睿医文献APP）！在使用之前请切记以下内容：\n\n    <orange>1.</orange> 凡以任何方式使用睿医文献APP内容者，均视为自愿接受本声明的约束。\n\n     <orange>2.</orange>睿医文献APP提供的原文、复制件仅用于个人学习、研究的目的，不能用于任何营利目的。如果超出以上范围，用户要为发生的版权侵权行为负责。一经发现用户的请求超出著作权法规定的范围，睿医文献APP保留拒绝接受该请求或取消该用户请求的权利。\n\n     <orange>3.</orange>睿医文献APP知识库中的所有信息均来源于国内外公开、可信及可靠的文献资料，睿医文献APP及其内容提供商都深知自己的责任，在收集和编排上述信息时都力求完整、准确并不断更新。信息使用的主要目的是帮助广大用户以最便捷的方式学习或查询相关的知识或数据，辅助而不是替代临床诊疗。所以必须声明，鉴于医药科学日新月异及临床实践的复杂性，本知识库系统并不能担保所提供的信息都是最新或唯一正确的，也不能担保这些信息能够覆盖或适用于所有领域，用户在使用这些信息时必须运用自己的判断。\n\n     <orange>4.</orange>睿医文献APP的内容是基于循证证据或人工的工具，所提供的服务或建议仅供临床参考，不可直接作为临床诊断或制定治疗措施依据，最终的治疗决策需结合临床实际。对于任何因使用本产品信息所导致的医疗差错或医疗纠纷，睿医文献APP及其内容提供商都不承担责任。\n\n     <orange>5.</orange>睿医文献APP中的很多内容，如医药文献、病例、医学视频、诊疗指南等这些内容不代表睿医文献APP的观点或立场，睿医文献APP会尽力维护内容的健康、科学和公正性，但并不对这些承担最终责任。\n\n     <orange>6．</orange>如果希望在睿医文献APP平台的互动社区署名发帖或跟帖，这些都需要用户注册独立的帐户，帐户中会包含一些必要的个人信息，睿医文献APP平台所有者及工作人员将严格执行有关用户信息的保护制度，保护用户信息仅限上述范围内使用。"

#define SETTINGS_INVITE_REGISTER @"邀请好友注册，提高全文权限"
#define SETTINGS_DOWNLOAD_WIFI @"仅在Wi-Fi网络下载全文"
#define SETTINGS_OPEN_NOTIFICATION @"开启文献索取通知"
#define SETTINGS_CLEAR_CACHE @"清空缓存"
#define SETTINGS_CLEAR_CACHE_MESSAGE @"请确认是否要清空缓存"

#define SETTINGS_INVITE_COMMON @"向你推荐专业医学文献服务：睿医文献，检索及全文下载都免费哦。它不但全面覆盖常用中英文医学文献数据库，还提供WEB、IOS/Android、微信等不同版本、实现多平台文献数据实时同步，让你随时随地畅享免费文献大餐，快试试吧！"
#define SETTINGS_INVITE_SMS @"向你推荐专业医学文献服务：睿医文献，中英文文献检索及全文下载都免费，还实时同步电脑、手机、微信的文献数据，快试试吧！"
#define SETTINGS_INVITE_TIMELINES   @"睿医文献，中英文文献检索及全文下载都免费，实时同步电脑、手机、微信的文献数据。"

//Feebback
#define FEEDBACK_CONTENT @"content"
#define FEEDBACK_CONTACT @"emailOrPhone"
#define FEEDBACK_USERAGENT @"userAgent"

#define FEEDBACK_SUBMIT_MESSAGE @"非常感谢您对睿医文献的理解和支持！"

#define SETTINGS_FEEDBACK @"反馈建议成功提交"
#define SETTINGS_RATING @"去App Store评个分"
#define FEEDBACK_PLACEHOLDER @"您的反馈意见将有助于我们优化睿医文献搜索服务"

#define FEEDBACK_EMAILORPHONE @"emailOrPhone"
#define FEEDBACK_USERAGENT @"userAgent"
#define FEEDBACK_CONTENT @"content"
#define FEEDBACK_POST @"提交"

#define SETTINGS_VERSION @"睿医文献已经是最新版本-V"
#define SETTINGS_VERSION_NEW @"点击下载最新版本-V"

#define SETTINGS_CALL_TEXT @"点击拨打客服电话反馈意见"
#define SETTINGS_CALL_CALL @"拨打电话"
#define SETTINGS_CALL_CANCEL @"取消"
#define SETTINGS_CALL_TITLE @"拨打客服热线"


//Ask for list
#define ASKFOR_COUNT @"count"
#define ASKFOR_DEMAND @"askforList"
#define ASKFORED_DOC @"已索取到文献"
#define SAVED_LOCAL_DOC @"已保存的文献"
#define ASKFOR_SHORTDOCINFO @"shortDocInfo"


//sql list
#define Create_MySearchTable @"CREATE TABLE IF NOT EXISTS MySearchTable (id integer primary key AUTOINCREMENT, author text,externalId text,issue text,journal text,pagination text, pubDate text,title text,userid text,ismgr text,volume text);"
#define Create_DetailTable @"CREATE TABLE IF NOT EXISTS DocTable (id integer primary key AUTOINCREMENT, CKID text,WFID text,WPID text,PMID text,text text,affiliation text,author text,category text,citation text,coreJournal text,externalId text, iid text,issue text,journal text,keywords text,machineCategory text,numCited text,pagination text,pubDate text,reference text,referenceCount text,title text,volume text, ismgr text,filePath text);"
#define Create_SearchHistory @"CREATE TABLE IF NOT EXISTS MyHistorTable (id integer primary key AUTOINCREMENT, searchresult text,kind text,userid text);"
//数据库中ismgr 当为1时表示 我的收藏的文献 2 索取中文献 3表示 已索取文献
#define IMD_Mydoc @"1"
#define IMD_Mywaitting @"2"
#define IMD_Myorder @"3"
//本地文献valuechange里 选择时 1表示已保存 2表示索取中 3表示 已索取
#define Select_Save @"1"
#define Select_Wait @"2"
#define Select_Own @"3"
//通知
#define Alert_Alert @"alert"
#define Alert_Badge @"badge"
#define Alert_Sound @"sound"
#define Alert_ID @"id"
#define Alert_Aps @"aps"
#define Alert_Action @"action-loc-key"
#define Alert_Body @"body"
#define Alert_Count @"BadgeCount"
#define Array_ID @"array"
@interface Strings : NSObject
//Request 是否更新detail
#define isUpdata @"IsUpdata"
#define Select_Updata @"Select_Updata"
#define Select_notUpdata @"Select_Not"
#define Ture YES
#define False NO
+(NSString*) getResultNoText:(NSInteger) number;

+(NSString*) arrayToString:(NSArray*) array;

+(NSString*) getJournal:(NSString*) journal pubDate:(NSString*) pubDate volume:(NSString*) volume  issue:(NSString*) issue pagination:(NSString*) pagination;

+(BOOL) validEmail:(NSString*) emailString;
+(BOOL)phoneNumberJudge:(NSString*)number;

+(NSMutableArray*) Departments;

+(NSString *)dissolutionDevToken:(NSData *)data;
+ (BOOL)judgeStringAsc:(NSString *)str;
+(NSMutableDictionary *)getUserInfo:(NSMutableDictionary*)dic;
+ (NSString *)getPosition:(NSString *)str;
+ (NSString *)getDepartmentString:(NSString *)str;
+(NSString *)getDegree:(NSString *)str;
+ (NSString *)getPositionEN:(NSString *)str;
+(NSString *)getDegreeEN:(NSString *)str;

+ (NSString *)getIdentity:(NSString *)str;
+ (NSString *)getIdentityEncode:(NSString *)str;
@end
