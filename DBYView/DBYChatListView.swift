//
//  DBYChatListView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/1/10.
//  Copyright © 2020 钟凡. All rights reserved.
//

import UIKit
import DBYSDK_dylib

let emojiImageDict: [String:String] = [
    "hello": "[:问好]",
    "love": "[:比心]",
    "smile": "[:微笑]",
    "happy": "[:开心]",
    "sad": "[:伤心]",
    "yes": "[:是的]",
    "no": "[:反对]",
    "question": "[:疑问]",
    "angry": "[:气愤]",
    "bye": "[:再见]",
    "like": "[:喜欢]",
    "fight": "[:加油]",
    "cry": "[:流泪]",
    "sorry": "[:抱歉]",
    "loudly": "[:大笑]",
    "strive": "[:努力]",
    "amazing": "[:惊讶]",
    "hum": "[:哼]"
]
let emojiNameDict: [String:String] = [
    "[:问好]": "hello",
    "[:比心]": "love",
    "[:微笑]": "smile",
    "[:开心]": "happy",
    "[:伤心]": "sad",
    "[:是的]": "yes",
    "[:反对]": "no",
    "[:疑问]": "question",
    "[:气愤]": "angry",
    "[:再见]": "bye",
    "[:喜欢]": "like",
    "[:加油]": "fight",
    "[:流泪]": "cry",
    "[:抱歉]": "sorry",
    "[:大笑]": "loudly",
    "[:努力]": "strive",
    "[:惊讶]": "amazing",
    "[:哼]": "hum"
]

class DBYChatListView: DBYView {
    let fromIdentifier: String = "DBYCommentFromCell"
    let toIdentifier: String = "DBYCommentToCell"
    let zanCell = "DBYZanCell"
    let estimatedRowHeight: CGFloat = 44
    
    lazy var chatBar = DBYChatBar()
    lazy var flButton = DBYForbiddenButton.landscapeView()
    lazy var fpButton = DBYForbiddenButton.portraitView()
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
    var tipView: DBYTipClickView?
    
    var roomConfig: DBYRoomConfig?
    var newMessageCount:Int = 0
    var chatBarOffset: CGFloat = 0
    var showTip:Bool = false
    var isChatForbidden:Bool = false
    var showChatbar:Bool = false
    var tipViewSafeSize: CGSize = .zero
    var tipViewPosition: DBYTipView.Position = [.bottom, .center]
    
    var allChatList: [[String:Any]] = [[String:Any]]() {
        didSet {
            if allChatList.count > 0 {
                tableView.backgroundView = nil
            }
        }
    }
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        let classType = type(of: self)
        let bundle = Bundle(for: classType)
        let fromNib = UINib(nibName: fromIdentifier, bundle: currentBundle)
        let toNib = UINib(nibName: toIdentifier, bundle: currentBundle)
        let zanNib = UINib(nibName: zanCell, bundle: currentBundle)
        
        t.backgroundColor = .clear
        t.separatorStyle = .none
        t.allowsSelection = false
        t.estimatedRowHeight = estimatedRowHeight;
        t.register(fromNib, forCellReuseIdentifier: fromIdentifier)
        t.register(toNib, forCellReuseIdentifier: toIdentifier)
        t.register(zanNib, forCellReuseIdentifier: zanCell)
        
        return t
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fpButton?.removeFromSuperview()
        flButton?.removeFromSuperview()
        inputButton.removeFromSuperview()
        chatBar.removeFromSuperview()
        
