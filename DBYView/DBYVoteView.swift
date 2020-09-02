//
//  DBYVoteView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/8.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYVoteViewDelegate: NSObjectProtocol {
    func voteView(voteView: DBYVoteView, didVotedAt index: Int)
}
class DBYBoxLabel: UILabel {
    lazy var margin:UIEdgeInsets = UIEdgeInsets()
    convenience init(margin: UIEdgeInsets) {
        self.init(frame:.zero)
        self.margin = margin
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: margin))
    }
}
class DBYVoteView: DBYView {
    let icons: [String] = [
        "icon-a",
        "icon-b",
        "icon-c",
        "icon-d",
        "icon-e",
        "icon-f"
    ]
    lazy var gradientColors:[[UIColor]] = [
        [UIColor(rgb: 0xffb867), UIColor(rgb: 0xff758c)],
        [UIColor(rgb: 0xfdde74), UIColor(rgb: 0xffb867)],
        [UIColor(rgb: 0x30ffb8), UIColor(rgb: 0x11db7a)],
        [UIColor(rgb: 0x8affff), UIColor(rgb: 0x63e4e4)],
        [UIColor(rgb: 0x81d5fa), UIColor(rgb: 0x3977f6)],
        [UIColor(rgb: 0x6f9efa), UIColor(rgb: 0xb37feb)]
    ]
    let cellIdentifier: String = "DBYVoteViewCell"
    let estimatedRowHeight: CGFloat = 44
    
    var totalCount:Int = 0
    var selectedIndex: Int = -1
    
    weak var delegate: DBYVoteViewDelegate?
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.separatorStyle = .none
        t.allowsSelection = false
        let classType = type(of: self)
        
        let nib = UINib(nibName: cellIdentifier, bundle: currentBundle)
        t.backgroundColor = DBYStyle.lightGray
        t.register(nib, forCellReuseIdentifier: cellIdentifier)
        t.estimatedRowHeight = estimatedRowHeight
        return t
    }()
    lazy var tipLab: DBYBoxLabel = {
        let l = DBYBoxLabel(margin: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = DBYStyle.darkGray
        l.text = "正在答题中"
        return l
    }()
    lazy var dataSource: [String] = [String]()
    lazy var countDict: [Int: Int] = [Int: Int]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = DBYStyle.lightGray
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = DBYStyle.lightGray
        if #available(iOS 11.0, *) {
            tableView.insetsContentViewsToSafeArea = false
        }
        addSubview(tableView)
        addSubview(tipLab)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func setupUI() {
        tipLab.setTextColor(color:DBYStyle.lightGray, forState: .landscape)
        tipLab.setTextColor(color:DBYStyle.darkGray, forState: .portrait)
        
        tipLab.setBackgroundColor(color:DBYStyle.lightAlpha, forState: .landscape)
        tipLab.setBackgroundColor(color:DBYStyle.lightGray, forState: .portrait)
        
        self.setBackgroundColor(color:DBYStyle.lightAlpha, forState: .landscape)
        self.setBackgroundColor(color:DBYStyle.lightGray, forState: .portrait)
        
        tableView.setBackgroundColor(color:DBYStyle.lightAlpha, forState: .landscape)
        tableView.setBackgroundColor(color:DBYStyle.lightGray, forState: .portrait)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        tipLab.frame = CGRect(x: 0,
                              y: 0,
                              width: bounds.width,
                              height: 40)
        tableView.frame = CGRect(x: 0,
                                 y: 40,
                                 width: bounds.width,
                                 height: bounds.height - 20)
    }
    func setVotes(votes: [String]) {
        countDict.removeAll()
        selectedIndex = -1
        dataSource = votes
        tableView.reloadData()
    }
    func setVote(index: Int, count: Int) {
        if let value = countDict[index] {
            countDict[index] = value + count
        }else {
            countDict[index] = count
        }
        totalCount = 0
        for (_, value) in countDict {
            totalCount += value
        }
        tableView.reloadData()
    }
}
extension DBYVoteView: UITableViewDelegate {
    
}
extension DBYVoteView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? DBYVoteViewCell else {
            return DBYVoteViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        let voteName = dataSource[indexPath.row]
        let iconName = icons[indexPath.row]
        let count = countDict[indexPath.row] ?? 0
        let colors = gradientColors[indexPath.row]
        cell.contenColor = tableView.backgroundColor
        if isLandscape() {
            cell.borderColor = DBYStyle.middleGray
        }else {
            cell.borderColor = UIColor.clear
        }
        cell.showVoteName(iconName: iconName, voteName: voteName)
        cell.showProgress(count: count, colors: colors, totalCount: totalCount)
        cell.indexPath = indexPath
        cell.delegate = self
        if selectedIndex == -1 {
            cell.state = .enable
        }else if selectedIndex == indexPath.row {
            cell.state = .selected
        }else {
            cell.state = .disable
        }
        return cell
    }
}
extension DBYVoteView: DBYVoteViewCellDelegate {
    func voteViewCell(cell: UITableViewCell, didVotedAt index: Int) {
        if selectedIndex > 0 {
            return
        }
        delegate?.voteView(voteView: self, didVotedAt: index)
        selectedIndex = index
        let voteName = dataSource[index]
        tipLab.text = "你选择了“\(voteName)”, 请等待下次答题"
        tableView.reloadData()
    }
}
