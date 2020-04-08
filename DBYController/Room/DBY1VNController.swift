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

func badgeUrl(role: Int, badgeDict:[String: Any]?) -> (String?, String?) {
    let disable = badgeDict?["disabled"] as? Bool ?? false
    if disable {
        return (nil, nil)
    }
    var imageKey:String = ""
    switch role {
    case 1:
        imageKey = "teacher"
    case 2:
        imageKey = "student"
    case 4:
        imageKey = "assistant"
    default:
        break
    }
    let placeHolderName = "icon-" + imageKey
    
    var resourceName: String = ""
    if let items = badgeDict?["items"] as? [String: String] {
        resourceName = items[imageKey] ?? ""
    }
    let serverUrl = DBYUrlConfig.shared().staticUrl(withSourceName: resourceName)
    return (serverUrl, placeHolderName)
}

public class DBY1VNController: UIViewController {
    let messageLabFontSize: CGFloat = 12
    let messageLabMargin: CGFloat = 18
    let estimatedRowHeight: CGFloat = 44
    let normalMargin: CGFloat = 8
    let topBtnMargin: CGFloat = 5
    let topBtnSize: CGSize = CGSize(width: 38, height: 38)
    let popBtnSize: CGSize = CGSize(width: 38, height: 38)
    let roomControlbarHeight: CGFloat = 40
    let fromIdentifier: String = "DBYCommentFromCell"
    let toIdentifier: String = "DBYCommentToCell"
    let zanCell = "DBYZanCell"
    var originTransform:CGAffineTransform = CGAffineTransform(scaleX: 1, y: 1)
    
    @objc public var authinfo: DBYAuthInfo?
    
    var mainViewFrame: CGRect = .zero
    var chatListViewFrame: CGRect = .zero
    var roomControlbarFrame: CGRect = .zero
    var scrollContainerFrame: CGRect = .zero
    var smallPopViewFrame: CGRect = .zero
    var largePopViewFrame: CGRect = .zero
    
    var iphoneXTop: CGFloat = 20
    var iphoneXLeft: CGFloat = 0
    var iphoneXRight: CGFloat = 0
    var iphoneXBottom: CGFloat = 0
    
    var beganPosition:CGPoint = .zero
    var brightness:CGFloat = 0
    var volume:Float = 0
    
    var controlBarIsHidden: Bool = false
    var isLoading: Bool = false
    var isStoping: Bool = false
    
    var voiceTimer: Timer?
    
    var allChatList: [[String:Any]] = [[String:Any]]() {
        didSet {
            if allChatList.count > 0 {
                chatListView.backgroundView = nil
            }
        }
    }
    
    lazy var videoDict = [String: DBYStudentVideoView]()
    //缓存高度字典
    lazy var cellHeightCache:[Int: CGFloat] = [Int: CGFloat]()
    
    lazy var mainView = DBYVideoView()
    lazy var chatContainer = UIView()
    lazy var courseInfoView = DBYCourseInfoView()
    lazy var videoTipView = DBYVideoTipView()
    lazy var roomControlbar = DBYRoomControlbar()
    lazy var volumeProgressView = DBYProgressView()
    lazy var brightnessProgressView = DBYProgressView()
    lazy var scrollContainer = DBYScrollView()
    lazy var settingView = DBYSettingView()
    lazy var chatListView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        let classType = type(of: self)
        
        let fromNib = UINib(nibName: fromIdentifier, bundle: currentBundle)
        let toNib = UINib(nibName: toIdentifier, bundle: currentBundle)
        let zanNib = UINib(nibName: zanCell, bundle: currentBundle)
        
        t.backgroundColor = DBYStyle.lightGray
        t.separatorStyle = .none
        t.allowsSelection = false
        t.estimatedRowHeight = estimatedRowHeight
        
        t.register(fromNib, forCellReuseIdentifier: fromIdentifier)
        t.register(toNib, forCellReuseIdentifier: toIdentifier)
        t.register(zanNib, forCellReuseIdentifier: zanCell)
        
