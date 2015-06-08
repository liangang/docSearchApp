//
//  UserAuth.m
//  imdSearch
//
//  Created by Huajie Wu on 11-11-25.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import "UserAuth.h"

#import "Base64.h"
#import <Security/Security.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Util.h"
#import "JSON.h"
#import "imdSearchAppDelegate.h"
#import "UrlRequest.h"
#import "ImdUrlPath.h"
#import "UIDevice+IdentifierAddition.h"

#import "ImdAppBehavior.h"
#import "Util.h"
#import "ISBaseInfoManager.h"

static const UInt8 publicKeyIdentifier_p[] = "com.i-md.ios.imdauthM.publickey\0";
static const UInt8 privateKeyIdentifier_p[] = "com.i-md.ios.imdauthM.privatekey\0";
static const UInt8 serverPublicKeyIdentifier_p[] = "com.i-md.ios.imdauthM.serverPublickey\0";

static unsigned char oidSequence_p[] = { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00 };


size_t encodeLength_p(unsigned char * buf, size_t length);

size_t encodeLength_p(unsigned char * buf, size_t length)
{
    
    // encode length in ASN.1 DER format
    if (length < 128) {
        buf[0] = length;
        return 1;
    }
    
    size_t i = (length / 256) + 1;
    buf[0] = i + 0x80;
    for (size_t j = 0 ; j < i; ++j)
    {
        buf[i - j] = length & 0xFF;
        length = length >> 8;
    }
    
    return i + 1;
}



@implementation UserAuth
@synthesize imdToken,clientId,serverString,serverData, delegate;
@synthesize fromRegister;

-(id)init
{
    self =[super init];
    
    if(self!=nil)
    {
        self.imdToken = @"";
        
        NSString* deviceId = [[UIDevice currentDevice] uniqueDeviceIdentifier];
        // self.clientId = deviceId;
        self.clientId = [NSString stringWithFormat:@"%@ID",deviceId];
        
        self.clientId = [self.clientId stringByReplacingOccurrencesOfString:@"-"
                                                                 withString:@""];
        self.fromRegister = NO;
        //self.clientId = @"ABC0000MMM";
        
        regFinishVC = [[registerFinishViewController alloc] init];
        //[self testKeyPair];
        //NSLog(@"end of the test!!!");
    }
    
    return self;
}

-(void)dealloc
{
    [clientId release];
    [imdToken release];
    [serverString release];
    [serverData release];
    [regFinishVC release];
    [super dealloc];
    
}

#pragma mark - check app version.
-(void)checkAppVersion
{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    [dic setObject:@"iphone doc search" forKey:@"appName"];
    [dic setObject:version forKey:@"appVersion"];
    [dic setObject:@"uuid" forKey:@"uuid"];
    
    NSMutableDictionary* userInfo = [[[NSMutableDictionary alloc] init] autorelease];
    [userInfo setObject:@"checkVersion" forKey:@"checkVersion"];
    
    [UrlRequest sendPostWithUserInfo:[ImdUrlPath appVersionUrl] data:dic userInfo:userInfo delegate:self];
    
    [dic release];
    //authStep = AUTHSTEP_CHECK_APPVERSION;
}

#pragma mark - auth progress
-(void)firstLogin
{
    NSString* keygened =[[NSUserDefaults standardUserDefaults] objectForKey:@"keygened"];
    if(![keygened isEqualToString:@"YES"])
    {
        [self generateKeyPair];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"keygened"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self postDeviceInfo];
}

-(void)testKeyPair
{
    NSLog(@"pub key = %@",[self getPublicKeyX509Formatted:YES useServerKey:NO]);
    NSLog(@"pri key = %@",[self getPKCS1FormattedPrivateKey]);
    
    NSString* plainText =@"{\"username\":\"test\",\"password\":\"test\",\"clientId\":\"A000002441010A\"}";
    
    plainText =@"ABCDEF00001234";
    
    NSLog(@"\nEncrypted String:\n%@\n\n",plainText);
    NSString *base64EncodedString = [self encryptWithPublicKey:plainText useServerKey:NO Base64OrHex:YES];
    NSLog(@"\nDecrypted String1:\n%@\n\n",[self decryptWithPrivateKey:base64EncodedString]);
    
}

