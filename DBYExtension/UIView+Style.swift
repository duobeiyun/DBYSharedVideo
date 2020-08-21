//
//  UIView+Frame.swift
//  SwiftFrame
//
//  Created by 钟凡 on 2020/7/6.
//  Copyright © 2020 钟凡. All rights reserved.
//

import Foundation

private var portraitFrameKey = "portraitFrameKey";
private var landscapeFrameKey = "landscapeFrameKey";
private var colorsKey = "colorsKey";
private var backgroundColorKey = "backgroundColorKey";

enum UIColorState {
    case light
    case dark
    case portrait
    case landscape
}

extension UIView {
    var portraitFrame:CGRect {
        set (newValue) {
            objc_setAssociatedObject(self, &portraitFrameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let rect = objc_getAssociatedObject(self, &portraitFrameKey) as? CGRect {
                return rect
            }
            return frame
        }
    }
    var landscapeFrame:CGRect {
        set (newValue) {
            objc_setAssociatedObject(self, &landscapeFrameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let rect = objc_getAssociatedObject(self, &landscapeFrameKey) as? CGRect {
                return rect
            }
            return frame
        }
    }
    var colors:[String: UIColor]? {
        set (newValue) {
            objc_setAssociatedObject(self, &colorsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let dict = objc_getAssociatedObject(self, &colorsKey) as? [String : UIColor] {
                return dict
            }
            return [String : UIColor]()
        }
    }
    func setBackgroundColor(color: UIColor, forState state:UIColorState) {
        let key = backgroundColorKey + "\(state)"
        colors?[key] = color
    }
    func backgroundColorforState(state:UIColorState) -> UIColor? {
        let key = backgroundColorKey + "\(state)"
        return colors?[key] ?? backgroundColor
    }
    func updateStyle() {
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .portrait {
            frame = portraitFrame
            backgroundColor = backgroundColorforState(state: .portrait)
        }
        if orientation == .landscapeLeft {
            frame = landscapeFrame
            backgroundColor = backgroundColorforState(state: .landscape)
        }
        if orientation == .landscapeRight {
            frame = landscapeFrame
            backgroundColor = backgroundColorforState(state: .landscape)
        }
    }
}
