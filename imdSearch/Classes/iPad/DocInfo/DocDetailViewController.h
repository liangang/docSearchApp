//
//  DocDetailViewController.h
//  imdSearch
//
//  Created by xiangzhang on 4/14/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DocDetail.h"
#import "EnumType.h"
#import "SearchContentMainViewController.h"

@interface DocDetailViewController : UIViewController

@property (strong, nonatomic) NSString *externelId;

@property (strong, nonatomic) NSDictionary *docInfoDic;

@property (assign, nonatomic) id<SearchContentShowDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *toolView;
@property (strong, nonatomic) IBOutlet UIImageView *toolbgImg;
@property (strong, nonatomic) IBOutlet UIButton *downSizeBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) IBOutlet UIButton *largeSizeBtn;
@property (strong, nonatomic) IBOutlet UIButton *favDocBtn;
@property (strong, nonatomic) IBOutlet UIButton *downloadDocBtn;

@property (strong, nonatomic) IBOutlet UIView *messgaeView;
@property (strong, nonatomic) IBOutlet UIImageView *msgtipsImgView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *msgLoadingActivity;
@property (strong, nonatomic) IBOutlet UILabel *msgtipLabel;

@property (assign, nonatomic) MeunSoruce meunSoruce;
@property (assign, nonatomic) NSString *isrecord;
@property (assign, nonatomic) ListType documentType;
/**
 *  缩小字体显示
 */
- (IBAction)downSizeTextClick:(id)sender;
/**
 *  放大字体显示
 */
- (IBAction)largeSizeTextClick:(id)sender;
/**
 *  点击收藏/取消文献
 */
- (IBAction)favDocBtnClick:(id)sender;
/**
 *  下载文献
 */
- (IBAction)downloadDocClick:(id)sender;
- (void)showMsgBarWithInfo:(NSString *)text;
@end
