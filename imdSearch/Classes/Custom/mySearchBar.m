//
//  mySearchBar.m
//  imdPad
//
//  Created by 8fox on 7/3/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import "mySearchBar.h"
#import "imdSearcher.h"

#define IMG_EN @"searchIconEN"
#define IMG_CN @"searchIconCN"

@implementation mySearchBar

//@synthesize searcherDelegate,modeButton;

- (void)layoutSubviews 
{
    
    UITextField *searchField= nil;
    
    for(int i = 0; i < [self.subviews count]; i++) {
        if([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [self.subviews objectAtIndex:i];
        }
    }
    if(!(searchField == nil)) {
        
        searchField.frame = CGRectMake(2, 7, 340, 31);
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(5, 13, 36, 28);
        
        [searchField setLeftView:button];
        [searchField setLeftViewMode:UITextFieldViewModeAlways];
        
    }
}

@end

