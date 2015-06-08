//
//  CompatibilityUtil.h
//  imdSearch
//
//  Created by Huajie Wu on 11-12-12.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompatibilityUtil : NSObject

+ (BOOL) isIOS5Above;
+ (BOOL) isIOS7Above;
+ (void) setScopeBarBackgroundImage:(UISearchBar*)searchBar image:(NSString*) imageFile;

+ (void)setBackButtonBackgroundImage:(UIBarButtonItem*)barButton backgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

+ (void)setBarButtonBackgroundImage:(UIBarButtonItem*)barButton backgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

+ (void) setNavigationBarBackgroundImage:(UINavigationBar*)navBar backgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
