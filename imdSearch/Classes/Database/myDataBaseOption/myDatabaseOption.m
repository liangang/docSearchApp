//
//  myDatabaseOption.m
//  imdSearch
//
//  Created by Lion User on 12-7-20.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#import "myDatabaseOption.h"
#import "imdiPadDatabase.h"
#import "Util.h"
#import "Url_iPad.h"
#import "DocDetail.h"

@implementation myDatabaseOption

+(void)docuSave:(NSMutableDictionary *)info
{
    if (info == nil) {
        //    return nil;
        return;
    }
    NSLog(@"docu ==== %@",info);
    NSDictionary *doc = [info objectForKey:KEY_DOCU];
    int isFav = [[info objectForKey:KEY_DOC_ISFAV] intValue];
    //  int isLogin = [[info objectForKey:KEY_DOC_ISLOGIN]intValue];
    int emailActive = [[info objectForKey:KEY_DOC_EMAIL_ACTIVE]intValue];
    int mobileActive = [[info objectForKey:KEY_DOC_MOBILE_ACTIVE]intValue];
    NSString *fetchStatus = [info objectForKey:KEY_DOC_FETCH_STATUS];
    NSString *username = [Util getUsername];
    NSString *eId = [self addDocument:doc];
    NSString *externalId = [doc objectForKey:KEY_DOC_EXTERNALID];
    NSString *PMID = [doc objectForKey:KEY_DOC_PMID];
    NSArray* authArray = [doc objectForKey:KEY_DOC_AUTHOR];
    NSString *author = [Util arrayToString:authArray sep:SEPARATING];
    NSString *issue = [doc objectForKey:KEY_DOC_ISSUE];
    NSString *journal = [doc objectForKey:KEY_DOC_JOURNAL];
    NSString *pagination = [doc objectForKey:KEY_DOC_PAGINATION];
    NSString *pubDate = [doc objectForKey:KEY_DOC_PUB_DATE];
    NSString *title = [doc objectForKey:KEY_DOC_TITLE];
    NSString *volume = [doc objectForKey:KEY_DOC_VOLUME];
    if (isFav == 1) {
        [self addFav:externalId author:author issue:issue journal:journal pubDate:pubDate title:title volume:volume pagination:pagination];
        //    [mDoc setIsFav:@"YES"];
    } else {
        [self removeFav:eId];
        //    [mDoc setIsFav:@"NO"];
    }
    [self addActive:emailActive mobile:mobileActive];
    //  if (isLogin == 1) {
    //    [mDoc setIsLogin:@"YES"];
    //  } else {
    //    [mDoc setIsLogin:@"NO"];
    //  }
    //  if (emailActive == 1) {
    //    [mDoc setIsEmailActive:@"YES"];
    //  } else {
    //    [mDoc setIsEmailActive:@"NO"];
    //  }
    //  if (mobileActive == 1) {
    //    [mDoc setIsMobileActive:@"YES"];
    //  } else {
    //    [mDoc setIsMobileActive:@"NO"];
    //  }
    if (eId.length > 0) {
        [self updateAskfor:eId username:username status:fetchStatus pmid:PMID author:author issue:issue journal:journal pagination:pagination pubdate:pubDate title:title volume:volume];
    }
    //  NSString *fs = [self fetchStatus:eId];
    //  NSString *where = [NSString stringWithFormat:@"externalId = '%@' and username = '%@'",eId,username];
    //  if (fetchStatus != nil && ![fetchStatus isEqualToString:@""]) {
    //    if ([fs isEqualToString:@""]) {
    //      [imdiPadDatabase insertAskforListTable:externalId username:username status:fetchStatus pmid:PMID requestTime:@"0" author:author issue:issue journal:journal pagination:pagination pubdate:pubDate title:title volume:volume];
    //    } else {
    //      if (![fs isEqualToString:fetchStatus]) {
    //
    //        [imdiPadDatabase updateAskforListTable:fetchStatus whereSql:where];
    //      }
    //    }
    //  } else {
    //    if (![fs isEqualToString:@""]) {
    //      [imdiPadDatabase deleteAskforListTable:where];
    //    }
    //  }
}

