//
//  AliyunConnect.swift
//  远程控制
//
//  Created by JiaCheng on 2020/2/1.
//  Copyright © 2020 JiaCheng. All rights reserved.
//

import Foundation
import IotLinkKit

let productKey = "a1n5qqGX7PA"
let deviceName = "iOS_manager1"
let deviceSecret = "MWOlPaqnYWgKqahZe2Ud9qzMBunFw32X"
let uploadTopic = "/a1n5qqGX7PA/iOS_manager1/user/update"
let propertyPostTopic = "/sys/a1n5qqGX7PA/iOS_manager1/thing/event/property/post"
let subscribePropertyTopic = "/sys/a1n5qqGX7PA/iOS_manager1/thing/service/property/set"
let subscribeUpdateTopic = "/a1n5qqGX7PA/iOS_manager1/user/get"
var uploadOnDataStr = """
{
    "status": 1,
    "devicename": "iOS_manager1"
}
"""
var propertyOpenPostStr = """
{
    "params":
    {
        "ContactState": 1,
        "Error": 0
    },
    "method": "thing.event.property.post"
}
"""
var propertyClosePostStr = """
{
    "params":
    {
        "ContactState": 0,
        "Error": 0
    },
    "method": "thing.event.property.post"
}
"""

extension ViewController: LinkkitChannelListener {
    func enterForeground() {
        
    }
    
    func enterBackground() {
        myLocks.first!.canCommunicate = false
        DispatchQueue.main.async { [unowned self] in
            self.lockCollectionView.reloadData()
        }
        
        statusOnUpload()
    }
    
    func onConnectStateChange(_ connectId: String, state: LinkkitChannelConnectState) {
        switch state {
        case .stateConnected:
            print("connected")
            propertySubscribe()  //连接成功后
            statusOnUpload()
        case .stateConnecting:
            print("connecting")
        case .stateDisconnected:
            enterBackground()   //到后台而且断开了连接之后就是断开连接后的变成updating
            print("disconnected")
        default:
            break
        }
    }
    
    func shouldHandle(_ connectId: String, topic: String) -> Bool {
        return true
    }
    
    
    
    /*
     会收到
     topic: /a1n5qqGX7PA/iOS_manager1/user/get
     {
       "deviceName" : "NB101",
       "statue" : 1
     }
     */
    func onNotify(_ connectId: String, topic: String, data: Any?) {
        print("\nonNotify")
        print("topic: \(topic)")
        
        if let str = data as? String {
            let json = JSON(parseJSON: str)
            print(json.description)
            print(json["deviceName"].stringValue)
            print(json["communicate"].boolValue)
            print(json["status"].boolValue)
                        
            if ((json["deviceName"].stringValue == "NB101" || json["deviceName"].stringValue == "BiShe_iOSDevice1") && json["communicate"].boolValue) {
                
                myLocks.first!.canCommunicate = true
                if json["status"].boolValue == true {
                    myLocks.first!.isOn = .on
                } else {
                    myLocks.first!.isOn = .off
                }
                
                DispatchQueue.main.async { [unowned self] in
                    self.lockCollectionView.reloadData()
                }
            }
            
//            var description = ""
//            if  json.dictionaryValue.count > 0 {
//                description = json.description
//                print(description)
//            } else {
//                description = str
//            }
        }
    }
    
    
}

extension ViewController {
    func connectToAliyun() {
        //初始化前请先注册listener侦听长连接通道的连接状态变化
        LinkKitEntry.sharedKit().register(self)
        
        let config = LinkkitChannelConfig()
        config.productKey = productKey
        config.deviceName = deviceName
        config.deviceSecret = deviceSecret
//        config.cleanSession = true
        
        config.server = "a1ngozY63IH.iot-as-mqtt.cn-shanghai.aliyuncs.com"
        config.port = 1883
        
        let setupParams = LinkkitSetupParams()
//        setupParams.appVersion = "1.0"
        setupParams.channelConfig = config
        LinkKitEntry.sharedKit().setup(setupParams) { (result, error) in
            if let error = error {
                let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true)
            } else {
                print("connect successfully")
            }
        }
    }
    
    @objc func disConnectToAliyun() {
//        LinkKitEntry.sharedKit().destroy { (result, error) in
//            if let error = error {
//                let ac = UIAlertController(title: "destroy failed", message: error.localizedDescription, preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(ac, animated: true)
//            } else {
//                print("disconnect successful")
//            }
//        }
        
        
        
        
//        self.waveView.changeWaveSpeedState()
        
        
        self.creatBulletinBoard()
    }
    
    //订阅topic
    func propertySubscribe() {
        LinkKitEntry.sharedKit().subscribe(subscribeUpdateTopic) { (result, error) in
           if let error = error {
                let ac = UIAlertController(title: "subscribe failed", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true)
            } else {
                print("\nsubscribe successful")
            }
        }
    }
    
    
    
    //https://www.alibabacloud.com/help/zh/doc-detail/89301.htm
    //说明 透传的上报数据中，必须包含请求方法method参数，取值为thing.event.property.post。 不加就出错“request parameter error.”
    /*
     {
       "id": "123",
       "version": "1.0",
       "params": {
         "Power": {
           "value": "on",
           "time": 1524448722000
         },
         "WF": {
           "value": 23.6,
           "time": 1524448722000
         }
       },
       "method": "thing.event.property.post"
     }
     */
    func propertyUpload(postStr: String) {
        //发送这个后首先下面这个裸传的d会在onnotify中回来
        // /sys/a1ngozY63IH/iOSDevice/thing/event/property/post
        //然后第一个还有/sys/a1ngozY63IH/iOSDevice/thing/event/property/post_reply
        //和/sys/a1ngozY63IH/iOSDevice/thing/service/property/set
        
        LinkKitEntry.sharedKit().publish(propertyPostTopic, data: postStr.data(using: .utf8)!, qos: 0) { (result, error) in
            if let error = error {
                let ac = UIAlertController(title: "propertyupload failed", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true)
            } else {
                print("\npropertyupload successful")
            }
        }
    }
    
    //业务请求响应模型
    func statusOnUpload() {
        let topic = uploadTopic
        
        LinkKitEntry.sharedKit().publish(topic, data: uploadOnDataStr.data(using: .utf8)!, qos: 0) { (result, error) in
//            if let error = error {
            if let _ = error {
                print("\nupload failed")
//                let ac = UIAlertController(title: "upload failed", message: error.localizedDescription, preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(ac, animated: true)
            } else {
                print("\nupload successful")
            }
        }
    }
}
