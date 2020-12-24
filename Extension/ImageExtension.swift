//
//  ImageExtension.swift
//  ZFViewStyle
//
//  Created by 钟凡 on 2020/9/10.
//

import UIKit
import CoreImage

extension UIImage {
    convenience init?(name: String) {
        self.init(named: name, in: currentBundle, compatibleWith: nil)
    }
    public func gaussianImage() -> UIImage {
        let imageToBlur = CIImage(image: self)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(imageToBlur, forKey: kCIInputImageKey)
        if let resultImage = blurfilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            return UIImage(ciImage: resultImage)
        }
        return self
    }
}
