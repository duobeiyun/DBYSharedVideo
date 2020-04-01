//
//  DBYOfflineController.swift
//  DBY1VNUI
//
//  Created by 钟凡 on 2019/1/3.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit
import DBYSDK_dylib

public class DBYOfflineController: DBYPlaybackController {
    
    @objc public var roomID:String?
    @objc public var offlineKey:String?
    @objc public var classFilePath:String?
    @objc public var hasVideo:Bool = false
    
    lazy var offlineManager = DBYOfflinePlayBackManager()
    var chatInfoList:[DBYChatEventInfo] = [DBYChatEventInfo]()
    
    //MARK: - override functions
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        unowned let weakSelf = self
        
        chatListView.delegate = self
        chatListView.dataSource = self
        topBar.delegate = self
        bottomBar.delegate = self
        settingView.delegate = self
        
        if authinfo?.classType == .sharedVideo {
            offlineManager.setSharedVideoView(mainView)
        }else {
            offlineManager.setTeacherViewWith(mainView)
        }
        offlineManager.setStudentViewWith(UIView())
        offlineManager.delegate = self
        offlineManager.setPPTViewBackgroundImage(UIImage(name: "black-board"))
        offlineManager.roomID = roomID
        offlineManager.classFilePath = classFilePath
        offlineManager.offlineKey = offlineKey
        
        offlineManager.startPlayback(withRoomID: roomID, filePath: classFilePath) { (code, message) in
            if code != 0 {
                DBYGlobalMessage.shared().showText(message!)
                return
            }
            let totalTime = weakSelf.offlineManager.lessonLength()
            weakSelf.bottomBar.set(totalTime: totalTime)
            weakSelf.offlineManager.seek(toTime: 10)
        }
    }
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func setupStaticUI() {
        super.setupStaticUI()
        topBar.set(title)
        courseInfoView.set(title: title)
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
    override func goBack() {
        if isPortrait() {
            offlineManager.stop()
            super.goBack()
        }else {
            toPortrait()
        }
    }
    override func changeProgress(value: CGFloat) {
        super.changeProgress(value: value)
    }
    override func changeEnded() {
        super.changeEnded()
        offlineManager.seek(toTime: bottomBar.currentValue)
        indicator.stopAnimating()
    }
}
//MARK: - private functions
extension DBYOfflineController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - tableView
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = chatInfoList.count
        if count > 0 {
            chatListView.backgroundView = nil
        }else {
            let chatTipView = DBYTipView(image: UIImage(name: "icon-empty-status-1"), message: "聊天消息为空")
            chatListView.backgroundView = chatTipView
        }
        return chatInfoList.count
    }
   public  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension //固定值
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:DBYCommentCell = DBYCommentCell()
        
        if chatInfoList.count <= indexPath.row {
            return cell
        }
        let chatInfo = chatInfoList[indexPath.row]
        
        let role:Int = Int(chatInfo.role)
        let isOwner:Bool = false
        let name:String = chatInfo.userName
        let time:String? = Date(timeIntervalSince1970: chatInfo.recordTime).shortString()
        let message:String = chatInfo.message
        
        if isOwner {
            cell = tableView.dequeueReusableCell(withIdentifier: toIdentifier) as! DBYCommentCell
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: fromIdentifier) as! DBYCommentCell
        }
        let avatarUrl = ""
        let badge:(String?, String?) = (nil, nil)
        let width = cell.bounds.width - 100
        let attMessage = beautifyMessage(message: message, maxWidth: width)
        cell.setText(name: name,
                     message: attMessage,
                     avatarUrl: avatarUrl,
                     badge: badge)
        
        return cell
    }
}
extension DBYOfflineController: DBYOfflinePlayBackManagerDelegate {
    public func offlinePlayBackManager(_ manager: DBYOfflinePlayBackManager!, thumbupWithCount count: Int) {
        courseInfoView.setThumbCount(count: count)
    }
    public func offlinePlayBackManager(_ manager: DBYOfflinePlayBackManager!, playStateIsPlaying isPlaying: Bool) {
        if isPlaying {
            bottomBar.set(state: .play)
        }else {
            bottomBar.set(state: .pause)
        }
    }
    public func offlinePlayBackManager(_ manager: DBYOfflinePlayBackManager!, hasVideo: Bool, in view: UIView!) {
        
    }
    public func offlinePlayBackManager(_ manager: DBYOfflinePlayBackManager!, hasNewChatMessageWithChatArray newChatDictArray: [Any]!) {
        if let chatDicts = newChatDictArray as? [DBYChatEventInfo] {
            chatInfoList += chatDicts
            let maxCount = chatInfoList.count - 1000
            if maxCount > 0 {
                for _ in 0..<maxCount {
                    chatInfoList.removeFirst()
                }
            }
            let count = chatInfoList.count
            chatListView.reloadData()
            if count > 0 {
                chatListView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .none, animated: true)
            }
        }
    }
    
    public func offlinePlayBackManagerChatMessageShouldClear(_ manager: DBYOfflinePlayBackManager!) {
        chatInfoList.removeAll()
        chatListView.reloadData()
    }
    public func offlinePlayBackManager(_ manager: DBYOfflinePlayBackManager!, isPlayingAtProgress progress: Float, time: TimeInterval) {
        if beginInteractive {
            return
        }
        bottomBar.set(time: time)
    }
    public func offlinePlayBackManagerFinishedPlay(_ manager: DBYOfflinePlayBackManager!) {
        bottomBar.set(time: 0)
        bottomBar.set(state: .end)
    }
}
//MARK: - DBYTopBarDelegate
extension DBYOfflineController: DBYTopBarDelegate {
    func backButtonClick(owner: DBYTopBar) {
        goBack()
    }
    
    func settingButtonClick(owner: DBYTopBar) {
        settingClick()
    }
}
//MARK: - DBYBottomBarDelegate
extension DBYOfflineController: DBYBottomBarDelegate {
    func chatButtonClick(owner: DBYBottomBar) {
        
    }
    
    func voteButtonClick(owner: DBYBottomBar) {
        
    }
    
    func fullscreenButtonClick(owner: DBYBottomBar) {
        toLandscape()
    }
    
    func stateDidChange(owner: DBYBottomBar, state: DBYPlayState) {
        if state == .play {
            offlineManager.pause()
        }
        if state == .pause {
            videoTipView.set(title: "点击播放", message: "已暂停播放", icon: "video-tip")
            offlineManager.resume()
        }
        if state == .end {
            offlineManager.play()
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
        offlineManager.seek(toTime: TimeInterval(value))
        indicator.stopAnimating()
    }
}
//MARK: - DBYSettingViewDelegate
extension DBYOfflineController: DBYSettingViewDelegate {
    func settingView(owner: DBYSettingView, didSelectedItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let playRate = playRates[indexPath.item]
            offlineManager.setPlayRate(playRate)
        }
    }
}
