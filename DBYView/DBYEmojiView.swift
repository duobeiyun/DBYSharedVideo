//
//  DBYEmojiView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/11/6.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYEmojiViewDelegate: NSObjectProtocol {
    func emojiView(emojiView: DBYEmojiView, didSelectedAt index: Int)
}
class DBYEmojiView: UIView {
    let identifier = "DBYEmojiCell"
    let layout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    weak var delegate: DBYEmojiViewDelegate?
    lazy var emojis: [String] = [String]()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func setupUI() {
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: "DBYEmojiCell", bundle: currentBundle)
        collectionView?.register(nib, forCellWithReuseIdentifier: identifier)
        
        if let cv = collectionView {
            addSubview(cv)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        var iphoneXBottom:CGFloat = 0
        if isIphoneXSeries() {
            iphoneXBottom = 34
        }
        let emojiViewX:CGFloat = isLandscape() && isIphoneXSeries() ? 44:8
        collectionView?.frame = CGRect(x: emojiViewX,
                                       y: 8,
                                       width: bounds.width - emojiViewX * 2,
                                       height: bounds.height - 16 - iphoneXBottom)
    }
    func setupData(data: [String]) {
        emojis = data
        collectionView?.reloadData()
    }
}
extension DBYEmojiView:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DBYEmojiCell
        if let image = UIImage(name: emojis[indexPath.item]) {
            cell.imageView.image = image
        }
        return cell
    }
}
extension DBYEmojiView:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
}
extension DBYEmojiView:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.emojiView(emojiView: self, didSelectedAt: indexPath.item)
    }
}
