//
//  DBYUtils.swift
//  DBYSDK_dylib
//
//  Created by 钟凡 on 2020/2/21.
//

import Foundation
import DBYSDK_dylib

let currentBundle = Bundle(identifier: "com.duobei.DBYSharedVideo")
let regexString = "(\\[:(.*?)\\])"

public func getIphonexEdge() -> UIEdgeInsets {
    var iphoneXTop:CGFloat = 20
    var iphoneXLeft:CGFloat = 0
    var iphoneXRight:CGFloat = 0
    var iphoneXBottom:CGFloat = 0
    if isIphoneXSeries() {
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .landscapeLeft || orientation == .landscapeRight{
            iphoneXLeft = 44
            iphoneXRight = 44
        }
        if orientation == .portrait {
            iphoneXTop = 44
        }
        iphoneXBottom = 34
    }
    return UIEdgeInsets(top: iphoneXTop, left: iphoneXLeft, bottom: iphoneXBottom, right: iphoneXRight)
}
public func isIphoneXSeries() -> Bool {
    var systemInfo = utsname()
    uname(&systemInfo)
    
    let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
        return String(cString: ptr)
    }
    if (platform == "iPhone10,3" ||
        platform == "iPhone10,6" ||
        platform == "iPhone11,2" ||
        platform == "iPhone11,4" ||
        platform == "iPhone11,6" ||
        platform == "iPhone11,8" ||
        platform == "iPhone12,1" ||
        platform == "iPhone12,3" ||
        platform == "iPhone12,5") {
        return true
    }else {
        return false
    }
}
public func isIpadSeries() -> Bool {
    var systemInfo = utsname()
    uname(&systemInfo)
    
    let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
        return String(cString: ptr)
    }
    if (platform == "iPad4,1" || platform == "iPad4,2" || platform == "iPad4,3" || platform == "iPad4,4" || platform == "iPad4,5" || platform == "iPad4,6" || platform == "iPad4,7" || platform == "iPad4,8" || platform == "iPad4,9" || platform == "iPad5,1" || platform == "iPad5,2" || platform == "iPad5,3" || platform == "iPad5,4" || platform == "iPad6,3" || platform == "iPad6,4" || platform == "iPad6,7" || platform == "iPad6,8") {
        return true
    }else {
        return false
    }
}
func beautifyMessage(message: String, maxWidth: CGFloat) -> NSAttributedString {
    let attMessage = NSMutableAttributedString(string: message)
    do {
        let regex = try NSRegularExpression(pattern: regexString, options: [])
        var results = regex.matches(in: message, options: [], range: NSRange(location: 0, length: message.count))
        results = results.reversed()
        for result in results {
            let range = result.range
            let emojiName = message.substring(with: range)
            if emojiName == "[:分割线]" {
                let imageName = "dottedline"
                let attachment = NSTextAttachment()
                attachment.bounds = CGRect(x: 0, y: 0, width: maxWidth, height: 22)
                attachment.image = UIImage(name: imageName)
                let attString = NSAttributedString(attachment: attachment)
                attMessage.replaceCharacters(in: range, with: attString)
            }
            if let imageName = emojiNameDict[emojiName] {
                let attachment = NSTextAttachment()
                attachment.bounds = CGRect(x: 0, y: 0, width: 36, height: 36)
                attachment.image = UIImage(name: imageName)
                let attString = NSAttributedString(attachment: attachment)
                attMessage.replaceCharacters(in: range, with: attString)
            }
        }
    } catch let error {
        print(error)
    }
    return attMessage
}
///1:老师 2:学生 3:管理员 4:助教 6:家长
func roleString(role: Int) -> String {
    var str = ""
    switch role {
        case 1:
            str = "老师"
        case 2:
            str = "学生"
        case 3:
            str = "管理员"
        case 4:
            str = "助教"
        case 6:
            str = "家长"
        default:
            str = ""
    }
    return str
}
func badgeUrl(role: Int, badgeDict:[String: Any]?) -> (String?, String?) {
    let disable = badgeDict?["disabled"] as? Bool ?? false
    if disable {
        return (nil, nil)
    }
    var imageKey:String = ""
    switch role {
        case 1:
            imageKey = "teacher"
        case 2:
            imageKey = "student"
        case 4:
            imageKey = "assistant"
        default:
            break
    }
    let placeHolderName = "icon-" + imageKey
    
    var resourceName: String = ""
    if let items = badgeDict?["items"] as? [String: String] {
        resourceName = items[imageKey] ?? ""
    }
    let serverUrl = DBYUrlConfig.shared().staticUrl(withSourceName: resourceName)
    return (serverUrl, placeHolderName)
}
func isPortrait() -> Bool {
    let orientation = UIApplication.shared.statusBarOrientation
    if orientation.isPortrait {
        return true
    }else {
        return false
    }
}
func isLandscape() -> Bool {
    let orientation = UIApplication.shared.statusBarOrientation
    if orientation.isLandscape {
        return true
    }else {
        return false
    }
}