-(void)requireToken
{
    [self postRequestString];
}

- (void)postDeviceInfo
{
    NSString* urlString = [NSString stringWithFormat:@"http://%@/client/auth/firstLogin",MY_AUTH_SERVER];
    
    NSString* clientMd5 =[ Util md5:self.clientId];
    NSString* pubKey = [self getPublicKeyX509Formatted:YES useServerKey:NO];
    
    //pubKey = [Util URLencode:pubKey stringEncoding:NSUTF8StringEncoding];
    
    NSLog(@"post device info %@",urlString);
    ASIFormDataRequest* authRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    
    [authRequest setPostValue:clientMd5 forKey:@"clientIdMd5"];
    [authRequest setPostValue:pubKey forKey:@"clientPublicKey"];
    authRequest.delegate = self;
    
    [authRequest startAsynchronous];
    
    NSLog(@"posting pub key %@",pubKey);
    NSLog(@"posting client md5 %@",clientMd5);
    authStep = AUTHSTEP_POSTING_DEVICEID;
    
}

- (void)doLogin:controller fromRegister:(BOOL)from
{
    self.fromRegister = from;
    self.delegate = controller;
    [self postDeviceInfo];
}


- (void)postAuthInfo
{
    NSString* urlString = [NSString stringWithFormat:@"http://%@/client/auth/postInfo",MY_AUTH_SERVER];
    
    NSString* userString = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
    //@"imdtest4";
    NSString* passString = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedPass"];
    //@"test1234";
    
    
    //NSString* userString = @"imdtest4";
    //NSString* passString = @"test1234";
    
    NSString* userInfoRawString = [NSString stringWithFormat:@"{\"username\":\"%@\",\"password\":\"%@\",\"clientId\":\"%@\"}",userString,passString,self.clientId];
    
    NSString* userInfoMd5 = [Util md5:userInfoRawString];
    NSString* userInfoEncryptedString =[self encryptWithPublicKey:userInfoRawString useServerKey:YES Base64OrHex:NO];
    
    NSLog(@"userinfo= %@ len =%d",userInfoRawString,userInfoRawString.length);
    NSLog(@"userinfo md5 =%@",userInfoMd5);
    NSLog(@"encrypted userinfo =%@",userInfoEncryptedString);
    
    ASIFormDataRequest* authRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [authRequest setPostValue: userInfoEncryptedString forKey:@"keyUserInfo"];
    [authRequest setPostValue:userInfoMd5 forKey:@"md5UserInfo"];
    [authRequest setPostValue:@"IPhone" forKey:@"device"];
    
    authRequest.delegate = self;
    [authRequest startAsynchronous];
    
    authStep = AUTHSTEP_POSTING_AUTHINFO;
}

- (void)postRequestString
{
    NSLog(@"requesting string");
    NSString* urlString = [NSString stringWithFormat:@"http://%@/client/auth/requestToken",MY_AUTH_SERVER];
    
    ASIFormDataRequest* authRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSString* clientIdString = [self encryptWithPublicKey:self.clientId useServerKey:YES Base64OrHex:NO];
    
    
    [authRequest setPostValue:clientIdString forKey:@"keyClientId"];
    
    authRequest.delegate = self;
    
    [authRequest startAsynchronous];
    
    authStep =  AUTHSTEP_REQUESTOKEN_GET_STRING;
    
}
- (void)postRequestToken
{
    
    NSLog(@"requesting token");
    NSString* urlString = [NSString stringWithFormat:@"http://%@/client/auth/authStr",MY_AUTH_SERVER];
    
    ASIFormDataRequest* authRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSString* clientIdString = [self encryptWithPublicKey:self.clientId useServerKey:YES Base64OrHex:NO];
    
    //NSString* keyStr =  [self encryptWithPublicKey:self.serverString useServerKey:YES Base64OrHex:NO];
    
    NSString* keyStr2 = [self encryptWithPublicKeyOnData:self.serverData useServerKey:YES Base64OrHex:NO];
    
    
    [authRequest setPostValue:clientIdString forKey:@"keyClientId"];
    [authRequest setPostValue:keyStr2 forKey:@"keyStr"];
    [authRequest setPostValue:@"IPhone" forKey:@"device"];
    
    
    authRequest.delegate = self;
    
    [authRequest startAsynchronous];
    
    authStep =  AUTHSTEP_REQUESTOKEN_GET_TOKEN;
    
}

