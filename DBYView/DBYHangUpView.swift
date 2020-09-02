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
            let radius = hangUpBtn.bounds.height * 0.5
            hangUpBtn.setBackgroudnStyle(fillColor: DBYStyle.yellow,
                                         strokeColor: DBYStyle.brown,
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
            adjustViewFrame()
            break
        default:
            break
        }
    }
    func adjustViewFrame() {
        guard let view = superview else {
            return
        }
        let viewW = view.bounds.width
        var rect = frame
        rect.origin.x = viewW - rect.width
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
