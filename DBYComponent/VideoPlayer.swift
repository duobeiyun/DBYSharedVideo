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
protocol VideoPlayerViewable {
    func addPlayerView(_ view: UIView)
    func removePlayerView()
}
protocol VideoPlayer: VideoPlayerViewable, VideoPlayerControl {
    
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
class AliVideoPlayer: NSObject, VideoPlayer {
    var player: AliPlayer
    var urlSource: AVPUrlSource
    
    required init(url: URL) {
        player = AliPlayer()
        urlSource = AVPUrlSource()
        urlSource.playerUrl = url
        player.setUrlSource(urlSource)
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
    func onPlayerEvent(_ player: AliPlayer!, eventWithString: AVPEventWithString, description: String!) {
        if eventWithString == EVENT_PLAYER_RTS_SERVER_MAYBE_DISCONNECT {
            
        }else if eventWithString == EVENT_PLAYER_RTS_SERVER_RECOVER {
            
        }
    }
}