#pragma mark - request delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"request finished %@",[request responseString]);
    NSLog(@"%d",[request responseStatusCode]);
    NSDictionary* userInfo =[request userInfo];
    NSString* check =[userInfo objectForKey:@"checkVersion"];
    
    if ([check isEqualToString:@"checkVersion"]) {
        //    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        //
        //    NSDictionary* results = [UrlRequest getJsonValue:request];
        //    NSString* latest = [results objectForKey:@"lastestVersion"];
        //    NSString* forceUpdate = [results objectForKey:@"forceUpdate"];
        
        //[appDelegate versionChecked:latest forceUpdate:[forceUpdate boolValue]];
        return;
    }
    
    else if(authStep == AUTHSTEP_POSTING_DEVICEID) {
        NSString* sevPublicKeyString = [request responseString];
        
        BOOL gotPubKeyOk = [self setPublicKey:sevPublicKeyString isX509Formatted:YES serverKey:YES];
        
        if(gotPubKeyOk)
        {
            //next step post auth info
            NSLog(@"post deviceid ok");
            // [self postAuthInfo];
            // authStep = AUTHSTEP_POSTING_AUTHINFO;
            BOOL temp = YES;
            [ISBaseInfoManager setFirstOpenInCurrentVersion:temp];
            
            authStep = AUTHSTEP_IDLE;
            
            imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [appDelegate firstLoginFinished];
            NSString* userString = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
            if (userString.length > 0) {
                [self postAuthInfo];
            }
        }
        else
        {
            NSLog(@"post deviceid failed");
            authStep = AUTHSTEP_IDLE;
            //s2
            
            imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate firstLoginFailed];
        }
    }
    
    else if (authStep == AUTHSTEP_POSTING_AUTHINFO)
    {
        NSString* responseString =[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        
        NSLog(@"ok %@",responseString);
        
        NSDictionary* info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 )
        {
            info =nil;
            
        }
        else
        {
            info =[responseString JSONValue];
        }
        
        
        if(info != nil) {
            NSString* status = [info objectForKey:@"status"];
            
            if ([status isEqualToString:@"false"] || ![[info objectForKey:@"result"] isEqualToString:@"Correct"]) {
                NSLog(@"Login Failed, status: %@", status);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"userLoginInfo" object:[info objectForKey:@"result"]];
                
                imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate userLoginFailed];
            } else {
                self.imdToken = [info objectForKey:@"imdToken"];
                NSLog(@"token ok %@",self.imdToken);
                
                NSString* pubKey = [info objectForKey:@"serverPublicKey"];
                [ISBaseInfoManager saveUserInfoId:[info objectForKey:@"uid"]];
                
                BOOL gotPubKeyOk = [self setPublicKey:pubKey isX509Formatted:YES serverKey:YES];
                
                if(gotPubKeyOk) {
                    //next step post auth info
                    NSLog(@"set new serverKey ok");
                    
                    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate userLoginFinished:!self.fromRegister];
                    
                    if (self.fromRegister) {
                        if ([self.delegate respondsToSelector:@selector(userLoginFinished:)])
                            [self.delegate userLoginFinished:YES];
                    }
                } else {
                    NSLog(@"set new serverKey failed");
                    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate userLoginFailed];
                }
            }
        }
        else
        {
            NSLog(@"sth is wrong with json");
            
            imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
            [self.delegate dismissModalViewControllerAnimated:YES];
            appDelegate.loginFail = YES;
            if (self.fromRegister) {
                [appDelegate registerloginFailed];
                self.fromRegister = NO;
            }else
            {
                [appDelegate userLoginFailed];
            }
        }
        authStep = AUTHSTEP_IDLE;
        
        [responseString release];//*/
        
        
    }
    else if(authStep == AUTHSTEP_REQUESTOKEN_GET_STRING)
    {
        if ([request responseStatusCode] != 200) {
            imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate requestTokenFailed];
            return;
        }
        NSString* responseString =[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        NSLog(@"get string");
        NSLog(@"ok %@",responseString);
        NSData* data = [Util dataFromHexString:responseString];
        NSString* text = [Base64 encode:data];
        
        self.serverString =[self decryptWithPrivateKey:text];
        
        
        NSLog(@"de str =%@",self.serverString);
        
        //if(self.serverString!= nil)
        {
            [self postRequestToken];
            authStep = AUTHSTEP_REQUESTOKEN_GET_TOKEN;
            
        }
        //else
        //{
        //    NSLog(@"post string failed");
        //    authStep = AUTHSTEP_IDLE;
        
        //}
        [responseString release];
        
        
    }
    else if(authStep == AUTHSTEP_REQUESTOKEN_GET_TOKEN)
    {
        NSLog(@"get token?");
        
        NSString* responseString =[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        
        NSLog(@"string %@",[request responseString]);
        NSLog(@"ok %@",responseString);
        
        NSDictionary* info;
        if (responseString ==(id)[NSNull null] || responseString.length ==0 ) {
            info =nil;
        }
        else {
            info =[responseString JSONValue];
        }
        
        if(info != nil)
        {
            self.imdToken = [info objectForKey:@"imdToken"];
            if(self.imdToken!= nil)
            {
                NSLog(@"token ok %@",self.imdToken);
            }
            
            NSString* pubKey = [info objectForKey:@"serverPublicKey"];
            [ISBaseInfoManager saveUserInfoId:[info objectForKey:@"uid"]];
            
            BOOL gotPubKeyOk = [self setPublicKey:pubKey isX509Formatted:YES serverKey:YES];
            
            if(gotPubKeyOk){
                //next step post auth info
                NSLog(@"set new serverKey ok");
                
                imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate requireTokenFinished];
            }
            else
            {
                NSLog(@"set new serverKey failed");
                
                imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate requireTokenFailed];
                
            }
        }
        else
        {
            NSLog(@"sth is wrong with json");
            imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate requireTokenFailed];
        }
        authStep = AUTHSTEP_IDLE;
        
        [responseString release];//*/
    }
}


