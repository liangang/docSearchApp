//
//  UIDevice(Identifier).m
//  UIDeviceAddition
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import "UIDevice+IdentifierAddition.h"
#import "NSString+MD5Addition.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

static const char kKeychainUDIDItemIdentifier[]  = "UUID";
static const char kKeyChainUDIDAccessGroup[] = "H29PF46Z8J.com.i-md.imdSearch";
@interface UIDevice(Private)

- (NSString *) macaddress;

@end

@implementation UIDevice (IdentifierAddition)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *) macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (NSString *) uniqueDeviceIdentifier
{
  NSString *sysVersion = [UIDevice currentDevice].systemVersion;
  CGFloat version = [sysVersion floatValue];
  
  if (version >= 7.0)
  {
    return [self _UDID_iOS7];
  }
  else if (version >= 2.0)
  {
    return [self _UDID_iOS6];
  }
  return nil;
}
/*
 * iOS 6.0
 * use wifi's mac address
 */
- (NSString*)_UDID_iOS6
{
  NSString *macaddress = [[UIDevice currentDevice] macaddress];
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  
  NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
  NSString *uniqueIdentifier = [stringToHash stringFromMD5];
  
  return uniqueIdentifier;
}

/*
 * iOS 7.0
 * Starting from iOS 7, the system always returns the value 02:00:00:00:00:00
 * when you ask for the MAC address on any device.
 * use identifierForVendor + keyChain
 * make sure UDID consistency atfer app delete and reinstall
 */
- (NSString*)_UDID_iOS7
{
    //[self removeUDIDFromKeyChain];
  NSString *udid = [self getUDIDFromKeyChain];
  if (!udid)
  {
    udid = [[UIDevice currentDevice].identifierForVendor UUIDString];
    [self settUDIDToKeyChain:udid];
  }
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
  NSString *stringToHash = [NSString stringWithFormat:@"%@%@",udid,bundleIdentifier];
  NSString *uniqueIdentifier = [stringToHash stringFromMD5];
    
  return uniqueIdentifier;
}

- (NSString *) uniqueGlobalDeviceIdentifier{
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *uniqueIdentifier = [macaddress stringFromMD5];
    
    return uniqueIdentifier;
}
#pragma mark -
#pragma mark Helper Method for make identityForVendor consistency

