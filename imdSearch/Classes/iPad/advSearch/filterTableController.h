//
//  filterTableController.h
//  imdPad
//
//  Created by 8fox on 6/14/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class filterTableController;


@interface filterTableController : UITableViewController {
    
    id delegate;
    NSMutableArray* filterDataEN;
    NSMutableArray* filterDataCN;
    NSString* filterString;
    
    int searchLanguage;
    int tag;
}

@property (nonatomic, retain) NSString* filterString;
@property (nonatomic, retain) id delegate;
@property (readwrite) int searchLanguage;
@property (readwrite) int tag;

- (NSDictionary*)readPListBundleFile:(NSString*)fileName;
@end
