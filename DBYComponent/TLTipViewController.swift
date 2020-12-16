//
//  TLTipViewController.swift
//  TakeALesson
//
//  Created by 钟凡 on 2020/9/16.
//  Copyright © 2020 钟凡. All rights reserved.
//

import UIKit
import SDWebImage

class TLTipViewController: UIViewController {
    private static let shared = TLTipViewController()
    
    @IBOutlet weak var contentView: UIView! {
        didSet {
            contentView.setRoundCorner(radius: 4)
        }
    }
    @IBOutlet weak var iconView: SDAnimatedImageView!
    @IBOutlet weak var messageLab: UILabel!
    
    public convenience init() {
        let cla = Self.self
        self.init(nibName: "\(cla)", bundle: Bundle(for: cla))
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }
    
    private static func show(image: UIImage?, message: String?) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(shared.view)
        shared.view.frame = window.bounds
        shared.iconView.image = image
        shared.messageLab.text = message
    }
    /// after in seconds
    static func dismiss(after: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + after) {
            shared.view.removeFromSuperview()
        }
    }
    static func dismiss() {
        shared.view.removeFromSuperview()
    }
}
extension TLTipViewController {
    ///should dismiss mannul
    static func showLoading(message: String?) {
        show(image: UIImage(named: "icon_loading"), message: message)
    }
    ///auto dismiss after 1s
    static func showError(message: String?) {
        show(image: UIImage(named: "icon_error"), message: message)
        dismiss(after: 1)
    }
    ///auto dismiss after 1s
    static func showFault(message: String?) {
        show(image: UIImage(named: "icon_fault"), message: message)
        dismiss(after: 1)
    }
    ///auto dismiss after 1s
    static func showInfo(message: String?) {
        show(image: UIImage(named: "icon_info"), message: message)
        dismiss(after: 1)
    }
}
