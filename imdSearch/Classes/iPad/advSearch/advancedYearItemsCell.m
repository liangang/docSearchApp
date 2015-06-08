//
//  advancedYearItemsCell.m
//  imdPad
//
//  Created by 8fox on 6/14/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import "advancedYearItemsCell.h"


@implementation advancedYearItemsCell

@synthesize minYear,maxYear;
@synthesize delegate;

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

- (void)dealloc
{
}

#pragma  mark - year button events

-(IBAction)minYearButtonTapped:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(minYearButtonTapped:)]) 
    {
		[delegate performSelector:@selector(minYearButtonTapped:) withObject:self];
    }    
}

-(IBAction)maxYearButtonTapped:(id)sender
{ 
    if (delegate && [delegate respondsToSelector:@selector(maxYearButtonTapped:)]) 
    {
		[delegate performSelector:@selector(maxYearButtonTapped:) withObject:self];
    }    


}

@end
