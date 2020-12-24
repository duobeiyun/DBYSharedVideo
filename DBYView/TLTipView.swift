//
//  TLTipView.swift
//  TakeALesson
//
//  Created by 钟凡 on 2020/9/10.
//  Copyright © 2020 钟凡. All rights reserved.
//

import UIKit

class TLTipView: UIView {
    @IBOutlet weak var messageLabel: UILabel!
    
    func showMessage(_ message: String) {
        messageLabel.text = message
        frame.size.width = message.width(withMaxHeight: 44, font: messageLabel.font) + 32
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        self.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 100)
    }
}
class TLTopTipView: TLTipView, ZFNibLoader {
    static func loadNibView() -> Self? {
        let views = loadViewsFromNib(name: "TLTipView", bundle: Bundle(for: Self.self))
        let tipView = views?[0] as? Self
        
        return tipView
    }
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        setRoundCorner()
    }
    //add to key window
    func show(icon: UIImage?, message: String) {
        messageLabel.text = message
        iconView.image = icon
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        self.center = CGPoint(x: UIScreen.main.bounds.midX, y: 100)
    }
}
class TLCenterTipView: TLTipView, ZFNibLoader {
    static func loadNibView() -> Self? {
        let views = loadViewsFromNib(name: "TLTipView", bundle: Bundle(for: Self.self))
        let tipView = views?[1] as? Self
        
        return tipView
    }
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        setRoundCorner(radius: 6)
    }
    func show(icon: String, message: String) {
        messageLabel.text = message
        iconView.image = UIImage(named: icon)
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        self.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY * 0.8)
    }
}
class TLBottomTipView: TLTipView, ZFNibLoader {
    static func loadNibView() -> Self? {
        let views = loadViewsFromNib(name: "TLTipView", bundle: Bundle(for: Self.self))
        let tipView = views?[2] as? Self
        
        return tipView
    }
    override func awakeFromNib() {
        setRoundCorner(radius: 6)
    }
}
class TLLineTipView: TLTipView, ZFNibLoader {
    static func loadNibView() -> Self? {
        let views = loadViewsFromNib(name: "TLTipView", bundle: Bundle(for: Self.self))
        let tipView = views?[3] as? Self
        
        return tipView
    }
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBAction func changeLine(sender: UIButton) {
        changLineBlock?()
    }
    
    var changLineBlock:(()->())?
    
    override func awakeFromNib() {
        setRoundCorner()
    }
    //add to key window
    func show() {
        indicator.startAnimating()
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        self.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY - 100)
    }
}
