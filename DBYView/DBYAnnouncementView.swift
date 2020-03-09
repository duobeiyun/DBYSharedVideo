//
//  DBYAnnouncementView.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/11/1.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

class DBYAnnouncementView: DBYNibView {
    @IBOutlet weak var messageLab:UILabel!
    @IBOutlet weak var messgaeLabLeft: NSLayoutConstraint!
    @IBOutlet weak var messgaeLabWidth: NSLayoutConstraint!
    
    let minLeft:CGFloat = 8
    let constHeight:CGFloat = 40
    let constLeft:CGFloat = 36
    var timer: Timer?
    var isExpend:Bool = false
    
    @IBAction func tap(gesture: UITapGestureRecognizer) {
        isExpend = !isExpend
        if messageLab.text == nil {
            return
        }
        let width = messageLab.text!.width(withMaxHeight: constHeight, font: messageLab.font)
        let maxWidth = bounds.width - constLeft
        if width < maxWidth {
            return
        }
        if isExpend {
            let height = messageLab.text!.height(withMaxWidth: maxWidth, font: messageLab.font)
            messgaeLabWidth.constant = maxWidth
            messgaeLabLeft.constant = minLeft
            frame.size.height = height + 16
        }else {
            messgaeLabWidth.constant = width
            frame.size.height = constHeight
        }
    }
    override func setupUI() {
        layer.shadowOpacity = 1
        layer.shadowColor = DBYStyle.middleGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    func set(text:String) {
        self.messageLab.text = text
        let width = messageLab.text!.width(withMaxHeight: constHeight, font: messageLab.font)
        messgaeLabWidth.constant = width
        
        stopTimer()
        startTimer()
    }
    func startTimer() {
        let date:Date = Date(timeIntervalSinceNow: 0)
        timer = Timer(fireAt: date,
                      interval: 0.1,
                      target: self,
                      selector: #selector(updateMessage),
                      userInfo: nil,
                      repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
    }
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    @objc func updateMessage() {
        if isExpend {
            return
        }
        let maxWidth = bounds.width - constLeft
        guard let width = messageLab.text?.width(withMaxHeight: maxWidth, font: messageLab.font) else {
            return
        }
        let delta = width - maxWidth
        if delta <= 0 {
            return
        }
        var x = messgaeLabLeft.constant - 1
        if x < -delta {
            x = minLeft
        }
        messgaeLabLeft.constant = x
        layoutIfNeeded()
    }
    @objc func dismiss() {
        let dy = self.frame.height
        UIView.animate(withDuration: 0.25) {
            self.frame = self.frame.offsetBy(dx: 0, dy: -dy)
            self.isHidden = true
        }
    }
}
extension DBYAnnouncementView: UIScrollViewDelegate {
    
}
