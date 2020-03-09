//
//  DBYControlbar.swift
//  DBYSDKExample
//
//  Created by 钟凡 on 2018/9/29.
//  Copyright © 2018 duobei. All rights reserved.
//

import UIKit

@objc public enum DBYPlayState:Int {
    case play
    case pause
    case end
}
@objc protocol DBYControlbarDelegate: NSObjectProtocol {
    func progressDidChange(owner: DBYControlbar, value: Int)
    func progressEndChange(owner: DBYControlbar, value: Int)
    func stateDidChange(owner: DBYControlbar, state: DBYPlayState)
    func playRateDidChange(owner: DBYControlbar, playRate: Float)
}
class DBYControlbar: DBYNibView {
    override public func layoutSubviews() {
        super.layoutSubviews()
        contentView!.frame = bounds
        layer.cornerRadius = bounds.size.height * 0.5
        layer.masksToBounds = true
    }
    
    //MARK: - 实现代码
    
    var modCount:Int = 0
    var currentValue:Int = 0
    var minValue:Int = 0
    var maxValue:Int = 0
    var playRate:Float = 1.0
    var playState:DBYPlayState = .end
    
    @objc public weak var delegate:DBYControlbarDelegate?
    
    @IBOutlet weak var currentTimeLab: UILabel!
    @IBOutlet weak var progressSlider: DBYSlider! {
        didSet {
            progressSlider.delegate = self
        }
    }
    @IBOutlet weak var endTimeLab: UILabel!
    @IBOutlet weak var switchBtn: UIButton!
    @IBOutlet weak var playRateBtn: UIButton!
    
    @IBAction func switchStatus(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            delegate?.stateDidChange(owner: self, state: .play)
        }else {
            delegate?.stateDidChange(owner: self, state: .pause)
        }
    }
    @IBAction func changePlayRate(_ sender: UIButton) {
        delegate?.playRateDidChange(owner: self, playRate: playRate)
    }
    @objc public func setPlayState(_ state:DBYPlayState) {
        playState = state
        switchBtn.isSelected = state == .play
        if state == .end {
            playRate = 1
            playRateBtn.setTitle("\(playRate)X", for: .normal)
        }
    }
    @objc public func setTime(value:Int) {
        if value < minValue {
            currentValue = minValue
        }else if value > maxValue {
            currentValue = maxValue
        }else {
            currentValue = value
        }
        let timeValue = String.playTime(time:currentValue)
        currentTimeLab.text = timeValue
        progressSlider.set(value:Float(currentValue))
    }
    @objc public func setTimeRange(minValue:Int, maxValue:Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        progressSlider.maxValue = Float(maxValue)
        progressSlider.minValue = Float(minValue)
        
        let totalValue = String.playTime(time:maxValue)
        endTimeLab.text = totalValue
    }
}
extension DBYControlbar: DBYSliderDelegate {
    func valueDidChange(owner: DBYSlider, value: Float) {
        delegate?.progressDidChange(owner: self, value: Int(value))
    }
    
    func valueEndChange(owner: DBYSlider, value: Float) {
        currentValue = Int(value)
        delegate?.progressEndChange(owner: self, value: Int(value))
    }
}
