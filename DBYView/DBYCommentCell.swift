//
//  DBYCommentCell.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/15.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit
import SDWebImage

protocol DBYCommentCellDelegate: NSObjectProtocol {
    func commentCell(cell: UITableViewCell, didPressWith index: IndexPath)
}
class DBYCommentCell: UITableViewCell {
    @IBOutlet weak var badgeWidth: NSLayoutConstraint!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var avatarView: UIImageView! {
        didSet {
            avatarView.layer.cornerRadius = avatarView.bounds.height * 0.5
        }
    }
    @IBOutlet weak var bubbleView: UIImageView!
    @IBOutlet weak var badgeView: UIImageView!
    @IBOutlet weak var messageLab: UILabel!
    
    var indexPath: IndexPath?
    weak var delegate: DBYCommentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = 1
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(longPress)
    }
    
    func setText(name:String?,
                 message:NSAttributedString?,
                 avatarUrl: String?,
                 badge: (String?, String?)) {
        messageLab.attributedText = message
        nameLab.text = name
        
        let (imageUrl, imageName) = badge
        let image1 = UIImage(name: "avatar")
        let url1 = URL(string: avatarUrl ?? "")
        avatarView.sd_setImage(with: url1, placeholderImage: image1)
        
        if imageUrl == nil || imageName == nil {
            badgeWidth.constant = 0
            return
        }
        badgeWidth.constant = 48
        let image2 = UIImage(name: imageName!)
        let url2 = URL(string: imageUrl!)
        badgeView.sd_setImage(with: url2, placeholderImage: image2)
    }
    func setBubbleImage(_ image: UIImage?){
        bubbleView.image = image
    }
    func setTextColor(_ color: UIColor) {
        messageLab.textColor = color
    }
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began {
            return
        }
        if let index = indexPath {
            delegate?.commentCell(cell: self, didPressWith: index)
        }
    }
}
