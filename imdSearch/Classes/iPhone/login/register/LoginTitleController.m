//
//  LoginTitleController.m
//  imdSearch
//
//  Created by Huajie Wu on 12-2-7.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "LoginTitleController.h"
#import "IPhoneHeader.h"
#import "ImdAppBehavior.h"
#import "Util.h"
#import "TableViewFormatUtil.h"

@implementation LoginTitleController

@synthesize titleStr, selectedBtn;
@synthesize level1, level2, level3, level4;
@synthesize color1, color2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = TITLE_SELECT;
        [TableViewFormatUtil setContentBackGround:self.view image:BG_DEPARTMENT];
        
       
        if (iPhone5) {
            [TableViewFormatUtil setBorder:level1 Color:[UIColor lightGrayColor]];
            [TableViewFormatUtil setBorder:level2 Color:[UIColor lightGrayColor]];
            [TableViewFormatUtil setBorder:level3 Color:[UIColor lightGrayColor]];
            [TableViewFormatUtil setBorder:level4 Color:[UIColor lightGrayColor]];
            
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
}


-(IBAction) selectTitle:(id)sender
{
    UIButton* btn = (UIButton*) sender;
    
    self.titleStr = [self getTitleFromButton:btn];
    [selectedBtn setSelected:NO];
    selectedBtn = btn;
    [self behavior:self.titleStr];
    [btn setSelected:YES];
    [self popBack];
}


- (void)resetFrameWithView:(UIView *)view  originY:(CGFloat)y height:(CGFloat)height{
    CGRect rect = view.frame;
    if (y>0) {
        rect.origin.y = y;
    }
    
    if (height > 0) {
        rect.size.height = height;
    }
    
    view.frame = rect;
}

- (NSString *)getTitleFromButton:(UIButton *)sender{
    NSString *title = nil;
    if (sender == level1) {
        title = @"主任医师";
    }else if(sender == level2){
        title = @"副主任医师";
    }else if (sender == level3){
        title = @"主治医师";
    }else{
        title = @"医师/医士";
    }
    
    return title;
}

#pragma mark - View lifecycle
-(void) popBack
{
    [self behavior:@"backButtonTapped"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [self behavior:@"viewDidLoad"];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self behavior:@"viewDidUnload"];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)behavior:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:SelectProfessional paramJson:json];
}

@end
