//
//  LinkkitGateway.h
//  IotLinkKit
//
//  Created by 朱永利 on 2018/11/14.
//  Copyright © 2018年 朱永利. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinkkitDefine.h"


NS_ASSUME_NONNULL_BEGIN

/**
子设备状态

 - ILKSubdeviceStateEnabled: 已使能
 - ILKSubdeviceStateDisabled: 已禁能
 - ILKSubdeviceStateDeleted: 已删除
 */
typedef NS_ENUM (NSInteger, ILKSubdeviceState) {
    ILKSubdeviceStateEnabled = 1,
    ILKSubdeviceStateDisabled = 2,
    ILKSubdeviceStateDeleted = 3,
};


/**
 子设备登录状态

 - ILKSubdeviceLoginStateOnline: 上线
 - ILKSubdeviceLoginStateOffline: 离线
 */
typedef NS_ENUM (NSInteger, ILKSubdeviceLoginState) {
    ILKSubdeviceLoginStateOnline = 1,
    ILKSubdeviceLoginStateOffline = 2,
};



/**
 设备基本信息
 */
@interface LinkkitDeviceBase : NSObject
@property(nonatomic, copy) NSString * productKey;///>IoT三元组之productKey
@property(nonatomic, copy) NSString * deviceName;///>IoT三元组之deviceName

- (NSString *) deviceBaseId;
@end

/**
 子设备当前状态以及基本信息
 */
@interface ILKSubdeviceProfile : LinkkitDeviceBase
@property(nonatomic, assign) ILKSubdeviceState ableState;///>enalbe/disable/delete
@property(nonatomic, assign) ILKSubdeviceLoginState loginState;///> online/offline
@end



/**
 侦听子设备禁能，被删除事件的协议
 */
@protocol ILKSubDeviceStateListener <NSObject>

/**
 设备在IoT后台被禁能

 @param desc 相关原始数据
 */
- (void)didDisable:(NSData *)desc;

/**
 设备在IoT后台被删除
 
 @param desc 相关原始数据
 */
- (void)didDelete:(NSData *)desc;

@end


/**
 子设备通道协议，包装子设备数据上行/下行/订阅等相关api
 */
@protocol ILKSubDeviceChannel <NSObject>

/**
 子设备上线
 封装 topic "/ext/session/${subdeviceProductKey}/${subdeviceDeviceName}/combine/login"
 @param resultBlock 结果回调
 */
- (void)login:(LinkkitBooleanResultBlock)resultBlock;


/**
 子设备离线
 封装 topic "/ext/session/${subdeviceProductKey}/${subdeviceDeviceName}/combine/logout"
 @param resultBlock 结果回调
 */
- (void)logout:(LinkkitBooleanResultBlock)resultBlock;


/**
 子设备订阅自己的topic

 @param topic 想要订阅的topic，参见 mqtt协议
 @param resultBlock 订阅结果回调
 */
- (void)subscribe:(NSString *)topic resultBlock:(LinkkitBooleanResultBlock)resultBlock;


/**
 子设备取消订阅自己的topic
 
 @param topic 想要取消订阅的topic，参见 mqtt协议
 @param resultBlock 取消订阅结果回调
 */
- (void)unsubscribe:(NSString *)topic resultBlock:(LinkkitBooleanResultBlock)resultBlock;



/**
 子设备原始数据上行，使用 mqtt publish方法

 @param topic publish的topic，参见mqtt协议
 @param qos publish的qos，默认为 ‘1’ ，参见mqtt协议
 @param data 原始数据
 @param resultBlock 结果回调
 */
- (void)publish:(NSString *)topic
          data:(NSData *)data
           qos:(int)qos
   resultBlock:(LinkkitBooleanResultBlock)resultBlock;



/**
 侦听子设备禁能，被删除事件的listener
 */
@property(nonatomic, weak) id<ILKSubDeviceStateListener> stateListener;


/**
 子设备的基本信息以及状态
 */
@property(nonatomic, strong, readonly) ILKSubdeviceProfile *subDeviceProfile;

@end



/**
 子设备签名信息
 */
@protocol ILKSubDeviceSigner <NSObject>

/**
 子设备签名信息时使用的签名方法
 可选值: "hmacmd5 or hmacsha1 or hmacsha256 or sha256",
 */
@property(nonatomic, copy, readonly) NSString * signMethod;


/**
 计算sign时的 salt，可以取 mac，也可以是随机字串，由用户自己确定。
 */
@property(nonatomic, copy, readonly) NSString * clientId;

