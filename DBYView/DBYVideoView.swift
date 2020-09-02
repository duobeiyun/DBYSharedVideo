//
//  DBYVideoView.swift
//  DBY1VNUI
//
//  Created by 钟凡 on 2019/8/28.
//

import UIKit

class DBYVideoView: UIView {
    var imageHolder:UIImageView?
    var loadingDelegate:DBYVideoTipViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildUI()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        buildUI()
    }
    func buildUI() {
        let imageView = UIImageView()
        insertSubview(imageView, at: 0)
        imageHolder = imageView
        imageHolder?.frame = self.bounds
        imageHolder?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    func setImageHolder(image:UIImage?) {
        imageHolder?.image = image
    }
}
