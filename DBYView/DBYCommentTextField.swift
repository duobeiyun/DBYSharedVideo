//
//  DBYCommentTextField.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/12.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

class DBYCommentTextField: UITextField {
    let iconContainView = UIView(frame: .zero)
    let imageView = UIImageView(image: UIImage(name: "icon-text"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        customUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        customUI()
    }
    func customUI() {
        iconContainView.addSubview(imageView)
        leftView = iconContainView
        leftViewMode = .always
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        iconContainView.frame = CGRect(x: 0, y: 0, width: 40, height: bounds.height)
        imageView.frame = CGRect(x: 8, y: (bounds.height - 24) * 0.5, width: 24, height: 24)
        roundBorder(color:  DBYStyle.lightGray)
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 40, y: 0, width: bounds.width - 40, height: bounds.height)
    }
}
