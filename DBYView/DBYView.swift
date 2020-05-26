//
//  DBYView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/25.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

class DBYView: UIView {
    lazy var backgroundLayer: CAShapeLayer = CAShapeLayer()
    var layerRadius: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect: bounds,
                                cornerRadius: layerRadius)
        backgroundLayer.path = path.cgPath
    }
    func setupUI() {
        
    }
    func setBackgroudnStyle(fillColor: UIColor,
                            strokeColor: UIColor,
                            radius: CGFloat) {
        backgroundLayer.fillColor = fillColor.cgColor
        backgroundLayer.strokeColor = strokeColor.cgColor
        layerRadius = radius
        layer.insertSublayer(backgroundLayer, at: 0)
    }
    func removeBackgroudnStyle() {
        backgroundLayer.removeFromSuperlayer()
        layerRadius = 0
    }
}
