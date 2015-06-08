//
//  msgPoller.m
//  NovartisDemo
//
//  Created by 8fox on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "msgPoller.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "Util.h"
//#import "AppDelegate.h"
#import "ImdAppBehavior.h"
#import "Util.h"

@implementation msgPoller
@synthesize delegate;
@synthesize pollingData,pollingURL,fetchingURL,imdToken,timestamp;
@synthesize currentUser,meetingServer;

-(id)init
{
    self =[super init];
    
    if(self)
    {
        //NSLog(@"init msg polling");
        meetingServer =@"www.i-md.com";
        //meetingServer =@"medwin.corp.i-md.com";
        
        self.currentUser =@"searchingApp";
        self.currentUser = [Util URLencode:currentUser stringEncoding:NSUTF8StringEncoding];
        
        pollingInterval =1.0f;
        
        //timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]*1000];
        
        self.fetchingURL = [NSString stringWithFormat:@"http://%@/novartis/login/%@",meetingServer,currentUser];
        
        NSString* randomSeed = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]*1000];
        //arc4random()
        
        //filters format:
        //<eventCategory1>:<key1>,<eventCategory2>:<key2>
        
        NSString* filter =@"";//[NSString stringWithFormat:@"cata1:key1,cata2:key2"];
        
        
        // <server>/events/<last_timestamp>/<filters>/?r=<random_seed (current time)>
        
        self.pollingURL =[NSString stringWithFormat:@"http://%@/events/%@/%@/?r=%@",meetingServer,self.timestamp,filter,randomSeed];
        
        self.pollingURL =[NSString stringWithFormat:@"http://%@/events/%@/",meetingServer,self.timestamp];
        
        pollingData = [[NSMutableArray alloc] initWithCapacity:200];
        
        //NSLog(@"polling url %@",self.pollingURL);
        
        //NSString *poweredBy = [[request responseHeaders] objectForKey:@"cookie"];
        self.timestamp = @"";
    }
    return  self;
    
}

-(void)dealloc
{
    [pollingTimer invalidate];
    pollingTimer =nil;
}

-(void)addData:(NSString*)s
{
    [pollingData addObject:s];
    
}

-(void)startPolling
{
    pollingFlag =YES;
    //pollingTimer = [NSTimer scheduledTimerWithTimeInterval:pollingInterval target:self selector:@selector(poll:) userInfo:nil repeats:NO];
    
    [self performSelector:@selector(poll:) withObject:nil afterDelay:0.5f];
}

