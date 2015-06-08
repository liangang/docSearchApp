//
//  downloader.m
//  imdPad
//
//  Created by 8fox on 6/8/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import "downloader.h"


@implementation downloader
@synthesize downloadType;

@synthesize  retryingTimes;
@synthesize  retryingMaxTimes;

@synthesize fileName;
@synthesize filePath;
@synthesize fileURL;


- (id)initWithURL:(NSURL *)newURL
{
    self = [super initWithURL:newURL];
    return self;
}

+ (id)requestWithURL:(NSURL *)newURL
{
	return [[self alloc] initWithURL:newURL];
}

@end
