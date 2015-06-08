//
//  searchHistory.m
//  imdSearch
//
//  Created by 8fox on 10/25/11.
//  Copyright (c) 2011 i-md.com. All rights reserved.
//

#import "searchHistory.h"
#import "imdiPadDatabase.h"
#import "Util.h"
#import "Url_iPad.h"


@implementation searchHistory


+(int)getAvailbleHistoryPos
{
    
    //    NSArray* historyArray =[[NSUserDefaults standardUserDefaults] objectForKey:@"localHistory"];
    NSArray* historyArray = [imdiPadDatabase selectHistoryListTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername] ]];
    
    if([historyArray count]==0) return 0;
    
    //    int p = [[[NSUserDefaults standardUserDefaults] objectForKey:@"newestPos"]intValue];
    //    return (p+1)%MAX_HISTORY;
    return [historyArray count];
    /*int c = [[[NSUserDefaults standardUserDefaults] objectForKey:@"historyCount"]intValue];
     
     if(c==0)return 0;
     
     int p = [[[NSUserDefaults standardUserDefaults] objectForKey:@"newestPos"]intValue];
     return (p+1)%MAX_HISTORY;*/
}


+(void)saveSearchHistory:(NSString*)searchWord Language:(NSString*)Lan
{
    //  [imdiPadDatabase insertHistoryListTable:searchWord language:Lan username:[Util getUsername]];
    //
    //  NSMutableArray *hisArray = [imdiPadDatabase selectHistoryListTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername] ]];
    //  NSLog(@"hisArray count : %d",[hisArray count]);
    //  NSLog(@"hisArray == %@",hisArray);
      [searchHistory removeSearchHistory:searchWord Language:Lan];
    
    //    int next =[searchHistory getAvailbleHistoryPos];
    
    //    NSMutableArray* historyArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"localHistory"] mutableCopy];
    NSArray* historyArray = [imdiPadDatabase selectHistoryListTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername] ]];
    int c = [historyArray count];
    
    //    NSString* aValue =[NSString stringWithFormat:@"%@%@",Lan,searchWord];
    
    if(c<MAX_HISTORY)
    {
        //        [historyArray insertObject:aValue atIndex:next];
        [imdiPadDatabase insertHistoryListTable:searchWord language:Lan username:[Util getUsername]];
    }
    else
    {
        //        [historyArray replaceObjectAtIndex:next withObject:aValue];
        NSMutableDictionary *history = [historyArray objectAtIndex:0];
        [searchHistory removeSearchHistory:[history objectForKey:KEY_SEARCH_WORD] Language:[history objectForKey:KEY_SEARCH_LANGUAGE]];
        [imdiPadDatabase insertHistoryListTable:searchWord language:Lan username:[Util getUsername]];
        
    }
    
    
    
    //    [[NSUserDefaults standardUserDefaults] setObject:historyArray forKey:@"localHistory"];
    //    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:next] forKey:@"newestPos"];
    //
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

+(void)removeSearchHistory:(NSString*)searchWord Language:(NSString*)Lan
{
    
    [imdiPadDatabase deleteHistoryListTable:[NSString stringWithFormat:@"username = '%@' and searchword = '%@' and language = '%@'",[Util getUsername],searchWord,Lan]];
    
    //     NSMutableArray* historyArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"localHistory"] mutableCopy];
    //    int c=[historyArray count];
    //    if(c ==0)return;
    //
    //
    //    NSString* aValue =[NSString stringWithFormat:@"%@%@",Lan,searchWord];
    //    for(int i=0;i<c;i++)
    //    {
    //        NSString* v=[historyArray objectAtIndex:i];
    //        if([v isEqualToString:aValue])
    //        {
    //            [historyArray removeObjectAtIndex:i];
    //
    //            int p = [[[NSUserDefaults standardUserDefaults] objectForKey:@"newestPos"]intValue];
    //
    //
    //            [[NSUserDefaults standardUserDefaults] setObject:historyArray forKey:@"localHistory"];
    //            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(p-1+MAX_HISTORY)%MAX_HISTORY] forKey:@"newestPos"];
    //            [[NSUserDefaults standardUserDefaults] synchronize];
    //
    //
    //
    //
    //            return;
    //        }
    //
    //    }
    
    
    /*int c = [[[NSUserDefaults standardUserDefaults] objectForKey:@"historyCount"]intValue];
     
     if(c==0)return;
     
     NSString* aValue =[NSString stringWithFormat:@"%@%@",Lan,searchWord];
     
     int p = [[[NSUserDefaults standardUserDefaults] objectForKey:@"newestPos"]intValue];
     
     
     int posInLine =-1;
     
     for(int i=0;i<c;i++)
     {
     int thisp =(p-i+MAX_HISTORY) %MAX_HISTORY;
     NSString* thisValue =[searchHistory getSavedSearchHistory:thisp];
     
     if([thisValue isEqualToString:aValue])
     {
     posInLine =thisp;
     
     NSLog(@"p=%d c=%d, found %d",p,c,posInLine);
     break;
     }
     }
     
     
     if(posInLine !=-1)
     {
     BOOL ready=NO;
     int nextp= posInLine;
     while (!ready)
     {
     if(nextp==p)
     {
     ready =YES;
     }
     else
     {
     NSString* aValue =[searchHistory getSavedSearchHistory:(nextp+1)%MAX_HISTORY];
     
     NSString* newKey=[NSString stringWithFormat:@"saved%02d",nextp%MAX_HISTORY];
     
     [[NSUserDefaults standardUserDefaults] setObject:aValue forKey:newKey];
     [[NSUserDefaults standardUserDefaults] synchronize];
     
     nextp =(nextp+1)%MAX_HISTORY;
     }
     
     }
     [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(p-1+MAX_HISTORY)%MAX_HISTORY] forKey:@"newestPos"];
     [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:c-1] forKey:@"historyCount"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     
     
     }*/
    
}


