//
//  ShowDailog.m
//  imdSearch
//
//  Created by Lion User on 12-7-20.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "ShowDailog.h"

@implementation ShowDailog

+(void)showMsgOk:(NSString *)title msg:(NSString *)msg
{
  UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                      message:msg delegate:self 
                                            cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alertView show];
}

@end
