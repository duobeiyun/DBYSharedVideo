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
    let fromIdentifier: String = "DBYCommentFromCell"
    let toIdentifier: String = "DBYCommentToCell"
    let zanCell = "DBYZanCell"
    var originTransform:CGAffineTransform = CGAffineTransform(scaleX: 1, y: 1)
    
    @objc public var authinfo: DBYAuthInfo?
    
    var chatListViewFrame: CGRect = .zero
    var smallPopViewFrame: CGRect = .zero
    var largePopViewFrame: CGRect = .zero
    
    var isLoading: Bool = false
    var isStoping: Bool = false
    
    lazy var videoDict = [String: DBYStudentVideoView]()
    
    lazy var mainView = DBYMainView()
    lazy var chatContainer = DBYChatContainer()
    lazy var courseInfoView = DBYCourseInfoView()
    lazy var videoTipView = DBYVideoTipView()
    lazy var segmentedView = DBYSegmentedView()
    
    lazy var settingView = DBYSettingView()
    lazy var chatListView = DBYChatListView()
    
    lazy var netTipView = DBYNetworkTipView()
    lazy var internetReachability = DBYReachability.forInternetConnection()
    
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
        return mainView.controlBarIsHidden
    }
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        mainView.startHiddenTimer()
        DBYSystemControl.shared.beginControl()
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainView.stopHiddenTimer()
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
        mainView.delegate = self
        addSubviews()
        setViewStyle()
        addActions()
        setupOrientationUI()
        setViewStyle()
        setupStaticUI()
        internetReachability?.startNotifier()
    }
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.zf_layoutSubviews()
    }
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        mainView.startHiddenTimer()
        weak var weakSelf = self
        coordinator.animate(alongsideTransition: { (context) in
            weakSelf?.setupOrientationUI()
            weakSelf?.chatListView.reloadData()
        }) { (context) in

        }
    }
    deinit {
        print("---deinit", type(of: self))
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - private functions
    func addSubviews() {
        view.addSubview(mainView)
        view.addSubview(segmentedView)
        view.addSubview(settingView)
    }
    func addActions() {
        playbackBtn.addTarget(self, action: #selector(playbackEnable), for: .touchUpInside)
    }
    func setupStaticUI() {
        view.backgroundColor = UIColor.white
        
        chatContainer.backgroundColor = UIColor.clear
        mainView.backgroundColor = UIColor.white
        segmentedView.barColor = DBYStyle.yellow
        segmentedView.hilightColor = DBYStyle.darkGray
        segmentedView.defaultColor = DBYStyle.middleGray
        
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
    }
    func setupLandscapeUI() {
    }
    func setupIphoneX() -> UIEdgeInsets {
        var iphoneXTop:CGFloat = 20
        var iphoneXLeft:CGFloat = 0
        var iphoneXRight:CGFloat = 0
        var iphoneXBottom:CGFloat = 0
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
        return UIEdgeInsets(top: iphoneXTop, left: iphoneXLeft, bottom: iphoneXBottom, right: iphoneXRight)
    }
    func setViewStyle() {
        let edge = setupIphoneX()
        
        let size = UIScreen.main.bounds.size
        let videoHeight = size.width * 0.5625
        let segmentedViewMinX = videoHeight + edge.top
        let segmentedViewHeight = size.height - segmentedViewMinX
        mainView.portraitFrame = CGRect(x: 0, y: edge.top, width: size.width, height: videoHeight)
        mainView.landscapeFrame = CGRect(x: edge.left, y: 0, width: size.height - edge.right, height: size.width)
        segmentedView.portraitFrame = CGRect(x: 0, y: segmentedViewMinX, width: size.width, height: segmentedViewHeight)
        segmentedView.landscapeFrame = CGRect(x: size.height - size.width - edge.right, y: -44, width: size.width, height: size.width + 44)
        
        chatListView.setBackgroundColor(color: DBYStyle.lightGray, forState: .portrait)
        chatListView.setBackgroundColor(color: DBYStyle.lightAlpha, forState: .landscape)
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
    
    func createVideoView(uid: String) -> DBYStudentVideoView {
        let videoView = DBYStudentVideoView()
        videoView.userId = uid
        videoDict[uid] = videoView
        view.addSubview(videoView)
        videoView.portraitFrame = CGRect(x: mainView.frame.minX, y: mainView.frame.maxY, width: 170, height: 150)
        videoView.landscapeFrame = CGRect(x: mainView.frame.minX, y: 0, width: 170, height: 150)
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
    
    func tapGesture(owner: DBYMainView, isSelected: Bool) {
        
    }
    
    func willHiddenControlBar(owner: DBYMainView) {
        if isPortrait() {
            return
        }
        segmentedView.isHidden = true
    }
    func willShowControlBar(owner: DBYMainView) {
        if isPortrait() {
            return
        }
        segmentedView.isHidden = false
    }
}
