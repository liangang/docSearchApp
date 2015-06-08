//
//  advancedYearItemsCell.h
//  imdPad
//
//  Created by 8fox on 6/14/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface advancedYearItemsCell : UITableViewCell {
    
    IBOutlet UIButton* minYear;
    IBOutlet UIButton* maxYear;
    id delegate;
}

@property (nonatomic, retain) UIButton* minYear;
@property (nonatomic, retain) UIButton* maxYear;
@property (nonatomic, retain) id delegate;

- (IBAction)minYearButtonTapped:(id)sender;
- (IBAction)maxYearButtonTapped:(id)sender;
@end
