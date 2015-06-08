//
//  TableViewFormatUtil.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-30.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "TableViewFormatUtil.h"
#import "Util.h"
#import "Strings.h"
#import "CompatibilityUtil.h"
#import "ImageViews.h"
#import "DocInfoRecord.h"

#import <QuartzCore/QuartzCore.h>
@implementation TableViewFormatUtil


+(UIColor*) getFontColor1
{
    //Used in Journal, afficiations.
    UIColor* color = RGBCOLOR(102, 102, 102);
    return color;
}

+(UIColor*) getFontColor2
{
    //Used in Title
    UIColor* color = RGBCOLOR(42, 30, 24);
    return color;
}

+(UIColor*) getFontColor3
{
    //Used in Abstract.
    UIColor* color = RGBCOLOR(107, 96, 69);
    return color;
}

+(UIColor*) getFontColor4
{
    //Not used.
    return RGBCOLOR(42, 30, 24);
}


+(UIColor*) getFontColor5
{
    //Not used.
    return RGBCOLOR(212, 73, 48);
}

+ (void)backBarButtonItemInfoModify:(UINavigationItem *)navigationItem{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] init];
    barButtonItem.title = @"返回";
    barButtonItem.tintColor = NavigationColor;
    navigationItem.backBarButtonItem = barButtonItem;
}

+ (UITableViewCell *)formatCell:(UITableView *)tableView CellIdentifier:(NSString *)cellIdentifier data:(NSDictionary*) resultsItem unreadSign:(BOOL)unreadSign
{
    NSArray* authorsArray = [resultsItem objectForKey:DOC_AUTHOR];
    NSString* authors = [Strings arrayToString:authorsArray];
    
    NSString* title = [Util replaceEM:[resultsItem objectForKey:DOC_TITLE] LeftMark:@"" RightMark:@""];
    NSString* journal = [Util replaceEM:[resultsItem objectForKey:DOC_JOURNAL] LeftMark:@"" RightMark:@""];
    NSString* pubDate = [resultsItem objectForKey:DOC_PUBDATE];
    NSString* issue = [resultsItem objectForKey:DOC_ISSUE];
    NSString* volume = [resultsItem objectForKey:DOC_VOLUME];
    NSString* pagination = [resultsItem objectForKey:DOC_PAGINATION];
    NSString* journalText = [Strings getJournal:journal pubDate:pubDate volume:volume issue:issue pagination:pagination];
    
    return [TableViewFormatUtil formatCell:tableView CellIdentifier:cellIdentifier journal:journalText title:title authors:authors unreadSign:unreadSign];
}


+ (UITableViewCell *)formatCell:(UITableView *)tableView CellIdentifier:(NSString *)cellIdentifier docInfo:(DocInfoRecord *)record{
    NSString *journalText = [Strings getJournal:[Util replaceEM:record.journal LeftMark:@"" RightMark:@""] pubDate:record.pubDate volume:record.volume issue:record.issue pagination:record.pagination];
    NSString *title = [Util replaceEM:record.title LeftMark:@"" RightMark:@""];
    
    
    return [TableViewFormatUtil formatCell:tableView CellIdentifier:cellIdentifier journal:journalText title:title authors:record.author unreadSign:!record.isRead];
}

