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
    public func setBackgroundStyle(fillColor: UIColor,
                         borderColor: UIColor,
                         radius: CGFloat) {
        backgroundColor = fillColor
        layer.borderColor = borderColor.cgColor
        layer.cornerRadius = radius;
        clipsToBounds = true;
    }
}
