//
//  DBYMarquee.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/12/31.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

class DBYMarquee: NSObject {
    var disabled: Bool = false
    var fontSize: Int = 10
    var color: String?
    var fontBackground: String?
    var transparent: Int = 100
    ///px/s
    var speed: Int = 10
    ///min
    var interval: Int = 10
    var content: String?
    var regionMin: Int = 0
    var regionMax: Int = 100
    
    init(with dict: [String: Any]) {
        super.init()
        
        disabled = dict["disabled"] as? Bool ?? false
        fontSize = dict["fontSize"] as? Int ?? 10
        color = dict["color"] as? String
        fontBackground = dict["fontBackground"] as? String
        transparent = dict["transparent"] as? Int ?? 100
        speed = dict["speed"] as? Int ?? 10
        interval = dict["interval"] as? Int ?? 10
        content = dict["content"] as? String
        regionMin = dict["regionMin"] as? Int ?? 0
        regionMax = dict["regionMax"] as? Int ?? 100
    }
}