+(void)updateAskfor:(NSString *)externalId username:(NSString *)username status:(NSString *)status pmid:(NSString *)pmid author:(NSString *)author issue:(NSString *)issue journal:(NSString *)journal pagination:(NSString *)pagination pubdate:(NSString *)pubdate title:(NSString *)title volume:(NSString *)volume
{
    NSString *fs = [self fetchStatus:externalId];
    NSString *where = [NSString stringWithFormat:@"externalId = '%@' and username = '%@'",externalId,username];
    if (status != nil && ![status isEqualToString:@""]) {
        if (fs == nil || [fs isEqualToString:@""]) {
            [imdiPadDatabase insertAskforListTable:externalId username:username status:status pmid:pmid requestTime:@"0" author:author issue:issue journal:journal pagination:pagination pubdate:pubdate title:title volume:volume];
        } else {
            if (![fs isEqualToString:status]) {
                
                [imdiPadDatabase updateAskforListTable:status whereSql:where];
            }
        }
    } else {
        if (![fs isEqualToString:@""]) {
            [imdiPadDatabase deleteAskforListTable:where];
        }
    }
}

+(void)addActive:(int)email mobile:(int)mobile
{
    NSString *username = [Util getUsername];
    if ([username isEqualToString:@"null"]) {
        return;
    }
    NSString *emailActive = VLU_UNACTIVED;
    NSString *mobileActive = VLU_UNACTIVED;
    if (email == 1) {
        emailActive = VLU_ACTIVED;
    }
    if (mobile == 1) {
        mobileActive = VLU_ACTIVED;
    }
    if ([self isUsername:username]) {
        NSString *where = [NSString stringWithFormat:@"username = '%@'",username];
        [imdiPadDatabase updateUsernameTable:username email:emailActive mobile:mobileActive whereSql:where];
    } else {
        [imdiPadDatabase insertUsernameTable:username email:emailActive mobile:mobileActive];
    }
}

+(void)removeFav:(NSString *)externalId
{
    if (![self isFav:externalId]) {
        return;
    }
    NSString *where = [NSString stringWithFormat:@"externalId = '%@' and username = '%@'",externalId,[Util getUsername]];
    [imdiPadDatabase deleteFavListTable:where];
}

+(void)addFav:(NSString *)externalId author:(NSString *)author issue:(NSString *)issue journal:(NSString *)journal pubDate:(NSString *)pubDate title:(NSString *)title volume:(NSString *)volume pagination:(NSString *)pagination
{
    if ([self isFav:externalId]) {
        return;
    }
    [imdiPadDatabase insertFavListTable:externalId username:[Util getUsername] author:author issue:issue journal:journal pubDate:pubDate title:title volume:volume pagination:pagination];
}

