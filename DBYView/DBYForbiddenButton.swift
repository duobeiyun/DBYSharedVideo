//
//  DBYForbiddenButton.swift
//  DBYSDK_dylib
//
//  Created by 钟凡 on 2020/8/28.
//

import UIKit

class DBYForbiddenButton: UIView, ZFNibLoader {
    static func loadNibView() -> Self? {
        return portraitView()
    }
    
    static let bundle = Bundle(for: DBYForbiddenButton.self)
    public static func landscapeView() -> Self? {
        let views = loadViewsFromNib(name: "DBYForbiddenButton", bundle:bundle)
        let tipView = views?[0] as? Self
        
        return tipView
    }
    public static func portraitView() -> Self? {
        let views = loadViewsFromNib(name: "DBYForbiddenButton", bundle:bundle)
        let tipView = views?[1] as? Self
        
        return tipView
    }
}
