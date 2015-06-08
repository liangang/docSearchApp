//
//  askFullTextViewController.h
//  imdSearch
//
//  Created by 立纲 吴 on 12/19/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface askFullTextViewController : UIViewController
{
    id delegate;
}

@property (nonatomic,retain) id delegate;
@end
