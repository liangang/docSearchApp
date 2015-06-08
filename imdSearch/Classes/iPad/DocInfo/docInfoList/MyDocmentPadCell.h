//
//  MyDocmentPadCell.h
//  imdSearch
//
//  Created by xiangzhang on 4/15/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EnumType.h"

@class DocInfoRecord;

@interface MyDocmentPadCell : UITableViewCell

@property (nonatomic, strong) DocInfoRecord *infoModel;
@property (nonatomic, assign) ListType listType;

@property (nonatomic, strong) IBOutlet UILabel *sourceType;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *author;
@property (nonatomic, strong) IBOutlet UILabel *department;
@property (nonatomic, strong) IBOutlet UIImageView *type;
@property (nonatomic, strong) IBOutlet UIImageView *nextLogo;

/**
 *  对cell信息进行加载显示
 *
 *  @param record 需要显示信息的model，文献记录信息
 */
- (void)setCellInfoWithDocInfo:(DocInfoRecord *)record;

/**
 *   对cell信息进行加载显示
 *
 *  @param dic  需要显示信息的dictionary，文献记录信息字典
 */
- (void)setCellInfoWithLocationInfo:(NSDictionary *)dic;

@end
