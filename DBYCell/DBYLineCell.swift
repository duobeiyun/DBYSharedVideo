//
//  DBYLineCell.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/12/23.
//

import UIKit

class DBYLineCell: UITableViewCell {
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.layer.cornerRadius = 6
            label.layer.masksToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        label.backgroundColor = selected ? DBYStyle.yellow:UIColor.white
    }
    
}
