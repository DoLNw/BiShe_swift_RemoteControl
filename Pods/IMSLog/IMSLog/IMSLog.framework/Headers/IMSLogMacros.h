//
//  IMSLogMacros.h
//  IMSLog
//
//  Created by muda on 2017/10/24.
//  Copyright © 2017年 muda. All rights reserved.

#import "IMSLog.h"

#define IMS_LOG_MACRO(isAsynchronous, flg, ctx, atag, frmt, ...)      \
        [IMSLog log : isAsynchronous                                  \
                    flag : flg                                        \
                 context : ctx                                        \
                    file : __FILE__                                   \
                function : __PRETTY_FUNCTION__                        \
                    line : __LINE__                                   \
                     tag : atag                                       \
                  format : (frmt), ## __VA_ARGS__]

#define IMS_LOG_CONTEXT 0
#define IMS_LOG_ASYNC_ENABLED YES

#define IMSLogError(tag,frmt,...) IMS_LOG_MACRO(NO, IMSLogFlagError,    IMS_LOG_CONTEXT, tag, frmt, ##__VA_ARGS__)
#define IMSLogWarn(tag,frmt,...) IMS_LOG_MACRO(IMS_LOG_ASYNC_ENABLED, IMSLogFlagWarning,    IMS_LOG_CONTEXT, tag, frmt, ##__VA_ARGS__)
#define IMSLogInfo(tag,frmt,...) IMS_LOG_MACRO(IMS_LOG_ASYNC_ENABLED, IMSLogFlagInfo,    IMS_LOG_CONTEXT, tag, frmt, ##__VA_ARGS__)
#define IMSLogDebug(tag,frmt,...) IMS_LOG_MACRO(IMS_LOG_ASYNC_ENABLED, IMSLogFlagDebug,    IMS_LOG_CONTEXT, tag, frmt, ##__VA_ARGS__)
#define IMSLogVerbose(tag,frmt,...) IMS_LOG_MACRO(IMS_LOG_ASYNC_ENABLED, IMSLogFlagVerbose,    IMS_LOG_CONTEXT, tag, frmt, ##__VA_ARGS__)
