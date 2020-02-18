//
//  ViewController.swift
//  远程控制
//
//  Created by JiaCheng on 2020/1/18.
//  Copyright © 2020 JiaCheng. All rights reserved.
//

import UIKit
import Cards
import CoreNFC
import BLTNBoard
import UserNotifications
import CloudPushSDK
import Comets
import AudioToolbox

private let reuseIdentifier = "CollectionCell"
//var myLocks = [Lock(isOn: false, description: "我是一把锁"), Lock(isOn: true, description: "我是一把锁"), Lock(isOn: false, description: "我是一把锁"), Lock(isOn: false, description: "我是一把锁")]
var myLocks = [Lock(isOn: .off, description: "我是一把锁", isConnecting: false)]

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var bulletinManager: BLTNItemManager! = nil
    
    var address = ""
    var phoneNumber = ""
    
    var isReadMode = false
    var nfcTagReaderSession: NFCTagReaderSession?
    var nfcSession: NFCNDEFReaderSession?
    
    let activityView = UIActivityIndicatorView()
    
    var waveView: WaveView!
    
    @IBOutlet weak var cometsView: UIView!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var TotalContainerView: UIView!
    @IBOutlet weak var InfoContainerView: UIView!
    @IBOutlet weak var lockCollectionView: UICollectionView!
    @IBOutlet weak var displayContainerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.connectToAliyun()

        self.createCometBackground()
        launchAnimation()
        
        //这个值如果设置的过大的话,View移动起来卡顿会比较严重.
        let effectOffset = 25.0
        let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)

        effectX.maximumRelativeValue = effectOffset
        effectX.minimumRelativeValue = -effectOffset

        effectY.maximumRelativeValue = effectOffset
        effectY.minimumRelativeValue = -effectOffset

        let group = UIMotionEffectGroup()
        group.motionEffects = [effectX, effectY]

        self.backgroundImageView.addMotionEffect(group)
        
        // Do any additional setup after loading the view.
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
                
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //https://www.jianshu.com/p/3bf6dac3f8e6
        //隐藏了导航条下面的那条横线
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let readNFCBtn = UIBarButtonItem(image: UIImage(named: "nfc-4"), style: .done, target: self, action: #selector(nfcRead))
        self.navigationItem.rightBarButtonItem = readNFCBtn
        
        let dis = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(disConnectToAliyun))
        self.navigationItem.leftBarButtonItem = dis
        
        self.navigationItem.titleView = activityView
        self.activityView.startAnimating()
        
        self.navigationController?.navigationBar.isHidden = true
        
        //注意：要是下面这个卡片在ViewController之上，那么我在appdelegate目前我就得到不了这个ViewController
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
//            self.creatBulletinBoard()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        DispatchQueue.main.async {
            print("(UIApplication.shared.delegate as! AppDelegate).jingmoRegister()")
            (UIApplication.shared.delegate as! AppDelegate).jingmoRegister()
        }
    }
    
    
    func createWave() {
        // 创建文本标签
//        let label = UILabel()
//        label.text = "正在加载中......"
//        label.textColor = UIColor(55, 153, 249)
//        label.textAlignment = .center
//        label.frame = CGRect(x: (screenWidth() * 0.5 - 100), y: 0, width: 200, height: 50)
         
        // 创建波浪视图
        waveView = WaveView(frame: CGRect(x: 0, y: screenHeight() - 70,
                                              width: screenWidth(), height: 70))
        // 波浪显示在上方
        waveView.waveOnBottom = false
        waveView.alpha = 0
        
//        // 波浪动画回调
//        waveView.closure = {centerY in
//            // 同步更新文本标签的y坐标
//            label.frame.origin.y = waveView.frame.origin.y + centerY - 60
//        }
         
        // 添加两个视图
        self.view.addSubview(waveView)
//        self.view.addSubview(label)
         
        // 开始播放波浪动画
        waveView.startWave()
        
        UIView.animate(withDuration: 0.5) {
            self.waveView.alpha = 1
        }
    }
    
    //播放启动画面动画
    private func launchAnimation() {
        //获取启动视图
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "launch") as! LaunchViewController
        let launchview = vc.view
