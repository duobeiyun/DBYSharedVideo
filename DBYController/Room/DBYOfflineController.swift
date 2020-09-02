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
        topBar.delegate = self
        bottomBar.delegate = self
        
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
            weakSelf?.bottomBar.set(totalTime: totalTime)
            weakSelf?.offlineManager.seek(toTime: 10)
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
    override func goBack() {
        if isPortrait() {
            offlineManager.stop()
            super.goBack()
        }else {
            toPortrait()
        }
    }
}
//MARK: - private functions
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
        topBar.isHidden = true
        bottomBar.isHidden = true
        segmentedView.isHidden = false
        segmentedView.scrollToIndex(index: 0)
    }
    
    func voteButtonClick(owner: DBYBottomBar) {
        
    }
    
    func fullscreenButtonClick(owner: DBYBottomBar) {
        toLandscape()
    }
    
    func stateDidChange(owner: DBYBottomBar, state: DBYPlayState) {
        if state == .play {
            offlineManager.pause()
            mainView.showVideoTipView(type: .pause, delegate: self)
        }
        if state == .pause {
            offlineManager.resume()
            mainView.hiddenVideoTipView()
        }
        if state == .end {
            offlineManager.play()
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
//MARK: - DBYVideoTipViewDelegate
extension DBYOfflineController: DBYVideoTipViewDelegate {
    func continueClick(_ owner: DBYPauseTipView) {
        
    }
    
    
}
