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
class DBYInteractionInfo {
    var type: DBYInteractionType
    var state: DBYInteractionState = .normal
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
    
    var userId:String?
    var userName:String?
    var userRole:Int = 0
    
    let btnHeight:CGFloat = 30
    let cellId = "DBYInteractionCell"
    
    @IBAction func audioAction(sender: UIButton) {
        switchButton(.audio)
    }
    @IBAction func videoAction(sender: UIButton) {
        switchButton(.video)
    }
    @IBAction func closeAction(sender: UIButton) {
        delegate?.closeInteraction(owner: self, type: currentInfo.type)
    }
    @IBAction func applyAction(sender: UIButton) {
        if currentInfo.state == .normal {
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
        audioButton.setBackgroudnStyle(fillColor: DBYStyle.yellow,
                                       strokeColor: DBYStyle.yellow,
                                       radius: btnHeight * 0.5)
        videoButton.setBackgroudnStyle(fillColor: DBYStyle.middleGray,
                                       strokeColor: DBYStyle.middleGray,
                                       radius: btnHeight * 0.5)
        videoButton.setTitleColor(.white, for: .normal)
        applyButton.setBackgroudnStyle(fillColor: DBYStyle.yellow, strokeColor: DBYStyle.brown, radius: 20)
    }
    //本地触发
    func switchButton(_ type: DBYInteractionType) {
        if type == .audio {
            currentInfo = audioInfo
            videoButton.setBackgroudnStyle(fillColor: DBYStyle.middleGray, strokeColor: DBYStyle.middleGray, radius: btnHeight * 0.5)
            videoButton.setTitleColor(UIColor.white, for: .normal)
            audioButton.setBackgroudnStyle(fillColor: DBYStyle.yellow, strokeColor: DBYStyle.yellow, radius: btnHeight * 0.5)
            audioButton.setTitleColor(DBYStyle.brown, for: .normal)
            delegate?.switchInteraction(owner: self, type: .audio)
        }
        if type == .video {
            currentInfo = videoInfo
            videoButton.setBackgroudnStyle(fillColor: DBYStyle.yellow, strokeColor: DBYStyle.yellow, radius: btnHeight * 0.5)
            videoButton.setTitleColor(DBYStyle.brown, for: .normal)
            audioButton.setBackgroudnStyle(fillColor: DBYStyle.middleGray, strokeColor: DBYStyle.middleGray, radius: btnHeight * 0.5)
            audioButton.setTitleColor(UIColor.white, for: .normal)
            delegate?.switchInteraction(owner: self, type: .video)
        }
        
        updateContent(type: type)
        updateButton(type: type)
    }
    //消息触发
    func set(models:[DBYInteractionModel], for type:DBYInteractionType) {
        //更新数据
        if type == .audio {
            audioInfo.models = models
        }
        if type == .video {
            videoInfo.models = models
        }
        //切换状态
        switchButton(type)
    }
    func updateButton(type: DBYInteractionType) {
        if currentInfo.state == .normal && type == .audio {
            applyButton.setTitle("申请语音上麦", for: .normal)
        }
        if currentInfo.state == .inqueue && type == .audio {
            applyButton.setTitle("正在申请上麦，点击取消", for: .normal)
        }
        if currentInfo.state == .joined && type == .audio {
            applyButton.setTitle("正在上麦中，点击挂断", for: .normal)
        }
        if currentInfo.state == .normal && type == .video {
            applyButton.setTitle("申请视频上台", for: .normal)
        }
        if currentInfo.state == .inqueue && type == .video {
            applyButton.setTitle("正在申请上台，点击取消", for: .normal)
        }
        if currentInfo.state == .joined && type == .video {
            applyButton.setTitle("正在上台中，点击挂断", for: .normal)
        }
    }
    func updateContent(type: DBYInteractionType) {
        var count = 0
        var userModel:DBYInteractionModel?
        var typeValue = ""
        
        if type == .audio {
            typeValue = "上麦"
            currentInfo = audioInfo
        }
        if type == .video {
            typeValue = "上台"
            currentInfo = videoInfo
        }
        for model in currentInfo.models {
            if model.state == .joined {
                count += 1
            }
            if model.userId == userId {
                userModel = model
            }
        }
        label.text = "\(count)人正在" + typeValue
        tableView.reloadData()
        
        //被邀请上台或上麦
        if userModel != nil && userModel?.state == .inqueue && currentInfo.state == .normal {
            delegate?.receiveInteraction(owner: self, state: .inqueue, type: type, model: userModel)
            currentInfo.state = .inqueue
        }else
        //上台或上麦
        if userModel != nil && userModel?.state == .joined  && currentInfo.state == .inqueue {
            delegate?.receiveInteraction(owner: self, state: .joined, type: type, model: userModel)
            currentInfo.state = .joined
        }else
        //被取消上台或上麦
        if userModel == nil && currentInfo.state == .joined {
            delegate?.receiveInteraction(owner: self, state: .quit, type: type, model: userModel)
            currentInfo.state = .normal
        }else
        //拒绝上台或上麦
        if userModel == nil && currentInfo.state == .inqueue {
            delegate?.receiveInteraction(owner: self, state: .abort, type: type, model: nil)
            currentInfo.state = .normal
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
