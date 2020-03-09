//
//  DBYSlider.swift
//  DBY1VNUI
//
//  Created by 钟凡 on 2019/1/5.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit

protocol DBYSliderDelegate: NSObjectProtocol {
    func valueDidChange(owner: DBYSlider, value:Float)
    func valueEndChange(owner: DBYSlider, value:Float)
}

class DBYSlider: UIView {
    //MARK: - 加载xib代码
    var contentView : UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView!.frame = bounds
        //立即更新进度条位置
        set(value:value)
    }
    func xibSetup() {
        contentView = loadViewFromNib()
        addSubview(contentView!)
        
        let tap = UIPanGestureRecognizer(target: self, action: #selector(onTouchEvent))
        addGestureRecognizer(tap)
    }
    @objc func onTouchEvent(tap:UIPanGestureRecognizer) {
        let point = tap.location(in: self)
        switch tap.state {
        case .began:
            shouldUpdate = true
            break
        case .changed:
            if shouldUpdate == false {
                break
            }
            sliderLeft.constant = point.x - sliderBar.bounds.width * 0.5
            if sliderLeft.constant < 0 {
                sliderLeft.constant = 0
            }
            let sliderMaxX:CGFloat = self.bounds.width - sliderBar.bounds.width
            if sliderLeft.constant > sliderMaxX {
                sliderLeft.constant = sliderMaxX
            }
            let progress = sliderLeft.constant / sliderMaxX
            progressViewWidth.constant = progress * progressBackView.bounds.width
            value = Float(progress) * (maxValue - minValue)
            delegate?.valueDidChange(owner: self, value: value)
            break
        case .ended :
            if shouldUpdate == false {
                break
            }
            shouldUpdate = false
            delegate?.valueEndChange(owner: self, value: value)
            break
        default:
            break
        }
    }
    func loadViewFromNib() -> UIView {
        let classType = type(of:self)
        
        let nib = UINib(nibName: "\(classType)", bundle: currentBundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    //MARK: - 实现代码
    var value: Float = 0 // default 0.0. this value will be pinned to min/max
    
    var minValue: Float = 0 // default 0.0. the current value may change if outside new min value
    
    var maxValue: Float = 1 // default 1.0. the current value may change if outside new max value
    
    var shouldUpdate:Bool = false
    
    weak var delegate:DBYSliderDelegate?
    
    @IBOutlet weak var sliderBar: UIImageView!
    @IBOutlet weak var progressBackView: UIView!
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var sliderLeft: NSLayoutConstraint!
    @IBOutlet weak var progressViewWidth: NSLayoutConstraint!
    
    func set(value:Float) {
        self.value = value
        var progress:CGFloat = 0
        if (maxValue - minValue) == 0 {
            progress = 0
        }else {
            progress = CGFloat(value / (maxValue - minValue))
        }
        if progress < 0 {
            progress = 0
        }
        let maxW:CGFloat = self.bounds.width - 8
        let sliderMaxX:CGFloat = maxW - sliderBar.bounds.width
        sliderLeft.constant = progress * sliderMaxX
        progressViewWidth.constant = progress * maxW
    }
}
