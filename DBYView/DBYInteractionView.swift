//
//  DBYInteractionView.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/5/19.
//

import UIKit
import DBYSDK_dylib

protocol DBYInteractionViewDelegate: NSObjectProtocol {
    func requestInteraction(owner: DBYInteractionView, state: DBYInteractionState, type: DBYInteractionType)
    func receiveInteraction(owner: DBYInteractionView, state: DBYInteractionState, type: DBYInteractionType, model: DBYInteractionModel?)
    func interactionStateChanged(owner: DBYInteractionView, old: DBYInteractionModel, new: DBYInteractionModel)
    
    func switchInteraction(owner: DBYInteractionView, type: DBYInteractionType)
    func closeInteraction(owner: DBYInteractionView, type: DBYInteractionType)
    func interactionAlert(owner: DBYInteractionView, message: String)
    func waittingForVideo(owner: DBYInteractionView, count: Int)
}
class DBYInteractionInfo {
    var type: DBYInteractionType
    var state: DBYInteractionState = .normal
    var joinedCount: Int = 0
    var inqueueCount: Int = 0
    lazy var models:[DBYInteractionModel] = [DBYInteractionModel]()
    init(type:DBYInteractionType) {
        self.type = type
    }
}
class DBYInteractionView: DBYNibView {
    @IBOutlet weak var audioButton:DBYButton!
    @IBOutlet weak var videoButton:DBYButton!
    @IBOutlet weak var closeButton:UIButton!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var label:UILabel!
    @IBOutlet weak var applyButton:DBYButton!
    @IBOutlet weak var bottomLayout:NSLayoutConstraint!
    
    weak var delegate:DBYInteractionViewDelegate?
    
    lazy var audioInfo = DBYInteractionInfo(type: .audio)
    lazy var videoInfo = DBYInteractionInfo(type: .video)
    lazy var currentInfo = DBYInteractionInfo(type: .audio)
    lazy var models = [DBYInteractionModel]()
    var currentModel: DBYInteractionModel?
    
    var userId:String?
    var userName:String?
    var userRole:Int = 0
    
    let btnHeight:CGFloat = 30
    let cellId = "DBYInteractionCell"
    
