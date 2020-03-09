//
//  DBYRoomConfig.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/12/6.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

class DBYRoomConfig: NSObject {
    var merchantId: String?
    var courseId: String?
    var roomId: String?
    
    var visitor: [String: Any]?
    var nickname: [String: Any]?
    var avatar: String?
    var badge: [String: Any]?
    var watermark: DBYWatermark?
    var marquee: DBYMarquee?
    var extends: [DBYExtendModel]?
    var sensitiveWords: String?
    var studentVideo: [String: Any]?
    
    init(with dict: [String: Any]) {
        super.init()
        merchantId = dict["merchantId"] as? String
        courseId = dict["courseId"] as? String
        roomId = dict["roomId"] as? String
        visitor = dict["visitor"] as? [String: Any]
        nickname = dict["nickname"] as? [String: Any]
        avatar = dict["avatar"] as? String
        badge = dict["badge"] as? [String: Any]
        studentVideo = dict["studentVideo"] as? [String: Any]
        
        if let value = dict["watermark"] as? [String: Any] {
            watermark = DBYWatermark(with: value)
        }
        if let value = dict["marquee"] as? [String: Any] {
            marquee = DBYMarquee(with: value)
        }
        if let extend = dict["extend"] as? [String: Any] {
            extends = [DBYExtendModel]()
            guard let fixed = extend["fixed"] as? [String: Any] else {
                return
            }
            if let qa = fixed["qa"] as? [String: Any] {
                let model = DBYExtendModel()
                model.title = qa["title"] as? String
                model.type = .qa
                extends?.append(model)
            }
            
            guard let diy = extend["diy"] as? [[String: Any]] else {
                return
            }
            for diyDict in diy {
                let model = DBYExtendModel()
                model.title = diyDict["title"] as? String
                model.content = diyDict["content"] as? String
                model.type = .diy
                extends?.append(model)
            }
        }
        sensitiveWords = dict["sensitiveWords"] as? String
    }
}