//        let delegate = UIApplication.shared.delegate
//        let mainWindow = delegate?.window
//        mainWindow!!.addSubview(launchview!)
        self.view.addSubview(launchview!)
        
        self.TotalContainerView.alpha = 0
//        vc.launchImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        vc.launchImageView2.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4 * 3)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        // 1.定义一个SystemSoundID
        var soundID : SystemSoundID = 0
        
        // 2.根据某一个音效文件,给soundID进行赋值
        guard let fileURL = Bundle.main.url(forResource: "launch2.mp3", withExtension: nil) else { return }
        AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
        
        // 3.播放音效
//        AudioServicesPlayAlertSoundWithCompletion(soundID, completion)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//            AudioServicesPlaySystemSound(soundID)
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generator.impactOccurred()
        }
        //播放动画效果，完毕后将其移除
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn,
                                   animations: {
                                    vc.launchImageView2.transform = .identity

        }) { (finished) in           
            UIView.animate(withDuration: 0.65, delay: 0.5, options: .curveLinear, animations: {
                self.TotalContainerView.alpha = 1
                launchview?.alpha = 0
            }) { (finished) in
                self.navigationController?.navigationBar.isHidden = false
                launchview!.removeFromSuperview()
                self.createWave()
            }
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        self.disConnectToAliyun()
//    }
    
    @objc func nfcRead() {
        guard NFCReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        isReadMode = true
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "请靠近nfc标签"
        //Hold your iPhone near the item to learn more about it.
        nfcSession?.begin()
    }

    
    func createInfoCard(info: String, number: String) {
        DispatchQueue.main.async { [unowned self] in
            // Aspect Ratio of 5:6 is preferred
            let card = CardHighlight(frame: CGRect(x: 10, y: 30, width: 200, height: 240))
            
            card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
            card.icon = UIImage(named: "snap")
            card.title = info
            card.itemTitle = "电话："
            card.itemSubtitle = number
            card.textColor = UIColor.white
            
            card.hasParallax = true
            
            let cardContentVC = self.storyboard!.instantiateViewController(withIdentifier: "CardContent")
            card.shouldPresent(cardContentVC, from: self, fullscreen: false)
            
            self.InfoContainerView.addSubview(card)
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myLocks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
                
        // Configure the cell
        cell.descriptionLabel.text = myLocks[indexPath.row].description

        if myLocks[indexPath.row].canCommunicate {
            cell.activityView.isHidden = true
            cell.activityView.stopAnimating()
            
            switch myLocks[indexPath.row].isOn {
            case .on:
                cell.statusImageView.image = UIImage(named: "open")
                cell.statusLabel.text = "on"
                cell.descriptionLabel.textColor = UIColor.black
                cell.statusLabel.textColor = UIColor.black
                cell.contentView.backgroundColor = UIColor.white
                cell.contentView.alpha = 1
                cell.activityView.color = UIColor.orange
            case .off:
                cell.statusImageView.image = UIImage(named: "close")
                cell.statusLabel.text = "on"
                cell.descriptionLabel.textColor = UIColor.darkGray
                cell.statusLabel.textColor = UIColor.darkGray
                cell.contentView.backgroundColor = UIColor.systemGray
                cell.contentView.alpha = 0.8
                cell.activityView.color = UIColor.darkGray
            }
            
            if myLocks[indexPath.row].isConnecting {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                }, completion: nil)
                
                cell.activityView.isHidden = false
                cell.activityView.startAnimating()
            } else {
                if myLocks[indexPath.row].stateChange {
                    mygenerator.impactOccurred()
                    myLocks[indexPath.row].stateChange = false
                }
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .curveEaseIn, animations: {
                    cell.transform = .identity
                }, completion: nil)
            }
        } else {
            if cell.statusLabel.text == "Label" {
                cell.statusImageView.image = UIImage(named: "close")
                cell.descriptionLabel.textColor = UIColor.darkGray
                cell.statusLabel.textColor = UIColor.darkGray
                cell.contentView.backgroundColor = UIColor.systemGray
                cell.contentView.alpha = 0.8
                cell.activityView.color = UIColor.darkGray
            }
            
            cell.statusLabel.text = "updating"
            cell.activityView.isHidden = false
            cell.activityView.startAnimating()
        }
    
        return cell
    }
    
    let mygenerator = UIImpactFeedbackGenerator(style: .rigid)
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if myLocks[indexPath.row].canCommunicate {
            if !myLocks[indexPath.row].isConnecting {
                if myLocks[indexPath.row].isOn == .off {
                    self.propertyUpload(postStr: propertyOpenPostStr)
                } else if myLocks[indexPath.row].isOn == .on  {
                    self.propertyUpload(postStr: propertyClosePostStr)
                } else {
                    return
                }
            }
            myLocks[indexPath.row].isConnecting.toggle()
            self.lockCollectionView.reloadData()
        }
    }
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension ViewController: NFCNDEFReaderSessionDelegate {
    /// - Tag: sessionBecomeActive
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            // Restart polling in 500 milliseconds.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }

        let tag = tags.first!
        if !isReadMode {
            // Connect to the found tag and write an NDEF message to it.
            session.connect(to: tag, completionHandler: { (error: Error?) in
                if let error = error {
                    session.alertMessage = "Unable to connect to tag.\n\(error.localizedDescription)"
                    session.invalidate()
                    return
                }

                tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                    guard error == nil else {
                        session.alertMessage = "Unable to query the NDEF status of tag."
                        session.invalidate()
                        return
                    }

                    switch ndefStatus {
                    case .notSupported:
                        session.alertMessage = "Tag is not NDEF compliant."
                        session.invalidate()
                    case .readOnly:
                        session.alertMessage = "Tag is read only."
                        session.invalidate()
                    case .readWrite:
                        tag.writeNDEF(NFCNDEFMessage(records: [NFCNDEFPayload(format: .nfcWellKnown, type: "T".data(using: .utf8)!, identifier: "".data(using: .utf8)!, payload: "\u{02}\(self.address)".data(using: .utf8)!), NFCNDEFPayload(format: .nfcWellKnown, type: "T".data(using: .utf8)!, identifier: "".data(using: .utf8)!, payload: "\u{02}\(self.phoneNumber)".data(using: .utf8)!)]), completionHandler: { (error: Error?) in
                            if nil != error {
                                session.alertMessage = "Write NDEF message fail: \(error!)"
                            } else {
                                session.alertMessage = "Write NDEF message successful."
                            }
                            session.invalidate()
                        })
                        break
                    @unknown default:
                        session.alertMessage = "Unknown NDEF tag status."
                        session.invalidate()
                    }
                })
            })
        } else {
            session.connect(to: tag, completionHandler: { (error: Error?) in
                if nil != error {
                    session.alertMessage = "Unable to connect to tag."
                    session.invalidate()
                    return
                }
                
                tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                    if .notSupported == ndefStatus {
                        session.alertMessage = "Tag is not NDEF compliant"
                        session.invalidate()
                        return
                    } else if nil != error {
                        session.alertMessage = "Unable to query NDEF status of tag"
                        session.invalidate()
                        return
                    }
                    
                    tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                        var statusMessage: String
                        if nil != error || nil == message {
                            statusMessage = "Fail to read NDEF from tag"
                        } else {
                            var info: String?
                            var number: String?
//                            statusMessage = "Found 1 NDEF message"
                            statusMessage = "Found NDEF messages"
                            for myPayload in message!.records {
                                switch myPayload.typeNameFormat {
                                case .nfcWellKnown:
//                                    self.readedStr += "\(myPayload.description)\n" //注意用这个能很好的看到brecord的裸着的内容，很棒
                                    print(myPayload.description)
                                    if let type = String(data: myPayload.type, encoding: .utf8) {
                                        switch type {
                                        case "U":
                                            if let uri = myPayload.wellKnownTypeURIPayload() {
//                                                self.readedStr += "identifier: \(myPayload.identifier.debugDescription)\n"
//                                                self.readedStr += "\(String(describing:myPayload.typeNameFormat)): \(type), \(uri.absoluteString)\n\n"
                                                print("identifier: \(myPayload.identifier.debugDescription)")
                                                print("\(String(describing:myPayload.typeNameFormat)): \(type), \(uri.absoluteString)\n")
                                            } else {
//                                                self.readedStr += "\(String(describing:myPayload.typeNameFormat)): \(type)\n\n"
                                                print("\(String(describing:myPayload.typeNameFormat)): \(type)\n")
                                            }
                                        case "T":
                                            let aa = myPayload.wellKnownTypeTextPayload()
                                            //因为这个text是我在前面加的aa和bb，所以
                                            if let lo = aa.1 {
                                                if lo.description.hasPrefix("aa") {
                                                    if let te = aa.0 {
//                                                        self.readedStr += "wellKnownTypeTextPayload.0: \(te)\n"
//                                                        self.readedStr += "信息: \(te=="" ? "未填写" : te)\n"
                                                        print("信息: \(te=="" ? "未填写" : te)")
                                                        info = te
                                                    }
                                                } else if lo.description.hasPrefix("bb") {
                                                    if let te = aa.0 {
//                                                        self.readedStr += "联系方式: \(te=="" ? "未填写" : te)\n"
                                                        print("联系方式: \(te=="" ? "未填写" : te)")
                                                        number = te
                                                    }
                                                }
                                            }
                                            
                                            if let payload = String(data: myPayload.payload, encoding: .utf8) {
//                                                self.readedStr += "payload: \(payload)\n"
                                                print("payload: \(payload)")
                                            }
                                            
                                            if let myInfo = info, let myNumber = number {
                                                self.createInfoCard(info: myInfo, number: myNumber)
                                            }
                                        default:
                                            break
                                        }
                                    }
                                    
                                case .absoluteURI:
                                    if let text = String(data: myPayload.payload, encoding: .utf8) {
//                                        self.readedStr += text
                                        print(text)
                                    }
                                    
                                case .media:
                                    if let type = String(data: myPayload.type, encoding: .utf8) {
//                                        self.readedStr += "\(String(describing:myPayload.typeNameFormat)): " + type + "\n\n"
                                        print("\(String(describing:myPayload.typeNameFormat)): " + type + "\n")
                                    }
                                    
                                case .nfcExternal, .empty, .unknown, .unchanged:
                                    fallthrough
                                    

                                @unknown default:
//                                    self.readedStr += "\(String(describing:myPayload.typeNameFormat))\n\n"
                                    print("\(String(describing:myPayload.typeNameFormat))\n")
                                }
                            }
                        }
                        
                        session.alertMessage = statusMessage
                        session.invalidate()
                    })
                })
            })
        }
    }
    
    /// - Tag: endScanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    func write(address: String?, phoneNumber: String?) {
        guard NFCReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        isReadMode = false
            
        self.nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        self.nfcSession?.alertMessage = "Hold your iPhone near an NDEF tag to write the message."
        self.nfcSession?.begin()
    }
}

