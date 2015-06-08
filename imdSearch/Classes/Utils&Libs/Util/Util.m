//
//  Util.m
//  imdPad
//
//  Created by 8fox on 7/8/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import "Util.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIDevice+IdentifierAddition.h"

@implementation Util

+(BOOL)isHtml:(NSString *)aString;
{
    if(aString == nil) return NO;
    
    if ([aString rangeOfString:@"<html>"].location!= NSNotFound && [aString rangeOfString:@"</html>"].location!= NSNotFound)
    {
        //NSLog(@"%d",[aString rangeOfString:@"<html>"].location);
        //NSLog(@"yes %@",aString);
        return YES;
    }
    
    
    return NO;
}

+(NSString *)loadFileData:(NSString *)filePath
{
    NSData* fileData = [NSData dataWithContentsOfFile:filePath];
    
    
    NSString* a =[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    
    return a;
    
}

+(void)initFavorateIndex
{
    NSMutableDictionary* favPlist = [[NSMutableDictionary alloc] initWithCapacity:20];
    int fav_currentCount =0;
    
    [[NSUserDefaults standardUserDefaults] setInteger:fav_currentCount forKey:@"fav_currentCount"];
    [[NSUserDefaults standardUserDefaults] setObject:favPlist forKey:@"fav_Index"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //[favPlist release];
}




+(int)getNextAvailableSaveSlot
{
    int n = [[[NSUserDefaults standardUserDefaults] valueForKey:@"fav_currentCount"] intValue];
    if(n < MAX_FAV_COUNTS) return n;
    return -1;
}

+(BOOL)addFavorateWithSearchKey:(NSString*)key andTitle:(NSString*)title
{
    int n = [Util getNextAvailableSaveSlot];
    if(n > -1)
    {
        NSMutableDictionary* favPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"fav_Index"];
        
        [favPlist setObject:key forKey:[NSString stringWithFormat:@"Key_%03d",n]];
        [favPlist setObject:title forKey:[NSString stringWithFormat:@"Title_%03d",n]];
        
        [[NSUserDefaults standardUserDefaults] setInteger:n+1 forKey:@"fav_currentCount"];
        [[NSUserDefaults standardUserDefaults] setObject:favPlist forKey:@"fav_Index"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return YES;
    }
    else
    {
        return NO;
    }
}

+(NSString *) md5:(NSString*)rawString
{
    const char *cStr = [rawString UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [[NSString stringWithFormat:
             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] uppercaseString];
}

+(NSString*)URLencode:(NSString *)originalString
       stringEncoding:(NSStringEncoding)stringEncoding {
    //!  @  $  &  (  )  =  +  ~  `  ;  '  :  ,  /  ?
    //%21%40%24%26%28%29%3D%2B%7E%60%3B%27%3A%2C%2F%3F
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
                            @"@" , @"&" , @"=" , @"+" ,    @"$" , @"," ,
                            @"!", @"'", @"(", @")", @"*", nil];
    
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F", @"%3F" , @"%3A" ,
                             @"%40" , @"%26" , @"%3D" , @"%2B" , @"%24" , @"%2C" ,
                             @"%21", @"%27", @"%28", @"%29", @"%2A", nil];
    
    int len = [escapeChars count];
    
    NSMutableString *temp = [[originalString
                              stringByAddingPercentEscapesUsingEncoding:stringEncoding]
                             mutableCopy];
    
    int i;
    for (i = 0; i < len; i++)
    {
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    NSString *outStr;
    if (temp == nil) {
        outStr = nil;
    }else {
        outStr = [NSString stringWithString: temp];
    }
    return outStr;
}

+(NSString*)replaceEM:(NSString*)rawStr LeftMark:(NSString*)lStr RightMark:(NSString*)rStr
{
    NSString *s;
    s = [rawStr stringByReplacingOccurrencesOfString:@"<em>"
                                          withString:lStr];
    
    s = [s stringByReplacingOccurrencesOfString:@"</em>"
                                     withString:rStr];
    
    //NSLog(@"s = %@",s);
    
    return s;
}

+(NSString*)stringWithHexBytes:(NSData*) theData
{
	static const char hexdigits[] = "0123456789ABCDEF";
	const size_t numBytes = [theData length];
	const unsigned char* bytes = [theData bytes];
	char *strbuf = (char *)malloc(numBytes * 2 + 1);
	char *hex = strbuf;
	NSString *hexBytes = nil;
    
	for (int i = 0; i<numBytes; ++i) {
		const unsigned char c = *bytes++;
		*hex++ = hexdigits[(c >> 4) & 0xF];
		*hex++ = hexdigits[(c ) & 0xF];
	}
	*hex = 0;
	hexBytes = [NSString stringWithUTF8String:strbuf];
	free(strbuf);
	return hexBytes;
}

+(NSData*)dataFromHexString:(NSString*)hexString
{
    NSMutableData *data= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int count = [hexString length]/2;
    int i;
    for (i=0; i < count; i++) {
        byte_chars[0] = [hexString characterAtIndex:i*2];
        byte_chars[1] = [hexString characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    NSLog(@"%@", data);
    return data;
    
}

+(void)DeleteAllInPath:(NSString *)path withExtention:(NSString*)fileExtenstion
{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    //NSString *directory = [[self documentsDirectory] stringByAppendingPathComponent:@"Photos/"];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:path error:&error]) {
        
        if([[file pathExtension] isEqualToString:fileExtenstion])
        {
            
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", path, file] error:&error];
            if (!success || error) {
                // it failed.
                NSLog(@"del file %@ error",file);
                
                NSLog(@"%@",error);
            }
            else
            {
                NSLog(@"sel file %@/%@ successfully", path ,file);
                
            }
        }
    }
    
    
}

+(NSString*)stringURLDecoding:(NSString*)str
{
    return [[[[[str stringByReplacingOccurrencesOfString: @"&amp;" withString: @"&"]
               stringByReplacingOccurrencesOfString: @"&quot;" withString: @"\""]
              stringByReplacingOccurrencesOfString: @"&#39;" withString: @"'"]
             stringByReplacingOccurrencesOfString: @"&gt;" withString: @">"]
            stringByReplacingOccurrencesOfString: @"&lt;" withString: @"<"];
}

+(BOOL)phoneNumberJudge:(NSString*)number
{
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"^(((13[0-9]{1})|15[0-9]{1}|18[0-9]{1}|)\\d{8})$"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:number
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, number.length)];
    
    if (numberofMatch == 0) {
        return NO;
    } else
        return YES;
}

+ (NSString *)getUsername
{
    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:
                        @"logined"] boolValue];
    if (useLogined) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:
                @"savedUser"];
    } else {
        return @"null";
    }
}

