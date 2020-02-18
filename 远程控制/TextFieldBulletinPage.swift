//
//  CustomBLTPageItem.swift
//  远程控制
//
//  Created by JiaCheng on 2020/1/23.
//  Copyright © 2020 JiaCheng. All rights reserved.
//

import UIKit
import BLTNBoard

class TextFieldBulletinPage: BLTNPageItem, UITextFieldDelegate {
    var textField: UITextField!
    var type = ""
    
    init(title: String, type: String) {
        super.init(title: title)
        
        self.type = type
    }

    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        if type == "page2" {
            textField = interfaceBuilder.makeTextField(placeholder: "请输入住址(不能为空)", returnKey: .done, delegate: self)
        } else if type == "page3" {
            textField = interfaceBuilder.makeTextField(placeholder: "请输入电话号码(不能为空)", returnKey: .done, delegate: self)
            textField.keyboardType = .numberPad
        }
        
        return [textField]
    }
}
