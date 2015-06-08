//
//  DocDetail.h
//  imdSearch
//
//  Created by Lion User on 12-7-21.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocDetail : NSObject
{
  NSString* externalId;
  NSString* ckid;
  NSString* wfid;
  NSString* wpid;
  NSString* pmid;
  NSArray* text;
  NSArray* background;
  NSArray* objective;
  NSArray* methods;
  NSArray* results;
  NSArray* conclusions;
  NSArray* copyrights;
  NSArray* affiliation;
  NSArray* author;
  NSArray* category;
  NSArray* citation;
  NSString* coreJournal;
  NSString* iid;
  NSString* issue;
  NSString* journal;
  NSArray* keywords;
  NSArray* machineCategory;
  NSString* numCited;
  NSString* pagination;
  NSString* pubDate;
  NSArray* reference;
  NSString* referenceCount;
  NSString* title;
  NSString* volume;
  NSString* ISSN;
  NSString* isFav;
  NSString* isLogin;
  NSString* isEmailActive;
  NSString* isMobileActive;
  NSString* fetchStatus;
}

@property (nonatomic,retain) NSString *externalId;
@property (nonatomic,retain) NSString* ckid;
@property (nonatomic,retain) NSString* wfid;
@property (nonatomic,retain) NSString* wpid;
@property (nonatomic,retain) NSString* pmid;
@property (nonatomic,retain) NSArray* text;
@property (nonatomic,retain) NSArray* background;
@property (nonatomic,retain) NSArray* objective;
@property (nonatomic,retain) NSArray* methods;
@property (nonatomic,retain) NSArray* results;
@property (nonatomic,retain) NSArray* conclusions;
@property (nonatomic,retain) NSArray* copyrights;
@property (nonatomic,retain) NSArray* affiliation;
@property (nonatomic,retain) NSArray* author;
@property (nonatomic,retain) NSArray* category;
@property (nonatomic,retain) NSArray* citation;
@property (nonatomic,retain) NSString* coreJournal;
@property (nonatomic,retain) NSString* iid;
@property (nonatomic,retain) NSString* issue;
@property (nonatomic,retain) NSString* journal;
@property (nonatomic,retain) NSArray* keywords;
@property (nonatomic,retain) NSArray* machineCategory;
@property (nonatomic,retain) NSString* numCited;
@property (nonatomic,retain) NSString* pagination;
@property (nonatomic,retain) NSString* pubDate;
@property (nonatomic,retain) NSArray* reference;
@property (nonatomic,retain) NSString* referenceCount;
@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) NSString* volume;
@property (nonatomic,retain) NSString* ISSN;
@property (nonatomic,retain) NSString* isFav;
@property (nonatomic,retain) NSString* isLogin;
@property (nonatomic,retain) NSString* isEmailActive;
@property (nonatomic,retain) NSString* isMobileActive;
@property (nonatomic,retain) NSString* fetchStatus;

-(void)copyWithDetail:(DocDetail *)detail;

@end
