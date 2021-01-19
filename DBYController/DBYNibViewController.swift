//
//  DBYNibViewController.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2021/1/18.
//

import UIKit

class DBYNibViewController: UIViewController {
    @objc public init() {
        let bundle = Bundle(for: DBYViewController.self)
        super.init(nibName: String(describing: type(of:self)), bundle:bundle)
    }
    @objc public init(nibName: String?) {
        let bundle = Bundle(for: DBYViewController.self)
        super.init(nibName:nibName, bundle:bundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
