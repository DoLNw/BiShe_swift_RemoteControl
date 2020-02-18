//
//  LKIoTGatewayLine.h
//  AlinkMobileGateway
//
//  Created by ZhuYongli on 2017/11/3.
//  Copyright © 2017年 ZhuYongli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LKMgwLineResult)(BOOL success, NSError * _Nullable err, id _Nullable dataObj);

typedef void (^LKMgwLineResultNoData)(BOOL success, NSError * _Nullable err);

/**
 数据下推侦听者
 */
@protocol LKMgwLineDownListener <NSObject>
/**
 下推数据方法
 
 @param topic 下推消息的 Topic ，由具体业务确定。下行的完整 Topic 形如：
 /sys/${subProductKey}/${subDeviceName}/thing/down/abc/cba
 @param data 消息内容。可能是 NSString 或者 NSDictionary
 */
-(void)onDownstream:(NSString *) topic data: (id  _Nullable) data;

/**
 数据使用 `onDownstream:data:` 上抛时，可以先过滤一遍，返回 NO，则不上抛；返回 YES，则会使用 `onDownstream:data:` 上抛
 
 @param topic 下推消息的 Topic ，由具体业务确定。下行的完整 Topic 形如：
 /sys/${subProductKey}/${subDeviceName}/thing/down/abc/cba
 @return 返回 NO，则不上抛；返回 YES，则会使用 `onDownstream:data:` 上抛
 */
-(BOOL)shouldHandle:(NSString *)topic;
@end

/**
 子设备跟移动设备网关建立的虚拟线路
 */
@interface LKIoTGatewayLine : NSObject
/**
 跟网关的topo关系是否已经建立。
 */
//-(BOOL)isTopoAdded;

/**
 子设备跟移动设备网关在云端建立topo关系。
 @param completeCallback 执行结果回调
 */
-(void)addTopo:(LKMgwLineResult)completeCallback;


/**
 删除子设备跟移动设备网关在云端的topo关系。
 @param completeCallback 执行结果回调
 */
-(void)deleteTopo:(LKMgwLineResult)completeCallback;

/**
 子设备是否已经上线成功 
 */
//-(BOOL)isOnlined;

/**
 子设备上线接口。子设备复用移动设备网关的数据链路。按照云端的约定，需要子设备跟移动网关
 先建立起 topo 关系。所以 online 前需要先要先调用 `addTopo:`
 @param completeCallback 执行结果回调
 */
-(void)online:(LKMgwLineResult)completeCallback;


/**
 子设备下线接口。子设备解除复用移动设备网关的数据链路。
 @param completeCallback 执行结果回调
 */
-(void)offline:(LKMgwLineResult)completeCallback;


/**
 子设备订阅接口
 @param topic 由具体业务确定，完整 topic 形如：
 /ext/session/${productKey}/${deviceName}/thing/push/something。
 其中 ${productKey} 为子设备的 productKey. 可通过 subDeviceProductKey 拿到
 ${deviceName} 为子设备的 deviceName. 可通过 subDeviceDeviceName 拿到
 @param completeCallback 执行结果回调
 */
-(void)subscribe:(NSString*)topic complete:(LKMgwLineResultNoData)completeCallback;



/**
 子设备取消订阅接口
 @param topic 由具体业务确定，完整 topic 形如：
 /ext/session/${productKey}/${deviceName}/thing/push/something。
 其中${productKey} 为子设备的 productKey. 可通过 `subDeviceProductKey` 拿到
 /${deviceName} 为子设备的 `deviceName`. 可通过 `subDeviceDeviceName` 拿到
 @param completeCallback 执行结果回调
 */
-(void)unsubscribe:(NSString*)topic complete:(LKMgwLineResultNoData)completeCallback;

/**
 获取当前子设备的 ProductKey
 */
-(NSString *)subDeviceProductKey;

/**
 获取当前子设备的 DeviceName
 */
-(NSString *)subDeviceDeviceName;


/**
 透传数据接口，qos会设置为1
 @param topic 消息topic
 @param data 上行数据，移动设备网关会透传
 @param completeCallback 上行结果
 */
-(void)uploadData:(NSString *)topic
             data:(NSData *)data
         complete:(LKMgwLineResult)completeCallback;

/**
 透传数据接口
 @param topic 消息topic
 @param data 上行数据，移动设备网关会透传
 @param qos publish 消息的qos，建议为 ‘1’ ，参见mqtt协议。qos可取值为[0,1]。不支持取值为2
 @param completeCallback 上行结果
 */
-(void)uploadData:(NSString *)topic
             data:(NSData *)data
              qos:(int)qos
         complete:(LKMgwLineResult)completeCallback;



/**
 设置通道的下推侦听者，如果不需要用的时候，记得调用 `removeDownStreamListener:`
 收到云端下推的处理逻辑如下所示:
 if ([downListener shouldHandle:topic] == YES) {
 [downListener onDownstream:topic data:data];
 } else {
 NSLog(@"message will ignored");
 }
 @param uiSafety 是否要在UI线程里回调，建议为 YES
 @param downListener 侦听下推消息，参见 ·LKExpDownListener·
 */
- (void)addDownStreamListener:(BOOL)uiSafety listener:(id<LKMgwLineDownListener>)downListener;

/**
 取消通道的某个下推侦听者
 @param downListener 侦听下推消息，参见 ·LKExpDownListener·
 */
-(void)removeDownStreamListener:(id<LKMgwLineDownListener>)downListener;

@end

NS_ASSUME_NONNULL_END
