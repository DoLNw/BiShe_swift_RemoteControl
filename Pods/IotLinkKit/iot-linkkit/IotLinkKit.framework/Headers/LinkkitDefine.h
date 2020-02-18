//
//  LinkkitDefine.h
//  IotLinkKit
//
//  Created by 朱永利 on 2018/11/15.
//  Copyright © 2018年 朱永利. All rights reserved.
//


#import <Foundation/Foundation.h>

//#import <AKLog/AKLog.h>
#import <IMSLog/IMSLogMacros.h>

#define LinkkitTag @"LinkkitTag"

#define LinkkitLogError(frmt,...) IMS_LOG_MACRO(NO, IMSLogFlagError,    IMS_LOG_CONTEXT, LinkkitTag, frmt, ##__VA_ARGS__)
#define LinkkitLogWarn(frmt,...) IMS_LOG_MACRO(IMS_LOG_ASYNC_ENABLED, IMSLogFlagWarning,    IMS_LOG_CONTEXT, LinkkitTag, frmt, ##__VA_ARGS__)
#define LinkkitLogInfo(frmt,...) IMS_LOG_MACRO(IMS_LOG_ASYNC_ENABLED, IMSLogFlagInfo,    IMS_LOG_CONTEXT, LinkkitTag, frmt, ##__VA_ARGS__)
#define LinkkitLogDebug(frmt,...) IMS_LOG_MACRO(IMS_LOG_ASYNC_ENABLED, IMSLogFlagDebug,    IMS_LOG_CONTEXT, LinkkitTag, frmt, ##__VA_ARGS__)
#define LinkkitLogVerbose(frmt,...) IMS_LOG_MACRO(IMS_LOG_ASYNC_ENABLED, IMSLogFlagDebug,    IMS_LOG_CONTEXT, LinkkitTag, frmt, ##__VA_ARGS__)


#define LinkkitLogInit() [IMSLog registerTag:LinkkitTag];



typedef void (^LinkkitBooleanResultBlock)(BOOL succeeded, NSError * _Nullable error);
typedef void (^LinkkitObjectResultBlock)(NSDictionary * _Nullable object, NSError * _Nullable error);
typedef void (^LinkkitArrayResultBlock)(NSArray * _Nullable result, NSError * _Nullable error);
typedef void (^LinkkitEmptyResultBlock)(void);


//注意此处wjc加了个_Nullable
FOUNDATION_EXPORT NSString * _Nullable const LinkkitErrorDomain;

/**
 linkkit错误码
 */
typedef NS_ENUM(NSInteger, LinkkitErrorCode) {
    LinkkitErrorSuccess = 0,                     ///< 业务成功
    LinkkitErrorInvalidParams = 4200,///< 业务入参非法
    LinkkitErrorNotSetup = 4201,///< Linkkit未初始化
    LinkkitErrorChannelDisconnected = 4202,///< 长连接通道未连接
};
