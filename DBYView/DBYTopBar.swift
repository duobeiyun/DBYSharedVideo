//
//  DBYTopBar.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/28.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

public enum DBYTopBarType:Int {
    case portrait
    case landscape
}
protocol DBYTopBarDelegate: NSObjectProtocol {
    func backButtonClick(owner: DBYTopBar)
    func settingButtonClick(owner: DBYTopBar)
}
class DBYTopBar: DBYView {
    let font12 = UIFont.systemFont(ofSize: 12)
    lazy var leftBtn:UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = font12
        btn.titleLabel?.textColor = UIColor.white
        btn.contentHorizontalAlignment = .left
        btn.setTitle("返回", for: .normal)
        btn.setImage(UIImage(name: "arrow-left"), for: .normal)
        return btn
    }()
    lazy var rightBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(name: "more"), for: .normal)
        return btn
    }()
    lazy var gradientLayer: CAGradientLayer = CAGradientLayer()
    
    var titleWidth:CGFloat = 100
    
    weak var delegate: DBYTopBarDelegate?
    
    override func setupUI() {
        let cgColors:[CGColor] = [
            DBYStyle.darkAlpha.cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]
        gradientLayer.colors = cgColors
        
        layer.insertSublayer(gradientLayer, at: 0)
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        leftBtn.addTarget(self,
                          action: #selector(backButtonClick),
                          for: .touchUpInside)
        rightBtn.addTarget(self,
                          action: #selector(settingButtonClick),
                          for: .touchUpInside)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = bounds.size
        
        gradientLayer.frame = bounds
        leftBtn.frame = CGRect(x: 12,
                               y: 12,
                               width: titleWidth,
                               height: 24)
        rightBtn.frame = CGRect(x: size.width - 12 - 24,
                                y: 12,
                                width: 24,
                                height: 24)
    }
    @objc func backButtonClick() {
        delegate?.backButtonClick(owner: self)
    }
    @objc func settingButtonClick() {
        delegate?.settingButtonClick(owner: self)
    }
    func set(_ title: String?){
        titleWidth = title?.width(withMaxHeight: 24, font: font12) ?? 80
        titleWidth += 24
        leftBtn.setTitle(title, for: .normal)
        let size = bounds.size
        leftBtn.frame = CGRect(x: 12,
                               y: size.height - 12 - 24,
                               width: titleWidth,
                               height: 24)
    }
    func set(type: DBYTopBarType) {
        leftBtn.removeFromSuperview()
        rightBtn.removeFromSuperview()
        
        if type == .portrait {
            addSubview(leftBtn)
        }
        if type == .landscape {
            addSubview(leftBtn)
            addSubview(rightBtn)
        }
    }
}
