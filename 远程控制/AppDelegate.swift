//
//  AppDelegate.swift
//  远程控制
//
//  Created by JiaCheng on 2020/1/18.
//  Copyright © 2020 JiaCheng. All rights reserved.
//

//①注意一下：静默推送、远程注册回调成功、失败，这些是不需要代理触发的
//②前端接收到消息、用户点击通知的类型、再加一个settingsd什么的这三个是需要代理设置为self，再self遵守协议，后触发
//③默认的你requestAuthorization之后选择了通知的三个类型，并且注册远程通知，然后在①回调方法（得到deviceToken）中若什么都不写，就可以使用APNs来推送通知了。测试可以使用Mac store的APNS Pusher或者easy APNS Provider等来测试通知了（需要证书cer）和deviceToken。
//④只要app没打开，你就已经能收到通知了（前台要收到要实现②的代理方法）
//⑤还有你在①的注册成功回调方法中把CloudPushSDK初始化还有registerDevice之后（成功会给你deviceID），只要在阿里云配置一些给它p12文件等，就可以使用阿里云推送了。（目前推送消息这一个还没搞好，推送通知可以了）

//因为一下大部分都是为了阿里云的推送，所以参照的是阿里云物联网平台文件夹下的alicloud-ios-demo-master下的mpush_ios_swift_demo，还有一些h就是swiftDemo的pushdemos的APNsDemo
//我打算在iOS10以上，他那个demo还10以上s还是8～10之间了

//阿里云的推送通知就是我们app不在前台的时候的通知，还有我一个代理方法(willpresent)在前台的是以后怎么处理消息
//阿里云的推送消息也不是在我们的静默推送的方法（"application(_ application:, didReceiveRemoteNotification userInfo:, fetchCompletionHandler completionHandler:"）收到的，而是自己搞了一个监听器（见registerMessageReceive: ），app在前台的时候能够被检测到还有就是刚刚打开的时候收到h之前的推送消息。

//https://help.aliyun.com/document_detail/30072.html?spm=5176.doc30071.6.648.No5CmA

import UIKit
import CloudPushSDK

let testAppKey = "28302428"
let testAppSecret = "f1962df1aa9fd8948e830b0b84c8fcb0"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var myLaunchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        myLaunchOptions = launchOptions
        
