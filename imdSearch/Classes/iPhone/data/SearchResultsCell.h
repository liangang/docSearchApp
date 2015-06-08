//
//  SearchResultsCell.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-29.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsCell : UITableViewCell
{
    UILabel* journalLbl;
    UILabel* titleLbl;
    UILabel* authorsLbl;
}

@property (nonatomic, retain) UILabel* journalLbl;
@property (nonatomic, retain) UILabel* titleLbl;
@property (nonatomic, retain) UILabel* authorsLbl;

@end
