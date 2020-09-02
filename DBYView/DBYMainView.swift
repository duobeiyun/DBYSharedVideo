//
//  DBYMainView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/7/6.
//

import UIKit

protocol DBYMainViewDelegate: NSObjectProtocol {
    func volumeChange(owner:DBYMainView, volume: CGFloat)
    func lightnessChange(owner:DBYMainView, volume: CGFloat)
    func willHiddenControlBar(owner:DBYMainView)
    func willShowControlBar(owner:DBYMainView)
}

class DBYMainView: DBYView {
    weak var delegate:DBYMainViewDelegate?
    
    lazy var videoView = DBYVideoView()
    lazy var volumeProgressView = DBYProgressView()
    lazy var brightnessProgressView = DBYProgressView()
    
    var beganPosition:CGPoint = .zero
    var brightness:CGFloat = 0
    var volume:Float = 0
    var controlBarIsHidden: Bool = false
    
    weak var voiceTimer: ZFTimer?
    
    override func setupUI() {
        addSubview(videoView)
        addSubview(volumeProgressView)
        addSubview(brightnessProgressView)
        
        volumeProgressView.setIcon(icon: "volume")
        brightnessProgressView.setIcon(icon: "brightness")
        
        volumeProgressView.isHidden = true
        brightnessProgressView.isHidden = true
        
        videoView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        volumeProgressView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp_centerY)
            make.right.equalTo(-10)
            make.height.equalTo(150)
            make.width.equalTo(20)
        }
        brightnessProgressView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp_centerY)
            make.left.equalTo(10)
            make.height.equalTo(150)
            make.width.equalTo(20)
        }
        let oneTap = UITapGestureRecognizer(target: self,
                                            action: #selector(oneTap(tap:)))
        addGestureRecognizer(oneTap)
        
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(gestureControl(pan:)))
        addGestureRecognizer(pan)
    }
    @objc func oneTap(tap:UITapGestureRecognizer) {
        if controlBarIsHidden {
            showControlBar()
        }else {
            hiddenControlBar()
        }
    }
    @objc func gestureControl(pan:UIPanGestureRecognizer) {
        switch pan.state {
            case .began:
                beganPosition = pan.location(in: self)
                brightness = DBYSystemControl.shared.getBrightness()
                volume = DBYSystemControl.shared.getVolume()
            case .changed:
                let position = pan.location(in: self)
                let offsetY = beganPosition.y - position.y
                let offsetX = beganPosition.x - position.x
                if abs(offsetX) > abs(offsetY) {
                    return
                }
                let progress = offsetY / bounds.height
                if position.x > bounds.width * 0.5 {
                    changeVolume(value: progress)
                }else {
                    changeLight(value: progress)
                }
            default:
                break
        }
    }
    func showVideoTipView(type: DBYTipType, delegate: DBYVideoTipViewDelegate?) {
        guard let pauseTipView = DBYPauseTipView.loadNibView() else {
            return
        }
        
        pauseTipView.tag = tag + 1
        pauseTipView.frame = bounds
        pauseTipView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(pauseTipView)
    }
    func hiddenVideoTipView() {
        viewWithTag(tag + 1)?.removeFromSuperview()
    }
    func showNetworkTipView(delegate: DBYNetworkTipViewDelegate?) {
        guard let networkView = DBYNetworkTipView.loadNibView() else {
            return
        }
        networkView.delegate = delegate
        networkView.tag = tag + 2
        networkView.frame = bounds
        networkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(networkView)
    }
    func hiddenNetworkTipView() {
        viewWithTag(tag + 2)?.removeFromSuperview()
    }
    func showLoadingView(delegate: DBYLoadingTipViewDelegate?) {
        guard let loadingView = DBYLoadingTipView.loadNibView() else {
            return
        }
        loadingView.delegate = delegate
        loadingView.tag = tag + 3
        loadingView.frame = bounds
        loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(loadingView)
    }
    func hiddenLoadingView() {
        viewWithTag(tag + 3)?.removeFromSuperview()
    }
    func startTimer() {
        voiceTimer = ZFTimer.startTimer(interval: 5, repeats: false, block: {[weak self] in
            self?.hiddenControlBar()
        })
    }
    func stopTimer() {
        voiceTimer?.stopTimer()
    }
    @objc func hiddenControlBar() {
        controlBarIsHidden = true
        delegate?.willHiddenControlBar(owner: self)
        stopTimer()
    }
    
    @objc func showControlBar() {
        controlBarIsHidden = false
        delegate?.willShowControlBar(owner: self)
        stopTimer()
        startTimer()
    }
    func changeVolume(value: CGFloat) {
        DBYSystemControl.shared.setVolume(value: volume + Float(value))
        volumeProgressView.setProgress(value: CGFloat(volume) + value)
    }
    func changeLight(value: CGFloat) {
        DBYSystemControl.shared.setBrightness(value: brightness + value)
        brightnessProgressView.setProgress(value: brightness + value)
    }
}
