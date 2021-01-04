//
//  DBYMicListView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/26.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYMicListViewDelegate: NSObjectProtocol {
    func micListView(owner: DBYMicListView, showMicList:Bool)
}

class DBYMicListView: DBYNibView {
    lazy var cornerLayer = CAShapeLayer()
    lazy var names = [String]()
    var showMicList = true
    weak var delegate:DBYMicListViewDelegate?
    var messageLabWidth: CGFloat = 0
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageLab: UILabel!
    @IBAction func tap(sender: UITapGestureRecognizer) {
        showMicList = !showMicList
        if showMicList {
            updateTipMessage()
        }else {
            let nameString = "学生发言中"
            messageLabWidth = nameString.width(withMaxHeight: 30,
                                               font: UIFont.systemFont(ofSize: 12))
            messageLab.text = nameString
        }
        delegate?.micListView(owner: self, showMicList: showMicList)
    }
    
    override func setupUI() {
        layer.insertSublayer(cornerLayer, at: 0)
        let drag = UIPanGestureRecognizer(target: self,
        action: #selector(dragVideoView(pan:)))
        addGestureRecognizer(drag)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = bounds.height * 0.5
        let radii = CGSize(width: radius, height: radius)
        let corners:UIRectCorner = [.topLeft, .bottomLeft]
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: radii)
        cornerLayer.fillColor = UIColor.white.cgColor
        cornerLayer.strokeColor = UIColor.white.cgColor
        cornerLayer.path = path.cgPath
        layer.insertSublayer(cornerLayer, at: 0)
    }
    @objc func dragVideoView(pan:UIPanGestureRecognizer) {
        let videoView = pan.view
        let position = pan.location(in: superview)
        
        switch pan.state {
        case .changed:
            videoView?.center = position
            break
        case .ended:
            adjustFrame()
            break
        default:
            break
        }
    }
    func adjustFrame() {
        guard let sv = superview else {
            return
        }
        let y = frame.origin.y
        
        let viewW = sv.bounds.width
        let width = frame.width
        let rect = CGRect(x: viewW - width, y: y, width: width, height: 32)
        UIView.animate(withDuration: 0.25) {
            self.frame = rect
        }
    }
    func autoAdjustFrame() {
        guard let sv = superview else {
            return
        }
        let y = sv.bounds.midY - 40
        let viewW = sv.bounds.width
        
        let width = getMessageWidth() + 50
        let rect = CGRect(x: viewW - width, y: y, width: width, height: 32)
        UIView.animate(withDuration: 0.25) {
            self.frame = rect
        }
    }
    func append(name: String) {
        names.append(name)
        updateTipMessage()
        autoAdjustFrame()
    }
    func remove(name: String) {
        if let index = names.firstIndex(of: name) {
            names.remove(at: index)
        }
        updateTipMessage()
        autoAdjustFrame()
    }
    func updateTipMessage() {
        if names.count <= 0 {
            isHidden = true
        }else {
            isHidden = false
        }
        let nameString = names.joined(separator: ",")
        messageLabWidth = nameString.width(withMaxHeight: 30,
                                           font: UIFont.systemFont(ofSize: 12))
        messageLab.text = nameString
    }
    func showTipMessage() {
        
    }
    func getMessageWidth() -> CGFloat {
        return messageLabWidth
    }
}
