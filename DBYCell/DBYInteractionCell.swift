//
//  DBYInteractionCell.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/5/20.
//

import UIKit
import DBYSDK_dylib

class DBYInteractionCell: UITableViewCell {
    @IBOutlet weak var iconView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var actionButton:UIButton!
    
    var type:DBYInteractionType = .audio
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setModel(_ model: DBYInteractionModel) {
        if model.state == .inqueue {
            actionButton.setTitle("申请中", for: .normal)
            actionButton.setImage(UIImage(name: "camera-request-icon"), for: .normal)
        }else if type == .audio {
            actionButton.setTitle("上麦中", for: .normal)
            actionButton.setImage(UIImage(name: "mic-small"), for: .normal)
        }else if type == .video {
            actionButton.setTitle("上台中", for: .normal)
            actionButton.setImage(UIImage(name: "camera-small"), for: .normal)
        }
        
        nameLabel.text = model.userName
    }
}
