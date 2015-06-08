//
//  publicDoc.h
//  imdSearch
//
//  Created by  侯建政 on 6/29/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface publicDoc : NSObject
{
    NSString *CKID;
    NSString *WFID;
    NSString *WPID;
    NSString *PMID;
    NSMutableDictionary *abstractText;
    NSArray *text;
    NSArray *affiliation;
    NSArray *author;
    NSArray *category;
    NSArray *citation;
    NSString *coreJournal;
    NSString *externalId;
    NSString *iid;
    NSString *issue;
    NSString *journal;
    NSArray *keywords;
    NSArray *machineCategory;
    NSString *numCited;
    NSString *pagination;
    NSString *pubDate;
    NSArray *reference;
    NSString *referenceCount;
    NSString *title;
    NSString *volume;
    NSString *ismgr;
    NSString *filePath;
    NSString *isfav;
    NSArray *background;
    NSArray *conclusions;
    NSArray *methods;
    NSArray *objective;
    NSArray *results;
}
@property (nonatomic, copy)  NSString *CKID;
@property (nonatomic, copy)  NSString *WFID;
@property (nonatomic, copy)  NSString *WPID;
@property (nonatomic, copy)  NSString *PMID;
@property (nonatomic, retain)  NSMutableDictionary *abstractText;
@property (nonatomic, retain)  NSArray *text;
@property (nonatomic, retain)  NSArray *affiliation;
@property (nonatomic, retain)  NSArray *author;
@property (nonatomic, retain)  NSArray *category;
@property (nonatomic, retain)  NSArray *citation;
@property (nonatomic, copy)  NSString *coreJournal;
@property (nonatomic, copy)  NSString *externalId;
@property (nonatomic, copy)  NSString *iid;
@property (nonatomic, copy)  NSString *issue;
@property (nonatomic, copy)  NSString *journal;
@property (nonatomic, retain) NSArray *keywords;
@property (nonatomic, retain) NSArray *machineCategory;
@property (nonatomic, copy) NSString *numCited;
@property (nonatomic, copy) NSString *pagination;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, retain) NSArray *reference;
@property (nonatomic, copy) NSString *referenceCount;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *volume;
@property (nonatomic, copy) NSString *ismgr;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *isfav;
@property (nonatomic, retain) NSArray *background;
@property (nonatomic, retain) NSArray *conclusions;
@property (nonatomic, retain) NSArray *methods;
@property (nonatomic, retain) NSArray *objective;
@property (nonatomic, retain) NSArray *results;
@end