//MARK: -
extension ViewController {
    func creatBulletinBoard() {
        var address: String? = nil
        var phoneNumber: String? = nil
        
        let page3 = TextFieldBulletinPage(title: "请输入电话", type: "page3")
        page3.isDismissable = false
        page3.image = UIImage(named: "lock")
        page3.descriptionText = "输入电话方便他人联系."
        page3.actionButtonTitle = "确认输入"
//        page3.alternativeButtonTitle = "跳过"
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            if page3.textField != nil {
//                page3.textField.placeholder = "请输入电话号码"
////                page3.textField.keyboardType = .numberPad
////                page3.textField.textContentType = .telephoneNumber
//            }
//        }
//        if let textField3 = (page3.makeViewsUnderDescription(with: BLTNInterfaceBuilder(appearance: page3.appearance, item: page3)) as? [UITextField])?.first {
//            textField3.placeholder = "请输入地址"
//            textField3.keyboardType = .numberPad
//        }
        
        page3.actionHandler = { [unowned self] (item: BLTNActionItem) in
            if page3.textField.text != "" {
                phoneNumber = "bb" + page3.textField.text!   //这个page3.textField就是我在创建TextFieldBulletinPage这个类里面我自己加的属性
                if  address != nil, phoneNumber != nil {
                    self.address = address!
                    self.phoneNumber = phoneNumber!
                    self.write(address: address, phoneNumber: phoneNumber)
                }
                self.bulletinManager.dismissBulletin(animated: true)
            }
        }
//        page3.alternativeHandler = { [unowned self] (item: BLTNActionItem) in
//            self.bulletinManager.dismissBulletin(animated: true)
//        }
        
        
        let page2 = TextFieldBulletinPage(title: "请输入住址", type: "page2")
        page2.isDismissable = false
        page2.image = UIImage(named: "lock")
        page2.descriptionText = "输入住址方便他人确认所在住户位置."
        page2.actionButtonTitle = "确认输入"
        page2.alternativeButtonTitle = "跳过"
        page2.next = page3
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            if page2.textField != nil {
//                page2.textField.placeholder = "请输入住址"
//            }
//        }
        
//        if let textField2 = (page3.makeViewsUnderDescription(with: BLTNInterfaceBuilder(appearance: page2.appearance, item: page2)) as? [UITextField])?.first {
//            textField2.placeholder = "请输入地址"
//        }

        page2.actionHandler = { (item: BLTNActionItem) in
            if page2.textField.text != "" {
                address = "aa" + page2.textField.text!
//                address = "aa" + myTextField2.text!
                self.bulletinManager.displayNextItem()
            }
        }
        page2.alternativeHandler = { (item: BLTNActionItem) in
            self.bulletinManager.dismissBulletin()
        }
        
        
        let page1 = BLTNPageItem(title: "推送通知")
        page1.isDismissable = false
        page1.image = UIImage(named: "notify")
        page1.descriptionText = "确保当推送通知时能够及时收到通知"
        page1.actionButtonTitle = "订阅"
        page1.alternativeButtonTitle = "下次再说"
        page1.next = page2
        page1.actionHandler = { (item: BLTNActionItem) in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [unowned self] (granted, err)  in
                if granted {
                    self.registerNOtification()
                } else {
                    print(err!.localizedDescription)
                }
            }
            
            self.bulletinManager.displayNextItem()
        }
        page1.alternativeHandler = { (item: BLTNActionItem) in
            self.bulletinManager.displayNextItem()
        }
        
        let rootItem: BLTNItem = page1
        bulletinManager = BLTNItemManager(rootItem: rootItem)
        
        bulletinManager.showBulletin(above: self)
    }
}



//MARK: - Notification
extension ViewController: UNUserNotificationCenterDelegate {
    func registerNOtification() {
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).mainRegister()
        }
    }
}


