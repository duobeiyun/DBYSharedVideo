//
//  VideoPlayer.swift
//  DBYSharedVideoDemo
//
//  Created by 钟凡 on 2020/12/4.
//  Copyright © 2020 duobei. All rights reserved.
//

import Foundation
import AliyunPlayer
import LiveEB_IOS

protocol VideoPlayerStateDelegate: NSObjectProtocol {
    func connected()
    func connecting()
    func disconnected()
    func stutter()
}

class VideoPlayer: NSObject {
    weak var delegate: VideoPlayerStateDelegate?
    
    required init(url: URL) {
        
    }
    
    func start() {
        
    }
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    func stop() {
        
    }
    
    func addPlayerView(_ view: UIView) {
        
    }
    
    func removePlayerView() {
        
    }
}
protocol VideoPlayerFactory {
    static func create(url: URL) -> VideoPlayer
}
class TencentPlayerFactory: VideoPlayerFactory {
    static func create(url: URL) -> VideoPlayer {
        return TencentVideoPlayer(url: url)
    }
}
class AliPlayerFactory: VideoPlayerFactory {
    static func create(url: URL) -> VideoPlayer {
        return AliVideoPlayer(url: url)
    }
}
class TencentVideoPlayer: VideoPlayer {
    var playerView: LiveEBVideoView
    let pullStream = "https://overseas-webrtc.liveplay.myqcloud.com/webrtc/v1/pullstream"
    let stopStream = "https://overseas-webrtc.liveplay.myqcloud.com/webrtc/v1/stopstream"
    
    required init(url: URL) {
        playerView = LiveEBVideoView()
        super.init(url: url)
        playerView.delegate = self
        playerView.setLiveURL(url.absoluteString, pullStream: pullStream, stopStream: stopStream)
    }
    override func start() {
        playerView.start()
    }
    override func pause() {
        playerView.pause()
    }
    override func resume() {
        playerView.resume()
    }
    override func stop() {
        playerView.stop()
    }
    override func addPlayerView(_ view: UIView) {
        view.addSubview(playerView)
        playerView.frame = view.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func removePlayerView() {
        playerView.removeFromSuperview()
    }
}
extension TencentVideoPlayer: LiveEBVideoViewDelegate {
    func videoView(_ videoView: LiveEBVideoView, didError error: Error) {
        
    }
    
    func videoView(_ videoView: LiveEBVideoView, didChangeVideoSize size: CGSize) {
        
    }
    func showStats(_ videoView: LiveEBVideoView, statReport: LEBStatReport) {
        if statReport.fps < 5 {
            delegate?.stutter()
        }
    }
}
class AliVideoPlayer: VideoPlayer {
    var player: AliPlayer
    var urlSource: AVPUrlSource
    
    required init(url: URL) {
        player = AliPlayer()
        urlSource = AVPUrlSource()
        super.init(url: url)
        urlSource.playerUrl = url
        player.setUrlSource(urlSource)
        player.delegate = self
        player.prepare()
    }
    
    override func start() {
        player.start()
    }
    
    override func pause() {
        player.pause()
    }
    
    override func resume() {
        player.start()
    }
    
    override func stop() {
        player.stop()
        player.destroy()
    }
    
    override func addPlayerView(_ view: UIView) {
        player.playerView = view
    }
    
    override func removePlayerView() {
        
    }
}
extension AliVideoPlayer: AVPDelegate {
    func onPlayerEvent(_ player: AliPlayer!, eventType: AVPEventType) {
        
    }
    func onPlayerEvent(_ player: AliPlayer!, eventWithString: AVPEventWithString, description: String!) {
        if eventWithString == EVENT_PLAYER_RTS_SERVER_MAYBE_DISCONNECT {
            
        }else if eventWithString == EVENT_PLAYER_RTS_SERVER_RECOVER {
            
        }
    }
    func onError(_ player: AliPlayer!, errorModel: AVPErrorModel!) {
        
    }
    func onVideoSizeChanged(_ player: AliPlayer!, width: Int32, height: Int32, rotation: Int32) {
        
    }
    func onPlayerStatusChanged(_ player: AliPlayer!, oldStatus: AVPStatus, newStatus: AVPStatus) {
        if oldStatus == AVPStatusError {
            delegate?.stutter()
        }
    }
}
