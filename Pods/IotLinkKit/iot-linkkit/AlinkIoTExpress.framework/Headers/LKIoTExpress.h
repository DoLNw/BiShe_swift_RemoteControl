/*
 * Copyright (c) 2014-2016 Alibaba Group. All rights reserved.
 * License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

//
//  LKNecsExpress.h
//  AlinkNecsChannel
//
//  Created by ZhuYongli on 2017/10/31.
//  Copyright © 2017年 ZhuYongli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSError+LKExpUtils.h"

NS_ASSUME_NONNULL_BEGIN


@interface LKIoTConnectConfig :NSObject
@property(nonatomic, copy) NSString * productKey;///>IoT三元组之productKey
@property(nonatomic, copy) NSString * deviceName;///>IoT三元组之deviceName
@property(nonatomic, copy) NSString * deviceSecret;///>IoT三元组之deviceSecret
@property(nonatomic, copy, nullable) NSString * server;///>通道连接的服务器地址，如果为空，底层通道会使用默认的地址
@property(nonatomic, assign) int port;///>通道连接的服务器端口
@property (nonatomic, assign) BOOL autoSelectChannelHost;///<<当 `server` 不指定时，且是在中国大陆以外地区使用，请将此值设置为 YES, 如果是在中国大陆使用时，则将此值设置为 NO。
//@property(nonatomic, assign) BOOL inSecure;//是否使用不安全的TLS连接 (即不校验服务器证书)， 默认为NO。如果设为YES，会放弃校验服务器证书
@property(nonatomic, copy, nullable) NSString * cerPath;//TLS证书路径，如果为空，会使用默认的证书
@property(nonatomic, assign) BOOL receiveOfflineMsg;///>是否接收客户端离线消息，默认为NO，如果设为YES，当客户端上线后，会收到离线时所有的消息
@end

typedef NS_ENUM (NSInteger, LKExpressConnectState){
    LKExpressConnectStateConnected = 1,
    LKExpressConnectStateDisconnected = 2,
    LKExpressConnectStateConnecting = 3,
};

typedef NS_ENUM (NSInteger, LKExpressDownListenerType){
    LKExpressDownListenerTypeApp = 1, ///>app sdk的listener
    LKExpressDownListenerTypeGw = 2, ///>移动网关sdk的listener，物联网套件/LinkPlatForm的用户请使用此值
};


@protocol LKExpressConnectListener<NSObject>
-(void)onConnectState:(LKExpressConnectState) state;///<通道连接状况改变，参见枚举LKExpConnectState
@end


@protocol LKExpressDownListener<NSObject>
-(void)onDownstream:(NSString *) topic data: (id _Nullable) data;///<topic-消息topic，data-消息内容,NSString 或者 NSDictionary
-(BOOL)shouldHandle:(NSString *)topic;///<数据使用onDownstream:data:上抛时，可以先过滤一遍，如返回NO，则不上传，返回YES，则会使用onDownstream:data:上抛
@end

@interface LKExpressResponse : NSObject
@property (nonatomic, assign) BOOL successed;                   ///< 是否成功
@property (nonatomic, strong, nullable) id dataObject;          ///< 服务端返回的json的data字段
@property (nonatomic, strong, nullable) NSError *responseError; ///< 错误,参见NSError+LKExpUtils.h
@end


typedef void (^LKExpressOnUpstreamResult)(NSError * _Nullable err);

//回调函数定义如下
typedef void(^LKExpressResponseHandler)(LKExpressResponse *response);

/**
 提供一条双工的长连接通道
 */
@interface LKIoTExpress : NSObject
/**
 * 单例
 */
+(instancetype)sharedInstance;


/**
 长连接通道启动接口，应用起来时调用一次，重复调用不会新建连接，SDK内部会做保护机制。
 @param config 建立连接时的配置项
 @param listener 反馈通道状态变化。
 */
- (void)startConnect:(LKIoTConnectConfig*)config connectListener:(id<LKExpressConnectListener>)listener;



