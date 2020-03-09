//
//  DBYNetworkTipView.swift
//  DBY1VNUI
//
//  Created by 钟凡 on 2019/1/28.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYNetworkTipViewDelegate: NSObjectProtocol {
    func confirmClick(_ owner:DBYNibView)
}

class DBYNetworkTipView: DBYNibView {
    weak var delegate:DBYNetworkTipViewDelegate?
    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var confirmBtn: UIButton! {
        didSet {
            confirmBtn.layer.cornerRadius = confirmBtn.bounds.height * 0.5
        }
    }
    @IBAction func confirmClick() {
        hidden()
        delegate?.confirmClick(self)
    }
    public func hidden() {
        removeFromSuperview()
    }
}
