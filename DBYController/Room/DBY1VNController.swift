//
//  DBY1VNController.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/18.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit
import MediaPlayer
import DBYSDK_dylib

public class DBY1VNController: UIViewController {
    @objc public var authinfo: DBYAuthInfo?
    
    var isLoading: Bool = false
    var isStoping: Bool = false
    
    lazy var videoDict = [String: DBYStudentVideoView]()
    
    lazy var topBar:DBYTopBar = DBYTopBar()
    lazy var bottomBar:DBYBottomBar = DBYBottomBar()
    
    lazy var mainView = DBYMainView()
    lazy var courseInfoView = DBYCourseInfoView()
    lazy var segmentedView = DBYSegmentedView()
    var settingView:DBYSettingView!
    lazy var chatListView = DBYChatListView()
    
    lazy var netTipView = DBYNetworkTipView()
    lazy var internetReachability = DBYReachability.forInternetConnection()
    lazy var changeLineButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(name: "icon-lines"), for: .normal)
        b.isHidden = true
        return b
    }()
    //MARK: - override functions
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    public override var prefersStatusBarHidden: Bool {
        return topBar.isHidden
    }
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        DBYSystemControl.shared.beginControl()
        topBar.isHidden = false
        bottomBar.isHidden = false
        mainView.startTimer()
        updateFrameAndStyle()
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DBYSystemControl.shared.endControl()
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.delegate = self
        addObserver()
        initSubViews()
        addSubviews()
        setViewFrameAndStyle()
        addActions()
        setupStaticUI()
        setupPortraitUI()
        internetReachability?.startNotifier()
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width < size.height {
            setupPortraitUI()
        }else {
            setupLandscapeUI()
        }
        weak var weakSelf = self
        coordinator.animate(alongsideTransition: { (context) in
            weakSelf?.updateFrameAndStyle()
        }) { (context) in
            weakSelf?.topBar.isHidden = false
            weakSelf?.bottomBar.isHidden = false
            weakSelf?.mainView.startTimer()
            weakSelf?.chatListView.reloadData()
        }
    }
    deinit {
        print("---deinit", type(of: self))
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - private functions
    func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: NSNotification.Name.dbyReachabilityChanged,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(volumeChange(notification:)),
                                               name: volumeChangeNotification,
                                               object: nil)
    }
    func initSubViews() {
        
    }
    func addSubviews() {
        view.addSubview(mainView)
        view.addSubview(topBar)
        view.addSubview(bottomBar)
        view.addSubview(segmentedView)
    }
    func addActions() {
        
    }
    func setupStaticUI() {
        view.backgroundColor = UIColor.white
        
        mainView.backgroundColor = UIColor.white
        segmentedView.barColor = DBYStyle.yellow
        segmentedView.hilightColor = DBYStyle.darkGray
        segmentedView.defaultColor = DBYStyle.middleGray
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    func setupPortraitUI() {
        segmentedView.isHidden = false
        settingView.isHidden = true
    }
    func setupLandscapeUI() {
        segmentedView.isHidden = true
    }
    func setViewFrameAndStyle() {
        let edge = getIphonexEdge()
        
        let size = UIScreen.main.bounds.size
        let videoHeight = size.width * 0.5625
        let segmentedViewMinX = videoHeight + edge.top
        let segmentedViewHeight = size.height - segmentedViewMinX
        mainView.portraitFrame = CGRect(x: 0, y: edge.top, width: size.width, height: videoHeight)
        mainView.landscapeFrame = CGRect(x: edge.left, y: 0, width: size.height - edge.right, height: size.width)
        
        segmentedView.portraitFrame = CGRect(x: 0, y: segmentedViewMinX, width: size.width, height: segmentedViewHeight)
        segmentedView.landscapeFrame = CGRect(x: size.height, y: -44, width: size.width, height: size.width + 44)
        
        settingView.portraitFrame = segmentedView.portraitFrame
        settingView.landscapeFrame = CGRect(x: size.height - 246 - edge.right, y: 0, width: 246, height: size.width)
        
        chatListView.setBackgroundColor(color: DBYStyle.lightGray, forState: .portrait)
        chatListView.setBackgroundColor(color: DBYStyle.lightAlpha, forState: .landscape)
        
        settingView.setBackgroundColor(color: DBYStyle.lightGray, forState: .portrait)
        settingView.setBackgroundColor(color: DBYStyle.lightAlpha, forState: .landscape)
        
        topBar.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(mainView)
            make.height.equalTo(60)
        }
        bottomBar.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(mainView)
            make.height.equalTo(60)
        }
        updateFrameAndStyle()
    }
    func updateFrameAndStyle() {
        mainView.updateFrameAndStyle()
        segmentedView.updateFrameAndStyle()
        chatListView.updateFrameAndStyle()
        settingView.updateFrameAndStyle()
    }
    func showSettingView() {
        view.addSubview(settingView)
        UIView.animate(withDuration: 0.25) {
            self.settingView.isHidden = false
        }
    }
    func hiddenSettingView() {
        settingView.removeFromSuperview()
        UIView.animate(withDuration: 0.25) {
            self.settingView.isHidden = true
        }
    }
    func settingClick() {
        showSettingView()
    }
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
    func toLandscape() {
        UIDevice.current.setValue(UIDeviceOrientation.unknown.rawValue, forKey: "orientation")
        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
    }
    func toPortrait() {
        UIDevice.current.setValue(UIDeviceOrientation.unknown.rawValue, forKey: "orientation")
        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    func createVideoView(uid: String) -> DBYStudentVideoView {
        let videoView = DBYStudentVideoView()
        videoView.backgroundColor = UIColor.white
        videoView.userId = uid
        videoDict[uid] = videoView
        
        videoView.portraitFrame = CGRect(x: mainView.frame.minX, y: mainView.frame.maxY + segmentedView.titleViewHeight, width: 172, height: 158)
        videoView.landscapeFrame = CGRect(x: mainView.frame.minX, y: topBar.bounds.height, width: 172, height: 158)
        view.addSubview(videoView)
        videoView.updateFrameAndStyle()
        
        let drag = UIPanGestureRecognizer(target: self,
                                          action: #selector(dragVideoView(pan:)))
        let pinch = UIPinchGestureRecognizer(target: self,
                                             action: #selector(scaleVideoView(pinch:)))
        
        videoView.addGestureRecognizer(drag)
        videoView.addGestureRecognizer(pinch)
        
        return videoView
    }
    func removeVideoView(uid: String) {
        let videoView = videoDict.removeValue(forKey: uid)
        videoView?.removeFromSuperview()
    }
    func adjustVideoViewFrame(videoView: UIView?) {
        let viewW = view.bounds.width
        let viewH = view.bounds.height
        let halfW = viewW * 0.5
        var rect = videoView?.frame ?? .zero
        if rect.midX < 0 || rect.midX <= halfW {
            rect.origin.x = 0
        }
        if rect.midX > halfW {
            rect.origin.x = viewW - rect.width
        }
        if rect.midY < 0 {
            rect.origin.y = 0
        }
        if rect.midY > viewH {
            rect.origin.y = viewH
        }
        UIView.animate(withDuration: 0.25) {
            videoView?.frame = rect
        }
    }
    func segmentedTitleLabel(title: String) -> UILabel {
        let l = UILabel()
        l.text = title
        l.textColor = DBYStyle.middleGray
        l.font = UIFont(name: "Helvetica", size: 12)
        l.textAlignment = .center
        return l
    }
    //MARK: - objc functions
    @objc func volumeChange(notification:Notification) {
        if let volume = notification.object as? CGFloat {
            mainView.volumeProgressView.setProgress(value: volume)
        }
    }
    
    @objc func scaleVideoView(pinch:UIPinchGestureRecognizer) {
        guard let videoView = pinch.view as? DBYStudentVideoView else {
            return
        }
        if pinch.state == .began {
            pinch.scale = videoView.scale
        }
        var scale = pinch.scale
        if pinch.state == .changed {
            if scale > 2 {
                scale = 2
            }
            if scale < 1 {
                scale = 1
            }
            let scaleW = videoView.portraitFrame.width * scale
            let scaleH = videoView.portraitFrame.height * scale
            
            videoView.bounds = CGRect(x: 0, y: 0, width: scaleW, height: scaleH)
        }
        if pinch.state == .ended {
            videoView.scale = scale
            adjustVideoViewFrame(videoView: pinch.view)
        }
    }
    @objc func dragVideoView(pan:UIPanGestureRecognizer) {
        let videoView = pan.view
        let position = pan.location(in: view)
        
        switch pan.state {
        case .changed:
            videoView?.center = position
            break
        case .ended:
            adjustVideoViewFrame(videoView:videoView)
            break
        default:
            break
        }
    }
    
    
    @objc func reachabilityChanged(note:NSNotification) {
        
    }
    @objc func playbackEnable(sender:UIButton) {
        sender.isSelected = !sender.isSelected
    }
    func requestOpenCamera() {
    }
    func cancelOpenCamera() {
    }
    func closeCamera() {
    }
}
//MARK: - DBYMainViewDelegate
extension DBY1VNController: DBYMainViewDelegate {
    func volumeChange(owner: DBYMainView, volume: CGFloat) {
        
    }
    
    func lightnessChange(owner: DBYMainView, volume: CGFloat) {
        
    }
    func didClick() {
        topBar.isHidden = !topBar.isHidden
        bottomBar.isHidden = !bottomBar.isHidden
        
        if topBar.isHidden {
            mainView.timer?.stop()
            if isLandscape() {
                settingView.isHidden = true
                segmentedView.isHidden = true
            }
        } else {
            mainView.startTimer()
        }
    }
    func timerOut() {
        topBar.isHidden = true
        bottomBar.isHidden = true
    }
}
