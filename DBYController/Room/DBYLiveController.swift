//
//  DBYLiveController.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/10.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit
import WebKit
import DBYSDK_dylib

public class DBYLiveController: DBY1VNController {
    var tipViewSafeSize: CGSize = CGSize(width: 0, height: -44)
    var tipViewPosition: DBYTipView.Position = [.bottom, .center]
    
    var announcement:String?
    var isHandsup:Bool = false
    var sendMessageEnable:Bool = true
    var micOpen:Bool = false
    var zanCount = 0
    var inviteIndex = 0
    
    let btnWidth: CGFloat = 60
    let btnHeight: CGFloat = 30
    let tipViewHeight:CGFloat = 32
    let forbiddenBtnHeight:CGFloat = 32
    
    lazy var liveManager:DBYLiveManager = DBYLiveManager()
    
    lazy var interactionView = DBYInteractionView()
    lazy var voteView:DBYVoteView = DBYVoteView()
    lazy var announcementView = DBYAnnouncementView()
    lazy var micListView = DBYMicListView()
    lazy var hangUpView = DBYHangUpView()
    
    lazy var audioBtn:DBYVerticalButton = {
        let btn = DBYVerticalButton()
        btn.setImage(UIImage(name:"audio-only-normal"), for: .normal)
        btn.setImage(UIImage(name:"audio-only-selected"), for: .selected)
        btn.setTitle("只听音频", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 8)
        btn.titleLabel?.textColor = UIColor.white
        btn.titleLabel?.textAlignment = .center
        btn.imageView?.contentMode = .center
        return btn
    }()
    lazy var images:[UIImage] = {
        var arr = [UIImage]()
        for i in 0..<30 {
            let name = "zan_000" + String(format: "%02d", i)
            let image = UIImage(name: name)
            arr.append(image!)
        }
        return arr
    }()
    
    lazy var inputVC = DBYInputController()
    lazy var watermarkView = DBYWatermarkView()
    lazy var marqueeView = DBYMarqueeView()
    lazy var questionView = DBYQustionListView()
    
    var roomConfig: DBYRoomConfig?
    var sensitiveWords: [String]?
    weak var animationTimer: ZFTimer?
    weak var zanTimer:ZFTimer?
    var questions: [[String:Any]]?
    var videoPlayer: VideoPlayer?
    
    //MARK: - override functions
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        chatListView.chatBar.delegate = self
        micListView.delegate = self
        hangUpView.delegate = self
        topBar.delegate = self
        bottomBar.delegate = self
        settingView.delegate = self
        interactionView.delegate = self
        
        if authinfo?.classType == .sharedVideo {
            liveManager.setSharedVideoView(mainView.videoView)
        }else {
            liveManager.setTeacherViewWith(mainView.videoView)
        }
        
        liveManager.delegate = self
        
        guard let roomId = authinfo?.roomID else {
            return;
        }
        
