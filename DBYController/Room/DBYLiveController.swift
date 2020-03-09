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
    
    let btnWidth: CGFloat = 60
    let btnHeight: CGFloat = 30
    let tipViewHeight:CGFloat = 38
    let forbiddenBtnHeight:CGFloat = 40
    
    lazy var liveManager:DBYLiveManager = DBYLiveManager()
    
    lazy var chatBar = DBYChatBar()
    lazy var voteView:DBYVoteView = DBYVoteView()
    lazy var announcementView = DBYAnnouncementView()
    lazy var messageTipView = DBYMessageTipView()
    lazy var micListView = DBYMicListView()
    lazy var hangUpView = DBYHangUpView()
    lazy var actionSheetView = DBYActionSheetView()
    lazy var forbiddenButton = DBYButton()
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
    
    lazy var inputVC = DBYInputController()
    lazy var loadingView = DBYVideoLoadingView()
    lazy var watermarkView = DBYWatermarkView()
    lazy var marqueeView = DBYMarqueeView()
    lazy var questionView = DBYChatListView()
    
    var roomConfig: DBYRoomConfig?
    var sensitiveWords: [String]?
    var animationTimer: Timer?
    var questions: [[String:Any]]?
    
    //MARK: - override functions
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        chatListView.delegate = self
        chatListView.dataSource = self
        netTipView.delegate = self
        chatBar.delegate = self
        roomControlbar.delegate = self
        messageTipView.delegate = self
        micListView.delegate = self
        hangUpView.delegate = self
        topBar.delegate = self
        bottomBar.delegate = self
        settingView.delegate = self
        videoTipView.delegate = self
        scrollContainer.delegate = self
        
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
        
        mainView.addSubview(loadingView)
        mainView.addSubview(marqueeView)
        mainView.addSubview(watermarkView)
        
        view.addSubview(messageTipView)
        view.addSubview(micListView)
        view.addSubview(hangUpView)
        view.addSubview(actionSheetView)
    }
    override func addActions() {
        super.addActions()
        inputButton.addTarget(self, action: #selector(showChatBar), for: .touchUpInside)
        audioBtn.addTarget(self, action: #selector(audioOnly), for: .touchUpInside)
    }
    override func setupStaticUI() {
        super.setupStaticUI()
        
        topBar.set(authinfo?.courseTitle)
        settingView.set(buttons: [audioBtn])
        roomControlbar.append(title: "互动")
        scrollContainer.append(view: chatContainer)
        chatBar.emojiImageDict = emojiImageDict
        chatBar.backgroundColor = UIColor.white
        hangUpView.isHidden = true
        messageTipView.isHidden = true
        actionSheetView.isHidden = true
        forbiddenButton.isHidden = true
        micListView.isHidden = true
        let volume = DBYSystemControl.shared.getVolume()
        hangUpView.setProgress(value: volume)
        forbiddenButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        forbiddenButton.setTitle(" 已开启全体禁言", for: .normal)
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
    }
    override func updateFrame() {
        super.updateFrame()
        
        chatBar.frame = chatBarFrame
        hangUpView.frame = hangUpViewFrame
        announcementView.frame = announcementViewFrame
        actionSheetView.frame = view.bounds
        messageTipView.frame = smallPopViewFrame
        micListView.frame = micListViewFrame
        forbiddenButton.frame = forbiddenBtnFrame
        loadingView.frame = mainView.bounds
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
        unowned let weakSelf = self
        liveManager.enterRoom(withAuthJson: authinfo?.authinfoString, completeHandler: { (message, type) in
            weakSelf.bottomBar.set(state: .play)
            if let reachability = weakSelf.internetReachability {
                weakSelf.dealWith(reachability: reachability)
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
        chatListView.reloadData()
        
        if showTip {
            newMessageCount += array.count
            let image = UIImage(name: "message-tip")
            let message = "\(newMessageCount)条新消息"
            showMessageTipView(image: image, message: message, type: .click)
            return
        }
        if count > 0 {
            chatListView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    @objc func hiddenActionSheet() {
        actionSheetView.dismiss()
    }
    @objc func hangup() {
        hangUpView.dismiss()
        liveManager.closeMicrophone()
        actionSheetView.dismiss()
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
        unowned let weakSelf = self
        inputVC.sendTextBlock = {text in
            weakSelf.send(message: text)
        }
        present(inputVC, animated: true, completion: nil)
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

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        chatBar.endInput()
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == scrollContainer {
            let index = Int(scrollView.contentOffset.x / scrollContainerFrame.width)
            roomControlbar.scroll(at: index)
        }
        if scrollView == chatListView {
            let delta = scrollView.contentSize.height - scrollView.contentOffset.y
            showTip = delta > scrollView.bounds.height
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
        cell.indexPath = indexPath
        cell.delegate = self
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
extension DBYLiveController: DBYLiveManagerDelegate {
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
            showMarqueeView()
        }
    }
    public func liveManagerDidKickedOff(_ manager: DBYLiveManager!) {
        let button1 = DBYActionButton(style: .confirm)
        let button2 = DBYActionButton(style: .cancel)
        
        button1.setTitle("重新登录", for: .normal)
        button2.setTitle("退出登录", for: .normal)
        
        button1.addTarget(self, action: #selector(enterRoom), for: .touchUpInside)
        button2.addTarget(self, action: #selector(exitRoom), for: .touchUpInside)
        
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
            message = name + "邀请你上麦"
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
extension DBYLiveController: DBYRoomControlbarDelegate {
    func roomControlBar(owner: DBYRoomControlbar, didClickCameraRequest selected: Bool) {
        if selected {
            liveManager.requestToOpenCamera()
        }else {
            liveManager.requestToCloseCamera()
        }
    }
    
    func roomControlBarDidSelected(owner: DBYRoomControlbar, index: Int) {
        scrollContainer.scroll(at: index)
    }
    
}
//MARK: - DBYMessageTipViewDelegate
extension DBYLiveController: DBYMessageTipViewDelegate {
    func messageTipViewAcceptInvite(owner: DBYMessageTipView) {
        let loading = UIImage(name: "icon-loading")
        let message = "正在接通中"
        
        showMessageTipView(image: loading, message: message, type: .close)
        liveManager.accept {[unowned self] (finished) in
            if !finished {
                let image = UIImage(name: "mic")
                self.showMessageTipView(image: image,
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
        let button1 = DBYActionButton(style: .confirm)
        let button2 = DBYActionButton(style: .cancel)
        
        button1.setTitle("确定", for: .normal)
        button2.setTitle("取消", for: .normal)
        
        button1.addTarget(self, action: #selector(hangup), for: .touchUpInside)
        button2.addTarget(self, action: #selector(hiddenActionSheet), for: .touchUpInside)
        
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
