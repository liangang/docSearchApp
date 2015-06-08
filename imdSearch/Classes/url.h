//
//  url.h
//  imdPad
//
//  Created by 8fox on 8/8/11.
//  Copyright 2011 i-MD.com. All rights reserved.
//


/// ====== AUTH ========
  //#define  AUTH_SERVER  @"www.i-md.com"
#define IDC_IPAD_DOCSEARCH_URL 1   //1为IDC 0为QA

#if IDC_IPAD_DOCSEARCH_URL
#define  NETSTATUS_SERVER  @"www.i-md.com"
#define  AUTH_SERVER  @"www.i-md.com/client"
#define  REGISTER_SERVER  @"www.i-md.com/client"

#define  SEARCH_SERVER  @"www.i-md.com/client"
#define  CONFIRM_SERVER @"www.i-md.com/client"
#define  PDFPROCESS_SERVER @"www.i-md.com/client"
#define NEW_SERVER_IPAD @"accounts.i-md.com"
#define MY_SERVERS @"api.i-md.com"
#else
#define  NETSTATUS_SERVER  @"www.qa.i-md.com"
#define  AUTH_SERVER  @"www.qa.i-md.com/client"
#define  REGISTER_SERVER  @"www.qa.i-md.com/client"

#define  SEARCH_SERVER  @"www.qa.i-md.com/client"
#define  CONFIRM_SERVER @"www.qa.i-md.com/client"
#define  PDFPROCESS_SERVER @"www.qa.i-md.com/client"
#define NEW_SERVER_IPAD @"accounts.qa.i-md.com"
#define MY_SERVERS @"api.qa.i-md.com"
#endif
//#define  NETSTATUS_SERVER  @"@192.168.1.55:19016/client"
////for out test
//#define  AUTH_SERVER  @"@192.168.1.55:9000/client"
//#define  REGISTER_SERVER  @"@192.168.3.29:9000/client"
//
//#define  SEARCH_SERVER  @"@192.168.3.29:9000/client"
//#define  CONFIRM_SERVER @"@192.168.3.29:9000/client"
//#define  PDFPROCESS_SERVER @"@192.168.3.29:9000/client"