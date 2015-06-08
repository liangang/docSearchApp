//
//  Layout.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-22.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "Layout.h"

@implementation Layout

+(void) layoutLabelByString:(UILabel*) myLabel
{
    myLabel.lineBreakMode = UILineBreakModeWordWrap;
    myLabel.numberOfLines = 0;
    CGSize maximumLabelSize = CGSizeMake(296,1000);
    CGSize expectedLabelSize = [myLabel.text sizeWithFont:myLabel.font constrainedToSize:maximumLabelSize lineBreakMode:myLabel.lineBreakMode];

    CGRect newFrame = myLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    myLabel.frame = newFrame;    
}


@end
