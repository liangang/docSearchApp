//
//  GrayPageControl.m
//  imdSearch
//
//  Created by ding zhihong on 12-4-26.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "GrayPageControl.h"

@implementation GrayPageControl

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    activeImage = [UIImage imageNamed:@"dot-blue.png"];
    inactiveImage = [UIImage imageNamed:@"dot-grey.png"];
    return self;
}

-(void) updateDots
{
    for (int i = 0, sum = [self.subviews count]; i < sum; i++)
    {
        UIView *subView = [self.subviews objectAtIndex:i];
        if ([subView isKindOfClass:[UIImageView class]]) {
            UIImageView *dot = (UIImageView *)subView;
            if (i == self.currentPage)
                dot.image = activeImage;
            else
                dot.image = inactiveImage;
        }
    }
}

-(void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}
@end
