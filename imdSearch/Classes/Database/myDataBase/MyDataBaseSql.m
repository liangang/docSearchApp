//
//  MyDataBaseSql.m
//  imdSearch
//
//  Created by  侯建政 on 7/3/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import "MyDataBaseSql.h"
#import "publicDoc.h"
#import "MyDatabase.h"
#import "publicMySearch.h"
#import "Strings.h"
#import "UserManager.h"
@implementation MyDataBaseSql
+(void) insertDetail:(NSMutableDictionary *)resultsJson ismgr:(NSString *)ismgr filePath:(NSString *)filePath
{
    publicDoc *docValue = [[publicDoc alloc]init];
    docValue.CKID = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"CKID"] ];
    docValue.WFID = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"WFID"]];
    docValue.WPID = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"WPID"]];
    docValue.PMID = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"PMID"]];
    docValue.abstractText = [resultsJson objectForKey:@"abstractText"];
    docValue.text = [docValue.abstractText objectForKey:@"text"];
    NSLog(@"%@",docValue.text);
    if (docValue.text == nil) {
        docValue.background = [docValue.abstractText objectForKey:@"background"];
        docValue.conclusions = [docValue.abstractText objectForKey:@"conclusions"];
        docValue.methods = [docValue.abstractText objectForKey:@"methods"];
        docValue.objective = [docValue.abstractText objectForKey:@"objective"];
        docValue.results = [docValue.abstractText objectForKey:@"results"];
        NSString *temp;
        temp = @"";
        if ([docValue.background count]) {
            temp = [NSString stringWithFormat:@"%@",[docValue.background objectAtIndex:0]];
        }
        if ([docValue.conclusions count]) {
            temp = [temp stringByAppendingString:[docValue.conclusions objectAtIndex:0]];
        }
        if ([docValue.methods count]) {
            temp = [temp stringByAppendingString:[docValue.methods objectAtIndex:0]];
        }
        if ([docValue.objective count]) {
            temp = [temp stringByAppendingString:[docValue.objective objectAtIndex:0]];
        }
        if ([docValue.results count]) {
            temp = [temp stringByAppendingString:[docValue.results objectAtIndex:0]];
        }
        NSArray *array = [[NSArray alloc] initWithObjects:temp, nil];
        docValue.text = [NSArray arrayWithArray:array];
    }
    docValue.affiliation = [resultsJson objectForKey:@"affiliation"];
    docValue.author = [resultsJson objectForKey:@"author"];
    docValue.category = [resultsJson objectForKey:@"category"];
    docValue.citation = [resultsJson objectForKey:@"citation"];
    docValue.coreJournal = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"coreJournal"] ];
    docValue.externalId = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"externalId"] ];
    docValue.iid = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"iid"] ];
    docValue.issue = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"issue"] ];
    docValue.journal = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"journal"] ];
    docValue.keywords = [resultsJson objectForKey:@"keywords"];
    docValue.machineCategory = [resultsJson objectForKey:@"machineCategory"];
    docValue.numCited = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"numCited"] ];
    docValue.pagination = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"pagination"] ];
    docValue.pubDate = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"pubDate"] ];
    docValue.reference = [resultsJson objectForKey:@"reference"];
    docValue.referenceCount = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"referenceCount"] ];
    docValue.title = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"title"] ];
    docValue.volume = [NSString stringWithFormat:@"%@",[resultsJson objectForKey:@"volume"] ];
    docValue.ismgr = ismgr;
    NSString *text;
    NSString *aaffiliation;
    NSString *author;
    NSString *category;
    NSString *citation;
    NSString *keywords;
    NSString *machineCategory;
    NSString *reference;
    
    text = nil;
    aaffiliation = nil;
    author = nil;
    category = nil;
    citation = nil;
    keywords = nil;
    machineCategory = nil;
    reference = nil;
    if ([docValue.text count]) {
        text = [docValue.text objectAtIndex:0];
        for (int i=1; i<[docValue.text count]; i++) {
            text = [NSString stringWithFormat:@"%@::%@",text,[docValue.text objectAtIndex:i]];
        }
        
    }
    if ([docValue.affiliation count]) {
        aaffiliation = [docValue.affiliation objectAtIndex:0];
        for (int i=1; i<[docValue.affiliation count]; i++) {
            aaffiliation = [NSString stringWithFormat:@"%@::%@",aaffiliation,[docValue.affiliation objectAtIndex:i]];
        }
        
    }
    if ([docValue.author count]) {
        author = [docValue.author objectAtIndex:0];
        for (int i=1; i<[docValue.author count]; i++) {
            author = [NSString stringWithFormat:@"%@::%@",author,[docValue.author objectAtIndex:i]];
        }
        
    }
    if ([docValue.category count]) {
        category = [docValue.category objectAtIndex:0];
        for (int i=1; i<[docValue.category count]; i++) {
            category = [NSString stringWithFormat:@"%@::%@",category,[docValue.category objectAtIndex:i]];
        }
        
    }
    if ([docValue.citation count]) {
        citation = [NSString stringWithFormat:@"%@",[docValue.citation objectAtIndex:0] ];
        for (int i=1; i<[docValue.citation count]; i++) {
            citation = [NSString stringWithFormat:@"%@::%@",citation,[docValue.citation objectAtIndex:i]];
        }
        
    }
    if ([docValue.keywords count]) {
        keywords = [docValue.keywords objectAtIndex:0];
        for (int i=1; i<[docValue.keywords count]; i++) {
            keywords = [NSString stringWithFormat:@"%@::%@",keywords,[docValue.keywords objectAtIndex:i]];
        }
        
    }
    if ([docValue.machineCategory count]) {
        machineCategory = [docValue.machineCategory objectAtIndex:0];
        for (int i=1; i<[docValue.machineCategory count]; i++) {
            machineCategory = [NSString stringWithFormat:@"%@::%@",machineCategory,[docValue.machineCategory objectAtIndex:i]];
        }
        
    }
    if ([docValue.reference count]) {
        reference = [docValue.reference objectAtIndex:0];
        for (int i=1; i<[docValue.reference count]; i++) {
            reference = [NSString stringWithFormat:@"%@::%@",reference,[docValue.reference objectAtIndex:i]];
        }
        
    }
    
    if ([MyDatabase isSelectId:docValue.externalId ismgr:ismgr]) {
        NSLog(@"1111");
        //          [MyDatabase updateDocValue:docValue.CKID WFID:docValue.WFID WPID:docValue.WPID text:self.text affiliation:self.aaffiliation author:self.author category:self.category citation:self.citation coreJournal:docValue.coreJournal externalId:docValue.externalId iid:docValue.iid issue:docValue.issue journal:docValue.journal keywords:self.keywords machineCategory:self.machineCategory numCited:docValue.numCited pagination:docValue.pagination pubDate:docValue.pubDate reference:self.reference referenceCount:docValue.referenceCount title:docValue.title volume:docValue.volume ismgr:docValue.ismgr];
    }else {
        [MyDatabase insertDocValue:docValue.CKID WFID:docValue.WFID WPID:docValue.WPID PMID:docValue.PMID text:text affiliation:aaffiliation author:author category:category citation:citation coreJournal:docValue.coreJournal externalId:docValue.externalId iid:docValue.iid issue:docValue.issue journal:docValue.journal keywords:keywords machineCategory:machineCategory numCited:docValue.numCited pagination:docValue.pagination pubDate:docValue.pubDate reference:reference referenceCount:docValue.referenceCount title:docValue.title volume:docValue.volume ismgr:docValue.ismgr filePath:filePath];
    }
}