//MARK: - changeStatusOnMessage
//a7c430290525c9488c41b70013a45264a83b98816c3e67a82605970100ddc71a
//ee29e78783694a8c83ca1a3023f2ee8b
//阿里云设备毕设状态通知
extension ViewController {
    func switchStatus(status: String) {
        mygenerator.prepare()
        myLocks.first!.stateChange = true
        if status == "on" {
            myLocks.first!.isOn = .on
            myLocks.first!.isConnecting = false
            self.lockCollectionView.reloadData()
        } else if status == "off" {
            myLocks.first!.isOn = .off
            myLocks.first!.isConnecting = false
            self.lockCollectionView.reloadData()
        }
    }
}


//MARK: - Comets
extension ViewController {
    func createCometBackground() {
        // Customize your comet
        let width = view.bounds.width
        let height = view.bounds.height
        let comets = [Comet(startPoint: CGPoint(x: 100, y: 0),
                            endPoint: CGPoint(x: 0, y: 100),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.randomColor()),
                      Comet(startPoint: CGPoint(x: 0.4 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.8 * width),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.randomColor()),
                      Comet(startPoint: CGPoint(x: 0.8 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.2 * width),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.randomColor()),
                      Comet(startPoint: CGPoint(x: width, y: 0.2 * height),
                            endPoint: CGPoint(x: 0, y: 0.25 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.randomColor()),
                      Comet(startPoint: CGPoint(x: 0, y: height - 0.8 * width),
                            endPoint: CGPoint(x: 0.6 * width, y: height),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.randomColor()),
                      Comet(startPoint: CGPoint(x: width - 100, y: height),
                            endPoint: CGPoint(x: width, y: height - 100),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.randomColor()),
                      Comet(startPoint: CGPoint(x: 0, y: 0.8 * height),
                            endPoint: CGPoint(x: width, y: 0.75 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.2),
                            cometColor: UIColor.randomColor())]

        // draw line track and animate
        for comet in comets {
            cometsView.layer.addSublayer(comet.drawLine())
            cometsView.layer.addSublayer(comet.animate())
        }
    }
    
}

extension ViewController {
    // 返回当前屏幕宽度
    func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
     
    // 返回当前屏幕高度
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
}
