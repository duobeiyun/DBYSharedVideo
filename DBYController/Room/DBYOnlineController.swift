//
//  DBYOnlineController.swift
//  DBY1VNUI
//
//  Created by 钟凡 on 2019/1/3.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit
import MediaPlayer
import DBYSDK_dylib

public class DBYOnlineController: DBYPlaybackController {
    var roomConfig: DBYRoomConfig?
    lazy var playbackManager:DBYOnlinePlayBackManager = DBYOnlinePlayBackManager()
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
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        topBar.delegate = self
        bottomBar.delegate = self
        settingView.delegate = self
        
        weak var weakSelf = self
        
        if authinfo?.classType == .sharedVideo {
            playbackManager.setSharedVideoView(mainView.videoView)
        }else {
            playbackManager.setTeacherViewWith(mainView.videoView)
        }
        playbackManager.delegate = self
        playbackManager.setPPTViewBackgroundImage(UIImage(name: "black-board"))
        playbackManager.startPlayback(with: authinfo, seekTime: 0) { (message, type) in
            if message != nil {
                DBYGlobalMessage.shared().showText(message!)
            }
            var items = [DBYSettingItem]()
            let count = weakSelf?.playbackManager.linesCount() ?? 0
            for i in 0..<count {
                items.append(DBYSettingItem(name: "线路\(i)"))
            }
            weakSelf?.settingView.models[2].items = items
            weakSelf?.settingView.collectionView.reloadData()
        }
        
        if let reachability = internetReachability {
            dealWith(reachability: reachability)
        }
        setupRemoteTransportControls()
        becomeFirstResponder()
        
        addObserver()
        
        guard let roomId = authinfo?.roomID else {
            return;
        }
        
        DBYRoomConfigUtil.shared.getRoomConfig(roomId: roomId) { (roomConfig) in
            self.roomConfig = roomConfig
        }
    }
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackManager.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playbackManager.totalTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackManager.isPlaying ? 1.0 : 0.0
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [weak self] event in
            if let playing = self?.playbackManager.isPlaying, playing {
                self?.playbackManager.pausePlay()
                return .success
            }
            return .commandFailed
        }
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [weak self] event in
           if self?.playbackManager.isPlaying == false {
                self?.playbackManager.resumePlay()
                return .success
            }
            return .commandFailed
        }
    }
    override func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recoverApi),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pauseApi),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    override func initSubViews() {
        settingView = DBYSettingViewOnlineFactory.create()
    }
    override public func addSubviews() {
        super.addSubviews()
    }
    override func addActions() {
        playbackBtn.addTarget(self, action: #selector(playbackEnable), for: .touchUpInside)
    }
    func registerBlocks() {
        
    }
    override func setupStaticUI() {
        super.setupStaticUI()
        chatListView.chatBar.isHidden = true
    }
    override func setupLandscapeUI() {
        super.setupLandscapeUI()
        topBar.set(type: .landscape)
    }
    override func setupPortraitUI() {
        super.setupPortraitUI()
        topBar.set(type: .portrait)
    }
    
    override func reachabilityChanged(note:NSNotification) {
        if let reachability = note.object as? DBYReachability {
            dealWith(reachability: reachability)
        }
    }
    
    //MARK: - private functions
    func dealWith(reachability: DBYReachability) {
        let netStatus = reachability.currentReachabilityStatus()
        switch netStatus{
        case NotReachable:
            break
        case ReachableViaWWAN:
            mainView.addSubview(netTipView)
            playbackManager.pausePlay()
            break
        case ReachableViaWiFi:
            mainView.hiddenNetworkTipView()
            playbackManager.resumePlay()
            break
        default:
            break
        }
    }
    override func goBack() {
        if isPortrait() {
            playbackManager.stopPlay { (code, message) in
                print("code:\(code), message:\(message ?? "")")
                super.goBack()
            }
        }else {
            toPortrait()
        }
    }
    override func settingClick() {
        super.settingClick()
    }
    func clearChatMessage() {
        chatListView.clearAll()
    }
    @objc func pauseApi() {
        if playbackBtn.isSelected {
            return
        }
        playbackManager.pauseApi()
    }
    @objc func recoverApi() {
        if playbackBtn.isSelected {
            return
        }
        playbackManager.resumeApi()
    }
    func pauseManager() {
        playbackManager.pausePlay()
    }
    func recoverManager() {
        playbackManager.resumePlay()
    }
}
extension DBYOnlineController:DBYOnlinePlayBackManagerDelegate {
    public func playBackManager(_ manager: DBYOnlinePlayBackManager!, onlineWithuserId uid: String!, nickName: String!, userRole role: Int32) {
        if role == 1 {
            courseInfoView.setTeacherName(name: nickName)
        }
    }
    public func playBackManager(_ manager: DBYOnlinePlayBackManager!, thumbupWithCount count: Int) {
        courseInfoView.setThumbCount(count: count)
    }
    public func playbackManager(_ manager: DBYOnlinePlayBackManager!, playStateChange isPlaying: Bool) {
        if isPlaying {
            bottomBar.set(state: .play)
        }else {
            bottomBar.set(state: .pause)
        }
    }
    public func playbackManager(_ manager: DBYOnlinePlayBackManager!, hasNewChatMessageWithChatArray newChatDictArray: [Any]!) {
        if let chatDicts = newChatDictArray as? [[String:Any]] {
            chatListView.appendChats(array: chatDicts)
        }
    }
    
