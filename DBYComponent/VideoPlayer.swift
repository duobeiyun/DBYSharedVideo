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
protocol Creator {
    static func create(url: URL) -> VideoPlayer
}
class TencentCreator: Creator {
    static func create(url: URL) -> VideoPlayer {
        return TencentVideoPlayer(url: url)
    }
}
class AliCreator: Creator {
    static func create(url: URL) -> VideoPlayer {
        return AliVideoPlayer(url: url)
    }
}
class VideoPlayerFactory<T> where T:Creator {
    static func getPlayer(url: URL) -> VideoPlayer {
        return T.create(url: url)
    }
}
class TencentVideoPlayer: VideoPlayer {
    var playerView: LiveEBVideoView
    
    required init(url: URL) {
        playerView = LiveEBVideoView()
        playerView.liveEBURL = url.absoluteString
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
class AliVideoPlayer: VideoPlayer {
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
    }
}
extension AliVideoPlayer {
    func addPlayerView(_ view: UIView) {
        player.playerView = view
    }
    
    func removePlayerView() {
        
    }
}
