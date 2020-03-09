//
//  DBYUIButtonExtension.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/10.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

let maskLayer = CAShapeLayer()
extension UIButton {
    public func setRoundBackground(color:UIColor) {
        setNeedsLayout()
        clipsToBounds = true
        
        let xCenter = bounds.size.width * 0.5
        let yCenter = bounds.size.height * 0.5
        
        let radius = min(xCenter, yCenter)
        
        let circlePath = UIBezierPath(roundedRect: bounds, cornerRadius: radius)
        maskLayer.strokeColor = nil
        maskLayer.fillColor = color.cgColor
        maskLayer.path = circlePath.cgPath
        
        maskLayer.removeFromSuperlayer()
        layer.insertSublayer(maskLayer, at: 0)
    }
}
