//
//  LKMobileGateway.h
//  AlinkMobileGateway
//
//  Created by ZhuYongli on 2017/11/3.
//  Copyright © 2017年 ZhuYongli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKIoTGatewayLine.h"

NS_ASSUME_NONNULL_BEGIN



@protocol LKMgwDownListener<NSObject>
-(void)onDownstream:(NSString *) topic data: (id _Nullable) data;///<topic-消息topic，data-消息内容,NSString 或者 NSDictionary
-(BOOL)shouldHandle:(NSString *)topic;///<数据使用onDownstream:data:上抛时，可以先过滤一遍，如返回NO，则不上传，返回YES，则会使用onDownstream:data:上抛
@end


/**
 移动设备网关建立长连接配置项
 */
@interface LKMgwConnectConfig :NSObject
@property(nonatomic, copy) NSString * productKey; ///< 移动网关三元组之productKey
@property(nonatomic, copy) NSString * deviceName;///< 移动网关三元组之deviceName
@property(nonatomic, copy) NSString * deviceSecret;///< 移动网关三元组之deviceSecret
@property(nonatomic, copy, nullable) NSString *  server;///< 通道连接的服务器地址，如果为空，底层通道会使用默认的地址
@property(nonatomic, assign) int port;///< 通道连接的服务器端口
@property(nonatomic, copy, nullable) NSString * cerPath;///< TLS证书路径，如果为空，会使用默认的证书
@property(nonatomic, assign) BOOL receiveOfflineMsg;///>是否接收客户端离线消息，默认为NO，如果设为YES，当客户端上线后，会收到离线时所有的消息
@end

/**
 移动设备网关建立长连接连接状态枚举
 */
typedef NS_ENUM (NSInteger, LKMgwConnectState) {
    LKMgwConnectStateConnected = 1,///< 已连接
    LKMgwConnectStateDisConnected = 2,///< 已断连
    LKMgwConnectStateConnecting = 3,///< 连接中
};

/**
 移动设备网关错误值枚举
 */
typedef NS_ENUM (NSInteger, LKMgwError) {
    LKMgwErrorSubdevConnFailed = 4301, ///< 子设备通道打开失败
    LKMgwErrorThingTopoNotExist = 4302,///< 子设备跟移动设备网关的拓扑关系不存在，请先添加拓扑关系

};

/**
 移动设备网关建立长连接连接状态侦听者
 */
@protocol LKMgwConnectListener<NSObject>
-(void)onConnectState:(LKMgwConnectState) state;///<通道连接状况改变，参见枚举 `LKMgwConnectState`
@end

/**
 子设备跟网关建立拓扑关系，然后子设备上线，跟网关通道复用,整个流程的结果。
 成功的话，返回 LKIoTGatewayLine 的实例，可以用来上行数据。
 失败的话，LKIoTGatewayLine 实例为空，具体错误见 err
 */
typedef void (^LKMgwLineInitResult)(LKIoTGatewayLine  * _Nullable line, NSError * _Nullable err);

/**
 子设备的连接通道，如 Ble 通道，由应用层实现后传入。
 */
@protocol LKIoTSubdeviceConn <NSObject>

/**
 打开子设备连接通道
 @param completionHandler 结果通知
 */
- (void)open:(void (^)(NSError *error))completionHandler;

/**
 关闭子设备连接通道
 @param completionHandler 结果通知
 */
- (void)close:(void (^)(NSError *error))completionHandler;

/**
 判断跟子设备之间的连接是否准备就绪，如果没有就绪，SDK会调用open接口打开
 */
- (BOOL)isReady;

/**
 获取子设备的信息，
 字典key包括：
    "clientId"
   "productKey"
   "deviceName"
   "sign",
   "signMethod"
 对于三元组设备 子设备签名规则同网关相同
 clientId 客户端标识，可以取 mac，也可以是随机字串，由设备端确定,对于蓝牙设备，signMethod 指定为 sha256
 假定：clientId=123, deviceName=test, productKey=123,deviceSecret=secret. signMethod:"sha256",
 则 sign 计算规则如下
 sign = sha256(clientId123deviceNametestdeviceSecretsecretproductKey123)
 */
- (NSDictionary *)getSubDeviceInfo;

@end


/**
 RPC请求回执内容
 */
@interface LKMgwExpResponse : NSObject
@property (nonatomic, assign) BOOL successed;                   ///< 是否成功
@property (nonatomic, strong, nullable) id dataObject;          ///< 服务端返回的json的data字段
@property (nonatomic, strong, nullable) NSError *responseError; ///< 错误详细信息
@end


/**
 云端物的管理模型里,对于设备身份的描述。即物的三元组信息，以及阿里云分配的iotId。
 动态注册子设备时由云端返回的子设备身份描述.
 */
@interface LKDmpDeviceModel:NSObject
@property(nonatomic, copy, nullable) NSString * productKey;///<物的三元组之productKey
@property(nonatomic, copy, nullable) NSString * deviceName;///<物的三元组之deviceName
@property(nonatomic, copy, nullable) NSString *  deviceSecret;///<物的三元组之deviceSecret
@property(nonatomic, copy, nullable) NSString *  iotId;///<物联网平台id
@end

/**
 动态注册子设备结果回调
 成功的话，返回LKDmpDeviceModel的队列。
 失败的话，LKDmpDeviceModel队列为空，具体错误见err
 */
