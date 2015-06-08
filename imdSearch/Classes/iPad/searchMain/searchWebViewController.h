//
//  searchWebViewController.h
//  imdSearch
//
//  Created by 立纲 吴 on 12/14/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface searchWebViewController : UIViewController
{
}

@property(nonatomic,retain) IBOutlet UIWebView* webview;

-(IBAction)CloseThis:(id)sender;
-(void)loadURL:(NSString*)u;

@end