+ (UITableViewCell *)formatCell:(UITableView *)tableView CellIdentifier:(NSString *)cellIdentifier journal:(NSString*) journal title:(NSString*) title authors:(NSString*) authors unreadSign:(BOOL)unreadSign
{
    UILabel* journalLbl;
    UILabel* titleLbl;
    UILabel* authorsLbl;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        float yOffset = CONTENT_MARGIN;
        journalLbl = [[UILabel alloc]initWithFrame:CGRectNull];
        
        journalLbl.tag = JOURNAL_TAG;
        
        UIFont* font1 = [UIFont fontWithName:FONT_TYPE size:FONT_1];
        journalLbl.font = font1;
        
        journalLbl.textAlignment = NSTextAlignmentLeft;
        journalLbl.textColor = [TableViewFormatUtil getFontColor1];
        journalLbl.numberOfLines = 1;
        journalLbl.opaque = NO;
        journalLbl.backgroundColor = [UIColor clearColor];
        
        [journalLbl setFrame:CGRectMake(SEARCHRESULTS_MARGIN_LEFT, yOffset, CONTENT_WIDTH, 15)];
        
        [cell.contentView addSubview:journalLbl];
        
        yOffset += 18;
        
        titleLbl = [[UILabel alloc]initWithFrame:CGRectNull];
        titleLbl.tag = TITLE_TAG;
        UIFont* font2 = [UIFont fontWithName:FONT_BOLD size:FONT_3];
        titleLbl.font = font2;
        titleLbl.textAlignment = NSTextAlignmentLeft;
        titleLbl.textColor = [TableViewFormatUtil getFontColor2];
        titleLbl.numberOfLines = 3;
        titleLbl.opaque = NO;
        titleLbl.backgroundColor = [UIColor clearColor];
        
        [titleLbl setFrame:CGRectMake(SEARCHRESULTS_MARGIN_LEFT, yOffset, CONTENT_WIDTH, 60)];
        
        [cell.contentView addSubview:titleLbl];
        yOffset += 60 + 3;
        
        authorsLbl = [[UILabel alloc]initWithFrame:CGRectNull];
        authorsLbl.tag = AUTHORS_TAG;
        authorsLbl.font = font1;
        authorsLbl.textAlignment = NSTextAlignmentLeft;
        authorsLbl.textColor = [TableViewFormatUtil getFontColor1];
        authorsLbl.opaque = NO;
        authorsLbl.backgroundColor = [UIColor clearColor];
        
        [authorsLbl setFrame:CGRectMake(SEARCHRESULTS_MARGIN_LEFT, yOffset, CONTENT_WIDTH, 15)];
        
        [cell.contentView addSubview:authorsLbl];
    } else {
        journalLbl = (UILabel*) [cell.contentView viewWithTag:JOURNAL_TAG];
        titleLbl = (UILabel*) [cell.contentView viewWithTag:TITLE_TAG];
        authorsLbl = (UILabel*) [cell.contentView viewWithTag:AUTHORS_TAG];
    }
    journalLbl.text = journal;
    titleLbl.text = title;
    authorsLbl.text = authors;
    
    //set unread image.
    if (unreadSign)
        [cell.imageView setImage:[UIImage imageNamed:IMG_IMG_DOT_UNREAD]];
    else {
        [cell.imageView setImage:nil];
    }
    cell.selected = NO;
    
    return cell;
}

+(NSInteger) layoutImageView:(UIImageView*) myView y:(NSInteger)yOffSet
{
    [myView setFrame:CGRectMake(0, yOffSet, myView.frame.size.width, myView.frame.size.height)];
    return yOffSet + myView.frame.size.height + 3;
}

+(NSInteger) layoutLabelByString:(UILabel*) myLabel text:(NSString*)text y:(NSInteger)yOffSet  contentWidth:(NSInteger)width
{
    
    CGSize maximumLabelSize = CGSizeMake(width, MAX_HEIGHT);
    CGSize expectedLabelSize = [text sizeWithFont:myLabel.font constrainedToSize:maximumLabelSize lineBreakMode:myLabel.lineBreakMode];
    
    [myLabel setFrame:CGRectMake(CONTENT_MARGIN_LEFT, yOffSet, expectedLabelSize.width, expectedLabelSize.height)];
    
    return yOffSet + expectedLabelSize.height + 3;
    
}


+(NSInteger) layoutLabelByStringWithLeft:(UILabel*) myLabel text:(NSString*)text y:(NSInteger)yOffSet  contentWidth:(NSInteger)width marginLeft:(NSInteger)left
{
    CGSize maximumLabelSize = CGSizeMake(width, MAX_HEIGHT);
    CGSize expectedLabelSize = [text sizeWithFont:myLabel.font constrainedToSize:maximumLabelSize lineBreakMode:myLabel.lineBreakMode];
    
    [myLabel setFrame:CGRectMake(left, yOffSet, expectedLabelSize.width, expectedLabelSize.height)];
    
    return yOffSet + expectedLabelSize.height + 3;
}

