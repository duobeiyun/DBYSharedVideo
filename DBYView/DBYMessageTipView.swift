//
//  DBYMessageTipView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/11.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

enum DBYMessageTipType: Int {
    case unknow
    case invite
    case close
    case click
    case normal
}
protocol DBYMessageTipViewDelegate: NSObjectProtocol {
    func messageTipViewAcceptInvite(owner: DBYMessageTipView)
    func messageTipViewRefuseInvite(owner: DBYMessageTipView)
    func messageTipViewWillDismiss(owner: DBYMessageTipView)
    func messageTipViewDidClick(owner: DBYMessageTipView)
}
class DBYMessageTipView: DBYView {
    lazy var iconView: UIImageView = UIImageView()
    lazy var messageLab: UILabel = UILabel()
    lazy var gradient = CAGradientLayer()
    lazy var cornerLayer = CAShapeLayer()
    lazy var acceptBtn:DBYButton = {
        let btn = DBYButton()
        let att = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                   NSAttributedString.Key.foregroundColor: DBYStyle.brown]
        let attStr = NSAttributedString(string: "接 受", attributes: att)
        btn.setAttributedTitle(attStr, for: .normal)
        btn.setTitleColor(DBYStyle.brown, for: .normal)
        return btn
    }()
    lazy var refuseBtn:DBYButton = {
        let btn = DBYButton()
        let att = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                   NSAttributedString.Key.foregroundColor: DBYStyle.brown]
        let attStr = NSAttributedString(string: "拒 绝", attributes: att)
        btn.setAttributedTitle(attStr, for: .normal)
        btn.setTitleColor(DBYStyle.brown, for: .normal)
        return btn
    }()
    lazy var closeBtn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(name: "close-18"), for: .normal)
        return btn
    }()
    lazy var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    
    let hMargin: CGFloat = 8
    let vMargin: CGFloat = 4
    let btnWidth: CGFloat = 60
    
    var corners: UIRectCorner = .allCorners
    var tipType: DBYMessageTipType = .unknow
    var timer: Timer?
    weak var delegate:DBYMessageTipViewDelegate?
    var messageLabWidth: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconHeight: CGFloat = bounds.height - vMargin * 2
        let btnHeight: CGFloat = bounds.height - vMargin * 2
        iconView.frame = CGRect(x: 0,
                                y: vMargin,
                                width: iconHeight,
                                height: iconHeight)
        messageLab.frame = CGRect(x: iconView.frame.maxX + hMargin,
                                  y: vMargin,
                                  width: messageLabWidth,
                                  height: iconHeight)
        closeBtn.frame = CGRect(x: bounds.width - btnHeight - hMargin,
                                y: vMargin,
                                width: btnHeight,
                                height: btnHeight)
        refuseBtn.frame = CGRect(x: bounds.width - btnWidth - hMargin,
                                 y: vMargin,
                                 width: btnWidth,
                                 height: btnHeight)
        acceptBtn.frame = refuseBtn.frame.offsetBy(dx: -btnWidth - hMargin, dy: 0)
        gradient.frame = bounds
        
        acceptBtn.setBackgroudnStyle(fillColor: DBYStyle.yellow,
                                     strokeColor: DBYStyle.brown,
                                     radius: btnHeight * 0.5)
        
        refuseBtn.setBackgroudnStyle(fillColor: UIColor.white,
                                     strokeColor: DBYStyle.brown,
                                     radius: btnHeight * 0.5)
        
        let radius = bounds.height * 0.5
        let radii = CGSize(width: radius, height: radius)
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: radii)
        cornerLayer.path = path.cgPath
        gradient.mask = cornerLayer
    }
    override func setupUI() {
        gradient.colors = [UIColor.white.cgColor, DBYStyle.middleGray.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        closeBtn.addTarget(self,
                           action: #selector(close),
                           for: .touchUpInside)
        acceptBtn.addTarget(self,
                            action: #selector(accept),
                            for: .touchUpInside)
        refuseBtn.addTarget(self,
                            action: #selector(refuse),
                            for: .touchUpInside)
        tapGesture.addTarget(self, action: #selector(tap))
        
        messageLab.font = UIFont.systemFont(ofSize: 12)
        messageLab.textColor = DBYStyle.darkGray
        
        iconView.contentMode = .center
        
        addSubview(iconView)
        addSubview(messageLab)
    }
    func set(corners: UIRectCorner) {
        self.corners = corners
        setNeedsLayout()
        layoutIfNeeded()
    }
    func show(icon: UIImage?, message: String, type: DBYMessageTipType) {
        tipType = type
        iconView.image = icon
        messageLab.text = message
        
        removeBackgroudnStyle()
        gradient.removeFromSuperlayer()
        acceptBtn.removeFromSuperview()
        refuseBtn.removeFromSuperview()
        closeBtn.removeFromSuperview()
        removeGestureRecognizer(tapGesture)
        
        let contentHeight: CGFloat = bounds.height - vMargin * 2
        messageLabWidth = message.width(withMaxHeight: contentHeight,
                                        font: UIFont.systemFont(ofSize: 12))
        
        switch type {
        case .close:
            addSubview(closeBtn)
            layer.insertSublayer(gradient, at: 0)
        case .invite:
            addSubview(acceptBtn)
            addSubview(refuseBtn)
            layer.insertSublayer(gradient, at: 0)
        case .click:
            addGestureRecognizer(tapGesture)
            setBackgroudnStyle(fillColor: UIColor.white,
                               strokeColor: DBYStyle.brown,
                               radius: bounds.height * 0.5)
            break
        default:
            break
        }
        UIView.animate(withDuration: 0.25) {
            self.isHidden = false
        }
        stopHiddenTimer()
        if type != .invite && type != .click {
            startHiddenTimer()
        }
    }
    func getContentWidth() -> CGFloat {
        let contentHeight: CGFloat = bounds.height - vMargin * 2
        var constWidth:CGFloat = 0
        switch tipType {
        case .close:
            constWidth = (contentHeight + hMargin) * 2
        case .invite:
            constWidth = btnWidth * 2 + hMargin * 4 + contentHeight
        case .click:
            constWidth = contentHeight + hMargin * 3
            break
        default:
            break
        }
        return messageLabWidth + constWidth
    }
    func startHiddenTimer() {
        
    }
    func stopHiddenTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc override func dismiss() {
        UIView.animate(withDuration: 0.25) {
            self.isHidden = true
        }
        stopHiddenTimer()
    }
    @objc func close() {
        dismiss()
    }
    @objc func accept() {
        delegate?.messageTipViewAcceptInvite(owner: self)
        dismiss()
    }
    @objc func refuse() {
        delegate?.messageTipViewRefuseInvite(owner: self)
        dismiss()
    }
    @objc func tap() {
        dismiss()
        delegate?.messageTipViewDidClick(owner: self)
    }
}
