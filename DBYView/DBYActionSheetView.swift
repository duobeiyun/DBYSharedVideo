//
//  DBYActionSheetView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/20.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit


protocol DBYActionSheetViewDelegate: NSObjectProtocol {
    func actionSheetViewConfirm(view: DBYActionSheetView)
    func actionSheetViewCancel(view: DBYActionSheetView)
}
@IBDesignable
class DBYActionButton: UIButton {
    typealias BtnAction = (UIButton)->()
    
    var action: BtnAction?
    
    @IBInspectable var styleValue: Int = 0 {
        didSet {
            if styleValue == 0 {
                style = .confirm
            }else {
                style = .cancel
            }
            setup()
        }
    }
    public enum Style: Int {
        case small
        case confirm
        case cancel
    }
    var style: Style = .confirm
    
    convenience init(style: Style) {
        self.init(type: .custom)
        self.style = style
        setup()
    }
    override func awakeFromNib() {
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    private func setup() {
        addTarget(self, action: #selector(touchUpInSideBtnAction), for: .touchUpInside)
        titleLabel?.font = DBYStyle.font14
        
        if style == .small {
            backgroundColor = UIColor.white
        }
        if style == .confirm {
            backgroundColor = UIColor.white
        }
        if style == .cancel {
            backgroundColor = DBYStyle.yellow
            setTitleColor(UIColor.white, for: .normal)
        }
        setTitleColor(DBYStyle.brown, for: .normal)
        layer.borderColor = DBYStyle.brown.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
    }
    @objc func touchUpInSideBtnAction() {
        action?(self)
    }
}
class DBYActionSheetView: DBYView {
    let largeMargin:CGFloat = 24
    let smallMargin:CGFloat = 12
    let containerW:CGFloat = 200
    var containerH:CGFloat = 170
    let btnHeight:CGFloat = 30
    
    var buttons:[DBYActionButton]?
    
    var container: UIView!
    var background: UIImageView!
    var titleLab: UILabel!
    var messageLab: UILabel!
    
    override func setupUI() {
        backgroundColor = DBYStyle.halfBlack
        
        background = UIImageView()
        
        container = UIView()
        container.backgroundColor = UIColor.white
        container.layer.cornerRadius = 12
        container.layer.shadowOpacity = 1
        container.layer.shadowColor = DBYStyle.brown.cgColor
        container.layer.shadowOffset = CGSize(width: 4, height: 4)
        
        titleLab = UILabel()
        messageLab = UILabel()
        
        titleLab.textAlignment = .center
        messageLab.textAlignment = .center
        
        messageLab.numberOfLines = 0
        
        titleLab.font = DBYStyle.font14
        messageLab.font = DBYStyle.font14
        
        addSubview(container)
        container.addSubview(background)
        container.addSubview(titleLab)
        container.addSubview(messageLab)
    }
    override func layoutSubviews() {
        container.bounds.size = CGSize(width: containerW, height: containerH)
        container.center = center
        background.frame = container.bounds
        
        let maxW = containerW - smallMargin * 2
        titleLab.frame = CGRect(x: smallMargin, y: smallMargin, width: maxW, height: btnHeight)
        let message = messageLab.text ?? ""
        let messageH = message.height(withMaxWidth: maxW, font: DBYStyle.font14)
        messageLab.frame = CGRect(x: smallMargin, y: smallMargin * 2 + btnHeight, width: maxW, height: messageH)
    }
    public func setBackground(image: UIImage?) {
        background.image = image
    }
    public func show(title: String, message: String, actions:[DBYActionButton]) {
        titleLab.text = title
        messageLab.text = message
        if let arr = buttons {
            for button in arr {
                button.removeFromSuperview()
            }
        }
        buttons = actions
        let count = actions.count
        
        let maxW = containerW - smallMargin * 2
        let messageH = message.height(withMaxWidth: maxW, font: DBYStyle.font14)
        
        var btnY = 54 + messageH + smallMargin
        for i in 0..<count {
            var btnWidth = containerW - smallMargin * 2
            let button = actions[i]
            if button.style == .small {
                btnWidth = btnWidth * 0.5
            }
            let offsetX = (containerW - btnWidth) * 0.5
            
            button.frame = CGRect(x: offsetX, y: btnY, width: btnWidth, height: btnHeight)
            container.addSubview(button)
            
            btnY += smallMargin + btnHeight
        }
        containerH = btnY > 170 ? btnY:170
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        frame = window?.bounds ?? .zero
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func dismiss() {
        removeFromSuperview()
    }
}
