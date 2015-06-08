//
//  FulltextAlert.h
//  imdSearch
//
//  Created by Huajie Wu on 12-3-30.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FulltextAlert : UIViewController
{
  UIImageView* _icon;
  UILabel* _label1;
  UILabel* _label2;
  UIButton* _submit;
}

@property(nonatomic, retain) IBOutlet UIImageView* icon;
@property(nonatomic, retain) IBOutlet UILabel* label1;
@property(nonatomic, retain) IBOutlet UILabel* label2;
@property(nonatomic, retain) IBOutlet UIButton* submit;

@end
