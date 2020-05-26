//
//  DBYProgressView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/13.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

class DBYProgressView: DBYNibView {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var progressTraceView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressHeight: NSLayoutConstraint!
    
    var progress: CGFloat = 0
    var timer: Timer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutIfNeeded()
        let height = iconView.frame.minY - 12
        progressHeight.constant = height * progress
        contentView?.layer.cornerRadius = bounds.width * 0.5
        progressTraceView.layer.cornerRadius = 4
        progressView.layer.cornerRadius = 4
    }
    override func setupUI() {
        super.setupUI()
        backgroundColor = UIColor.clear
    }
    func setIcon(icon: String) {
        iconView.image = UIImage(name: icon)
    }
    func setProgress(value: CGFloat) {
        if value > 1 {
            progress = 1
        }else if value < 0 {
            progress = 0
        }else {
            progress = value
        }
        layoutIfNeeded()
        let maxHeight = iconView.frame.minY - 12
        let height = maxHeight * progress
        progressHeight.constant = height
        stopHiddenTimer()
        startHiddenTimer()
    }
    func startHiddenTimer() {
        self.isHidden = false
        let date:Date = Date(timeIntervalSinceNow: 5)
        timer = Timer(fireAt: date,
                      interval: 0,
                      target: self,
                      selector: #selector(hidden),
                      userInfo: nil,
                      repeats: false)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
    }
    func stopHiddenTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func hidden() {
        UIView.animate(withDuration: 0.25) {
            self.isHidden = true
        }
        stopHiddenTimer()
    }
}
