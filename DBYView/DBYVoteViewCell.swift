//
//  DBYVoteViewCell.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/11.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYVoteViewCellDelegate: NSObjectProtocol {
    func voteViewCell(cell: UITableViewCell, didVotedAt index: Int)
}
class DBYVoteViewCell: UITableViewCell {
    enum State {
        case enable
        case disable
        case selected
    }
    let progressHeight: CGFloat = 20
    var indexPath: IndexPath?
    var voteEnable: Bool = true
    var progress:CGFloat = 0
    var state:State = .enable
    var contenColor:UIColor? = DBYStyle.lightGray
    var borderColor:UIColor? = DBYStyle.lightGray
    
    weak var delegate: DBYVoteViewCellDelegate?
    
    lazy var gradientLayer: CAGradientLayer = CAGradientLayer()
    lazy var backgroundLayer: CAShapeLayer = CAShapeLayer()
    lazy var countLab: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = DBYStyle.darkGray
        l.text = "00:00/00:00"
        return l
    }()
    
    @IBOutlet weak var voteIcon:UIImageView!
    @IBOutlet weak var voteBtn:DBYButton! {
        didSet {
            let radius = voteBtn.bounds.height * 0.5
            voteBtn.setBackgroudnStyle(fillColor: DBYStyle.yellow,
                                       strokeColor: DBYStyle.brown,
                                       radius: radius)
        }
    }
    @IBAction func vote(sender: UIButton) {
        if state != .enable {
            return
        }
        guard let index = indexPath?.row else {
            return
        }
        delegate?.voteViewCell(cell: self, didVotedAt: index)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.fillColor = contenColor?.cgColor
        backgroundLayer.strokeColor = borderColor?.cgColor
        
        let rect = CGRect(x: 12, y: 2,
                          width: bounds.width - 24,
                          height: bounds.height - 4)
        let layerRadius = rect.height * 0.5
        let path = UIBezierPath(roundedRect: rect, cornerRadius: layerRadius)
        backgroundLayer.path = path.cgPath
        
        let radius = voteBtn.bounds.height * 0.5
        if state == .disable {
            voteBtn.setBackgroudnStyle(fillColor: DBYStyle.middleGray,
                                       strokeColor: DBYStyle.brown,
                                       radius: radius)
            voteBtn.setTitleColor(UIColor.white, for: .normal)
        }else {
            voteBtn.setBackgroudnStyle(fillColor: DBYStyle.yellow,
                                       strokeColor: DBYStyle.brown,
                                       radius: radius)
            voteBtn.setTitleColor(DBYStyle.brown, for: .normal)
        }
        let width = bounds.width - 46 - 76 - 8
        let y = (bounds.height - progressHeight) * 0.5
        gradientLayer.frame = CGRect(x: 50,
                                     y: y,
                                     width: width * progress,
                                     height: progressHeight)
        countLab.frame = CGRect(x: gradientLayer.frame.maxX - 68,
                                y: y,
                                width: 60,
                                height: progressHeight)
    }
    
    func setupUI() {
        backgroundColor = UIColor.clear
        
        countLab.font = UIFont.systemFont(ofSize: 14)
        countLab.textColor = UIColor.white
        
        gradientLayer.cornerRadius = progressHeight * 0.5
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
        layer.insertSublayer(backgroundLayer, at: 0)
        
        contentView.addSubview(countLab)
    }
    func showVoteName(iconName: String, voteName: String) {
        voteIcon.image = UIImage(name: iconName)
        voteBtn.setTitle("选择\(voteName)", for: .normal)
    }
    func showProgress(count: Int, colors: [UIColor], totalCount: Int) {
        var cgColors = [CGColor]()
        for color in colors {
            cgColors.append(color.cgColor)
        }
        gradientLayer.colors = cgColors
        
        if totalCount > 0 {
            progress = CGFloat(count) / CGFloat(totalCount)
        }
        if progress < 0.2 {
            progress = 0.2
        }
        
        countLab.text = "\(count)票"
        countLab.textAlignment = .right
    }
}
