//
//  DBYWatermark.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/12/31.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

enum DBYWatermarkPosition:String {
    case top_left = "TOP_LEFT"
    case top_right = "TOP_RIGHT"
    case bottom_left = "DOWN_LEFT"
    case bottom_right = "DOWN_RIGHT"
}
enum DBYWatermarkType:String {
    case text = "TEXT"
    case image = "IMAGE"
}
class DBYWatermark: NSObject {
    var disabled: Bool = false
    var type: DBYWatermarkType = .text
    var text: String?
    var image: String?
    var position: DBYWatermarkPosition = .top_left
    
    init(with dict: [String: Any]) {
        super.init()
        
        disabled = dict["disabled"] as? Bool ?? false
        text = dict["text"] as? String
        if let value = dict["type"] as? String {
            type = DBYWatermarkType.init(rawValue: value) ?? .text
        }
        image = dict["image"] as? String
        if let value = dict["position"] as? String {
            position = DBYWatermarkPosition.init(rawValue: value) ?? .top_left
        }
    }
}
