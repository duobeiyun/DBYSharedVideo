//
//  ZFTimer.swift
//  TimerLeak
//
//  Created by 钟凡 on 2020/7/8.
//  Copyright © 2020 钟凡. All rights reserved.
//

import Foundation

class ZFTimer {
    var timer:Timer?
    var block:(()->())?
    
    class func startTimer(interval:TimeInterval, repeats:Bool, block: @escaping ()->()) -> ZFTimer {
        let obs = ZFTimer()
        let timer = Timer.scheduledTimer(timeInterval: interval, target: obs, selector: #selector(ZFTimer.timerClock), userInfo: block, repeats: repeats)
        obs.timer = timer
        obs.block = block
        return obs
    }
    @objc func timerClock() {
        block?()
    }
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
