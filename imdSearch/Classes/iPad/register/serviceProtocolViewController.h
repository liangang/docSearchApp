//
//  serviceProtocolViewController.h
//  imdSearch
//
//  Created by ding zhihong on 12-3-31.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface serviceProtocolViewController : UIViewController
{
  id delegate;
}

@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) IBOutlet UIScrollView* scrollView;

- (IBAction)backButtonTapped:(id)sender;

@end
