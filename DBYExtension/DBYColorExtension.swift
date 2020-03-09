//
//  DBYColorExtension.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/11.
//  Copyright © 2019 钟凡. All rights reserved.
//

import Foundation

extension UIColor {
    public convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    public convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    public convenience init(hex: String) {
        let value = hex.replacingOccurrences(of: "#", with: "0x")
        let rgb:Int = Int(value) ?? 0x00
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
