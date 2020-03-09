//
//  DBYAuthInfoSerialization.swift
//  DBY1VNUI
//
//  Created by 钟凡 on 2019/3/28.
//  Copyright © 2019 钟凡. All rights reserved.
//

import Foundation

class DBYAuthInfoSerialization {
    
    /// 这个函数可以将 authinfo 字符串(json)展开获取需要的字段
    ///
    /// - Parameters:
    ///     - authStr: authinfo 字符串
    /// - Returns:
    ///     - hasVideo: 是否有视频
    ///     - titleString: 课程标题
    ///     - merchantString: 机构名
    ///     - timeString: 课程开始时间-结束时间
    ///     - courseType: 课程类型 1:1v1, 2:1vn
    static func extendAuthinfo(authStr:String?) -> (Bool, String, String, String, Int) {
        let data = authStr?.data(using: String.Encoding.utf8)
        var dict:[String:Any] = [String:Any]()
        var hasVideo:Bool = false
        var timeString:String = "0000-00-00 ~ 0000-00-00"
        var titleString:String = "~"
        var merchantString:String = "~"
        var courseType:Int = 0
        do {
            dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : Any]
        }catch {
            print("JSONSerialization error")
        }
        if let courseInfo = dict["courseInfo"] as? [String:Any] {
            if let isVideo = courseInfo["roomVideo"] as? String {
                hasVideo = isVideo == "true"
            }
            var startTimeStr:String = "0000/00/00"
            var endTimeStr:String = "0000/00/00"
            if let courseStartTime = courseInfo["courseStartTime"] as? TimeInterval {
                startTimeStr = String.dateStrFromInt(courseStartTime)
            }
            if let courseEndTime = courseInfo["courseEndTime"] as? TimeInterval {
                endTimeStr = String.dateStrFromInt(courseEndTime)
            }
            if let courseTitle = courseInfo["courseTitle"] as? String {
                let titleData = Data(base64Encoded: courseTitle, options: [.ignoreUnknownCharacters]) ?? Data()
                titleString = String(data: titleData, encoding: String.Encoding.utf8) ?? titleString
            }
            if let merchantName = courseInfo["merchantName"] as? String {
                let merchantData = Data(base64Encoded: merchantName, options: [.ignoreUnknownCharacters]) ?? Data()
                merchantString = String(data: merchantData, encoding: String.Encoding.utf8) ?? merchantString
            }
            if let courseTypeValue = courseInfo["courseType"] as? Int {
                courseType = courseTypeValue
            }
            
            timeString = "\(startTimeStr) ~ \(endTimeStr)"
        }
        return (hasVideo, titleString, merchantString, timeString, courseType)
    }
}
