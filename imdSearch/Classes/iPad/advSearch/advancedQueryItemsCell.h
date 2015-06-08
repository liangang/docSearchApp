//
//  advancedQueryItemsCell.h
//  imdPad
//
//  Created by 8fox on 6/13/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OPERATION_UNKNOWN -1
#define OPERATION_AND  0
#define OPERATION_OR   1
#define OPERATION_NOT  2

@interface advancedQueryItemsCell : UITableViewCell <UITextFieldDelegate> {
    
    id delegate;
    int tag;
    
    int selectedOperation;
}


@property (nonatomic, retain) UITextField* conditionText;
@property (nonatomic, retain) id delegate;
@property (readwrite) int selectedOperation;
@property (readwrite) int tag;

@property (nonatomic, retain) UIButton* minusButton;
@property (nonatomic, retain) UIButton* filterButton;
@property (nonatomic, retain) UIButton* andButton;
@property (nonatomic, retain) UIButton* orButton;
@property (nonatomic, retain) UIButton* notButton;


- (IBAction)filterButtonTapped:(id)sender;
- (IBAction)operationButtonTapped:(id)sender;
- (IBAction)minusButtonTapped:(id)sender;

- (void)displayOperations;
- (void)hideOperations;
- (void)addTextChange;

@end
