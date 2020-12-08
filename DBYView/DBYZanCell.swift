//
//  DBYZanCell.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/3/19.
//

import UIKit

class DBYZanCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    func set(text: String?) {
        titleLabel.text = text
        titleLabel.sizeToFit()
        layoutIfNeeded()
    }
    
}
