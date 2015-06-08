//
//  DocListPadCell.m
//  imdSearch
//
//  Created by xiangzhang on 5/7/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "DocListPadCell.h"

#import "Util.h"
#import "Strings.h"

@implementation DocListPadCell

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
    self.journLabel.text = journalText;
    self.titleLabel.text = record.title;
    self.authorLabel.text = record.author;
    self.affliationsLabel.text = record.affiliation;
    
    if (!record.isRead) {
        self.nextLogo.image = [UIImage imageNamed:@"list_enter_default"];
    }else{
        self.nextLogo.image = [UIImage imageNamed:@"list_enter_vistited"];
    }
    
    if ([@"NO_FULLTEXT" isEqualToString:record.type] || [@"FAIL" isEqualToString:record.type]) {
        self.type.image = Nil;
    }else if ([@"WAITING" isEqualToString:record.type]){
        self.type.image = [UIImage imageNamed:@"mine_progress"];
    }else if ([@"SUCCESS" isEqualToString:record.type]){
        self.type.image = [UIImage imageNamed:@"mine_pdf"];
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
    self.journLabel.text = journalText;
    self.titleLabel.text = title;
    self.authorLabel.text = authors;
    self.affliationsLabel.text = [Strings arrayToString:[dic objectForKey:@"affiliation"]];
    
    if ([[dic allKeys] containsObject:@"resulteIsRead"]) {
        BOOL isRead = [[dic valueForKey:@"resulteIsRead"] boolValue];
        self.nextLogo.image = [UIImage imageNamed:isRead ? @"list_enter_vistited" : @"list_enter_default"];
    }
    
    self.type.hidden = YES;
}


@end
