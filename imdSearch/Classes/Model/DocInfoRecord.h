//
//  DocInfoRecord.h
//  imdSearch
//
//  Created by xiangzhang on 3/21/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocInfoRecord : NSObject

@property (nonatomic, strong)  NSString *userid;        // 用户id
@property (nonatomic, strong)  NSString *externalId;    // 文献id
@property (nonatomic, strong)  NSString *title;         // 文献名
@property (nonatomic, strong)  NSString *author;        //作者
@property (nonatomic, strong)  NSString *journal;       //期刊
@property (nonatomic, strong)  NSString *volume;        //卷
@property (nonatomic, strong)  NSString *issue;         // 期
@property (nonatomic, strong)  NSString *pagination;    // 页码
@property (nonatomic, strong)  NSString *pubDate;       //发布日期
@property (nonatomic, strong)  NSString *searchresult;
@property (nonatomic, strong)  NSString *affiliation;
@property (nonatomic, strong)  NSString *kind;          //类型，英文/中文
@property (nonatomic, strong)  NSString *type;          //索取状态
@property (nonatomic, assign)  BOOL isRead;             //是否已经读取
@end
