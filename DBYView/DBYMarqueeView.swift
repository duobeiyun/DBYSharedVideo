//
//  DBYMarqueeView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/1/2.
//  Copyright © 2020 钟凡. All rights reserved.
//

import UIKit

class DBYMarqueeView: DBYView {
    lazy var label:UILabel = UILabel()
    
    override func setupUI() {
        addSubview(label)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    func set(marquee: DBYMarquee) {
        isHidden = false
        label.font = UIFont.systemFont(ofSize: CGFloat(marquee.fontSize))
        if let color = marquee.color {
            label.textColor = UIColor(hex: color)
        }
        if let backgroundColor = marquee.fontBackground {
            label.backgroundColor = UIColor(hex: backgroundColor)
        }
        label.text = marquee.content
    }
}
