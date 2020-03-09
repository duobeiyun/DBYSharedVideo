//
//  DBYSystemControl.swift
//  DBY1VNUI
//
//  Created by 钟凡 on 2019/10/11.
//

import UIKit
import MediaPlayer

public let volumeChangeNotification: NSNotification.Name = NSNotification.Name(rawValue: "volumeChangeNotification")

class DBYSystemControl: NSObject {
    static let shared = DBYSystemControl()
    
    let systemVolumeView = MPVolumeView()
    
    var brightness:CGFloat = 0
    var volume:Float = 0
    var volumeViewSlider:UISlider?
    
    private override init() {
        super.init()
        let audioSession = AVAudioSession()
        try? audioSession.setActive(true)
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            let value = change?[.newKey] as? Float ?? volume
            NotificationCenter.default.post(name: volumeChangeNotification, object: value)
        }
    }
    func getBrightness() -> CGFloat {
        if brightness == 0 {
            brightness = UIScreen.main.brightness
        }
        return brightness
    }
    func setBrightness(value: CGFloat) {
        if value > 1 {
            brightness = 1
        }else if value < 0 {
            brightness = 0
        }else {
            brightness = value
        }
        UIScreen.main.brightness = brightness
    }
    func setVolume(value: Float) {
        if value > 1 {
            volume = 1
        }else if value < 0 {
            volume = 0
        }else {
            volume = value
        }
        if let slider = getVolumeViewSlider() {
            slider.setValue(volume, animated: false)
        }
    }
    func getVolume() -> Float {
        let audioSession = AVAudioSession.sharedInstance()
        volume = audioSession.outputVolume
        return volume
    }
    func getVolumeViewSlider() -> UISlider? {
        if let slider = volumeViewSlider {
            return slider
        }
        
        for view in systemVolumeView.subviews {
            if let slider = view as? UISlider {
                volumeViewSlider = slider
                break
            }
        }
        return nil
    }
    func beginControl() {
        systemVolumeView.frame = CGRect(x: -500, y: -500, width: 0, height: 0)
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(systemVolumeView, at: 0)
    }
    func endControl() {
        systemVolumeView.frame = .zero
        systemVolumeView.removeFromSuperview()
    }
}
