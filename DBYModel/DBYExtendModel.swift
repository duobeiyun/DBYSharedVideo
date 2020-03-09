//
//  DBYExtendModel.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/1/4.
//  Copyright © 2020 钟凡. All rights reserved.
//

import UIKit

enum DBYExtendType {
    case unknow
    case diy
    case qa
}
class DBYExtendModel: NSObject {
    var title:String?
    var content:String?
    var type:DBYExtendType = .unknow
}
