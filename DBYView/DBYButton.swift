//
//  DBYButton.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/12.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

public class DBYButton: UIButton {
    var layerRadius: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override public func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        updateStyle()
    }
    
    func setupUI() {
    }
}