+(NSString *)addDocument:(NSDictionary *)doc
{
    if (doc == nil) {
        return nil;
    }
    
    NSString *externalId = [doc objectForKey:KEY_DOC_EXTERNALID];
    NSString *CKID = [doc objectForKey:KEY_DOC_CKID];
    NSString *WFID = [doc objectForKey:KEY_DOC_WFID];
    NSString *WPID = [doc objectForKey:KEY_DOC_WPID];
    NSString *PMID = [doc objectForKey:KEY_DOC_PMID];
    NSDictionary *abstractText = [doc objectForKey:KEY_DOC_ABSTRACTTEXT];
    NSArray *textArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_TEXT];
    NSMutableString* text =[NSMutableString stringWithString:@""];
    if (textArray != (id)[NSNull null] && [textArray count] > 0) {
        NSLog(@"textArray============ %@",textArray);
        for(int i =0; i<[textArray count];i++)
        {
            if(![text isEqualToString:@""]) {
                [text appendString:SEPARATING];
            }
            
            NSString* aStr =[textArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [text appendString:aStr];
        }
    }
    NSArray *bgArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_BACKGROUND];
    //  [back setBackground:bgArray];
    NSMutableString* background =[NSMutableString stringWithString:@""];
    if (bgArray != (id)[NSNull null] && [bgArray count] > 0) {
        NSLog(@"bgArray============ %@",bgArray);
        for(int i =0; i<[bgArray count];i++)
        {
            if(![background isEqualToString:@""]) {
                [background appendString:SEPARATING];
            }
            NSString* aStr =[bgArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [background appendString:aStr];
        }
    }
    NSArray *objArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_OBJECTIVE];
    //  [back setObjective:objArray];
    NSMutableString* objective =[NSMutableString stringWithString:@""];
    if (objArray != (id)[NSNull null] && [objArray count] > 0) {
        NSLog(@"objArray============ %@",objArray);
        for(int i =0; i<[objArray count];i++)
        {
            if(![objective isEqualToString:@""]) {
                [objective appendString:SEPARATING];
            }
            NSString* aStr =[objArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [objective appendString:aStr];
        }
    }
    NSArray *metArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_METHODS];
    //  [back setMethods:metArray];
    NSMutableString* methods =[NSMutableString stringWithString:@""];
    if (metArray != (id)[NSNull null] && [metArray count] > 0) {
        NSLog(@"metArray============ %@",metArray);
        for(int i =0; i<[metArray count];i++)
        {
            if(![methods isEqualToString:@""]) {
                [methods appendString:SEPARATING];
            }
            NSString* aStr =[metArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [methods appendString:aStr];
        }
    }
    NSArray *resArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_RESULTS];
    //  [back setResults:resArray];
    NSMutableString* results =[NSMutableString stringWithString:@""];
    if (resArray != (id)[NSNull null] && [resArray count] > 0) {
        NSLog(@"resArray============ %@",resArray);
        for(int i =0; i<[resArray count];i++)
        {
            if(![results isEqualToString:@""]) {
                [results appendString:SEPARATING];
            }
            NSString* aStr =[resArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [results appendString:aStr];
        }
    }
    NSArray *conArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_CONCLUSIONS];
    //  [back setConclusions:conArray];
    NSMutableString* conclusions =[NSMutableString stringWithString:@""];
    if (conArray != (id)[NSNull null] && [conArray count] > 0) {
        NSLog(@"conArray============ %@",conArray);
        for(int i =0; i<[conArray count];i++)
        {
            if(![conclusions isEqualToString:@""]) {
                [conclusions appendString:SEPARATING];
            }
            NSString* aStr =[conArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [conclusions appendString:aStr];
        }
    }
    NSArray *copyArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_COPYRIGHTS];
    //  [back setCopyrights:copyArray];
    NSMutableString* copyrights =[NSMutableString stringWithString:@""];
    if (copyArray != (id)[NSNull null] && [copyArray count] > 0) {
        NSLog(@"copyArray============ %@",copyArray);
        for(int i =0; i<[copyArray count];i++)
        {
            if(![copyrights isEqualToString:@""]) {
                [copyrights appendString:SEPARATING];
            }
            NSString* aStr =[copyArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [copyrights appendString:aStr];
        }
    }
    NSArray* affiArray =[doc objectForKey:KEY_DOC_AFFILIATION];
    //  [back setAffiliation:affiArray];
    NSString *affiliation = [Util arrayToString:affiArray sep:SEPARATING];
    //  if (affiArray != nil && [affiArray count] > 0) {
    //    affiliation = [affiArray objectAtIndex:0];
    //    for (int i=1; i < [affiArray count]; i++) {
    //      affiliation = [NSString stringWithFormat:@"%@%@%@",affiliation,SEPARATING,[affiArray objectAtIndex:i]];
    //    }
    //  }
    NSArray* authArray = [doc objectForKey:KEY_DOC_AUTHOR];
    //  [back setAuthor:authArray];
    NSString *author = [Util arrayToString:authArray sep:SEPARATING];
    //  if (authArray != nil && [authArray count] > 0) {
    //    author = [authArray objectAtIndex:0];
    //    for (int i=1; i < [authArray count]; i++) {
    //      author = [NSString stringWithFormat:@"%@%@%@",author,SEPARATING,[authArray objectAtIndex:i]];
    //    }
    //  }
    NSArray* cateArray = [doc objectForKey:KEY_DOC_CATEGORY];
    //  [back setCategory:cateArray];
    NSString *category = [Util arrayToString:cateArray sep:SEPARATING];
    //  if (cateArray != nil && [cateArray count] > 0) {
    //    category = [cateArray objectAtIndex:0];
    //    for (int i=1; i < [cateArray count]; i++) {
    //      category = [NSString stringWithFormat:@"%@%@%@",category,SEPARATING,[cateArray objectAtIndex:i]];
    //    }
    //  }
    NSArray* citaArray = [doc objectForKey:KEY_DOC_CITATION];
    //  [back setCitation:citaArray];
    NSString *citation = [Util arrayToString:citaArray sep:SEPARATING];
    
    NSString *coreJournal = [doc objectForKey:KEY_DOC_COREJOURNAL];
    //  [back setCoreJournal:coreJournal];
    NSString *iid = [doc objectForKey:KEY_DOC_ID];
    //  [back setIid:iid];
    NSString *issue = [doc objectForKey:KEY_DOC_ISSUE];
    //  [back setIssue:issue];
    NSString *journal = [doc objectForKey:KEY_DOC_JOURNAL];
    //  [back setJournal:journal];
    
    NSArray* kwArray = [doc objectForKey:KEY_DOC_KEYWORDS];
    //  [back setKeywords:kwArray];
    NSString *keywords = [Util arrayToString:kwArray sep:SEPARATING];
    
    NSArray* mcArray = [doc objectForKey:KEY_DOC_MACHINE_CATEGORY];
    //  [back setMachineCategory:mcArray];
    NSString *machineCategory = [Util arrayToString:mcArray sep:SEPARATING];
    
    NSString *numCited = [doc objectForKey:KEY_DOC_NUM_CITED];
    //  [back setNumCited:numCited];
    NSString *pagination = [doc objectForKey:KEY_DOC_PAGINATION];
    //  [back setPagination:pagination];
    NSString *pubDate = [doc objectForKey:KEY_DOC_PUB_DATE];
    //  [back setPubDate:pubDate];
    
    NSArray* rfrcArray = [doc objectForKey:KEY_DOC_REFERENCE];
    //  [back setReference:rfrcArray];
    NSString *reference = [Util arrayToString:rfrcArray sep:SEPARATING];
    
    NSString *referenceCount = [doc objectForKey:KEY_DOC_REFERENCE_COUNT];
    //  [back setReferenceCount:referenceCount];
    NSString *title = [doc objectForKey:KEY_DOC_TITLE];
    //  [back setTitle:title];
    NSString *volume = [doc objectForKey:KEY_DOC_VOLUME];
    //  [back setVolume:volume];
    NSString *ISSN = [doc objectForKey:KEY_DOC_ISSN];
    //  [back setISSN:ISSN];
    if (externalId.length > 0) {
        [imdiPadDatabase insertDocTable:externalId CKID:CKID WFID:WFID WPID:WPID PMID:PMID text:text background:background objective:objective methods:methods results:results conclusions:conclusions copyrights:copyrights affiliation:affiliation author:author category:category citation:citation corejournal:coreJournal iid:iid issue:issue journal:journal keywords:keywords machineCategory:machineCategory numcited:numCited pagination:pagination pubDate:pubDate reference:reference referenceCount:referenceCount title:title volume:volume ISSN:ISSN];
    }
    //  return [back autorelease];
    return externalId;
}

