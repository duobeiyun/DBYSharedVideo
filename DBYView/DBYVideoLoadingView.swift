//
//  DBYVideoLoadingView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/12/10.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

class DBYVideoLoadingView: DBYNibView {

    @IBOutlet weak var tipBtn:UIButton!
    @IBOutlet weak var imageView:UIImageView!
    
    func show(message: String?, image: UIImage) {
        tipBtn.setTitle(message, for: .normal)
        imageView.image = image
    }
}
