//
//  imdSearchAppDelegate.h
//  imdSearch
//
//  Created by 8fox on 9/9/11.
//  Copyright 2011 i-md.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imdAuthor.h"


@interface imdSearchAppDelegate : NSObject <UIApplicationDelegate> {

    BOOL isLoading;
    
    imdAuthor* auth;
    BOOL authPrepared;
    BOOL loginFail;
}

-(void)loadSecurity;

-(void)connectionServerFinished;
-(void)connectionServerFailed;

-(void)login;
-(void)loginFailed;

-(void)postAuth;
-(void) showLoginView:(UIViewController*)controller title:(NSString*) title;

-(void)showAlert;

//New auth interface
-(void) firstLoginFinished;
-(void) firstLoginFailed;

-(void) requireTokenFinished;
-(void) requireTokenFailed;

-(void) userLoginFinished:(BOOL)animated;
-(void) userLoginFailed;

-(void)registerloginFailed;
-(void) versionChecked:(NSString*)latest forceUpdate:(BOOL)forceUpdate;
-(void) requestTokenFailed;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) imdAuthor* auth;
@property (nonatomic, assign) BOOL loginFail;
@end
