//
//  TableViewFormatUtil.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-30.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMCustomLabel.h"

@class DocInfoRecord;

#define ZOOM_STEP 1.5

#define CELL_HEIGHT 110
#define JOURNAL_TAG 1
#define TITLE_TAG 2
#define AUTHORS_TAG 3 

#define CONTENT_MARGIN 8
#define CONTENT_MARGIN_LEFT 16
#define SEARCHRESULTS_MARGIN_LEFT 24
#define CONTENT_WIDTH 260

#define MAX_HEIGHT 20000.0f

#define FONT_TYPE @"Palatino"
#define FONT_BOLD @"Palatino-Bold"

#define FONT_0 12.0
#define FONT_1 14.0
#define FONT_2 16.0
#define FONT_3 18.0
#define FONT_4 20.0
@interface TableViewFormatUtil : NSObject

+(UIButton*) customButton:(NSString*) imageFile title:(NSString*) title location:(int)x target:(id)target action:(SEL)action ;

+ (UITableViewCell *)formatCell:(UITableView *)tableView CellIdentifier:(NSString *)cellIdentifier journal:(NSString*) journal title:(NSString*) title authors:(NSString*) authors unreadSign:(BOOL)unreadSign;

/**
 *  修改状态栏的返回按钮显示
 *
 *  @param navigationItem 需要修改的状态栏Item
 */
+ (void)backBarButtonItemInfoModify:(UINavigationItem *)navigationItem;
/**
 *  更加文献信息创建UItableViewCel
 *
 *  @param tableView      需要创建cell的UITableView
 *  @param cellIdentifier id
 *  @param record         文献信息
 *
 *  @return cell
 */
+ (UITableViewCell *)formatCell:(UITableView *)tableView CellIdentifier:(NSString *)cellIdentifier docInfo:(DocInfoRecord *)record;

+ (UITableViewCell *)formatCell:(UITableView *)tableView CellIdentifier:(NSString *)cellIdentifier data:(NSDictionary*) resultsItem unreadSign:(BOOL)unreadSign;

+(NSInteger) layoutLabelByString:(UILabel*) myLabel text:(NSString*)text y:(NSInteger)yOffSet  contentWidth:(NSInteger)width;

+(NSInteger) layoutLabelByStringWithLeft:(UILabel*) myLabel text:(NSString*)text y:(NSInteger)yOffSet  contentWidth:(NSInteger)width marginLeft:(NSInteger)left;

+(NSInteger) layoutImageView:(UIImageView*) myView y:(NSInteger)yOffSet;


+(void) layoutTitleView:(UIView*)titleView query:(NSString*)query resultsNo:(NSString*)resultsNo;

+(CGRect)zoomRectForScale:(UIView*)scrollView scale:(float)scale withCenter:(CGPoint)center;

/**
 *  定制UIBarButtonItem的颜色，及特定文字显示
 *
 *  @param title    显示的标题
 *  @param color    文字颜色
 *  @param target   target对象
 *  @param selector 方法
 *
 *  @return 需要是呀的UIBarButtonItem
 */
+ (UIBarButtonItem *)customBackBarButton:(NSString *)title color:(UIColor *)color target:(id)target action:(SEL)selector;

+(UIBarButtonItem*) customBackBarButton:(NSString*) imageFile title:(NSString*) title;

+(UIBarButtonItem*) customBarButton:(NSString*) imageFile title:(NSString*) title target:(id)target action:(SEL)action;

+(UIBarButtonItem*) initCustomBarButton:(NSString*) imageFile title:(NSString*) title target:(id)target action:(SEL)action width:(NSUInteger)width;

+(void) setCustomBarButtonTitle:(UIBarButtonItem*)barBtn title:(NSString*) title;

+(UIBarButtonItem*) customBackBarButtonWithAction:(NSString*) imageFile title:(NSString*) title target:(id)target action:(SEL)action;

+(void) setContentBackGround:(UIView*)view image:(NSString*)imageFile;

+(void) setTableViewBackGround:(UITableView*) view image:(NSString*) imageFile;

+(void) setToolBarBackGround:(UIToolbar*)toolBar image:(NSString*) imageFile;

+(void) setNavigationBar:(UINavigationController*)nav normal:(NSString*)normal highlight:(NSString*)highlight barBg:(NSString*)barBg;

+(UIView*) initActiveHintView:(NSString*) text lines:(NSUInteger)lines;


+(UIColor*) getFontColor1;
+(UIColor*) getFontColor2;
+(UIColor*) getFontColor3;
+(UIColor*) getFontColor4;
+(UIColor*) getFontColor5;

+(UIColor*) getSelectedColor;
+(UIColor*) getUnSelectedColor;

+(UIColor*) getInputedColor;
+(UIColor*) getNotInputedColor;

+(UIImage *) imageFromColor:(UIColor *)color;

/**
 *  对UIView设置边框颜色
 *
 *  @param view  需要设置的UIview
 *  @param color 边框颜色
 */
+ (void)setBorder:(UIView *)view Color:(UIColor *)color;

+(void) setShadow:(UINavigationBar *)navBar;
@end
