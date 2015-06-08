//
//  LoginDepartment.m
//  imdSearch
//
//  Created by Huajie Wu on 12-2-7.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "LoginDepartment.h"
#import "IPhoneHeader.h"
#import "ImdAppBehavior.h"
#import "Util.h"

@implementation LoginDepartment

@synthesize delegate;
@synthesize scrollView, alertView, departmentList;
@synthesize currentCn, currentKey;
@synthesize selectedBtn;

@synthesize httpRequest = _httpRequest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = DEPARTMENT_SELECT;
        [TableViewFormatUtil setContentBackGround:self.view image:BG_DEPARTMENT];
        alertView = [[UIAlertView alloc] initWithTitle:REQUEST_FAILED_TITLE message:REQUEST_FAILED_MESSAGE delegate:self cancelButtonTitle:REQUEST_FAILED_CANCEL otherButtonTitles:nil];
        
    }
    return self;
}

-(void) selectDepartment{
}

-(void) popBack
{
    [self behavior:@"backButtonTapped"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
    if (_httpRequest != nil) {
        [_httpRequest clearDelegatesAndCancel];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

#pragma mark Asy Request

-(void)requestFinished:(ASIHTTPRequest *)request
{
    self.view.hidden = NO;
    NSArray* resultsJson = [UrlRequest getJsonArrayValue:request];
    if ([resultsJson count]) {
        self.departmentList = [[NSMutableArray alloc]init];
        [self.departmentList addObjectsFromArray:resultsJson];
        [self.departmentList exchangeObjectAtIndex:[self.departmentList count]-1 withObjectAtIndex:29];
    }
    
    //Check if results is nil.
    if (self.departmentList == nil) {
        NSLog(@"Nil Results");
        return;
    } else {
//        [self showDepartments];
        [self.departTableView reloadData];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request failed %@",[request responseString]);
    [ImdAppBehavior exceptionLog:[Util getUsername] MACAddr:[Util getMacAddress] exceptionCode:@"requestFailed" exceptionMessage:[request responseString]];
    self.departmentList = [Strings Departments];
    if (self.departmentList) {
//        [self showDepartments];
        [self.departTableView reloadData];
    }
    self.view.hidden = NO;
    [self.alertView show];
}

-(void) requestDepartment
{
    if (self.departmentList == nil) {
        if (self.httpRequest != nil) {
            [self.httpRequest clearDelegatesAndCancel];
        }
        self.httpRequest = [UrlRequest send:[ImdUrlPath departmentUrl] delegate:self];
    }
}

-(void) showDepartments
{
    NSInteger yOffSet = 0;
    for(int i = 0 ; i < self.departmentList.count; ++i) {
        NSLog(@"%@, %@",
              [[self.departmentList objectAtIndex:i] objectForKey:DEPARTMENT_CN],
              [[self.departmentList objectAtIndex:i] objectForKey:DEPARTMENT_EN]
              );
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:[[self.departmentList objectAtIndex:i] objectForKey:DEPARTMENT_CN] forState:UIControlStateNormal];
        
        [btn setTitle:[[self.departmentList objectAtIndex:i] objectForKey:DEPARTMENT_KEY] forState:UIControlStateReserved];
        
        UIColor* color = RGBCOLOR(78, 63, 53);
        
        [btn setTitleColor:color forState:UIControlStateNormal];
        
        [btn setTitleColor: RGBCOLOR(247, 247, 247) forState:UIControlStateSelected];
        
        [btn setTitle:[[self.departmentList objectAtIndex:i] objectForKey:DEPARTMENT_KEY] forState:UIControlStateReserved];
        
        [btn setBackgroundImage:[UIImage imageNamed:IMG_DEPARTMENT_NORMAL] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:IMG_DEPARTMENT_SELECTED] forState:UIControlStateSelected];
        
        
        
        NSInteger x = 26;
        NSInteger y = 27;
        NSInteger w = 121;
        NSInteger h = 44;
        NSInteger margin = 34;
        
        if (i % 2 == 0) {
            x = 26;
        } else {
            x = 320 - x - w;
        }
        y = y + (i/2) * (h + margin);
        
        [btn addTarget:self action:@selector(selectDepartment:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.frame = CGRectMake(x, y, w, h);
        btn.hidden = NO;
        [self.scrollView addSubview:btn];
        
        yOffSet = y + h + margin;
    }
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, yOffSet)];
}

-(void) selectDepartment:(id)sender
{
    if (sender != nil) {
        UIButton* btn = (UIButton*) sender;
        [btn setSelected:YES];
        [self.selectedBtn setSelected:NO];
        self.selectedBtn = btn;
        self.currentCn = [self.selectedBtn titleForState:UIControlStateNormal];
        self.currentKey = [self.selectedBtn titleForState:UIControlStateReserved];
        [self behavior:self.currentCn];
    }
    [self popBack];
}


#pragma mark - UITableViewDelegate 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.departmentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    NSDictionary *department = [self.departmentList objectAtIndex:indexPath.row];
    cell.textLabel.text = [department objectForKey:DEPARTMENT_CN];
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *department = [self.departmentList objectAtIndex:indexPath.row];
    self.currentCn = [department objectForKey:DEPARTMENT_CN];
    self.currentKey = [department objectForKey:DEPARTMENT_KEY];
    [self popBack];
}

- (void)behavior:(NSString *)status
{
    NSString* json = [NSString stringWithFormat:@"{\"status\":\"%@\"", status];
    [ImdAppBehavior registerLog:[Util getUsername] MACAddr:[Util getMacAddress] pageName:SelectDepartment paramJson:json];
}
@end
