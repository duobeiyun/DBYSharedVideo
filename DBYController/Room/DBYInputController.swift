//
//  DBYInputController.swift
//  DBY1VN
//  评论横屏界面
//  Created by 钟凡 on 2018/10/31.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

class DBYInputController: UIViewController {
    
    let borderColor = UIColor(red: 213/255.0, green: 213/255.0, blue: 213/255.0, alpha: 1)
    let btnNormalColor = UIColor(red: 204/255.0, green: 206/255.0, blue: 213/255.0, alpha: 1)
    let btnHilightColor = UIColor(red: 0/255.0, green: 130/255.0, blue: 211/255.0, alpha: 1)
    
    lazy var chatBar = DBYChatBar()
    
    var sendTextBlock:((String) -> ())?
    
    var iphoneXTop: CGFloat = 20
    var iphoneXLeft: CGFloat = 0
    var iphoneXRight: CGFloat = 0
    var iphoneXBottom: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatBar.emojiImageDict = emojiImageDict
        chatBar.delegate = self
        view.addSubview(chatBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupChatBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        dismissChatBar()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissChatBar()
    }
    func dismissChatBar() {
        chatBar.endInput()
        let size = view.bounds.size
        chatBar.frame = CGRect(x: iphoneXLeft,
                               y: size.height - 48 - iphoneXBottom,
                               width: size.width - iphoneXLeft - iphoneXRight,
                               height: 48 + iphoneXBottom)
        dismiss(animated: true, completion: nil)
    }
    func setupChatBar() {
        iphoneXTop = 20
        iphoneXLeft = 0
        iphoneXRight = 0
        iphoneXBottom = 0
        if isIphoneXSeries() {
            let orientation = UIApplication.shared.statusBarOrientation
            if orientation == .landscapeLeft {
                iphoneXRight = 44
            }
            if orientation == .landscapeRight {
                iphoneXLeft = 44
            }
            if orientation == .portrait {
                iphoneXTop = 44
            }
            iphoneXBottom = 34
        }
        let size = view.bounds.size
        chatBar.frame = CGRect(x: iphoneXLeft,
                               y: size.height - 48 - iphoneXBottom,
                               width: size.width - iphoneXLeft - iphoneXRight,
                               height: 48 + iphoneXBottom)
        chatBar.showKeyboad()
    }
}
extension DBYInputController: DBYChatBarDelegate {
    func chatBarDidBecomeActive(owner: DBYChatBar) {
        
    }
    func chatBar(owner: DBYChatBar, selectEmojiAt index: Int) {
        
    }
    func chatBar(owner: DBYChatBar, send message: String) {
        sendTextBlock?(message)
        dismissChatBar()
    }
    func chatBarWillShowInputView(rect: CGRect, duration: TimeInterval) {
        let size = view.bounds.size
        let frame = CGRect(x: iphoneXLeft,
                           y: size.height - rect.height - 48,
                           width: size.width - iphoneXLeft - iphoneXRight,
                           height: 48)
        
        UIView.animate(withDuration: duration, animations: {
            self.chatBar.frame = frame
        })
    }
    
    func chatBarWillDismissInputView(duration: TimeInterval) {
        let size = view.bounds.size
        chatBar.frame = CGRect(x: iphoneXLeft,
                               y: size.height - 48 - iphoneXBottom,
                               width: size.width - iphoneXLeft - iphoneXRight,
                               height: 48 + iphoneXBottom)
    }
}