-(void)stopPolling
{
    pollingFlag = NO;
    //[pollingTimer invalidate];
    
}
-(void)poll:(id)sender
{
    //NSLog(@"poll start");
    
    if(!pollingFlag)return;
    
    //NSLog(@"poll start %@",self.timestamp);
    
    if(inPolling)
    {
        //NSLog(@"I am polling,try again next time");
    }
    
    if([self.timestamp isEqualToString:@""])
    {
        self.timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:@"registerTime"];
        //self.timestamp = [NSString stringWithFormat:@"%llu", (long long)[[NSDate date] timeIntervalSince1970]*1000];
    }
    
    //NSLog(@"poll ? %@",self.pollingURL);
    
    //NSLog(@"poll continue");
    
    
    self.pollingURL =[NSString stringWithFormat:@"http://%@/events/%@/",meetingServer,self.timestamp];
    
    
    NSString* nowTime =[NSString stringWithFormat:@"%llu", (long long)[[NSDate date] timeIntervalSince1970]*1000];
    
    NSString* filter =@"Novartis:1";//[NSString stringWithFormat:@"cata1:key1,cata2:key2"];
    self.pollingURL =[NSString stringWithFormat:@"http://%@/events/%@/%@/?r=%@",meetingServer,self.timestamp,filter,nowTime];
    
    NSString* urlString = self.pollingURL;
    //NSLog(@"polling url at %@",pollingURL);
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    //NSLog(@"syn %@",urlString);
    //[request appendPostData:[aString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    //[request setRequestMethod:@"POST"];
    
    //imdPadAppDelegate *appDelegate = (imdPadAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"polling" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    NSString* token =self.imdToken;
    // [NSString stringWithFormat:@"imdToken=%@",appDelegate.auth.imdToken];
    //NSLog(@"token =%@",token);
    //[request addRequestHeader:@"Cookie" value:token];
    
    
    //Create a cookie
    
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:token forKey:NSHTTPCookieValue];
    [properties setValue:@"imdToken" forKey:NSHTTPCookieName];
    [properties setValue:[NSString stringWithFormat:@".%@",meetingServer]forKey:NSHTTPCookieDomain];
    [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
    NSString* pathString =[NSString stringWithFormat:@"/events/%@",self.timestamp];
    [properties setValue:pathString forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    
    [request setUseCookiePersistence:NO];
    [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
    
    
    
    request.delegate = self;
    [request startAsynchronous];
    inPolling = YES;
    
    //netStep = MEETING_REQUEST_EVENTS;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //NSData * responseData =[request rawResponseData];
    //NSString* responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSString* responseString =[request responseString];
    
    NSDictionary* n =[request userInfo];
    NSString* rType =[n objectForKey:@"requestType"];
    //NSLog(@"rType = %@",rType);
    //NSLog(@"url =%@",pollingURL);
    
    if([rType isEqualToString:@"fetching"])
    {
        
        for(int i =0;i<[[request responseCookies] count];i++)
        {
            NSHTTPCookie* c1 = [[request responseCookies] objectAtIndex:i];
            if([[c1 name] isEqualToString:@"imdToken"])
            {
                //NSLog(@"token = %@",[c1 value]);
                self.imdToken =[c1 value];
                
                [[NSUserDefaults standardUserDefaults] setObject:self.imdToken forKey:@"imdToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (delegate && [delegate respondsToSelector:@selector(registerOK:)])
                {
                    [delegate performSelector:@selector(registerOK:) withObject:responseString];
                }
                
                break;
            }
            
        }
        
        NSLog(@"get a fetching string %@",[request responseString]);
        
        [[NSUserDefaults standardUserDefaults] setObject:[request responseString] forKey:@"registerTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else if([rType isEqualToString:@"polling"])
    {
        //NSLog(@"get a polling");
        
        
        if (delegate && [delegate respondsToSelector:@selector(display:)])
        {
            [delegate performSelector:@selector(display:) withObject:responseString];
        }
        
        
        BOOL hasError = NO;
        
        {
            NSDictionary* info;
            if (responseString ==(id)[NSNull null] || responseString.length ==0 )
            {
                info =nil;
                hasError = YES;
            }
            else
            {
                info =[responseString JSONValue];
            }
            
            
            if(info != nil)
            {
                //NSLog(@"last timestamp: %@",self.timestamp);
                self.timestamp = [NSString stringWithFormat:@"%llu",[[info objectForKey:@"timestamp"] longLongValue]];
                //NSLog(@"new timestamp: %@",[info objectForKey:@"timestamp"]);
                //NSLog(@"now timestamp: %@",self.timestamp);
                //NSLog(@"info %@",info);
                NSArray* events = [info objectForKey:@"events"];
                //NSLog(@"info %@",info);
                //NSLog(@"events count %d",[events count]);
                
                if([events count]>0)
                {
                    int turnPageCount =0;
                    int latestPage =-1;
                    long long lastestTurnPageTime =0;
                    
                    //int winLotteryCount=0;
                    BOOL youWon =NO;
                    
                    int toMeetingCount =0;
                    int toMidSurveyCount =0;
                    int toMeetingOverCount =0;
                    
                    
                    for(int i=0;i<[events count];i++)
                    {
                        NSDictionary* ev=[events objectAtIndex:i];
                        int etype =[[ev objectForKey:@"eventType"] intValue];
                        
                        
                        if(etype ==22)  //turn page
                        {
                            turnPageCount++;
                            NSString* attachment =[ev objectForKey:@"attachment"];
                            
                            NSDictionary* p=[attachment JSONValue];
                            
                            NSLog(@"%@",p);
                            
                            int pNo =[[p objectForKey:@"pageNum"] intValue];
                            
                            
                            long long ts =[[ev objectForKey:@"timestamp"] longLongValue];
                            if(ts>lastestTurnPageTime)
                            {
                                lastestTurnPageTime = ts;
                                latestPage =pNo;
                            }
                        }
                        
                        if(etype ==24) // win lottery
                        {
                            NSString* attachment =[ev objectForKey:@"attachment"];
                            
                            NSDictionary* p=[attachment JSONValue];
                            
                            //NSLog(@"%@",p);
                            
                            NSString* winner =[p objectForKey:@"winner"];
                            NSLog(@"win%@",winner);
                            //if([winner isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]])
                            NSString* userName =[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
                            if([winner isEqualToString:userName])
                            {
                                youWon = YES;
                            }
                        }
                        
                        if(etype == 21) //meeting begin
                        {
                            toMeetingCount ++;
                        }
                        
                        if(etype == 29) //meeting over
                        {
                            toMeetingOverCount++;
                        }
                        
                        if(etype == 30) //survey
                        {
                            toMidSurveyCount++;
                        }
                    }
                    
                    if(toMeetingCount>0)
                    {
                        NSURL *url = [NSURL URLWithString:@"NovartisDemo:meeting"];
                        [[UIApplication sharedApplication] openURL:url];
                        
                    }
                }
            }
            else
            {
                hasError = YES;
            }
        }
        
        [self startPolling];
    }
    
    inPolling = NO;
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    NSLog(@"request failed");
    NSDictionary* info =[request userInfo];
    NSString* rType = [info objectForKey:@"requestType"];
    
    NSLog(@"rType %@",rType);
    
    if([rType isEqualToString:@"polling"])
    {
        [self startPolling];
    }
    
    inPolling = NO;
}

- (void)fetchToken;
{
    
    NSString* userCode =[Util URLencode:currentUser stringEncoding:NSUTF8StringEncoding];
    self.fetchingURL = [NSString stringWithFormat:@"http://%@/novartis/login/%@",meetingServer,userCode];
    
    NSString* urlString = self.fetchingURL;
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    //[request setRequestMethod:@"POST"];
    //[request setShouldRedirect:NO];
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
    [userInfo setObject:@"fetching" forKey:@"requestType"];
    [request setUserInfo:userInfo];
    
    request.delegate = self;
    [request startAsynchronous];
    inPolling = YES;
}


@end
