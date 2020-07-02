//
//  DBYMediaManager.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/7/1.
//

import Foundation
import DBYSDK_dylib

protocol DBYInteractionStateObserver: NSObjectProtocol {
    func requestInteraction(owner: DBYInteractionManager, state: DBYInteractionState, type: DBYInteractionType)
    func receiveInteraction(owner: DBYInteractionManager, state: DBYInteractionState, type: DBYInteractionType, model: DBYInteractionModel?)
}
protocol DBYInteractionDataObserver: NSObjectProtocol {
    
}
class DBYInteractionManager {
    weak var delegate:DBYInteractionViewDelegate?
    weak var dataObserver:DBYInteractionDataObserver?
    weak var stateObserver:DBYInteractionStateObserver?
    
    private lazy var models:[DBYInteractionModel] = [DBYInteractionModel]()
    private lazy var audioList:[DBYInteractionModel] = [DBYInteractionModel]()
    private lazy var videoList:[DBYInteractionModel] = [DBYInteractionModel]()
    
    //用于更新数据
    var type: DBYInteractionType = .audio
    //用于切换
    var tmpType: DBYInteractionType = .audio
    var state: DBYInteractionState = .normal
    
    var userId:String?
    var userName:String?
    var userRole:Int = 0
    
    //消息触发
    func set(models:[DBYInteractionModel], for type:DBYInteractionType) {
        if type == .audio {
            self.audioList = models
        }
        if type == .video {
            self.videoList = models
        }
        var count = 0
        var userModel:DBYInteractionModel?
        for model in models {
            if model.state == .joined {
                count += 1;
            }
            if model.userId == userId {
                userModel = model
            }
        }
        let preState = state
        //被邀请上台或上麦
        if userModel != nil && userModel?.state == .inqueue && state == .normal {
            state = .inqueue
        }else
        //上台或上麦
        if userModel != nil && userModel?.state == .joined  && state == .inqueue {
            state = .joined
        }else
        //被取消上台或上麦
        if userModel == nil && state == .joined && tmpType == type {
            state = .quit
        }else
        //被取消上台或上麦邀请
        if userModel == nil && state == .inqueue && tmpType == type {
            state = .abort
        }
        if preState != state {
            stateObserver?.receiveInteraction(owner: self, state: state, type: type, model: nil)
        }
        //初始状态
        if state == .quit || state == .abort {
            state = .normal
            tmpType = self.type
        }
    }
}
