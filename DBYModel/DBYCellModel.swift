//
//  DBYCellModel.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/3/19.
//

import Foundation
import DBYSDK_dylib

struct DBYCommentCellModel {
    var name: String?
    var message: NSAttributedString?
    var avatarUrl: String?
    var badge: (String?, String?) = ("", "")
    var identifier: String = "identifier"
    var bubbleImage: UIImage?
    var textColor: UIColor?
}
class DBYCellModel {
    static let fromIdentifier: String = "DBYCommentFromCell"
    static let toIdentifier: String = "DBYCommentToCell"
    static let zanCell = "DBYZanCell"
    
    static func commentCellModel(dict:[String:Any], roomConfig: DBYRoomConfig?) -> DBYCommentCellModel {
        var model = DBYCommentCellModel()
        
        let role:Int = dict["role"] as? Int ?? 0
        let isOwner:Bool = dict["isOwner"] as? Bool ?? false
        let name:String = dict["userName"] as? String ?? ""
        let message:String = dict["message"] as? String ?? ""
        let size:CGSize = dict["size"] as? CGSize ?? .zero
        
        let isPortrait = size.width < size.height
        
        if isOwner {
            model.identifier = toIdentifier
            if isPortrait {
                model.bubbleImage = UIImage(name: "chat-to-bubble")
            }else {
                model.bubbleImage = UIImage(name: "chat-to-dark-bubble")
            }
        }else {
            model.identifier = fromIdentifier
            if isPortrait {
                model.bubbleImage = UIImage(name: "chat-from-bubble")
            }else {
                model.bubbleImage = UIImage(name: "chat-from-dark-bubble")
            }
        }
        if isPortrait {
            model.textColor = DBYStyle.dark
        }else {
            model.textColor = UIColor.white
        }
        
        let avatarUrl = DBYUrlConfig.shared().staticUrl(withSourceName: roomConfig?.avatar ?? "")
        let badge = badgeUrl(role: role, badgeDict: roomConfig?.badge)
        let width = size.width - 100
        let attMessage = beautifyMessage(message: message, maxWidth: width)
        
        model.name = name
        model.avatarUrl = avatarUrl
        model.badge = badge
        model.message = attMessage
        
        return model
    }
}
