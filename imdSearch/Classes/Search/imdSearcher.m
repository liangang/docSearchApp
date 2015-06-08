//
//  imdSearcher.m
//  imdSearch
//
//  Created by 8fox on 10/9/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "imdSearcher.h"
#import "Util.h"
#import "ASIHTTPRequest.h"
#import "url.h"
#import "JSON.h"
#import "ImdAppBehavior.h"
#import "imdSearchAppDelegate.h"

@implementation imdSearcher


+(ASIHTTPRequest*)simpleSearch:(NSString*)searchString Page:(int)pNo Lan:(int)LanMode Delegate:(id)d sort:(int)sortWay
{
    //if(isLoading)return;
    
    NSString* lanStr = (LanMode == SEARCH_MODE_CN ? @"cn" : @"en");
    NSString* searchStr = [Util URLencode:searchString stringEncoding:NSUTF8StringEncoding];
    NSString* appURL = [imdSearcher getSimpleSearchURLwithQueryString:searchStr Language:lanStr pageNo:pNo pageSize:20 sortWay:sortWay];
    
    NSLog(@"appurl simpleSearch = %@",appURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:appURL]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:YES];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:searchString forKey:@"searchWord"];
    [userInfo setObject:lanStr forKey:@"searchMode"];
    [userInfo setObject:@"simple" forKey:@"searchType"];
    [userInfo setObject:@"search" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.delegate = d;
    [request startAsynchronous];
    
    return request;
}

+(ASIHTTPRequest*)advacedSearch:(NSString*)startField QueryItems:(NSString *)items Option:(NSString *)optionList Page:(int)page Lan:(int)LanMode minYear:(NSString *)miny maxYear:(NSString *)maxy sort:(NSString *)sort sci:(BOOL)isSci reviews:(BOOL)isReviews Delegate:(id)d
{
    //if(isLoading)return;
    
    NSString* lanStr = (LanMode == SEARCH_MODE_CN ? @"cn" : @"en");
    
    NSLog(@"advanced search url =%@",[imdSearcher getSearcherURL:LanMode]);
    
    NSString* searchSource =[imdSearcher getSearcherSource:LanMode];
    NSLog(@"advanced search source =%@",searchSource);
    
    NSString* searchWords =[imdSearcher getSearcherWord:startField Language:LanMode QueryItems:items];
    NSLog(@"advanced search word =%@",searchWords);
    
    NSString* searchOption = [imdSearcher getSearcherOptionWithPageSize:20 PageNumber:page List:optionList minYear:miny maxYear:maxy sort:sort sci:isSci reviews:isReviews];
    NSLog(@"advanced search option =%@",searchOption);
    
    NSString* searchJson = [imdSearcher getSearcherRequestStringWithWord:searchWords Option:searchOption searchSource:searchSource simpleFlag:@"false"];
    
    
    //for debug
    //searchJson =@"{\"searchWord\":{\"advancedQueryItems\":[{\"op\":\"AND\",\"queryItem\":{\"query\":\"heart\",\"field\":\"TITLE\"}}],\"startingField\":{\"field\":\"KEYWORD\",\"query\":\"heart\"}},\"searchOption\":{\"optionList\":[{\"field\":\"hxk\",\"query\":\"N\"}],\"sort\":\"5\",\"minYear\":\"\",\"maxYear\":\"\",\"pageSize\":20,\"pageNumber\":1,\"coreJournal\":true},\"searchSource\":\"cn\",\"isSimpleQuery\":false}";
    
    
    NSLog(@"advanced search json =%@",searchJson);
    
    //NSString* appURL = [searcher getSearcherURL:searchMode];
    
    NSString* appURL = [imdSearcher getAdvancedSearchURL];
    
    NSLog(@"adv url %@",appURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:appURL]];
    [request appendPostData:[searchJson dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:YES];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"search" forKey:@"requestType"];
    [userInfo setObject:@"" forKey:@"searchWord"];
    [userInfo setObject:startField forKey:@"startField"];
    [userInfo setObject:@"advanced" forKey:@"searchType"];
    [userInfo setObject:lanStr forKey:@"searchMode"];
    [request setUserInfo:userInfo];
    
    request.delegate = d;
    NSLog(@"adv 0");
    //isAdvancedSearching = YES;
    
    [request startAsynchronous];
    
    return request;
}

