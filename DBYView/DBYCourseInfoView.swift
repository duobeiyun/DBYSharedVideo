//
//  DBYCourseInfoView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/12.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

class DBYCourseInfoView: DBYNibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var userCountbutton: UIButton!
    @IBOutlet weak var thumbCountbutton: UIButton!
    
    func set(title: String?) {
        titleLabel.text = title
    }
    func setTeacherName(name: String) {
        teacherLabel.text = "主讲教师：" + name
    }
    func setUserCount(count: Int) {
        userCountbutton.setTitle("\(count)", for: .normal)
    }
    func setThumbCount(count: Int) {
        thumbCountbutton.setTitle("\(count)", for: .normal)
    }
}
