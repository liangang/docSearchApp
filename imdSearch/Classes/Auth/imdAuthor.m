//
//  imdAuthor.m
//  imdPad
//
//  Created by 8fox on 8/5/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import "imdAuthor.h"
#import "Base64.h"
#import <Security/Security.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Util.h"
#import "JSON.h"
#import "imdSearchAppDelegate.h"
#import "UIDevice+IdentifierAddition.h"

#import "ImdAppBehavior.h"
#import "Util.h"
#import "NetStatusChecker.h"

#import "ISBaseInfoManager.h"

static const UInt8 publicKeyIdentifier[] = "com.i-md.ios.imdauthM.publickey\0";
static const UInt8 privateKeyIdentifier[] = "com.i-md.ios.imdauthM.privatekey\0";
static const UInt8 serverPublicKeyIdentifier[] = "com.i-md.ios.imdauthM.serverPublickey\0";

static unsigned char oidSequence[] = { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00 };


size_t encodeLength(unsigned char * buf, size_t length);

size_t encodeLength(unsigned char * buf, size_t length) 
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



@implementation imdAuthor
@synthesize imdToken,clientId,serverString,serverData,registerFailed;

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
        
        //self.clientId = @"ABC0000MMM";
        
        NSLog(@"my client id is %@",self.clientId);
        
        
        //[self testKeyPair];
        //NSLog(@"end of the test!!!");
    }   
    
    return self;
}

-(void)dealloc
{
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
    //NSString* urlString = [NSString stringWithFormat:@"http://%@/auth/client/firstLogin",AUTH_SERVER];
    
    NSString* urlString = [NSString stringWithFormat:@"http://%@/auth/firstLogin",AUTH_SERVER];
    
    
    
    NSString* clientMd5 =[Util md5:self.clientId];
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


- (void)postAuthInfo:(NSString *)str
{
    //NSString* urlString = [NSString stringWithFormat:@"http://%@/auth/client/postInfo",AUTH_SERVER];
    
    NSString* urlString = [NSString stringWithFormat:@"http://%@/auth/postInfo",AUTH_SERVER];
    
    NSLog(@"auth url =%@",urlString);
    
    
    NSString* userString = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
        //@"imdtest4";
    NSString* passString = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedPass"];
        //@"test1234";
    
    
    //NSString* userString = @"imdtest4";
    //NSString* passString = @"test1234";
  if (!userString.length >0) {
    return;
  }
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
  if ([str isEqualToString:@"register"]) {
    self.registerFailed = @"registerFailed";
  }
  
  authStep = AUTHSTEP_POSTING_AUTHINFO;

}


- (void)postRequestString
{
    NSLog(@"requesting string");
    //NSString* urlString = [NSString stringWithFormat:@"http://%@/auth/client/requestToken",AUTH_SERVER];
    
    NSString* urlString = [NSString stringWithFormat:@"http://%@/auth/requestToken",AUTH_SERVER];
    
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
    //NSString* urlString = [NSString stringWithFormat:@"http://%@/auth/client/authStr",AUTH_SERVER];
    NSString* urlString = [NSString stringWithFormat:@"http://%@/auth/authStr",AUTH_SERVER];
    
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
    NSLog(@"request finished [%@]", [request responseString]);
    
    if(authStep == AUTHSTEP_POSTING_DEVICEID)
    {
        NSString* sevPublicKeyString = [request responseString];
        
        BOOL gotPubKeyOk = [self setPublicKey:sevPublicKeyString isX509Formatted:YES serverKey:YES];

        if(gotPubKeyOk)
        {
            //next step post auth info
            NSLog(@"post deviceid ok"); 
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"firstLogined"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            authStep = AUTHSTEP_IDLE;
        
            BOOL renewToken =[[[NSUserDefaults standardUserDefaults] objectForKey:@"renewAuth"] boolValue];
            
            if(renewToken)
            {
               [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"renewAuth"];
               [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            //[appDelegate connectionServerFinished];
            
          NSString* userString = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedUser"];
          if (userString.length > 0) {
            [appDelegate postAuth];
          }else
          {
          [appDelegate connectionServerFinished];
          }
            
        }
        else
        {
          NSLog(@"post deviceid failed");
            authStep = AUTHSTEP_IDLE;
            //s2
            
            imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [appDelegate connectionServerFailed];
            
            
            
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
        
        if(info != nil)
        {
            NSString* status = [info objectForKey:@"status"];
            
            if ([status isEqualToString:@"false"] || ![[info objectForKey:@"result"] isEqualToString:@"Correct"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"userLoginInfo" object:[info objectForKey:@"result"]];
            }else{
                self.imdToken = [info objectForKey:@"imdToken"];
                NSLog(@"token ok %@",self.imdToken);
                NSLog(@"json %@",info);
                
                
                NSString* pubKey = [info objectForKey:@"serverPublicKey"];
                [ISBaseInfoManager saveUserInfoId:[info objectForKey:@"uid"]];
                
                BOOL gotPubKeyOk = [self setPublicKey:pubKey isX509Formatted:YES serverKey:YES];
                
                if(gotPubKeyOk)
                {
                    //next step post auth info
                    NSLog(@"set new serverKey ok");
                    
                    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate login];
                    
                    
                }
                else
                {
                    BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
                    
                    NSLog(@"set new serverKey failed");
                    imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    if(!useLogined)
                        [appDelegate loginFailed];
                    else
                        [appDelegate connectionServerFailed];  
                }
            }
        }
        else
        {
            NSLog(@"sth is wrong with json");
            
            BOOL useLogined = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logined"] boolValue];
            
            NSLog(@"set new serverKey failed");
            imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if(!useLogined)
            {
              if ([self.registerFailed isEqualToString:@"registerFailed"]) {
                [appDelegate registerloginFailed];
                self.registerFailed = @"";
              }else
              {
                [appDelegate loginFailed];
              }
            }else
            {
                [appDelegate connectionServerFailed];
            }
                
            
        }
        authStep = AUTHSTEP_IDLE;

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
    }
    else if(authStep == AUTHSTEP_REQUESTOKEN_GET_TOKEN)
    {
        NSLog(@"get token?"); 
       
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
            
            if(gotPubKeyOk)
            {
                //next step post auth info
                NSLog(@"set new serverKey ok");
                
                imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate login];
                //[appDelegate connectionServerFinished];
                
            }
            else
            {
                NSLog(@"set new serverKey failed");
                
                imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate connectionServerFailed];

            }
        }
        else
        {
            NSLog(@"sth is wrong with json get token");
        }
        authStep = AUTHSTEP_IDLE;
    }
}


