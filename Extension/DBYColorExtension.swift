//
//  DBYColorExtension.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/11.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    public convenience init(rgb: Int) {
        self.init(
            r: (rgb >> 16) & 0xFF,
            g: (rgb >> 8) & 0xFF,
            b: rgb & 0xFF
        )
    }
    public convenience init(hex: String) {
        let value = hex.replacingOccurrences(of: "#", with: "0x")
        let rgb:Int = Int(value) ?? 0x00
        self.init(
            r: (rgb >> 16) & 0xFF,
            g: (rgb >> 8) & 0xFF,
            b: rgb & 0xFF
        )
    }
}
