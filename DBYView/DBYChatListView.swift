//
//  DBYChatListView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/1/10.
//  Copyright © 2020 钟凡. All rights reserved.
//

import UIKit
import DBYSDK_dylib

class DBYChatListView: DBYView {
    let fromIdentifier: String = "DBYCommentFromCell"
    let toIdentifier: String = "DBYCommentToCell"
    let zanCell = "DBYZanCell"
    let estimatedRowHeight: CGFloat = 44
    
    var tipView: DBYTipClickView?
    
    var roomConfig: DBYRoomConfig?
    var newMessageCount:Int = 0
    var showTip:Bool = false
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
    override func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
        chatDict["size"] = UIScreen.main.bounds.size
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