//        Thread.sleep(forTimeInterval: 3)
        
        return true
    }
    
    
    func mainRegister() {
        // APNs注册，获取deviceToken并上报
        registerAPNs(UIApplication.shared)
    }
    
    func jingmoRegister() {
        // 初始化阿里云推送SDK
        initCloudPushSDK()
        // 监听推送通道打开动作
        listenOnChannelOpened()
        // 监听推送消息到达, 我估计这一步监听和上一步监听只是为了测试捕获得到的通知而已吧？
        registerMessageReceive()
        // 点击通知将App从关闭状态启动时，将通知打开回执上报
        //CloudPushSDK.handleLaunching(launchOptions)(Deprecated from v1.8.1)
        CloudPushSDK.sendNotificationAck(myLaunchOptions)
    }
    
    //MARK: - didFinishLaunchingWithOptions初始化函数的实现
    func registerAPNs(_ application: UIApplication) {
        createCustomNotificationCategory()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, err) in
            if granted {
                DispatchQueue.main.async {
                    //注册苹果远程推送，获取deviceToken用于推送
                    application.registerForRemoteNotifications()
                    print("application.registerForRemoteNotifications()")
                }
            } else {
                print(err!.localizedDescription)
            }
        }
    }
    // 创建自定义category，并注册到通知中心
    /*
     {
        "aps":{
            "alert":{
                "title":"hangge.com",
                "body":"囤积iPhoneX的黄牛赔到怀疑人生?"
            },
            "sound":"default",
            "badge":1,
            "category":"test_category"
        }
     }
     只要在这里写上"category":"test_category"的identifier，就可以实现了
    */
    func createCustomNotificationCategory() {
        let action1 = UNNotificationAction(identifier: "action1", title: "test1", options: [])
        let action2 = UNNotificationAction(identifier: "action2", title: "test2", options: [.destructive])
        let category = UNNotificationCategory(identifier: "test_category", actions: [action1, action2], intentIdentifiers: [], options: .customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // SDK初始化
    func initCloudPushSDK() {
        // 打开Log，要线上的时候建议关闭它
        // CloudPushSDK.turnOnDebug()
        CloudPushSDK.asyncInit(testAppKey, appSecret: testAppSecret) { (res) in
            if (res?.success)! {
                //String(describing:)只是slience了可选值打印的警告，但是打印出来还是有可选标志的Optional
                print("Push SDK init success, deviceId: \(String(describing: CloudPushSDK.getDeviceId()))")
            } else {
                print("Push SDK init failed, error: \(String(describing: res?.error?.localizedDescription))")
            }
        }
    }
    
    
    
    //https://help.aliyun.com/document_detail/42668.html?spm=a2c4g.11186623.6.595.2a8160f5YK8KgC
    // 监听推送通道是否打开
    func listenOnChannelOpened() {
        let notificationName = Notification.Name("CCPDidChannelConnectedSuccess")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(channelOpenedFunc(notification:)),
                                               name: notificationName,
                                               object: nil)
    }
    @objc func channelOpenedFunc(notification : Notification) {
        print("Push SDK channel opened.")
    }
    
    // 注册消息到来监听, 我估计这一步监听和上一步监听只是为了测试捕获得到的通知而已吧？
    // 居然不是这样的，这里面还真的有点东西的啊。
    // 这个也不是类似于静默推送的，这个监听居然就是监听阿里云的推送消息的，因为是监听么所以也只能在前台打开的时候检测到还有干刚打开app的时候能够听到之前发出来的消息
    func registerMessageReceive() {
        let notificationName = Notification.Name("CCPDidReceiveMessageNotification")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onMessageReceivedFunc(notification:)),
                                               name: notificationName,
                                               object: nil)
    }
    // 处理推送消息
    @objc func onMessageReceivedFunc(notification : Notification) {
        let pushMessage: CCPSysMessage = notification.object as! CCPSysMessage
        let title = String.init(data: pushMessage.title, encoding: String.Encoding.utf8)!
        let body = String.init(data: pushMessage.body, encoding: String.Encoding.utf8)!
//        print("收到阿里云 推送消息")
        print("Message title: \(title), body: \(body).\n")
        
        DispatchQueue.main.async {
            if title == "阿里云设备毕设状态通知" {
    //                let nav = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
    //                if let viewController = nav.visibleViewController as? ViewController {
    //                    viewController.switchStatus(status: body)
    //                }
                    let nav = UIApplication.shared.windows.first!.rootViewController as! UINavigationController
                    if let viewController = nav.visibleViewController as? ViewController {
                        viewController.switchStatus(status: body)
                    }
            } else if body.contains("manager") {
                if title == "设备上线" {
                    let nav = UIApplication.shared.windows.first!.rootViewController as! UINavigationController
                    //注意：要是下面有个卡片弹窗在ViewController之上，那么我在appdelegate目前我就得到不了这个ViewController
                    if let viewController = nav.visibleViewController as? ViewController {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            viewController.activityView.stopAnimating()
                            viewController.activityView.isHidden = true
                            viewController.waveView.changeWaveSpeedState()
                        }
                    }
                } else if title == "设备下线" {
                    let nav = UIApplication.shared.windows.first!.rootViewController as! UINavigationController
                    if let viewController = nav.visibleViewController as? ViewController {
                        viewController.activityView.startAnimating()
                        viewController.activityView.isHidden = false
                    }
                }
            }
        }
    }
    
    
    
    
//MARK: - application.registerForRemoteNotifications()之后回调成功失败方法实现
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let device = NSData(data: deviceToken)
//        print(device.description)
//        print(device.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: ""))
    
       
       //https://www.jianshu.com/p/8183d086b931
       //https://www.jianshu.com/p/37daef564e14
//        let token = deviceToken.map{String(format: "%02.2hhx", $0)}.joined()
//        let token = deviceToken.map{String(format: "%02x", $0)}.joined()
       let token = deviceToken.reduce("", {$0 + String(format: "%02x", $1)}) //比上面解析速度快
       print(token)
       
       //苹果推送注册成功回调，将苹果返回的deviceToken上传到CloudPush服务器
       //注意，你把deviceToken上传到CloudPush服务器后，它会给你返回一个deviceId
       //比如我这台DoLnw P的苹果返回的deviceToken：09790ae455a8328608033ce72e1d6e947c9c8fbdefe2a94505ea97ca578b9aec
       //DoLnw P的CloudPush服务器返回的deviceId： 395ab53bba25425ba065e40d7c3a5bac
       CloudPushSDK.registerDevice(deviceToken) { (res) in
           if res!.success {
               print("Register deviceToken success.")
           } else {
               print("Register deviceToken failed, error: \((res?.error?.localizedDescription)!)")
           }
       }
   }
   
   func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
       print("didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
   }
   
   //这个函数目的应该是给静默推送使用的，"content-available" = 1的时候算是静默推送，静默推送反正前台后台都是会被触发的，不过应用没打开不行吧？还有ibeacon可以的吧？
   //静默推送一般认为是不需要声音内容标记的，而且默认是为了给数据更新等使用的。所以如果在静默推送的时候还勾选了soundcontengalert等的话其实还是有声音的，而且此时你是前台的话，willPresent notification:也是会被触发的。
   //阿里云的静默推送应该是叫推送消息吧？不对不一样的，一般的通知就叫推送通知？但是目前阿里云的推送消息我这里貌似收不到？？
    //2020-02_01, 我发现服务端挂着pushadvanced通知的时候，我app在前台运行时，会触发这个方法的嘎
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as! [AnyHashable : Any]
        let alert = aps["alert"] ?? "none"
        let badge = aps["badge"] ?? 0
        let sound = aps["sound"] ?? "none"
        let extras = userInfo["Extras"]