        DBYRoomConfigUtil.shared.getRoomConfig(roomId: roomId) { (roomConfig) in
            self.roomConfig = roomConfig
            let name = roomConfig?.sensitiveWords
            DBYRoomConfigUtil.shared.getSensitiveWord(name: name) { (array) in
                self.sensitiveWords = array
            }
            DispatchQueue.main.async {
                self.questionView.roomConfig = roomConfig
                self.showMarqueeView()
                self.showExtendView()
            }
        }
        let oneTap = UITapGestureRecognizer(target: self,
                                            action: #selector(viewTap(tap:)))
        chatListView.addGestureRecognizer(oneTap)
        mainView.showLoadingView(delegate: nil)
        enterRoom()
    }
    deinit {
        animationTimer?.stopTimer()
        zanTimer?.stopTimer()
    }
    override func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recoverManager),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pauseManager),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    override func initSubViews() {
        settingView = DBYSettingViewLiveFactory.create()
    }
    override func addSubviews() {
        super.addSubviews()
        
        view.addSubview(interactionView)
        
        mainView.addSubview(marqueeView)
        mainView.addSubview(watermarkView)
    }
    override func addActions() {
        super.addActions()
        chatListView.inputButton.addTarget(self, action: #selector(showInputController), for: .touchUpInside)
        audioBtn.addTarget(self, action: #selector(audioOnly), for: .touchUpInside)
    }
    override func setupStaticUI() {
        super.setupStaticUI()
        
        topBar.set(authinfo?.courseTitle)
        
        chatListView.showChatbar = true
        
        var models = [DBYSegmentedModel]()
        let dicts:[[String:Any]] = [
            [
                "title":"讨论",
                "view":chatListView
            ],[
                "title":"课程信息",
                "view":courseInfoView
            ]
        ]
        for dict in dicts {
            let model = DBYSegmentedModel()
            let title = dict["title"] as! String
            let label = segmentedTitleLabel(title: title)
            let v = dict["view"] as! UIView
            model.labelWidth = 60
            model.label = label
            model.view = v
            models.append(model)
        }
        segmentedView.appendDatas(models: models)
        interactionView.isHidden = true
        courseInfoView.set(title: authinfo?.courseTitle)
        interactionView.userId = authinfo?.userId
    }
    override func setupLandscapeUI() {
        super.setupLandscapeUI()
        
        announcementView.isHidden = true
        interactionView.isHidden = true
        
        topBar.set(type: .landscape)
        chatListView.chatBar.endInput()
        bottomBar.set(type: .liveLandscape)
        segmentedView.containerView?.isScrollEnabled = false
    }
    override func setupPortraitUI() {
        super.setupPortraitUI()
        
        chatListView.inputButton.dismiss()
        
        inputVC.dismiss(animated: true, completion: nil)
        announcementView.isHidden = (announcement?.count ?? 0) <= 0
        topBar.set(type: .portrait)
        bottomBar.set(type: .live)
        
        segmentedView.containerView?.isScrollEnabled = true
    }
    override func setViewFrameAndStyle() {
        super.setViewFrameAndStyle()
        
        let edge = getIphonexEdge()
        
        tipViewSafeSize = CGSize(width: 0, height: -60 - edge.bottom)
        
        interactionView.portraitFrame = segmentedView.portraitFrame
        interactionView.landscapeFrame = .zero
        
        chatListView.setBackgroundColor(color: DBYStyle.lightAlpha, forState: .landscape)
        chatListView.setBackgroundColor(color: DBYStyle.lightGray, forState: .portrait)
    }
    override func updateStyles() {
        super.updateStyles()
        interactionView.updateStyle()
        hangUpView.autoAdjustFrame()
        micListView.autoAdjustFrame()
    }
    override func reachabilityChanged(note:NSNotification) {
        if let reachability = note.object as? DBYReachability {
            dealWith(reachability: reachability)
        }
    }
    override func goBack() {
        if isPortrait() {
            exitRoom()
        }else {
            toPortrait()
        }
    }
    //MARK: - private functions
    @objc func viewTap(tap: UITapGestureRecognizer) {
        chatListView.chatBar.endInput()
    }
    func dealWith(reachability: DBYReachability) {
        let netStatus = internetReachability?.currentReachabilityStatus()
        switch netStatus {
        case NotReachable:
            pauseManager()
            break
        case ReachableViaWWAN:
            mainView.addSubview(netTipView)
            pauseManager()
            break
        case ReachableViaWiFi:
            netTipView.dismiss()
            recoverManager()
            break
        default:
            break
        }
    }
    //显示竖屏小公告
    func showAnnouncement(text: String) {
        announcement = text
        if isLandscape() || text.count < 1 {
            return
        }
        segmentedView.addSubview(announcementView)
        announcementView.isHidden = false
        announcementView.frame = CGRect(x: 0,
                                        y: segmentedView.titleViewHeight,
                                        width: segmentedView.portraitFrame.width,
                                        height: tipViewHeight)
        announcementView.set(text: text)
    }
    
    @objc func enterRoom() {
        weak var weakSelf = self
        liveManager.enterRoom(withAuthJson: authinfo?.authinfoString, completeHandler: { (message, type) in
            weakSelf?.bottomBar.set(state: .play)
            if let reachability = weakSelf?.internetReachability {
                weakSelf?.dealWith(reachability: reachability)
            }
        })
    }
    @objc func exitRoom() {
        self.navigationController?.popViewController(animated: true)
        liveManager.quitClassRoom(completeHandler: { (message, code) in
            print("code:\(code), message:\(message ?? "")")
        })
    }
    func resetHandsupState() {
        isHandsup = false
    }
    func clearChatMessage() {
        chatListView.clearAll()
    }
    func showVoteView(title:String, votes:[String]) {
        voteView.setVotes(votes: votes)
        voteView.delegate = self
        bottomBar.showVoteButton()
        
        let model = DBYSegmentedModel()
        let label = segmentedTitleLabel(title: title)
        model.labelWidth = 60
        model.label = label
        model.view = voteView
        segmentedView.appendData(model: model)
    }
    func hiddenVoteView() {
        if voteView.delegate == nil {
            return
        }
        voteView.delegate = nil
        bottomBar.hiddenVoteButton()
        segmentedView.removeData(with: "答题", animated: false)
    }
    
    func showWatermarkView() {
        guard let wk = roomConfig?.watermark else {
            return
        }
        var rect:CGRect = .zero
        let width:CGFloat = wk.text?.width(withMaxHeight: 30, font: UIFont.systemFont(ofSize: 20)) ?? 40
        if wk.position == .top_left {
            rect = CGRect(x: 8, y: 8, width: width, height: 30)
        }
        if wk.position == .top_right {
            rect = CGRect(x: mainView.frame.width - 8 - width, y: 8, width: width, height: 30)
        }
        if wk.position == .bottom_left {
            rect = CGRect(x: 8, y: mainView.frame.height - 8 - 30, width: width, height: 30)
        }
        if wk.position == .bottom_right {
            let x = mainView.frame.width - 8 - width
            let y = mainView.frame.height - 8 - 30
            rect = CGRect(x: x, y: y, width: width, height: 30)
        }
        watermarkView.frame = rect
        watermarkView.set(watermark: wk)
        mainView.bringSubviewToFront(watermarkView)
    }
    func showMarqueeView() {
        guard let mq = roomConfig?.marquee else {
            return
        }
        guard let content = mq.content else {
            return
        }
        let width:CGFloat = content.width(withMaxHeight: 30, font: UIFont.systemFont(ofSize: 20))
        let x:CGFloat = 0
        let y:CGFloat = CGFloat(mq.regionMin) / 100.0 * mainView.frame.height
        marqueeView.frame = CGRect(x: x, y: y, width: width, height: 30)
        mainView.bringSubviewToFront(marqueeView)
        marqueeView.set(marquee: mq)
        animationTimer?.stopTimer()
        animationTimer = ZFTimer.startTimer(interval: 1, repeats: true) {[weak self] in
            self?.updateAnimation()
        }
    }
    func showExtendView() {
        guard let extends = roomConfig?.extends else {
            return
        }
        for extend in extends {
            let model = DBYSegmentedModel()
            let title = extend.title ?? ""
            let label = segmentedTitleLabel(title: title)
            
            if extend.type == .diy {
                let webview = WKWebView()
                webview.backgroundColor = UIColor.white
                let header = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>img{max-width:100%}</style></header>";
                webview.loadHTMLString(header + (extend.content ?? ""), baseURL: nil)
                model.view = webview
            }
            if extend.type == .qa {
                questionView.backgroundColor = UIColor.white
                model.view = questionView
            }
            model.labelWidth = 60
            model.label = label
            segmentedView.appendData(model: model)
        }
        segmentedView.scrollToIndex(index: 0, animated: false)
    }
    func setQuestions(list: [[String:Any]]) {
        questions = list
        questionView.set(list: list)
    }
    func appendQuestion(dict: [String:Any]) {
        questionView.append(dict: dict)
    }
    func removeQustion(questionId: String) {
        questionView.remove(questionId: questionId)
    }
    
    func send(message: String) {
        let chatDict:[String : Any] = [
            "userName": authinfo?.nickName ?? "",
            "message": message,
            "isOwner": true,
            "uid": authinfo?.userId ?? "",
            "role": authinfo?.userRole ?? 2
        ]
        let sensitive:Bool = sensitiveWords?.contains(message) ?? false
        
        //如果是敏感词或者禁言
        if sensitive || !sendMessageEnable {
            chatListView.appendChats(array:[chatDict])
            return
        }
        liveManager.sendChatMessage(with: message) { (errorMessage) in
            print(errorMessage ?? "sendChatMessage")
        }
    }
    func changeQuickLine(index: Int) {
        if let str = liveManager.getNextPriorityQuickLine(),
           let url = URL(string: str) {
            if url.scheme == "webrtc" {
                videoPlayer = TencentPlayerFactory.create(url: url)
            } else {
                videoPlayer = AliPlayerFactory.create(url: url)
            }
        }
        videoPlayer?.addPlayerView(mainView.videoView)
        videoPlayer?.start()
    }
    //MARK: - objc functions
    @objc func updateAnimation() {
        guard let mq = roomConfig?.marquee else {
            return
        }
        
        let x:CGFloat = marqueeView.frame.minX
        let y:CGFloat = marqueeView.frame.minY
        var deltaY:CGFloat = 0
        var deltaX:CGFloat = 5
        if x + marqueeView.frame.width > mainView.frame.width {
            let value = Int.random(in: mq.regionMin ... mq.regionMax)
            deltaY = CGFloat(value) / 100 * mainView.frame.height - y
            deltaX = -x
        }
        
        marqueeView.frame = marqueeView.frame.offsetBy(dx: deltaX, dy: deltaY)
    }
    @objc func showInputController() {
        if chatListView.isChatForbidden {
            return
        }
        inputVC.modalPresentationStyle = .custom
        inputVC.modalTransitionStyle = .crossDissolve

        inputVC.sendTextBlock = {[weak self] text in
            self?.send(message: text)
        }
        present(inputVC, animated: true, completion: nil)
    }
    
    @objc func audioOnly(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            mainView.showVideoTipView(type: .audio, delegate: self)
        }else {
            mainView.hiddenVideoTipView()
        }
        
        liveManager.setReceiveVideoWith(!sender.isSelected) { (message) in
            print(message ?? "setReceiveVideoWith")
        }
    }
    @objc func announcementClick() {
        
    }
    @objc func handsupClick() {
        if isHandsup {
            DBYGlobalMessage.shared().showText(.Retry)
        }else {
            isHandsup = true
            DBYGlobalMessage.shared().showText(.LM_Handsup)

            liveManager.requestRaiseHand(completeHandler: { (message) in
                if message != nil {
                    DBYGlobalMessage.shared().showText(message!)
                }
            })
        }
    }
    
    @objc func playControl() {
        
    }
    
    @objc func pauseManager() {
        bottomBar.set(state: .pause)
        liveManager.pauseLive()
    }
    @objc func recoverManager() {
        mainView.hiddenVideoTipView()
        clearChatMessage()
        bottomBar.set(state: .play)
        liveManager.recoverLive()
    }
    
    //MARK: - scrollView
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        chatListView.chatBar.endInput()
    }
}
extension DBYLiveController: DBYLiveManagerDelegate {
    public func clientOnline(_ liveManager: DBYLiveManager!, userId uid: String!, nickName: String!, userRole role: Int32) {
        mainView.hiddenLoadingView()
        let group = DispatchGroup()
        group.enter()
        liveManager.getInteractionList(.audio) {[weak self] (list) in
            if let models = list {
                self?.interactionView.set(models: models, for: .audio)
            }
            group.leave()
        }
        group.enter()
        liveManager.getInteractionList(.video) {[weak self] (list) in
            if let models = list {
                self?.interactionView.set(models: models, for: .video)
            }
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            self.interactionView.switchButton(.audio)
        }
    }
    public func liveManagerClassOver(_ manager: DBYLiveManager!) {
        DBYGlobalMessage.shared().showText(.LM_ClassOver)
    }
    public func liveManager(_ manager: DBYLiveManager!, hasNewChatMessageWithChatArray newChatDictArray: [Any]!) {
        guard let array = newChatDictArray as? [[String:Any]] else {
            return
        }
        
        chatListView.appendChats(array:array)
    }
    
