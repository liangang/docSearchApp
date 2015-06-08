//
//  DocListPadCell.h
//  imdSearch
//
//  Created by xiangzhang on 5/7/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DocInfoRecord.h"

#define ReadingFlag @"readFlag"

@interface DocListPadCell : UITableViewCell

@property (nonatomic, strong) DocInfoRecord *infoModel;

@property (nonatomic, strong) IBOutlet UILabel *journLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *authorLabel;
@property (nonatomic, strong) IBOutlet UILabel *affliationsLabel;

@property (nonatomic, strong) IBOutlet UIImageView *type;
@property (nonatomic, strong) IBOutlet UIImageView *nextLogo;

- (void)setCellInfoWithDocInfo:(DocInfoRecord *)record;
- (void)setCellInfoWithLocationInfo:(NSDictionary *)dic;
@end