+(NSMutableDictionary *)getDetail:(NSString *)externalId
{
    NSString *username = [Util getUsername];
    //  NSString *where = [NSString stringWithFormat:@" externalId = '%@'",externalId];
    @try {
        NSMutableDictionary *doc = [imdiPadDatabase selectDocTable:externalId];
        
        if (doc == nil) {
            return nil;
        }
        NSLog(@"doc === %@",doc);
        NSMutableDictionary *docu = [[NSMutableDictionary alloc]init ];
        [docu setObject:doc forKey:KEY_DOCU];
        if ([self isFav:externalId]) {
            [docu setObject:[NSNumber numberWithInt:1] forKey:KEY_DOC_ISFAV];
        } else {
            [docu setObject:[NSNumber numberWithInt:0] forKey:KEY_DOC_ISFAV];
        }
        if ([username isEqualToString:@"null"]) {
            [docu setObject:[NSNumber numberWithInt:0] forKey:KEY_DOC_ISLOGIN];
            [docu setObject:[NSNumber numberWithInt:0] forKey:KEY_DOC_EMAIL_ACTIVE];
            [docu setObject:[NSNumber numberWithInt:0] forKey:KEY_DOC_MOBILE_ACTIVE];
        } else {
            [docu setObject:[NSNumber numberWithInt:1] forKey:KEY_DOC_ISLOGIN];
            if ([self isMailActive:username]) {
                [docu setObject:[NSNumber numberWithInt:1] forKey:KEY_DOC_EMAIL_ACTIVE];
            } else {
                [docu setObject:[NSNumber numberWithInt:0] forKey:KEY_DOC_EMAIL_ACTIVE];
            }
            if ([self isMobileActive:username]) {
                [docu setObject:[NSNumber numberWithInt:1] forKey:KEY_DOC_MOBILE_ACTIVE];
            } else {
                [docu setObject:[NSNumber numberWithInt:0] forKey:KEY_DOC_MOBILE_ACTIVE];
            }
        }
        NSString *fetchStatus = [self fetchStatus:externalId];
        if (fetchStatus != nil) {
            [docu setObject:fetchStatus forKey:KEY_DOC_FETCH_STATUS];
        }
        
        return docu;
    }
    @catch (NSException *exception) {
        NSLog(@"error: %@",[exception description]);
        return nil;
    }
}