    public func liveManagerChatMessageShouldClear(_ manager: DBYLiveManager!) {
        chatListView.clearAll()
    }
    public func liveManager(_ manager: DBYLiveManager!, hasAnnounceContent announceContent: String!) {
        announcementView.removeFromSuperview()
        showAnnouncement(text: announceContent)
    }
    public func liveManager(_ manager: DBYLiveManager!, onlineUserCountWith count: Int) {
        courseInfoView.setUserCount(count: count)
    }
    public func liveManager(_ manager: DBYLiveManager!, studentCanSpeak canSpeak: Bool) {
        micOpen = canSpeak
    }
    public func liveManagerTeacherDownHands(_ manager: DBYLiveManager!) {
        
    }
    public func liveManager(_ manager: DBYLiveManager!, shouldShowVoteWith voteType: DBYLiveManagerVoteType) {
        var votes = [String]()
        switch voteType {
        case DBYLiveManagerVoteType2Options:
            votes = ["A", "B"]
        case DBYLiveManagerVoteType3Options:
            votes = ["A", "B", "C"]
        case DBYLiveManagerVoteType4Options:
            votes = ["A", "B", "C", "D"]
        case DBYLiveManagerVoteType5Options:
            votes = ["A", "B", "C", "D", "E"]
        case DBYLiveManagerVoteType6Options:
            votes = ["A", "B", "C", "D", "E", "F"]
        default:
            break
        }
        showVoteView(title: "答题", votes: votes)
    }
    public func liveManagerShouldStopVote(_ manager: DBYLiveManager!) {
        segmentedView.removeData(with: "答题", animated: true)
    }
    public func liveManagerShouldHideVote(_ manager: DBYLiveManager!) {
        hiddenVoteView()
    }
    public func liveManager(_ manager: DBYLiveManager!, voteChangeWithOptionIndex index: Int, optionCount count: Int) {
        voteView.setVote(index: index, count: count)
    }
    public func liveManager(_ manager: DBYLiveManager!, voteEndWithOptionIndex index: Int, ontionSumCount count: Int) {
        
    }
    public func liveManager(_ manager: DBYLiveManager!, teacherStatusChangedWithOnline online: Bool, name: String!) {
        if online {
            courseInfoView.setTeacherName(name: name)
        }
    }