+(void) insertMySearch:(NSMutableDictionary *)resultsJson ismgr:(NSString *)ismgr
{
    publicMySearch *valueSearch = [[publicMySearch alloc]init];
    NSArray *array = [resultsJson objectForKey:@"author"];
    if ([array count]) {
        valueSearch.author = [array objectAtIndex:0];
        for (int i=1; i<[array count]; i++) {
            valueSearch.author = [NSString stringWithFormat:@"%@::%@",valueSearch.author,[array objectAtIndex:i]];
        }
        NSLog(@"valueSearch.author=%@",valueSearch.author);
    }
    
    valueSearch.externalId = [resultsJson objectForKey:@"externalId"];
    valueSearch.issue = [resultsJson objectForKey:@"issue"];
    valueSearch.journal = [resultsJson objectForKey:@"journal"];
    valueSearch.pagination = [resultsJson objectForKey:@"pagination"];
    valueSearch.pubDate = [resultsJson objectForKey:@"pubDate"];
    valueSearch.title = [resultsJson objectForKey:@"title"];
    valueSearch.userid = [UserManager userName];
    valueSearch.volume = [resultsJson objectForKey:@"volume"];
    if ([MyDatabase isSelectId:valueSearch.externalId ismgr:ismgr userid:[UserManager userName]]) {
        
    }else {
        [MyDatabase insertMySearchValue:valueSearch.author externalId:valueSearch.externalId issue:valueSearch.issue journal:valueSearch.journal pagination:valueSearch.pagination pubDate:valueSearch.pubDate  title:valueSearch.title userid:valueSearch.userid ismgr:ismgr volume:valueSearch.volume];
    }
}

+(void) insertMyHistory:(NSMutableDictionary *)fullText userid:(NSString *)userid
{
    publicMySearch *valueSearch = [[publicMySearch alloc]init];
    valueSearch.searchresult = [fullText objectForKey:QUERY_HISTORY_STRING];
    valueSearch.kind = [fullText objectForKey:QUERY_HISTORY_SOURCE];
    if ([MyDatabase isExistHistorylist:valueSearch.searchresult kind:valueSearch.kind userid:userid]) {
        NSLog(@"历史记录表中已存在");
    }else {
        [MyDatabase insertMyHistorTable:valueSearch.searchresult kind:valueSearch.kind userid:userid];
    }
}
@end
