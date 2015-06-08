//
//  settingDetailViewController.h
//  imdSearch
//
//  Created by 立纲 吴 on 12/25/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"


#define DETAIL_TYPE_ABOUT_US 0
#define DETAIL_TYPE_POLOCY 1
#define DETAIL_TYPE_FEEDBACK 2
#define DETAIL_TYPE_RATING 3


@interface settingDetailViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate>
{
    int detailType;
    
    IBOutlet UIButton* backButton;
    IBOutlet UILabel* titleLabel;
    
    UIPlaceHolderTextView* feedbackView;
    UITextField* contactInfo;
    

}

@property (readwrite) int detailType;
@property (nonatomic,retain) IBOutlet UIButton* backButton;
@property (nonatomic,retain) IBOutlet UILabel* titleLabel;
@property (nonatomic,retain) UIPlaceHolderTextView* feedbackView;
@property (nonatomic,retain) UITextField* contactInfo;

-(void)displayDetail;
-(IBAction)back:(id)sender;
-(void)submitFeedback;
@end
