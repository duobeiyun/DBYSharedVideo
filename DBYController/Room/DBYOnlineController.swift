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
    
    //MARK: - override functions
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        netTipView.delegate = self
        mainView.topBarDelegate = self
        mainView.bottomBarDelegate = self
        settingView.delegate = self
        
        weak var weakSelf = self
        
        if authinfo?.classType == .sharedVideo {
            playbackManager.setSharedVideoView(mainView)
        }else {
            playbackManager.setTeacherViewWith(mainView)
        }
        playbackManager.delegate = self
        playbackManager.setPPTViewBackgroundImage(UIImage(name: "black-board"))
        playbackManager.startPlayback(with: authinfo, seekTime: 0) { (message, type) in
            if message != nil {
                DBYGlobalMessage.shared().showText(message!)
            }
            var lines = [String]()
            let count = weakSelf?.playbackManager.linesCount() ?? 0
            for i in 0..<count {
                lines.append("线路\(i)")
            }
            weakSelf?.settingView.set(lines: lines)
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
    override public func addSubviews() {
        super.addSubviews()
    }
    func registerBlocks() {
        
    }
    override func setupStaticUI() {
        super.setupStaticUI()
        settingView.set(buttons: [playbackBtn])
    }
    override func setupLandscapeUI() {
        super.setupLandscapeUI()
        mainView.topBar.set(type: .landscape)
    }
    override func setupPortraitUI() {
        super.setupPortraitUI()
        mainView.topBar.set(type: .portrait)
    }
    override func setViewStyle() {
        super.setViewStyle()
        
    }
    
    override func reachabilityChanged(note:NSNotification) {
        if let reachability = note.object as? DBYReachability {
            dealWith(reachability: reachability)
        }
    }
    
    override func changeProgress(value: CGFloat) {
        super.changeProgress(value: value)
        
    }
    override func changeEnded() {
        super.changeEnded()
        
        playbackManager.seekToTime(with: mainView.bottomBar.currentValue, completeHandler: {message in
            self.mainView.videoView.stopLoading()
        })
    }
    //MARK: - private functions
    func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recoverApi),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pauseApi),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
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
            netTipView.hidden()
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
        cellHeightCache.removeAll()
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
            mainView.bottomBar.set(state: .play)
        }else {
            mainView.bottomBar.set(state: .pause)
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
        mainView.bottomBar.set(totalTime: time)
    }
    public func playBackManager(_ manager: DBYOnlinePlayBackManager!, playedAtTime time: TimeInterval) {
        setupNowPlaying()
        if beginInteractive {
            return
        }
        mainView.bottomBar.set(time: time)
    }
    public func playbackManagerDidPlayEnd(_ manager: DBYOnlinePlayBackManager!) {
        mainView.bottomBar.set(state: .end)
    }
    public func playbackManager(_ manager: DBYOnlinePlayBackManager!, hasVideo: Bool, in view: UIView!) {
        
    }
}
extension DBYOnlineController:DBYNetworkTipViewDelegate {
    func confirmClick(_ owner: DBYNibView) {
        netTipView.hidden()
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
        
    }
    
    func voteButtonClick(owner: DBYBottomBar) {
        
    }
    
    func fullscreenButtonClick(owner: DBYBottomBar) {
        toLandscape()
    }
    
    func stateDidChange(owner: DBYBottomBar, state: DBYPlayState) {
        if state == .pause {
            recoverManager()
            videoTipView.set(type: .audio)
        }
        if state == .play {
            pauseManager()
            videoTipView.set(type: .pause)
        }
        if state == .end {
            recoverManager()
        }
    }
    
    func progressDidChange(owner: DBYBottomBar, value: Float) {
        mainView.stopHiddenTimer()
        beginInteractive = true
        timeTipLab.isHidden = false
        timeTipLab.text = String.playTime(time:Int(value))
        timeTipLab.sizeToFit()
        mainView.bottomBar.set(time: TimeInterval(value))
    }
    
    func progressEndChange(owner: DBYBottomBar, value: Float) {
        mainView.startHiddenTimer()
        beginInteractive = false
        timeTipLab.isHidden = true
        
        mainView.videoView.startLoading()
        playbackManager.seekToTime(with: TimeInterval(value), completeHandler: { message in
            if let msg = message {
                DBYGlobalMessage.shared().showText(msg)
            }
            self.mainView.videoView.stopLoading()
            self.mainView.bottomBar.set(state: .play)
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
            weak var weakSelf = self
            playbackManager.changePlaybackLine(with: Int32(indexPath.item)) { (message) in
                weakSelf?.settingView.set(speeds: weakSelf?.playRateTitles ?? [])
            }
        }
    }
}
