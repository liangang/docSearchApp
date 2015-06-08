//
//  publicMySearch.h
//  imdSearch
//
//  Created by  侯建政 on 6/29/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface publicMySearch : NSObject
{
    NSString *author;       //作者
    NSString *externalId;
    NSString *issue;        // 期
    NSString *journal;      //期刊
    NSString *pagination;    // 页码
    NSString *pubDate;      //发布日期
    NSString *title;
    NSString *userid;
    NSString *ismgr;
    NSString *searchresult;
    NSString *kind;
    NSString *volume;       //卷
    NSString *type;         //类型：无，有，索取中
}

@property (nonatomic, copy)  NSString *author;
@property (nonatomic, copy)  NSString *externalId;
@property (nonatomic, copy)  NSString *issue;
@property (nonatomic, copy)  NSString *journal;
@property (nonatomic, copy)  NSString *pagination;
@property (nonatomic, copy)  NSString *pubDate;
@property (nonatomic, copy)  NSString *title;
@property (nonatomic, copy)  NSString *userid;
@property (nonatomic, copy)  NSString *ismgr;
@property (nonatomic, copy)  NSString *searchresult;
@property (nonatomic, copy)  NSString *kind;
@property (nonatomic, copy)  NSString *volume;
@property (nonatomic, copy)  NSString *type;
@end
