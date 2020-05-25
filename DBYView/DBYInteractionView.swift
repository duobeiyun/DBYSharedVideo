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
    
    func switchInteraction(owner: DBYInteractionView, type: DBYInteractionType)
    func closeInteraction(owner: DBYInteractionView, type: DBYInteractionType)
    func interactionAlert(owner: DBYInteractionView, message: String)
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
    
    private lazy var models:[DBYInteractionModel] = [DBYInteractionModel]()
    private lazy var audioList:[DBYInteractionModel] = [DBYInteractionModel]()
    private lazy var videoList:[DBYInteractionModel] = [DBYInteractionModel]()
    
    var type: DBYInteractionType = .audio
    
    var userId:String?
    var userName:String?
    var userRole:Int = 0
    
    var stateDict:[DBYInteractionType:DBYInteractionState] = [
        .audio: .normal,
        .video: .normal
    ]
    
    let btnHeight:CGFloat = 30
    let cellId = "DBYInteractionCell"
    
    @IBAction func audioAction(sender: UIButton) {
        switchType(.audio)
        videoButton.setBackgroudnStyle(fillColor: DBYStyle.middleGray, strokeColor: DBYStyle.middleGray, radius: btnHeight * 0.5)
        videoButton.setTitleColor(UIColor.white, for: .normal)
        audioButton.setBackgroudnStyle(fillColor: DBYStyle.yellow, strokeColor: DBYStyle.yellow, radius: btnHeight * 0.5)
        audioButton.setTitleColor(DBYStyle.brown, for: .normal)
        delegate?.switchInteraction(owner: self, type: .audio)
    }
    @IBAction func videoAction(sender: UIButton) {
        switchType(.video)
        videoButton.setBackgroudnStyle(fillColor: DBYStyle.yellow, strokeColor: DBYStyle.yellow, radius: btnHeight * 0.5)
        videoButton.setTitleColor(DBYStyle.brown, for: .normal)
        audioButton.setBackgroudnStyle(fillColor: DBYStyle.middleGray, strokeColor: DBYStyle.middleGray, radius: btnHeight * 0.5)
        audioButton.setTitleColor(UIColor.white, for: .normal)
        delegate?.switchInteraction(owner: self, type: .video)
    }
    @IBAction func closeAction(sender: UIButton) {
        delegate?.closeInteraction(owner: self, type: type)
    }
    @IBAction func applyAction(sender: UIButton) {
        let state = stateDict[type]
        if stateDict[.audio] != .normal && type == .video {
            delegate?.interactionAlert(owner: self, message: "正在上麦操作")
            return
        }
        if stateDict[.video] != .normal && type == .audio {
            delegate?.interactionAlert(owner: self, message: "正在上台操作")
            return
        }
        if state == .normal {
            delegate?.requestInteraction(owner: self, state: .inqueue, type: type)
        }
        if state == .inqueue {
            delegate?.requestInteraction(owner: self, state: .abort, type: type)
        }
        if state == .joined {
            delegate?.requestInteraction(owner: self, state: .quit, type: type)
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
        audioButton.setBackgroudnStyle(fillColor: DBYStyle.yellow,
                                       strokeColor: DBYStyle.yellow,
                                       radius: btnHeight * 0.5)
        videoButton.setBackgroudnStyle(fillColor: DBYStyle.middleGray,
                                       strokeColor: DBYStyle.middleGray,
                                       radius: btnHeight * 0.5)
        videoButton.setTitleColor(.white, for: .normal)
        applyButton.setBackgroudnStyle(fillColor: DBYStyle.yellow, strokeColor: DBYStyle.brown, radius: 20)
    }
    //不更新数据
    func switchType(_ type: DBYInteractionType) {
        self.type = type
        
        updateContent()
        updateButton()
    }
    //更新数据
    func set(models:[DBYInteractionModel], for type:DBYInteractionType) {
        self.type = type
        self.models = models
        
        if type == .audio {
            self.audioList = models
        }
        if type == .video {
            self.videoList = models
        }
        updateContent()
        updateButton()
    }
    func updateButton() {
        let state = stateDict[type]
        if state == .normal && type == .audio {
            applyButton.setTitle("申请语音上麦", for: .normal)
        }
        if state == .inqueue && type == .audio {
            applyButton.setTitle("正在申请上麦，点击取消", for: .normal)
        }
        if state == .joined && type == .audio {
            applyButton.setTitle("正在上麦中，点击挂断", for: .normal)
        }
        if state == .normal && type == .video {
            applyButton.setTitle("申请视频上台", for: .normal)
        }
        if state == .inqueue && type == .video {
            applyButton.setTitle("正在申请上台，点击取消", for: .normal)
        }
        if state == .joined && type == .video {
            applyButton.setTitle("正在上台中，点击挂断", for: .normal)
        }
    }
    func updateContent() {
        var count = 0
        var userModel:DBYInteractionModel?
        var typeValue = ""
        
        if type == .audio {
            typeValue = "上麦"
            models = audioList
        }
        if type == .video {
            typeValue = "上台"
            models = videoList
        }
        for model in models {
            if model.state == .joined {
                count += 1;
            }
            if model.userId == userId {
                userModel = model
            }
        }
        let state = stateDict[type]
        //被邀请上台或上麦
        if userModel != nil && userModel?.state == .inqueue {
            delegate?.receiveInteraction(owner: self, state: .inqueue, type: type, model: userModel)
            stateDict[type] = .inqueue
        }
        //上台或上麦中
        if userModel != nil && userModel?.state == .joined {
            delegate?.receiveInteraction(owner: self, state: .joined, type: type, model: userModel)
            stateDict[type] = .joined
        }
        //被取消上台或上麦
        if userModel == nil && state == .joined {
            delegate?.receiveInteraction(owner: self, state: .quit, type: type, model: userModel)
            stateDict[type] = .normal
        }
        //被取消上台或上麦邀请
        if userModel == nil && state == .inqueue {
            delegate?.receiveInteraction(owner: self, state: .abort, type: type, model: nil)
            stateDict[type] = .normal
        }
        
        label.text = "\(count)人正在" + typeValue
        tableView.reloadData()
    }
}
extension DBYInteractionView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
extension DBYInteractionView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let interactionCell = cell as? DBYInteractionCell
        let model = models[indexPath.row]
        interactionCell?.type = type
        interactionCell?.setModel(model)
        return cell
    }
}
