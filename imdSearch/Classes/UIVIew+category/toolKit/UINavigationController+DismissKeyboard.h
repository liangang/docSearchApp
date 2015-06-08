//
//  UINavigationController+DismissKeyboard.h
//  imdSearch
//
//  Created by xiangzhang on 10/30/13.
//  Copyright (c) 2013 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (DismissKeyboard)

// 使用UIModalPresentationFormSheet时
// 重写disablesAutomaticKeyboardDismissal方法使键盘隐藏
- (BOOL)disablesAutomaticKeyboardDismissal;

@end