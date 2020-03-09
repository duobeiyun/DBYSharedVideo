//
//  DBYUtils.swift
//  DBYSDK_dylib
//
//  Created by 钟凡 on 2020/2/21.
//

import Foundation

let currentBundle = Bundle(identifier: "com.duobei.DBYSharedVideo")
let regexString = "(\\[:(.*?)\\])"

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
func beautifyUserName(role:Int, name:String, showBadge: Bool) -> NSAttributedString? {
    var imageName:String = ""
    let attName = NSMutableAttributedString()
    switch role {
    case 1:
        imageName = "icon-teacher"
    case 2:
        imageName = "icon-student"
    case 4:
        imageName = "icon-assistant"
    default:
        break
    }
    if showBadge {
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: -2.5, width: 48, height: 13)
        attachment.image = UIImage(name: imageName)
        let iconString = NSAttributedString(attachment: attachment)
        attName.append(iconString)
    }
    let nameString = NSAttributedString(string: " \(name)")
    attName.append(nameString)
    return attName
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
