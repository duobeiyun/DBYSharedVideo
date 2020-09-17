//
//  DBYTipView.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/11/14.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit
protocol DBYTipViewUIProtocol {
    func show(icon:UIImage?, message: String?)
    func setPosition(position: DBYTipView.Position)
    func setContentOffset(size: CGSize)
}
protocol DBYTipViewInviteable {
    
}
class DBYTipBaseView: DBYView {
    lazy var gradient = CAGradientLayer()
    lazy var cornerLayer = CAShapeLayer()
    var corners: UIRectCorner = .allCorners
    var position: DBYTipView.Position = .center
    var offset: CGSize = .zero
    var margin: CGFloat = 8
    var type: DBYTipView.TipType = .normal
    
    override func setupUI() {
        super.setupUI()
        backgroundColor = UIColor.clear
        gradient.colors = [UIColor.white.cgColor, DBYStyle.middleGray.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradient, at: 0)
        layer.shadowColor = DBYStyle.middleGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = bounds.height * 0.5
        let radii = CGSize(width: radius, height: radius)
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: radii)
        cornerLayer.path = path.cgPath
        gradient.mask = cornerLayer
        gradient.frame = bounds
    }
    func contentSize() -> CGSize {
        return .zero
    }
    func updateFrame(contentSize:CGSize) {
        let windowSize = superview?.bounds.size ?? .zero
        var x:CGFloat = 0
        var y:CGFloat = 0
        if position.contains(.center) {
            x = (windowSize.width - contentSize.width) * 0.5
            y = (windowSize.height - contentSize.height) * 0.5
        }
        if position.contains(.left) {
            x = 0
        }
        if position.contains(.right) {
            x = windowSize.width - contentSize.width
        }
        if position.contains(.bottom) {
            y = windowSize.height - contentSize.height - margin
        }
        if position.contains(.top) {
            y = contentSize.height + margin
        }
        frame = CGRect(x: x - offset.width, y: y - offset.height, width: contentSize.width, height: contentSize.height)
    }
}
class DBYTipNormalView: DBYTipBaseView, DBYTipViewUIProtocol {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func contentSize() -> CGSize {
        let height = bounds.size.height
        var minWidth = messageLabel.text?.width(withMaxHeight: height, font: messageLabel.font) ?? 0
        minWidth += 64
        return CGSize(width: minWidth, height: height)
    }
    func setPosition(position: DBYTipView.Position) {
        self.position = position
        let size = self.contentSize()
        updateFrame(contentSize: size)
    }
    func show(icon:UIImage?, message: String?) {
        iconView.image = icon
        messageLabel.text = message
    }
    func setContentOffset(size: CGSize) {
        offset = size
        frame = frame.offsetBy(dx: size.width, dy: size.height)
    }
}
class DBYTipClickView: DBYTipBaseView, DBYTipViewUIProtocol {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var clickBlock:(()->())?
    
    override func setupUI() {
        super.setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(click(ges:)))
        addGestureRecognizer(tap)
    }
    @objc func click(ges: UITapGestureRecognizer) {
        clickBlock?()
    }
    override func contentSize() -> CGSize {
        let height = bounds.size.height
        var minWidth = messageLabel.text?.width(withMaxHeight: height, font: messageLabel.font) ?? 0
        minWidth += 64
        return CGSize(width: minWidth, height: height)
    }
    func setPosition(position: DBYTipView.Position) {
        self.position = position
        let size = self.contentSize()
        updateFrame(contentSize: size)
    }
    func show(icon:UIImage?, message: String?) {
        iconView.image = icon
        messageLabel.text = message
    }
    func setContentOffset(size: CGSize) {
        offset = size
        frame = frame.offsetBy(dx: size.width, dy: size.height)
    }
}
class DBYTipCloseView: DBYTipBaseView, DBYTipViewUIProtocol {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func close(sender: UIButton) {
        closeBlock?()
    }
    
    var closeBlock:(()->())?
    