-(void) requestFailed:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userLoginInfo" object:@"requestFailed"];
    
    NSLog(@"request failed %d",authStep);
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    NSError *error = [request error];
    NSLog(@"error %@",error);
    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate requireTokenFailed];
    if(authStep == AUTHSTEP_POSTING_DEVICEID || authStep == AUTHSTEP_REQUESTOKEN_GET_TOKEN)
    {
        //[appDelegate connectionServerFailed];
    }
    
    authStep = AUTHSTEP_IDLE;
}


#pragma mark - key process functions


-(void)generateKeyPair
{
    NSLog(@"generated key pair");
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
    
    NSData *publicTag = [NSData dataWithBytes:publicKeyIdentifier_p length:strlen((const char *)publicKeyIdentifier_p)];
    NSData *privateTag = [NSData dataWithBytes:privateKeyIdentifier_p length:strlen((const char *)privateKeyIdentifier_p)];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *privateKeyDictionary = [[NSMutableDictionary alloc] init];
    [privateKeyDictionary setObject:(id) kSecClassKey forKey:(id)kSecClass];
    [privateKeyDictionary setObject:(id) kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [privateKeyDictionary setObject:privateTag forKey:(id)kSecAttrApplicationTag];
    SecItemDelete((CFDictionaryRef)privateKeyDictionary);
    
    NSMutableDictionary *publicKeyDictionary = [[NSMutableDictionary alloc] init];
    [publicKeyDictionary setObject:(id) kSecClassKey forKey:(id)kSecClass];
    [publicKeyDictionary setObject:(id) kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [publicKeyDictionary setObject:publicTag forKey:(id)kSecAttrApplicationTag];
    SecItemDelete((CFDictionaryRef)publicKeyDictionary);
    
    [privateKeyDictionary release];
    [publicKeyDictionary release];
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    
    [keyPairAttr setObject:(id)kSecAttrKeyTypeRSA
                    forKey:(id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithInt:2048]
                    forKey:(id)kSecAttrKeySizeInBits];
    
    
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(id)kSecAttrApplicationTag];
    
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(id)kSecAttrApplicationTag];
    
    [keyPairAttr setObject:privateKeyAttr forKey:(id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(id)kSecPublicKeyAttrs];
    
    SecKeyGeneratePair((CFDictionaryRef)keyPairAttr,&publicKey, &privateKey);
    
    if(privateKeyAttr) [privateKeyAttr release];
    if(publicKeyAttr) [publicKeyAttr release];
    if(keyPairAttr) [keyPairAttr release];
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
}


-(NSString *)getPublicKeyX509Formatted:(BOOL)formatBool useServerKey:(BOOL)isServerKey
{
    NSData * publicTag;
    
    if(isServerKey)
    {
        publicTag= [NSData dataWithBytes:serverPublicKeyIdentifier_p length:strlen((const char *)serverPublicKeyIdentifier_p)];
    }
    else
    {
        publicTag= [NSData dataWithBytes:publicKeyIdentifier_p length:strlen((const char *)publicKeyIdentifier_p)];
    }
    
    
    // Now lets extract the public key - build query to get bits
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    
    [queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnData];
    
    NSData * publicKeyBits;
    OSStatus err = SecItemCopyMatching((CFDictionaryRef)queryPublicKey,(CFTypeRef *)&publicKeyBits);
    
    if (err != noErr)
    {
        [queryPublicKey release];
        return nil;
    }
    
    // OK - that gives us the "BITSTRING component of a full DER
    // encoded RSA public key - we now need to build the rest
    
    unsigned char builder[15];
    NSMutableData * encKey = [[NSMutableData alloc] init];
    int bitstringEncLength;
    
    // When we get to the bitstring - how will we encode it?
    if  ([publicKeyBits length ] + 1  < 128 )
        bitstringEncLength = 1 ;
    else
        bitstringEncLength = (([publicKeyBits length ] +1 ) / 256 ) + 2 ;
    
    // Overall we have a sequence of a certain length
    builder[0] = 0x30;    // ASN.1 encoding representing a SEQUENCE
    // Build up overall size made up of -
    // size of OID + size of bitstring encoding + size of actual key
    size_t i = sizeof(oidSequence_p) + 2 + bitstringEncLength + [publicKeyBits length];
    size_t j = encodeLength_p(&builder[1], i);
    
    if (formatBool)
    {
        [encKey appendBytes:builder length:j +1];
        
        // First part of the sequence is the OID
        [encKey appendBytes:oidSequence_p length:sizeof(oidSequence_p)];
        
        // Now add the bitstring
        builder[0] = 0x03;
        j = encodeLength_p(&builder[1], [publicKeyBits length] + 1);
        builder[j+1] = 0x00;
        [encKey appendBytes:builder length:j + 2];
    }
    
    // Now the actual key
    [encKey appendData:publicKeyBits];
    [publicKeyBits release];
    
    // Now translate the result to a Base64 string
    NSString *ret =[Base64 encode:encKey];
    [queryPublicKey release];
    [encKey release];
    return ret;
}

-(NSString *)getPKCS1FormattedPrivateKey
{
    NSData *privateTag = [NSData dataWithBytes:privateKeyIdentifier_p length:strlen((const char *) privateKeyIdentifier_p)];
    
    // Now lets extract the private key - build query to get bits
    NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
    
    [queryPrivateKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnData];
    
    NSData * privateKeyBits;
    OSStatus err = SecItemCopyMatching((CFDictionaryRef)queryPrivateKey,(CFTypeRef *)&privateKeyBits);
    
    if (err != noErr)
    {
        [queryPrivateKey release];
        return nil;
    }
    
    // OK - that gives us the "BITSTRING component of a full DER
    // encoded RSA private key - we now need to build the rest
    
    NSMutableData * encKey = [[NSMutableData alloc] init];
    //NSLog(@"n%@\n\n",[[NSData dataWithBytes:privateKeyBits length:[privateKeyBits length]] description]);
    
    // Now the actual key
    [encKey appendData:privateKeyBits];
    [privateKeyBits release];
    
    // Now translate the result to a Base64 string
    NSString *ret = [Base64 encode:encKey];
    
    [queryPrivateKey release];
    [encKey release];
    return ret;
}

-(BOOL)setPublicKey:(NSString *)keyString isX509Formatted:(BOOL)formatBool serverKey:(BOOL)isServerKey
{
    
    // This will be base64 encoded, decode it.
    NSData *strippedPublicKeyData = [Base64 decode:keyString];
    
    //if (VERBOSE)
    {
        NSLog(@"\nPublic Key Base 64:\n%@\n\n",keyString);
        NSLog(@"\nPublic Key Hexadecimal:\n%@\n\n",[strippedPublicKeyData description]);
    }
    
    
    if (formatBool)
    {
        unsigned char * bytes = (unsigned char *)[strippedPublicKeyData bytes];
        size_t bytesLen = [strippedPublicKeyData length];
        
        size_t i = 0;
        if (bytes[i++] != 0x30)
            return NO;
        
        /* Skip size bytes */
        if (bytes[i] > 0x80)
            i += bytes[i] - 0x80 + 1;
        else
            i++;
        
        if (i >= bytesLen)
            return NO;
        
        if (bytes[i] != 0x30)
            return NO;
        
        /* Skip OID */
        i += 15;
        
        if (i >= bytesLen - 2)
            return NO;
        
        if (bytes[i++] != 0x03)
            return NO;
        
        /* Skip length and null */
        if (bytes[i] > 0x80)
            i += bytes[i] - 0x80 + 1;
        else
            i++;
        
        if (i >= bytesLen)
            return NO;
        
        if (bytes[i++] != 0x00)
            return NO;
        
        if (i >= bytesLen)
            return NO;
        
        strippedPublicKeyData = [NSData dataWithBytes:&bytes[i] length:bytesLen - i];
    }
    
    //if (VERBOSE)
    {
        NSLog(@"\nStripped Public Key Base 64:\n%@\n\n",keyString);
        NSLog(@"\nStripped Public Key Hexadecimal:\n%@\n\n",[strippedPublicKeyData description]);
    }
    
    
    NSData * publicTag;
    if(isServerKey)
    {
        publicTag= [NSData dataWithBytes:serverPublicKeyIdentifier_p length:strlen((const char *)serverPublicKeyIdentifier_p)];
    }
    else
    {
        publicTag= [NSData dataWithBytes:publicKeyIdentifier_p length:strlen((const char *)publicKeyIdentifier_p)];
    }
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(id) kSecClassKey forKey:(id)kSecClass];
    [publicKey setObject:(id) kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [publicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
    SecItemDelete((CFDictionaryRef)publicKey);
    
    CFTypeRef persistKey = nil;
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:strippedPublicKeyData forKey:(id)kSecValueData];
    [publicKey setObject:(id) kSecAttrKeyClassPublic forKey:(id)kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnPersistentRef];
    
    OSStatus secStatus = SecItemAdd((CFDictionaryRef)publicKey, &persistKey);
    
    //if (VERBOSE)
    NSLog(@"\nPublic key keychain addition status: %lu",secStatus);
    
    if (persistKey != nil) CFRelease(persistKey);
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        [publicKey release];
        return NO;
    }
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    
    [publicKey removeObjectForKey:(id)kSecValueData];
    [publicKey removeObjectForKey:(id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
    [publicKey setObject:(id) kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    
    secStatus = SecItemCopyMatching((CFDictionaryRef)publicKey,(CFTypeRef *)&keyRef);
    
    [publicKey release];
    if(keyRef) CFRelease(keyRef);
    
    if (keyRef == nil || secStatus) return NO;
    
    return YES;
}


# pragma mark - Encryption/Decryption Methods:
-(NSString *)decryptWithPrivateKey:(NSString *)inputString
{
    OSStatus status = noErr;
    
    size_t plainBufferSize;;
    uint8_t *plainBuffer;
    
    SecKeyRef privateKey = NULL;
    
    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier_p length:strlen((const char *)privateKeyIdentifier_p)];
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    [queryPrivateKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
    
    status = SecItemCopyMatching((CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey);
    
    if (status)
    {
        if(privateKey) CFRelease(privateKey);
        if(queryPrivateKey) [queryPrivateKey release];
        
        return nil;
    }
    
    //  Allocate the buffer
    plainBufferSize = SecKeyGetBlockSize(privateKey);
    //cipherBufferSize = 128;
    //plainBufferSize = 128;
    
    plainBuffer = malloc(plainBufferSize);
    
    NSData *incomingData = [Base64 decode:inputString];
    uint8_t *cipherBuffer = (uint8_t*)[incomingData bytes];
    
    // Ordinarily, you would split the data up into blocks
    // equal to plainBufferSize, with the last block being
    // shorter. For simplicity, this example assumes that
    // the data is short enough to fit.
	//cipherBuffer = 2048;
    NSLog(@"psize %ld,csize %ld",plainBufferSize,cipherBufferSize);
	
    //cipherBufferSize = 512;
    //plainBufferSize = 512;
    
    if (plainBufferSize < cipherBufferSize)
    {
        printf("Could not decrypt.  Packet too large.\n");
        
        if(privateKey) CFRelease(privateKey);
        if(queryPrivateKey) [queryPrivateKey release];
        
        //Huajiewu: Leak.
        free(plainBuffer);
        return nil;
    }
    
    //note: use padding:kSecPaddingPKCS1 here
    
    //status = SecKeyDecrypt(privateKey, kSecPaddingPKCS1, cipherBuffer, cipherBufferSize, plainBuffer, &plainBufferSize);
    status = SecKeyDecrypt(privateKey, kSecPaddingNone, cipherBuffer, cipherBufferSize, plainBuffer, &plainBufferSize);
	
    if (status)
    {
        if(privateKey) CFRelease(privateKey);
        if(queryPrivateKey) [queryPrivateKey release];
        
        NSLog(@"bad decrypt");
        //Huajiewu: Leak.
        free(plainBuffer);
        return nil;
    }
    
    NSData *decryptedData = [NSData dataWithBytes:plainBuffer length:plainBufferSize];
    
    NSLog(@"d data %@",decryptedData);
    
    self.serverData = decryptedData;
    
    NSString *decryptedString = [[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding] autorelease];
    
    //[NSString stringWithUTF8String:[decryptedData bytes]];
    
    //[[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"d str %@",decryptedString);
    
    
    if(privateKey) CFRelease(privateKey);
    if(queryPrivateKey) [queryPrivateKey release];
    //Huajiewu: Leak.
    free(plainBuffer);
    
    return decryptedString;
}



-(NSString *)encryptWithPublicKey:(NSString *)plainTextString useServerKey:(BOOL)isServerKey Base64OrHex:(BOOL)isBase64
{
    OSStatus status = noErr;
    
    SecKeyRef publicKey = NULL;
    
    NSData * publicTag;
    if(isServerKey)
    {
        publicTag= [NSData dataWithBytes:serverPublicKeyIdentifier_p length:strlen((const char *)serverPublicKeyIdentifier_p)];
    }
    else
    {
        publicTag= [NSData dataWithBytes:publicKeyIdentifier_p length:strlen((const char *)publicKeyIdentifier_p)];
    }
    
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
    
    status = SecItemCopyMatching((CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey);
    
    if (status)
    {
        if(publicKey) CFRelease(publicKey);
        if(queryPublicKey) [queryPublicKey release];
        
        return nil;
    }
    
	//cipherBufferSize = 2048;
	
    //  Allocate a buffer
    cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    
    NSLog(@"\nCipher buffer size: %lu\n\n",cipherBufferSize);
    
    uint8_t *nonce = (uint8_t *)[plainTextString UTF8String];
    
    //NSLog(@"nonce %@",[plainTextString UTF8String]);
    
    //  Error handling:
    // Ordinarily, you would split the data up into blocks
    // equal to cipherBufferSize, with the last block being
    // shorter. For simplicity, this example assumes that
    // the data is short enough to fit.
    if (cipherBufferSize < sizeof(nonce))
    {
        printf("Could not decrypt.  Packet too large.\n");
        
        if(publicKey) CFRelease(publicKey);
        if(queryPublicKey) [queryPublicKey release];
        
        return nil;
    }
    
    //note: use padding:kSecPaddingPKCS1 lenth:strlen( (char*)nonce ) here
    
    //status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, nonce, strlen( (char*)nonce ) + 1, &cipherBuffer[0], &cipherBufferSize);
    status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, nonce, strlen( (char*)nonce ), &cipherBuffer[0], &cipherBufferSize);
    
    if (status)
    {
        if(publicKey) CFRelease(publicKey);
        if(queryPublicKey) [queryPublicKey release];
        
        return nil;
    }
    
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    
    //if (VERBOSE)
    NSLog(@"\nBase 64 Encrypted String:\n%@\n\n",[Base64 encode:encryptedData]);
    
    if(publicKey) CFRelease(publicKey);
    if(queryPublicKey) [queryPublicKey release];
    free(cipherBuffer);
    
    NSLog(@"cipher buff[%@]",encryptedData);
	if(isBase64)
        return [Base64 encode:encryptedData];
    else
        return [Util stringWithHexBytes:encryptedData];
}


-(NSString *)encryptWithPublicKeyOnData:(NSData *)plainTextData useServerKey:(BOOL)isServerKey Base64OrHex:(BOOL)isBase64
{
    OSStatus status = noErr;
    
    SecKeyRef publicKey = NULL;
    
    NSData * publicTag;
    if(isServerKey)
    {
        publicTag= [NSData dataWithBytes:serverPublicKeyIdentifier_p length:strlen((const char *)serverPublicKeyIdentifier_p)];
    }
    else
    {
        publicTag= [NSData dataWithBytes:publicKeyIdentifier_p length:strlen((const char *)publicKeyIdentifier_p)];
    }
    
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
    
    status = SecItemCopyMatching((CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey);
    
    if (status)
    {
        if(publicKey) CFRelease(publicKey);
        if(queryPublicKey) [queryPublicKey release];
        
        return nil;
    }
    
	//cipherBufferSize = 2048;
	
    //  Allocate a buffer
    cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    
    NSLog(@"\nCipher buffer size: %lu\n\n",cipherBufferSize);
    
    uint8_t *nonce = (uint8_t *)plainTextData;
    
    //NSLog(@"nonce %@",[plainTextString UTF8String]);
    
    //  Error handling:
    // Ordinarily, you would split the data up into blocks
    // equal to cipherBufferSize, with the last block being
    // shorter. For simplicity, this example assumes that
    // the data is short enough to fit.
    if (cipherBufferSize < sizeof(nonce))
    {
        printf("Could not decrypt.  Packet too large.\n");
        
        if(publicKey) CFRelease(publicKey);
        if(queryPublicKey) [queryPublicKey release];
        
        return nil;
    }
    
    //note: use padding:kSecPaddingPKCS1 lenth:strlen( (char*)nonce ) here
    
    //status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, nonce, strlen( (char*)nonce ) + 1, &cipherBuffer[0], &cipherBufferSize);
    status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, nonce, strlen( (char*)nonce ), &cipherBuffer[0], &cipherBufferSize);
    
    if (status) 
    {
        if(publicKey) CFRelease(publicKey);
        if(queryPublicKey) [queryPublicKey release];
        
        return nil;
    }
    
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    
    //if (VERBOSE)
    NSLog(@"\nBase 64 Encrypted String:\n%@\n\n",[Base64 encode:encryptedData]);
    
    if(publicKey) CFRelease(publicKey);
    if(queryPublicKey) [queryPublicKey release];
    free(cipherBuffer);
    
    NSLog(@"cipher buff[%@]",encryptedData);
	if(isBase64)
        return [Base64 encode:encryptedData];
    else
        return [Util stringWithHexBytes:encryptedData];
}


@end

