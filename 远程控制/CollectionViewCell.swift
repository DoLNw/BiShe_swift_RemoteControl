//
//  CollectionViewCell.swift
//  远程控制
//
//  Created by JiaCheng on 2020/1/22.
//  Copyright © 2020 JiaCheng. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
                
//        //这个值如果设置的过大的话,View移动起来卡顿会比较严重.
//        let effectOffset = 20.0
//        let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
//        let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
//
//        effectX.maximumRelativeValue = effectOffset
//        effectX.minimumRelativeValue = -effectOffset
//
//        effectY.maximumRelativeValue = effectOffset
//        effectY.minimumRelativeValue = -effectOffset
//
//        let group = UIMotionEffectGroup()
//        group.motionEffects = [effectX, effectY]
//
//        self.contentView.addMotionEffect(group)
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
        
//        //这个值如果设置的过大的话,View移动起来卡顿会比较严重.
//        let effectOffset = 20.0
//        let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
//        let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
//
//        effectX.maximumRelativeValue = effectOffset
//        effectX.minimumRelativeValue = -effectOffset
//
//        effectY.maximumRelativeValue = effectOffset
//        effectY.minimumRelativeValue = -effectOffset
//
//        let group = UIMotionEffectGroup()
//        group.motionEffects = [effectX, effectY]
//
//        self.contentView.addMotionEffect(group)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
