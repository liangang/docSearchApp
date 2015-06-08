//
//  yearTableController.h
//  imdPad
//
//  Created by 8fox on 6/14/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface yearTableController : UITableViewController {
    
    NSMutableArray* yearData;
    id delegate;
}

@property (nonatomic,retain) id delegate;

@end
