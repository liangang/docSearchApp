//
//  searchMainUtils.m
//  imdSearch
//
//  Created by xiangzhang on 4/15/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#import "searchMainUtils.h"

#import "Util.h"

@implementation searchMainUtils

+ (NSString*) fileNameWithExternelId:(NSString*)externelId {
    NSString* fileId =[Util md5:externelId];
    NSString* fileName = [NSString stringWithFormat:@"%@.pdf",fileId];
    return fileName;
}

+ (NSString*)filePathInCache:(NSString *)fileName {
    NSString *filePath =
    [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:fileName];
    NSLog(@"filePath %@",filePath);
    return filePath;
}

+ (NSString*)filePathInDocuments:(NSString*)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}


+ (NSDictionary*)readPListBundleFile:(NSString*)fileName {
	NSString *plistPath;
	plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	
	NSMutableDictionary* temp =[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
	if (!temp) {
		NSLog(@"Error reading plist of %@",fileName);
	}
	
	return temp;
}
@end
