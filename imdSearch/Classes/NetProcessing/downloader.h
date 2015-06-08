//
//  downloader.h
//  imdPad
//
//  Created by 8fox on 6/8/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//


#import "ASIHTTPRequest.h"


#define SEARCHING_FULLDOCUMENT 0
#define MEETING_SLIDERS 1


@interface downloader : ASIHTTPRequest {
    
    int downloadType;
    
    int retryingTimes;
    int retryingMaxTimes;
    
    NSString* fileName;
    NSString* fileURL;
    NSString* filePath;
    
}

+ (id)requestWithURL:(NSURL *)newURL;

@property (readwrite)   int downloadType;

@property (readwrite)   int retryingTimes;
@property (readwrite)   int retryingMaxTimes;

@property (nonatomic, retain) NSString* fileName;
@property (nonatomic, retain) NSString* filePath;
@property (nonatomic, retain) NSString* fileURL;

@end