typedef void (^LKMgwDynamicRegisterResult)(NSArray<LKDmpDeviceModel *>  * _Nullable subDevices, NSError * _Nullable err);

//回调函数定义如下
typedef void(^LKMgwExpResponseHandler)(LKMgwExpResponse *response);

@interface LKIoTMobileGateway : NSObject
/**
 单例
 */
+ (instancetype)sharedGateway;


/**
 移动设备网关长连接通道启动接口，应用起来时调用一次.
 @param config 建立长联通道的配置信息，参见 `LKMgwConnectConfig`
 @param listener 反馈通道状态变化
 */
- (void)startConnect:(LKMgwConnectConfig *)config connectListener:(id<LKMgwConnectListener>)listener;



/**
 移动端设备网关初始化通道。在应用的其他模块已经初始化长连通道的情况下
 可以调用此接口初始化移动端设备网关

 @param clientId 通道 id, 通过 [[LKAppExpress sharedInstance] getClientId] 可获取到
 @param listener 反馈通道状态变化
 */
- (void)startConnectWithId:(NSString *)clientId connectListener:(id<LKMgwConnectListener>)listener;

/**
 生成对应子设备的数据上行通路
 */
- (void)setupGatewayLine:(id<LKIoTSubdeviceConn>)connection complete:(nullable LKMgwLineInitResult)completeCallback;

/**
 拿到移动设备网关中已存在的子设备上行通路
 @param productKey 子设备 productKey
 @param deviceName 子设备 deviceName
 @return 返回虚拟线路实例
 */
-(LKIoTGatewayLine *)getGatewayLine:(NSString *)productKey dn:(NSString*)deviceName;


/**
 移动设备网关的rpc请求接口，封装了业务的上行 request 以及下行 response。
 @param topic rpc 请求的 topic，由具体业务确定，上行的完整 topic 形如：
 /ext/session/${productKey}/${deviceName}/thing/topo/add。
 其中 ${productKey} 为移动设备网关的 productKey. 可通过 [self getProductKey] 拿到
 /${deviceName} 为移动设备网关的 deviceName.可通过 [self getDevcieName] 拿到
 所以开发者需要传完整 topic
 @param method 设备 IoT 协议中的 method 字段。没有的话，可不填。
 @param params 业务参数。
 @param responseHandler 业务服务器响应回调接口，参见 `LKExpResponse`
 */
-(void)invokeWithTopic:(NSString *)topic method:(nullable NSString * )method
                params:(NSDictionary*)params respHandler:(LKMgwExpResponseHandler)responseHandler;


/**
 上行数据，直接透传，不会再按alink业务报文协议封装，qos会设置为1
 @param topic 消息topic
 @param dat 需透传的数据
 @param completeCallback 数据上行结果回调
 */
-(void)uploadData:(NSString *)topic
             data:(NSData *)dat
         complete:(void (^)(NSError  * _Nullable error))completeCallback;


/**
 上行数据，直接透传，不会再按alink业务报文协议封装
 @param topic 消息topic
 @param dat 需透传的数据
 @param qos publish 消息的qos，建议为 ‘1’ ，参见mqtt协议。qos可取值为[0,1]。不支持取值为2
 @param completeCallback 数据上行结果回调
 */
-(void)uploadData:(NSString *)topic
             data:(NSData *)dat
              qos:(int)qos
         complete:(void (^)(NSError  * _Nullable error))completeCallback;


/**
 上行数据，不会有回执。SDK会按alink标准协议封装业务报文。
 @param topic 消息topic,完整的topic
 @param params 业务参数
 @param completeCallback 数据上行结果回调
 */
-(void)publish:(NSString *) topic
        params:(NSDictionary *)params
      complete:(void (^)(NSError  * _Nullable error))completeCallback;

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
 @param downListener 侦听下推消息，参见LKMgwDownListener
 */
- (void)addDownstreamListener:(id<LKMgwDownListener>)downListener;


/**
 取消某个通道的下推回调
 @param downListener 侦听下推消息，参见LKMgwDownListener
 */
-(void)removeDownStreamListener:(id<LKMgwDownListener>)downListener;


/**向云端动态注册一批子设备
 @param devices 批量注册时提交的信息，每个设备的信息包括
 {
 "productKey":"xxx",
 "deviceName":"yyy" //deviceName 可空，当为空时，云端会生成 deviceName。蓝牙设备的 deviceName 为 Mac 地址,
  形如：'1D2456F2D34E'.
 }
 @param completeCallback 结果回调
  */
-(void) dynamicRegisterSubDevices:(NSArray *)devices complete:(LKMgwDynamicRegisterResult)completeCallback;



/**向云端动态注销一批子设备
 @param devices 批量注销时提交的子设备信息，每个设备的信息包括
 {
 "productKey":"xxx",
 "deviceName":"yyy" //deviceName 蓝牙设备的 deviceName 为 Mac 地址,且必须携带,形如：'1D2456F2D34E'，
 }
 @param completeCallback 结果回调
 */
-(void) dynamicUnregisterSubDevices:(NSArray *)devices complete:(void(^)(NSError *))completeCallback;

/**
 移动设备网关的 productKey
 */
-(NSString*) getProductKey;

/**
 移动设备网关的 deviceName
 */
-(NSString *)getDevcieName;

@end

NS_ASSUME_NONNULL_END
