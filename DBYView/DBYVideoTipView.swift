//
//  DBYVideoTipView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/29.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYVideoTipViewDelegate:NSObjectProtocol {
    func buttonClick(owner: DBYVideoTipView, type: DBYTipType)
}
public enum DBYTipType:Int {
    case pause
    case audio
    case unknow
}
class DBYVideoTipView: DBYNibView {
    weak var delegate: DBYVideoTipViewDelegate?
    var tipType:DBYTipType = .unknow
    
    @IBOutlet weak var playBtn: DBYButton! {
        didSet {
            let radius = playBtn.bounds.height * 0.5
            playBtn.setBackgroudnStyle(fillColor: DBYStyle.dark,
                                       strokeColor: DBYStyle.yellow,
                                       radius: radius)
        }
    }
    @IBOutlet weak var messageLab: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func click(sender: UIButton) {
        delegate?.buttonClick(owner: self, type: tipType)
    }
    func set(type: DBYTipType) {
        tipType = type
        if type == .pause {
            set(title: "点击播放", message: "已暂停播放", icon: "video-tip")
        }
        if type == .audio {
            set(title: "返回视频", message: "音频播放", icon: "audio-tip")
        }
    }
    func set(title:String, message:String, icon:String) {
        messageLab.text = message
        playBtn.setTitle(title, for: .normal)
        imageView.image = UIImage(name: icon)
    }
}
