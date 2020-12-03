//
//  ImageViewExtension.swift
//  TakeALesson
//
//  Created by 钟凡 on 2020/9/11.
//  Copyright © 2020 钟凡. All rights reserved.
//

import UIKit

extension UIImageView {
    //stride 多远画一个
    public func showImages(images: [UIImage?], stride: Int) {
        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        for (i,image) in images.enumerated() {
            let rect = CGRect(x: CGFloat(i * stride), y: 0, width: size.height, height: size.height)
            image?.draw(in: rect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = image
    }
}
