//
//  DBYCornerButton.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/4/28.
//

import UIKit

class DBYCornerButton: UIButton {
    var backgroundLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    func setupUI() {
        backgroundLayer = CAShapeLayer()
        layer.insertSublayer(backgroundLayer, at: 0)
    }
    func setBackground(corner: UIRectCorner = .allCorners, radii: CGSize = CGSize(width: 4,height: 4), color: UIColor = .white) {
        backgroundColor = .clear
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: radii)
        backgroundLayer.fillColor = color.cgColor
        backgroundLayer.strokeColor = UIColor.clear.cgColor
        backgroundLayer.path = path.cgPath
    }
}