+(ASIHTTPRequest*)advacedSearch:(NSString*)startField QueryItems:(NSString*)items Option:(NSString*)optionList Page:(int)page Lan:(int)LanMode minYear:(NSString*)miny maxYear:(NSString*)maxy sort:(NSString*)sort coreJournal:(BOOL)isCoreJournal Delegate:(id)d
{
    //if(isLoading)return;
    
    NSString* lanStr = (LanMode == SEARCH_MODE_CN ? @"cn" : @"en");
    
    NSLog(@"advanced search url =%@",[imdSearcher getSearcherURL:LanMode]);
    
    NSString* searchSource =[imdSearcher getSearcherSource:LanMode];
    NSLog(@"advanced search source =%@",searchSource);
    
    NSString* searchWords =[imdSearcher getSearcherWord:startField Language:LanMode QueryItems:items];
    NSLog(@"advanced search word =%@",searchWords);
    
    NSString* searchOption = [imdSearcher getSearcherOptionWithPageSize:20 PageNumber:page List:optionList minYear:miny maxYear:maxy sort:sort coreJournal:isCoreJournal];
    NSLog(@"advanced search option =%@",searchOption);
    
    NSString* searchJson = [imdSearcher getSearcherRequestStringWithWord:searchWords Option:searchOption searchSource:searchSource simpleFlag:@"false"];
    
    
    //for debug
    //searchJson =@"{\"searchWord\":{\"advancedQueryItems\":[{\"op\":\"AND\",\"queryItem\":{\"query\":\"heart\",\"field\":\"TITLE\"}}],\"startingField\":{\"field\":\"KEYWORD\",\"query\":\"heart\"}},\"searchOption\":{\"optionList\":[{\"field\":\"hxk\",\"query\":\"N\"}],\"sort\":\"5\",\"minYear\":\"\",\"maxYear\":\"\",\"pageSize\":20,\"pageNumber\":1,\"coreJournal\":true},\"searchSource\":\"cn\",\"isSimpleQuery\":false}";
    
    
    NSLog(@"advanced search json =%@",searchJson);
    
    //NSString* appURL = [searcher getSearcherURL:searchMode];
    
    NSString* appURL = [imdSearcher getAdvancedSearchURL];
    
    NSLog(@"adv url %@",appURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:appURL]];
    [request appendPostData:[searchJson dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:YES];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"search" forKey:@"requestType"];
    [userInfo setObject:@"" forKey:@"searchWord"];
    [userInfo setObject:startField forKey:@"startField"];
    [userInfo setObject:@"advanced" forKey:@"searchType"];
    [userInfo setObject:lanStr forKey:@"searchMode"];
    [request setUserInfo:userInfo];
    
    request.delegate = d;
    NSLog(@"adv 0");
    //isAdvancedSearching = YES;
    
    [request startAsynchronous];
    
    return request;
    
}

+(NSString*)getSimpleSearchURLwithQueryString:(NSString*)str Language:(NSString*)lan pageNo:(int)pageNo pageSize:(int)pageSize sortWay:(int)sortWay
{
    NSString* s = [NSString stringWithFormat:@"http://%@/docsearch/s/?q=%@&src=%@&pn=%d&ps=%d&sort=%d",SEARCH_SERVER,str,lan,pageNo,pageSize,sortWay];
    return s;
    
}