    @IBAction func audioAction(sender: UIButton) {
        switchToAudio()
    }
    @IBAction func videoAction(sender: UIButton) {
        switchToVideo()
    }
    @IBAction func closeAction(sender: UIButton) {
        delegate?.closeInteraction(owner: self, type: currentInfo.type)
    }
    @IBAction func applyAction(sender: UIButton) {
        if currentInfo.state == .normal {
            if audioInfo.state == .joined || videoInfo.state == .joined {
                return
            }
            delegate?.requestInteraction(owner: self, state: .inqueue, type: currentInfo.type)
        }
        if currentInfo.state == .inqueue {
            delegate?.requestInteraction(owner: self, state: .abort, type: currentInfo.type)
        }
        if currentInfo.state == .joined {
            delegate?.requestInteraction(owner: self, state: .quit, type: currentInfo.type)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        if isIphoneXSeries() {
            bottomLayout.constant = 42
        }
        let bundle = Bundle(for: DBYInteractionView.self)
        let nib = UINib(nibName: cellId, bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        audioButton.setBackgroundStyle(fillColor: DBYStyle.yellow,
                                       borderColor: DBYStyle.yellow,
                                       radius: btnHeight * 0.5)
        videoButton.setBackgroundStyle(fillColor: DBYStyle.middleGray,
                                       borderColor: DBYStyle.middleGray,
                                       radius: btnHeight * 0.5)
        videoButton.setTitleColor(.white, for: .normal)
        applyButton.setBackgroundStyle(fillColor: DBYStyle.yellow, borderColor: DBYStyle.brown, radius: 20)
    }
    //
    func switchToAudio() {
        currentInfo = audioInfo
        delegate?.switchInteraction(owner: self, type: .audio)
        videoButton.setBackgroundStyle(fillColor: DBYStyle.middleGray, borderColor: DBYStyle.middleGray, radius: btnHeight * 0.5)
        videoButton.setTitleColor(UIColor.white, for: .normal)
        audioButton.setBackgroundStyle(fillColor: DBYStyle.yellow, borderColor: DBYStyle.yellow, radius: btnHeight * 0.5)
        audioButton.setTitleColor(DBYStyle.brown, for: .normal)
        label.text = "\(currentInfo.joinedCount)人正在上麦"
    }
    func switchToVideo() {
        currentInfo = videoInfo
        delegate?.switchInteraction(owner: self, type: .video)
        videoButton.setBackgroundStyle(fillColor: DBYStyle.yellow, borderColor: DBYStyle.yellow, radius: btnHeight * 0.5)
        videoButton.setTitleColor(DBYStyle.brown, for: .normal)
        audioButton.setBackgroundStyle(fillColor: DBYStyle.middleGray, borderColor: DBYStyle.middleGray, radius: btnHeight * 0.5)
        audioButton.setTitleColor(UIColor.white, for: .normal)
        label.text = "前方还有\(currentInfo.inqueueCount)人正在等待上台"
    }
    //本地触发
    func updateUI() {
        updateContent()
        updateBottomButton()
        
        tableView.reloadData()
    }
    //消息触发
    func set(models:[DBYInteractionModel], for type:DBYInteractionType) {
        //更新数据
        if type == .audio {
            diffModels(oldModels: audioInfo.models, newModels: models)
            audioInfo.models = models
        }
        if type == .video {
            diffModels(oldModels: videoInfo.models, newModels: models)
            videoInfo.models = models
        }
        //当前tab页才更新
        if type == currentInfo.type {
            updateUI()
        }
    }
    func updateBottomButton() {
        if currentInfo.state == .normal && currentInfo.type == .audio {
            applyButton.setTitle("申请语音上麦", for: .normal)
        }
        if currentInfo.state == .inqueue && currentInfo.type == .audio {
            applyButton.setTitle("正在申请上麦，点击取消", for: .normal)
        }
        if currentInfo.state == .joined && currentInfo.type == .audio {
            applyButton.setTitle("正在上麦中，点击挂断", for: .normal)
        }
        if currentInfo.state == .normal && currentInfo.type == .video {
            applyButton.setTitle("申请视频上台", for: .normal)
        }
        if currentInfo.state == .inqueue && currentInfo.type == .video {
            applyButton.setTitle("正在申请上台，点击取消", for: .normal)
        }
        if currentInfo.state == .joined && currentInfo.type == .video {
            applyButton.setTitle("正在上台中，点击挂断", for: .normal)
        }
    }
    func diffModels(oldModels: [DBYInteractionModel], newModels: [DBYInteractionModel]) {
        for old in oldModels {
            for new in newModels {
                if (old.state != new.state) {
                    //state change
                    delegate?.interactionStateChanged(owner: self, old: old, new: new)
                }
            }
        }
    }
    func updateContent() {
        var count = 0
        var inqueueCount = 0
        var userModel:DBYInteractionModel?
        
        for model in currentInfo.models {
            if model.state == .joined {
                count += 1
            }
            if model.userId == userId {
                userModel = model
            }
            if model.state == .inqueue && userModel == nil {
                inqueueCount += 1
            }
        }
        currentInfo.joinedCount = count
        currentInfo.inqueueCount = inqueueCount
        
        //被邀请上台或上麦
        if userModel != nil && userModel?.state == .inqueue && currentInfo.state == .normal {
            delegate?.receiveInteraction(owner: self, state: .inqueue, type: currentInfo.type, model: userModel)
            currentInfo.state = .inqueue
        }else
        //上台或上麦
        if userModel != nil && userModel?.state == .joined {
            delegate?.receiveInteraction(owner: self, state: .joined, type: currentInfo.type, model: userModel)
            currentInfo.state = .joined
        }else
        //被取消上台或上麦
        if userModel == nil && currentInfo.state == .joined {
            delegate?.receiveInteraction(owner: self, state: .quit, type: currentInfo.type, model: userModel)
            currentInfo.state = .normal
        }else
        //拒绝上台或上麦
        if userModel == nil && currentInfo.state == .inqueue {
            delegate?.receiveInteraction(owner: self, state: .abort, type: currentInfo.type, model: nil)
            currentInfo.state = .normal
        }
        // 等待上台
        if currentInfo.state == .inqueue && currentInfo.type == .video && inqueueCount > 0 {
            delegate?.waittingForVideo(owner: self, count: inqueueCount)
        }
    }
}
extension DBYInteractionView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
extension DBYInteractionView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentInfo.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let interactionCell = cell as? DBYInteractionCell
        let model = currentInfo.models[indexPath.row]
        interactionCell?.type = currentInfo.type
        interactionCell?.setModel(model)
        return cell
    }
}
