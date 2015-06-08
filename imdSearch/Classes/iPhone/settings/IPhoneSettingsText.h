//
//  IPhoneSettingsText.h
//  imdSearch
//
//  Created by Huajie Wu on 12-1-10.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPhoneSettingsText : UIViewController {
    IBOutlet UIScrollView* scrollView;
    UILabel* label;
    NSString* type;
}

@property (nonatomic,retain) UIScrollView* scrollView;
@property (nonatomic,retain) UILabel* label;
@property (nonatomic,retain) NSString* type;

-(void) popBack:(id) sender;

@end
