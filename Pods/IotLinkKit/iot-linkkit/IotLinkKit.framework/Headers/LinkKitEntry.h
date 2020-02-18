//
//  LinkKitEntry.h
//  IotLinkKit
//
//  Created by 朱永利 on 2018/11/13.
//  Copyright © 2018年 朱永利. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinkkitDefine.h"
#import "LinkkitGateway.h"

NS_ASSUME_NONNULL_BEGIN

/**
 mqtt长连接通道配置信息
 */
@interface LinkkitChannelConfig : NSObject
@property(nonatomic, copy) NSString * productKey;///>IoT三元组之productKey
@property(nonatomic, copy) NSString * deviceName;///>IoT三元组之deviceName
@property(nonatomic, copy) NSString * deviceSecret;///>IoT三元组之deviceSecret
@property(nonatomic, copy, nullable) NSString * server;///>通道连接的服务器地址，如果为空，底层通道会使用默认的地址
@property(nonatomic, assign) int port;///>通道连接的服务器端口
@property(nonatomic, copy, nullable) NSString * cerPath;//TLS根证书路径，如果为空，会使用默认的证书
@property(nonatomic, assign) BOOL cleanSession;///>是否接收客户端离线消息，默认为YES，如果设为NO，当客户端上线后，会收到离线时所有的消息，请参见 mqtt CleanSession介绍
@end



/**
 Linkkit 初始化入参
 */
@interface LinkkitSetupParams : NSObject
@property(nonatomic, strong) LinkkitChannelConfig *channelConfig; ///>mqtt长连接通道配置信息
@property(nonatomic, copy) NSString *appVersion; ///>应用版本号
@end


/**
 mqtt长连接通道连接状态枚举
 - LinkkitChannelStateConnected: 已连接
 - LinkkitChannelStateDisconnected: 连接断开
 - LinkkitChannelStateConnecting: 连接中
 */
typedef NS_ENUM (NSInteger, LinkkitChannelConnectState){
    LinkkitChannelStateConnected = 1,
    LinkkitChannelStateDisconnected = 2,
    LinkkitChannelStateConnecting = 3,
};

@protocol LinkkitChannelListener <NSObject>

/**
通道连接状况改变，参见枚举LinkkitChannelConnectState

 @param connectId 通道id,如"persistent-connection"/"api-gateway"
 @param state 连接状态枚举值，参见枚举LinkkitChannelConnectState
 */
-(void)onConnectStateChange:(NSString *)connectId
                      state:(LinkkitChannelConnectState)state;


/**
 通道下推数据
 @param connectId 通道id,如"persistent-connection"/"api-gateway"
 @param topic 消息topic
 @param data 消息内容,NSString 或者 NSDictionary
 */
-(void)onNotify:(NSString *)connectId
          topic:(NSString *)topic
           data: (id _Nullable) data;


/**
数据使用onNotify:topic:data:上抛时，可以先过滤一遍，如返回NO，则不上传，返回YES，则会使用onNotify:topic:data:上抛

 @param connectId 通道id,如"persistent-connection"/"api-gateway"
 @param topic 消息topic
 @return YES/NO
 */
-(BOOL)shouldHandle:(NSString *)connectId
              topic:(NSString *)topic;
@end



/**
 Linkkit for iOS 入口类
 */
@interface LinkKitEntry : NSObject

/**
 单例方法

 @return 返回单例
 */
+ (instancetype)sharedKit;


/**
 linkkit初始化,建立长连接通道，上报设备信息

 @param setupParams 初始化入参
 @param resultBlock 结果回调
 */
- (void)setup:(LinkkitSetupParams *)setupParams
  resultBlock:(LinkkitBooleanResultBlock)resultBlock;



/**
 linkkit去初始化，会断开长连接通道

 @param resultBlock 结果回调
 */
- (void)destroy:(LinkkitBooleanResultBlock)resultBlock;


/**
 注册长连接通道事件listener

 @param listener 事件侦听者
 */
- (void)registerChannelListener:(id<LinkkitChannelListener>)listener;



/**
 取消注册长连接通道事件listener

 @param listener 事件侦听者
 */
- (void)unregisterChannelListener:(id<LinkkitChannelListener>)listener;

/**
 订阅自己的topic
 
 @param topic 想要订阅的topic，参见 mqtt协议
 @param resultBlock 订阅结果回调
 */
- (void)subscribe:(NSString *)topic resultBlock:(LinkkitBooleanResultBlock)resultBlock;


/**
 取消订阅自己的topic
 
 @param topic 想要取消订阅的topic，参见 mqtt协议
 @param resultBlock 取消订阅结果回调
 */
- (void)unsubscribe:(NSString *)topic resultBlock:(LinkkitBooleanResultBlock)resultBlock;





/**
 原始数据上行，使用 mqtt publish方法
 
 @param topic publish的topic，参见mqtt协议
 @param data 原始数据
 @param qos publish的qos，默认为 ‘1’ ，参见mqtt协议
 @param resultBlock 结果回调
 */
- (void)publish:(NSString *)topic
           data:(NSData *)data
            qos:(int)qos
    resultBlock:(LinkkitBooleanResultBlock)resultBlock;



/**
 网关相关操作接口
 */
@property(nonatomic, strong, readonly) id<LinkkitGateway> gatewayInterface;


/**
 长连接通道连接状态
 */
@property(nonatomic, assign, readonly) LinkkitChannelConnectState channelState;
@end

NS_ASSUME_NONNULL_END
