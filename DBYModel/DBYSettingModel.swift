//
//  DBYSettingModel.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/12/8.
//

import Foundation

class DBYSettingItem {
    var name: String?
    var defaultIcon: String?
    var selectedIcon: String?
    var selectedIndex: Int = -1
    
    init(name: String? = nil, defaultIcon: String? = nil, selectedIcon: String? = nil) {
        self.name = name
        self.defaultIcon = defaultIcon
        self.selectedIcon = selectedIcon
    }
}
class DBYSettingModel {
    enum SeletType {
        case single
        case multiple
    }
    var name: String?
    var resueId: String = "DBYSettingCell"
    var itemSize: CGSize
    lazy var items: [DBYSettingItem] = [DBYSettingItem]()
    var selectedIndex: Int = -1
    var selectType: SeletType = .single
    
    init() {
        itemSize = CGSize(width: 44, height: 44)
    }
}
