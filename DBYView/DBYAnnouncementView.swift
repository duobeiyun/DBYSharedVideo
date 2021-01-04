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
    weak var timer: ZFTimer?
    var isExpend:Bool = false
    
    @IBAction func tap(gesture: UITapGestureRecognizer) {
        isExpend = !isExpend
        guard let text = messageLab.text else {
            return
        }
        let width = text.width(withMaxHeight: constHeight, font: messageLab.font)
        let maxWidth = bounds.width - constLeft
        if width < maxWidth {
            return
        }
        if isExpend {
            let height = text.height(withMaxWidth: maxWidth, font: messageLab.font)
            messgaeLabWidth.constant = maxWidth
            messgaeLabLeft.constant = minLeft
            frame.size.height = height + 16
            timer?.stop()
        }else {
            messgaeLabWidth.constant = width
            frame.size.height = constHeight
            set(text: text)
        }
    }
    override func setupUI() {
        layer.shadowOpacity = 1
        layer.shadowColor = DBYStyle.middleGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    deinit {
        timer?.stop()
    }
    func set(text:String) {
        self.messageLab.text = text
        let width = messageLab.text!.width(withMaxHeight: constHeight, font: messageLab.font)
        messgaeLabWidth.constant = width
        messgaeLabLeft.constant = minLeft
        if isExpend {
            return
        }
        let maxWidth = bounds.width - constLeft
        let delta = width - maxWidth
        if delta <= 0 {
            return
        }
        timer?.stop()
        timer = ZFTimer.startTimer(interval: 0.1, repeats: true, block: {[weak self] in
            self?.updateMessage(delta: delta)
        })
    }
    @objc func updateMessage(delta:CGFloat) {
        var x = messgaeLabLeft.constant - 1
        if x < -delta {
            x = minLeft
        }
        messgaeLabLeft.constant = x
        layoutIfNeeded()
    }
}
extension DBYAnnouncementView: UIScrollViewDelegate {
    
}
