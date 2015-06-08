//
//  url.h
//  imdPad
//
//  Created by 8fox on 8/8/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//
#define IDC_IPHONE_DOCSEARCH_URL 1  //1为IDC 0为QA
#if IDC_IPHONE_DOCSEARCH_URL
#define  MY_SEARCH_SERVER  @"www.i-md.com"
#define  MY_AUTH_SERVER  @"www.i-md.com"
#define MY_SERVER @"api.i-md.com"
#define NEW_SERVER @"accounts.i-md.com"
#else
#define  MY_SEARCH_SERVER  @"www.qa.i-md.com"
#define  MY_AUTH_SERVER  @"www.qa.i-md.com"
#define MY_SERVER @"api.qa.i-md.com"
#define NEW_SERVER @"accounts.qa.i-md.com"
#endif

//#define  MY_SEARCH_SERVER  @"192.168.1.55:9000"
//#define  MY_AUTH_SERVER  @"192.168.1.55:9000"
//#define MY_SERVER @"192.168.1.55:18020"
//#define NEW_SERVER @"192.168.1.55:19016"

