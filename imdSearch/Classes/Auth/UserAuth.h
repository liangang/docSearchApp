//
//  UserAuth.h
//  imdSearch
//
//  Created by Huajie Wu on 11-11-25.
//  Copyright (c) 2011年 i-md.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "myUrl.h"
#import "registerFinishViewController.h"
#define  AUTHSTEP_IDLE 0
#define  AUTHSTEP_POSTING_DEVICEID 1
#define  AUTHSTEP_POSTING_AUTHINFO 2
#define  AUTHSTEP_REQUESTOKEN_GET_STRING 3
#define  AUTHSTEP_REQUESTOKEN_GET_TOKEN  4
#define  AUTHSTEP_CHECK_APPVERSION  5


@interface UserAuth : NSObject {
    
    NSString* imdToken;
    NSString* clinetId;
    NSString* serverString;
    NSData* serverData;
    
    int authStep;
    size_t cipherBufferSize;
    
    id delegate;
  registerFinishViewController *regFinishVC;
}

-(void)firstLogin;
-(void)testKeyPair;
-(void)requireToken;


-(void)checkAppVersion;

- (void)postDeviceInfo;
- (void)postAuthInfo;
- (void)postRequestString;
- (void)postRequestToken;
- (void)doLogin:loginController fromRegister:(BOOL)from;

-(void)generateKeyPair;
-(NSString *)getPublicKeyX509Formatted:(BOOL)formatBool useServerKey:(BOOL)isServerKey;
-(NSString *)getPKCS1FormattedPrivateKey;
-(NSString *)encryptWithPublicKey:(NSString *)plainTextString useServerKey:(BOOL)isServerKey Base64OrHex:(BOOL)isBase64;

-(NSString *)encryptWithPublicKeyOnData:(NSData *)plainTextData useServerKey:(BOOL)isServerKey Base64OrHex:(BOOL)isBase64;

-(NSString *)decryptWithPrivateKey:(NSString *)inputString;
-(BOOL)setPublicKey:(NSString *)keyString isX509Formatted:(BOOL)formatBool serverKey:(BOOL)isServerKey;


@property (nonatomic,retain) NSString* clientId;
@property (nonatomic,assign) BOOL fromRegister ;
@property (nonatomic,retain) NSString* imdToken;
@property (nonatomic,retain) NSString* serverString; 
@property (nonatomic,retain) NSData* serverData;
@property (nonatomic,retain) id delegate;
@end