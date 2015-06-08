//
//  SearchResultsCell.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-29.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "SearchResultsCell.h"

@implementation SearchResultsCell

@synthesize journalLbl, titleLbl, authorsLbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