    public func liveManager(_ manager: DBYLiveManager!, teacherGiveMicToStudentWithUserInfo userInfo: [AnyHashable : Any]! = [:], canSpeak: Bool) {
        guard let userName = userInfo?["userName"] as? String else {
            return
        }
        if canSpeak {
            micListView.append(name: userName)
        }else {
            micListView.remove(name: userName)
        }
        micListView.autoAdjustFrame()
    }
    public func liveManager(_ manager: DBYLiveManager!, hasVideo: Bool, in view: UIView!) {
        if hasVideo {
            //切换到最前面
            showMarqueeView()
        }
    }
    public func liveManagerDidKickedOff(_ manager: DBYLiveManager!) {
        let actionSheetView = DBYActionSheetView()
        let button1 = DBYActionButton(style: .confirm)
        let button2 = DBYActionButton(style: .cancel)
        
        button1.setTitle("重新登录", for: .normal)
        button2.setTitle("退出登录", for: .normal)
        
        weak var weakSelf = self
        button1.action = { btn in
            actionSheetView.dismiss()
            weakSelf?.enterRoom()
        }
        button2.action = { btn in
            actionSheetView.dismiss()
            weakSelf?.exitRoom()
        }
        
        actionSheetView.show(title: "提示",
                        message: "检测到你在其他设备上登录",
                        actions: [button1, button2])
    }
    public func liveManagerTeacherAskStudentOpenCamera(_ manager: DBYLiveManager!) {
        liveManager.responseTeacherOpenCamRequest(withOpenCamera: true, completeHandler: { (message) in
            DBYGlobalMessage.shared().showText(message ?? "")
        })
    }
    public func liveManager(_ manager: DBYLiveManager!, denyChatStatusChange isDeny: Bool) {
        chatListView.isChatForbidden = isDeny
        chatListView.chatBar.isHidden = isDeny
    }
    public func liveManager(_ manager: DBYLiveManager!, canChat: Bool) {
        sendMessageEnable = canChat
    }
    public func liveManager(_ manager: DBYLiveManager!, receivedQuestions array: [[AnyHashable : Any]]!) {
        guard let list = array as? [[String: Any]] else {
            return
        }
        setQuestions(list: list)
    }
    public func liveManager(_ manager: DBYLiveManager!, receivedQuestion dict: [AnyHashable : Any]!) {
        guard let questionDict = dict as? [String: Any] else {
            return
        }
        appendQuestion(dict: questionDict)
    }
    public func liveManager(_ manager: DBYLiveManager!, removedQuestion questionId: String!) {
        removeQustion(questionId: questionId)
    }
    public func initVideoRecorder(_ liveManager: DBYLiveManager!, userId uid: String!) {
        let videoView = createVideoView(uid: uid)
        liveManager.setLocalVideoView(videoView.video)
        videoView.setUserName(name: authinfo?.nickName)
    }
    public func destroyVideoRecorder(_ liveManager: DBYLiveManager!, userId uid: String!) {
        let videoView = videoDict.removeValue(forKey: uid)
        videoView?.removeFromSuperview()
    }
    public func liveManager(_ manager: DBYLiveManager!, interActionListChange list: [DBYInteractionModel]!, type: DBYInteractionType) {
        self.interactionView.set(models: list, for: type)
    }
    public func willReceivedVideoData(_ liveManager: DBYLiveManager!, userId uid: String!) {
        if uid == authinfo?.teacherId || uid == liveManager.assitantId {
            return
        }
        let videoView = createVideoView(uid: uid)
        liveManager.setStudentView(videoView.video, withUserId: uid)
        liveManager.getUserInfo(uid) { (dict) in
            guard let userInfo = dict as? [String: Any] else {
                return
            }
            guard let userName = userInfo["userName"] as? String else {
                return
            }
            videoView.setUserName(name: userName)
        }
    }
    public func willInterruptVideoData(_ liveManager: DBYLiveManager!, userId uid: String!) {
        let videoView = videoDict.removeValue(forKey: uid)
        videoView?.removeFromSuperview()
    }
    public func liveManager(_ manager: DBYLiveManager!, thumbupWithCount count: Int, userName: String!) {
        if userName.count < 1 {
            courseInfoView.setThumbCount(count: count)
            return
        }
        print("\(userName ?? "")为教师点了\(count)个赞");
        let dict = [
            "type": "thumbup",
            "name": "\(userName ?? "")为教师点了\(count)个赞"
        ]
        chatListView.append(dict: dict)
    }
}
extension DBYLiveController:DBYNetworkTipViewDelegate {
    func confirmClick(_ owner: DBYNetworkTipView) {
        mainView.hiddenNetworkTipView()
        recoverManager()
    }
}
//MARK: - DBYChatBarDelegate
extension DBYLiveController: DBYChatBarDelegate {
    func chatBarDidBecomeActive(owner: DBYChatBar) {
        
    }
    func chatBar(owner: DBYChatBar, selectEmojiAt index: Int) {
        
    }
    func chatBar(owner: DBYChatBar, send message: String) {
        send(message: message)
    }
    func chatBar(owner: DBYChatBar, buttonClickWith target: UIButton) {
        interactionView.isHidden = false
    }
    func chatBarWillShowInputView(rect: CGRect, duration: TimeInterval) {
        if isLandscape() {
            return
        }
        chatListView.showInputView(offset: rect.height)
    }
    