- (NSString*)getUDIDFromKeyChain
{
  NSMutableDictionary *dictForQuery = [[NSMutableDictionary alloc] init];
  [dictForQuery setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
  
    // set Attr Description for query
  [dictForQuery setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]
                  forKey:kSecAttrDescription];
  
    // set Attr Identity for query
  NSData *keychainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier
                                          length:strlen(kKeychainUDIDItemIdentifier)];
  [dictForQuery setObject:keychainItemID forKey:(id)kSecAttrGeneric];
  
    // The keychain access group attribute determines if this item can be shared
    // amongst multiple apps whose code signing entitlements contain the same keychain access group.
  NSString *accessGroup = [NSString stringWithUTF8String:kKeyChainUDIDAccessGroup];
  if (accessGroup != nil)
  {
#if TARGET_IPHONE_SIMULATOR
      // Ignore the access group if running on the iPhone simulator.
      //
      // Apps that are built for the simulator aren't signed, so there's no keychain access group
      // for the simulator to check. This means that all apps can see all keychain items when run
      // on the simulator.
      //
      // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
      // simulator will return -25243 (errSecNoAccessForItem).
#else
    [dictForQuery setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
  }
  
  [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecMatchCaseInsensitive];
  [dictForQuery setValue:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
  [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
  
  OSStatus queryErr   = noErr;
  NSData   *udidValue = nil;
  NSString *udid      = nil;
  queryErr = SecItemCopyMatching((CFDictionaryRef)dictForQuery, (CFTypeRef*)&udidValue);
  
  NSMutableDictionary *dict = nil;
  [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
  queryErr = SecItemCopyMatching((CFDictionaryRef)dictForQuery, (CFTypeRef*)&dict);
  
  if (queryErr == errSecItemNotFound)
  {
    NSLog(@"KeyChain Item: %@ not found!!!", [NSString stringWithUTF8String:kKeychainUDIDItemIdentifier]);
  }
  else if (queryErr != errSecSuccess)
  {
    NSLog(@"KeyChain Item query Error!!! Error code:%ld", queryErr);
  }
  if (queryErr == errSecSuccess)
  {
    NSLog(@"KeyChain Item: %@", udidValue);
    
    if (udidValue)
    {
      udid = [NSString stringWithUTF8String:udidValue.bytes];
    }
  }
  
  [dictForQuery release];
  return udid;
}

- (BOOL)settUDIDToKeyChain:(NSString*)udid
{
  NSMutableDictionary *dictForAdd = [[NSMutableDictionary alloc] init];
  
  [dictForAdd setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
  [dictForAdd setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier] forKey:kSecAttrDescription];
  
  [dictForAdd setValue:@"UUID" forKey:(id)kSecAttrGeneric];
  
    // Default attributes for keychain item.
  [dictForAdd setObject:@"" forKey:(id)kSecAttrAccount];
  [dictForAdd setObject:@"" forKey:(id)kSecAttrLabel];
  
  
    // The keychain access group attribute determines if this item can be shared
    // amongst multiple apps whose code signing entitlements contain the same keychain access group.
  NSString *accessGroup = [NSString stringWithUTF8String:kKeyChainUDIDAccessGroup];
  if (accessGroup != nil)
  {
#if TARGET_IPHONE_SIMULATOR
      // Ignore the access group if running on the iPhone simulator.
      //
      // Apps that are built for the simulator aren't signed, so there's no keychain access group
      // for the simulator to check. This means that all apps can see all keychain items when run
      // on the simulator.
      //
      // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
      // simulator will return -25243 (errSecNoAccessForItem).
#else
    [dictForAdd setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
  }
  
  const char *udidStr = [udid UTF8String];
  NSData *keyChainItemValue = [NSData dataWithBytes:udidStr length:strlen(udidStr)];
  [dictForAdd setValue:keyChainItemValue forKey:(id)kSecValueData];
  
  OSStatus writeErr = noErr;
  if ([self getUDIDFromKeyChain])
  {        // there is item in keychain
    [self updateUDIDInKeyChain:udid];
    [dictForAdd release];
    return YES;
  }
  else
  {          // add item to keychain
    writeErr = SecItemAdd((CFDictionaryRef)dictForAdd, NULL);
    if (writeErr != errSecSuccess)
    {
      NSLog(@"Add KeyChain Item Error!!! Error Code:%ld", writeErr);
      
      [dictForAdd release];
      return NO;
    }
    else
    {
      NSLog(@"Add KeyChain Item Success!!!");
      [dictForAdd release];
      return YES;
    }
  }
  
  [dictForAdd release];
  return NO;
}

- (BOOL)removeUDIDFromKeyChain
{
  NSMutableDictionary *dictToDelete = [[NSMutableDictionary alloc] init];
  
  [dictToDelete setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
  
  NSData *keyChainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier length:strlen(kKeychainUDIDItemIdentifier)];
  [dictToDelete setValue:keyChainItemID forKey:(id)kSecAttrGeneric];
  
  OSStatus deleteErr = noErr;
  deleteErr = SecItemDelete((CFDictionaryRef)dictToDelete);
  if (deleteErr != errSecSuccess)
  {
    NSLog(@"delete UUID from KeyChain Error!!! Error code:%ld", deleteErr);
    [dictToDelete release];
    return NO;
  }
  else
  {
    NSLog(@"delete success!!!");
  }
  
  [dictToDelete release];
  return YES;
}

- (BOOL)updateUDIDInKeyChain:(NSString*)newUDID
{
  
  NSMutableDictionary *dictForQuery = [[NSMutableDictionary alloc] init];
  
  [dictForQuery setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
  
  NSData *keychainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier
                                          length:strlen(kKeychainUDIDItemIdentifier)];
  [dictForQuery setValue:keychainItemID forKey:(id)kSecAttrGeneric];
  [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecMatchCaseInsensitive];
  [dictForQuery setValue:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
  [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
  
  NSDictionary *queryResult = nil;
  SecItemCopyMatching((CFDictionaryRef)dictForQuery, (CFTypeRef*)&queryResult);
  if (queryResult)
  {
    
    NSMutableDictionary *dictForUpdate = [[NSMutableDictionary alloc] init];
    [dictForUpdate setValue:[NSString stringWithUTF8String:kKeychainUDIDItemIdentifier] forKey:kSecAttrDescription];
    [dictForUpdate setValue:keychainItemID forKey:(id)kSecAttrGeneric];
    
    const char *udidStr = [newUDID UTF8String];
    NSData *keyChainItemValue = [NSData dataWithBytes:udidStr length:strlen(udidStr)];
    [dictForUpdate setValue:keyChainItemValue forKey:(id)kSecValueData];
    
    OSStatus updateErr = noErr;
    
      // First we need the attributes from the Keychain.
    NSMutableDictionary *updateItem = [NSMutableDictionary dictionaryWithDictionary:queryResult];
    
      // Second we need to add the appropriate search key/values.
      // set kSecClass is Very important
    [updateItem setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    updateErr = SecItemUpdate((CFDictionaryRef)updateItem, (CFDictionaryRef)dictForUpdate);
    if (updateErr != errSecSuccess)
    {
      NSLog(@"Update KeyChain Item Error!!! Error Code:%ld", updateErr);
      
      [dictForQuery release];
      [dictForUpdate release];
      return NO;
    }
    else
    {
      NSLog(@"Update KeyChain Item Success!!!");
      [dictForQuery release];
      [dictForUpdate release];
      return YES;
    }
  }
  [dictForQuery release];
  return NO;
}
@end
