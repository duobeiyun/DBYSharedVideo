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
protocol DBYSegmentedProtocol {
    func removeModel(model: DBYSegmentedModel)
    func appendModel(model: DBYSegmentedModel)
    func appendModels(models: [DBYSegmentedModel])
    func scrollToIndex(index: Int)
}
class DBYSegmentedTitleView: UIScrollView {
    lazy var models:[DBYSegmentedModel] = [DBYSegmentedModel]()
    lazy var barLayer:CAShapeLayer = CAShapeLayer()
    var preModel:DBYSegmentedModel?
    var contentWidth:CGFloat = 0
    var barAnimation:CAAnimationGroup?
    var barColor: UIColor = .yellow {
        didSet {
            barLayer.backgroundColor = barColor.cgColor
        }
    }
    var hilightColor: UIColor = .lightGray
    var defaultColor: UIColor = .darkGray
    var indexChanged: ((Int)->())?
    var scrollIndex:Int = 0
    
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
        
        contentWidth = 0
        for model in models {
            if let label = model.label {
                label.frame = CGRect(x: contentWidth, y: 0, width: model.displayWidth, height: bounds.height)
                contentWidth += model.displayWidth
            }
        }
        contentSize = CGSize(width: contentWidth, height: bounds.height)
        updateBarFrame()
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
        indexChanged?(index)
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
        let index = models.count - 1
        removeModel(at: index)
    }
    public func removeModel(at index: Int) {
        let model = models.remove(at: index)
        removeModel(model: model)
        scrollToIndex(index: index - 1)
    }
    public func scrollToIndex(index: Int) {
        if index >= models.count {
            return
        }
        scrollIndex = index
        //取消选中
        preModel?.label?.textColor = defaultColor
        //选中的label
        let model = models[index]
        preModel = model
        guard let label = model.label else {
            return
        }
        label.textColor = hilightColor
        //计算bar的位置
        let textWidth = label.text?.width(withMaxHeight: bounds.height, font: label.font) ?? 0
        let minX = CGFloat(index) * model.displayWidth
        let barMinX = minX + (model.displayWidth - textWidth) * 0.5
        let barMinY = bounds.height - 12
        barLayer.frame = CGRect(x: barMinX, y: barMinY, width: textWidth, height: 4)
        //如果小于一个屏幕，不需要滚动
        if contentWidth < bounds.width {
            return
        }
        //计算滚动位置
        let halfWidth = bounds.width * 0.5
        let centerOffset = minX + model.displayWidth * 0.5
        
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
    func updateBarFrame() {
        let model = models[scrollIndex]
        guard let label = model.label else {
            return
        }
        let textWidth = label.text?.width(withMaxHeight: bounds.height, font: label.font) ?? 0
        let minX = CGFloat(scrollIndex) * model.displayWidth
        let barMinX = minX + (model.displayWidth - textWidth) * 0.5
        let barMinY = bounds.height - 12
        barLayer.frame = CGRect(x: barMinX, y: barMinY, width: textWidth, height: 4)
    }
    func updateOffset() {
        
    }
}
class DBYSegmentedContainerView: UIScrollView {
    lazy var models:[DBYSegmentedModel] = [DBYSegmentedModel]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var contentOffset:CGFloat = 0
        for model in models {
            if let view = model.view {
                view.frame = CGRect(x: contentOffset, y: 0, width: bounds.width, height: bounds.height)
                contentOffset += bounds.width
            }
        }
        contentSize = CGSize(width: contentOffset, height: bounds.height)
    }
    private func removeModel(model: DBYSegmentedModel) {
        if let view = model.view {
            view.removeFromSuperview()
        }
    }
    public func appendModel(model: DBYSegmentedModel) {
        if models.contains(model) {
            return
        }
        models.append(model)
        if let view = model.view {
            addSubview(view)
        }
    }
    public func appendModels(models: [DBYSegmentedModel]) {
        for model in models {
            appendModel(model: model)
        }
    }
    public func removeLastModel() {
        let index = models.count - 1
        removeModel(at: index)
    }
    public func removeModel(at index: Int) {
        let model = models.remove(at: index)
        removeModel(model: model)
        scrollToIndex(index: index - 1)
    }
    public func scrollToIndex(index: Int) {
        if index >= models.count {
            return
        }
        let offset = bounds.width * CGFloat(index)
        setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
    public func scrollToLast() {
        let index = models.count
        let offset = bounds.width * CGFloat(index)
        setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
}
class DBYSegmentedView: UIView {
    var titleView:DBYSegmentedTitleView?
    var containerView:DBYSegmentedContainerView?
    
    public var barColor: UIColor = .yellow {
        didSet {
            titleView?.barColor = barColor
        }
    }
    public var hilightColor: UIColor = .lightGray {
        didSet {
            titleView?.hilightColor = hilightColor
        }
    }
    public var defaultColor: UIColor = .lightGray {
        didSet {
            titleView?.defaultColor = defaultColor
        }
    }
    override var backgroundColor: UIColor? {
        didSet {
            titleView?.backgroundColor = backgroundColor
            containerView?.backgroundColor = backgroundColor
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
        
        addSubview(titleView!)
        addSubview(containerView!)
        
        containerView?.isPagingEnabled = true
        titleView?.delegate = self
        containerView?.delegate = self
        
        titleView?.indexChanged = { [weak self] index in
            self?.containerView?.scrollToIndex(index: index)
        }
        titleView?.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(titleViewHeight)
        }
        containerView?.snp.makeConstraints { (make) in
            make.top.equalTo(titleViewHeight)
            make.left.bottom.right.equalTo(0)
        }
    }
    public func appendData(model: DBYSegmentedModel) {
        for titleModel in titleView!.models {
            if titleModel.label?.text == model.label?.text {
                return
            }
        }
        containerView?.appendModels(models: [model])
        titleView?.appendModels(models: [model])
    }
    public func appendDatas(models: [DBYSegmentedModel]) {
        containerView?.appendModels(models: models)
        titleView?.appendModels(models: models)
    }
    public func removeLastData() {
        titleView?.removeLastModel()
        containerView?.removeLastModel()
    }
    public func removeData(at index: Int) {
        titleView?.removeModel(at: index)
        containerView?.removeModel(at: index)
    }
    public func removeData(with title: String) {
        let count = titleView?.models.count ?? 0
        for i in (0..<count).reversed() {
            let model = titleView?.models[i]
            if model?.label?.text == title {
                titleView?.removeModel(at: i)
                containerView?.removeModel(at: i)
            }
        }
    }
    public func scrollToIndex(index: Int) {
        titleView?.scrollToIndex(index: index)
        containerView?.scrollToIndex(index: index)
    }
}
extension DBYSegmentedView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll(scrollView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndScroll(scrollView)
    }
    func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        if scrollView == containerView {
            let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            titleView?.scrollToIndex(index: index)
        }
        if scrollView == titleView {
            let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            containerView?.scrollToIndex(index: index)
        }
    }
}
