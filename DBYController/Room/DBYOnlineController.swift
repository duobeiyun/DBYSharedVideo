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
        
        chatListView.delegate = self
        chatListView.dataSource = self
        netTipView.delegate = self
        topBar.delegate = self
        bottomBar.delegate = self
        settingView.delegate = self
        
        unowned let weakSelf = self
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
            for i in 0..<weakSelf.playbackManager.linesCount() {
                lines.append("线路\(i)")
            }
            weakSelf.settingView.set(lines: lines)
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
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.playbackManager.isPlaying {
                self.playbackManager.pausePlay()
                return .success
            }
            return .commandFailed
        }
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
           if self.playbackManager.isPlaying == false {
                self.playbackManager.resumePlay()
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
        
    }
    override func setupPortraitUI() {
        super.setupPortraitUI()
        
    }
    override func updateFrame() {
        super.updateFrame()
        
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
        
        playbackManager.seekToTime(with: bottomBar.currentValue, completeHandler: {message in
            self.indicator.stopAnimating()
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
            }
            super.goBack()
        }else {
            toPortrait()
        }
    }
    override func settingClick() {
        super.settingClick()
    }
    func clearChatMessage() {
        cellHeightCache.removeAll()
        allChatList.removeAll()
        DispatchQueue.main.async {
            self.chatListView.reloadData()
        }
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
extension DBYOnlineController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - tableView
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = allChatList.count
        if count > 0 {
            chatListView.backgroundView = nil
        }else {
            let chatTipView = DBYTipView(image: UIImage(name: "icon-empty-status-1"), message: "聊天消息为空")
            chatListView.backgroundView = chatTipView
        }
        return count
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension //固定值
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:DBYCommentCell = DBYCommentCell()
        
        let chatList = allChatList
        if chatList.count <= indexPath.row {
            return cell
        }
        let chatDict = chatList[indexPath.row]
        
        let role:Int = chatDict["role"] as? Int ?? 0
        let isOwner:Bool = chatDict["isOwner"] as? Bool ?? false
        let name:String = chatDict["userName"] as? String ?? ""
        let message:String = chatDict["message"] as? String ?? ""
        
        if isOwner {
            cell = tableView.dequeueReusableCell(withIdentifier: toIdentifier) as! DBYCommentCell
            if isPortrait() {
                cell.setBubbleImage(UIImage(name: "chat-to-bubble"))
            }else {
                cell.setBubbleImage(UIImage(name: "chat-to-dark-bubble"))
            }
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: fromIdentifier) as! DBYCommentCell
            if isPortrait() {
                cell.setBubbleImage(UIImage(name: "chat-from-bubble"))
            }else {
                cell.setBubbleImage(UIImage(name: "chat-from-dark-bubble"))
            }
        }
        if isPortrait() {
            cell.setTextColor(DBYStyle.dark)
        }else {
            cell.setTextColor(UIColor.white)
        }
        let avatarUrl = DBYUrlConfig.shared().staticUrl(withSourceName: roomConfig?.avatar ?? "")
        let badge = badgeUrl(role: role, badgeDict: roomConfig?.badge)
        let width = cell.bounds.width - 100
        
        let attMessage = beautifyMessage(message: message, maxWidth: width)
        cell.setText(name: name,
                     message: attMessage,
                     avatarUrl: avatarUrl,
                     badge: badge)
        
        return cell
    }
}
extension DBYOnlineController:DBYOnlinePlayBackManagerDelegate {
    public func playbackManager(_ manager: DBYOnlinePlayBackManager!, playStateChange isPlaying: Bool) {
        if isPlaying {
            bottomBar.set(state: .play)
        }else {
            bottomBar.set(state: .pause)
        }
    }
    public func playbackManager(_ manager: DBYOnlinePlayBackManager!, hasNewChatMessageWithChatArray newChatDictArray: [Any]!) {
        if let chatDicts = newChatDictArray as? [[String:Any]] {
            allChatList += chatDicts
            let maxCount = allChatList.count - 1000
            if maxCount > 0 {
                for _ in 0..<maxCount {
                    allChatList.removeFirst()
                }
            }
            let count = self.allChatList.count
            self.chatListView.reloadData()
            if count > 0 {
                self.chatListView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .none, animated: true)
            }
        }
    }
    
    public func playBackManagerChatMessageShouldClear(_ manager: DBYOnlinePlayBackManager!) {
        allChatList.removeAll()
        DispatchQueue.main.async {
            self.chatListView.reloadData()
        }
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
extension DBYOnlineController: DBYRoomControlbarDelegate {
    func roomControlBarDidClickCameraRequest(owner: DBYRoomControlbar) {
        
    }
    
    func roomControlBarDidSelected(owner: DBYRoomControlbar, index: Int) {
        scrollContainer.scroll(at: index)
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
        stopHiddenTimer()
        beginInteractive = true
        timeTipLab.isHidden = false
        timeTipLab.text = String.playTime(time:Int(value))
        timeTipLab.sizeToFit()
        bottomBar.set(time: TimeInterval(value))
    }
    
    func progressEndChange(owner: DBYBottomBar, value: Float) {
        startHiddenTimer()
        beginInteractive = false
        timeTipLab.isHidden = true
        indicator.isHidden = false
        indicator.startAnimating()
        playbackManager.seekToTime(with: TimeInterval(value), completeHandler: { message in
            if let msg = message {
                DBYGlobalMessage.shared().showText(msg)
            }
            self.indicator.stopAnimating()
            self.bottomBar.set(state: .play)
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
            unowned let weakSelf = self
            playbackManager.changePlaybackLine(with: Int32(indexPath.item)) { (message) in
                weakSelf.settingView.set(speeds: weakSelf.playRateTitles)
            }
        }
    }
}