+(ASIHTTPRequest*)fetchSuggestion:(NSString*)word lan:(int)LanMode Delegate:(id)d
{
    if(word == nil || [word isEqualToString:@""])return nil;
    
    word =[Util URLencode:word stringEncoding:NSUTF8StringEncoding];
    
    if(word == nil || [word isEqualToString:@""])return nil;
    
    NSLog(@"word =%@",word);
    
    NSString* lan =((LanMode == SEARCH_MODE_CN)?@"cn":@"en");
    
    
    NSString* appURL = [NSString stringWithFormat:@"http://%@/docsearch/suggest/?q=%@&src=%@&max_matches=%d&use_similar=%d",SEARCH_SERVER,word,lan,SUGGESTION_MAX,0];
    
    NSLog(@"appurl =%@",appURL);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:appURL]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* token = [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];*/
    
    //Create a cookie
    if (token != nil) {
        NSDictionary *properties = [[NSMutableDictionary alloc] init];
        [properties setValue:token forKey:NSHTTPCookieValue];
        [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
        [properties setValue:[NSString stringWithFormat:@".%@",SEARCH_SERVER]forKey:NSHTTPCookieDomain];
        
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        NSString* pathString = [NSString stringWithFormat:@"/docsearch/"];
        [properties setValue:pathString forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        
        [request setUseCookiePersistence:YES];
        [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    }
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:word forKey:@"suggestionWord"];
    [userInfo setObject:@"suggestion" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.timeOutSeconds = 60*10;
    request.delegate = d;
    [request startAsynchronous];
    
    //[cookie release];
    //[properties release];
    return request;
    
}

+(NSString*)getSearcherStartFieldItem:(NSString*)value Filter:(NSString*)filter
{
    
    NSMutableDictionary* dic =[[NSMutableDictionary alloc] initWithCapacity:5];
    
    [dic setObject:filter forKey:@"field"];
    [dic setObject:value forKey:@"query"];
    
    
    return [dic JSONRepresentation];
}

+(NSString*)getSearcherQueryItem:(NSString*)value Filter:(NSString*)filter Operation:(NSString*)op
{
    if([value isEqualToString:@""])return @"";
    //{"op":"Or","queryItem":{"query":"rrrr","field":"TI"}},
    
    NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
    [s appendString:@"{\"op\":\""];
    [s appendString:op];
    [s appendString:@"\",\"queryItem\":{\"query\":\""];
    [s appendString:value];
    [s appendString:@"\",\"field\":\""];
    [s appendString:filter];
    [s appendString:@"\"}}" ];
    
    return s;
    
}

+(NSString*)getSearcherURL:(int)Language
{
    // OLD Interface DO NOT USE. (zhding) 28-08-2012
    if(SEARCH_MODE_CN == Language)
    {
        return [[NSString alloc] initWithFormat:@"http://%@/docSearch/doSearch",SEARCH_SERVER];
    }
    else
    {
        return [[NSString alloc] initWithFormat:@"http://%@/docSearch/doSearchEnglish",SEARCH_SERVER];
    }
    
}

+(NSString*)getSearcherSource:(int)Language
{
    if(SEARCH_MODE_CN == Language)
    {
        return  @"cn";//@"CMCC";
    }
    else
    {
        return  @"en";//@"PUBMED";
    }
}


+(NSString*)getSearcherWord:(NSString*)startField Language:(int)language QueryItems:(NSString*) QueryItems
{
    /*NSString* textField;
     if (SEARCH_MODE_EN == language) {
     textField =@"TITLE";//@"All Fields";
     }
     else
     {
     textField =@"TITLE";//@"DCS";
     
     }*/
    
    
    NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
    NSString* advancedQueryItemsJson =[NSString stringWithFormat:@"\"advancedQueryItems\":[%@]",QueryItems];
    
    
    //NSString* querItemJson =[NSString stringWithFormat:@"{\"field\":\"%@\",\"query\":\"%@\"}",textField,word];
    
    [s appendString:@"\"searchWord\":{"];
    [s appendString:advancedQueryItemsJson];
    [s appendString:@",\"startingField\":"];
    [s appendString:startField];
    [s appendString:@"}"];
    
    return s;
    
}

+(NSString*)getSearcherOptionWithPageSize:(int)size PageNumber:(int)number List:(NSString *)list minYear:(NSString *)miny maxYear:(NSString *)maxy sort:(NSString *)sortString sci:(BOOL)isSci reviews:(BOOL)isRevies
{
    
    NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
    
    
    NSString* sci = [NSString stringWithFormat:@"{\"field\":\"SCI\",\"query\":\"%@\"}",(isSci?@"Y":@"N")];
    NSString* reviews = [NSString stringWithFormat:@"{\"field\":\"reviews\",\"query\":\"%@\"}",(isRevies?@"Y":@"N")];
    
    NSString* optionList = [NSString stringWithFormat:@"\"optionList\":[%@,%@]",sci,reviews];
    NSString* sort = [NSString stringWithFormat:@"\"sort\":\"%@\"",sortString];
    NSString* minYear = [NSString stringWithFormat:@"\"minYear\":\"%@\"",miny];
    NSString* maxYear = [NSString stringWithFormat:@"\"maxYear\":\"%@\"",maxy];
    NSString* pageSize = [NSString stringWithFormat:@"\"pageSize\":%d",size];
    NSString* pageNumber =[NSString stringWithFormat:@"\"pageNumber\":%d",number];
    
    
    [s appendString:@"\"searchOption\":{"];
    [s appendString:optionList];
    [s appendString:@","];
    [s appendString:sort];
    [s appendString:@","];
    [s appendString:minYear];
    [s appendString:@","];
    [s appendString:maxYear];
    [s appendString:@","];
    [s appendString:pageSize];
    [s appendString:@","];
    [s appendString:pageNumber];
    [s appendString:@"}"];
    
    return s;
}

+(NSString*)getSearcherOptionWithPageSize:(int)size PageNumber:(int)number List:(NSString*)list minYear:(NSString*)miny maxYear:(NSString*)maxy sort:(NSString*)sortString coreJournal:(BOOL)isCoreJournal
{
    
    NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
    
    
    NSString* coreJournal = [NSString stringWithFormat:@"{\"field\":\"hxk\",\"query\":\"%@\"}",(isCoreJournal?@"Y":@"N")];
    
    NSString* optionList = [NSString stringWithFormat:@"\"optionList\":[%@]",coreJournal];
    NSString* sort = [NSString stringWithFormat:@"\"sort\":\"%@\"",sortString];
    NSString* minYear = [NSString stringWithFormat:@"\"minYear\":\"%@\"",miny];
    NSString* maxYear = [NSString stringWithFormat:@"\"maxYear\":\"%@\"",maxy];
    NSString* pageSize = [NSString stringWithFormat:@"\"pageSize\":%d",size];
    NSString* pageNumber =[NSString stringWithFormat:@"\"pageNumber\":%d",number];
    
    
    [s appendString:@"\"searchOption\":{"];
    [s appendString:optionList];
    [s appendString:@","];
    [s appendString:sort];
    [s appendString:@","];
    [s appendString:minYear];
    [s appendString:@","];
    [s appendString:maxYear];
    [s appendString:@","];
    [s appendString:pageSize];
    [s appendString:@","];
    [s appendString:pageNumber];
    [s appendString:@"}"];
    
    return s;
    
}

+(NSString*)getAdvancedSearchURL
{
    return [[NSString alloc] initWithFormat:@"http://%@/docsearch/advsearch",SEARCH_SERVER];
    
}

+(NSString*)getSearcherRequestStringWithWord:(NSString*)searchWordJson Option:(NSString*)searchOptionJson searchSource:(NSString*) searchSource simpleFlag:(NSString*)simpleFlag
{
    NSMutableString* s = [[NSMutableString alloc] initWithFormat:@""];
    //NSString* searchWordJson=@"123";
    //NSString* searchOptionJson=@"456";
    //NSString* searchSource = @"PubMed";
    //NSString* isSimpleQuery =@"yes";
    
    [s appendString:@"{"];
    [s appendString:searchWordJson];
    [s appendString:@","];
    [s appendString:searchOptionJson];
    [s appendString:@","];
    [s appendString:@"\"searchSource\":\""];
    [s appendString:searchSource];
    [s appendString:@"\""];
    [s appendString:@","];
    [s appendString:@"\"isSimpleQuery\":"];
    [s appendString:simpleFlag];
    [s appendString:@"}" ];
    
    
    return  s;
}

@end
