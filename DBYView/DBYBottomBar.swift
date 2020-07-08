//
//  DBYBottomBar.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/28.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

public enum DBYBottomBarType:Int {
    case unknow
    case live
    case playback
    case liveLandscape
    case playbackLandscape
}
public enum DBYPlayState {
    case play
    case pause
    case end
}
protocol DBYBottomBarDelegate: NSObjectProtocol {
    func chatButtonClick(owner: DBYBottomBar)
    func voteButtonClick(owner: DBYBottomBar)
    func fullscreenButtonClick(owner: DBYBottomBar)
    func stateDidChange(owner: DBYBottomBar, state: DBYPlayState)
    func progressWillChange(owner: DBYBottomBar, value:Float)
    func progressDidChange(owner: DBYBottomBar, value:Float)
    func progressEndChange(owner: DBYBottomBar, value:Float)
}
class DBYBottomBar: DBYView {
    var currentValue: TimeInterval = 0
    var maxValue: TimeInterval = 0
    var maxValueString: String = "00:00"
    var playState: DBYPlayState = .end
    let btnWidth: CGFloat = 40
    
    lazy var chatBtn:DBYButton = {
        let btn = DBYButton()
        btn.setBackgroudnStyle(fillColor: DBYStyle.halfBlack,
                               strokeColor: UIColor.clear,
                               radius: 15)
        btn.setImage(UIImage(name: "btn-chat"), for: .normal)
        let att = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                   NSAttributedString.Key.foregroundColor: UIColor.white]
        let attStr = NSAttributedString(string: " 讨 论", attributes: att)
        btn.setAttributedTitle(attStr, for: .normal)
        return btn
    }()
    lazy var voteBtn:DBYButton = {
        let btn = DBYButton()
        btn.setBackgroudnStyle(fillColor: DBYStyle.halfBlack,
                               strokeColor: UIColor.clear,
                               radius: 15)
        btn.setImage(UIImage(name: "btn-vote"),
                     for: .normal)
        let att = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                   NSAttributedString.Key.foregroundColor: UIColor.white]
        let attStr = NSAttributedString(string: " 答 题", attributes: att)
        btn.setAttributedTitle(attStr, for: .normal)
        return btn
    }()
    lazy var playBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(name: "btn-play"), for: .normal)
        btn.setImage(UIImage(name: "btn-pause"), for: .selected)
        return btn
    }()
    lazy var fullScreenBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(name: "fullscreen"), for: .normal)
        return btn
    }()
    lazy var slider = DBYSlider()
    lazy var timeLab = UILabel()
    lazy var gradientLayer: CAGradientLayer = CAGradientLayer()
    
    weak var delegate: DBYBottomBarDelegate?
    var barType: DBYBottomBarType = .unknow
    
    override func setupUI() {
        timeLab.textColor = UIColor.white
        timeLab.textAlignment = .right
        timeLab.font = UIFont(name: "Helvetica", size: 10)
        timeLab.text = "00:00/00:00"
        
        let cgColors:[CGColor] = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
            DBYStyle.darkAlpha.cgColor
        ]
        gradientLayer.colors = cgColors
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        slider.delegate = self
        playBtn.addTarget(self,
                          action: #selector(playButtonClick),
                          for: .touchUpInside)
        chatBtn.addTarget(self,
                          action: #selector(chatButtonClick),
                          for: .touchUpInside)
        voteBtn.addTarget(self,
                          action: #selector(voteButtonClick),
                          for: .touchUpInside)
        fullScreenBtn.addTarget(self,
                                action: #selector(fullscreenButtonClick),
                                for: .touchUpInside)
        hiddenVoteButton()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = bounds.size
        var slederFrame:CGRect = .zero
        var timeLabFrame:CGRect = .zero
        
        let timeString = "\(maxValueString)/\(maxValueString)"
        let timeWidth = timeString.width(withMaxHeight: size.height,
                                         font: timeLab.font) + 2
        if barType == .playbackLandscape {
            slederFrame = CGRect(x: 0,
                                 y: 0,
                                 width: size.width,
                                 height: btnWidth)
            timeLabFrame = CGRect(x: btnWidth + 8,
                                  y: size.height - 4 - btnWidth,
                                  width: timeWidth,
                                  height: btnWidth)
        }
        if barType == .playback {
            slederFrame = CGRect(x: btnWidth + 8,
                                 y: size.height - 4 - btnWidth,
                                 width: size.width - 96 - timeWidth,
                                 height: btnWidth)
            timeLabFrame = CGRect(x: slederFrame.maxX,
                                  y: size.height - 4 - btnWidth,
                                  width: timeWidth,
                                  height: btnWidth)
        }
        gradientLayer.frame = bounds
        playBtn.frame = CGRect(x: 8,
                               y: size.height - 4 - btnWidth,
                               width: btnWidth,
                               height: btnWidth)
        chatBtn.frame = CGRect(x: size.width - 12 - 60,
                                y: size.height - 12 - 30,
                                width: 60,
                                height: 30)
        voteBtn.frame = chatBtn.frame.offsetBy(dx: -68, dy: 0)
        fullScreenBtn.frame = CGRect(x: size.width - 8 - btnWidth,
                                     y: size.height - 4 - btnWidth,
                                     width: btnWidth,
                                     height: btnWidth)
        timeLab.frame = timeLabFrame
        slider.frame = slederFrame
    }
    @objc func playButtonClick() {
        playBtn.isSelected = !playBtn.isSelected
        delegate?.stateDidChange(owner: self, state: playState)
    }
    @objc func chatButtonClick() {
        delegate?.chatButtonClick(owner: self)
    }
    @objc func voteButtonClick() {
        delegate?.voteButtonClick(owner: self)
    }
    @objc func fullscreenButtonClick() {
        delegate?.fullscreenButtonClick(owner: self)
    }
    func showVoteButton() {
        voteBtn.isHidden = false
    }
    func hiddenVoteButton() {
        voteBtn.isHidden = true
    }
    func set(state: DBYPlayState) {
        playState = state
        if state == .play {
            playBtn.isSelected = true
        }
        if state == .pause {
            playBtn.isSelected = false
        }
        if state == .end {
            playBtn.isSelected = false
        }
    }
    func set(totalTime: TimeInterval) {
        maxValue = totalTime
        
        slider.maxValue = Float(maxValue)
        slider.minValue = 0
        
        maxValueString = String.playTime(time:Int(totalTime))
        set(time: 0)
        setNeedsLayout()
        layoutIfNeeded()
    }
    func set(time: TimeInterval) {
        if time < 0 {
            currentValue = 0
        }else if time > maxValue {
            currentValue = maxValue
        }else {
            currentValue = time
        }
        slider.set(value: Float(currentValue))
        let timeValue = String.playTime(time:Int(currentValue))
        timeLab.text = timeValue + "/" + maxValueString
    }
    func set(type: DBYBottomBarType) {
        barType = type
        
        playBtn.removeFromSuperview()
        chatBtn.removeFromSuperview()
        voteBtn.removeFromSuperview()
        fullScreenBtn.removeFromSuperview()
        slider.removeFromSuperview()
        
        switch type {
        case .live:
            addSubview(playBtn)
            addSubview(fullScreenBtn)
        case .playback:
            addSubview(playBtn)
            addSubview(slider)
            addSubview(timeLab)
            addSubview(fullScreenBtn)
        case .liveLandscape:
            addSubview(playBtn)
            addSubview(voteBtn)
            addSubview(chatBtn)
        case .playbackLandscape:
            addSubview(playBtn)
            addSubview(timeLab)
            addSubview(slider)
            addSubview(chatBtn)
        case .unknow:
            break
        }
    }
}
extension DBYBottomBar: DBYSliderDelegate {
    func valueWillChange(owner: DBYSlider, value: Float) {
        delegate?.progressWillChange(owner: self, value: value)
    }
    
    func valueDidChange(owner: DBYSlider, value: Float) {
        delegate?.progressDidChange(owner: self, value: value)
    }
    
    func valueEndChange(owner: DBYSlider, value: Float) {
        delegate?.progressEndChange(owner: self, value: value)
    }
}
