//
//  Lock.swift
//  
//
//  Created by JiaCheng on 2020/1/22.
//

import Foundation

class Lock {
    var isOn: DoorStatus
    var description: String
    var isConnecting: Bool
    var stateChange = false
    var canCommunicate = false
    
    init(isOn: DoorStatus, description: String, isConnecting: Bool) {
        self.isOn = isOn
        self.description = description
        self.isConnecting = isConnecting
    }
}