        return t
    }()
    
    lazy var netTipView = DBYNetworkTipView()
    lazy var internetReachability = DBYReachability.forInternetConnection()
    
    lazy var topBar:DBYTopBar = DBYTopBar()
    lazy var bottomBar:DBYBottomBar = DBYBottomBar()
    
    lazy var playbackBtn:DBYVerticalButton = {
        let btn = DBYVerticalButton()
        btn.setImage(UIImage(name:"playback-normal"), for: .normal)
        btn.setImage(UIImage(name:"playback-selected"), for: .selected)
        btn.setTitle("后台播放", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 8)
        btn.titleLabel?.textColor = UIColor.white
        btn.titleLabel?.textAlignment = .center
        btn.imageView?.contentMode = .center
        return btn
    }()

    //MARK: - override functions
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    public override var prefersStatusBarHidden: Bool {
        return controlBarIsHidden
    }
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startHiddenTimer()
        DBYSystemControl.shared.beginControl()
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopHiddenTimer()
        DBYSystemControl.shared.endControl()
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: NSNotification.Name.dbyReachabilityChanged,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(volumeChange(notification:)),
                                               name: volumeChangeNotification,
                                               object: nil)
        
        addSubviews()
        addActions()
        setupOrientationUI()
        updateFrame()
        setupStaticUI()
        internetReachability?.startNotifier()
    }
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        startHiddenTimer()
        unowned let weakSelf = self
        coordinator.animate(alongsideTransition: { (context) in
            weakSelf.setupOrientationUI()
            weakSelf.updateFrame()
            weakSelf.cellHeightCache.removeAll()
            weakSelf.chatListView.reloadData()
        }) { (context) in

        }
    }
    deinit {
        print("---deinit")
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - private functions
    func addSubviews() {
        view.addSubview(mainView)
        view.addSubview(volumeProgressView)
        view.addSubview(brightnessProgressView)
        view.addSubview(topBar)
        view.addSubview(bottomBar)
        view.addSubview(scrollContainer)
        view.addSubview(roomControlbar)
        view.addSubview(settingView)
    }
    func addActions() {
        let oneTap = UITapGestureRecognizer(target: self,
                                            action: #selector(oneTap(tap:)))
        mainView.addGestureRecognizer(oneTap)
        
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(gestureControl(pan:)))
        
        mainView.addGestureRecognizer(pan)
        playbackBtn.addTarget(self, action: #selector(playbackEnable), for: .touchUpInside)
    }
    func setupStaticUI() {
        view.backgroundColor = UIColor.white
        
        chatContainer.backgroundColor = UIColor.clear
        roomControlbar.backgroundColor = UIColor.white
        mainView.backgroundColor = UIColor.white
        
        roomControlbar.delegate = self
        scrollContainer.delegate = self
        scrollContainer.bounces = false
        scrollContainer.isPagingEnabled = true
        scrollContainer.backgroundColor = UIColor.clear
        scrollContainer.showsHorizontalScrollIndicator = false
        scrollContainer.showsVerticalScrollIndicator = false
        
        if #available(iOS 11.0, *) {
            chatListView.insetsContentViewsToSafeArea = false
        }
        volumeProgressView.setIcon(icon: "volume")
        let volume = DBYSystemControl.shared.getVolume()
        volumeProgressView.setProgress(value: CGFloat(volume))
        
        brightnessProgressView.setIcon(icon: "brightness")
        let brightness = DBYSystemControl.shared.getBrightness()
        brightnessProgressView.setProgress(value: brightness)
        
        volumeProgressView.isHidden = true
        brightnessProgressView.isHidden = true
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    func setupOrientationUI() {
        if isPortrait(){
            setupPortraitUI()
        }else {
            setupLandscapeUI()
        }
        settingView.isHidden = true
    }
    func setupPortraitUI() {
        scrollContainer.isScrollEnabled = true
        roomControlbar.isHidden = false
        chatListView.isHidden = false
        chatListView.backgroundColor = DBYStyle.lightGray
    }
    func setupLandscapeUI() {
        scrollContainer.isScrollEnabled = false
        roomControlbar.isHidden = true
        chatListView.backgroundColor = DBYStyle.darkAlpha
    }
    func updateFrame() {
        iphoneXTop = 20
        iphoneXLeft = 0
        iphoneXRight = 0
        iphoneXBottom = 0
        if isIphoneXSeries() {
            let orientation = UIApplication.shared.statusBarOrientation
            if orientation == .landscapeLeft || orientation == .landscapeRight{
                iphoneXLeft = 44
                iphoneXRight = 44
            }
            if orientation == .portrait {
                iphoneXTop = 44
            }
            iphoneXBottom = 34
        }
        
        if isPortrait() {
            updatePortraitFrame()
        }else {
            updateLandscapeFrame()
        }
        let size = view.bounds.size
        let progressWidth:CGFloat = 30
        let progressHeight:CGFloat = 140
        
        mainView.frame = mainViewFrame
        chatListView.frame = chatListViewFrame
        topBar.frame = CGRect(x: 0,
                              y: 0,
                              width: size.width,
                              height: 44 + iphoneXTop)
        volumeProgressView.frame = CGRect(x: mainViewFrame.maxX - progressWidth - normalMargin,
                                          y: mainViewFrame.midY - progressHeight * 0.5,
                                          width: progressWidth,
                                          height: progressHeight)
        brightnessProgressView.frame = CGRect(x: mainViewFrame.minX + normalMargin,
                                              y: mainViewFrame.midY - progressHeight * 0.5,
                                              width: progressWidth,
                                              height: progressHeight)
        roomControlbar.frame = roomControlbarFrame
        scrollContainer.frame = scrollContainerFrame
        videoTipView.frame = mainView.bounds
        netTipView.frame = mainView.bounds
        settingView.frame = largePopViewFrame
    }
    
    func updatePortraitFrame() {
        let size = view.bounds.size
        let largePopViewHeight = size.height * 0.5
        mainViewFrame = CGRect(x: 0,
                               y: iphoneXTop,
                               width: size.width,
                               height: size.width * 0.56)
        roomControlbarFrame = CGRect(x: 0,
                                     y: mainViewFrame.maxY,
                                     width: mainViewFrame.width,
                                     height: roomControlbarHeight)
        largePopViewFrame = CGRect(x: 0,
                                   y: largePopViewHeight,
                                   width: size.width,
                                   height: largePopViewHeight)
        bottomBar.frame = CGRect(x: 0,
                                 y: mainViewFrame.maxY - 44,
                                 width: size.width,
                                 height: 44)
    }
    func updateLandscapeFrame() {
        let size = view.bounds.size
        let largePopViewWidth = size.width * 0.4
        let const_scale:CGFloat = 16/9.0
        let scale:CGFloat = size.width/size.height
        var largeViewW = size.width
        var largeViewH = size.height
        if scale > const_scale {
            largeViewW = size.height * const_scale
            largeViewH = size.height
        }else {
            largeViewW = size.width
            largeViewH = size.width / const_scale
        }
        mainViewFrame = CGRect(x: (size.width - largeViewW) * 0.5,
                                y: (size.height - largeViewH) * 0.5,
                                width: largeViewW,
                                height: largeViewH)
        largePopViewFrame = CGRect(x: size.width - largePopViewWidth,
                                   y: 0,
                                   width: largePopViewWidth,
                                   height: size.height)
        bottomBar.frame = CGRect(x: 0,
                                 y: size.height - 78,
                                 width: size.width,
                                 height: 78)
    }
    
    func startHiddenTimer() {
        let date:Date = Date(timeIntervalSinceNow: 5)
        voiceTimer = Timer(fireAt: date,
                           interval: 0,
                           target: self,
                           selector: #selector(hiddenControlBar),
                           userInfo: nil,
                           repeats: false)
        RunLoop.current.add(voiceTimer!,
                            forMode: RunLoop.Mode.default)
    }
    func stopHiddenTimer() {
        voiceTimer?.invalidate()
        voiceTimer = nil
    }
    func showSettingView() {
        UIView.animate(withDuration: 0.25) {
            self.settingView.isHidden = false
            self.settingView.frame = self.largePopViewFrame
        }
    }
    func hiddenSettingView() {
        let size = view.bounds.size
        var rect:CGRect = .zero
        if isPortrait() {
            rect = CGRect(x: 0, y: size.height, width: size.width, height: 0)
        }
        if isLandscape() {
            rect = CGRect(x: size.width, y: 0, width: 0, height: size.height)
        }
        UIView.animate(withDuration: 0.25) {
            self.settingView.isHidden = true
            self.settingView.frame = rect
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
    func showVideoTipView() {
        mainView.addSubview(videoTipView)
    }
    func hiddenVideoTipView() {
        videoTipView.removeFromSuperview()
    }
    func changeVolume(value: CGFloat) {
        DBYSystemControl.shared.setVolume(value: volume + Float(value))
        volumeProgressView.setProgress(value: CGFloat(volume) + value)
    }
    func changeLight(value: CGFloat) {
        DBYSystemControl.shared.setBrightness(value: brightness + value)
        brightnessProgressView.setProgress(value: brightness + value)
    }
    func createVideoView(uid: String) -> DBYStudentVideoView {
        let videoView = DBYStudentVideoView()
        videoView.userId = uid
        videoDict[uid] = videoView
        view.addSubview(videoView)
        videoView.frame = CGRect(x: mainViewFrame.minX, y: mainViewFrame.maxY, width: 170, height: 150)
        let drag = UIPanGestureRecognizer(target: self,
                                          action: #selector(dragVideoView(pan:)))
        let pinch = UIPinchGestureRecognizer(target: self,
                                             action: #selector(scaleVideoView(pinch:)))
        
        videoView.addGestureRecognizer(drag)
        videoView.addGestureRecognizer(pinch)
        
        return videoView
    }
    func adjustVideoViewFrame(videoView: UIView?) {
        let viewW = view.bounds.width
        let halfW = viewW * 0.5
        var rect = videoView?.frame ?? .zero
        if rect.midX < 0 || rect.midX <= halfW {
            rect.origin.x = 0
        }
        if rect.midX > halfW {
            rect.origin.x = viewW - rect.width
        }
        UIView.animate(withDuration: 0.25) {
            videoView?.frame = rect
        }
    }
    //MARK: - objc functions
    @objc func volumeChange(notification:Notification) {
        if let volume = notification.object as? CGFloat {
            volumeProgressView.setProgress(value: volume)
            print("---\(volume)")
        }
    }
    @objc func scaleVideoView(pinch:UIPinchGestureRecognizer) {
        let scale = pinch.scale
        
        let videoView = pinch.view
        
        if pinch.state == .began {
            videoView?.transform = originTransform
        }
        if pinch.state == .changed {
            let transform = originTransform.scaledBy(x: scale, y: scale)
            let scaleX = transform.a
            if scaleX < 2.0 && scaleX > 1.0 {
                videoView?.transform = transform
            }
        }
        if pinch.state == .ended {
            originTransform = videoView!.transform
            adjustVideoViewFrame(videoView: videoView)
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
    @objc func gestureControl(pan:UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            beganPosition = pan.location(in: mainView)
            brightness = DBYSystemControl.shared.getBrightness()
            volume = DBYSystemControl.shared.getVolume()
        case .changed:
            let position = pan.location(in: mainView)
            let offsetY = beganPosition.y - position.y
            let offsetX = beganPosition.x - position.x
            if abs(offsetX) > abs(offsetY) {
                return
            }
            let progress = offsetY / mainViewFrame.height
            if position.x > mainViewFrame.width * 0.5 {
                changeVolume(value: progress)
            }else {
                changeLight(value: progress)
            }
        default:
            break
        }
    }
    @objc func oneTap(tap:UITapGestureRecognizer) {
        hiddenSettingView()
        
        if controlBarIsHidden {
            showControlBar()
        }else {
            hiddenControlBar()
        }
    }
    
    @objc func hiddenControlBar() {
        topBar.isHidden = true
        bottomBar.isHidden = true
        controlBarIsHidden = true
        setNeedsStatusBarAppearanceUpdate()
        stopHiddenTimer()
    }
    
    @objc func showControlBar() {
        topBar.isHidden = false
        bottomBar.isHidden = false
        controlBarIsHidden = false
        setNeedsStatusBarAppearanceUpdate()
        stopHiddenTimer()
        startHiddenTimer()
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
extension DBY1VNController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == scrollContainer {
            let index = Int(scrollView.contentOffset.x / scrollContainerFrame.width)
            roomControlbar.scroll(at: index)
        }
    }
}
extension DBY1VNController: DBYRoomControlbarDelegate {
    func roomControlBar(owner: DBYRoomControlbar, stateWillChange state: DBYRoomControlbar.CameraState) {
        if state == .normal {
            requestOpenCamera()
        }
        if state == .invite {
            cancelOpenCamera()
        }
        if state == .joined {
            closeCamera()
        }
    }
    
    func roomControlBarDidSelected(owner: DBYRoomControlbar, index: Int) {
        scrollContainer.scroll(at: index)
    }
}