    override func contentSize() -> CGSize {
        let height = bounds.size.height
        var minWidth = messageLabel.text?.width(withMaxHeight: height, font: messageLabel.font) ?? 0
        minWidth += 102
        return CGSize(width: minWidth, height: height)
    }
    func setPosition(position: DBYTipView.Position) {
        self.position = position
        let contentSize = self.contentSize()
        updateFrame(contentSize: contentSize)
    }
    func show(icon:UIImage?, message: String?) {
        iconView.image = icon
        messageLabel.text = message
    }
    func setContentOffset(size: CGSize) {
        offset = size
        frame = frame.offsetBy(dx: size.width, dy: size.height)
    }
}
class DBYTipInviteView: DBYTipBaseView, DBYTipViewUIProtocol {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var acceptButton: DBYButton!
    @IBOutlet weak var refuseButton: DBYButton!
    @IBAction func accept(sender: UIButton) {
        acceptBlock?()
    }
    @IBAction func refuse(sender: UIButton) {
        refuseBlock?()
    }
    let btnHeight: CGFloat = 30
    
    var acceptBlock:(()->())?
    var refuseBlock:(()->())?
    
    override func setupUI() {
        super.setupUI()
        let att = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                   NSAttributedString.Key.foregroundColor: DBYStyle.brown]
        let attStr1 = NSAttributedString(string: "接 受", attributes: att)

        acceptButton.setAttributedTitle(attStr1, for: .normal)
        acceptButton.setTitleColor(DBYStyle.brown, for: .normal)
        let attStr2 = NSAttributedString(string: "拒 绝", attributes: att)
        refuseButton.setAttributedTitle(attStr2, for: .normal)
        refuseButton.setTitleColor(DBYStyle.brown, for: .normal)

        acceptButton.setBackgroundStyle(fillColor: DBYStyle.yellow,
                                        borderColor: DBYStyle.brown,
                                        radius: btnHeight * 0.5)
        
        refuseButton.setBackgroundStyle(fillColor: UIColor.white,
                                        borderColor: DBYStyle.brown,
                                        radius: btnHeight * 0.5)
    }
    override func contentSize() -> CGSize {
        let height = bounds.size.height
        var minWidth = messageLabel.text?.width(withMaxHeight: height, font: messageLabel.font) ?? 0
        minWidth += 200
        return CGSize(width: minWidth, height: height)
    }
    func setPosition(position: DBYTipView.Position) {
        self.position = position
        let contentSize = self.contentSize()
        updateFrame(contentSize: contentSize)
    }
    func show(icon:UIImage?, message: String?) {
        iconView.image = icon
        messageLabel.text = message
    }
    func setContentOffset(size: CGSize) {
        offset = size
        frame = frame.offsetBy(dx: size.width, dy: size.height)
    }
}
class DBYTipView {
    enum TipType: Int {
        case unknow
        case invite
        case close
        case click
        case normal
    }
    struct Position: OptionSet {
        let rawValue: Int
        
        static let top = Position(rawValue: 1 << 0)
        static let bottom = Position(rawValue: 1 << 1)
        static let left = Position(rawValue: 1 << 2)
        static let right = Position(rawValue: 1 << 3)
        static let center = Position(rawValue: 1 << 4)
    }
    
    class func loadViewsFromNib(name: String) -> [UIView]? {
        let bundle = Bundle(for: DBYTipView.self)
        let nib = UINib(nibName: name, bundle: bundle)
        let views = nib.instantiate(withOwner: nil, options: nil) as? [UIView]
        return views
    }
    class func loadView(type: TipType) -> UIView? {
        let views = loadViewsFromNib(name: "DBYTipView")
        var typeView: UIView?
        if type == .normal {
            typeView = views?[0]
        }
        if type == .close {
            typeView = views?[1]
        }
        if type == .invite {
            typeView = views?[2]
        }
        if type == .click {
            typeView = views?[3]
        }
        
        guard let view = typeView as? DBYTipBaseView else {
            return typeView
        }
        view.type = type
        return view
    }
    
    class func removeTipViews(on view: UIView) {
        for subview in view.subviews {
            if let _ = subview as? DBYTipViewUIProtocol {
                subview.removeFromSuperview()
            }
        }
    }
    class func removeTipViews(type: DBYTipView.TipType, on view: UIView) {
        for subview in view.subviews {
            if let tipView = subview as? DBYTipBaseView, tipView.type == type {
                tipView.removeFromSuperview()
            }
        }
    }
}
