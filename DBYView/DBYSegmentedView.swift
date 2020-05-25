//
//  DBYSegmentedView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/5/18.
//

import UIKit
import SnapKit

class DBYSegmentedModel: NSObject {
    var displayWidth: CGFloat = 0
    var label: UILabel?
    var view: UIView?
}
class DBYSegmentedTitleView: UIScrollView {
    lazy var models:[DBYSegmentedModel] = [DBYSegmentedModel]()
    lazy var barLayer:CAShapeLayer = CAShapeLayer()
    var selectedIndex:Int = 0
    var contentWidth:CGFloat = 0
    var barAnimation:CAAnimationGroup?
    var barColor: UIColor = .yellow {
        didSet {
            barLayer.backgroundColor = barColor.cgColor
        }
    }
    var hilightColor: UIColor = .lightGray
    var defaultColor: UIColor = .lightGray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setupUI() {
        barLayer.backgroundColor = barColor.cgColor
        barLayer.cornerRadius = 2
        layer.addSublayer(barLayer)
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(ges:)))
        addGestureRecognizer(tap)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let labelHeight = bounds.height
        contentWidth = 0
        for model in models {
            if let label = model.label {
                label.frame = CGRect(x: contentWidth, y: 0, width: model.displayWidth, height: labelHeight)
                contentWidth += model.displayWidth
            }
        }
    }
    @objc private func tap(ges: UITapGestureRecognizer) {
        let location = ges.location(in: self)
        var index = -1
        for (i, model) in models.enumerated() {
            if let result = model.label?.frame.contains(location), result {
                index = i
            }
        }
        if index < 0 {
            return
        }
        scrollToIndex(index: index)
    }
    private func removeModel(model: DBYSegmentedModel) {
        if let label = model.label {
            label.removeFromSuperview()
        }
    }
    public func appendModel(model: DBYSegmentedModel) {
        if models.contains(model) {
            return
        }
        models.append(model)
        if let label = model.label {
            addSubview(label)
        }
    }
    public func appendModels(models: [DBYSegmentedModel]) {
        for model in models {
            appendModel(model: model)
        }
    }
    public func removeLastModel() {
        let model = models.removeLast()
        removeModel(model: model)
    }
    public func removeModel(at index: Int) {
        let model = models.remove(at: index)
        removeModel(model: model)
    }
    public func scrollToIndex(index: Int) {
        if index >= models.count {
            return
        }
        let preModel = models[selectedIndex]
        preModel.label?.textColor = defaultColor
        selectedIndex = index
        let model = models[index]
        guard let label = model.label else {
            return
        }
        label.textColor = hilightColor
        let labelHeight = label.frame.height
        let labelWidth = label.frame.width
        let textWidth = label.text?.width(withMaxHeight: labelHeight, font: label.font) ?? 0
        let minX = label.frame.minX + (labelWidth - textWidth) * 0.5
        barLayer.frame = CGRect(x: minX, y: bounds.height - 12, width: textWidth, height: 4)
        if contentWidth < bounds.width {
            return
        }
        let halfWidth = bounds.width * 0.5
        let centerOffset = label.frame.minX + labelWidth * 0.5
        
        var diff = centerOffset - halfWidth
        if centerOffset < halfWidth {
            diff = 0
        }
        if contentWidth - centerOffset < halfWidth {
            diff = contentWidth - bounds.width
        }
        
        let offset = CGPoint(x: diff, y: 0)
        setContentOffset(offset, animated: true)
    }
}
class DBYSegmentedContainerView: UICollectionView {
    var flowLayout:UICollectionViewFlowLayout!
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.init(frame:.zero, collectionViewLayout:layout)
        self.flowLayout = layout
        backgroundColor = UIColor.white
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.itemSize = bounds.size
    }
    public func scrollToIndex(index: Int) {
        let offset = CGPoint(x: CGFloat(index) * bounds.width, y: 0)
        setContentOffset(offset, animated: true)
    }
}
class DBYSegmentedView: UIView {
    var titleView:DBYSegmentedTitleView!
    var containerView:DBYSegmentedContainerView!
    lazy var dataSource:[DBYSegmentedModel] = [DBYSegmentedModel]()
    let cellIdentifier = "DBYSegmentedViewCell"
    public var barColor: UIColor = .yellow {
        didSet {
            titleView.barColor = barColor
        }
    }
    public var hilightColor: UIColor = .lightGray {
        didSet {
            titleView.hilightColor = hilightColor
        }
    }
    public var defaultColor: UIColor = .lightGray {
        didSet {
            titleView.defaultColor = defaultColor
        }
    }
    override var backgroundColor: UIColor? {
        didSet {
            titleView.backgroundColor = backgroundColor
            containerView.backgroundColor = backgroundColor
        }
    }
    var titleViewHeight:CGFloat = 44
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    func setupUI() {
        titleView = DBYSegmentedTitleView()
        containerView = DBYSegmentedContainerView()
        containerView.delegate = self
        containerView.dataSource = self
        containerView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        containerView.isPagingEnabled = true
        
        addSubview(titleView)
        addSubview(containerView)
        
        titleView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(titleViewHeight)
        }
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(titleViewHeight)
            make.left.bottom.right.equalTo(0)
        }
    }
    public func appendData(models: [DBYSegmentedModel]) {
        dataSource += models
        containerView.reloadData()
        titleView.appendModels(models: models)
    }
    public func removeLastData() {
        titleView.removeLastModel()
        dataSource.removeLast()
        containerView.reloadData()
    }
    public func removeData(at index: Int) {
        titleView.removeModel(at: index)
        dataSource.remove(at: index)
        containerView.reloadData()
    }
    public func scrollToIndex(index: Int) {
        if index >= dataSource.count {
            return
        }
        containerView.scrollToIndex(index: index)
        titleView.scrollToIndex(index: index)
    }
}
extension DBYSegmentedView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == containerView {
            let index = Int(scrollView.contentOffset.x / containerView.bounds.width)
            titleView.scrollToIndex(index: index)
        }
    }
}
extension DBYSegmentedView: UICollectionViewDelegate {
    
}
extension DBYSegmentedView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        guard let view = dataSource[indexPath.item].view else {
            return cell
        }
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = cell.bounds
        cell.contentView.addSubview(view)
        
        return cell
    }
}
