//
//  DBYEmptyView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/5/25.
//

import UIKit

class DBYEmptyView: DBYView {
    var tipLab: UILabel!
    var imageView: UIImageView!
    
    override func setupUI() {
        tipLab = UILabel()
        tipLab.textColor = DBYStyle.darkGray
        tipLab.font = DBYStyle.font12
        tipLab.textAlignment = .center
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        addSubview(tipLab)
        addSubview(imageView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame.size = CGSize(width: 100, height: 100)
        imageView.center = center
        tipLab.frame = CGRect(x: 0, y: imageView.frame.maxY + 8, width: frame.width, height: 20)
    }
    convenience init(image:UIImage?, message:String?){
        self.init()
        imageView.image = image
        tipLab.text = message
    }
}
