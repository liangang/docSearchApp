//
//  CommonMacro.h
//  imdSearch
//
//  Created by xiangzhang on 1/2/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#ifndef imdSearch_CommonMacro_h
#define imdSearch_CommonMacro_h

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define InfoColor [UIColor colorWithRed:124.0/255.0 green:142.0/255.0 blue:160.0/255.0 alpha:1]
#define DefaultColor1 [UIColor colorWithRed:124.0/255.0 green:142.0/255.0 blue:160.0/255.0 alpha:1]
#define NavigationColor  RGBCOLOR(248,249,249)
#define APPDefaultColor RGBCOLOR(64,111,176)

#endif
