//
//  UIViewExtension.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/4/21.
//

import Foundation

@objc enum DBYViewTheme:Int {
    case light
    case dark
}

extension UIView {
    private struct AssociatedKeys {
        static var theme = "theme"
    }
    var theme: DBYViewTheme? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.theme) as? DBYViewTheme
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.theme, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    @objc func setTheme(_ theme:DBYViewTheme) {
        self.theme = theme
    }
    ///after seconds
    func dismiss(after: Int) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(after)) {
            self.removeFromSuperview()
        }
    }
    func dismiss(animation: Bool) {
        if !animation {
            self.removeFromSuperview()
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0;
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
}