+ (NSString *)getSystemDate{
    
    return @"";
}

+ (NSString *)getMacAddress
{
    //  int                 mgmtInfoBase[6];
    //  char                *msgBuffer = NULL;
    //  NSString            *errorFlag = NULL;
    //  size_t              length;
    //
    //    // Setup the management Information Base (mib)
    //  mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    //  mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    //  mgmtInfoBase[2] = 0;
    //  mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    //  mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    //
    //    // With all configured interfaces requested, get handle index
    //  if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
    //    errorFlag = @"if_nametoindex failure";
    //    // Get the size of the data available (store in len)
    //  else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
    //    errorFlag = @"sysctl mgmtInfoBase failure";
    //    // Alloc memory based on above call
    //  else if ((msgBuffer = malloc(length)) == NULL)
    //    errorFlag = @"buffer allocation failure";
    //    // Get system information, store in buffer
    //  else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
    //    {
    //    free(msgBuffer);
    //    errorFlag = @"sysctl msgBuffer failure";
    //    }
    //  else
    //    {
    //      // Map msgbuffer to interface message structure
    //    struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    //
    //      // Map to link-level socket structure
    //    struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    //
    //      // Copy link layer address data in socket structure to an array
    //    unsigned char macAddress[6];
    //    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    //
    //      // Read from char array into a string object, into traditional Mac address format
    //    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
    //                                  macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
    //    NSLog(@"Mac Address: %@", macAddressString);
    //
    //      // Release the buffer memory
    //    free(msgBuffer);
    //
    //    return macAddressString;
    //    }
    //
    //    // Error...
    //  NSLog(@"Error: %@", errorFlag);
    //
    //  return errorFlag;
    NSString* mac = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSLog(@"mac:%@", mac);
    return mac;
}

+(NSString *)arrayToString:(NSArray *)array sep:(NSString *)sep
{
    if (![array count]) {
        return nil;
    } else {
        NSString *back = [array objectAtIndex:0];
        for (int i = 1; i < [array count]; i++) {
            back = [NSString stringWithFormat:@"%@%@%@",back,sep,[array objectAtIndex:i]];
        }
        return back;
    }
}

+(BOOL)checkArrayContentWithString:(NSArray *)array
{
    BOOL haveContent = true;
    if ([array count] == 1) {
        NSString *ss = [array objectAtIndex:0];
        if (ss == nil || [ss isEqualToString:@""]) {
            haveContent = false;
        }
    }
    return haveContent;
}

@end
