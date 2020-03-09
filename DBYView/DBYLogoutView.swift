//
//  DBYLogoutView.swift
//  DBY1VNUI
//
//  Created by 钟凡 on 2018/12/26.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

protocol DBYLogoutViewDelegate: NSObjectProtocol {
    func enterRoom(_ owner:DBYLogoutView)
    func exitRoom(_ owner:DBYLogoutView)
}
class DBYLogoutView: DBYNibView {
    weak var delegate:DBYLogoutViewDelegate?
    @IBOutlet weak var alertView:UIView!{
        didSet {
            alertView.layer.cornerRadius = 2
        }
    }
    @IBOutlet weak var retryBtn: UIButton! {
        didSet {
            retryBtn.layer.borderColor = DBYStyle.lightGray.cgColor
            retryBtn.layer.borderWidth = 1
            retryBtn.layer.cornerRadius = retryBtn.bounds.height * 0.5
        }
    }
    @IBOutlet weak var exitBtn: UIButton! {
        didSet {
            exitBtn.layer.cornerRadius = exitBtn.bounds.height * 0.5
        }
    }
    
    @IBAction func enterRoom() {
        hidden()
        delegate?.enterRoom(self)
    }
    @IBAction func exitRoom() {
        hidden()
        delegate?.exitRoom(self)
    }
    public func show() {
        if let dummyView = alertView.snapshotView(afterScreenUpdates: true) {
            dummyView.center = alertView.center
            dummyView.bounds.size = .zero
            superview?.addSubview(dummyView)
            
            UIView.animate(withDuration: 0.25, animations: {
                dummyView.frame = self.alertView.frame
            }) { (result) in
                self.isHidden = false
                dummyView.removeFromSuperview()
            }
        }
    }
    public func hidden() {
        if let dummyView = alertView.snapshotView(afterScreenUpdates: true) {
            dummyView.frame = alertView.frame
            superview?.addSubview(dummyView)
            self.isHidden = true
            
            UIView.animate(withDuration: 0.25, animations: {
                dummyView.center = self.alertView.center
                dummyView.bounds.size = .zero
            }) { (result) in
                dummyView.removeFromSuperview()
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
