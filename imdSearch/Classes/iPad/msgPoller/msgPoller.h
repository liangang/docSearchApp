//
//  msgPoller.h
//  NovartisDemo
//
//  Created by 8fox on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface msgPoller : NSObject
{
    
    float pollingInterval;

    BOOL inPolling;
    
    NSString* pollingURL;
    NSString* fetchingURL;
    
    NSTimer * pollingTimer;
    
    NSMutableArray* pollingData;
    
    NSString* meetingServer;
    id delegate;
    
    NSString* currentUser;
    NSString* timestamp;
    NSString* imdToken;
    
    BOOL pollingFlag;
    
}
@property (nonatomic,strong) id delegate;
@property (nonatomic,strong) NSString* pollingURL; 
@property (nonatomic,strong) NSString* fetchingURL;
@property (nonatomic,strong) NSMutableArray* pollingData;
@property (nonatomic,strong) NSString* imdToken;
@property (nonatomic,strong) NSString* currentUser;
@property (nonatomic,strong) NSString* meetingServer;
@property (nonatomic,retain) NSString* timestamp;


- (void)addData:(NSString*)s;
- (void)startPolling;
- (void)stopPolling;

- (void)poll:(id)sender;
- (void)fetchToken;
@end
