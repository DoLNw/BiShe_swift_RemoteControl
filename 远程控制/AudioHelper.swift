//
//  AudioHelper.swift
//  远程控制
//
//  Created by JiaCheng on 2020/1/31.
//  Copyright © 2020 JiaCheng. All rights reserved.
//

import Foundation
import AudioToolbox

extension ViewController {
    class func playAudio(_ audioName : String, _ isAlert : Bool = false,  _ completion : (() -> ())? = nil) {
        // 1.定义一个SystemSoundID
        var soundID : SystemSoundID = 0
        
        // 2.根据某一个音效文件,给soundID进行赋值
        guard let fileURL = Bundle.main.url(forResource: audioName, withExtension: nil) else { return }
        AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
        
        // 3.播放音效
        if isAlert {
            AudioServicesPlayAlertSoundWithCompletion(soundID, completion)
        } else {
            AudioServicesPlaySystemSoundWithCompletion(soundID, completion)
        }
    }
}


