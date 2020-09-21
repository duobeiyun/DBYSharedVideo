//
//  DBYHangUpView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/15.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYHangUpViewDelegate: NSObjectProtocol {
    func hangUpViewShouldHangUp(owner: DBYHangUpView)
}
class DBYHangUpView: DBYNibView {
    let backgroundLayer = CAShapeLayer()
    weak var delegate:DBYHangUpViewDelegate?
    
    @IBOutlet weak var nameLab: UILabel!
//    @IBOutlet weak var slider: DBYSlider! {
//        didSet {
//            slider.delegate = self
//        }
//    }
    @IBOutlet weak var hangUpBtn: DBYButton! {
        didSet {
            let radius:CGFloat = 14
            hangUpBtn.setBackgroundStyle(fillColor: DBYStyle.yellow,
                                         borderColor: DBYStyle.brown,
                                         radius: radius)
        }
    }
    @IBAction func hangUp(sender: DBYButton) {
        delegate?.hangUpViewShouldHangUp(owner: self)
    }
    override func setupUI() {
        contentView?.layer.insertSublayer(backgroundLayer, at: 0)
        let drag = UIPanGestureRecognizer(target: self,
        action: #selector(dragVideoView(pan:)))
        addGestureRecognizer(drag)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = bounds.height * 0.5
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.topLeft, .bottomLeft],
                                cornerRadii: CGSize(width: radius, height: radius))
        backgroundLayer.fillColor = UIColor.white.cgColor
        backgroundLayer.strokeColor = DBYStyle.brown.cgColor
        backgroundLayer.path = path.cgPath
        backgroundLayer.frame = bounds
    }
    @objc func dragVideoView(pan:UIPanGestureRecognizer) {
        let videoView = pan.view
        let position = pan.location(in: superview)
        
        switch pan.state {
        case .changed:
            videoView?.center = position
            break
        case .ended:
            autoAdjustFrame()
            break
        default:
            break
        }
    }
    func autoAdjustFrame() {
        guard let view = superview else {
            return
        }
        let y = view.bounds.midY
        let viewW = view.bounds.width
        let width:CGFloat = 200
        let rect = CGRect(x: viewW - width, y: y, width: width, height: 32)
        
        UIView.animate(withDuration: 0.25) {
            self.frame = rect
        }
    }
    func setProgress(value: Float) {
        if value > 1 || value < 0 {
            return
        }
//        slider.set(value:value)
    }
    override func dismiss() {
        UIView.animate(withDuration: 0.25) {
            self.isHidden = true
        }
    }
}
extension DBYHangUpView: DBYSliderDelegate {
    func valueWillChange(owner: DBYSlider, value: Float) {
        
    }
    
    func valueDidChange(owner: DBYSlider, value: Float) {
        
    }
    
    func valueEndChange(owner: DBYSlider, value: Float) {
        DBYSystemControl.shared.setVolume(value: value)
    }
}
