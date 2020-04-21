//
//  DBYChatBar.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/6.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYChatBarDelegate: NSObjectProtocol {
    func chatBarDidBecomeActive(owner: DBYChatBar)
    func chatBar(owner: DBYChatBar, selectEmojiAt index: Int)
    func chatBar(owner: DBYChatBar, send message: String)
    func chatBarWillShowInputView(rect: CGRect, duration: TimeInterval)
    func chatBarWillDismissInputView(duration: TimeInterval)
}
class DBYChatBar: DBYNibView {
    let animationDuration:TimeInterval = 0.25
    
    lazy var roundLayer:CAShapeLayer = CAShapeLayer()
    lazy var emojiImageDict = [String:String]()
    lazy var emojis = [String]()

    let emojiViewH_V: CGFloat = 200
    let emojiViewH_H: CGFloat = 120
    
    var emojiView:DBYEmojiView?
    weak var delegate:DBYChatBarDelegate?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var emojiBtn: UIButton!
    
    @IBAction func showEmoji(_ sender: UIButton) {
        showEmojiView()
    }
    
    @IBAction func send(_ sender: UIButton) {
        if textField.hasText {
            delegate?.chatBar(owner: self, send: textField.text!)
            textField.text = nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func setupUI() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardChange),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardChange),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        roundLayer.fillColor = UIColor.clear.cgColor
        roundLayer.strokeColor = DBYStyle.middleGray.cgColor
        roundLayer.lineWidth = 0.5
        layer.addSublayer(roundLayer)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let roundHeight:CGFloat = 40
        let roundWidth:CGFloat = bounds.width - 16
        let rect = CGRect(x: 8,
                          y: 4,
                          width: roundWidth,
                          height: roundHeight)
        let roundPath = UIBezierPath(roundedRect: rect,
                                     cornerRadius: 2)
        
        roundLayer.path = roundPath.cgPath
    }
    @objc func keyBoardChange(notification: NSNotification) {
        // 在 swift 中，数值可以直接从字典中提取
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        // 判断是否是 边框变化事件
        if notification.name == UIResponder.keyboardWillShowNotification {
            // 从 userInfo 字典中，取出键盘高度
            // 字典中如果保存的是结构体，通常是以 NSValue 的形式保存的
            let rect = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            delegate?.chatBarWillShowInputView(rect: rect, duration: duration)
        }
    }
    func append(text: String) {
        textField.text = textField.text?.appending(text)
    }
    func endInput() {
        hiddenEmojiView()
        hiddenKeyboad()
    }
    func showKeyboad() {
        hiddenEmojiView()
        textField.becomeFirstResponder()
    }
    private func hiddenKeyboad() {
        textField.resignFirstResponder()
        delegate?.chatBarWillDismissInputView(duration: animationDuration)
    }
    func showEmojiView() {
        hiddenKeyboad()
        
        emojiBtn.isSelected = true
        emojis.removeAll()
        for (_, value) in emojiNameDict {
            emojis.append(value)
        }
        textField.endEditing(true)
        emojiView = DBYEmojiView()
        emojiView?.delegate = self
        emojiView?.backgroundColor = UIColor.white
        emojiView?.emojis = emojis
        
        let emojiViewH = isLandscape() ? emojiViewH_H:emojiViewH_V
        
        let window = UIApplication.shared.keyWindow
        let windowH = window?.bounds.height ?? 0
        let windowW = window?.bounds.width ?? 0
        let rect = CGRect(x: 0,
                          y: windowH - emojiViewH,
                          width: windowW,
                          height: emojiViewH)
        if let kv = emojiView {
            window?.addSubview(kv)
        }
        emojiView?.frame = rect.offsetBy(dx: 0, dy: emojiViewH)
        UIView.animate(withDuration: animationDuration) {
            self.emojiView?.frame = rect
        }
        delegate?.chatBarWillShowInputView(rect: rect, duration: animationDuration)
    }
    private func hiddenEmojiView() {
        emojiBtn.isSelected = false
        
        let emojiViewH = isLandscape() ? emojiViewH_H:emojiViewH_V
        let rect = emojiView?.frame.offsetBy(dx: 0, dy: emojiViewH) ?? .zero
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.emojiView?.frame = rect
        }) { (result) in
            self.emojiView?.removeFromSuperview()
        }
        delegate?.chatBarWillDismissInputView(duration: animationDuration)
    }
}
extension DBYChatBar: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hiddenEmojiView()
        delegate?.chatBarDidBecomeActive(owner: self)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        emojiView?.removeFromSuperview()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.hasText {
            delegate?.chatBar(owner: self, send: textField.text!)
            textField.text = nil
        }
        return true;
    }
}
extension DBYChatBar: DBYEmojiViewDelegate {
    func emojiView(emojiView: DBYEmojiView, didSelectedAt index: Int) {
        let imageName = emojis[index]
        if let emojiName = emojiImageDict[imageName] {
            textField.text = textField.text?.appending(emojiName)
        }
        delegate?.chatBar(owner: self, selectEmojiAt: index)
    }
}
