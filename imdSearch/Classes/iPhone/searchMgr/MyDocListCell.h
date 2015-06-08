//
//  MyDocListCell.h
//  imdSearch
//
//  Created by xiangzhang on 3/25/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnumType.h"

@class DocInfoRecord;


@interface MyDocListCell : UITableViewCell

@property (nonatomic, strong) DocInfoRecord *infoModel;
@property (nonatomic, assign) ListType listType;

@property (nonatomic, strong) IBOutlet UILabel *sourceType;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *author;
@property (nonatomic, strong) IBOutlet UIImageView *type;
@property (nonatomic, strong) IBOutlet UIImageView *nextLogo;

- (void)setCellInfoWithDocInfo:(DocInfoRecord *)record;
- (void)setCellInfoWithLocationInfo:(NSDictionary *)dic;
@end
