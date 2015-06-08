//
//  Util.h
//  imdPad
//
//  Created by 8fox on 7/8/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_FAV_COUNTS  5

@interface Util : NSObject {
    
}

+ (BOOL)isHtml:(NSString *)aString;
+ (NSString *)loadFileData:(NSString *)filePath;
+ (void)initFavorateIndex;
+ (int)getNextAvailableSaveSlot;
+ (BOOL)addFavorateWithSearchKey:(NSString*)key andTitle:(NSString*)title;
+ (NSString *)md5:(NSString*)rawString;
+ (NSString*)URLencode:(NSString *)originalString
       stringEncoding:(NSStringEncoding)stringEncoding;
+ (NSString*)replaceEM:(NSString*)rawStr LeftMark:(NSString*)lStr RightMark:(NSString*)rStr;

+ (NSString*)stringWithHexBytes:(NSData*) theData;
+ (NSData*)dataFromHexString:(NSString*)hexString;
+ (void)DeleteAllInPath:(NSString *)path withExtention:(NSString*)fileExtenstion;
+ (NSString*)stringURLDecoding:(NSString*)str;
+ (BOOL)phoneNumberJudge:(NSString*)number;
+ (NSString *)getMacAddress;
+ (NSString *)getUsername;
+ (NSString *)getSystemDate;
//+(NSDate *)getStringToDate:(NSString *)YYYY-MM-DD
+ (NSString *)arrayToString:(NSArray *)array sep:(NSString *)sep;
+ (BOOL)checkArrayContentWithString:(NSArray *)array;
@end
