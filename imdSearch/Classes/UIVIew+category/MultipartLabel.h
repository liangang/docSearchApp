//
//  MultipartLabel.h
//  imdSearch
//
//  Created by 立纲 吴 on 12/8/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

// this is brought by: http://stackoverflow.com/questions/1417346/iphone-uilabel-containing-text-with-multiple-fonts-at-the-same-time


#import <Foundation/Foundation.h>

@interface MultipartLabel : UIView {
}

@property (nonatomic,retain) UIView *containerView;
@property (nonatomic,retain) NSMutableArray *labels;
@property (nonatomic) UIViewContentMode contentMode;

- (void)updateNumberOfLabels:(int)numLabels;
- (void)setText:(NSString *)text forLabel:(int)labelNum;
- (void)setText:(NSString *)text andFont:(UIFont*)font forLabel:(int)labelNum;
- (void)setText:(NSString *)text andColor:(UIColor*)color forLabel:(int)labelNum;
- (void)setText:(NSString *)text andFont:(UIFont*)font andColor:(UIColor*)color forLabel:(int)labelNum;

@end