    func chatBarWillDismissInputView(duration: TimeInterval) {
        if isLandscape() {
            return
        }
        chatListView.hiddenInputView()
    }
}
//MARK: - DBYVoteViewDelegate
extension DBYLiveController: DBYVoteViewDelegate {
    func voteView(voteView: DBYVoteView, didVotedAt index: Int) {
        liveManager.sendVote(withOptionIndex: index)
    }
}
//MARK: - DBYHangUpViewDelegate
extension DBYLiveController: DBYHangUpViewDelegate {
    func hangUpViewShouldHangUp(owner: DBYHangUpView) {
        let actionSheetView = DBYActionSheetView()
        let button1 = DBYActionButton(style: .confirm)
        let button2 = DBYActionButton(style: .cancel)
        
        button1.setTitle("确定", for: .normal)
        button2.setTitle("取消", for: .normal)
        
        weak var weakSelf = self
        button1.action = { btn in
            weakSelf?.liveManager.send(.audio, state: .quit, completion: { (result) in
                
            })
            weakSelf?.hangUpView.dismiss()
            actionSheetView.dismiss()
        }
        button2.action = { btn in
            actionSheetView.dismiss()
        }
        actionSheetView.setBackground(image: UIImage(name: "open_mic_bg"))
        actionSheetView.show(title: "提示",
                             message: "你确定要挂断上麦么？",
                             actions: [button1, button2])
    }
}
extension DBYLiveController: DBYMicListViewDelegate {
    func micListView(owner: DBYMicListView, showMicList: Bool) {
        if micOpen {
            hangUpView.isHidden = !showMicList
        }
        micListView.autoAdjustFrame()
    }
}
//MARK: - DBYBottomBarDelegate
extension DBYLiveController: DBYBottomBarDelegate {
    func chatButtonClick(owner: DBYBottomBar) {
        topBar.isHidden = true
        bottomBar.isHidden = true
        segmentedView.scrollToIndex(index: 0, animated: false)
        let rect = segmentedView.landscapeFrame
        UIView.animate(withDuration: 0.25) {
            self.segmentedView.isHidden = false
            self.segmentedView.frame = rect.offsetBy(dx: -rect.width, dy: 0)
        }
    }
    
