//
//  MyDocumentPadViewController.h
//  imdSearch
//
//  Created by xiangzhang on 4/15/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchContentMainViewController.h"

@protocol sortSelectDelegate <NSObject>

@optional

- (void)selectSortItem:(NSString *)item;
- (void)selectSortWithPosition:(NSInteger)item;

@end

/**
 *  iPad中我的文献页面控制类，主要用于切换获取记录，我的收藏，本地文献的信息。
 */
@interface MyDocumentPadViewController : UIViewController<UIPopoverControllerDelegate, sortSelectDelegate>

@property (assign, nonatomic) id<SearchContentShowDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) IBOutlet UIView *docSegmentView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *docSegment;
@property (strong, nonatomic) IBOutlet UIButton *docTypeBtn;


/**
 *  显示类型变化处理
 *
 *  @param sender
 */
- (IBAction)docTypeChange:(id)sender;

/**
 *  segmentControl的值变动处理
 *
 *  @param sender 控件
 */
- (IBAction)segmentValueChange:(id)sender;

/**
 *  从新载入文献记录信息
 */
- (void)reloadRecordInfo;
/**
 *  从新载入文献收藏信息
 */
- (void)reloadCollectionInfo;
/**
 *  从新载入本地文献的信息
 */
- (void)reloadLocationInfo;

/**
 *  清除我的文献的所有的信息
 */
- (void)clearMyDocumentAllInfo;
@end
