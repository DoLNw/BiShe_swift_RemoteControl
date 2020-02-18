//
//  IMSLog.h
//  IMSLog
//
//  Created by muda on 2017/10/24.
//  Copyright © 2017年 muda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMSLogMacros.h"
@class IMSLogMessage;
@class IMSLogRule;
@protocol IMSLogAssistant;

/**
 Flag,和 Level 一起协同过滤要输出的日志，每条 log 都有对应的 flag。
 
 */
typedef NS_OPTIONS(NSUInteger, IMSLogFlag){
    IMSLogFlagError      = (1 << 0),
    IMSLogFlagWarning    = (1 << 1),
    IMSLogFlagInfo       = (1 << 2),
    IMSLogFlagDebug      = (1 << 3),
    IMSLogFlagVerbose    = (1 << 4)
};

/**
 Level，日志级别，和 flag 一起协同过滤要输出的日志。
 
 */
typedef NS_ENUM(NSUInteger, IMSLogLevel){
    IMSLogLevelOff       = 0,
    IMSLogLevelError     = (IMSLogFlagError),
    IMSLogLevelWarning   = (IMSLogLevelError   | IMSLogFlagWarning),
    IMSLogLevelInfo      = (IMSLogLevelWarning | IMSLogFlagInfo),
    IMSLogLevelDebug     = (IMSLogLevelInfo    | IMSLogFlagDebug),
    IMSLogLevelVerbose   = (IMSLogLevelDebug   | IMSLogFlagVerbose),
    IMSLogLevelAll       = NSUIntegerMax
};


/**
 日志模块，提供客户端统一日志打印，日志等级控制，分模块日志隔离等能力，同时支持拓展日志输出的能力。
 */
@interface IMSLog : NSObject

/**
 注册需要输出日志的 tag
 
 日志模块以 tag 为维度对日志进行等级控制、隔离等操作，建议使用模块名称作为tag。
 
 @param tag 标签
 */
+ (void)registerTag:(NSString *_Nonnull)tag;


/**
 统一设置所有 tag 的显示日志级别
 
 若 tag 未设置级别，将不会输出对应 tag 的日志。
 
 @param level 日志级别
 */
+ (void)setAllTagsLevel:(IMSLogLevel) level;


/**
 设置 tag 对应的显示日志级别

 若 tag 未设置级别，将不会输出对应 tag 的日志。
 
 @param level 日志级别
 @param tag 标签
 */
+ (void)setLevel:(IMSLogLevel)level forTag:(NSString *_Nonnull)tag;


/**
 在控制台打印日志
 
 建议在 release 版本中关闭打印
 
 */
+ (void)showInConsole:(BOOL)show;

/**
 增加日志助手

 日志模块提供了将日志分发给日志助手的能力，方便第三方扩展 IMSLog 的功能。
 日志助手需遵守 IMSLogAssistant 协议。
 
 @param assistant 助手
 */
+ (void)addAssistant:(id  <IMSLogAssistant> _Nullable)assistant;


/**
 处理单条日志
 
 日志信息包括 flag,level,tag,日志描述，方法名，文件名

 */
+ (void)log:(BOOL)asynchronous
       flag:(IMSLogFlag)flag
    context:(NSInteger)context
       file:(const char *_Nullable)file
   function:(const char *_Nullable)function
       line:(NSUInteger)line
        tag:(id _Nullable )tag
     format:(NSString *_Nullable)format, ...;


/**
 处理日志的队列
 
 提供处理日志的当前队列，用于保持线程同步。

 */
+ (dispatch_queue_t _Nullable )loggingQueue;

/**
 Tag 和 Level 的映射表

 */
+(NSArray <IMSLogRule *>*_Nullable)tagLevelRules;

@end


/**
 IMSLogRule 类包含tag和Level的映射关系
 */
@interface IMSLogRule : NSObject

/**
 tag
 
 用于对日志进行等级控制、隔离等操作，建议使用模块名称作为tag。
 */
@property(nonatomic, copy, readonly) NSString * _Nullable tag;

/**
 日志级别
 
 用于过滤要输出的日志
 */
@property(nonatomic, assign, readonly) IMSLogLevel  level;
@end



/**
 IMSLogMessage 类包含日志信息
 */
@interface IMSLogMessage : NSObject

/**
 tag
 */
@property(nonatomic, copy) NSString * _Nullable tag;

/**
 日志消息
 */
@property(nonatomic, copy) NSString * _Nullable message;

/**
 日志flag
 */
@property(nonatomic, assign) IMSLogFlag  flag;

/**
 文件名
 */
@property(nonatomic, copy) NSString * _Nullable fileName;

/**
 方法名
 */
@property(nonatomic, copy) NSString * _Nullable function;

/**
 时间戳
 */
@property(nonatomic, strong) NSDate * _Nullable timestamp;

/**
 代码行数
 */
@property(nonatomic, assign) NSUInteger line;
@end


/**
 IMSLogAssistant 协议描述了日志助手应该实现的方法。
 */
@protocol IMSLogAssistant<NSObject>

/**
 日志分发
 
 用于将日志分发给日志助手，日志助手需重载该方法。
 */
- (void)logMessage:(IMSLogMessage *_Nullable)message;

@optional

/**
 兼容DDLog衍生工具的日志分发接口（可选）
 
 用于将日志分发给日志助手。
 */
- (void)log:(BOOL)asynchronous
      level:(IMSLogLevel)level
       flag:(IMSLogFlag)flag
    context:(NSInteger)context
       file:(const char *_Nullable)file
   function:(const char *_Nullable)function
       line:(NSUInteger)line
        tag:(id _Nullable )tag
     format:(NSString *_Nullable)format
       args:(va_list)argList;


@end;

