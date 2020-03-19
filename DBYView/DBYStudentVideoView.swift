//
//  DBYStudentVideoView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/3/17.
//

import UIKit

class DBYStudentVideoView: DBYNibView {
    var userId: String?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var voiceIcon: UIImageView!
    @IBOutlet weak var video: DBYVideoView!

    func setUserName(name: String?) {
        nameLabel.text = name
    }
}
