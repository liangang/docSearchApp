//
//  ImageViews.m
//  imdSearch
//
//  Created by Huajie Wu on 11-12-5.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "ImageViews.h"

@implementation ImageViews



+(void) setBackgroundImage:(UIView*)view image:(NSString*)imagefile
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_BG_TABBAR]];

    [view addSubview:imageView];
    [view sendSubviewToBack:imageView];
    [view setOpaque:NO];
    [view setBackgroundColor:[UIColor clearColor]];
}

@end
