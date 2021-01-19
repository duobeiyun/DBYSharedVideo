//
//  DBYBottomSafeView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2021/1/18.
//

import UIKit
import SnapKit

class DBYBottomSafeView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if isIphoneXSeries() {
            return
        }
        let safeOffset = bounds.height - 34
        snp_updateConstraints { (make) in
            make.height.equalTo(safeOffset)
        }
    }
}
