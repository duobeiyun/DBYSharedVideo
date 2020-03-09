//
//  DBYGlobalMessage.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/11/12.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

public class DBYGlobalMessage:NSObject {
    static fileprivate let manager = DBYGlobalMessage()
    @objc public static func shared() -> DBYGlobalMessage {
        return manager
    }
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    lazy var messageView:DBYGlobalMessageView = {
        
        return DBYGlobalMessageView()
    }()
    @objc func rotated() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        messageView.center = CGPoint(x: width * 0.5, y: height * 0.5)
    }
    @objc public func showText(_ text:String) {
        if messageView.superview != nil || text.count == 0 {
            return
        }
        if text.count > 0 {
            let width = UIScreen.main.bounds.size.width
            let height = UIScreen.main.bounds.size.height
            
            let size = text.boundingRect(with: CGSize(width: width - 32, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], context: nil).size
            let messageViewW = size.width + 20
            messageView.frame = CGRect(x: (width - messageViewW) * 0.5 , y: (height - size.height) * 0.5, width: messageViewW, height: size.height + 16)
            let window = UIApplication.shared.keyWindow
            DispatchQueue.main.async {
                window?.addSubview(self.messageView)
                self.messageView.showText(text)
            }
        }
    }
}
class DBYGlobalMessageView: UIView, CAAnimationDelegate {
    lazy var textLab:UILabel = {
        let lab = UILabel()
        lab.backgroundColor = UIColor.clear
        lab.textAlignment = NSTextAlignment.center
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = UIColor.white
        lab.numberOfLines = 0
        
        return lab
    }()
    lazy var opacityAnimation: CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.delegate = self
        animation.values = [0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 0]
        animation.duration = 1.0
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        return animation
    }()
    
    func showText(_ text: String) {
        textLab.text = text
        textLab.frame = self.bounds
        
        layer.add(opacityAnimation, forKey: "opacityAnimation")
    }
    func animationDidStart(_ anim: CAAnimation) {
        self.isHidden = false
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.isHidden = true
        self.removeFromSuperview()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height * 0.5
        layer.masksToBounds = true
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(textLab)
        backgroundColor = DBYStyle.halfBlack
        isUserInteractionEnabled = false
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