+(NSString *)fetchStatus:(NSString *)externalId
{
    NSString *where = [NSString stringWithFormat:@"externalId = '%@' and username = '%@'",externalId,[Util getUsername]];
    NSMutableArray *ask = [imdiPadDatabase selectAskforTable:where];
    if (![ask count]) {
        return @"";
    } else {
        NSMutableDictionary *aa = [ask objectAtIndex:0];
        NSString *status = [aa objectForKey:KEY_DOC_FETCH_STATUS];
        return status;
    }
}

+(BOOL)isUsername:(NSString *)username
{
    NSString *where = [NSString stringWithFormat:@"username = '%@'",username];
    NSMutableArray *mA = [imdiPadDatabase selectUsernameTable:where];
    if (![mA count]) {
        return NO;
    } else {
        return YES;
    }
}

+(BOOL)isMobileActive:(NSString *)username
{
    NSString *where = [NSString stringWithFormat:@"username = '%@'",username];
    NSMutableArray *mA = [imdiPadDatabase selectUsernameTable:where];
    if (![mA count]) {
        return NO;
    } else {
        NSMutableDictionary *un = [mA objectAtIndex:0];
        NSString *mA = [un objectForKey:KEY_DOC_MOBILE_ACTIVE];
        //    [un release];
        if ([mA isEqualToString:VLU_ACTIVED]) {
            return YES;
        } else {
            return NO;
        }
    }
}

+(BOOL)isMailActive:(NSString *)username
{
    NSString *where = [NSString stringWithFormat:@"username = '%@'",username];
    NSMutableArray *mA = [imdiPadDatabase selectUsernameTable:where];
    if (![mA count]) {
        return NO;
    } else {
        NSMutableDictionary *un = [mA objectAtIndex:0];
        NSString *eA = [un objectForKey:KEY_DOC_EMAIL_ACTIVE];
        //    [un release];
        if ([eA isEqualToString:VLU_ACTIVED]) {
            return YES;
        } else {
            return NO;
        }
    }
}

