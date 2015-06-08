//
//  IPhoneHeader.h
//  imdSearch
//
//  Created by Huajie Wu on 11-12-12.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompatibilityUtil.h"
#import "TableViewFormatUtil.h"
#import "ImageViews.h"
#import "TKAlertCenter.h"

#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "Strings.h"
#import "UserManager.h"
#import "ImdAppBehavior.h"

#ifdef DEBUG
  #define DLog( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
  #define DLog( s, ... ) 
#endif