    func voteButtonClick(owner: DBYBottomBar) {
        topBar.isHidden = true
        bottomBar.isHidden = true
        segmentedView.scrollToLast(animated: false)
        let rect = segmentedView.landscapeFrame
        UIView.animate(withDuration: 0.25) {
            self.segmentedView.isHidden = false
            self.segmentedView.frame = rect.offsetBy(dx: -rect.width, dy: 0)
        }
    }
    
    func fullscreenButtonClick(owner: DBYBottomBar) {
        toLandscape()
    }
    
    func playStateDidChange(owner: DBYBottomBar, state: DBYPlayState) {
        if state == .pause {
            recoverManager()
            mainView.hiddenNetworkTipView()
            mainView.hiddenVideoTipView()
        }
        if state == .play {
            pauseManager()
            mainView.showVideoTipView(type: .pause, delegate: self)
        }
    }
    func progressWillChange(owner: DBYBottomBar, value: Float) {
        
    }
    func progressDidChange(owner: DBYBottomBar, value: Float) {
        
    }
    
    func progressEndChange(owner: DBYBottomBar, value: Float) {
        
    }
}
//MARK: - DBYTopBarDelegate
extension DBYLiveController: DBYTopBarDelegate {
    func backButtonClick(owner: DBYTopBar) {
        goBack()
    }
    
