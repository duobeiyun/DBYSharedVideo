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

protocol VideoPlayerControl {
    func start()
    func pause()
    func resume()
    func stop()
}
extension VideoPlayerControl {
    func start() {
        
    }
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    func stop() {
        
    }
}
protocol VideoPlayerViewable {
    func addPlayerView(_ view: UIView)
    func removePlayerView()
}
extension VideoPlayerViewable {
    func addPlayerView(_ view: UIView) {
        
    }
    
    func removePlayerView() {
        
    }
}
protocol VideoPlayerStateDelegate: NSObjectProtocol {
    func connected()
    func connecting()
    func disconnected()
    func stutter()
}
class VideoPlayer: NSObject, VideoPlayerControl, VideoPlayerViewable {
    weak var delegate: VideoPlayerStateDelegate?
    
    required init(url: URL) {
        
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
}
extension TencentVideoPlayer {
    func start() {
        playerView.start()
    }
    func pause() {
        playerView.pause()
    }
    func resume() {
        playerView.resume()
    }
    func stop() {
        playerView.stop()
    }
}
extension TencentVideoPlayer {
    func addPlayerView(_ view: UIView) {
        view.addSubview(playerView)
        playerView.frame = view.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func removePlayerView() {
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
}
extension AliVideoPlayer {
    func start() {
        player.start()
    }
    
    func pause() {
        player.pause()
    }
    
    func resume() {
        player.start()
    }
    
    func stop() {
        player.stop()
        player.destroy()
    }
}
extension AliVideoPlayer {
    func addPlayerView(_ view: UIView) {
        player.playerView = view
    }
    
    func removePlayerView() {
        
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
