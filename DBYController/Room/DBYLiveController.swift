//
//  DBYLiveController.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/10.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit
import DBYSDK_dylib

public class DBYLiveController: DBY1VNController {
    var chatBarFrame: CGRect = .zero
    var hangUpViewFrame: CGRect = .zero
    var micListViewFrame: CGRect = .zero
    var forbiddenBtnFrame: CGRect = .zero
    var announcementViewFrame: CGRect = .zero
    
    var announcement:String?
    var isHandsup:Bool = false
    var sendMessageEnable:Bool = true
    var newMessageCount:Int = 0
    var showTip:Bool = false
    var micOpen:Bool = false
    var zanCount = 0
    var inviteIndex = 0
    
    let btnWidth: CGFloat = 60
    let btnHeight: CGFloat = 30
    let tipViewHeight:CGFloat = 32
    let forbiddenBtnHeight:CGFloat = 32
    
    lazy var liveManager:DBYLiveManager = DBYLiveManager()
    
    lazy var chatBar = DBYChatBar()
    lazy var voteView:DBYVoteView = DBYVoteView()
    lazy var announcementView = DBYAnnouncementView()
    lazy var messageTipView = DBYMessageTipView()
    lazy var micListView = DBYMicListView()
    lazy var hangUpView = DBYHangUpView()
    lazy var forbiddenButton = DBYButton()
    lazy var zanButton = UIButton(type: .custom)
    lazy var inputButton:DBYButton = {
        let btn = DBYButton()
        btn.setBackgroudnStyle(fillColor: DBYStyle.halfBlack,
                               strokeColor: UIColor.clear,
                               radius: 15)
        btn.setImage(UIImage(name: "btn-chat"), for: .normal)
        let att = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                   NSAttributedString.Key.foregroundColor: UIColor.white]
        let attStr = NSAttributedString(string: " 输入聊天", attributes: att)
        btn.setAttributedTitle(attStr, for: .normal)
        return btn
    }()
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
    lazy var questionView = DBYChatListView()
    lazy var zanView = UIImageView()
    
    var roomConfig: DBYRoomConfig?
    var sensitiveWords: [String]?
    var animationTimer: Timer?
    var questions: [[String:Any]]?
    var zanTimer:Timer?
    
    //MARK: - override functions
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        chatListView.delegate = self
        chatListView.dataSource = self
        netTipView.delegate = self
        chatBar.delegate = self
        messageTipView.delegate = self
        micListView.delegate = self
        hangUpView.delegate = self
        topBar.delegate = self
        bottomBar.delegate = self
        settingView.delegate = self
        videoTipView.delegate = self
        
        if authinfo?.classType == .sharedVideo {
            liveManager.setSharedVideoView(mainView)
        }else {
            liveManager.setTeacherViewWith(mainView)
        }
        
        liveManager.delegate = self
        
        addObserver()
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
                self.setupVideoButton()
            }
        }
        let oneTap = UITapGestureRecognizer(target: self,
                                            action: #selector(viewTap(tap:)))
        chatListView.addGestureRecognizer(oneTap)
        mainView.startLoading()
        enterRoom()
    }
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    deinit {
        print("---deinit")
        NotificationCenter.default.removeObserver(self)
    }
    override func addSubviews() {
        super.addSubviews()
        
        chatContainer.addSubview(chatListView)
        chatContainer.addSubview(chatBar)
        chatContainer.addSubview(forbiddenButton)
        chatContainer.addSubview(inputButton)
        chatContainer.addSubview(announcementView)
        
        mainView.addSubview(marqueeView)
        mainView.addSubview(watermarkView)
        
        view.addSubview(messageTipView)
        view.addSubview(micListView)
        view.addSubview(hangUpView)
//        view.addSubview(zanButton)
        view.addSubview(zanView)
    }
    override func addActions() {
        super.addActions()
        inputButton.addTarget(self, action: #selector(showChatBar), for: .touchUpInside)
        audioBtn.addTarget(self, action: #selector(audioOnly), for: .touchUpInside)
        zanButton.addTarget(self, action: #selector(zanAnimation), for: .touchUpInside)
    }
    override func setupStaticUI() {
        super.setupStaticUI()
        
        topBar.set(authinfo?.courseTitle)
        settingView.set(buttons: [audioBtn])
        roomControlbar.append(title: "讨论")
        roomControlbar.append(title: "课程信息")
        scrollContainer.append(view: chatContainer)
        scrollContainer.append(view: courseInfoView)
        chatBar.emojiImageDict = emojiImageDict
        chatBar.backgroundColor = UIColor.white
        hangUpView.isHidden = true
        messageTipView.isHidden = true
        forbiddenButton.isHidden = true
        micListView.isHidden = true
        let volume = DBYSystemControl.shared.getVolume()
        hangUpView.setProgress(value: volume)
        forbiddenButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        forbiddenButton.setTitle(" 已开启全体禁言", for: .normal)
        zanButton.setImage(UIImage(name: "greate-icon"), for: .normal)
        courseInfoView.set(title: authinfo?.courseTitle)
    }
    override func setupLandscapeUI() {
        super.setupLandscapeUI()
        
        inputButton.isHidden = false
        announcementView.isHidden = true
        topBar.set(type: .landscape)
        chatBar.endInput()
        messageTipView.set(corners: [.topLeft, .bottomLeft])
        bottomBar.set(type: .liveLandscape)
        forbiddenButton.setTitleColor(UIColor.white, for: .normal)
        forbiddenButton.setBackgroudnStyle(fillColor: DBYStyle.darkGray,
                                           strokeColor: UIColor.white,
                                           radius: forbiddenBtnHeight * 0.5)
        forbiddenButton.setImage(UIImage(name: "forbidden-white"), for: .normal)
        voteView.setTheme(.dark)
    }
    override func setupPortraitUI() {
        super.setupPortraitUI()
        
        inputVC.dismiss(animated: true, completion: nil)
        inputButton.isHidden = true
        announcementView.isHidden = (announcement?.count ?? 0) <= 0
        topBar.set(type: .portrait)
        bottomBar.set(type: .live)
        messageTipView.set(corners: [.allCorners])
        forbiddenButton.setTitleColor(DBYStyle.brown, for: .normal)
        forbiddenButton.setBackgroudnStyle(fillColor: UIColor.white,
                                           strokeColor: DBYStyle.brown,
                                           radius: 4)
        forbiddenButton.setImage(UIImage(name: "forbidden-light"), for: .normal)
        voteView.setTheme(.light)
    }
    override func updateFrame() {
        super.updateFrame()
        
        chatBar.frame = chatBarFrame
        hangUpView.frame = hangUpViewFrame
        announcementView.frame = announcementViewFrame
        messageTipView.frame = smallPopViewFrame
        micListView.frame = micListViewFrame
        forbiddenButton.frame = forbiddenBtnFrame
        
        zanView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        zanView.center = view.center
        updateMicListViewFrame()
    }
    override func updatePortraitFrame() {
        super.updatePortraitFrame()
        let size = view.bounds.size
        let chatBarHeight =  48 + iphoneXBottom
        
        scrollContainerFrame = CGRect(x: 0,
                                    y: roomControlbarFrame.maxY,
                                    width: size.width,
                                    height: size.height - roomControlbarFrame.maxY)
        chatListViewFrame = CGRect(x: 0,
                                   y: 0,
                                   width: size.width,
                                   height: scrollContainerFrame.height - chatBarHeight)
        announcementViewFrame = CGRect(x: roomControlbarFrame.minX,
                                       y: 0,
                                       width: size.width,
                                       height: 40)
        chatBarFrame = CGRect(x: 0,
                              y: chatListViewFrame.maxY,
                              width: size.width,
                              height: chatBarHeight)
        hangUpViewFrame = CGRect(x: size.width - 140,
                                 y: roomControlbarFrame.maxY + 72,
                                 width: 140,
                                 height: tipViewHeight)
        smallPopViewFrame = CGRect(x: normalMargin * 2,
                                   y: size.height - chatBarFrame.height - normalMargin - tipViewHeight,
                                   width: size.width - normalMargin * 4,
                                   height: tipViewHeight)
        forbiddenBtnFrame = CGRect(x: normalMargin,
                                   y: chatListViewFrame.maxY + normalMargin,
                                   width: chatListViewFrame.width - normalMargin * 2,
                                   height: forbiddenBtnHeight)
        zanButton.frame = CGRect(x: size.width - 60, y: size.height - 160, width: 48, height: 48)
    }
    override func updateLandscapeFrame() {
        super.updateLandscapeFrame()
        let size = view.bounds.size
        let tipViewWidth = size.width * 0.4
        let buttonWidth:CGFloat = 160
        let scrollContainerWidth = size.width * 0.5
        
        scrollContainerFrame = CGRect(x: size.width,
                                    y: 0,
                                    width: scrollContainerWidth,
                                    height: size.height)
        chatListViewFrame = CGRect(x: 0,
                                   y: 0,
                                   width: scrollContainerWidth,
                                   height: size.height)
        chatBarFrame = CGRect(x: 0,
                              y: size.height,
                              width: size.width,
                              height: 48)
        announcementViewFrame = CGRect(x: size.width - scrollContainerWidth,
                                       y: 0,
                                       width: scrollContainerWidth,
                                       height: 40)
        smallPopViewFrame = CGRect(x: size.width - tipViewWidth,
                                   y: topBar.frame.maxY + normalMargin,
                                   width: tipViewWidth,
                                   height: tipViewHeight)
        hangUpViewFrame = CGRect(x: smallPopViewFrame.minX,
                                 y: smallPopViewFrame.maxY + normalMargin,
                                 width: tipViewWidth,
                                 height: tipViewHeight)
        forbiddenBtnFrame = CGRect(x: chatListViewFrame.midX - buttonWidth * 0.5,
                                   y: chatListViewFrame.height - normalMargin - forbiddenBtnHeight,
                                   width: buttonWidth,
                                   height: forbiddenBtnHeight)
        inputButton.frame = CGRect(x: normalMargin,
                                   y: chatListViewFrame.height - normalMargin - forbiddenBtnHeight - iphoneXBottom,
                                   width: 80,
                                   height: forbiddenBtnHeight)
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
    func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recoverManager),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pauseManager),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    @objc func viewTap(tap: UITapGestureRecognizer) {
        chatBar.endInput()
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
            netTipView.hidden()
            recoverManager()
            break
        default:
            break
        }
    }
    //显示竖屏小公告
    func showAnnouncement(text: String) {
        announcement = text
        announcementView.set(text: text)
        let dy = announcementViewFrame.height
        announcementView.frame = announcementViewFrame.offsetBy(dx: 0, dy: -dy)
        UIView.animate(withDuration: 0.25) {
            self.announcementView.frame = self.announcementViewFrame
        }
        if isLandscape() {
            announcementView.isHidden = true
        }else {
            announcementView.isHidden = false
        }
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
        cellHeightCache.removeAll()
        allChatList.removeAll()
        DispatchQueue.main.async {
            self.chatListView.reloadData()
        }
    }
    func showChatView() {
        showScrollContainer()
        scrollContainer.scroll(at: 0)
    }
    func showVoteView(title:String, votes:[String]) {
        voteView.setVotes(votes: votes)
        voteView.delegate = self
        bottomBar.showVoteButton()
        roomControlbar.append(title: "答题")
        scrollContainer.append(view: voteView)
    }
    func hiddenVoteView() {
        if voteView.delegate == nil {
            return
        }
        voteView.delegate = nil
        bottomBar.hiddenVoteButton()
        roomControlbar.removeLast()
        scrollContainer.removeLast()
    }
    func showVoteView() {
        showScrollContainer()
        scrollContainer.scrollAtLast()
    }
    func showScrollContainer() {
        let offsetX:CGFloat = -scrollContainerFrame.width
        scrollContainer.frame = scrollContainerFrame.offsetBy(dx: offsetX, dy: 0)
    }
    func hiddenScrollContainer() {
        scrollContainer.frame = scrollContainerFrame
    }
    func showMessageTipView(image: UIImage?, message: String, type: DBYMessageTipType) {
        messageTipView.show(icon: image, message: message, type: type)
        let tipViewWidth = messageTipView.getContentWidth()
        
        var x:CGFloat = 0
        if isPortrait() {
            x = smallPopViewFrame.minX + (smallPopViewFrame.width - tipViewWidth) * 0.5
        }
        if isLandscape() {
            x = smallPopViewFrame.minX + (smallPopViewFrame.width - tipViewWidth)
        }
        let showFrame = CGRect(x: x,
                               y: smallPopViewFrame.minY,
                               width: tipViewWidth,
                               height: smallPopViewFrame.height)
        
        messageTipView.frame = showFrame
        chatBar.endInput()
    }
    func updateMicListViewFrame() {
        let messageLabWidth = micListView.getMessageWidth()
        let width = 50 + messageLabWidth
        let x = view.bounds.width - width
        micListViewFrame = CGRect(x: x,
                                  y: scrollContainerFrame.minY + tipViewHeight,
                                  width: width,
                                  height: tipViewHeight)
        
        micListView.frame = micListViewFrame
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
            rect = CGRect(x: mainViewFrame.width - 8 - width, y: 8, width: width, height: 30)
        }
        if wk.position == .bottom_left {
            rect = CGRect(x: 8, y: mainViewFrame.height - 8 - 30, width: width, height: 30)
        }
        if wk.position == .bottom_right {
            let x = mainViewFrame.width - 8 - width
            let y = mainViewFrame.height - 8 - 30
            rect = CGRect(x: x, y: y, width: width, height: 30)
        }
        watermarkView.frame = rect
        watermarkView.set(watermark: wk)
        mainView.bringSubviewToFront(watermarkView)
    }
    func setupVideoButton() {
        let studentVideo = roomConfig?.studentVideo
        guard let disable = studentVideo?["disabled"] as? Bool else {
            return
        }
        if disable {
            return
        }
        roomControlbar.showVideoButton()
    }
    func showMarqueeView() {
        guard let mq = roomConfig?.marquee else {
            return
        }
        let width:CGFloat = mq.content?.width(withMaxHeight: 30, font: UIFont.systemFont(ofSize: 20)) ?? 40
        let x:CGFloat = 0
        let y:CGFloat = CGFloat(mq.regionMin) / 100.0 * mainViewFrame.height
        marqueeView.frame = CGRect(x: x, y: y, width: width, height: 30)
        mainView.bringSubviewToFront(marqueeView)
        marqueeView.set(marquee: mq)
        stopTimer()
        startTimer()
    }
    func showExtendView() {
        guard let extends = roomConfig?.extends else {
            return
        }
        for model in extends {
            roomControlbar.append(title: model.title ?? "")
            if model.type == .diy {
                let webview = UIWebView()
                webview.backgroundColor = UIColor.white
                webview.loadHTMLString(model.content ?? "", baseURL: nil)
                scrollContainer.append(view: webview)
            }
            if model.type == .qa {
                questionView.backgroundColor = UIColor.white
                scrollContainer.append(view: questionView)
            }
        }
        roomControlbar.scroll(at: 0)
        scrollContainer.scroll(at: 0)
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
    func startTimer() {
        let interval:TimeInterval = 1
        let date:Date = Date(timeIntervalSinceNow: interval)
        animationTimer = Timer(fireAt: date,
                               interval: interval,
                               target: self,
                               selector: #selector(updateAnimation),
                               userInfo: nil,
                               repeats: true)
        RunLoop.current.add(animationTimer!,
                            forMode: RunLoop.Mode.default)
    }
    func stopTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
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
            appendChats(array:[chatDict])
            return
        }
        liveManager.sendChatMessage(with: message) { (errorMessage) in
            print(errorMessage ?? "sendChatMessage")
        }
    }
    func appendChats(array: [[String:Any]]) {
        allChatList += array
        let maxCount = allChatList.count - 1000
        if maxCount > 0 {
            for _ in 0..<maxCount {
                allChatList.removeFirst()
            }
        }
        let count = allChatList.count
        
        if showTip {
            newMessageCount += array.count
            let image = UIImage(name: "message-tip")
            let message = "\(newMessageCount)条新消息"
            showMessageTipView(image: image, message: message, type: .click)
            return
        }else if count > 0 {
            chatListView.reloadData()
            chatListView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    override func requestOpenCamera() {
        let actionSheetView = DBYActionSheetView()
        let button1 = DBYActionButton(style: .confirm)
        let button2 = DBYActionButton(style: .cancel)
        
        button1.setTitle("申请上台", for: .normal)
        button2.setTitle("取消", for: .normal)
        
        button1.action = {[weak self] btn in
            actionSheetView.dismiss()
            self?.liveManager.requestToOpenCamera()
            self?.roomControlbar.setCameraState(state: .invite)
        }
        button2.action = { btn in
            actionSheetView.dismiss()
        }
        actionSheetView.setBackground(image: UIImage(name: "open_camera_bg"))
        actionSheetView.show(title: "申请上台",
                             message: "是否要申请上台发言？",
                             actions: [button1, button2])
    }
    override func cancelOpenCamera() {
        let actionSheetView = DBYActionSheetView()
        let button1 = DBYActionButton(style: .confirm)
        let button2 = DBYActionButton(style: .cancel)
        
        button1.setTitle("取消上台", for: .normal)
        button2.setTitle("取消", for: .normal)
        
        button1.action = {[weak self] btn in
            actionSheetView.dismiss()
            self?.roomControlbar.setCameraState(state: .normal)
            self?.liveManager.requestToCloseCamera()
        }
        button2.action = { btn in
            actionSheetView.dismiss()
        }
        actionSheetView.setBackground(image: UIImage(name: "open_camera_bg"))
        actionSheetView.show(title: "上台信息",
                             message: "前方还有 \(inviteIndex) 人等待上台点击取消上台申请",
                             actions: [button1, button2])
    }
    override func closeCamera() {
        let actionSheetView = DBYActionSheetView()
        let button1 = DBYActionButton(style: .confirm)
        let button2 = DBYActionButton(style: .cancel)
        
        button1.setTitle("确认退出", for: .normal)
        button2.setTitle("取消", for: .normal)
        
        button1.action = {[weak self] btn in
            actionSheetView.dismiss()
            self?.roomControlbar.setCameraState(state: .normal)
            self?.liveManager.requestToCloseCamera()
        }
        button2.action = { btn in
            actionSheetView.dismiss()
        }
        actionSheetView.setBackground(image: UIImage(name: "open_camera_bg"))
        actionSheetView.show(title: "确认退出上台",
                             message: "你确认要退出上台？",
                             actions: [button1, button2])
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
        if x + marqueeView.frame.width > mainViewFrame.width {
            let value = Int.random(in: mq.regionMin ... mq.regionMax)
            deltaY = CGFloat(value) / 100 * mainViewFrame.height - y
            deltaX = -x
        }
        
        marqueeView.frame = marqueeView.frame.offsetBy(dx: deltaX, dy: deltaY)
    }
    @objc func showChatBar() {
        inputVC.modalPresentationStyle = .custom
        inputVC.modalTransitionStyle = .crossDissolve

        inputVC.sendTextBlock = {[weak self] text in
            self?.send(message: text)
        }
        present(inputVC, animated: true, completion: nil)
    }
    @objc func zanAnimation(sender:UIButton) {
        if zanView.isAnimating {
            return
        }
        zanView.animationImages = images
        zanView.animationRepeatCount = 1
        zanView.animationDuration = 0.3
        zanView.startAnimating()
        
        zanCount += 1
        stopZanTimer()
        startZanTimer()
    }
    func startZanTimer() {
        zanTimer = Timer(timeInterval: 1, target: self, selector: #selector(updateZan), userInfo: nil, repeats: false)
        RunLoop.main.add(zanTimer!, forMode: .common)
    }
    @objc func updateZan() {
        liveManager.thumbsup(withCount: Int32(zanCount)) { (message) in
            print(message ?? "updateZan")
        }
        zanCount = 0
    }
    func stopZanTimer() {
        zanTimer?.invalidate()
        zanTimer = nil
    }
    @objc func audioOnly(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            videoTipView.set(type: .audio)
            showVideoTipView()
        }else {
            hiddenVideoTipView()
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
        hiddenVideoTipView()
        clearChatMessage()
        bottomBar.set(state: .play)
        liveManager.recoverLive()
    }
    override func oneTap(tap: UITapGestureRecognizer) {
        super.oneTap(tap: tap)
        hiddenScrollContainer()
    }
    
//MARK: - scrollView
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        chatBar.endInput()
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == chatListView {
            let delta = scrollView.contentSize.height - scrollView.contentOffset.y
            showTip = delta > scrollView.bounds.height
            print(showTip)
            if !showTip {
                newMessageCount = 0
                messageTipView.close()
            }
        }
    }
}
// MARK: - UITableViewDelegate
extension DBYLiveController: UITableViewDelegate, UITableViewDataSource {
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
        return UITableView.automaticDimension
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:DBYCommentCell = DBYCommentCell()
        
        if allChatList.count <= indexPath.row {
            return cell
        }
        var chatDict = allChatList[indexPath.row]
        if let type:String = chatDict["type"] as? String, type == "thumbup" {
            let thumbCell = tableView.dequeueReusableCell(withIdentifier: zanCell, for: indexPath) as! DBYZanCell
            thumbCell.set(text: chatDict["name"] as? String)
            return thumbCell
        }
        chatDict["size"] = view.bounds.size
        let model = DBYCellModel.commentCellModel(dict: chatDict, roomConfig: roomConfig)
        
        cell = tableView.dequeueReusableCell(withIdentifier: model.identifier) as! DBYCommentCell
        cell.setTextColor(model.textColor)
        cell.setBubbleImage(model.bubbleImage)
        cell.setText(name: model.name,
                     message: model.message,
                     avatarUrl: model.avatarUrl,
                     badge: model.badge)
        
        return cell
    }
}
extension DBYLiveController: DBYLiveManagerDelegate {
    public func clientOnline(_ liveManager: DBYLiveManager!, userId uid: String!, nickName: String!, userRole role: Int32) {
        mainView.stopLoading()
    }
    public func liveManagerClassOver(_ manager: DBYLiveManager!) {
        DBYGlobalMessage.shared().showText(.LM_ClassOver)
    }
    public func liveManager(_ manager: DBYLiveManager!, hasNewChatMessageWithChatArray newChatDictArray: [Any]!) {
        guard let array = newChatDictArray as? [[String:Any]] else {
            return
        }
        
        appendChats(array:array)
    }
    
