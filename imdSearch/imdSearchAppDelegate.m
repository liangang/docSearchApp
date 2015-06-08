//
//  imdSearchAppDelegate.m
//  imdSearch
//
//  Created by 8fox on 9/9/11.
//  Copyright 2011 i-md.com. All rights reserved.
//

#import "imdSearchAppDelegate.h"

@implementation imdSearchAppDelegate


@synthesize window=_window;
@synthesize auth;
@synthesize loginFail;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
- (void)dealloc
{
    self.auth =nil;
}

-(void)loadSecurity{
}

-(void)connectionServerFinished{
}

-(void)connectionServerFailed{
}

-(void)login{
}

-(void)loginFailed{
}

-(void)postAuth{
}

-(void)registerloginFailed{
}

-(void) requestTokenFailed{
}

-(void) showLoginView:(UIViewController*)controller title:(NSString*) title{
}

-(void)showAlert{
}

//New auth interface
-(void) firstLoginFinished{
}

-(void) firstLoginFailed{
}

-(void) requireTokenFinished{
}

-(void) requireTokenFailed{
}

-(void) userLoginFinished:(BOOL)animated{
}

-(void) userLoginFailed{
}

-(void) versionChecked:(NSString*)latest forceUpdate:(BOOL)forceUpdate{
}

@end
