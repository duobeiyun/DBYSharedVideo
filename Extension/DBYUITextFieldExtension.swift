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

private var regexKey = "regexKey"
private var maxCountKey = "maxCountKey"
private var textChangeBlockKey = "textChangeBlockKey"

extension UITextField {
    public var regex:String? {
        set (newValue) {
            objc_setAssociatedObject(self, &regexKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &regexKey) as? String
        }
    }
    public var maxCount:Int {
        set (newValue) {
            objc_setAssociatedObject(self, &maxCountKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &maxCountKey) as? Int ?? 0
        }
    }
    public var textChangeBlock:((String?)->())? {
        set (newValue) {
            weak var weakSelf = self
            addTarget(weakSelf, action: #selector(textChange(textField:)), for: .editingChanged)
            objc_setAssociatedObject(self, &textChangeBlockKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
        get {
            return objc_getAssociatedObject(self, &textChangeBlockKey) as? ((String?)->())
        }
    }
    @objc func textChange(textField: UITextField) {
        let text = textField.text ?? ""
        let count = text.count
        if let _ = textField.markedTextRange {
            return
        }
        if (maxCount > 0 && count > maxCount) {
            let subIndex = text.index(text.startIndex, offsetBy: maxCount)
            textField.text = String(text[..<subIndex])
        }
        textChangeBlock?(textField.text)
    }
}
