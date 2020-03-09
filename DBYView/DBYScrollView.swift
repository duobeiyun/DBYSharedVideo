//
//  DBYScrollView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/21.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

class DBYScrollView: UIScrollView {
    lazy var childViews = [UIView]()
    
    override var frame: CGRect {
        didSet {
            if frame.width <= 0 {
                return
            }
            for (i, view) in childViews.enumerated() {
                let dx = CGFloat(i) * frame.width
                view.frame = CGRect(x: dx,
                                    y: 0,
                                    width: frame.width,
                                    height: frame.height)
            }
            let contentWidth = frame.width * CGFloat(childViews.count)
            contentSize = CGSize(width: contentWidth, height: frame.height)
            let offset = frame.width * (contentOffset.x / frame.width).rounded()
            contentOffset.x = offset
        }
    }
    func append(view: UIView) {
        if childViews.contains(view) {
            return
        }
        let x = bounds.width * CGFloat(childViews.count)
        view.frame = CGRect(x: x,
                            y: 0,
                            width: bounds.width,
                            height: bounds.height)
        childViews.append(view)
        addSubview(view)
        let contentWidth = bounds.width * CGFloat(childViews.count)
        contentSize = CGSize(width: contentWidth, height: bounds.height)
        scrollAtLast()
    }
    func removeLast() {
        let view = childViews.removeLast()
        view.removeFromSuperview()
        let contentWidth = bounds.width * CGFloat(childViews.count)
        contentSize = CGSize(width: contentWidth, height: bounds.height)
    }
    func set(views: [UIView]) {
        for view in childViews {
            view.removeFromSuperview()
        }
        for (i, view) in views.enumerated() {
            let dx = CGFloat(i) * bounds.width
            view.frame = CGRect(x: dx,
                                y: 0,
                                width: bounds.width,
                                height: bounds.height)
            addSubview(view)
        }
        childViews = views
        let contentWidth = bounds.width * CGFloat(childViews.count)
        contentSize = CGSize(width: contentWidth, height: bounds.height)
    }
    func scroll(at index: Int) {
        if index >= childViews.count {
            return
        }
        let dx = CGFloat(index) * bounds.width
        setContentOffset(CGPoint(x: dx , y: 0), animated: false)
    }
    func scrollAtLast() {
        let count = childViews.count - 1
        scroll(at: count)
    }
}
