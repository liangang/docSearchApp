//
//  TextLayoutLabel.h
//  imdSearch
//
//  Created by ding zhihong on 12-5-3.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import<Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface TextLayoutLabel : UILabel
{
  
@private
  
  CGFloat characterSpacing_;       //字间距
  
@private
  
  long linesSpacing_;   //行间距
  
}

@property(nonatomic,assign) CGFloat characterSpacing;
@property(nonatomic,assign) long linesSpacing;

@end
