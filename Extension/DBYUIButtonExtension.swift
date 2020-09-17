//
//  DBYUIButtonExtension.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/10.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

private var backgroundLayerKey = "BackgroundLayerKey"

extension UIButton {
    public func setRoundCorner(radius: CGFloat) {
        layer.cornerRadius = radius;
        clipsToBounds = true;
    }
    ///根据宽高一半的最小值设置圆角
    public func setRoundCorner() {
        let xCenter = bounds.size.width * 0.5
        let yCenter = bounds.size.height * 0.5
        
        let radius = min(xCenter, yCenter)
        
        layer.cornerRadius = radius;
        clipsToBounds = true;
    }
    public func setBackgroundStyle(fillColor: UIColor,
                         borderColor: UIColor,
                         radius: CGFloat) {
        backgroundColor = fillColor
        layer.borderColor = borderColor.cgColor
        layer.cornerRadius = radius;
        clipsToBounds = true;
    }
}