    public func playBackManagerChatMessageShouldClear(_ manager: DBYOnlinePlayBackManager!) {
        chatListView.clearAll()
    }
    public func playBackManager(_ manager: DBYOnlinePlayBackManager!, totalTime time: TimeInterval) {
        bottomBar.set(totalTime: time)
    }
    public func playBackManager(_ manager: DBYOnlinePlayBackManager!, playedAtTime time: TimeInterval) {
        setupNowPlaying()
        if beginInteractive {
            return
        }
        bottomBar.set(time: time)
    }
    public func playbackManagerDidPlayEnd(_ manager: DBYOnlinePlayBackManager!) {
        bottomBar.set(state: .end)
    }
    public func playbackManager(_ manager: DBYOnlinePlayBackManager!, hasVideo: Bool, in view: UIView!) {
        
    }
}
extension DBYOnlineController:DBYNetworkTipViewDelegate {
    func confirmClick(_ owner: DBYNetworkTipView) {
        mainView.hiddenNetworkTipView()
        playbackManager.resumePlay()
    }
}
//MARK: - DBYTopBarDelegate
extension DBYOnlineController: DBYTopBarDelegate {
    func backButtonClick(owner: DBYTopBar) {
        goBack()
    }
    
    func settingButtonClick(owner: DBYTopBar) {
        settingClick()
    }
}
//MARK: - DBYBottomBarDelegate
extension DBYOnlineController: DBYBottomBarDelegate {
    func chatButtonClick(owner: DBYBottomBar) {
        topBar.isHidden = true
        bottomBar.isHidden = true
        segmentedView.isHidden = false
        segmentedView.scrollToIndex(index: 0, animated: false)
    }
    
    func voteButtonClick(owner: DBYBottomBar) {
        
    }
    
    func fullscreenButtonClick(owner: DBYBottomBar) {
        toLandscape()
    }
    
    func playStateDidChange(owner: DBYBottomBar, state: DBYPlayState) {
        if state == .pause {
            recoverManager()
            mainView.showVideoTipView(type: .audio, delegate: self)
        }
        if state == .play {
            pauseManager()
            mainView.showVideoTipView(type: .pause, delegate: self)
        }
        if state == .end {
            recoverManager()
        }
    }
    func progressWillChange(owner: DBYBottomBar, value: Float) {
        mainView.stopTimer()
    }
    func progressDidChange(owner: DBYBottomBar, value: Float) {
        beginInteractive = true
        timeTipLab.isHidden = false
        timeTipLab.text = String.playTime(time:Int(value))
        timeTipLab.sizeToFit()
        bottomBar.set(time: TimeInterval(value))
    }
    
    func progressEndChange(owner: DBYBottomBar, value: Float) {
        mainView.startTimer()
        beginInteractive = false
        timeTipLab.isHidden = true
        
        mainView.showLoadingView(delegate: nil)
        playbackManager.seekToTime(with: TimeInterval(value), completeHandler: { [weak self] message in
            if let msg = message {
                DBYGlobalMessage.shared().showText(msg)
            }
            self?.mainView.hiddenLoadingView()
            self?.bottomBar.set(state: .play)
        })
    }
}
extension DBYOnlineController: DBYSettingViewDelegate {
    func settingView(owner: DBYSettingView, didSelectedItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        }
        if indexPath.section == 1 {
            let playRate = playRates[indexPath.item]
            playbackManager.setPlaySpeedWith(playRate) { (isFinished) in
                
            }
        }
        if indexPath.section == 2 {
            playbackManager.changePlaybackLine(with: Int32(indexPath.item)) { (message) in
                
            }
        }
    }
}
extension DBYOnlineController: DBYVideoTipViewDelegate {
    func continueClick(_ owner: DBYPauseTipView) {
        
    }
    
}