+(BOOL)isFav:(NSString *)externalId
{
    NSString *where = [NSString stringWithFormat:@" externalId = '%@' and username = '%@'",externalId,[Util getUsername]];
    NSMutableArray *fav = [imdiPadDatabase selectFavListTable:where];
    if (![fav count]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark -- Favorite List
+(void)favsSave:(NSMutableArray *)info
{
    NSMutableArray *favs = [self getFavs];
    if ([favs count]) {
        [imdiPadDatabase deleteFavListTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername]]];
    }
    if (info != nil && [info count] > 0) {
        NSMutableArray *data = [info copy];
        for (int i = 0; i < [data count]; i++) {
            NSMutableDictionary *favorite = [info objectAtIndex:i];
            
            NSArray *authorArray = [favorite objectForKey:KEY_DOC_AUTHOR];
            NSString *autherlist = nil;
            if (authorArray != nil && [authorArray count]) {
                NSMutableString *authors = [[NSMutableString alloc] initWithFormat:@""];;
                for (int i = 0; i < [authorArray count]; i++) {
                    if (i > 0) {
                        [authors appendString:SEPARATING];
                    }
                    [authors appendString:[authorArray objectAtIndex:i]];
                }
                autherlist = [authors copy];
            }
            //      [authorArray release];
            NSString *externalId = [favorite objectForKey:KEY_DOC_EXTERNALID];
            NSString *issue = [favorite objectForKey:KEY_DOC_ISSUE];
            NSString *journal = [favorite objectForKey:KEY_DOC_JOURNAL];
            NSString *pagination = [favorite objectForKey:KEY_DOC_PAGINATION];
            NSString *pubDate = [favorite objectForKey:KEY_DOC_PUB_DATE];
            NSString *title = [favorite objectForKey:KEY_DOC_TITLE];
            NSString *volume = [favorite objectForKey:KEY_DOC_VOLUME];
            [imdiPadDatabase insertFavListTable:externalId username:[Util getUsername] author:autherlist issue:issue journal:journal pubDate:pubDate title:title volume:volume pagination:pagination];
        }
    }
}

+(NSMutableArray *)getFavs
{
    NSMutableArray *favs = [imdiPadDatabase selectFavListTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername]]];
    return favs;
}

#pragma mark -- asked list
+(void)askedSave:(NSMutableArray *)info
{
    NSMutableArray *askedList = [self getAsked];
    if ([askedList count]) {
        [imdiPadDatabase deleteAskforListTable:[NSString stringWithFormat:@"username = '%@' and status = 'SUCCESS'",[Util getUsername]]];
    }
    if (info != nil && [info count] > 0) {
        NSMutableArray *data = [info copy];
        for (int i = 0; i < [data count]; i++) {
            NSMutableDictionary *asked = [info objectAtIndex:i];
            
            NSString *pmid = [asked objectForKey:@"pmid"];
            NSString *requestTime = [NSString stringWithFormat:@"%lld",[[asked objectForKey:@"requestTime"]longLongValue]];
            NSString *status = [asked objectForKey:@"status"];
            NSMutableDictionary *sdi = [asked objectForKey:@"shortDocInfo"];
            NSArray *authArray = [sdi objectForKey:KEY_DOC_AUTHOR];
            NSString *authors = nil;
            if ([authArray count]) {
                NSMutableString *auth = [[NSMutableString alloc] initWithFormat:@""];
                for (int i = 0; i < [authArray count]; i++) {
                    if (i > 0) {
                        [auth appendString:SEPARATING];
                    }
                    [auth appendString:[authArray objectAtIndex:i]];
                }
                authors = [auth copy];
                //        [auth release];
            }
            NSString *externalId = [sdi objectForKey:@"id"];
            NSString *issue = [sdi objectForKey:KEY_DOC_ISSUE];
            NSString *journal = [sdi objectForKey:KEY_DOC_JOURNAL];
            NSString *pagination = [sdi objectForKey:KEY_DOC_PAGINATION];
            NSString *pubdate = [sdi objectForKey:@"pubdate"];
            NSString *title = [sdi objectForKey:KEY_DOC_TITLE];
            NSString *volume = [sdi objectForKey:KEY_DOC_VOLUME];
            [imdiPadDatabase insertAskforListTable:externalId username:[Util getUsername] status:status pmid:pmid requestTime:requestTime author:authors issue:issue journal:journal pagination:pagination pubdate:pubdate title:title volume:volume];
        }
    }
}

