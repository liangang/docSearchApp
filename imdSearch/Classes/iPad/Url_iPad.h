//
//  Url_iPad.h
//  imdSearch
//
//  Created by ding zhihong on 12-3-27.
//  Copyright (c) 2012年 i-md.com. All rights reserved.
//

#ifndef imdSearch_Url_iPad_h
#define imdSearch_Url_iPad_h

/*
 url
 */
#define APP_STORE_VERSION_URL @"http://itunes.apple.com/lookup?id=%i&country=cn"
#define FEEDBACK_URL @"http://%@/feedback"
#define CHECK_EMAIL_URL @"http://%@/Profile/checkEmailAvailable/%@"
#define REGISTER_URL @"http://%@/users"
#define DEPARTMENT_URL @"http://%@/department/"


#define URL_FOR_PROVINCE @"http://accounts.i-md.com/hospital:cities?r=1352797588496"
  //@"192.168.2.22:19020"
/*
 Header Key
 */
#define CONTENT_TYPE @"Content-Type"
#define ACCEPT @"Accept"
#define POST @"POST"
#define USER_AGENT @"userAgent"
#define IMD_TOKEN @"imdToken"

/*
 Header Value
 */
#define TYPE_JSON @"application/json"
#define TOKEN_FORMAT @"imdToken=%@"

/*
 Feedback Value
 */
#define FEEDBACK_KEY_CONTENT @"content"
#define FEEDBACK_KEY_CONTACT @"emailOrPhone"

/*
 request key and value
 */
#define REQUEST_TYPE @"requestType"
#define REQUEST_FEEDBACK @"feedback"
#define REQUEST_CHECK_EMAIL @"checkMail"
#define REQUEST_CHECK_EMAIL_NEXT @"checkMailAtNext"
#define REQUEST_REGISTER_NEW @"registerNew"
#define REQUEST_GET_DEPARTMENT @"getDepartment"

#define FEEDBACK_PATH @"/feedback/"

/*
 Register Key
 */
#define KEY_USERID @"userid"
#define KEY_USERNAME @"username"
#define KEY_REALNAME @"realname"
#define KEY_PASSWORD @"password"
#define KEY_NICKNAME @"nickname"
#define KEY_DEPARTMENT @"department"
#define KEY_TITLE @"title"
#define KEY_HOSPITAL @"hospital"
#define KEY_SCHOOL @"school"
#define KEY_ADMISSIONYEAR @"admissionYear"
#define KEY_MAJOR @"major"
#define KEY_DEGREE @"degree"
//#define KEY_STUDENTID @"studentid"

/*
 Confirm
 */
#define KEY_MOBILE_CONFIRM @"mobile"

  //DOC
#define KEY_DOCU @"article"
#define KEY_DOC_EXTERNALID @"externalId"
#define KEY_DOC_PMID @"PMID"
#define KEY_DOC_WFID @"WFID"
#define KEY_DOC_WPID @"WPID"
#define KEY_DOC_CKID @"CKID"
#define KEY_DOC_ISFAV @"isFav"
#define KEY_DOC_ISLOGIN @"isLogin"
#define KEY_DOC_EMAIL_ACTIVE @"emailActive"
#define KEY_DOC_MOBILE_ACTIVE @"mobileActive"
#define KEY_DOC_FETCH_STATUS @"fetchStatus"
#define KEY_DOC_ABSTRACTTEXT @"abstractText"
#define ABSTRACT_TEXT @"text"
#define ABSTRACT_BACKGROUND @"background"
#define ABSTRACT_OBJECTIVE @"objective"
#define ABSTRACT_METHODS @"methods"
#define ABSTRACT_RESULTS @"results"
#define ABSTRACT_CONCLUSIONS @"conclusions"
#define ABSTRACT_COPYRIGHTS @"copyrights"
#define KEY_DOC_ABSTRACT_TEXT @"text"
#define KEY_DOC_ABSTRACT_BACKGROUND @"background"
#define KEY_DOC_ABSTRACT_OBJECTIVE @"objective"
#define KEY_DOC_ABSTRACT_METHODS @"methods"
#define KEY_DOC_ABSTRACT_RESULTS @"results"
#define KEY_DOC_ABSTRACT_CONCLUSIONS @"conclusions"
#define KEY_DOC_ABSTRACT_COPYRIGHTS @"copyrights"
#define KEY_DOC_AFFILIATION @"affiliation"
#define KEY_DOC_AUTHOR @"author"
#define KEY_DOC_CATEGORY @"category"
#define KEY_DOC_CITATION @"citation"
#define KEY_DOC_COREJOURNAL @"coreJournal"
#define KEY_DOC_ID @"id"
#define KEY_DOC_ISSUE @"issue"
#define KEY_DOC_JOURNAL @"journal"
#define KEY_DOC_KEYWORDS @"keywords"
#define KEY_DOC_MACHINE_CATEGORY @"machineCategory"
#define KEY_DOC_NUM_CITED @"numCited"
#define KEY_DOC_PAGINATION @"pagination"
#define KEY_DOC_PUB_DATE @"pubdate"
#define KEY_DOC_REFERENCE @"reference"
#define KEY_DOC_REFERENCE_COUNT @"referenceCount"
#define KEY_DOC_TITLE @"title"
#define KEY_DOC_VOLUME @"volume"
#define KEY_DOC_ISSN @"ISSN"
#define SEPARATING @"::"

  //search
#define KEY_SEARCH_SORT @"sort"
#define KEY_SEARCH_WORD @"word"
#define KEY_SEARCH_LANGUAGE @"language"

  //value
#define VLU_ACTIVED @"actived"
#define VLU_UNACTIVED @"unactived"

#endif