    func settingButtonClick(owner: DBYTopBar) {
        topBar.isHidden = true
        bottomBar.isHidden = true
        settingClick()
    }
}
extension DBYLiveController: DBYSettingViewDelegate {
    func settingView(owner: DBYSettingView, didSelectedItemAt indexPath: IndexPath) {
        
    }
}
extension DBYLiveController: DBYVideoTipViewDelegate {
    func continueClick(_ owner: DBYPauseTipView) {
        recoverManager()
    }
    
    func buttonClick(owner: DBYVideoTipView1, type: DBYTipType) {
        if type == .audio {
            audioBtn.isSelected = true
            liveManager.setReceiveVideoWith(true) { (message) in
                print(message ?? "setReceiveVideoWith")
            }
            mainView.hiddenVideoTipView()
        }
        if type == .pause {
            recoverManager()
        }
    }
}
extension DBYLiveController: DBYCommentCellDelegate {
    func commentCell(cell: UITableViewCell, didPressWith index: IndexPath) {
        let chatDict = chatListView.allChatList[index.row]
        let name:String = chatDict["userName"] as? String ?? ""
        chatListView.chatBar.append(text: "@" + name)
    }
}
//MARK: - DBYInteractionViewDelegate
extension DBYLiveController: DBYInteractionViewDelegate {
    func waittingForVideo(owner: DBYInteractionView, count: Int) {
        if count != 1 {
            return
        }
        guard let tipView = DBYTipView.loadView(type: .close) else {
            return
        }
        view.addSubview(tipView)
        let icon = UIImage(name: "camera-request-icon")
        let message = "还有 1 人等待上台，请你做好准备"
        if let p = tipView as? DBYTipViewUIProtocol {
            p.show(icon: icon, message: message)
            p.setPosition(position: tipViewPosition)
            p.setContentOffset(size: tipViewSafeSize)
        }
        tipView.dismiss(after: 3)
        guard let closeView = tipView as? DBYTipCloseView else {
            return
        }
        weak var weakView = closeView
        closeView.closeBlock = {
            weakView?.removeFromSuperview()
        }
    }
    
