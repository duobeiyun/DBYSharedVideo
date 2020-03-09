//
//  DBYSettingView.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/11/6.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

protocol DBYSettingViewDelegate: NSObjectProtocol {
    func settingView(owner: DBYSettingView, didSelectedItemAt indexPath: IndexPath)
}
class DBYSettingView: DBYView {
    lazy var normalLab = UILabel()
    lazy var lineLab = UILabel()
    lazy var speedLab = UILabel()
    lazy var normalGroup: DBYButtonGroup = DBYButtonGroup()
    lazy var lineGroup: DBYButtonGroup = DBYButtonGroup()
    lazy var speedGroup: DBYButtonGroup = DBYButtonGroup()
    
    weak var delegate: DBYSettingViewDelegate?
    
    override func setupUI() {
        backgroundColor = DBYStyle.darkAlpha
        
        normalLab.textColor = UIColor.white
        normalLab.font = UIFont.systemFont(ofSize: 12)
        normalLab.text = "通用设置"
        normalLab.isHidden = true
        
        lineLab.textColor = UIColor.white
        lineLab.font = UIFont.systemFont(ofSize: 12)
        lineLab.text = "线路切换"
        lineLab.isHidden = true
        
        speedLab.textColor = UIColor.white
        speedLab.font = UIFont.systemFont(ofSize: 12)
        speedLab.text = "倍速播放"
        speedLab.isHidden = true
        
        normalGroup.delegate = self
        speedGroup.delegate = self
        lineGroup.delegate = self
        
        addSubview(normalLab)
        addSubview(lineLab)
        addSubview(speedLab)
        addSubview(normalGroup)
        addSubview(speedGroup)
        addSubview(lineGroup)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = bounds.size
        
        normalLab.frame = CGRect(x: 12, y: 16, width: 100, height: 20)
        speedLab.frame = CGRect(x: 12, y: 136, width: 100, height: 20)
        lineLab.frame = CGRect(x: 12, y: 256, width: 100, height: 20)
        normalGroup.frame = CGRect(x: 0, y: 36, width: size.width, height: 60)
        speedGroup.frame = CGRect(x: 0, y: 156, width: size.width, height: 100)
        lineGroup.frame = CGRect(x: 0, y: 276, width: size.width, height: 100)
    }
    
    func set(buttons:[UIButton]) {
        normalLab.isHidden = false
        normalGroup.setButtons(buttons: buttons)
    }
    func set(lines:[String]) {
        lineLab.isHidden = false
        lineGroup.setButtons(titles: lines, columns: 5, selectedIndex: 0)
    }
    func set(speeds:[String]) {
        speedLab.isHidden = false
        speedGroup.setButtons(titles: speeds, columns: 5, selectedIndex: 2)
    }
}
extension DBYSettingView:DBYButtonGroupDelegate {
    func buttonClick(owner: DBYButtonGroup, at index: Int) {
        var section = -1
        if owner == normalGroup {
            section = 0
        }
        if owner == speedGroup {
            section = 1
        }
        if owner == lineGroup {
            section = 2
        }
        if section < 0 {
            return
        }
        let indexPath = IndexPath(item: index, section: section)
        delegate?.settingView(owner: self, didSelectedItemAt: indexPath)
    }
}
