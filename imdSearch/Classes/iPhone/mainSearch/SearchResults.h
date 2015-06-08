//
//  SearchResults.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-21.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@interface SearchResults : UIViewController <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate, UIPickerViewDelegate, UIPickerViewDataSource,UIActionSheetDelegate>
{
}

@property (nonatomic, assign) NSInteger pickerSelected;;
@property (nonatomic, retain) UIActionSheet *sortAS;
@property (nonatomic, retain) NSArray *pickerViewArray;
@property (nonatomic, retain) NSArray *pickerSortArray;

@property (nonatomic, retain) UIPickerView *sortPicker;

@property (nonatomic, retain) ASIHTTPRequest *httpRequest;

@property (nonatomic, retain) NSMutableArray *resultsArray;
@property (nonatomic, retain) NSString *queryStr;

@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger sort;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger lastRequestCount;

@property (nonatomic, retain) NSString *source;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,retain) IBOutlet UITableView *tableView;
@property (nonatomic,retain) IBOutlet UIView *noResultsView;
@property (nonatomic,retain) UIAlertView *alertView;
@property (nonatomic, strong) UIView *pickerView;
-(void) loadMore:(NSMutableArray *)data;

-(void) popBack;

-(void) sortSearch:(id) sender;
-(void) createSortPicker;
- (CGRect)pickerFrameWithSize:(CGSize)size;

-(void) updateSortPicker:(int)sort;

@end
