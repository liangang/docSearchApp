//
//  IPhoneSettingsFeedback.h
//  imdSearch
//
//  Created by Huajie Wu on 12-1-10.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@interface IPhoneSettingsFeedback : UIViewController <UITextFieldDelegate, UITextViewDelegate, ASIHTTPRequestDelegate>
{
    IBOutlet UIScrollView* scrollView;
    IBOutlet UITextField* contactField;
    IBOutlet UITextView* feedbackTextV;
    BOOL showPlaceHolderInTextView;
    UIAlertView* _alertView;
    ASIHTTPRequest* _httpRequest;
}
@property (nonatomic, retain) ASIHTTPRequest* httpRequest;



@property (nonatomic,retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic,retain) IBOutlet UITextField* contactField;
@property (nonatomic,retain) IBOutlet UITextView* feedbackTextV;
@property (nonatomic,assign) BOOL showPlaceHolderInTextView;
@property (nonatomic,retain) UIAlertView* alertView;

- (void) postFeedback:(id) sender;
- (void) popBack:(id) sender;

- (void) setPlaceHolder;


@end