-(void) requestFailed:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userLoginInfo" object:@"requestFailed"];
    
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    NSLog(@"request failed %d",authStep);
    
    NSError *error = [request error];
    NSLog(@"error %@",error);
    
    //if(authStep == AUTHSTEP_POSTING_DEVICEID || authStep == AUTHSTEP_REQUESTOKEN_GET_TOKEN)
    {
    
        imdSearchAppDelegate *appDelegate = (imdSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate connectionServerFailed];
    
    }
    
    if(authStep == AUTHSTEP_POSTING_AUTHINFO)
    {
    
        NSLog(@"post auth failed");
        //[[NSUserDefaults standardUserDefaults] setObject:@"passwordnotsaved" forKey:@"savedPass"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
    
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
    
    NSData *publicTag = [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    NSData *privateTag = [NSData dataWithBytes:privateKeyIdentifier length:strlen((const char *)privateKeyIdentifier)];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *privateKeyDictionary = [[NSMutableDictionary alloc] init];
    [privateKeyDictionary setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKeyDictionary setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [privateKeyDictionary setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)privateKeyDictionary);
    
    NSMutableDictionary *publicKeyDictionary = [[NSMutableDictionary alloc] init];
    [publicKeyDictionary setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKeyDictionary setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKeyDictionary setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKeyDictionary);
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA
                    forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithInt:2048]
                    forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    
    SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr,&publicKey, &privateKey);
    
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
}


