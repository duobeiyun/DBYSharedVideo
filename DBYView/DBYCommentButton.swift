//
//  DBYCommentButton.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/11/15.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

class DBYCommentButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: contentRect.height, height: contentRect.height)
    }
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: contentRect.height, y: 0, width: contentRect.width - contentRect.height, height: contentRect.height)
    }
}
