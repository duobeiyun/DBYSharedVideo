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
    let estimatedRowHeight: CGFloat = 44
    
    var roomConfig: DBYRoomConfig?
    
    lazy var qaList: [[String:Any]] = [[String:Any]]()
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        let classType = type(of: self)
        let bundle = Bundle(for: classType)
        let fromNib = UINib(nibName: fromIdentifier, bundle: bundle)
        let toNib = UINib(nibName: toIdentifier, bundle: bundle)
        
        t.backgroundColor = DBYStyle.lightGray
        t.separatorStyle = .none
        t.allowsSelection = false
        t.estimatedRowHeight = estimatedRowHeight;
        t.register(fromNib, forCellReuseIdentifier: fromIdentifier)
        t.register(toNib, forCellReuseIdentifier: toIdentifier)
        
        return t
    }()
    override func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(tableView)
    }
    func set(list: [[String:Any]]) {
        qaList = list
        tableView.reloadData()
    }
    func append(dict: [String:Any]) {
        qaList.append(dict)
        tableView.reloadData()
    }
    func remove(questionId: String) {
        var index:Int = -1
        for i in 0..<qaList.count {
            let dict = qaList[i]
            let msgId = dict["id"] as? String
            if msgId == questionId {
                index = i
                break
            }
        }
        if index < 0 {
            return
        }
        qaList.remove(at: index)
        tableView.reloadData()
    }
}
extension DBYChatListView: UITableViewDelegate {
    
}
extension DBYChatListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return qaList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let imageView = UIImageView()
        imageView.image = UIImage(name: "dottedline")
        imageView.frame = CGRect(x: 8, y: 4, width: tableView.frame.width - 16, height: 22)
        let view = UIView()
        view.addSubview(imageView)
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:DBYCommentCell = DBYCommentCell()
        
        let chatDict = qaList[indexPath.section]
        
        let value = chatDict["value"] as? String
        guard let data = value?.data(using: .utf8) else {
            return cell
        }
        guard let valueDict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] else {
            return cell
        }
        var infoDict:[String:Any]?
        if indexPath.row == 0 {
            infoDict = valueDict["questionInfo"] as? [String:Any]
        }else {
            infoDict = valueDict["answerInfo"] as? [String:Any]
        }
        let role:String = infoDict?["role"] as? String ?? ""
        let name:String = infoDict?["username"] as? String ?? ""
        let message:String = infoDict?["msg"] as? String ?? ""
        
        if role == "1" {
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
        let badge = badgeUrl(role: Int(role) ?? 0, badgeDict: roomConfig?.badge)
        let width = cell.bounds.width - 100
        let attMessage = beautifyMessage(message: message, maxWidth: width)
        cell.setText(name: name,
                     message: attMessage,
                     avatarUrl: avatarUrl,
                     badge: badge)
        
        return cell
    }
}
