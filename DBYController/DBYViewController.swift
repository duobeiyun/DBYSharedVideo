//
//  DBYViewController.swift
//  DBY1VNUI
//
//  Created by 钟凡 on 2018/12/19.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

public class DBYViewController: UIViewController {
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
