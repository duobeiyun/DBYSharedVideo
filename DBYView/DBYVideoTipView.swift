//
//  DBYVideoTipView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/29.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYVideoTipViewDelegate1:NSObjectProtocol {
    func buttonClick(owner: DBYVideoTipView1, type: DBYTipType)
}
public enum DBYTipType:Int {
    case pause
    case audio
    case unknow
}
class DBYVideoTipView1: DBYNibView {
    weak var delegate: DBYVideoTipViewDelegate1?
    var tipType:DBYTipType = .unknow
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playBtn: DBYButton! {
        didSet {
            let radius = playBtn.bounds.height * 0.5
            playBtn.setBackgroudnStyle(fillColor: DBYStyle.yellow,
                                       strokeColor: DBYStyle.brown,
                                       radius: radius)
        }
    }
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
        label.text = title
        //iconView.image = UIImage(name: icon)
    }
}
