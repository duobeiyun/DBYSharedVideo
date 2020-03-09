//
//  DBYNibView.swift
//  DBY1VNUI
//
//  Created by 钟凡 on 2018/12/19.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

class DBYNibView: UIView {
    var contentView : UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    func setupUI() {
        
    }
    func xibSetup() {
        backgroundColor = UIColor.clear
        contentView = loadViewFromNib()
        contentView!.frame = bounds
        contentView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView!)
    }
    func loadViewFromNib() -> UIView {
        let classType = type(of:self)
        let bundle = Bundle(for: classType)
        let nib = UINib(nibName: "\(classType)", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
