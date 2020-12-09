//
//  DBYSettingView.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/11/6.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit
import SnapKit

protocol DBYSettingViewDelegate: NSObjectProtocol {
    func settingView(owner: DBYSettingView, didSelectedItemAt indexPath: IndexPath)
}
protocol DBYSettingViewFactory {
    static func create() -> DBYSettingView
}
class DBYSettingViewLiveFactory: DBYSettingViewFactory {
    static func create() -> DBYSettingView {
        let settingView = DBYSettingView()
        let settingModel1 = DBYSettingModel()
        settingModel1.name = "通用设置"
        settingModel1.resueId = "\(DBYSettingIconCell.self)"
        settingModel1.items = [DBYSettingItem(name: "音频播放", defaultIcon: "audio-only-normal", selectedIcon: "audio-only-selected")]
        
        let settingModel2 = DBYSettingModel()
        settingModel2.name = "线路切换"
        settingModel2.resueId = "\(DBYSettingLabelCell.self)"
        settingModel2.items = [
            DBYSettingItem(name: "sdk"),
            DBYSettingItem(name: "ali"),
            DBYSettingItem(name: "tencent")
        ]
        
        settingView.models = [
            settingModel1,
            settingModel2
        ]
        return settingView
    }
}
class DBYSettingViewOnlineFactory: DBYSettingViewFactory {
    static func create() -> DBYSettingView {
        let settingView = DBYSettingView()
        let settingModel1 = DBYSettingModel()
        settingModel1.name = "通用设置"
        settingModel1.resueId = "\(DBYSettingIconCell.self)"
        settingModel1.items = [DBYSettingItem(name: "后台播放", defaultIcon: "playback-normal", selectedIcon: "playback-selected")]
        
        var items = [DBYSettingItem]()
        
        for playRate in playRates {
            items.append(DBYSettingItem(name: String(format: "%.1fx", playRate)))
        }
        
        let settingModel2 = DBYSettingModel()
        settingModel2.name = "倍速播放"
        settingModel2.resueId = "\(DBYSettingLabelCell.self)"
        settingModel2.items = items
        
        let settingModel3 = DBYSettingModel()
        settingModel3.name = "线路切换"
        settingModel3.resueId = "\(DBYSettingLabelCell.self)"
        
        settingView.models = [
            settingModel1,
            settingModel2,
            settingModel3
        ]
        return DBYSettingView()
    }
}
class DBYSettingViewOfflineFactory: DBYSettingViewFactory {
    static func create() -> DBYSettingView {
        let settingView = DBYSettingView()
        let settingModel1 = DBYSettingModel()
        settingModel1.name = "通用设置"
        settingModel1.resueId = "\(DBYSettingIconCell.self)"
        settingModel1.items = [DBYSettingItem(name: "后台播放", defaultIcon: "playback-normal", selectedIcon: "playback-selected")]
        
        var items = [DBYSettingItem]()
        
        for playRate in playRates {
            items.append(DBYSettingItem(name: String(format: "%.1fx", playRate)))
        }
        
        let settingModel2 = DBYSettingModel()
        settingModel2.name = "倍速播放"
        settingModel2.resueId = "\(DBYSettingLabelCell.self)"
        settingModel2.items = items
        
        settingView.models = [
            settingModel1,
            settingModel2
        ]
        return DBYSettingView()
    }
}
class DBYSettingHeader: UICollectionReusableView {
    lazy var nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    func setupUI() {
        nameLabel.textColor = UIColor.white
        nameLabel.font = DBYStyle.font12
        addSubview(nameLabel)
        nameLabel.snp_makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
class DBYSettingCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    func setupUI() {
        
    }
}
class DBYSettingIconCell: DBYSettingCell {
    lazy var nameLabel = UILabel()
    lazy var iconView = UIImageView()
    
    override func setupUI() {
        nameLabel.textColor = UIColor.white
        nameLabel.font = DBYStyle.font8
        nameLabel.textAlignment = .center
        addSubview(nameLabel)
        addSubview(iconView)
        iconView.snp_makeConstraints { (make) in
            make.height.width.equalTo(32)
            make.top.equalTo(0)
            make.centerX.equalToSuperview()
        }
        nameLabel.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(10)
        }
    }
}
class DBYSettingLabelCell: DBYSettingCell {
    lazy var nameLabel = UILabel()
    
    override func setupUI() {
        nameLabel.textColor = UIColor.white
        nameLabel.font = DBYStyle.font12
        nameLabel.textAlignment = .center
        addSubview(nameLabel)
        nameLabel.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.centerY.equalToSuperview()
        }
    }
}
class DBYSettingView: DBYView {
    lazy var collectionView:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let c = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return c
    }()
    lazy var models = [DBYSettingModel]()
    weak var delegate: DBYSettingViewDelegate?
    
    override func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DBYSettingIconCell.self, forCellWithReuseIdentifier: "\(DBYSettingIconCell.self)")
        collectionView.register(DBYSettingLabelCell.self, forCellWithReuseIdentifier: "\(DBYSettingLabelCell.self)")
        collectionView.register(DBYSettingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(DBYSettingHeader.self)")
        collectionView.backgroundColor = UIColor.clear
        addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-16)
            make.top.equalTo(16)
        }
    }
}
extension DBYSettingView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = models[indexPath.section]
        model.selectedIndex = indexPath.row
        collectionView.reloadItems(at: [indexPath])
        delegate?.settingView(owner: self, didSelectedItemAt: indexPath)
    }
}
extension DBYSettingView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = models[indexPath.section]
        return model.itemSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
}
extension DBYSettingView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return models.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let model = models[section]
        return model.items?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let model = models[indexPath.section]
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(DBYSettingHeader.self)", for: indexPath) as! DBYSettingHeader
        header.nameLabel.text = model.name
        return header
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[indexPath.section]
        let item = model.items?[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.resueId, for: indexPath)
        if let iconCell = cell as? DBYSettingIconCell {
            iconCell.nameLabel.text = item?.name
            let iconName = model.selectedIndex == indexPath.row ? item?.selectedIcon:item?.defaultIcon
            iconCell.iconView.image = UIImage(name: iconName ?? "")
        }
        if let labelCell = cell as? DBYSettingLabelCell {
            labelCell.nameLabel.text = item?.name
        }
        
        return cell
    }
}
