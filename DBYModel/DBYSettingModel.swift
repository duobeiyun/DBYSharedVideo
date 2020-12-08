//
//  DBYSettingModel.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/12/8.
//

import Foundation

struct DBYSettingItem {
    var name: String?
    var defaultIcon: String?
    var selectedIcon: String?
}
class DBYSettingModel<T> where T:UICollectionViewCell {
    var name: String?
    var resueId: String
    var itemSize: CGSize
    var items: [DBYSettingItem]?
    var selectedIndex: Int = 0
    
    init() {
        itemSize = CGSize(width: 44, height: 44)
        self.resueId = "\(T.self)"
    }
}