+(NSMutableArray *)getAsked
{
    NSMutableArray *asked = [imdiPadDatabase selectAskforTable:[NSString stringWithFormat:@"username = '%@' and status = 'SUCCESS'",[Util getUsername]]];
    return asked;
}

#pragma mark -- detail
+(void)searchDetail:(NSString *)externalId
{
    if (externalId == nil || [externalId isEqualToString:@""]) {
        return;
    }
    if ([self isRead:externalId]) {
        return;
    }
    [imdiPadDatabase insertDetailTable:externalId username:[Util getUsername]];
}

+(NSArray *)getReads
{
    NSMutableArray *data = [imdiPadDatabase selectDetailTable:[NSString stringWithFormat:@"username = '%@'",[Util getUsername]]];
    return data;
}

+(BOOL)isRead:(NSString *)externalId
{
    NSMutableArray *data = [imdiPadDatabase selectDetailTable:[NSString stringWithFormat:@"externalId = '%@' and username = '%@'",externalId,[Util getUsername]]];
    if ([data count]) {
        return true;
    }
    return false;
}

#pragma mark -- Saved Docs
+(void)changeOlderVision
{
    NSArray *docs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"downloadArrays"] mutableCopy];
    NSLog(@"docs == %@", docs);
    if ([docs count]) {
        for (int i = 0; i < [docs count]; i++) {
            NSDictionary *doc = [docs objectAtIndex:i];
            [myDatabaseOption savedDoc:doc];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"downloadArrays"];
    }
}