/**
 子设备签名信息，
 对于三元组设备 子设备签名规则如下：
 clientId 客户端标识，可以取 mac，也可以是随机字串，由设备端确定,对于蓝牙设备，signMethod 指定为 sha256
 假定：clientId=123, deviceName=test, productKey=123,deviceSecret=secret. signMethod:"sha256",
 则 sign 计算规则如下
 sign = sha256(clientId123deviceNametestdeviceSecretsecretproductKey123)
 */
@property(nonatomic, copy, readonly) NSString * signValue;



@end

/**
 子设备代理
 */
@protocol ILKSubDeviceDelegate <NSObject>

/**
 子设备连接IoT云端结果回调

 @param success 连接成功
 @param err 如果连接失败，错误值
 @param subDeviceChannel 返回子设备channel实例
 */
- (void)onConnectResult:(BOOL)success
                  error:(NSError * _Nullable)err
       subDeviceChannel:(id<ILKSubDeviceChannel>)subDeviceChannel;



/**
 子设备数据下推回调

 @param topic 数据topic
 @param data 下推数据
 */
- (void)onDataPush:(NSString *)topic data:(NSData *)data;
@end





@interface LinkkitDeviceAuth : LinkkitDeviceBase
@property(nonatomic, copy) NSString * deviceSecret;///>IoT三元组之deviceSecret
@property(nonatomic, copy) NSString * iotId;///>阿里云IoT云端给设备颁发的唯一标识
@end




typedef void (^LinkkitSubdeviceAddResultBlock)(id<ILKSubDeviceChannel> _Nullable subChannel,
                                               NSError * _Nullable error);

/**
 此协议封装了作为子设备网关的相关功能
 */
@protocol LinkkitGateway <NSObject>

/**
 添加某个子设备到网关，跟子设备在云端建立 topo 关系
 会封装 topic "/sys/${subdeviceProductKey}/${subdeviceDeviceName}/thing/topo/add"

 @param baseInfo 子设备基本信息，没有带deviceSecret
 @param signer 子设备签名信息提供者
 @param delegate 子设备delegate
 */
- (void)addSubDevice:(LinkkitDeviceBase *)baseInfo
              signer:(id<ILKSubDeviceSigner>)signer
            delegate:(id<ILKSubDeviceDelegate>)delegate
         resultBlock:(LinkkitSubdeviceAddResultBlock)resultBlock;



/**
 添加某个子设备到网关，跟子设备在云端建立 topo 关系
 会封装 topic "/sys/${subdeviceProductKey}/${subdeviceDeviceName}/thing/topo/add"

 @param deviceAuth 子设备三元组信息，必须带deviceSecret，sdk内部逻辑会根据deviceSecret计算出sign
 @param delegate 子设备delegate
 */
- (void)addSubDevice:(LinkkitDeviceAuth *)deviceAuth
            delegate:(id<ILKSubDeviceDelegate>)delegate
         resultBlock:(LinkkitSubdeviceAddResultBlock)resultBlock;



/**
 将某个子设备从网关里删除，并且删除跟子设备在云端的 topo 关系

 @param baseInfo 子设备基本信息
 @param resultBlock 结果回调
 */
- (void)deleteSubDevice:(LinkkitDeviceBase *)baseInfo
            resultBlock:(LinkkitBooleanResultBlock)resultBlock;



/**
 获取添加到网关的子设备列表

 @return 子设备队列，参见 `ILKSubdeviceProfile`
 */
- (NSArray<ILKSubdeviceProfile *> *)getSubDevices;

/**
 批量注册子设备

 @param subDevs 子设备productKey,deviceName
 @param resultBlock 注册结果，成功返回子设备三元组，失败看 NSError.
 */
- (void)subDeviceRegisterBatch:(NSArray<LinkkitDeviceBase *> *)subDevs
                   resultBlock:(LinkkitArrayResultBlock)resultBlock;

/**
 子设备上线，实际上是 调用 [ILKSubDeviceChannel online:]

 @param baseInfo 子设备基本信息，根据此信息找到子设备对应的 ILKSubDeviceChannel 实例
 @param resultBlock 结果回调
 */
- (void)subDeviceLogin:(LinkkitDeviceBase *)baseInfo
           resultBlock:(LinkkitBooleanResultBlock)resultBlock;

/**
 子设备下线，实际上是 调用 [ILKSubDeviceChannel offline:]
 
 @param baseInfo 子设备基本信息，根据此信息找到子设备对应的 ILKSubDeviceChannel 实例
 @param resultBlock 结果回调
 */
- (void)subDeviceLogout:(LinkkitDeviceBase *)baseInfo
           resultBlock:(LinkkitBooleanResultBlock)resultBlock;
@end

NS_ASSUME_NONNULL_END