+(void) layoutTitleView:(UIView*)titleView query:(NSString*)query resultsNo:(NSString*)resultsNo
{
    UILabel* queryLabel = [[UILabel alloc]initWithFrame:CGRectNull];
    queryLabel.numberOfLines = 0;
    queryLabel.font = [UIFont fontWithName:FONT_BOLD size:FONT_3];
    queryLabel.textAlignment = NSTextAlignmentCenter;
    queryLabel.opaque = NO;
    queryLabel.text = query;
    [queryLabel setFrame:CGRectMake(0, 2, 150, 20)];
    
    UILabel* resultsLabel = [[UILabel alloc]initWithFrame:CGRectNull];
    resultsLabel.text = resultsNo;
    resultsLabel.numberOfLines = 0;
    resultsLabel.opaque = NO;
    resultsLabel.font = [UIFont fontWithName:FONT_TYPE size:FONT_2];
    resultsLabel.textAlignment = NSTextAlignmentCenter;
    [resultsLabel setFrame:CGRectMake(0, 22, 150, 20)];
    
    [titleView setFrame:CGRectMake(10, 2, 150, 45)];
    [titleView addSubview:queryLabel];
    [titleView addSubview:resultsLabel];
    titleView.opaque = NO;
    
}


+(CGRect)zoomRectForScale:(UIView*)scrollView scale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

+(UIBarButtonItem*) customBackBarButtonWithAction:(NSString*) imageFile title:(NSString*) title target:(id)target action:(SEL)action
{
    UIImage* image = [UIImage imageNamed:imageFile];
    
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    [backBtn setBackButtonBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    return backBtn;
}

+ (UIBarButtonItem *)customBackBarButton:(NSString *)title color:(UIColor *)color target:(id)target action:(SEL)selector{
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:selector];
    barItem.tintColor = color;
    return barItem;
}

+ (UIBarButtonItem*) customBackBarButton:(NSString*) imageFile title:(NSString*) title
{
    UIImage* image = [UIImage imageNamed:imageFile];
    
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [CompatibilityUtil setBackButtonBackgroundImage:backBtn backgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //[backBtn setImage:image];
    return backBtn;
}

+(void) setContentBackGround:(UIView*) view image:(NSString*) imageFile
{
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFile]];
    if (iPhone5) {
        imageView.frame = CGRectMake(0, 87, 320, 417);
    }
    [view addSubview:imageView];
    [view sendSubviewToBack:imageView];
    [view setOpaque:NO];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view setBackgroundColor:[UIColor clearColor]];
}

+(void) setTableViewBackGround:(UITableView*) view image:(NSString*) imageFile
{
    UIImageView* imageContentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFile]];
    [view setBackgroundView:imageContentView];
    [view setBackgroundColor:[UIColor clearColor]];
    [view setOpaque:NO];
}


+(void) setToolBarBackGround:(UIToolbar*)toolBar image:(NSString*) imageFile
{
    UIImageView* imageContentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFile]];
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 5)
        [toolBar setBackgroundImage:[UIImage imageNamed:imageFile] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    else
        [toolBar insertSubview:imageContentView atIndex:0]; // iOS4 atIndex:0
    [toolBar setBackgroundColor:[UIColor clearColor]];
    
    [toolBar setOpaque:NO];
    //    UIImage* image = [UIImage imageNamed:imageFile];
    //    [image drawInRect:CGRectMake(toolBar.frame.origin.x, toolBar.frame.origin.y, toolBar.frame.size.width, toolBar.frame.size.height)];
}

+(void) setNavigationBar:(UINavigationController*)nav normal:(NSString*)normal highlight:(NSString*)highlight barBg:(NSString*)barBg
{
    
    nav.title = @"";
  if (IOS7) {
    nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:normal] selectedImage:[UIImage imageNamed:highlight]];
  }else
  {
    if ([nav.tabBarItem respondsToSelector:@selector(setFinishedSelectedImage:withFinishedUnselectedImage:)]) {
        [nav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:highlight] withFinishedUnselectedImage:[UIImage imageNamed:normal]];
        [nav.tabBarItem setImageInsets:UIEdgeInsetsMake(3, 0, 1, 0)];
    }
}
    [CompatibilityUtil setNavigationBarBackgroundImage:[nav navigationBar] backgroundImage:[UIImage imageNamed:barBg] forBarMetrics:UIBarMetricsDefault];
}

