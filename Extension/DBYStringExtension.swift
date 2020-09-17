//
//  DBYStringExtension.swift
//  DBY1VN
//
//  Created by 钟凡 on 2018/10/12.
//  Copyright © 2018 钟凡. All rights reserved.
//

import UIKit

extension String {
    public static func playTime(time:Int) -> String {
        let second = time % 60
        let minute = (time / 60)
        if minute > 100 {
            return String(format: "%03d:%02d", minute, second)
        }
        return String(format: "%02d:%02d", minute, second)
    }
    public static func dateStrFromInt(_ intTime: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: intTime / 1000)
        let dfmt = DateFormatter()
        
        dfmt.dateFormat = "yyyy/MM/dd HH:mm";
        return dfmt.string(from: date)
    }
    
    func height(withMaxWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withMaxHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    func substring(with range: NSRange) -> String {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(startIndex, offsetBy: range.location + range.length)
        return String(self[start..<end])
    }
}
extension NSAttributedString {
    func height(withMaxWidth width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let framesetter = CTFramesetterCreateWithAttributedString(self)
        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, size, nil)
        return ceil(frameSize.height)
    }
    func width(withMaxHeight height: CGFloat) -> CGFloat {
        let size = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        
        return ceil(boundingBox.width)
    }
}
