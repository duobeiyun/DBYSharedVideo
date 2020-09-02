//
//  DBYFullTipView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/9/1.
//

import UIKit

protocol DBYNetworkTipViewDelegate: NSObjectProtocol {
    func confirmClick(_ owner: DBYNetworkTipView)
}
protocol DBYVideoTipViewDelegate: NSObjectProtocol {
    func continueClick(_ owner: DBYPauseTipView)
}
protocol DBYLoadingTipViewDelegate: NSObjectProtocol {
    func changeLineClick(_ owner: DBYLoadingTipView)
}

class DBYPauseTipView: DBYView, ZFNibLoader {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playBtn: DBYButton!
    @IBAction func click(sender: UIButton) {
        delegate?.continueClick(self)
    }
    weak var delegate:DBYVideoTipViewDelegate?
    
    override func setupUI() {
        super.setupUI()
        let radius = playBtn.bounds.height * 0.5
        playBtn.setBackgroudnStyle(fillColor: DBYStyle.yellow,
                                   strokeColor: DBYStyle.brown,
                                   radius: radius)
    }
    public static func loadNibView() -> Self? {
        let views = loadViewsFromNib(name: "DBYFullTipView", bundle: Bundle(for: Self.self))
        let tipView = views?[1] as? Self
        
        return tipView
    }
}
class DBYLoadingTipView: DBYView, ZFNibLoader {
    @IBOutlet weak var tipBtn:DBYCornerButton!
    @IBOutlet weak var imageView:UIImageView!
    
    weak var delegate:DBYLoadingTipViewDelegate?
    
    public static func loadNibView() -> Self? {
        let views = loadViewsFromNib(name: "DBYFullTipView", bundle: Bundle(for: Self.self))
        let tipView = views?[2] as? Self
        
        return tipView
    }
}
class DBYNetworkTipView: DBYView, ZFNibLoader {
    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var confirmBtn: UIButton! {
        didSet {
            confirmBtn.layer.cornerRadius = confirmBtn.bounds.height * 0.5
        }
    }
    @IBAction func confirmClick() {
        delegate?.confirmClick(self)
    }
    
    weak var delegate:DBYNetworkTipViewDelegate?
    
    public static func loadNibView() -> Self? {
        let views = loadViewsFromNib(name: "DBYFullTipView", bundle: Bundle(for: Self.self))
        let tipView = views?[3] as? Self
        
        return tipView
    }
}
