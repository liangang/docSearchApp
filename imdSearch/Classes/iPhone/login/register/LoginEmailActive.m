//
//  LoginEmailActive.m
//  imdSearch
//
//  Created by Huajie Wu on 12-4-19.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "LoginEmailActive.h"
#import "IPhoneHeader.h"
#import "LoginEmailActive2.h"

@interface LoginEmailActive (startToUse)

- (void)popBack:(id)sender;
- (void)dismissView:(id)sender;
@end

@implementation LoginEmailActive

@synthesize emailActiveBtn = _emailActiveBtn, emailActiveGoBtn = _emailActiveGoBtn;
@synthesize isLevel1;
@synthesize hintActiveView = _hintActiveView;
@synthesize userLabel = _userLabel;
@synthesize fromRegister;
@synthesize hintValidateView = _hintValidateView;

- (void)dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isLevel1 = NO;
        self.fromRegister = NO;
        self.title = ACTIVE_EMAIL_TITLE;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [TableViewFormatUtil setContentBackGround:self.view image:IMG_BG_SIGNIN];
    
    NSString* user = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_USER];
    [self.userLabel setText:user];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


- (void)popBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)emailActiveView:(id)sender
{
    LoginEmailActive2* step2 = [[LoginEmailActive2 alloc] init];
    [self.navigationController pushViewController:step2 animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