    func closeInteraction(owner: DBYInteractionView, type: DBYInteractionType) {
        interactionView.isHidden = true
        if owner.currentInfo.state == .normal {
            chatListView.chatBar.interactionButton.isSelected = false
        }else {
            chatListView.chatBar.interactionButton.isSelected = true
        }
    }
    
    func interactionAlert(owner: DBYInteractionView, message: String) {
        let icon = UIImage(name: "mic")
        guard let tipView = DBYTipView.loadView(type: .click) else {
            return
        }
        view.addSubview(tipView)
        if let p = tipView as? DBYTipViewUIProtocol {
            p.show(icon: icon, message: message)
            p.setPosition(position: tipViewPosition)
            p.setContentOffset(size: tipViewSafeSize)
        }
        tipView.dismiss(after: 3)
    }
    
    func requestInteraction(owner: DBYInteractionView, state: DBYInteractionState, type: DBYInteractionType) {
        liveManager.send(type, state: state) { (result) in
            print("requestInteraction", result)
        }
    }
    
    func receiveInteraction(owner: DBYInteractionView, state: DBYInteractionState, type: DBYInteractionType, model: DBYInteractionModel?) {
        if state == .inqueue, let userInfo = model {
            if userInfo.fromUserId == userInfo.userId {
                return
            }
            var name:String = ""
            var message:String = ""
            if type == .audio {
                name = "mic-small"
                message = userInfo.fromUserName + "邀请你上麦"
            }
            if type == .video {
                name = "camera-request-icon"
                message = userInfo.fromUserName + "邀请你上台"
            }
            let image = UIImage(name: name)
            
            //加载tipview
            guard let tipView = DBYTipView.loadView(type: .invite) else {
                return
            }
            view.addSubview(tipView)
            //设置ui
            if let p = tipView as? DBYTipViewUIProtocol {
                p.show(icon: image, message: message)
                p.setPosition(position: tipViewPosition)
                p.setContentOffset(size: tipViewSafeSize)
            }
            //动作
            guard let inviteView = tipView as? DBYTipInviteView else {
                return
            }
            weak var weakView = inviteView
            weak var weakSelf = self
            inviteView.acceptBlock = {
                weakView?.removeFromSuperview()
                weakSelf?.liveManager.send(type, state: .joined, completion: { (result) in
                    
                })
            }
            inviteView.refuseBlock = {
                weakView?.removeFromSuperview()
                weakSelf?.liveManager.send(type, state: .abort, completion: { (result) in
                    
                })
            }
        }
        if state == .abort {
            DBYTipView.removeTipViews(type: .invite, on: view)
        }
        if state == .joined && type == .video {
            liveManager.openCam(true) { (message) in
                
            }
        }
        if state == .quit && type == .video {
            liveManager.openCam(false) { (message) in
                
            }
        }
        if state == .joined && type == .audio {
            liveManager.openMic(true) { (message) in
                
            }
            view.addSubview(hangUpView)
            view.addSubview(micListView)
            hangUpView.autoAdjustFrame()
            micListView.autoAdjustFrame()
        }
        if state == .quit && type == .audio {
            liveManager.openMic(false) { (message) in
                
            }
            hangUpView.removeFromSuperview()
            micListView.removeFromSuperview()
        }
    }
    
    func switchInteraction(owner: DBYInteractionView, type: DBYInteractionType) {
        
    }
    
}