/**
 中断当前长连接通道，一般情况下不需要使用此 API，除非想换新的三元组建联。

 @param completeHandler 结果回调，在结果回调后方可继续建立新的连接
 */
- (void)stopConnect:(void(^)())completeHandler;

/**
 RPC请求接口，封装了业务的上行request以及下行resp。request业务报文由SDK内部按alink标准协议封装，形如
 {
 "id":"msgId" //消息id
 "system": {
    "version": "1.0",  // 必填，消息版本，目前为1.0
     "time": ""  // 必填，消息发生的时间，毫秒,
 },
 "request": {
 },
 "params": {
 }
 }
 @param topic rpc请求的topic，由具体业务确定，完整topic形如：
  /sys/${productKey}/${deviceName}/app/abc/cba
 @param opts 可选配置项，可空，预留
 示例，{"extraParam":{"method":"thing.topo.add"}}
      则会将"method":"thing.topo.add"塞到最终的业务报文里,跟业务报文中的params平级。
 @param params 业务参数。
 @param responseHandler 业务服务器响应回调接口，参见LKExpressResponse
 */
-(void)invokeWithTopic:(NSString *)topic opts:(NSDictionary* _Nullable)opts
            params:(NSDictionary*)params respHandler:(LKExpressResponseHandler)responseHandler;


/**
 上行数据，直接透传，不会再按alink业务报文协议封装, qos会设置成默认值1
 @param topic 消息topic
 @param dat 需透传的数据
 @param completeCallback 数据上行结果回调
 */
-(void)uploadData:(NSString *)topic
             data:(NSData *)dat
         complete:(LKExpressOnUpstreamResult)completeCallback;

/**
 上行数据，直接透传，不会再按alink业务报文协议封装
 @param topic 消息topic
 @param dat 需透传的数据
 @param qos publish的qos，建议为 ‘1’ ，参见mqtt协议。qos可取值为[0,1]。不支持取值为2
 @param completeCallback 数据上行结果回调
 */
-(void)uploadData:(NSString *)topic
             data:(NSData *)dat
              qos:(int)qos
         complete:(LKExpressOnUpstreamResult)completeCallback;


/**
 上行数据，不会有回执。SDK会按alink标准协议封装业务报文。
 @param topic 消息topic,完整的topic
 @param params 业务参数
 @param completeCallback 数据上行结果回调
 */
-(void)publish:(NSString *)topic params:(NSDictionary *)params complete:(LKExpressOnUpstreamResult)completeCallback;

/**
 移动网关订阅topic的接口
 @param topic 订阅的消息的topic，由具体业务确定，需要传完整的topic区段,形如：
 /sys/${productKey}/${deviceName}/app/abc/cba
 @param completionHandler 订阅流程结束的callback，如果error为空表示订阅成功，否则订阅失败
 */
- (void)subscribe:(NSString *)topic complete: (void (^)(NSError  * _Nullable error))completionHandler;


/**
 移动网关取消订阅topic的接口
 @param topic 订阅的消息的topic，由具体业务确定，需要传完整的topic区段,形如：
 /sys/${productKey}/${deviceName}/app/abc/cba
 @param completionHandler 取消订阅流程结束的callback，如果error为空表示订阅成功，否则订阅失败
 */
- (void)unsubscribe : (NSString *)topic complete: (void (^)(NSError  * _Nullable error))completionHandler;

/**
 设置通道的下推回调，如果不需要用的时候，记得调用removeDownStreamListener:
 @param listenerType 参见LKExpressDownListenerType
 @param downListener 侦听下推消息，参见LKExpDownListener
 */
- (void)addDownstreamListener:(LKExpressDownListenerType)listenerType listener:(id<LKExpressDownListener>)downListener;


/**
 取消某个通道的下推回调
 @param downListener 侦听下推消息，参见LKExpressDownListener
 */
-(void)removeDownStreamListener:(id<LKExpressDownListener>)downListener;


@end


NS_ASSUME_NONNULL_END
