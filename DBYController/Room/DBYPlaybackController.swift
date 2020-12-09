//
//  DBYPlaybackController.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/10.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

public class DBYPlaybackController: DBY1VNController {
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
        
        segmentedView.scrollToIndex(index: 0, animated: false)
    }
    override public func addSubviews() {
        super.addSubviews()
        
        view.addSubview(timeTipLab)
        view.addSubview(indicator)
    }
    override func setupStaticUI() {
        super.setupStaticUI()
        topBar.set(authinfo?.courseTitle)
        courseInfoView.set(title: authinfo?.courseTitle)
        chatListView.showChatbar = false
        
        var models = [DBYSegmentedModel]()
        var titleOffset:CGFloat = 0
        let dicts:[[String:Any]] = [
            [
                "title":"互动",
                "view":chatListView
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
            
            model.labelWidth = 60
            model.label = l
            model.view = v
            models.append(model)
            titleOffset += titleWidth
        }
        segmentedView.appendDatas(models: models)
    }
    
    override func setupPortraitUI() {
        super.setupPortraitUI()
        bottomBar.set(type: .playback)
    }
    override func setupLandscapeUI() {
        super.setupLandscapeUI()
        bottomBar.set(type: .playbackLandscape)
    }
    override func setViewFrameAndStyle() {
        super.setViewFrameAndStyle()
        
        let size = UIScreen.main.bounds.size
        let chatListViewHeight = segmentedView.portraitFrame.height - segmentedView.titleViewHeight
        
        timeTipLab.center = CGPoint(x: mainView.frame.midX, y: mainView.frame.midY)
        indicator.center = CGPoint(x: mainView.frame.midX, y: mainView.frame.midY)
        
        chatListView.portraitFrame = CGRect(x: 0, y: 0, width: size.width, height: chatListViewHeight)
        chatListView.landscapeFrame = CGRect(x: 0, y: 0, width: size.width, height: size.width)
    }
    //MARK: - private functions
    
}
