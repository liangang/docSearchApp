//
//  MyDocmentPadCell.m
//  imdSearch
//
//  Created by xiangzhang on 4/15/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "MyDocmentPadCell.h"

#import "DocInfoRecord.h"
#import "Util.h"
#import "Strings.h"

@implementation MyDocmentPadCell

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

- (void)setCellInfoWithDocInfo:(DocInfoRecord *)record{
    NSString *journal = [Util replaceEM:record.journal LeftMark:@"" RightMark:@""];
    NSString *journalText = [Strings getJournal:journal pubDate:record.pubDate volume:record.volume issue:record.issue pagination:record.pagination];
    self.sourceType.text = journalText;
    self.title.text = record.title;
    self.author.text = record.author;
    if (!record.isRead) {
        self.nextLogo.image = [UIImage imageNamed:@"list_enter_default"];
    }else{
        self.nextLogo.image = [UIImage imageNamed:@"list_enter_vistited"];
    }
    
    if (self.listType == ListTypeRecord) {
        self.type.hidden = NO;
        [self setLogoWithType:record.type];
    }else{
        self.type.hidden = YES;
    }
}

- (void)setCellInfoWithLocationInfo:(NSDictionary *)dic{
    NSArray* authorsArray = [dic objectForKey:DOC_AUTHOR];
    NSString* authors = [Strings arrayToString:authorsArray];
    
    NSString* title = [Util replaceEM:[dic objectForKey:DOC_TITLE] LeftMark:@"" RightMark:@""];
    
    NSString* journal = [Util replaceEM:[dic objectForKey:DOC_JOURNAL] LeftMark:@"" RightMark:@""];
    NSString* pubDate = [dic objectForKey:DOC_PUBDATE];
    NSString* issue = [dic objectForKey:DOC_ISSUE];
    NSString* volume = [dic objectForKey:DOC_VOLUME];
    NSString* pagination = [dic objectForKey:DOC_PAGINATION];
    NSString* journalText = [Strings getJournal:journal pubDate:pubDate volume:volume issue:issue pagination:pagination];
    self.sourceType.text = journalText;
    self.title.text = title;
    self.author.text = authors;
    self.type.hidden = YES;
}

- (void)setLogoWithType:(NSString *)type{
    if ([@"NO_FULLTEXT" isEqualToString:type] || [@"FAIL" isEqualToString:type] || type == nil) {
        self.type.image = nil;
    }else if ([@"WAITING" isEqualToString:type]){
        self.type.image = [UIImage imageNamed:@"mine_progress"];
    }else if ([@"SUCCESS" isEqualToString:type]){
        self.type.image = [UIImage imageNamed:@"mine_pdf"];
    }
}
@end
