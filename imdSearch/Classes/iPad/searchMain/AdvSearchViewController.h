//
//  AdvSearchViewController.h
//  imdSearch
//
//  Created by  侯建政 on 9/13/12.
//  Copyright (c) 2012 i-md.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
@interface AdvSearchViewController : UITableViewController <UIGestureRecognizerDelegate,UIPopoverControllerDelegate,UITextFieldDelegate>
{
    int currentSearchLanguage;
    int advancedQueryItemCount;
    int advancedQueryItemCountMax;
    int popedYearButton;
    int searchingType; //adv or sim search
    int fetchingPage;
    int currentPage;
    id currentKeybordHolder;
    NSMutableArray* filterNames;
    NSMutableArray* filterValues;
    NSMutableArray* filterOperations;
    BOOL coreJournalOn;
    BOOL sciOn;
    BOOL reviewsOn;
    BOOL newSearchStart;
    UISwitch* coreJournalSwitch;
    UISwitch* sciSwitch;
    UISwitch* reviewsSwitch;
    NSMutableDictionary *filterItemData;
    NSString *maxYear;
    NSString *minYear;
    UIPopoverController *filterPopoverController;
    UIPopoverController *yearPopoverController;
    UIPopoverController *languagePopoverController;
    NSString* sortMethod;
    id delegate;
    ASIHTTPRequest* httpRequestSearchAdvanceSearch;
    NSDictionary *sendadvRequestValue;
}

@property(nonatomic, retain) NSMutableDictionary *filterItemData;
@property (nonatomic,retain) ASIHTTPRequest* httpRequestSearchAdvanceSearch;
@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) id currentKeybordHolder;
@property (nonatomic,assign) BOOL newSearchStart;
@property (nonatomic,assign) int currentPage;

-(void)advSearch:(id)sender status:(NSString *)status sort:(NSString*)sort;
-(void)tableViewReload;
@end
