//
//  advancedQueryItemsCell.m
//  imdPad
//
//  Created by 8fox on 6/13/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import "advancedQueryItemsCell.h"


@implementation advancedQueryItemsCell

//@synthesize operationSelect;
@synthesize conditionText;
@synthesize delegate;
@synthesize filterButton,andButton,orButton,notButton;
@synthesize tag,selectedOperation,minusButton;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        // Initialization code
        NSLog(@"222222 style");
        //[self.conditionText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
    }
    return self;
}

-(void)addTextChange
{
    [self.conditionText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(IBAction)filterButtonTapped:(id)sender
{
    
    if (delegate && [delegate respondsToSelector:@selector(filterButtonTapped:)])
    {
		[delegate performSelector:@selector(filterButtonTapped:) withObject:self];
    }
}

-(IBAction)operationButtonTapped:(id)sender
{
    NSLog(@"op tapped %@",self.conditionText.text);
    
    UIButton* button =(UIButton*)sender;
    
    if(button == self.andButton)
    {
        selectedOperation = OPERATION_AND;
    }
    else if(button == self.orButton)
    {
        selectedOperation = OPERATION_OR;
    }
    else
    {
        selectedOperation = OPERATION_NOT;
    }
    
    [self displayOperations];
    
    if (delegate && [delegate respondsToSelector:@selector(selectedOperation:)])
    {
		[delegate performSelector:@selector(selectedOperation:) withObject:self];
    }
}

-(void)displayOperations
{
    NSLog(@"current selected %d",selectedOperation);
    
    if(selectedOperation == OPERATION_AND)
    {
        [self.andButton setImage:[UIImage imageNamed:@"btn-and-highlight"] forState:UIControlStateNormal];
        
        [self.orButton setImage:[UIImage imageNamed:@"btn-or-normal"] forState:UIControlStateNormal];
        
        [self.notButton setImage:[UIImage imageNamed:@"btn-not-normal"] forState:UIControlStateNormal];
        
        NSLog(@"And");
    }
    
    if(selectedOperation == OPERATION_OR)
    {
        [self.andButton setImage:[UIImage imageNamed:@"btn-and-normal"] forState:UIControlStateNormal];
        
        [self.orButton setImage:[UIImage imageNamed:@"btn-or-highlight"] forState:UIControlStateNormal];
        
        [self.notButton setImage:[UIImage imageNamed:@"btn-not-normal"] forState:UIControlStateNormal];
        
        NSLog(@"or");
    }
    
    if(selectedOperation == OPERATION_NOT)
    {
        [self.andButton setImage:[UIImage imageNamed:@"btn-and-normal"] forState:UIControlStateNormal];
        
        [self.orButton setImage:[UIImage imageNamed:@"btn-or-normal"] forState:UIControlStateNormal];
        
        [self.notButton setImage:[UIImage imageNamed:@"btn-not-highlight"] forState:UIControlStateNormal];
        
        NSLog(@"not");
    }
}


- (void)dealloc
{
}

-(IBAction)minusButtonTapped:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(remvoeQueryItem:)])
    {
		[delegate performSelector:@selector(remvoeQueryItem:) withObject:self];
    }
}

#pragma mark - textfield delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (delegate && [delegate respondsToSelector:@selector(addKeyboardHolder:)])
    {
		[delegate performSelector:@selector(addKeyboardHolder:) withObject:textField];
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    if (delegate && [delegate respondsToSelector:@selector(removeKeyboardHolder:)])
    {
		[delegate performSelector:@selector(removeKeyboardHolder:) withObject:textField];
    }
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"edit complete");
    
    if (delegate && [delegate respondsToSelector:@selector(textValueInputed:)])
    {
		[delegate performSelector:@selector(textValueInputed:) withObject:self];
    }
    
    
}

-(void)textFieldDidChange:(UITextField *)textField
{
    NSLog(@"fix changed");
    if (delegate && [delegate respondsToSelector:@selector(textValueInputed:)])
    {
		[delegate performSelector:@selector(textValueInputed:) withObject:self];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)hideOperations
{
    self.andButton.hidden =YES;
    self.orButton.hidden =YES;
    self.notButton.hidden =YES;
}

@end
