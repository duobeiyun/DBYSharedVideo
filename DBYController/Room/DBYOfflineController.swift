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
    
    //MARK: - override functions
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        weak var weakSelf = self
        
        settingView.delegate = self
        mainView.topBarDelegate = self
        mainView.bottomBarDelegate = self
        
        if authinfo?.classType == .sharedVideo {
            offlineManager.setSharedVideoView(mainView.videoView)
        }else {
            offlineManager.setTeacherViewWith(mainView.videoView)
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
            let totalTime = weakSelf?.offlineManager.lessonLength() ?? 0
            weakSelf?.mainView.bottomBar.set(totalTime: totalTime)
            weakSelf?.offlineManager.seek(toTime: 10)
        }
    }
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func setupStaticUI() {
        super.setupStaticUI()
        mainView.topBar.set(title)
        courseInfoView.set(title: title)
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
        offlineManager.seek(toTime: mainView.bottomBar.currentValue)
        indicator.stopAnimating()
    }
}
//MARK: - private functions
extension DBYOfflineController: DBYOfflinePlayBackManagerDelegate {
    public func offlinePlayBackManager(_ manager: DBYOfflinePlayBackManager!, thumbupWithCount count: Int) {
        courseInfoView.setThumbCount(count: count)
    }
    public func offlinePlayBackManager(_ manager: DBYOfflinePlayBackManager!, playStateIsPlaying isPlaying: Bool) {
        if isPlaying {
            mainView.bottomBar.set(state: .play)
        }else {
            mainView.bottomBar.set(state: .pause)
        }
    }
    public func offlinePlayBackManager(_ manager: DBYOfflinePlayBackManager!, hasVideo: Bool, in view: UIView!) {
        
    }
    public func offlinePlayBackManager(_ manager: DBYOfflinePlayBackManager!, hasNewChatMessageWithChatArray newChatDictArray: [Any]!) {
        guard let chatInfos = newChatDictArray as? [DBYChatEventInfo] else {
            return
        }
        var chatDicts = [[String:Any]]()
        for info in chatInfos {
            chatDicts.append(info.jsonObject() as! [String : Any])
        }
        
        chatListView.appendChats(array:chatDicts)
    }
    
    public func offlinePlayBackManagerChatMessageShouldClear(_ manager: DBYOfflinePlayBackManager!) {
        chatListView.clearAll()
        chatListView.reloadData()
    }
    public func offlinePlayBackManager(_ manager: DBYOfflinePlayBackManager!, isPlayingAtProgress progress: Float, time: TimeInterval) {
        if beginInteractive {
            return
        }
        mainView.bottomBar.set(time: time)
    }
    public func offlinePlayBackManagerFinishedPlay(_ manager: DBYOfflinePlayBackManager!) {
        mainView.bottomBar.set(time: 0)
        mainView.bottomBar.set(state: .end)
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
