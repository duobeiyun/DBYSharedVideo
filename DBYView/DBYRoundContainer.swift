//
//  DBYRoundContainer.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/12.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

class DBYRoundContainer: UIView {
    lazy var subButtons:[UIButton] = [UIButton]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height * 0.5
        layer.masksToBounds = true
    }
    
    func setButtons(buttons:[UIButton], btnSize:CGSize, margin:CGFloat) {
        if buttons.count <= 0 {
            isHidden = true
            return
        }else {
            isHidden = false
        }
        for button in subButtons {
            button.removeFromSuperview()
        }

        for (i, button) in buttons.enumerated() {
            button.bounds.size = btnSize
            let btnX:CGFloat = btnSize.width * CGFloat(i) + margin
            button.frame.origin = CGPoint(x: btnX, y: 0)
            addSubview(button)
        }
        subButtons = buttons
    }
}
