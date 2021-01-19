//
//  DBYInputController.swift
//  DBY1VN
//  评论横屏界面
//  Created by 钟凡 on 2018/10/31.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

class DBYInputController: DBYNibViewController {
    enum ShowType {
        case emoji
        case text
    }
    let borderColor = UIColor(red: 213/255.0, green: 213/255.0, blue: 213/255.0, alpha: 1)
    let btnNormalColor = UIColor(red: 204/255.0, green: 206/255.0, blue: 213/255.0, alpha: 1)
    let btnHilightColor = UIColor(red: 0/255.0, green: 130/255.0, blue: 211/255.0, alpha: 1)
    let emojiViewHeight: CGFloat = 200
    let emojiViewH_H: CGFloat = 120
    
    var sendTextBlock:((String) -> ())?
    var textChangeBlock:((String?) -> ())?
    var showType: ShowType = .text
    
    lazy var emojiView: DBYEmojiView = {
        let v = DBYEmojiView()
        v.delegate = self
        v.backgroundColor = UIColor.white
        v.emojis = emojis
        return v
    }()
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    
    @IBAction func emojiButtonClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            textField.inputView = emojiView
        } else {
            textField.inputView = nil
        }
        emojiView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: emojiViewHeight)
        textField.resignFirstResponder()
        textField.becomeFirstResponder()
    }
    @IBAction func sendButtonClick(sender: UIButton) {
        sendText()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emojiButton.isSelected = showType != .text
        if emojiButton.isSelected {
            textField.inputView = emojiView
        } else {
            textField.inputView = nil
        }
        emojiView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: emojiViewHeight)
        textField.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardChange),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardChange),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        textField.textChangeBlock = textChangeBlock
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    @objc func keyBoardChange(notification: NSNotification) {
        // 判断是否是 边框变化事件
        if notification.name == UIResponder.keyboardWillShowNotification {
            // 从 userInfo 字典中，取出键盘高度
            // 字典中如果保存的是结构体，通常是以 NSValue 的形式保存的
            let rect = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            UIView.animate(withDuration: 0.2) {
                self.bottomViewBottom.constant = rect.height
                self.view.layoutIfNeeded()
            }
        }
    }
    func sendText() {
        guard let text = textField.text else {
            return
        }
        sendTextBlock?(text)
        textField.text = ""
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
extension DBYInputController: DBYEmojiViewDelegate {
    func emojiView(emojiView: DBYEmojiView, didSelectedAt index: Int) {
        let imageName = emojis[index]
        if let emojiName = emojiImageDict[imageName] {
            textField.text = textField.text?.appending(emojiName)
        }
    }
}
extension DBYInputController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendText()
        return true
    }
}
