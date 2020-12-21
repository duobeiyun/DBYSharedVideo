//
//  DBYMessageCell.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/12/18.
//

import UIKit

class DBYMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var labelWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func setupUI() {
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        messageLabel.layer.cornerRadius = 15
        messageLabel.layer.masksToBounds = true
        let width = messageLabel.text!.width(withMaxHeight: 30, font: messageLabel.font) + 32
        labelWidth.constant = width
    }
    
}
