//
//  imdSearcher.h
//  imdSearch
//
//  Created by 8fox on 10/9/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SearchMode){
    SearchModeCN = 0,
    SearchModeEN = 1
};

typedef NS_ENUM(NSInteger, SearchSort){
    SearchSortPubdate = 1,
    SearchSortAuthor,
    SearchSortJournal,
    SearchSortTitle,
    SearchSortNone
};


#define  SEARCH_MODE_CN  0
#define  SEARCH_MODE_EN  1

#define  SEARCH_SORT_PUBDATE 1
#define  SEARCH_SORT_AUTHOR 2
#define  SEARCH_SORT_JOURNAL 3
#define  SEARCH_SORT_TITLE 4
#define  SEARCH_SORT_NONE 5


#define  SUGGESTION_MAX 5

#define SEARCHING_TYPE_SIMPLE 0
#define SEARCHING_TYPE_ADVANCED 1

#import "ASIHTTPRequest.h"

@interface imdSearcher : NSObject



+(ASIHTTPRequest*)simpleSearch:(NSString*)searchString Page:(int)pNo Lan:(int)LanMode Delegate:(id)d sort:(int)sortWay;
+(ASIHTTPRequest*)advacedSearch:(NSString*)startField QueryItems:(NSString*)items Option:(NSString*)optionList Page:(int)page Lan:(int)LanMode minYear:(NSString*)miny maxYear:(NSString*)maxy sort:(NSString*)sort sci:(BOOL)isSci reviews:(BOOL)isReviews Delegate:(id)d;
+(ASIHTTPRequest*)advacedSearch:(NSString*)startField QueryItems:(NSString*)items Option:(NSString*)optionList Page:(int)page Lan:(int)LanMode minYear:(NSString*)miny maxYear:(NSString*)maxy sort:(NSString*)sort coreJournal:(BOOL)isCoreJournal Delegate:(id)d;

//en:SCI reviews


+(NSString*)getSimpleSearchURLwithQueryString:(NSString*)str Language:(NSString*)lan pageNo:(int)pageNo pageSize:(int)pageSize sortWay:(int)sortWay;


+(ASIHTTPRequest*)fetchSuggestion:(NSString*)word lan:(int)LanMode Delegate:(id)d;

+(NSString*)getSearcherStartFieldItem:(NSString*)value Filter:(NSString*)filter;

+(NSString*)getSearcherQueryItem:(NSString*)value Filter:(NSString*)filter Operation:(NSString*)op;

+(NSString*)getSearcherURL:(int)Language;
+(NSString*)getSearcherSource:(int)Language;
+(NSString*)getSearcherWord:(NSString*)startField Language:(int)language QueryItems:(NSString*) QueryItems;

+(NSString*)getSearcherOptionWithPageSize:(int)size PageNumber:(int)number List:(NSString*)list minYear:(NSString*)miny maxYear:(NSString*)maxy sort:(NSString*)sortString sci:(BOOL)isSci reviews:(BOOL)isReviews;
+(NSString*)getSearcherOptionWithPageSize:(int)size PageNumber:(int)number List:(NSString*)list minYear:(NSString*)miny maxYear:(NSString*)maxy sort:(NSString*)sortString coreJournal:(BOOL)isCoreJournal;

+(NSString*)getAdvancedSearchURL;
+(NSString*)getSearcherRequestStringWithWord:(NSString*)searchWordJson Option:(NSString*)searchOptionJson searchSource:(NSString*) searchSource simpleFlag:(NSString*)simpleFlag;

@end
