//
//  imdAuthor.h
//  imdPad
//
//  Created by 8fox on 8/5/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "url.h"

#define  AUTHSTEP_IDLE 0
#define  AUTHSTEP_POSTING_DEVICEID 1
#define  AUTHSTEP_POSTING_AUTHINFO 2
#define  AUTHSTEP_REQUESTOKEN_GET_STRING 3
#define  AUTHSTEP_REQUESTOKEN_GET_TOKEN  4


@interface imdAuthor : NSObject {
        
    NSString* imdToken;
    NSString* clinetId;
    NSString* serverString;
    NSData* serverData;
    
    int authStep;
    size_t cipherBufferSize;
  NSString* registerFailed;
}

-(void)firstLogin;
-(void)testKeyPair;
-(void)requireToken;


- (void)postDeviceInfo;
- (void)postAuthInfo:(NSString *)str;
- (void)postRequestString;
- (void)postRequestToken;

-(void)generateKeyPair;
-(NSString *)getPublicKeyX509Formatted:(BOOL)formatBool useServerKey:(BOOL)isServerKey;
-(NSString *)getPKCS1FormattedPrivateKey;
-(NSString *)encryptWithPublicKey:(NSString *)plainTextString useServerKey:(BOOL)isServerKey Base64OrHex:(BOOL)isBase64;

-(NSString *)encryptWithPublicKeyOnData:(NSData *)plainTextData useServerKey:(BOOL)isServerKey Base64OrHex:(BOOL)isBase64;

-(NSString *)decryptWithPrivateKey:(NSString *)inputString;
-(BOOL)setPublicKey:(NSString *)keyString isX509Formatted:(BOOL)formatBool serverKey:(BOOL)isServerKey;


@property (nonatomic,retain) NSString* clientId;
@property (nonatomic,retain) NSString* imdToken;
@property (nonatomic,retain) NSString* serverString; 
@property (nonatomic,retain) NSData* serverData;
@property (nonatomic,retain) NSString* registerFailed;
@end
