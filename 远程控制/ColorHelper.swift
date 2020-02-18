//
//  ColorHelper.swift
//  远程控制
//
//  Created by JiaCheng on 2020/1/28.
//  Copyright © 2020 JiaCheng. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static var myGreen: UIColor {
        return UIColor(displayP3Red: 0.196, green: 0.604, blue: 0.357, alpha: 1)
    }
    
    static var myBlue: UIColor {
        return UIColor(displayP3Red: 0.184, green: 0.536, blue: 0.892, alpha: 1)
    }
    
    static var myRed: UIColor {
        return UIColor(displayP3Red: 0.898, green: 0.399, blue: 0.429, alpha: 1)
    }
    
    static var biXuanColor: UIColor {
        return UIColor(displayP3Red: 0.898, green: 0.399, blue: 0.429, alpha: 1)
    }
    
    static var renXuanColor: UIColor {
        return UIColor(displayP3Red: 0.196, green: 0.604, blue: 0.357, alpha: 1)
    }
    
    static var gongXuanColor: UIColor {
        return UIColor(displayP3Red: 0.967, green: 0.753, blue: 0.149, alpha: 1)
    }
    
    static var keWaiColor: UIColor {
        return UIColor(displayP3Red: 0.929, green: 0.396, blue: 0.059, alpha: 1)
    }
    
    static var otherColor: UIColor {
        return UIColor(displayP3Red: 0.596, green: 0.227, blue: 0.235, alpha: 1)
    }
    
    static var myPink: UIColor {
        return UIColor(displayP3Red: 0.941, green: 0.271, blue: 0.384, alpha: 1)
    }
    
    static var myPurple: UIColor {
        return UIColor(displayP3Red: 0.443, green: 0.278, blue: 1, alpha: 1)
    }
    
    static var myLightBlue: UIColor {
        return UIColor(displayP3Red: 0.251, green: 0.549, blue: 0.961, alpha: 1)
    }
    
    static var myLightOrange: UIColor {
        return UIColor(displayP3Red: 0.988, green: 0.659, blue: 0.263, alpha: 1)
    }
    
    
    static var lightBlue: UIColor {
//        return UIColor(displayP3Red: 0.333, green: 0.396, blue: 0.793, alpha: 1)
        return UIColor(displayP3Red: 0.533, green: 0.801, blue: 1, alpha: 1)
    }
    
    static var lightGreen: UIColor {
        return UIColor(displayP3Red: 0.792, green: 0.929, blue: 0.921, alpha: 1)
    }
    
    static var lightRed: UIColor {
        return UIColor(displayP3Red: 0.996, green: 0.867, blue: 0.894, alpha: 1)
    }
    
    static let colors: [UIColor] = [.myGreen, .myBlue, .myRed, .biXuanColor, .renXuanColor, .gongXuanColor, .keWaiColor, .otherColor, .myPink, .myPurple, .myLightBlue, .myLightOrange, .lightBlue, .lightGreen, .lightRed]
    
    static func randomColor() -> UIColor {
        return UIColor.colors[Int.random(in: 0..<UIColor.colors.count)]
    }
    
    
    //使用rgb方式生成自定义颜色
    convenience init(_ r : CGFloat, _ g : CGFloat, _ b : CGFloat) {
        let red = r / 255.0
        let green = g / 255.0
        let blue = b / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
     
    //使用rgba方式生成自定义颜色
    convenience init(_ r : CGFloat, _ g : CGFloat, _ b : CGFloat, _ a : CGFloat) {
        let red = r / 255.0
        let green = g / 255.0
        let blue = b / 255.0
        self.init(red: red, green: green, blue: blue, alpha: a)
    }
}
