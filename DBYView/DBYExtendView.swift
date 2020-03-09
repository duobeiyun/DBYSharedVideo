//
//  DBYExtendView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/1/4.
//  Copyright © 2020 钟凡. All rights reserved.
//

import UIKit

class DBYExtendView: DBYView {
    lazy var label:UILabel = UILabel()
    override func setupUI() {
        addSubview(label)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    func set(content: String?) {
        let webview = UIWebView()
        webview.loadHTMLString(content ?? "", baseURL: nil)
        label.text = content
    }
}
