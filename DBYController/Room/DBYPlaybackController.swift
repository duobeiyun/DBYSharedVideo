//
//  DBYPlaybackController.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/10.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

public class DBYPlaybackController: DBY1VNController {
    let playRates:[Float] = [0.5, 0.8, 1.0, 1.5, 2.0]
    let playRateTitles:[String] = ["0.5x", "0.8x", "1.0x", "1.5x", "2.0x"]
    lazy var timeTipLab:UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.font = UIFont.systemFont(ofSize: 14)
        label.frame = CGRect(origin: .zero, size: CGSize(width: 14 * 8, height: 14 * 1.2))
        label.textColor = UIColor.white
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    lazy var bottomSettingBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(name: "btn-setting"), for: .normal)
        return btn
    }()
    
    lazy var indicator = UIActivityIndicatorView()
    
    var beginInteractive:Bool = false
    var time:TimeInterval = 0
    
    //MARK: - override functions
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        startHiddenTimer()
        segmentedView.scrollToIndex(index: 0)
    }
    override public func addSubviews() {
        super.addSubviews()
        
        view.addSubview(timeTipLab)
        view.addSubview(indicator)
        chatContainer.addSubview(chatListView)
    }
    override func addActions() {
        super.addActions()
        
    }
    override func setupStaticUI() {
        super.setupStaticUI()
        topBar.set(authinfo?.courseTitle)
        settingView.set(speeds: playRateTitles)
        courseInfoView.set(title: authinfo?.courseTitle)
        
        var models = [DBYSegmentedModel]()
        var titleOffset:CGFloat = 0
        let dicts:[[String:Any]] = [
            [
                "title":"互动",
                "view":chatContainer
            ],[
                "title":"课程信息",
                "view":courseInfoView
            ]
        ]
        for dict in dicts {
            let model = DBYSegmentedModel()
            let title = dict["title"] as! String
            let l = UILabel()
            l.text = title
            l.font = UIFont(name: "Helvetica", size: 14)
            l.textAlignment = .center
            let v = dict["view"] as! UIView
            
            let titleWidth = title.width(withMaxHeight: 44, font: l.font) * 2
            
            model.displayWidth = 60
            model.label = l
            model.view = v
            models.append(model)
            titleOffset += titleWidth
        }
        segmentedView.appendData(models: models)
    }
    
    override func setupPortraitUI() {
        super.setupPortraitUI()
        bottomBar.set(type: .playback)
    }
    override func setupLandscapeUI() {
        super.setupLandscapeUI()
        bottomBar.set(type: .playbackLandscape)
    }
    override func updateFrame() {
        super.updateFrame()
        
        timeTipLab.center = CGPoint(x: mainViewFrame.midX, y: mainViewFrame.midY)
        indicator.center = CGPoint(x: mainViewFrame.midX, y: mainViewFrame.midY)
    }
    override func updatePortraitFrame() {
        super.updatePortraitFrame()
        
        let size = view.bounds.size
        
        segmentedViewFrame = CGRect(x: 0,
                                      y: mainViewFrame.maxY,
                                      width: size.width,
                                      height: size.height - mainViewFrame.maxY)
        chatListViewFrame = CGRect(x: 0,
                                   y: 0,
                                   width: segmentedViewFrame.width,
                                   height: segmentedViewFrame.height)
    }
    override func updateLandscapeFrame() {
        super.updateLandscapeFrame()
        
        let size = view.bounds.size
        let chatContainerWidth = size.width * 0.5
        
        segmentedViewFrame = CGRect(x: size.width,
                                      y: 0,
                                      width: chatContainerWidth,
                                      height: size.height)
        chatListViewFrame = CGRect(x: 0,
                                   y: 0,
                                   width: segmentedViewFrame.width,
                                   height: segmentedViewFrame.height)
    }
    @objc override func goBack() {
        super.goBack()
        
        stopHiddenTimer()
    }
    override func hiddenControlBar() {
        if voiceTimer == nil {
            return
        }
        if voiceTimer!.isValid == false {
            return
        }
        super.hiddenControlBar()
    }
    override func showControlBar() {
        super.showControlBar()
    }
    override func gestureControl(pan: UIPanGestureRecognizer) {
        super.gestureControl(pan: pan)
        switch pan.state {
        case .began:
            time = bottomBar.currentValue
        case .changed:
            let position = pan.location(in: mainView)
            let offsetX = position.x - beganPosition.x
            let offsetY = position.y - beganPosition.y
            if abs(offsetX) < abs(offsetY) {
                return
            }
            let progress = offsetX / mainViewFrame.width
            changeProgress(value: progress)
        case .ended:
            changeEnded()
        default:
            break
        }
    }
    func changeProgress(value: CGFloat) {
        let tempTime = time + bottomBar.maxValue * Double(value)
        stopHiddenTimer()
        beginInteractive = true
        timeTipLab.isHidden = false
        timeTipLab.text = String.playTime(time:Int(tempTime))
        timeTipLab.sizeToFit()
        bottomBar.set(time: tempTime)
    }
    func changeEnded() {
        beginInteractive = false
        timeTipLab.isHidden = true
        indicator.isHidden = false
        indicator.startAnimating()
    }
    //MARK: - private functions
    
}
