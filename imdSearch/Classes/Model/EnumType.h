//
//  EnumType.h
//  imdSearch
//
//  Created by xiangzhang on 5/20/14.
//  Copyright (c) 2014 i-md.com. All rights reserved.
//

#ifndef imdSearch_EnumType_h
#define imdSearch_EnumType_h

/**
 *  设置里的item类型
 */
typedef enum {
    SettingItemLogin = 2012,
    SettingItemUserCenter,
    SettingItemExitAccount,
    SettingItemsInviteRegister,
    SettingItemWIFIOn,
    SettingItemDocNotification,
    SettingItemClearBuffer,
    SettingItemFeedback,
    SettingItemComment,
    SettingItemAboutUs,
    SettingItemDisclaimer,
    SettingItemAPP,
    SettingItemVersion
}SettingItems;

/**
 *  我的文献里的内容分类
 */
typedef enum{
    ListTypeRecord = 0,
    ListTypeCollection,
    ListTypeLocation
}ListType;

/**
 *  文章类型
 */
typedef enum {
    DocTypeAll = 0,
    DocTypeCH,
    DocTypeEN
} DocType;

/**
 *  来源的菜单页
 */
typedef NS_ENUM(NSInteger, MeunSoruce) {
    /**
     *  搜索菜单也
     */
    MeunSoruceSearch = 0,
    /**
     *  我的文档菜单页
     */
    MeunSoruceMyDocument
};

/**
 *  model 页面的类型
 */
typedef NS_ENUM(NSInteger, PresentType) {
    /**
     *  model登录页面
     */
    PresentTypeLoginView,
    /**
     *  model 邀请注册页面
     */
    PresentTypeInviteFriendView,
    /**
     *  model验证页面
     */
    PresentTypeVerifiedView,
    /**
     *  model注册成功页
     */
    PresentTypeRegisterSuccessView,
  /**
   *  model选择医生或学生页
   */
  PresentUserTypeView
};

#endif
