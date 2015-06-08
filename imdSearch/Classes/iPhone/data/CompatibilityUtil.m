//
//  CompatibilityUtil.m
//  imdSearch
//
//  Created by Huajie Wu on 11-12-12.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "CompatibilityUtil.h"

@implementation CompatibilityUtil


+ (BOOL) isIOS5Above
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5)
        return YES;
    return NO;
}

+ (BOOL) isIOS7Above{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        return YES;
    return NO;
}

+ (void) setScopeBarBackgroundImage:(UISearchBar*)searchBar image:(NSString*) imageFile
{
    if ([CompatibilityUtil isIOS5Above])
        searchBar.scopeBarBackgroundImage = [UIImage imageNamed:imageFile];
    // else try to firgure out how to do.
}

+ (void)setBackButtonBackgroundImage:(UIBarButtonItem*)barButton backgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    if ([CompatibilityUtil isIOS5Above])
        [barButton setBackButtonBackgroundImage:backgroundImage forState:state barMetrics:barMetrics];
    else {
        [barButton setImage:backgroundImage];
    }
}

+ (void) setNavigationBarBackgroundImage:(UINavigationBar*)navBar backgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics
{
    if (IOS7) {
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        navBar.translucent = NO;
    }else{
        if ([CompatibilityUtil isIOS5Above]) {
            [[UINavigationBar appearance] setTintColor:NavigationColor];
        }else{
            [navBar setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
        }
        
    }
}

+ (void)setBarButtonBackgroundImage:(UIBarButtonItem*)barButton backgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    if ([CompatibilityUtil isIOS5Above])
        [barButton setBackgroundImage:backgroundImage forState:state barMetrics:barMetrics];
    else {
        [barButton setImage:backgroundImage];
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