    public func liveManagerChatMessageShouldClear(_ manager: DBYLiveManager!) {
        showTip = false
        newMessageCount = 0
        allChatList.removeAll()
        chatListView.reloadData()
    }
    public func liveManager(_ manager: DBYLiveManager!, hasAnnounceContent announceContent: String!) {
        if announceContent.count <= 0 {
            announcementView.isHidden = true
        }else {
            showAnnouncement(text: announceContent)
        }
    }
    public func liveManager(_ manager: DBYLiveManager!, onlineUserCountWith count: Int) {
        courseInfoView.setUserCount(count: count)
    }
    public func liveManager(_ manager: DBYLiveManager!, studentCanSpeak canSpeak: Bool) {
        micOpen = canSpeak
        if canSpeak {
            hangUpView.isHidden = false
        }else {
            hangUpView.isHidden = true
        }
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
        updateMicListViewFrame()
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
    public func liveManager(_ manager: DBYLiveManager!, receivedMessage type: DBYMessageType, withUserInfo userInfo: [String : String]! = [:]) {
        var message:String = ""
        var tipType:DBYMessageTipType = .unknow
        let name = userInfo["userName"] ?? ""
        switch type {
        case .audioInvite:
            message = "教师 " + name + "邀请你上麦"
            tipType = .invite
        case .audioInviteEnd:
            message = "上麦结束"
            tipType = .close
            hangUpView.isHidden = true
        case .audioInviteTimeout:
            message = "上麦超时"
            tipType = .close
            hangUpView.isHidden = true
        case .audioKickedOut:
            message = "被踢出上麦"
            tipType = .close
            hangUpView.isHidden = true
        default:
            break;
        }
        let image = UIImage(name: "mic")
        showMessageTipView(image: image,
                           message: message,
                           type: tipType)
    }
    public func liveManager(_ manager: DBYLiveManager!, denyChatStatusChange isDeny: Bool) {
        forbiddenButton.isHidden = !isDeny
        chatBar.isHidden = isDeny
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
    public func liveManager(_ manager: DBYLiveManager!, cameraRequest index: UInt) {
        inviteIndex = Int(index)
        print("前方还有 \(index) 人正在等待上台。")
        let message = "前方还有 \(index) 人正在等待上台。"
        let image = UIImage(name: "camera-request-icon")
        showMessageTipView(image: image,
                           message: message,
                           type: .close)
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
    public func liveManager(_ manager: DBYLiveManager!, cameraStateChange state: DBYCameraState) {
        if state == .normal {
            roomControlbar.setCameraState(state: .normal)
        }
        if state == .invite {
            roomControlbar.setCameraState(state: .invite)
        }
        if state == .joined {
            roomControlbar.setCameraState(state: .joined)
        }
    }
    public func willReceivedVideoData(_ liveManager: DBYLiveManager!, userId uid: String!) {
        if uid == authinfo?.teacherId {
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
        let count = allChatList.count
        allChatList.append(dict)
        let index = IndexPath(row:count, section:0)
        chatListView.beginUpdates()
        chatListView.insertRows(at: [index], with: .automatic)
        chatListView.endUpdates()
        if count > 0 {
            chatListView.scrollToRow(at: index, at: .bottom, animated: true)
        }
    }
}
extension DBYLiveController:DBYNetworkTipViewDelegate {
    func confirmClick(_ owner: DBYNibView) {
        netTipView.hidden()
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
        chatBar.endInput()
        send(message: message)
    }
    
    func chatBarWillShowInputView(rect: CGRect, duration: TimeInterval) {
        if isLandscape() {
            return
        }
        let frame = CGRect(x: chatBarFrame.minX,
                           y: chatBarFrame.minY - rect.height + iphoneXBottom,
                           width: chatBarFrame.width,
                           height: chatBarFrame.height - iphoneXBottom)
        
        let frame2 = CGRect(x: 0,
                            y: 0,
                            width: chatListViewFrame.width,
                            height: frame.minY)
        
        UIView.animate(withDuration: duration, animations: {
            self.chatBar.frame = frame
            self.chatListView.frame = frame2
            let count = self.allChatList.count
            if count > 0 {
                self.chatListView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: false)
            }
        })
    }
    
    func chatBarWillDismissInputView(duration: TimeInterval) {
        if isLandscape() {
            return
        }
        chatBar.frame = chatBarFrame
        chatListView.frame = chatListViewFrame
    }
}
extension DBYLiveController {
    
}
//MARK: - DBYMessageTipViewDelegate
extension DBYLiveController: DBYMessageTipViewDelegate {
    func messageTipViewAcceptInvite(owner: DBYMessageTipView) {
        let loading = UIImage(name: "icon-loading")
        let message = "正在接通中"
        
        showMessageTipView(image: loading, message: message, type: .close)
        liveManager.accept {[weak self] (finished) in
            if !finished {
                let image = UIImage(name: "mic")
                self?.showMessageTipView(image: image,
                                        message: "已经达到最大上麦人数",
                                        type: .close)
            }
        }
    }
    
    func messageTipViewRefuseInvite(owner: DBYMessageTipView) {
        liveManager.refuse { (finished) in
            
        }
    }
    func messageTipViewDidClick(owner: DBYMessageTipView) {
        newMessageCount = 0
        chatListView.reloadData()
        let count = allChatList.count
        if count > 0 {
            chatListView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    func messageTipViewWillDismiss(owner: DBYMessageTipView) {
        
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
            weakSelf?.hangUpView.dismiss()
            weakSelf?.liveManager.closeMicrophone()
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
        updateMicListViewFrame()
    }
}
//MARK: - DBYBottomBarDelegate
extension DBYLiveController: DBYBottomBarDelegate {
    func chatButtonClick(owner: DBYBottomBar) {
        showChatView()
    }
    
    func voteButtonClick(owner: DBYBottomBar) {
        showVoteView()
    }
    
    func fullscreenButtonClick(owner: DBYBottomBar) {
        toLandscape()
    }
    
    func stateDidChange(owner: DBYBottomBar, state: DBYPlayState) {
        if state == .pause {
            recoverManager()
            netTipView.hidden()
            hiddenVideoTipView()
        }
        if state == .play {
            pauseManager()
            videoTipView.set(type: .pause)
            showVideoTipView()
        }
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
        settingClick()
    }
}
extension DBYLiveController: DBYSettingViewDelegate {
    func settingView(owner: DBYSettingView, didSelectedItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        }
        if indexPath.section == 1 {
            
        }
    }
}
extension DBYLiveController: DBYVideoTipViewDelegate {
    func buttonClick(owner: DBYVideoTipView, type: DBYTipType) {
        if type == .audio {
            audioBtn.isSelected = true
            liveManager.setReceiveVideoWith(true) { (message) in
                print(message ?? "setReceiveVideoWith")
            }
            hiddenVideoTipView()
        }
        if type == .pause {
            recoverManager()
        }
    }
}
extension DBYLiveController: DBYCommentCellDelegate {
    func commentCell(cell: UITableViewCell, didPressWith index: IndexPath) {
        let chatDict = allChatList[index.row]
        let name:String = chatDict["userName"] as? String ?? ""
        chatBar.append(text: "@" + name)
    }
}
