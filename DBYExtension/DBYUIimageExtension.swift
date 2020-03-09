//
//  DBYUIimageExtension.swift
//  DBYSDK_dylib
//
//  Created by 钟凡 on 2020/2/21.
//

import Foundation
import UIKit

extension UIImage {
    convenience init?(name: String) {
        self.init(named: name, in: currentBundle, compatibleWith: nil)
    }
    
}