        guard let sv = superview else {
            return
        }
        let edge = getIphonexEdge()
        let chatBarHeight = showChatbar ? 48 + edge.bottom:0
        let fbly = sv.landscapeFrame.height - 24 - edge.bottom
        let fblx = (sv.landscapeFrame.width - 160) * 0.5
        
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .portrait {
            if isChatForbidden {
                addSubview(fpButton!)
            }else {
                addSubview(chatBar)
            }
            
            tableView.frame = CGRect(x: 0, y: 0, width: sv.portraitFrame.width, height: sv.portraitFrame.height - chatBarHeight)
            chatBar.frame = CGRect(x: 0, y: sv.portraitFrame.height - chatBarHeight, width: sv.portraitFrame.width, height: chatBarHeight)
            fpButton?.frame = CGRect(x: 4, y: sv.portraitFrame.height, width: sv.portraitFrame.width - 8, height: 44)
            inputButton.frame = .zero
        }
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            if isChatForbidden {
                addSubview(fpButton!)
            }else {
                addSubview(inputButton)
            }
            tableView.frame = CGRect(x: 0, y: 0, width: sv.landscapeFrame.width, height: sv.landscapeFrame.height)
            chatBar.frame = .zero
            flButton?.frame = CGRect(x: fblx, y: fbly, width: 160, height: 24)
            inputButton.frame = CGRect(x: 10, y: sv.landscapeFrame.width - 24 - edge.bottom, width: 84, height: 24)
        }
    }
    override func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        chatBar.emojiImageDict = emojiImageDict
        chatBar.backgroundColor = UIColor.white
        flButton?.isHidden = true
        
        addSubview(tableView)
    }
    
    func append(dict: [String:Any]) {
        let count = allChatList.count
        allChatList.append(dict)
        let index = IndexPath(row:count, section:0)
        tableView.beginUpdates()
        tableView.insertRows(at: [index], with: .automatic)
        tableView.endUpdates()
        if count > 0 {
            tableView.scrollToRow(at: index, at: .bottom, animated: true)
        }
    }
    func reloadData() {
        tableView.reloadData()
        scrollToBottom()
    }
    func clearAll() {
        showTip = false
        newMessageCount = 0
        allChatList.removeAll()
        tableView.reloadData()
        scrollToBottom()
    }
    func showInputView(offset: CGFloat) {
        chatBarOffset = offset
        let edge = getIphonexEdge()
        let frame1 = chatBar.portraitFrame.offsetBy(dx: 0, dy: edge.bottom - offset)
        let frame2 = portraitFrame.resizeBy(sub_w: 0, sub_h: offset - edge.bottom)
        
        UIView.animate(withDuration: 0.25) {
            self.chatBar.portraitFrame = frame1
            self.tableView.portraitFrame = frame2
        }
        scrollToBottom()
    }
    func hiddenInputView() {
        let edge = getIphonexEdge()
        let chatBarHeight = 48 + edge.bottom
        
        chatBar.portraitFrame = CGRect(x: 0, y: bounds.height - chatBarHeight, width: bounds.width, height: chatBarHeight)
        tableView.portraitFrame = bounds.resizeBy(sub_w: 0, sub_h: chatBarHeight)
        scrollToBottom()
    }
    func scrollToTop() {
        
    }
    func scrollToBottom() {
        let count = self.allChatList.count
        if count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: false)
        }
        DBYTipView.removeTipViews(type: .click, on: self)
    }
    func appendChats(array: [[String:Any]]) {
        allChatList += array
        let maxCount = allChatList.count - 1000
        if maxCount > 0 {
            for _ in 0..<maxCount {
                allChatList.removeFirst()
            }
        }
        tableView.reloadData()
        let count = allChatList.count
        if showTip {
            newMessageCount += array.count
            let image = UIImage(name: "message-tip")
            let message = "\(newMessageCount)条新消息"
            DBYTipView.removeTipViews(type: .click, on: self)
            guard let tipView = DBYTipView.loadView(type: .click) else {
                return
            }
            addSubview(tipView)
            if let p = tipView as? DBYTipViewUIProtocol {
                p.show(icon: image, message: message)
                p.setPosition(position: tipViewPosition)
                p.setContentOffset(size: tipViewSafeSize)
            }
            guard let clickView = tipView as? DBYTipClickView else {
                return
            }
            weak var weakView = clickView
            weak var weakSelf = self
            clickView.clickBlock = {
                weakView?.removeFromSuperview()
                weakSelf?.newMessageCount = 0
                weakSelf?.showTip = false
                let count = weakSelf?.allChatList.count ?? 1
                if count > 0 {
                    weakSelf?.tableView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }else if count > 0 {
            tableView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: true)
        }
    }
}
extension DBYChatListView: UITableViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stoppedScrolling(scrollView: scrollView)
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        stoppedScrolling(scrollView: scrollView)
    }
    func stoppedScrolling(scrollView: UIScrollView) {
        if scrollView == tableView {
            let delta = scrollView.contentSize.height - scrollView.contentOffset.y
            //浮点数可能不准，+1减少误差
            showTip = delta > tableView.bounds.height + 1
            if !showTip {
                newMessageCount = 0
                DBYTipView.removeTipViews(type: .click, on: self)
            }
        }
    }
}
extension DBYChatListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = allChatList.count
        if count > 0 {
            tableView.backgroundView = nil
        }else {
            let chatTipView = DBYEmptyView(image: UIImage(name: "icon-empty-status-1"), message: "聊天消息为空")
            tableView.backgroundView = chatTipView
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
        let size = UIScreen.main.bounds.size
        chatDict["size"] = size
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
