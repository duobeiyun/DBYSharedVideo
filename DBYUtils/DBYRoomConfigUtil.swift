//
//  DBYRoomConfigUtil.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2019/12/6.
//  Copyright © 2019 钟凡. All rights reserved.
//

import UIKit
import DBYSDK_dylib

class DBYRoomConfigUtil: NSObject {
    static let shared = DBYRoomConfigUtil()
    var savePath: URL?
    
    override init() {
        super.init()
        let fileManager = FileManager.default
        if let document = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.savePath = document.appendingPathComponent("config.json")
        }
    }
    
    func getSensitiveWord(name: String?, completion: @escaping ([String]?) -> ()) {
        if name == nil {
            return
        }
        let requestUrl = DBYUrlConfig.shared().staticUrl() + "/slides_pic/" + name!
        DBYRequestUtil.getRequestWithURL(requestUrl, successHandler: { (data) in
            var dict:[String:Any] = [String:Any]()
            do {
                dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : Any]
            }catch {
                print("JSONSerialization error")
            }
            let array = dict["sensitiveWords"] as? [String]
            completion(array)
        }) { (error) in
            completion(nil)
        }
    }
    func getRoomConfig(roomId: String, completion: @escaping (DBYRoomConfig?) -> ()) {
        let url = DBYUrlConfig.shared().roomConfigUrl(withRoomID: roomId)
        DBYRequestUtil.getRequestWithURL(url, successHandler: { (data) in
            var dict:[String:Any] = [String:Any]()
            do {
                dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : Any]
            }catch {
                print("JSONSerialization error")
            }
            var configDict = [String:Any]()
            if let dataDict  = dict["data"] as? [String:Any] {
                configDict = dataDict
            }
            self.saveRoomConfig(dict: configDict)
            let roomConfig = DBYRoomConfig(with: configDict)
            completion(roomConfig)
        }) { (error) in
            let roomConfig = self.getRoomConfig(roomId: roomId)
            completion(roomConfig)
        }
    }
    func getRoomConfig(roomId: String) -> DBYRoomConfig {
        return DBYRoomConfig(with: [String : Any]())
    }
    private func saveRoomConfig(dict: [String : Any]) {
        guard let path = savePath else {
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
            try data.write(to: path)
        }catch let error {
            print(error)
        }
    }
}
