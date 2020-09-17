//
//  DBYCommentController.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/17.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

class DBYCommentController: DBYViewController {

    let borderColor = UIColor(red: 213/255.0, green: 213/255.0, blue: 213/255.0, alpha: 1)
    let btnNormalColor = UIColor(red: 204/255.0, green: 206/255.0, blue: 213/255.0, alpha: 1)
    let btnHilightColor = UIColor(red: 0/255.0, green: 130/255.0, blue: 211/255.0, alpha: 1)
    
    var sendTextBlock:((String) -> ())?
    
    @IBOutlet weak var commentViewBottom:NSLayoutConstraint!
    @IBOutlet weak var numberLab: UILabel!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.layer.borderColor = borderColor.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 2
        }
    }
    @IBOutlet weak var cancelBtn: UIButton! {
        didSet {
            cancelBtn.layer.borderColor = borderColor.cgColor
            cancelBtn.layer.borderWidth = 1
            cancelBtn.layer.cornerRadius = cancelBtn.bounds.height * 0.5
        }
    }
    @IBOutlet weak var sendBtn: UIButton! {
        didSet {
            sendBtn.setRoundCorner()
            sendBtn.backgroundColor = btnNormalColor
        }
    }
    
    @IBAction func cancel(sender:UIButton) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func send(sender:UIButton) {
        if textView.text.count > 128 {
            DBYGlobalMessage.shared().showText("字数超过限制")
            return
        }
        if sendTextBlock != nil {
            sendTextBlock!(textView.text)
        }
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        textView.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
        textView.text = nil
        numberLab.text = "0/128"
        NotificationCenter.default.removeObserver(self)
    }
    @objc func keyBoardChange(notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        // 键盘默认高度
        var height: CGFloat = 0
        
        // 判断是否是 边框变化事件
        if notification.name == UIResponder.keyboardWillChangeFrameNotification {
            // 字典中如果保存的是结构体，通常是以 NSValue 的形式保存的
            let rect = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            height = rect.height
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.commentViewBottom.constant = height
                
                self.view.layoutIfNeeded()
            })
        } else {
            self.commentViewBottom.constant = height
        }
    }
}

extension DBYCommentController:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.hasText {
            sendBtn.backgroundColor = btnHilightColor
        }
        if textView.markedTextRange == nil {
            numberLab.text = "\(textView.text.count)/128"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //删除时
        if text == "" {
            return true
        }
        if textView.text.count >= 128 && textView.markedTextRange == nil {
            return false
        }else {
            return true
        }
    }
}
