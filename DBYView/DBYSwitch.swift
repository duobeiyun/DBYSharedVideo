//
//  DBYSwitch.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/11/20.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

class DBYSwitch: UIView {

    lazy var backgroundView:UIView = UIView()
    lazy var controlBar:UIImageView = UIImageView()
    var isOn:Bool = false {
        didSet {
            if isOn {
                onAnimation()
            }else {
                offAnimation()
            }
        }
    }
    var switchStateBlock:((Bool) -> ())?
    let controlBarSize:CGSize = CGSize(width: 32, height: 32)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        setup()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = CGRect(x: bounds.height * 0.3, y: bounds.height * 0.3, width: bounds.width - bounds.height * 0.6, height: bounds.height * 0.4)
        backgroundView.layer.cornerRadius = backgroundView.bounds.height * 0.5
        controlBar.frame = CGRect(x: 0, y: (bounds.height - controlBarSize.height) * 0.5, width: controlBarSize.width, height: controlBarSize.height)
    }
    
    func addSubviews() {
        if backgroundView.superview == nil {
            addSubview(backgroundView)
        }
        if controlBar.superview == nil {
            addSubview(controlBar)
        }
    }
    func setup() {
        backgroundView.backgroundColor = DBYStyle.middleGray
        controlBar.image = UIImage(name: "oval")
        let tap = UITapGestureRecognizer(target: self, action: #selector(switchState))
        addGestureRecognizer(tap)
    }
    @objc func switchState() {
        isOn = !isOn
        switchStateBlock?(isOn)
    }
    func onAnimation() {
        UIView.animate(withDuration: 0.25) {
            self.controlBar.frame.origin = CGPoint(x: self.bounds.width - self.controlBar.bounds.width, y: (self.bounds.height - self.controlBarSize.height) * 0.5)
            self.backgroundView.backgroundColor = DBYStyle.blue
        }
    }
    func offAnimation() {
        UIView.animate(withDuration: 0.25) {
            self.controlBar.frame.origin = CGPoint(x: 0, y: (self.bounds.height - self.controlBarSize.height) * 0.5)
            self.backgroundView.backgroundColor = DBYStyle.middleGray
        }
    }
}
