//
//  DBYInteractionModel.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/5/22.
//

import Foundation

class DBYInteractionModell:NSObject {
    enum State:String {
        case inqueue = "inqueue"
        case join = "join"
    }
    var userId:String?
    var state:State?
    var info:String?
    
    init(with dict: [String: Any]) {
        super.init()
        
        userId = dict["userId"] as? String
        if let value = dict["state"] as? String {
            state = State(rawValue: value)
        }
        info = dict["info"] as? String
    }
}