-(NSString *)getPublicKeyX509Formatted:(BOOL)formatBool useServerKey:(BOOL)isServerKey
{ 
    NSData * publicTag;
    
    if(isServerKey)
    {
        publicTag= [NSData dataWithBytes:serverPublicKeyIdentifier length:strlen((const char *)serverPublicKeyIdentifier)];
    }
    else
    {
        publicTag= [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    }

    
    // Now lets extract the public key - build query to get bits
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    NSData * publicKeyBits;
    CFTypeRef typeRef = (__bridge  CFTypeRef)publicKeyBits;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey,&typeRef);
    
    if (err != noErr)
    {
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
    size_t i = sizeof(oidSequence) + 2 + bitstringEncLength + [publicKeyBits length];
    size_t j = encodeLength(&builder[1], i);
    
    if (formatBool)
    {
        [encKey appendBytes:builder length:j +1];
        
        // First part of the sequence is the OID
        [encKey appendBytes:oidSequence length:sizeof(oidSequence)];
        
        // Now add the bitstring
        builder[0] = 0x03;
        j = encodeLength(&builder[1], [publicKeyBits length] + 1);
        builder[j+1] = 0x00;
        [encKey appendBytes:builder length:j + 2];
    }
    
    // Now the actual key
    [encKey appendData:publicKeyBits];
    
    // Now translate the result to a Base64 string
    NSString *ret =[Base64 encode:encKey];
    
    return ret;
}

-(NSString *)getPKCS1FormattedPrivateKey
{ 
        NSData *privateTag = [NSData dataWithBytes:privateKeyIdentifier length:strlen((const char *) privateKeyIdentifier)];
        
        // Now lets extract the private key - build query to get bits
        NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
        
        [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
        [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
        [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
        [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
        
        NSData * privateKeyBits;
        CFTypeRef typeRef = (__bridge  CFTypeRef)privateKeyBits ;
        OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey,&typeRef);
        
        if (err != noErr)
        {
            return nil;
        }
        
        // OK - that gives us the "BITSTRING component of a full DER
        // encoded RSA private key - we now need to build the rest
        
        NSMutableData * encKey = [[NSMutableData alloc] init];
        //NSLog(@"\n%@\n\n",[[NSData dataWithBytes:privateKeyBits length:[privateKeyBits length]] description]);
        
        // Now the actual key
        [encKey appendData:privateKeyBits];
        
        // Now translate the result to a Base64 string
        NSString *ret = [Base64 encode:encKey];
        
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
  if ([strippedPublicKeyData description] == nil) {
    return NO;
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
        publicTag= [NSData dataWithBytes:serverPublicKeyIdentifier length:strlen((const char *)serverPublicKeyIdentifier)];
    }
    else
    {
        publicTag= [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    }
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    CFTypeRef persistKey = nil;
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:strippedPublicKeyData forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    
    //if (VERBOSE)
        NSLog(@"\nPublic key keychain addition status: %lu",secStatus);
    
    if (persistKey != nil) CFRelease(persistKey);
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        return NO;
    }
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    secStatus = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey,(CFTypeRef *)&keyRef);
    
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
    
    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier length:strlen((const char *)privateKeyIdentifier)];
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey);
    
    if (status) 
    {
        if(privateKey) CFRelease(privateKey);
        
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
        
        return nil;
    }
    
     //note: use padding:kSecPaddingPKCS1 here
    
    //status = SecKeyDecrypt(privateKey, kSecPaddingPKCS1, cipherBuffer, cipherBufferSize, plainBuffer, &plainBufferSize);
    status = SecKeyDecrypt(privateKey, kSecPaddingNone, cipherBuffer, cipherBufferSize, plainBuffer, &plainBufferSize);
	
    if (status) 
    {
        if(privateKey) CFRelease(privateKey);
    
        NSLog(@"bad decrypt");
        return nil;
    }
    
    NSData *decryptedData = [NSData dataWithBytes:plainBuffer length:plainBufferSize];
    
    NSLog(@"d data %@",decryptedData);
    
    self.serverData = decryptedData;
    
    NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    //[NSString stringWithUTF8String:[decryptedData bytes]];
    
    //[[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"d str %@",decryptedString);
    
    
    if(privateKey) CFRelease(privateKey);
    
    return decryptedString;
}



-(NSString *)encryptWithPublicKey:(NSString *)plainTextString useServerKey:(BOOL)isServerKey Base64OrHex:(BOOL)isBase64
{
    OSStatus status = noErr;
    
    SecKeyRef publicKey = NULL;
    
    NSData * publicTag;
    if(isServerKey)
    {
        publicTag= [NSData dataWithBytes:serverPublicKeyIdentifier length:strlen((const char *)serverPublicKeyIdentifier)];
    }
    else
    {
        publicTag= [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    }

        
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey);
    
    if (status) 
    {
        if(publicKey) CFRelease(publicKey);
        
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
        
        return nil;
    }
    
    //note: use padding:kSecPaddingPKCS1 lenth:strlen( (char*)nonce ) here
    
    //status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, nonce, strlen( (char*)nonce ) + 1, &cipherBuffer[0], &cipherBufferSize);
    status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, nonce, strlen( (char*)nonce ), &cipherBuffer[0], &cipherBufferSize);
    
    if (status) 
    {
        if(publicKey) CFRelease(publicKey);
        
        return nil;
    }
    
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    
    //if (VERBOSE)
    NSLog(@"\nBase 64 Encrypted String:\n%@\n\n",[Base64 encode:encryptedData]);
    
    if(publicKey) CFRelease(publicKey);
    
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
        publicTag= [NSData dataWithBytes:serverPublicKeyIdentifier length:strlen((const char *)serverPublicKeyIdentifier)];
    }
    else
    {
        publicTag= [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    }
    
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey);
    
    if (status) 
    {
        if(publicKey) CFRelease(publicKey);
        
        return nil;
    }
    
	//cipherBufferSize = 2048;
	
    //  Allocate a buffer
    cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    
    NSLog(@"\nCipher buffer size: %lu\n\n",cipherBufferSize);
    
    uint8_t *nonce = (uint8_t *)[plainTextData bytes];
    
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
        
        return nil;
    }
    
    //note: use padding:kSecPaddingPKCS1 lenth:strlen( (char*)nonce ) here
    
    //status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, nonce, strlen( (char*)nonce ) + 1, &cipherBuffer[0], &cipherBufferSize);
    status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, nonce, strlen( (char*)nonce ), &cipherBuffer[0], &cipherBufferSize);
    
    if (status) 
    {
        if(publicKey) CFRelease(publicKey);
        
        return nil;
    }
    
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    
    //if (VERBOSE)
    NSLog(@"\nBase 64 Encrypted String:\n%@\n\n",[Base64 encode:encryptedData]);
    
    if(publicKey) CFRelease(publicKey);
    free(cipherBuffer);
    
    NSLog(@"cipher buff[%@]",encryptedData);
	if(isBase64)
        return [Base64 encode:encryptedData];
    else
        return [Util stringWithHexBytes:encryptedData];
}

@end
