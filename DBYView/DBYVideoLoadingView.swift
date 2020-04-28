//
//  DBYVideoLoadingView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/12/10.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

class DBYVideoLoadingView: DBYNibView {

    @IBOutlet weak var tipBtn:DBYCornerButton!
    @IBOutlet weak var imageView:UIImageView!
    
    override func setupUI() {
        tipBtn.titleLabel?.textAlignment = .center
        tipBtn.setBackground(corner: [.bottomRight, .topRight], radii: CGSize(width: 12, height: 12), color: DBYStyle.yellow)
    }
    func show(message: String?, image: UIImage) {
        tipBtn.setTitle(message, for: .normal)
        imageView.image = image
    }
}
