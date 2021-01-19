//
//  DBYChatBar.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/6.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYChatBarDelegate: NSObjectProtocol {
    func chatBarDidClickEmojiButton(owner: DBYChatBar)
    func chatBarDidClickTextButton(owner: DBYChatBar)
    func chatBarDidClickInteractiveButton(owner: DBYChatBar)
}
class DBYChatBar: DBYNibView {
    lazy var roundLayer:CAShapeLayer = CAShapeLayer()

    weak var delegate:DBYChatBarDelegate?
    
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var interactiveButton: UIButton!
    
    @IBAction func emojiButtonClick(_ sender: UIButton) {
        delegate?.chatBarDidClickEmojiButton(owner: self)
    }
    
    @IBAction func textButtonClick(_ sender: UIButton) {
        delegate?.chatBarDidClickTextButton(owner: self)
    }
    
    @IBAction func interactiveButtonClick(_ sender: UIButton) {
        delegate?.chatBarDidClickInteractiveButton(owner: self)
    }
    
    override func setupUI() {
        roundLayer.fillColor = UIColor.clear.cgColor
        roundLayer.strokeColor = DBYStyle.middleGray.cgColor
        roundLayer.lineWidth = 0.5
        layer.addSublayer(roundLayer)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let roundHeight:CGFloat = 40
        let roundWidth:CGFloat = bounds.width - 64
        let rect = CGRect(x: 8,
                          y: 4,
                          width: roundWidth,
                          height: roundHeight)
        let roundPath = UIBezierPath(roundedRect: rect,
                                     cornerRadius: 2)
        
        roundLayer.path = roundPath.cgPath
    }
    func setText(_ text: String) {
        textButton.setTitle(text, for: .normal)
    }
    func appendText(_ text: String) {
        let title = textButton.title(for: .normal) ?? ""
        textButton.setTitle(title + text, for: .normal)
    }
}