+ (NSMutableArray *)getSavedSearchHistory{
    NSArray* historyArray = [imdiPadDatabase selectHistoryListTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername] ]];
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *historyArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dictionary in historyArray) {
        NSString *historyStr = [NSString stringWithFormat:@"%@%@",[dictionary objectForKey:KEY_SEARCH_LANGUAGE],[dictionary objectForKey:KEY_SEARCH_WORD]];
        [temp addObject:historyStr];
    }
  for (int i = temp.count-1; i > -1 ; i--) {
    [historyArr addObject:[temp objectAtIndex:i]];
  }
    return historyArr;
}

+(NSString*)getSavedSearchHistory:(int)pos
{
    NSArray* historyArray = [imdiPadDatabase selectHistoryListTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername] ]];
    NSMutableDictionary *history;
    NSLog(@"%@",historyArray);
    if (pos<[historyArray count]) {
        history = [historyArray objectAtIndex:pos];
    }else
    {
        return nil;
    }
    NSString *back = [NSString stringWithFormat:@"%@%@",[history objectForKey:KEY_SEARCH_LANGUAGE],[history objectForKey:KEY_SEARCH_WORD]];
    return back;
    
    //    NSArray* historyArray =[[NSUserDefaults standardUserDefaults] objectForKey:@"localHistory"];
    //    return [historyArray objectAtIndex:pos];
    
    //NSString* s=[NSString stringWithFormat:@"saved%02d",pos];
    //NSString* savedWord = [[NSUserDefaults standardUserDefaults] objectForKey:s];
    //return savedWord;
    
    
}

+(int)getHistoryCount
{
    NSArray* historyArray = [imdiPadDatabase selectHistoryListTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername] ]];
    return [historyArray count];
    
    //    NSArray* historyArray =[[NSUserDefaults standardUserDefaults] objectForKey:@"localHistory"];
    //
    //    return [historyArray count];
    
    //int c = [[[NSUserDefaults standardUserDefaults] objectForKey:@"historyCount"]intValue];
    
    //return c;
}

+(void)clearHistory
{
    [imdiPadDatabase deleteHistoryListTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername]]];
    //no historyCount
    //    NSMutableArray* historyArray =[[[NSMutableArray alloc] initWithCapacity:MAX_HISTORY] autorelease];
    //    [[NSUserDefaults standardUserDefaults] setObject:historyArray forKey:@"localHistory"];
    //     [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"newestPos"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"historyCount"];
    
    // [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(void)displayData
{
    //   NSArray* historyArray =[[NSUserDefaults standardUserDefaults] objectForKey:@"localHistory"];
    NSArray* historyArray = [imdiPadDatabase selectHistoryListTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername] ]];
    NSLog(@"history = %@",historyArray);
    
    //   int p = [[[NSUserDefaults standardUserDefaults] objectForKey:@"newestPos"]intValue];
    int p = [historyArray count];
    NSLog(@"p = %d",p);
    
}



@end
