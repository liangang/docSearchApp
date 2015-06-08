//
//  systemVersion.h
//  imdSearch
//
//  Created by xiangzhang on 3/4/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#ifndef imdSearch_systemVersion_h
#define imdSearch_systemVersion_h

//定义宏，判断ios7
#define IOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0
#define IOS8 [[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone3GS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] currentMode].size) : NO)


#define  CGRECT_NO_NAV(x,y,w,h)      CGRectMake((x), (y+(IOS7?20:0)), (w), (h))
#define  CGRECT_HAVE_NAV(x,y,w,h)  CGRectMake((x), (y+(IOS7?64:0)), (w), (h))

#define IOS7ADJUST if(IOS7)\
            {self.extendedLayoutIncludesOpaqueBars= NO;\
            self.modalPresentationCapturesStatusBarAppearance=NO;\
            self.edgesForExtendedLayout= UIRectEdgeNone;}
#endif
