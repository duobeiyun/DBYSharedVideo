//
//  DBYTipView.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/11/14.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit
protocol DBYTipViewProtocol {
    func show(icon:UIImage?, message: String?)
    func setPosition(position: DBYTipView.Position)
    func contentSize() -> CGSize
    func setSafeSize(size: CGSize)
}
class DBYTipBaseView: DBYView {
    lazy var gradient = CAGradientLayer()
    lazy var cornerLayer = CAShapeLayer()
    var corners: UIRectCorner = .allCorners
    var position: DBYTipView.Position = .center
    var offset: CGSize = .zero
    var margin:CGFloat = 8
    
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
        if let p = self as? DBYTipViewProtocol {
            p.setPosition(position: position)
        }
    }
}
class DBYTipNormalView: DBYTipBaseView, DBYTipViewProtocol {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    func contentSize() -> CGSize {
        let height = bounds.size.height
        var minWidth = messageLabel.text?.width(withMaxHeight: height, font: messageLabel.font) ?? 0
        minWidth += 64
        return CGSize(width: minWidth, height: height)
    }
    func setPosition(position: DBYTipView.Position) {
        self.position = position
        let contentSize = self.contentSize()
        let window = UIApplication.shared.delegate?.window
        let windowSize = window??.bounds.size ?? .zero
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
    func show(icon:UIImage?, message: String?) {
        iconView.image = icon
        messageLabel.text = message
    }
    func setSafeSize(size: CGSize) {
        offset = size
        frame = frame.offsetBy(dx: size.width, dy: size.height)
    }
}
class DBYTipCloseView: DBYTipBaseView, DBYTipViewProtocol {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    func contentSize() -> CGSize {
        let height = bounds.size.height
        var minWidth = messageLabel.text?.width(withMaxHeight: height, font: messageLabel.font) ?? 0
        minWidth += 102
        return CGSize(width: minWidth, height: height)
    }
    func setPosition(position: DBYTipView.Position) {
        self.position = position
        let contentSize = self.contentSize()
        let window = UIApplication.shared.delegate?.window
        let windowSize = window??.bounds.size ?? .zero
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
    func show(icon:UIImage?, message: String?) {
        iconView.image = icon
        messageLabel.text = message
    }
    func setSafeSize(size: CGSize) {
        offset = size
        frame = frame.offsetBy(dx: size.width, dy: size.height)
    }
}
class DBYTipInviteView: DBYTipBaseView, DBYTipViewProtocol {
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
        
        acceptButton.setBackgroudnStyle(fillColor: DBYStyle.yellow,
                                     strokeColor: DBYStyle.brown,
                                     radius: btnHeight * 0.5)
        
        refuseButton.setBackgroudnStyle(fillColor: UIColor.white,
                                     strokeColor: DBYStyle.brown,
                                     radius: btnHeight * 0.5)
    }
    func contentSize() -> CGSize {
        let height = bounds.size.height
        var minWidth = messageLabel.text?.width(withMaxHeight: height, font: messageLabel.font) ?? 0
        minWidth += 200
        return CGSize(width: minWidth, height: height)
    }
    func setPosition(position: DBYTipView.Position) {
        self.position = position
        let contentSize = self.contentSize()
        let window = UIApplication.shared.delegate?.window
        let windowSize = window??.bounds.size ?? .zero
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
    func show(icon:UIImage?, message: String?) {
        iconView.image = icon
        messageLabel.text = message
    }
    func setSafeSize(size: CGSize) {
        offset = size
        frame = frame.offsetBy(dx: size.width, dy: size.height)
    }
}
class DBYTipView: DBYView {
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
    var normalView: UIView?
    var closeView: UIView?
    var inviteView: UIView?
    var position: Position = [.bottom, .center]
    
    var tipLab: UILabel!
    var imageView: UIImageView!
    
    static let margin:CGFloat = 8
    
    class func show(icon: UIImage?, message: String, type: TipType, position:Position) -> UIView? {
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
        
        if let p = typeView as? DBYTipViewProtocol {
            p.show(icon: icon, message: message)
            p.setPosition(position: position)
        }
        guard let view = typeView else {
            return typeView
        }
        
        let window = UIApplication.shared.delegate?.window
        window??.addSubview(view)
        return view
    }
    class func removeAllSubviews() {
        let window = UIApplication.shared.delegate?.window
        if let subviews = window??.subviews {
            for subview in subviews {
                if let _ = subview as? DBYTipViewProtocol {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}