+(void)savedDoc:(NSDictionary *)docInfo
{
    NSLog(@"save docInfo === %@", docInfo);
    //affiliation
    NSArray* affiliations =[docInfo objectForKey:KEY_DOC_AFFILIATION];
    NSString *affiliation = [Util arrayToString:affiliations sep:SEPARATING];
    //author
    NSArray* authors =[docInfo objectForKey:KEY_DOC_AUTHOR];
    NSString *author = [Util arrayToString:authors sep:SEPARATING];
    //externalId
    NSString *externalId = [docInfo objectForKey:KEY_DOC_EXTERNALID];
    //issue
    NSString* issue = [docInfo objectForKey:@"issue"];
    //journal
    NSString* journal =[docInfo objectForKey:@"journal"];
    //pubDate
    NSString* pubDate =[docInfo objectForKey:@"pubDate"];
    //title
    NSString* title = [docInfo objectForKey:@"title"];
    //volume
    NSString* volume = [docInfo objectForKey:@"volume"];
    //pagination
    NSString* pagination = [docInfo objectForKey:@"pagination"];
    NSDictionary *abstractText = [docInfo objectForKey:KEY_DOC_ABSTRACTTEXT];
    NSArray *textArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_TEXT];
    //  [back setText:textArray];
    NSMutableString* text =[NSMutableString stringWithString:@""];
    if (textArray != (id)[NSNull null] && [textArray count] > 0) {
        NSLog(@"textArray============ %@",textArray);
        for(int i =0; i<[textArray count];i++)
        {
            if(![text isEqualToString:@""]) {
                [text appendString:SEPARATING];
            }
            
            NSString* aStr =[textArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [text appendString:aStr];
        }
    }
    NSArray *bgArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_BACKGROUND];
    //  [back setBackground:bgArray];
    NSMutableString* background =[NSMutableString stringWithString:@""];
    if (bgArray != (id)[NSNull null] && [bgArray count] > 0) {
        NSLog(@"bgArray============ %@",bgArray);
        for(int i =0; i<[bgArray count];i++)
        {
            if(![background isEqualToString:@""]) {
                [background appendString:SEPARATING];
            }
            NSString* aStr =[bgArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [background appendString:aStr];
        }
    }
    NSArray *objArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_OBJECTIVE];
    //  [back setObjective:objArray];
    NSMutableString* objective =[NSMutableString stringWithString:@""];
    if (objArray != (id)[NSNull null] && [objArray count] > 0) {
        NSLog(@"objArray============ %@",objArray);
        for(int i =0; i<[objArray count];i++)
        {
            if(![objective isEqualToString:@""]) {
                [objective appendString:SEPARATING];
            }
            NSString* aStr =[objArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [objective appendString:aStr];
        }
    }
    NSArray *metArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_METHODS];
    //  [back setMethods:metArray];
    NSMutableString* methods =[NSMutableString stringWithString:@""];
    if (metArray != (id)[NSNull null] && [metArray count] > 0) {
        NSLog(@"metArray============ %@",metArray);
        for(int i =0; i<[metArray count];i++)
        {
            if(![methods isEqualToString:@""]) {
                [methods appendString:SEPARATING];
            }
            NSString* aStr =[metArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [methods appendString:aStr];
        }
    }
    NSArray *resArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_RESULTS];
    //  [back setResults:resArray];
    NSMutableString* results =[NSMutableString stringWithString:@""];
    if (resArray != (id)[NSNull null] && [resArray count] > 0) {
        NSLog(@"resArray============ %@",resArray);
        for(int i =0; i<[resArray count];i++)
        {
            if(![results isEqualToString:@""]) {
                [results appendString:SEPARATING];
            }
            NSString* aStr =[resArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [results appendString:aStr];
        }
    }
    NSArray *conArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_CONCLUSIONS];
    //  [back setConclusions:conArray];
    NSMutableString* conclusions =[NSMutableString stringWithString:@""];
    if (conArray != (id)[NSNull null] && [conArray count] > 0) {
        NSLog(@"conArray============ %@",conArray);
        for(int i =0; i<[conArray count];i++)
        {
            if(![conclusions isEqualToString:@""]) {
                [conclusions appendString:SEPARATING];
            }
            NSString* aStr =[conArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [conclusions appendString:aStr];
        }
    }
    NSArray *copyArray = [abstractText objectForKey:KEY_DOC_ABSTRACT_COPYRIGHTS];
    //  [back setCopyrights:copyArray];
    NSMutableString* copyrights =[NSMutableString stringWithString:@""];
    if (copyArray != (id)[NSNull null] && [copyArray count] > 0) {
        NSLog(@"copyArray============ %@",copyArray);
        for(int i =0; i<[copyArray count];i++)
        {
            if(![copyrights isEqualToString:@""]) {
                [copyrights appendString:SEPARATING];
            }
            NSString* aStr =[copyArray objectAtIndex:i];
            aStr = [Util replaceEM:aStr LeftMark:@"" RightMark:@""];
            aStr = [Util stringURLDecoding:aStr];
            [copyrights appendString:aStr];
        } 
    }
    NSArray* kwArray = [docInfo objectForKey:KEY_DOC_KEYWORDS];
    NSString *keywords = [Util arrayToString:kwArray sep:SEPARATING];
    [imdiPadDatabase insertSavedDocTable:externalId username:[Util getUsername] affiliation:affiliation author:author issue:issue journal:journal pagination:pagination pubdate:pubDate title:title volume:volume text:text background:background objective:objective methods:methods results:results conclusions:conclusions copyrights:copyrights keywords:keywords];
}

+(NSMutableArray *)getSavedDoc
{
    NSString *where = [NSString stringWithFormat:@"username = '%@'", [Util getUsername]];
    NSMutableArray *back = [imdiPadDatabase selectSavedDocTable:where];
    return back;
}

+(void)removeSavedDoc:(NSString *)externalId
{
    if ([self isSaved:externalId]) {
        NSString *where = [NSString stringWithFormat:@"externalId = '%@' and username = '%@'",externalId,[Util getUsername]];
        [imdiPadDatabase deleteSavedDocTable:where];
    }
}

+(BOOL)isSaved:(NSString *)externalId
{
    NSMutableArray *data = [imdiPadDatabase selectSavedDocTable:[NSString stringWithFormat:@"externalId = '%@' and username = '%@'",externalId,[Util getUsername]]];
    if ([data count]) {
        return true;
    }
    return false;
}

+(BOOL)isSavedDocWithAnother:(NSString *)externalId
{
    NSMutableArray *data = [imdiPadDatabase selectSavedDocTable:[NSString stringWithFormat:@"externalId = '%@'",externalId]];
    if ([data count]) {
        return true;
    }
    return false;
}

@end
