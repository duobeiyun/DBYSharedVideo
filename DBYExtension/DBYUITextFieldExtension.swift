//
//  DBYUITextFieldExtension.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/11.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

extension UITextField {
    ///需要设置UITextField的高度，不然计算不出准确位置
    func roundBorder(color: UIColor) {
        borderStyle = .none
        layer.cornerRadius = bounds.size.height * 0.5
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
    }
}
