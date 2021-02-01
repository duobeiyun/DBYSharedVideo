//
//  DBYStudentVideoView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/3/17.
//

import UIKit
import SnapKit

class DBYStudentVideoView: DBYView {
    var userId: String?
    var scale:CGFloat = 1
    
    var nameLabel: UILabel!
    var voiceIcon: UIImageView!
    var video: DBYVideoView!
    
    override func setupUI() {
        super.setupUI()
        nameLabel = UILabel()
        voiceIcon = UIImageView()
        video = DBYVideoView()
        
        voiceIcon.contentMode = .center
        nameLabel.textColor = DBYStyle.brown
        video.backgroundColor = UIColor.white
        voiceIcon.image = UIImage(name: "voice-value")
        
        addSubview(nameLabel)
        addSubview(voiceIcon)
        addSubview(video)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let videoW = bounds.width
        let videoH = videoW * 0.75
        video.frame = CGRect(x: 0, y: 0, width: videoW, height: videoH)
        nameLabel.frame = CGRect(x: 6, y: video.frame.maxY, width: bounds.width - 46, height: 20)
        voiceIcon.frame = CGRect(x: bounds.width - 44, y: bounds.height - 22, width: 40, height: 20)
    }
    func setUserName(name: String?) {
        nameLabel.text = name
    }
}
