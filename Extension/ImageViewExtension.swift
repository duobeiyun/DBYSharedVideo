//
//  ImageViewExtension.swift
//  TakeALesson
//
//  Created by 钟凡 on 2020/9/11.
//  Copyright © 2020 钟凡. All rights reserved.
//

import UIKit

extension UIImageView {
    func showImages(images: [UIImage?], stride: Int) -> UIImage? {
        let size = bounds.size
        UIGraphicsBeginImageContext(size)
        for (i,image) in images.enumerated() {
            image?.draw(at: CGPoint(x: i * stride, y: 0))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