+(UIBarButtonItem*) customBarButton:(NSString*) imageFile title:(NSString*) title target:(id)target action:(SEL)action
{
    UIImage* imageView = [UIImage imageNamed:imageFile];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (imageFile != nil){
        button.frame = CGRectMake(0, 0, imageView.size.width, imageView.size.height);
    }else{
        button.frame = CGRectMake(0, 0, 50, 30);
    }
    
    [button setBackgroundImage:imageView forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIFont* font = [UIFont fontWithName:FONT_TYPE size:FONT_1];
    button.titleLabel.font = font;
    [button setTitle:title forState:UIControlStateNormal];
    
    UIBarButtonItem* barBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barBtn;
}


+(UIBarButtonItem*) initCustomBarButton:(NSString*) imageFile title:(NSString*) title target:(id)target action:(SEL)action width:(NSUInteger)width
{
    UIImage* imageView = [UIImage imageNamed:imageFile];
    //    UIView* container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, imageView.size.width, imageView.size.height)];
    
    UIView* customView = [[UIView alloc]initWithFrame:CGRectMake(3, -5, width, imageView.size.height)];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((width - imageView.size.width)/2, 0, imageView.size.width, imageView.size.height);
    
    [button setBackgroundImage:imageView forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIFont* font = [UIFont fontWithName:FONT_TYPE size:FONT_1];
    button.titleLabel.font = font;
    [button setTitle:title forState:UIControlStateNormal];
    
    [customView addSubview:button];
    
    UIBarButtonItem* barBtn = [[UIBarButtonItem alloc] initWithCustomView:customView];
    return barBtn;
}

+(UIButton*) customButton:(NSString*) imageFile title:(NSString*) title location:(int)x target:(id)target action:(SEL)action
{
    UIImage* imageView = [UIImage imageNamed:imageFile];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(x-5-imageView.size.width,5 , imageView.size.width, imageView.size.height);
    
    [button setBackgroundImage:imageView forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIFont* font = [UIFont fontWithName:FONT_TYPE size:FONT_1];
    button.titleLabel.font = font;
    [button setTitle:title forState:UIControlStateNormal];
    
    return button;
}

+(UIView*) initActiveHintView:(NSString*) text lines:(NSUInteger)lines
{
    UIView* hintView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 9.0, 307.0, 56.0)];

    hintView.backgroundColor = RGBCOLOR(248, 248, 248);
    
    UILabel* hint = [[UILabel alloc] init];
    hint.text = text;
    hint.lineBreakMode = NSLineBreakByCharWrapping;
    hint.numberOfLines = lines;
    hint.textColor = [TableViewFormatUtil getFontColor1];
    hint.font = [UIFont fontWithName:FONT_TYPE size:FONT_1];
    hint.backgroundColor = [UIColor clearColor];
    
    UIImageView* tips = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IMG_INFO_TIPS_ICON]];
    
    if (lines == 1) {
        [tips setFrame:CGRectMake(16.0, 18.0, tips.frame.size.width, tips.frame.size.height)];
        [hint setFrame:CGRectMake(42, 18, 250, 18)];
        hint.textAlignment = NSTextAlignmentLeft;
    } else if (lines == 2) {
        [tips setFrame:CGRectMake(16.0, 10.0, tips.frame.size.width, tips.frame.size.height)];
        [hint setFrame:CGRectMake(42, 10, 250, 36)];
        hint.textAlignment = NSTextAlignmentLeft;
    }else if (lines == 3){
        [tips setFrame:CGRectMake(16.0, 10.0, tips.frame.size.width, tips.frame.size.height)];
        [hint setFrame:CGRectMake(42, 4, 250, 50)];
        hint.font = [UIFont fontWithName:FONT_TYPE size:FONT_0];
        hint.textAlignment = NSTextAlignmentLeft;
    }
    
    [hintView addSubview:tips];
    [hintView addSubview:hint];
    
    return hintView;
}


+(void) setCustomBarButtonTitle:(UIBarButtonItem *)barBtn title:(NSString*) title
{
    if ([barBtn.customView isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)barBtn.customView;
        [btn setTitle:title forState:UIControlStateNormal];
    }
}


+ (void)setBorder:(UIView *)view Color:(UIColor *)color{
    [view.layer setBorderWidth:0.5f];
    [view.layer setBorderColor:color.CGColor];
}

+(void) setShadow:(UINavigationBar *)navBar
{
    navBar.layer.shadowOpacity = 0.4;
    navBar.layer.shadowOffset = CGSizeMake(0, 0);
    navBar.layer.shadowColor = [UIColor blackColor].CGColor;
    navBar.layer.shadowRadius = 2;
}

+(UIColor*) getInputedColor
{
    return [UIColor blackColor];
    
}
+(UIColor*) getNotInputedColor
{
    return [UIColor redColor];
}


+(UIColor*) getUnSelectedColor
{
    return RGBCOLOR(247, 247, 247);
}

+(UIColor*) getSelectedColor
{
    return RGBCOLOR(79, 63, 54);
}


+ (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
