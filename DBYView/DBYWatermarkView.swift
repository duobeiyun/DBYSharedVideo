//
//  DBYWatermarkView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/12/31.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit
import DBYSDK_dylib
import SDWebImage

class DBYWatermarkView: DBYView {
    lazy var label:UILabel = UILabel()
    lazy var imageView:UIImageView = UIImageView()
    
    override func setupUI() {
        addSubview(label)
        addSubview(imageView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
        imageView.frame = bounds
    }
    func set(watermark: DBYWatermark) {
        label.isHidden = true
        imageView.isHidden = true
        if watermark.type == .text {
            label.isHidden = false
            label.text = watermark.text
        }
        if watermark.type == .image {
            imageView.isHidden = false
            let url = DBYUrlConfig.shared().staticUrl(withSourceName: watermark.image ?? "")
            imageView.sd_setImage(with: URL(string: url), completed: nil)
        }
    }
}
