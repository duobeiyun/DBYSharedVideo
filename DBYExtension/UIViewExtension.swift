//
//  UIViewExtension.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/4/21.
//

import Foundation

private var portraitFrameKey = "portraitFrameKey";
private var landscapeFrameKey = "landscapeFrameKey";
private var colorsKey = "colorsKey";
private var backgroundColorKey = "backgroundColorKey";
private var textColorKey = "textColorKey";
private var isHiddenKey = "isHiddenKey";

private var animationsKey = "animationsKey";

public enum UIColorState {
    case light
    case dark
    case portrait
    case landscape
}
public protocol ZFViewAutoDismissable {
    func dismiss()
    func dismiss(after: Int, animation: Bool)
}
public protocol ZFViewStyleable {
    func setBackgroundColor(color: UIColor, forState state:UIColorState)
    func backgroundColorforState(state:UIColorState) -> UIColor?
    func updateStyle()
}
protocol ZFNibLoader {
    static func loadViewsFromNib(name: String, bundle:Bundle) -> [UIView]?
}
extension ZFNibLoader {
    static func loadViewsFromNib(name: String, bundle:Bundle) -> [UIView]? {
        let nib = UINib(nibName: name, bundle: bundle)
        let views = nib.instantiate(withOwner: nil, options: nil) as? [UIView]
        return views
    }
}
extension UIView:ZFViewStyleable {
    public var portraitFrame:CGRect {
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
    public var landscapeFrame:CGRect {
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
    var colors:[String: UIColor] {
        set (newValue) {
            objc_setAssociatedObject(self, &colorsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let dict = objc_getAssociatedObject(self, &colorsKey) as? [String : UIColor]
            return dict ?? [String: UIColor]()
        }
    }
    public func setBackgroundColor(color: UIColor, forState state:UIColorState) {
        let key = backgroundColorKey + "\(state)"
        colors[key] = color
    }
    public func backgroundColorforState(state:UIColorState) -> UIColor? {
        let key = backgroundColorKey + "\(state)"
        return colors[key] ?? backgroundColor
    }
    public func setTextColor(color: UIColor, forState state:UIColorState) {
        let key = textColorKey + "\(state)"
        colors[key] = color
    }
    public func textColorforState(state:UIColorState) -> UIColor? {
        let key = textColorKey + "\(state)"
        return colors[key] ?? backgroundColor
    }
    
    @objc public func updateStyle() {
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
extension UIView: ZFViewAutoDismissable {
    var animations: (() -> ())? {
        get {
            return objc_getAssociatedObject(self, &animationsKey) as? (() -> ())
        }
        set {
            objc_setAssociatedObject(self, &animationsKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    @objc public func dismiss() {
        self.removeFromSuperView(animation: false)
    }
    public func dismiss(after: Int, animation: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(after)) {
            self.removeFromSuperView(animation: animation)
        }
    }
    func removeFromSuperView(animation: Bool) {
        if !animation {
            self.removeFromSuperview()
            return
        }
        UIView.animate(withDuration: 0.25, animations: animations ?? { self.alpha = 0 }) { (finished) in
            self.removeFromSuperview()
        }
    }
}
extension CGRect {
    func resizeBy(sub_w: CGFloat, sub_h: CGFloat) -> CGRect {
        return CGRect(x: minX, y: minY, width: width - sub_w, height: height - sub_h)
    }
}
public extension DispatchQueue {
    private static var _onceTracker = [String]()
    class func once(file: String = #file, function: String = #function, line: Int = #line, block:()->Void) {
        let token = file + ":" + function + ":" + String(line)
        once(token: token, block: block)
    }
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}
