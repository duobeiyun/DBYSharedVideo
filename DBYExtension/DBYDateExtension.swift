//
//  DBYDataExtension.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/30.
//  Copyright © 2018 钟凡. All rights reserved.
//

import Foundation

extension Date {
    ///hh:mm:ss
    func shortString() -> String {
        let dfmt = DateFormatter()
        dfmt.dateFormat = "HH:mm:ss";
        
        let str = dfmt.string(from: self)
        return str
    }
    ///yyyy.mm.dd hh:mm:ss
    func longString() -> String {
        let dfmt = DateFormatter()
        dfmt.dateFormat = "yyyy.MM.dd HH:mm:ss";
        let str = dfmt.string(from: self)
        return str
    }
}
