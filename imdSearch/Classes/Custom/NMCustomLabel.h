//
//  NMCustomLabel.h
//  imdSearch
//
//  Created by ding zhihong on 12-5-3.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface NMCustomLabel : UILabel {
	CGFloat maxLineHeight;
	
	CTFramesetterRef framesetter;
	CFMutableAttributedStringRef attrString;
	
	BOOL shouldTruncate;
	
	CTFontRef bodyFont;
	CTFontRef bodyFontBold;
	CTFontRef bodyFontItalic;
	
	CGColorRef backgroundCGColor;
}

@property (nonatomic, readonly) NSString *cleanText;
@property (nonatomic, strong) UIFont *fontBold;
@property (nonatomic, strong) UIFont *fontItalic;
@property (nonatomic) CTTextAlignment ctTextAlignment;
@property (nonatomic, strong) UIColor *textColorBold;
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) int numberOfLines;
@property (nonatomic) BOOL shouldBoldAtNames;
@property (nonatomic) CGFloat kern;

@end
