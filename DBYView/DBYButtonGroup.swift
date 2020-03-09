//
//  DBYButtonGroup.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/11/6.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

protocol DBYButtonGroupDelegate: NSObjectProtocol {
    func buttonClick(owner: DBYButtonGroup, at index:Int)
}
class DBYButtonGroup: UIView {
    weak var delegate:DBYButtonGroupDelegate?
    var normalColor:UIColor = DBYStyle.middleGray
    var selectedColor:UIColor = DBYStyle.blue
    lazy var buttons:[UIButton] = [UIButton]()
    var columns = 5
    
    func setButtons(buttons:[UIButton]) {
        self.buttons = buttons
        for button in buttons {
            button.removeFromSuperview()
        }
        
        for btn in buttons {
            addSubview(btn)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let btnWidth = bounds.width / CGFloat(columns)
        let btnHeight = bounds.height
        for (i, btn) in buttons.enumerated() {
            btn.frame = CGRect(x: CGFloat(i) * btnWidth, y: 0, width: btnWidth, height: btnHeight)
        }
    }
    func setButtons(titles:[String], columns:Int, selectedIndex:Int) {
        self.columns = columns
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons.removeAll()
        
        let btnWidth = bounds.width / CGFloat(columns)
        let btnHeight = bounds.height / CGFloat(titles.count - 1 / columns + 1)
        
        for (i, title) in titles.enumerated() {
            let btnY = CGFloat((i - 1) / columns) * btnHeight
            let btn = UIButton()
            btn.tag = i
            btn.setTitle(title, for: .normal)
            btn.setTitle(title, for: .selected)
            btn.setTitleColor(normalColor, for: .normal)
            btn.setTitleColor(selectedColor, for: .selected)
            btn.frame = CGRect(x: CGFloat(i) * btnWidth, y: btnY, width: btnWidth, height: btnHeight)
            btn.addTarget(self, action: #selector(click), for: .touchUpInside)
            if i == selectedIndex {
                btn.isSelected = true
            }
            addSubview(btn)
            buttons.append(btn)
        }
    }
    @objc func click(btn:UIButton) {
        for button in buttons {
            button.isSelected = false
        }
        btn.isSelected = true
        delegate?.buttonClick(owner: self, at: btn.tag)
    }
}
