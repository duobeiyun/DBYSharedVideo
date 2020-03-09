//
//  DBYVerticalButton.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/29.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

class DBYVerticalButton: UIButton {

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 20)
    }
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: 0, y: bounds.height - 20, width: bounds.width, height: 20)
    }

}
