//
//  DBYSettingLandscapeView.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/11/8.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

class DBYSettingLandscapeView: DBYNibView {
    var dismissBlock:(() -> ())?
    var didSelectBlock:((Int) -> ())?
    
    @IBOutlet weak var buttonGroup1: DBYButtonGroup! {
        didSet {
            buttonGroup1.delegate =  self
        }
    }
    @IBOutlet weak var buttonGroup2: DBYButtonGroup! {
        didSet {
            buttonGroup2.delegate =  self
        }
    }
    @IBOutlet weak var audioOnlyBtn: UIButton!
    
    func setButtons(titles:[String], columns:Int, selectedIndex:Int) {
        buttonGroup1.normalColor = UIColor.white
        buttonGroup2.setButtons(titles: titles, columns: columns, selectedIndex:selectedIndex)
    }
}
extension DBYSettingLandscapeView:DBYButtonGroupDelegate {
    func buttonClick(owner: DBYButtonGroup, at index: Int) {
        
    }
}
