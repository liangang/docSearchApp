//
//  LoginTitleController.h
//  imdSearch
//
//  Created by Huajie Wu on 12-2-7.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTitleController : UIViewController
{
    NSString* titleStr;
    IBOutlet UIButton* selectedBtn;
    IBOutlet UIButton* level1;
    IBOutlet UIButton* level2;
    IBOutlet UIButton* level3;
    IBOutlet UIButton* level4;

    UIColor* color1;
    UIColor* color2;
};

@property (nonatomic,retain) NSString* titleStr;
@property (nonatomic,retain) IBOutlet UIButton* selectedBtn;
@property (nonatomic,retain) IBOutlet UIButton* level1;
@property (nonatomic,retain) IBOutlet UIButton* level2;
@property (nonatomic,retain) IBOutlet UIButton* level3;
@property (nonatomic,retain) IBOutlet UIButton* level4;

@property (strong, nonatomic) IBOutlet UILabel *centerHLine;

@property (nonatomic,retain) UIColor* color1;
@property (nonatomic,retain) UIColor* color2;

-(IBAction) selectTitle:(id)sender;


-(void) popBack;
- (void)behavior:(NSString *)status;
@end
