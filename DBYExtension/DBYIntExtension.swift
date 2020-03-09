//
//  DBYIntExtension.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/31.
//  Copyright © 2018 钟凡. All rights reserved.
//

import Foundation

extension Int {
    func tenThousandUnit() -> String {
        if self > 10000 {
            return String(format: "%.2f", (Float(self) / 10000))
        }else {
            return self.description
        }
    }
}
