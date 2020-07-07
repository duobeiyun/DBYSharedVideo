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
    func tapGesture(owner:DBYMainView, isSelected: Bool)
}

class DBYMainView: DBYView {
    weak var delegate:DBYMainViewDelegate?
    weak var bottomBarDelegate:DBYBottomBarDelegate? {
        didSet {
            bottomBar.delegate = bottomBarDelegate
        }
    }
    weak var topBarDelegate:DBYTopBarDelegate? {
        didSet {
            topBar.delegate = topBarDelegate
        }
    }
    
    lazy var topBar:DBYTopBar = DBYTopBar()
    lazy var bottomBar:DBYBottomBar = DBYBottomBar()
    lazy var videoView = DBYVideoView()
    lazy var volumeProgressView = DBYProgressView()
    lazy var brightnessProgressView = DBYProgressView()
    
    var beganPosition:CGPoint = .zero
    var brightness:CGFloat = 0
    var volume:Float = 0
    var controlBarIsHidden: Bool = false
    
    var voiceTimer: Timer?
    
    override func setupUI() {
        addSubview(videoView)
        addSubview(topBar)
        addSubview(bottomBar)
        addSubview(volumeProgressView)
        addSubview(brightnessProgressView)
        
        volumeProgressView.setIcon(icon: "volume")
        brightnessProgressView.setIcon(icon: "brightness")
        
        volumeProgressView.isHidden = true
        brightnessProgressView.isHidden = true
        
        videoView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        topBar.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(80)
        }
        bottomBar.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(0)
            make.height.equalTo(80)
        }
        volumeProgressView.snp.makeConstraints { (make) in
            make.bottom.right.equalTo(-10)
            make.top.equalTo(10)
            make.width.equalTo(20)
        }
        brightnessProgressView.snp.makeConstraints { (make) in
            make.bottom.equalTo(-10)
            make.left.top.equalTo(10)
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
        delegate?.tapGesture(owner: self, isSelected: controlBarIsHidden)
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
    func startHiddenTimer() {
        let date:Date = Date(timeIntervalSinceNow: 5)
        voiceTimer = Timer(fireAt: date,
                           interval: 0,
                           target: self,
                           selector: #selector(hiddenControlBar),
                           userInfo: nil,
                           repeats: false)
        RunLoop.current.add(voiceTimer!, forMode: RunLoop.Mode.default)
    }
    func stopHiddenTimer() {
        voiceTimer?.invalidate()
        voiceTimer = nil
    }
    @objc func hiddenControlBar() {
        topBar.isHidden = true
        bottomBar.isHidden = true
        controlBarIsHidden = true
        delegate?.willHiddenControlBar(owner: self)
        stopHiddenTimer()
    }
    
    @objc func showControlBar() {
        topBar.isHidden = false
        bottomBar.isHidden = false
        controlBarIsHidden = false
        delegate?.willShowControlBar(owner: self)
        stopHiddenTimer()
        startHiddenTimer()
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
