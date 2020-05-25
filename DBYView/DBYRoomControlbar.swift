//
//  DBYRoomControlbar.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/15.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

protocol DBYRoomControlbarDelegate: NSObjectProtocol {
    func roomControlBarDidSelected(owner: DBYRoomControlbar, index:Int)
}

class DBYRoomControlbar: UIView {
    var btnMargin:CGFloat = 20
    var selectedButton:UIButton?
    weak var delegate:DBYRoomControlbarDelegate?
    
    lazy var buttons:[UIButton] = [UIButton]()
    lazy var barLayer:CAShapeLayer = CAShapeLayer()
    var barAnimation:CAAnimationGroup?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI() {
        barLayer.backgroundColor = DBYStyle.yellow.cgColor
        barLayer.cornerRadius = 2
        layer.addSublayer(barLayer)
        
        layer.shadowOpacity = 1
        layer.shadowColor = DBYStyle.middleGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    func append(title: String) {
        for button in buttons {
            if button.titleLabel!.text == title {
                return
            }
        }
        let btnWidth = title.width(withMaxHeight: bounds.height, font: DBYStyle.font12)
        
        let btn = UIButton(type: .custom)
        let attributesNormal = [NSAttributedString.Key.font: DBYStyle.font12,
                                NSAttributedString.Key.foregroundColor: DBYStyle.middleGray]
        let attTitleNormal = NSAttributedString(string: title, attributes: attributesNormal)
        
        let attributesSelected = [NSAttributedString.Key.font: DBYStyle.font12,
                                  NSAttributedString.Key.foregroundColor: DBYStyle.darkGray]
        let attTitleSelected = NSAttributedString(string: title, attributes: attributesSelected)
        
        btn.setAttributedTitle(attTitleNormal, for: .normal)
        btn.setAttributedTitle(attTitleSelected, for: .selected)
        btn.addTarget(self, action: #selector(click), for: .touchUpInside)
        var x:CGFloat = btnMargin
        if buttons.count > 0 {
            x = buttons[buttons.count - 1].frame.maxX + btnMargin
        }
        btn.frame = CGRect(x: x, y: 0, width: btnWidth, height: bounds.height)
        if buttons.count == 0 {
            setSelected(btn: btn)
        }
        buttons.append(btn)
        addSubview(btn)
        setSelected(btn: btn)
    }
    func removeLast() {
        let btn = buttons.removeLast()
        btn.removeFromSuperview()
        guard let last = buttons.last else {
            return
        }
        setSelected(btn: last)
    }
    @objc func click(btn: UIButton) {
        setSelected(btn: btn)
        if let index = buttons.firstIndex(of: btn) {
            delegate?.roomControlBarDidSelected(owner: self, index: index)
        }
    }
    func scroll(at index: Int) {
        if index >= buttons.count {
            return
        }
        let btn = buttons[index]
        setSelected(btn: btn)
    }
    func setSelected(btn: UIButton) {
        selectedButton?.isSelected = false
        btn.isSelected = true
        let rect = btn.frame
        barLayer.frame = CGRect(x: rect.minX,
                                y: bounds.height - 12,
                                width: rect.width,
                                height: 4)
        selectedButton = btn
    }
}