//        if "\(alert)".contains("iOS_manager1") {
//            if "\(sound)".contains("online.wav") {
//                let nav = UIApplication.shared.windows.first!.rootViewController as! UINavigationController
//                if let viewController = nav.visibleViewController as? ViewController {
//                    viewController.activityView.stopAnimating()
//                    viewController.activityView.isHidden = true
//                }
//            } else if "\(sound)".contains("offline.wav") {
//                let nav = UIApplication.shared.windows.first!.rootViewController as! UINavigationController
//                if let viewController = nav.visibleViewController as? ViewController {
//                    viewController.activityView.startAnimating()
//                    viewController.activityView.isHidden = false
//                }
//            }
//        }
        
        // 设置角标数为0
        //application.applicationIconBadgeNumber = 0;
        // 同步角标数到服务端
        // self.syncBadgeNum(0)
        //CloudPushSDK.sendNotificationAck(userInfo)
        print("content-available didReceiveRemoteNotification:fetchCompletionHandler:")
        print("Notification, alert: \(alert), badge: \(badge), sound: \(sound), extras: \(String(describing: extras)).\n")
        completionHandler(.noData)
    }

           
           
           
           
           
           
           
           
           
           
           
           
           
           
           
           
           
           
           
   //MARK: - UNUserNotificationCenterDelegatew方法实现,上面三句不加代理也会触发的。
//    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {}
   func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       switch response.actionIdentifier {
       case UNNotificationDefaultActionIdentifier:
           print("User touch default action.")
           handleForegroundNotification(response.notification)
       case "action1":
           print("User touch custom action1.")
       case "action2":
           print("User touch custom action2.")
       case UNNotificationDismissActionIdentifier:
           print("User dismissed the notification.")
       default:
           print("User touch other action.")
       }
       
       // you must call the completion handler when you're done
       completionHandler()
   }
   
    //当设备运行在前台收到消息时如何处理
   func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       print("Receive a notification in foreground.")
       handleForegroundNotification(notification)
       
       // 通知不弹出
       //completionHandler([])
       // 通知弹出，且带有声音、内容和角标
       completionHandler([.alert, .badge, .sound])
   }
    
    //MARK: - 一些额外的需要对消息进行处理的方法的实现
    func handleForegroundNotification(_ notification: UNNotification) {
        let content: UNNotificationContent = notification.request.content
        let userInfo = content.userInfo
        // 通知时间
        let noticeDate = notification.date
        // 标题
        let title = content.title
        // 副标题
        let subtitle = content.subtitle
        // 内容
        let body = content.body
        // 角标
        let badge = content.badge ?? 0
        // 取得通知自定义字段内容，例：获取key为"Extras"的内容
        let extras = userInfo["Extras"]
        // 设置角标数为0
        //UIApplication.shared.applicationIconBadgeNumber = 0
        // 同步角标数到服务端
        // self.syncBadgeNum(0)
        // 通知打开回执上报
        //CloudPushSDK.sendNotificationAck(userInfo)
        print("Foreground Notification, date: \(noticeDate), title: \(title), subtitle: \(subtitle), body: \(body), badge: \(badge), extras: \(String(describing: extras)).\n")
    }
    //同步角标数到服务端
    func syncBadgeNum(_ badgeNum: UInt) {
        CloudPushSDK.syncBadgeNum(badgeNum) { (res) in
            if (res!.success) {
                print("Sync badge num: [\(badgeNum)] success")
            } else {
                print("Sync badge num: [\(badgeNum)] failed, error: \(String(describing: res?.error))")
            }
        }
    }
    

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    
//    //MARK: -
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        print("applicationWillEnterForeground")
//        let nav = UIApplication.shared.windows.first!.rootViewController as! UINavigationController
//        if let viewController = nav.visibleViewController as? ViewController {
//            viewController.enterForeground()
//        }
//    }
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        print("applicationDidEnterBackground")
//    }
//    func applicationWillTerminate(_ application: UIApplication) {
//        print("applicationWillTerminate")
//    }
    

}

